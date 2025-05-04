local EVENT = {}

EVENT.Title = "REAL Gun Game"
EVENT.Description = "Everyone starts with the same weapon. First player to kill with every weapon wins for their team\nEach time you kill the other team, you get the next weapon"
EVENT.id = "realgungame"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"gamemode", "rolechange", "item", "largeimpact"}

CreateConVar("randomat_realgungame_blocklist", "", FCVAR_NONE, "The comma-separated list of weapon IDs to not give out")
CreateConVar("randomat_realgungame_respawn_time", 5, FCVAR_NONE, "How long before a dead player respawns", 0, 60)
CreateConVar("randomat_realgungame_round_limit", 0, FCVAR_NONE, "How many rounds to limit the game to, maximum (Limited by the number of available weapons). Set to 0 to go through every weapon available")

function EVENT:EquipPlayer(ply, wepClass)
    ply:StripWeapons()
    -- Reset FOV to unscope
    ply:SetFOV(0, 0.2)

    -- Give them their weapon and don't let them drop it
    local wep = ply:Give(wepClass)
    wep.AllowDrop = false
    wep.OnDrop = function() SafeRemoveEntity(wep) end

    -- Give them enough ammo to fill their clip and their reserve
    if wep.Primary and wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then
        wep:SetClip1(wep.Primary.ClipSize)

        local amount
        if wep.Primary.ClipMax and wep.Primary.ClipMax > 0 then
            amount = wep.Primary.ClipMax
        else
            -- If we don't know the max clip size, just give them 3 clips
            amount = wep.Primary.ClipSize * 3
        end

        local ammoType = wep:GetPrimaryAmmoType()
        if ammoType >= 0 then
            ply:SetAmmo(amount, ammoType)
        end
    end
end

local blocklist = {}
function EVENT:Begin()
    blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_realgungame_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    -- Stop win checks so the only way to win is if someone gets all the gun kills
    StopWinChecks()

    local weps = {
        [WEAPON_HEAVY] = {},
        [WEAPON_PISTOL] = {}
    }

    -- Gather spawnable weapons
    for _, wep in ipairs(weapons.GetList()) do
        if not wep.AutoSpawnable then continue end
        if not weps[wep.Kind] then continue end

        local wepClass = WEPS.GetClass(wep)
        -- Ignore blocked weapons
        if table.HasValue(blocklist, wepClass) then continue end

        table.insert(weps[wep.Kind], wepClass)
    end

    -- End it with the crowbar
    weps[WEAPON_MELEE] = { "weapon_zm_improvised" }

    -- Shuffle the tables so the weapons aren't the same every time
    table.Shuffle(weps[WEAPON_HEAVY])
    table.Shuffle(weps[WEAPON_PISTOL])

    local round_limit = GetConVar("randomat_realgungame_round_limit"):GetInt() - 1
    if round_limit > 0 then
        local non_melee_round_count = math.floor(round_limit / 2)
        local rounds_per_type = {
            [WEAPON_HEAVY] = non_melee_round_count,
            [WEAPON_PISTOL] = non_melee_round_count,
            [WEAPON_MELEE] = 1
        }

        -- If this was an odd number, add one to the first round to get to the round limit
        if (round_limit % 2) ~= 0 then
            rounds_per_type[WEAPON_HEAVY] = rounds_per_type[WEAPON_HEAVY] + 1
        end

        -- Limit the rounds for each type by the number of weapons available
        rounds_per_type[WEAPON_HEAVY] = math.min(rounds_per_type[WEAPON_HEAVY], #weps[WEAPON_HEAVY])
        rounds_per_type[WEAPON_PISTOL] = math.min(rounds_per_type[WEAPON_PISTOL], #weps[WEAPON_PISTOL])

        -- If we've limited the rounds for each type, make sure we've used all available rounds according to the configured limit
        if (round_limit - rounds_per_type[WEAPON_HEAVY] - rounds_per_type[WEAPON_PISTOL]) > 0 then
            -- At this point we know one of the lists was capped by the number of weapons
            -- So if we adjust the size of each list to contain the maximum number they can hold of the remaining rounds,
            -- the maxed weapon type will be unchanged and the other type will have as many weapons assigned to it as it can hold
            -- If both of them are maxed already then neither number will change, but no harm done
            rounds_per_type[WEAPON_HEAVY] = math.min(round_limit - rounds_per_type[WEAPON_PISTOL], #weps[WEAPON_HEAVY])
            rounds_per_type[WEAPON_PISTOL] = math.min(round_limit - rounds_per_type[WEAPON_HEAVY], #weps[WEAPON_PISTOL])
        end

        -- "Resize" each weapon list to the new limit, or empty the table if the limit is 0
        if rounds_per_type[WEAPON_HEAVY] > 0 then
            weps[WEAPON_HEAVY] = table.move(weps[WEAPON_HEAVY], 1, rounds_per_type[WEAPON_HEAVY], 1, {})
        else
            weps[WEAPON_HEAVY] = {}
        end
        if rounds_per_type[WEAPON_PISTOL] > 0 then
            weps[WEAPON_PISTOL] = table.move(weps[WEAPON_PISTOL], 1, rounds_per_type[WEAPON_PISTOL], 1, {})
        else
            weps[WEAPON_PISTOL] = {}
        end
    end

    local firstKind = WEAPON_HEAVY
    -- Make sure we have weapons in each list
    if #weps[WEAPON_HEAVY] == 0 then
        if #weps[WEAPON_PISTOL] == 0 then
            firstKind = WEAPON_MELEE
        else
            firstKind = WEAPON_PISTOL
        end
    end
    local firstWeapon = weps[firstKind][1]
    local currentWepData = {}
    -- Set up each player with their first weapon
    for i, p in player.Iterator() do
        local sid64 = p:SteamID64()
        currentWepData[sid64] = {
            Kind = firstKind,
            Index = 1
        }

        -- Convert everyone to Detective and Traitor so everyone knows whose on their team
        if i % 2 == 0 then
            Randomat:SetRole(p, ROLE_DETECTIVE)
        else
            Randomat:SetRole(p, ROLE_TRAITOR)
        end
        -- Remove their credits
        p:SetCredits(0)

        -- Take their weapons and give them the first weapon
        self:EquipPlayer(p, firstWeapon)
    end
    SendFullStateUpdate()

    local respawnTime = GetConVar("randomat_realgungame_respawn_time"):GetInt()
    self:AddHook("DoPlayerDeath", function(victim, attacker, dmginfo)
        if not IsPlayer(victim) then return end

        if respawnTime > 0 then
            Randomat:PrintMessage(victim, MSG_PRINTBOTH, "Don't worry, you'll respawn in " .. respawnTime .. " second(s)")
            -- Death is not an escape
            timer.Create("RealGunGameRespawn_" .. victim:SteamID64(), respawnTime, 1, function()
                if not IsPlayer(victim) then return end

                victim:SpawnForRound(true)
                local body = victim.server_ragdoll or victim:GetRagdollEntity()
                if IsValid(body) then
                    body:Remove()
                end
            end)
        end

        if not IsPlayer(attacker) then return end
        if victim:GetRole() == attacker:GetRole() then return end

        -- Get the weapon used
        local inflictor = dmginfo.GetWeapon and dmginfo:GetWeapon() or nil
        if not IsValid(inflictor) then
            -- If it wasn't set, get the inflictor
            inflictor = dmginfo:GetInflictor()
            if not IsValid(inflictor) then return end
        end

        local attSid64 = attacker:SteamID64()
        local wepData = currentWepData[attSid64]
        if not wepData then return end

        local wepKind = wepData.Kind
        local wepIndex = wepData.Index
        local wepClass = weps[wepKind][wepIndex]

        -- Get the inflictor class, but if it's a weapon
        -- get the attacker's current weapon instead
        local inflClass = WEPS.GetClass(inflictor)
        if inflClass ~= wepClass then
            inflClass = WEPS.GetClass(attacker:GetActiveWeapon())
        end

        if inflClass == wepClass then
            wepIndex = wepIndex + 1
            if wepIndex > #weps[wepKind] then
                wepKind = wepKind - 1
                -- If they've used all of the kinds too, they win!
                if wepKind <= 0 then
                    Randomat:EventNotify(attacker:Nick() .. " WINS!")
                    Randomat:SmallNotify("They killed an enemy with every weapon and won the round for their team!")
                    currentWepData[attSid64] = nil
                    if attacker:IsDetective() then
                        EndRound(WIN_INNOCENT)
                    else
                        EndRound(WIN_TRAITOR)
                    end
                    return
                else
                    wepIndex = 1
                end
            end

            currentWepData[attSid64] = {
                Kind = wepKind,
                Index = wepIndex
            }

            -- Give them their new weapon
            local newClass = weps[wepKind][wepIndex]
            self:EquipPlayer(attacker, newClass)

            -- Send a request for the weapon name to the client
            -- Event handler located in cl_networkstrings
            net.Start("alerteventtrigger")
            net.WriteString(EVENT.id)
            net.WriteString(newClass)
            -- Repurpose this string as the player's name
            net.WriteString(attSid64)
            -- We only care about weapons so always send 0 for the is_item
            net.WriteUInt(0, 32)
            net.WriteInt(attacker:GetRole(), 16)
            net.Send(attacker)
        end
    end)

    -- Block players who are still playing the game from picking up other weapons
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() then return end
        if WEAPON_CATEGORY_ROLE and wep.Category == WEAPON_CATEGORY_ROLE then return end

        local sid64 = ply:SteamID64()
        local wepData = currentWepData[sid64]
        if not wepData then return end

        -- Make sure they can only pick up their assigned weapon
        local wepClass = weps[wepData.Kind][wepData.Index]
        return wepClass == WEPS.GetClass(wep)
    end)

    local lastUpdate = nil
    self:AddHook("Think", function()
        local curTime = CurTime()
        if lastUpdate == nil or curTime >= lastUpdate then
            lastUpdate = curTime + 1
            -- Change the round time so it effectively never ends
            SetGlobalFloat("ttt_round_end", curTime + 90000)
        end
    end)

    -- Disable karma
    self:AddHook("TTTKarmaShouldGivePenalty", function()
        return false
    end)

    -- Anyone who spawns should be locked in too
    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        local sid64 = ply:SteamID64()
        local wepData = currentWepData[sid64]
        if not wepData then return end

        local wepKind = wepData.Kind
        local wepIndex = wepData.Index
        local wepClass = weps[wepKind][wepIndex]
        self:EquipPlayer(ply, wepClass)
    end)

    -- Print out which weapon the player is now using
    -- Event started in cl_networkstrings
    net.Receive("AlertTriggerFinal", function()
        local event = net.ReadString()
        if event ~= EVENT.id then return end

        local name = self:RenameWeps(net.ReadString())
        local sid64 = net.ReadString()
        local ply = player.GetBySteamID64(sid64)
        if not ply or not IsPlayer(ply) then return end
        if not ply:Alive() or ply:IsSpec() then return end

        Randomat:PrintMessage(ply, MSG_PRINTBOTH, "Success! Your new weapon is '" .. name .. "'")
    end)

    -- Disable shops by removing credits
    timer.Create("RealGunGameNoCreditsTimer", 0, 0, function()
        for _, ply in player.Iterator() do
            ply:SetCredits(0)
        end
    end)
end

function EVENT:End()
    timer.Remove("RealGunGameNoCreditsTimer")
    for _, p in player.Iterator() do
        if not IsPlayer(p) then continue end
        timer.Remove("RealGunGameRespawn_" .. p:SteamID64())
    end
end

function EVENT:GetConVars()
    local checks = {}
    for _, v in ipairs({"respawn_time", "round_limit"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return {}, checks
end

Randomat:register(EVENT)