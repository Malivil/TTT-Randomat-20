local EVENT = {}

EVENT.Title = "What gamemode is this again?"
EVENT.AltTitle = "Murder"
EVENT.Description = "Bystanders gather loot to get a gun! Murderers... murder!"
EVENT.id = "murder"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"gamemode", "biased_traitor", "biased", "item", "rolechange", "modelchange", "largeimpact"}

local murdererRatioConVar    = CreateConVar("randomat_murder_murderer_ratio",     7,  FCVAR_NONE, "Bystanders per murderer", 1, 31)
local hasGunRatioConVar      = CreateConVar("randomat_murder_gun_ratio",          7,  FCVAR_NONE, "Bystanders per starting gun", 1, 31)
local lootCountConVar        = CreateConVar("randomat_murder_loot_spawn_amount",  10, FCVAR_NONE, "Loot on the map per player at any one time", 1, 50)
local lootRespawnTimeConVar  = CreateConVar("randomat_murder_loot_respawn",       12, FCVAR_NONE, "Time (s) before collected loot is replaced", 1, 120)
local tkGunDropConVar        = CreateConVar("randomat_murder_tk_drop_gun",        1,  FCVAR_NONE, "Whether the gun is dropped on a team kill")
local tkGunBanTimeConVar     = CreateConVar("randomat_murder_tk_pickup_ban",      20, FCVAR_NONE, "Time (s) a gun can't be picked up after a team kill", 0, 300)
local tkBlindTimeConVar      = CreateConVar("randomat_murder_tk_blind",           5,  FCVAR_NONE, "Blind time (s) after a team kill", 0, 60)
local tkKilledConVar         = CreateConVar("randomat_murder_tk_kill",            0,  FCVAR_NONE, "Whether a bystander is killed if they team kill")
local murdererFogTimeConVar  = CreateConVar("randomat_murder_fog_time",           60, FCVAR_NONE, "Time (s) without killing before murderer is revealed", 0, 900)
local flashlightTimeConVar   = CreateConVar("randomat_murder_flashlight",         10, FCVAR_NONE, "Time (s) of flashlight battery (0 = infinite)", 0, 120)
local undiguiseOnKillConVar  = CreateConVar("randomat_murder_undisguise_on_kill", 1,  FCVAR_NONE, "Whether to remove a Murderer's disguise when they kill", 0, 1)

local lootNeededConVar
local bystanderSprintConVar
local murdererSprintConVar
local carrySpeedConVar
local knifeReplaceTimeConVar

util.AddNetworkString("Rdmt_Murder_Footstep")
util.AddNetworkString("Rdmt_Murder_LootSync")
util.AddNetworkString("Rdmt_Murder_Taunt")
util.AddNetworkString("Rdmt_Murder_Dead")

resource.AddFile("materials/thieves/footprint.vmt")
resource.AddFile("materials/thieves/footprint.vtf")

------------------------------------------------------
-- Master tables of stuff
------------------------------------------------------

local phoneticNames = {
    "Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliett", "Kilo", "Lima", "Mike",
    "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu"
}

local playerModels = {
    {"male03", "male"}, {"male04", "male"}, {"male05", "male"}, {"male07", "male"}, {"male06", "male"},
    {"male09", "male"}, {"male01", "male"}, {"male02", "male"}, {"male08", "male"},
    {"female06", "female"}, {"female01", "female"}, {"female03", "female"}, {"female05", "female"},
    {"female02", "female"}, {"female04", "female"},
    {"refugee01", "male"}, {"refugee02", "male"}, {"refugee03", "male"}, {"refugee04", "male"}
}

local lootModels = {
    "models/props_combine/breenbust.mdl", "models/props_lab/huladoll.mdl", "models/props_junk/glassbottle01a.mdl",
    "models/props_junk/glassjug01.mdl", "models/props_lab/cactus.mdl", "models/props_lab/desklamp01.mdl",
    "models/props_lab/clipboard.mdl", "models/props_c17/suitcase_passenger_physics.mdl", "models/props_c17/suitcase001a.mdl",
    "models/items/car_battery01.mdl", "models/props/de_tides/vending_turtle.mdl", "models/props/cs_militia/toothbrushset01.mdl",
    "models/props/cs_militia/circularsaw01.mdl", "models/props/cs_militia/axe.mdl", "models/Gibs/HGIBS.mdl",
    "models/props_c17/doll01.mdl", "models/Gibs/Antlion_gib_Large_2.mdl", "models/props_c17/BriefCase001a.mdl",
    "models/props_combine/breenclock.mdl", "models/props_junk/sawblade001a.mdl", "models/props_c17/tools_wrench01a.mdl",
    "models/props_c17/consolebox01a.mdl", "models/props_c17/cashregister01a.mdl", "models/props/cs_italy/bananna_bunch.mdl",
    "models/props/cs_italy/bananna.mdl", "models/props/cs_italy/orange.mdl", "models/props_lab/frame002a.mdl",
    "models/props_junk/watermelon01.mdl"
}

local taunts = {
    help = {
        male   = {"vo/npc/male01/help01.wav"},
        female = {"vo/npc/female01/help01.wav"}
    },
    scream = {
        male   = {"vo/npc/male01/runforyourlife01.wav", "vo/npc/male01/runforyourlife02.wav", "vo/npc/male01/runforyourlife03.wav", "vo/npc/male01/watchout.wav", "vo/npc/male01/gethellout.wav"},
        female = {"vo/npc/female01/runforyourlife01.wav", "vo/npc/female01/runforyourlife02.wav", "vo/npc/female01/watchout.wav", "vo/npc/female01/gethellout.wav"}
    },
    morose = {
        male   = {"vo/npc/female01/question31.wav", "vo/npc/male01/question30.wav", "vo/npc/male01/question20.wav", "vo/npc/male01/question25.wav", "vo/npc/male01/question15.wav"},
        female = {"vo/npc/female01/question30.wav", "vo/npc/female01/question25.wav", "vo/npc/female01/question20.wav", "vo/npc/female01/question15.wav"}
    },
    funny = {
        male   = {"vo/npc/male01/doingsomething.wav", "vo/npc/male01/busy02.wav", "vo/npc/male01/gordead_ques07.wav", "vo/npc/male01/notthemanithought01.wav", "vo/npc/male01/notthemanithought02.wav", "vo/npc/male01/question06.wav", "vo/npc/male01/question09.wav"},
        female = {"vo/npc/female01/doingsomething.wav", "vo/npc/female01/busy02.wav", "vo/npc/female01/gordead_ques07.wav", "vo/npc/female01/notthemanithought01.wav", "vo/npc/female01/notthemanithought02.wav", "vo/npc/female01/question06.wav", "vo/npc/female01/question09.wav"}
    }
}

local allowedWeapons = {
    weapon_ttt_randomatmurderhands    = true,
    weapon_ttt_randomatmurderrevolver = true,
    weapon_ttt_randomatmurderknife    = true
}

local playerData       = {}
local lootSpawnPoints  = {}
local stripWeaponTimer = 0

------------------------------------------------------
-- Helpers
------------------------------------------------------

local function IsMurderer(ply)
    return IsPlayer(ply) and ply:Alive() and not ply:IsSpec() and ply:GetRole() == ROLE_TRAITOR
end

local function IsGunBanned(ply)
    return ply:GetNWFloat("RdmtMurderGunBanEnd", 0) > CurTime()
end

local function SetIdentity(ply, name, colour)
    ply:SetNWString("RdmtMurderName", name)
    ply:SetNWVector("RdmtMurderColour", colour)
    ply:SetPlayerColor(colour)
end

-- Override role strings for body searches
local originalNameInnocent
local originalNameExtInnocent
local originalNamePluralInnocent
local originalNameTraitor
local originalNameExtTraitor
local originalNamePluralTraitor

local function OverrideRoleStrings()
    originalNameInnocent       = ROLE_STRINGS[ROLE_INNOCENT]
    originalNameExtInnocent    = ROLE_STRINGS_EXT[ROLE_INNOCENT]
    originalNamePluralInnocent = ROLE_STRINGS_PLURAL[ROLE_INNOCENT]
    originalNameTraitor        = ROLE_STRINGS[ROLE_TRAITOR]
    originalNameExtTraitor     = ROLE_STRINGS_EXT[ROLE_TRAITOR]
    originalNamePluralTraitor  = ROLE_STRINGS_PLURAL[ROLE_TRAITOR]

    ROLE_STRINGS[ROLE_INNOCENT]        = "Bystander"
    ROLE_STRINGS_EXT[ROLE_INNOCENT]    = "a Bystander"
    ROLE_STRINGS_PLURAL[ROLE_INNOCENT] = "Bystanders"
    ROLE_STRINGS[ROLE_TRAITOR]         = "Murderer"
    ROLE_STRINGS_EXT[ROLE_TRAITOR]     = "a Murderer"
    ROLE_STRINGS_PLURAL[ROLE_TRAITOR]  = "Murderers"
end

local function RestoreRoleStrings()
    if originalNameInnocent then
        ROLE_STRINGS[ROLE_INNOCENT]        = originalNameInnocent
        ROLE_STRINGS_EXT[ROLE_INNOCENT]    = originalNameExtInnocent
        ROLE_STRINGS_PLURAL[ROLE_INNOCENT] = originalNamePluralInnocent
        ROLE_STRINGS[ROLE_TRAITOR]         = originalNameTraitor
        ROLE_STRINGS_EXT[ROLE_TRAITOR]     = originalNameExtTraitor
        ROLE_STRINGS_PLURAL[ROLE_TRAITOR]  = originalNamePluralTraitor
    end

    originalNameInnocent       = nil
    originalNameExtInnocent    = nil
    originalNamePluralInnocent = nil
    originalNameTraitor        = nil
    originalNameExtTraitor     = nil
    originalNamePluralTraitor  = nil
end

local function StripConnies(ply)
    for _, wep in ipairs(ply:GetWeapons()) do
        local class = wep:GetClass()

        if not allowedWeapons[class] then
            ply:StripWeapon(class)
            ply:SetFOV(0, 0.2)
        end
    end
end

------------------------------------------------------
-- Loot stuff
------------------------------------------------------

-- Search for player spawn points, wepaon/ammo spawn points and loose weapons
local function FindLootSpawns()
    local spawnPoints = {}

    for _, ent in ents.Iterator() do
        local class = ent:GetClass()
        local unownedWeapon = ent:IsWeapon() and not IsValid(ent:GetOwner())

        if unownedWeapon or ent.AutoSpawnable or class == "ttt_random_weapon" or class == "ttt_random_ammo"
            or string.StartWith(class, "item_ammo") or string.StartWith(class, "item_box_buckshot") or string.StartWith(class, "info_player_") then
            table.insert(spawnPoints, ent:GetPos())
        end
    end

    return spawnPoints
end

local function SyncPlayerLoot(ply, playerLoot)
    if not IsValid(ply) then return end

    net.Start("Rdmt_Murder_LootSync")
        net.WriteTable(playerLoot)
    net.Send(ply)
end

-- Spawn a piece of loot for the given player
local function SpawnLoot(ply, data)
    if #lootSpawnPoints == 0 then return end

    -- Try to make loot be not all close together
    local pos
    for _ = 1, 10 do
        local potentialPoint = lootSpawnPoints[math.random(#lootSpawnPoints)]
        local farAway = true

        for _, otherPos in ipairs(data.loot) do
            if IsValid(otherPos) and otherPos:GetPos():DistToSqr(potentialPoint) < 5000 then
                farAway = false
                break
            end
        end

        if farAway then
            pos = potentialPoint
            break
        end
    end

    pos = pos or lootSpawnPoints[math.random(#lootSpawnPoints)]

    -- Hopefully make some of the props not float in mid air
    local tr = util.TraceLine({start = pos, endpos = pos - Vector(0, 0, 100), mask = MASK_SOLID_BRUSHONLY})
    if tr.Hit then pos = tr.HitPos end

    local lootProp = ents.Create("prop_dynamic")
    lootProp:SetModel(lootModels[math.random(#lootModels)])
    lootProp:SetPos(pos)
    lootProp:SetAngles(Angle(0, math.random(0, 360), 0))
    lootProp:Spawn()
    lootProp:SetSolid(SOLID_NONE)
    lootProp:SetPos(pos - Vector(0, 0, lootProp:OBBMins().z))

    for _, p in player.Iterator() do
        if p ~= ply then
            lootProp:SetPreventTransmit(p, true)
        end
    end

    table.insert(data.loot, lootProp)

    timer.Simple(0.1, function()
        SyncPlayerLoot(ply, data.loot) -- Sync updated list to client
    end)
end

-- Finds the closest bit of this player's loot that they're looking at and are close enough to grab
local function FindCollectableLoot(ply, lootProps)
    local eyePos      = ply:GetShootPos()
    local aimAngle    = ply:GetAimVector()
    local pickUpRange = 100
    local checkRange  = pickUpRange * 2
    local foundLoot   = nil

    -- Check whether there's something solid in the eye -> pickUpRange line
    local blockedTrace = util.TraceLine({
        start  = eyePos,
        endpos = eyePos + aimAngle * pickUpRange,
        mask   = MASK_SOLID_BRUSHONLY,
        filter = ply
    })

    -- If there was something solid in that line, limit pick up distance to the distance to the blocking thing
    local unblockedDistance = blockedTrace.Fraction * pickUpRange

    -- Check if the pick up line (lol) hits (or at least, KINDA hits) the loot prop
    for _, lootProp in ipairs(lootProps) do
        if IsValid(lootProp) and eyePos:DistToSqr(lootProp:GetPos()) < (checkRange * checkRange) then
            local hitPos, _, hitFraction = util.IntersectRayWithOBB(
                eyePos,
                aimAngle * pickUpRange,
                lootProp:WorldSpaceCenter(),
                lootProp:GetAngles(),
                lootProp:OBBMins(),
                lootProp:OBBMaxs()
            )

            -- If the pick up line hit the loot prop's bounding box...
            if hitPos then
                local lootDistance = hitFraction * pickUpRange

                -- ... make sure it's closer than anything blocking the block trace
                if lootDistance <= unblockedDistance then
                    foundLoot = lootProp
                end
            end
        end
    end

    return foundLoot
end

local function GiveGun(ply, data, fromLoot)
    if IsMurderer(ply) or ply:HasWeapon("weapon_ttt_randomatmurderrevolver") then return end

    if IsGunBanned(ply) then
        ply.beingGivenGun = true

        ply:Give("weapon_ttt_randomatmurderrevolver")

        timer.Simple(0.1, function()
            ply:SelectWeapon("weapon_ttt_randomatmurderhands")

            local wep = ply:GetWeapon("weapon_ttt_randomatmurderrevolver")
            ply:DropWeapon(wep)
        end)

        ply.beingGivenGun = false

        return
    end

    ply:Give("weapon_ttt_randomatmurderrevolver")

    if fromLoot then
        ply:SelectWeapon("weapon_ttt_randomatmurderrevolver")
    end
end

local function CollectLoot(ply, data, lootProp)
    for i = #data.loot, 1, -1 do
        if data.loot[i] == lootProp then
            table.remove(data.loot, i)
        end
    end

    lootProp:Remove()

    data.lootCollected = data.lootCollected + 1
    ply:SetNWInt("RdmtMurderLootCollected", data.lootCollected)
    ply:EmitSound("ambient/levels/canals/windchime2.wav", 100, math.random(40, 160))

    SyncPlayerLoot(ply, data.loot)

    -- Start the replacement timer if it isn't already running
    if not data.nextLootTime then
        data.nextLootTime = CurTime() + lootRespawnTimeConVar:GetFloat()
    end

    -- Give Bystander a gun when they collect enough loot (normal limit, then at 3 x normal limit)
    if not IsMurderer(ply) then
        local lootNeeded = lootNeededConVar:GetInt()

        if data.lootCollected == lootNeeded and not ply:HasWeapon("weapon_ttt_randomatmurderrevolver") then
            GiveGun(ply, data, true)
        end

        if data.lootCollected % (lootNeeded * 3) == 0 and not ply:HasWeapon("weapon_ttt_randomatmurderrevolver") then
            GiveGun(ply, data, true)
        end
    end
end

local function PunishShooter(ply)
    Randomat:SmallNotify(ply:GetNWString("RdmtMurderName", "Someone") .. " killed an innocent Bystander!")

    if tkGunDropConVar:GetBool() then
        ply:SelectWeapon("weapon_ttt_randomatmurderhands")

        timer.Simple(0.1, function()
            local wep = ply:GetWeapon("weapon_ttt_randomatmurderrevolver")
            ply:DropWeapon(wep)
        end)
    end

    local banTime = tkGunBanTimeConVar:GetFloat()
    if banTime > 0 then
        ply:SetNWFloat("RdmtMurderGunBanEnd", CurTime() + banTime)
    end

    local blindTime = tkBlindTimeConVar:GetFloat()
    if blindTime > 0 then
        ply:SetNWFloat("RdmtMurderBlindEndTime", CurTime() + blindTime)
    end

    if tkKilledConVar:GetBool() then
        ply:Kill()
    end
end

function EVENT:Begin()
    lootNeededConVar       = GetConVar("randomat_murder_loot_needed")
    bystanderSprintConVar  = GetConVar("randomat_murder_bystander_sprint")
    murdererSprintConVar   = GetConVar("randomat_murder_murderer_sprint")
    carrySpeedConVar       = GetConVar("randomat_murder_carry_slow")
    knifeReplaceTimeConVar = GetConVar("randomat_murder_knife_replace")

    playerData = {}
    stripWeaponTimer = 0
    OverrideRoleStrings()

    local players = self:GetAlivePlayers(true)

    -- Work out how many murderers and starting guns to have
    local murdererAmount = math.max(1, math.ceil(#players / (murdererRatioConVar:GetInt() + 1)))
    murdererAmount = math.min(murdererAmount, #players - 1)

    local gunAmount = math.ceil(#players / (hasGunRatioConVar:GetInt() + 1))
    gunAmount = math.min(gunAmount, #players - murdererAmount)

    -- Get weapon locations before removing weapons (oops)
    lootSpawnPoints = FindLootSpawns()

    -- Remove all the normal weapons and ammo lying around
    for _, ent in ents.Iterator() do
        local class = ent:GetClass()

        if (ent:IsWeapon() and not IsValid(ent:GetOwner())) or string.StartWith(class, "item_ammo") or string.StartWith(class, "item_box_buckshot") then
            ent:Remove()
        end
    end

    -- Hand out roles/names/colours/models
    local names = table.Copy(phoneticNames)
    table.Shuffle(names)

    table.Shuffle(players)
    for i, ply in ipairs(players) do
        Randomat:SetRole(ply, i <= murdererAmount and ROLE_TRAITOR or ROLE_INNOCENT)

        -- Double up names if we run out
        local name = names[i] or (names[math.random(#names)] .. " " .. names[math.random(#names)])
        local colour = Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1))

        local modelInfo = playerModels[math.random(#playerModels)]
        local model = player_manager.TranslatePlayerModel(modelInfo[1])

        Randomat:ForceSetPlayermodel(ply, {
            model            = model,
            playerColor      = colour,
            skin             = 0,
            viewOffset       = Vector(0, 0, 64),
            viewOffsetDucked = Vector(0, 0, 28)
        })

        SetIdentity(ply, name, colour)
        ply:SetNWInt("RdmtMurderLootCollected", 0)
        ply:SetNWBool("RdmtMurderFog", false)
        ply:SetNWBool("RdmtMurderCarrying", false)
        ply:SetNWFloat("RdmtMurderFlashlightCharge", 1)
        ply:SetNWFloat("RdmtMurderBlindEndTime", 0)
        ply:SetNWFloat("RdmtMurderGunBanEnd", 0)

        ply.FlashlightLocked = 0

        playerData[ply] = {
            name          = name,
            color         = colour,
            sex           = modelInfo[2],
            loot          = {},
            lootCollected = 0,
            lastKill      = CurTime(),
            knifeTime     = CurTime(),
            disguised     = false
        }
    end

    SendFullStateUpdate()

    timer.Simple(0, function()
        local bystanders = {}

        for ply, data in pairs(playerData) do
            if IsValid(ply) and ply:Alive() and not ply:IsSpec() then
                ply:StripWeapons()
                ply:Give("weapon_ttt_randomatmurderhands")

                if IsMurderer(ply) then
                    ply:Give("weapon_ttt_randomatmurderknife")
                    data.knifeTime = CurTime()
                else
                    table.insert(bystanders, ply)
                end

                -- Freeze players when role screen is up
                ply:Freeze(true)

                for _ = 1, lootCountConVar:GetInt() do
                    SpawnLoot(ply, data)
                end
            end
        end

        table.Shuffle(bystanders)
        for i = 1, gunAmount do
            if bystanders[i] then
                GiveGun(bystanders[i], playerData[bystanders[i]])
            end
        end
    end)

    -- Freeze during intro black screen
    timer.Create("Rdmt_Murder_Unfreeze", 5, 1, function()
        for _, ply in player.Iterator() do
            ply:Freeze(false)
        end
    end)

    local nextThink = CurTime()

    self:AddHook("Think", function()
        local now = CurTime()

        if now < nextThink then return end

        nextThink = nextThink + 0.1

        stripWeaponTimer = stripWeaponTimer + 1
        local batteryTime = flashlightTimeConVar:GetFloat()
        local fogTime = murdererFogTimeConVar:GetFloat()

        for ply, data in pairs(playerData) do
            if not IsValid(ply) then
                playerData[ply] = nil
            elseif ply:Alive() and not ply:IsSpec() then
                -- Drain battery if on/recharge at half speed if off
                if batteryTime > 0 then
                    local charge = ply:GetNWFloat("RdmtMurderFlashlightCharge", 1)

                    if ply:FlashlightIsOn() then
                        charge = charge - (0.1 / batteryTime)

                        if charge <= 0 then
                            charge = 0
                            ply:Flashlight(false)
                            ply.FlashlightLocked = now + 1.5
                        end
                    elseif charge < 1 then
                        charge = math.min(1, charge + (0.05 / batteryTime))
                    end

                    ply:SetNWFloat("RdmtMurderFlashlightCharge", charge)
                end

                -- Loot replacement
                if data.nextLootTime and now >= data.nextLootTime then
                    if #data.loot < lootCountConVar:GetInt() then
                        SpawnLoot(ply, data)
                    end

                    if #data.loot < lootCountConVar:GetInt() then
                        data.nextLootTime = now + lootRespawnTimeConVar:GetFloat()
                    else
                        data.nextLootTime = nil
                    end
                end

                if IsMurderer(ply) then
                    -- Murderer fog if they haven't killed in too long
                    if fogTime > 0 and now - data.lastKill >= fogTime then
                        ply:SetNWBool("RdmtMurderFog", true)
                    end

                    -- Replace a thrown knife if the thrower hasn't picked it up after too long
                    if ply:HasWeapon("weapon_ttt_randomatmurderknife") then
                        data.knifeTime = now
                    elseif now - data.knifeTime >= knifeReplaceTimeConVar:GetFloat() then
                        for _, e in ipairs(ents.FindByClass("weapon_ttt_randomatmurderknife")) do
                            if not IsValid(e:GetOwner()) then e:Remove() end
                        end

                        for _, e in ipairs(ents.FindByClass("prop_physics")) do
                            if e.rdmtMurderKnife then e:Remove() end
                        end

                        ply:Give("weapon_ttt_randomatmurderknife")
                        data.knifeTime = now
                    end
                end

                -- Strip non-allowed weapons every 0.5s just in case
                if stripWeaponTimer % 5 == 0 then
                    StripConnies(ply)
                end
            end
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        local class = wep:GetClass()

        if not allowedWeapons[class] then return false end

        if class == "weapon_ttt_randomatmurderknife" then return IsMurderer(ply) end

        if class == "weapon_ttt_randomatmurderrevolver" then
            if IsMurderer(ply) or ply:HasWeapon(class) then return false end
            if IsGunBanned(ply) and not ply.beingGivenGun then return false end
        end

        if ply:HasWeapon(class) then return false end

        return true
    end)

    self:AddHook("EntityTakeDamage", function(target, dmg)
        if not IsPlayer(target) then return end

        local attacker = dmg:GetAttacker()

        -- Punish Bystanders who kill other Bystanders
        if IsPlayer(attacker) and attacker ~= target and not IsMurderer(attacker) and not IsMurderer(target) then
            local wep = util.WeaponFromDamage(dmg)

            if IsValid(wep) and wep:GetClass() == "weapon_ttt_randomatmurderrevolver" then

                if IsValid(attacker) and attacker:Alive() then
                    PunishShooter(attacker)
                end
            end
        end
    end)

    self:AddHook("PlayerDeath", function(victim, inflictor, attacker)
        -- Dead players don't need their loot any more
        local victimData = playerData[victim]
        if victimData then
            for _, lootProp in ipairs(victimData.loot) do
                if IsValid(lootProp) then lootProp:Remove() end
            end

            victimData.loot = {}
            victimData.nextLootTime = nil

            SyncPlayerLoot(victim, victimData.loot)

            timer.Simple(0, function()
                if not IsValid(victim) then return end
                local ragdoll = victim.server_ragdoll or victim:GetRagdollEntity()

                if IsValid(ragdoll) then
                    victim:Spectate(OBS_MODE_CHASE)
                    victim:SpectateEntity(ragdoll)

                    net.Start("Rdmt_Murder_Dead")
                        net.WriteEntity(ragdoll)
                    net.Send(victim)
                end
            end)
        end

        -- Remove disguise and fog from murderer on kill
        local attackerData = playerData[attacker]
        if attackerData and IsMurderer(attacker) and attacker ~= victim then
            attackerData.lastKill = CurTime()
            attacker:SetNWBool("RdmtMurderFog", false)

            if attackerData.disguised and undiguiseOnKillConVar:GetBool() then
                attackerData.disguised = false
                SetIdentity(attacker, attackerData.name, attackerData.color)
            end
        end
    end)

    -- Prevent searching bodies
    self:AddHook("TTTCanSearchCorpse", function(ply, corpse)
        return false
    end)

    -- Tag bodies with info needed for searches/disguises
    self:AddHook("TTTOnCorpseCreated", function(ragdoll, ply)
        if not IsValid(ragdoll) or not playerData[ply] then return end

        local name = ply:GetNWString("RdmtMurderName", "Bystander")
        ragdoll:SetNWString("RdmtMurderName", name)
        ragdoll:SetNWVector("RdmtMurderColour", ply:GetNWVector("RdmtMurderColour", Vector(1, 1, 1)))

        CORPSE.SetPlayerNick(ragdoll, name)
    end)

    self:AddHook("PlayerSwitchFlashlight", function(ply, turningOn)
        if not playerData[ply] then return end

        if turningOn and ply.FlashlightLocked > CurTime() then
            return false
        end
    end)

    self:AddHook("TTTCanOrderEquipment", function()
        return false
    end)

    self:AddHook("TTTSpeedMultiplier", function(ply, mults, sprinting)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() or not playerData[ply] then return end

        if sprinting then
            local mult = IsMurderer(ply) and murdererSprintConVar:GetFloat() or bystanderSprintConVar:GetFloat()
            table.insert(mults, mult)
        end

        if ply:GetNWBool("RdmtMurderCarrying", false) then
            table.insert(mults, 1 - carrySpeedConVar:GetFloat())
        end
    end)

    self:AddHook("PlayerFootstep", function(ply, pos, foot)
        if not CR_VERSION then return end
        if IsMurderer(ply) or ply:IsSpec() or ply:WaterLevel() ~= 0 or not (playerData[ply] and ply:Alive() and IsValid(ply)) then return end

        local murderers = {}
        for p in pairs(playerData) do
            if IsValid(p) and IsMurderer(p) and p:Alive() and not p:IsSpec() then
                table.insert(murderers, p)
            end
        end

        net.Start("TTT_PlayerFootstep")
            net.WritePlayer(ply)
            net.WriteVector(pos)
            net.WriteAngle(ply:GetAimVector():Angle())
            net.WriteBit(foot)
            local colour = ply:GetNWVector("RdmtMurderColour", Vector(1, 1, 1))
            net.WriteTable(Color(colour.x * 255, colour.y * 255, colour.z * 255))
            net.WriteUInt(30, 8)
            net.WriteFloat(1) -- Scale
        net.Send(murderers)
    end)

    -- Collect loot/disguise as body when pressing E
    self:AddHook("KeyPress", function(ply, key)
        if key ~= IN_USE then return end
        if not ply:Alive() or ply:IsSpec() then return end

        local data = playerData[ply]

        -- Collect loot
        local loot = FindCollectableLoot(ply, data.loot)
        if IsValid(loot) then
            CollectLoot(ply, data, loot)
        end

        -- Disguise as a body for 1 loot
        if IsMurderer(ply) and data.lootCollected >= 1 then
            local tr = util.TraceLine({
                start  = ply:GetShootPos(),
                endpos = ply:GetShootPos() + ply:GetAimVector() * 100,
                filter = ply,
                mask   = MASK_SHOT
            })
            local ragdoll = tr.Entity

            if IsValid(ragdoll) and ragdoll:GetClass() == "prop_ragdoll" then
                local ragdollName   = ragdoll:GetNWString("RdmtMurderName", "")
                local ragdollColour = ragdoll:GetNWVector("RdmtMurderColour", Vector(1, 1, 1))

                if ragdollName ~= ply:GetNWString("RdmtMurderName") or ragdollColour ~= ply:GetNWVector("RdmtMurderColour") then
                    data.disguised = true
                    data.lootCollected = data.lootCollected - 1

                    ply:SetNWInt("RdmtMurderLootCollected", data.lootCollected)
                    SetIdentity(ply, ragdollName, ragdollColour)

                    return
                end
            end
        end
    end)

    net.Receive("Rdmt_Murder_Taunt", function(len, ply)
        if not Randomat:IsEventActive("murder") then return end
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end

        local tauntID = net.ReadString()
        local tauntCategory = taunts[string.lower(tauntID or "")]
        if not tauntCategory or not playerData[ply] then return end

        local tauntSounds = tauntCategory[playerData[ply].sex]
        local tauntSound  = tauntSounds[math.random(#tauntSounds)]

        ply:EmitSound(tauntSound)
    end)
end

function EVENT:End(isActive)
    timer.Remove("Rdmt_Murder_Unfreeze")

    for _, ply in player.Iterator() do
        if playerData[ply] then
            ply:Freeze(false)
            ply:SetNWString("RdmtMurderName", "")
            ply:SetNWInt("RdmtMurderLootCollected", 0)
            ply:SetNWBool("RdmtMurderFog", false)
            ply:SetNWBool("RdmtMurderCarrying", false)
            ply:SetNWFloat("RdmtMurderFlashlightCharge", 1)
            ply:SetNWFloat("RdmtMurderBlindEndTime", 0)
            ply:SetNWFloat("RdmtMurderGunBanEnd", 0)

            ply.beingGivenGun = nil

            for _, wep in ipairs(ply:GetWeapons()) do
                if allowedWeapons[WEPS.GetClass(wep)] then
                    ply:StripWeapon(WEPS.GetClass(wep))
                end
            end
        end
    end
    playerData = {}

    RestoreRoleStrings()

    -- Reset player models if we changed them
    if isActive then
        Randomat:ForceResetAllPlayermodels()
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"murderer_ratio", "gun_ratio", "loot_needed", "loot_spawn_amount", "loot_respawn", "tk_pickup_ban", "tk_blind", "bystander_sprint", "murderer_sprint", "knife_regen", "fog_time", "carry_slow", "flashlight"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            local decimal = 0
            if v == "bystander_sprint" or v == "murderer_sprint" or v == "flashlight" then
                decimal = 1
            elseif v == "carry_slow" then
                decimal = 2
            end
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = decimal
            })
        end
    end

    local checks = {}
    for _, v in ipairs({"tk_drop_gun", "tk_kill", "undisguise_on_kill", "allow_shop"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

Randomat:register(EVENT)