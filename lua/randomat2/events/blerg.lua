local EVENT = {}

local eventnames = {}
table.insert(eventnames, "Blerg!")
table.insert(eventnames, "Blegh!")
table.insert(eventnames, "Blergh!")
table.insert(eventnames, "Bleh!")
table.insert(eventnames, "Blarg!")

CreateConVar("randomat_blerg_respawntimer", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Delay before dead players respawn", 5, 240)
CreateConVar("randomat_blerg_respawnlimit", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum number of times a player can respawn", 0, 10)
CreateConVar("randomat_blerg_weapondelay", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Delay before respawned can use weapons", 5, 60)

local function GetDescription(respawnlimit)
    local desc = "Players respawn "
    if respawnlimit > 0 then
        desc = desc .. "up to " .. respawnlimit .. " time(s)"
    else
        desc = desc .. "repeatedly"
    end
    return desc .. " unless killed during a brief window where they can't use weapons"
end

EVENT.Title = table.Random(eventnames)
EVENT.Description = GetDescription(0)
EVENT.id = "blerg"
EVENT.Type = {EVENT_TYPE_RESPAWN, EVENT_TYPE_WEAPON_OVERRIDE}
EVENT.Categories = {"deathtrigger", "largeimpact"}

local respawntime = {}
local respawncount = {}
local permadead = {}
local roleweapons = {}

local function CanPickup(ply, weapondelay)
    local time = respawntime[ply:SteamID64()]
    if time and (CurTime() < time + weapondelay) then
        return false
    end
    return true
end

function EVENT:Begin()
    respawntime = {}
    respawncount = {}
    permadead = {}
    roleweapons = {}

    local respawntimer = GetConVar("randomat_blerg_respawntimer"):GetInt()
    local respawnlimit = GetConVar("randomat_blerg_respawnlimit"):GetInt()
    local weapondelay = GetConVar("randomat_blerg_weapondelay"):GetInt()

    EVENT.Description = GetDescription(respawnlimit)

    self:AddHook("DoPlayerDeath", function(victim, attacker, dmginfo)
        if not IsValid(victim) then return end
        if not WEAPON_CATEGORY_ROLE then return end

        -- Track role weapons when using the version of CR for TTT that can do that
        local sid = victim:SteamID64()
        roleweapons[sid] = {}
        for _, wep in ipairs(victim:GetWeapons()) do
            if wep.Category == WEAPON_CATEGORY_ROLE and not wep.AllowDrop then
                table.insert(roleweapons[sid], WEPS.GetClass(wep))
            end
        end
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end

        local sid = victim:SteamID64()
        -- If they are permadead, don't start the timer again
        if permadead[sid] then return end

        -- Keep track of how many times players have respawned
        if not respawncount[sid] then
            respawncount[sid] = 0
        end

        -- If they are still in the no-weapon phase, dying again makes them permadead
        if not CanPickup(victim, weapondelay) then
            victim:PrintMessage(HUD_PRINTTALK, "You died too quickly and are now permanently dead")
            victim:PrintMessage(HUD_PRINTCENTER, "You died too quickly and are now permanently dead")
            permadead[sid] = true
            timer.Remove("RdmtBlergRespawnTimer_" .. sid)
            timer.Remove("RdmtBlergWeaponTimer_" .. sid)
            return
        end

        -- Limit the number of times a player can respawn, if that is enabled
        if respawnlimit > 0 and respawncount[sid] >= respawnlimit then
            victim:PrintMessage(HUD_PRINTTALK, "You died too many times are now permanently dead")
            victim:PrintMessage(HUD_PRINTCENTER, "You died too many times and are now permanently dead")
            permadead[sid] = true
            timer.Remove("RdmtBlergRespawnTimer_" .. sid)
            timer.Remove("RdmtBlergWeaponTimer_" .. sid)
            return
        end

        victim:PrintMessage(HUD_PRINTTALK, "You will automatically respawn in " .. respawntimer .. " seconds")
        victim:PrintMessage(HUD_PRINTCENTER, "You will automatically respawn in " .. respawntimer .. " seconds")

        -- Respawn them after the delay and keep track of when it happens
        timer.Create("RdmtBlergRespawnTimer_" .. sid, respawntimer, 1, function()
            victim:PrintMessage(HUD_PRINTTALK, "You're back! Try to survive without weapons for " .. weapondelay .. " seconds")
            victim:PrintMessage(HUD_PRINTCENTER, "You're back! Try to survive without weapons for " .. weapondelay .. " seconds")
            respawntime[sid] = CurTime()
            respawncount[sid] = respawncount[sid] + 1
            -- Destroy their old body
            local body = victim.server_ragdoll or victim:GetRagdollEntity()
            local credits = 0
            if IsValid(body) then
                credits = CORPSE.GetCredits(body, 0)
                body:Remove()
            end
            victim:SpawnForRound(true)
            victim:SetCredits(credits)
            -- Let them know when they can use weapons and give their defaults back
            timer.Create("RdmtBlergWeaponTimer_" .. sid, weapondelay, 1, function()
                victim:PrintMessage(HUD_PRINTTALK, "You made it! Get some weapons and get back to killing!")
                victim:PrintMessage(HUD_PRINTCENTER, "You made it! Get some weapons and get back to killing!")

                if not victim:HasWeapon("weapon_ttt_unarmed") then
                    victim:Give("weapon_ttt_unarmed")
                end
                if not victim:HasWeapon("weapon_zm_carry") then
                    victim:Give("weapon_zm_carry")
                end

                local hasCrowbar = false
                if victim:IsKiller() then
                    -- Only run this if the version of Custom Roles with a knife exists and it is enabled
                    if ConVarExists("ttt_killer_knife_enabled") and GetConVar("ttt_killer_knife_enabled"):GetBool() then
                        -- The newest version of CR doesn't replace the crowbar with the knife
                        if not CR_VERSION then
                            hasCrowbar = true
                        end
                        victim:Give("weapon_kil_knife")
                    end

                    -- In the newest version of CR the killer can get a throwable crowbar as a replacement for the normal one
                    if CR_VERSION and ConVarExists("ttt_killer_crowbar_enabled") and GetConVar("ttt_killer_crowbar_enabled"):GetBool() then
                        victim:Give("weapon_kil_crowbar")
                        hasCrowbar = true
                    end
                end

                if not hasCrowbar and not victim:HasWeapon("weapon_zm_improvised") then
                    victim:Give("weapon_zm_improvised")
                end

                -- Make sure they get their role weapons back
                if roleweapons[sid] then
                    for _, wep in ipairs(roleweapons[sid]) do
                        victim:Give(wep)
                    end
                    roleweapons[sid] = {}
                end
            end)
        end)
    end)

    -- Stop the timer if something else resurrects them
    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        permadead[sid] = false
        timer.Remove("RdmtBlergRespawnTimer_" .. sid)
        timer.Remove("RdmtBlergWeaponTimer_" .. sid)
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not IsValid(ply) then return end

        -- Don't allow players who were recently resurrected by this event pickup weapons
        if not CanPickup(ply, weapondelay) then
            return false
        end
    end)

    -- Hide the role of the player's attacker so they can't reveal it when they respawn
    self:AddHook("TTTDeathNotifyOverride", function(victim, inflictor, attacker, reason, killerName, role)
        if GetRoundState() ~= ROUND_ACTIVE then return end
        if not IsValid(inflictor) or not IsValid(attacker) then return end
        if not attacker:IsPlayer() then return end
        if victim == attacker then return end

        local sid = victim:SteamID64()
        if not timer.Exists("RdmtBlergRespawnTimer_" .. sid) then return end

        return reason, killerName, ROLE_NONE
    end)
end

function EVENT:End()
    for _, p in pairs(player.GetAll()) do
        timer.Remove("RdmtBlergRespawnTimer_" .. p:SteamID64())
        timer.Remove("RdmtBlergWeaponTimer_" .. p:SteamID64())
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"respawntimer", "respawnlimit", "weapondelay"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)