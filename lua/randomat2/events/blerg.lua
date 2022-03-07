local EVENT = {}

local eventnames = {}
table.insert(eventnames, "Blerg!")
table.insert(eventnames, "Blegh!")
table.insert(eventnames, "Blergh!")
table.insert(eventnames, "Bleh!")
table.insert(eventnames, "Blarg!")

CreateConVar("randomat_blerg_respawntimer", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Delay before dead players respawn", 5, 240)
CreateConVar("randomat_blerg_weapondelay", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Delay before respawned can use weapons", 5, 60)

EVENT.Title = table.Random(eventnames)
EVENT.Description = "Players respawn repeatedly unless killed during a brief window where they can't use weapons"
EVENT.id = "blerg"
EVENT.Categories = {"deathtrigger", "largeimpact"}

local respawntime = {}
local permadead = {}

local function CanPickup(ply, weapondelay)
    local time = respawntime[ply:SteamID64()]
    if time and (CurTime() < time + weapondelay) then
        return false
    end
    return true
end

function EVENT:Begin()
    respawntime = {}
    permadead = {}

    local respawntimer = GetConVar("randomat_blerg_respawntimer"):GetInt()
    local weapondelay = GetConVar("randomat_blerg_weapondelay"):GetInt()
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end

        local sid = victim:SteamID64()
        -- If they are permadead, don't start the timer again
        if permadead[sid] then return end

        -- If they are still in the no-weapon phase, dying again makes them permadead
        if not CanPickup(victim, weapondelay) then
            victim:PrintMessage(HUD_PRINTTALK, "You died too quickly and are now permanently dead")
            victim:PrintMessage(HUD_PRINTCENTER, "You died too quickly and are now permanently dead")
            permadead[sid] = true
            return
        end

        victim:PrintMessage(HUD_PRINTTALK, "You will automatically respawn in " .. respawntimer .. " seconds")
        victim:PrintMessage(HUD_PRINTCENTER, "You will automatically respawn in " .. respawntimer .. " seconds")

        -- Respawn them after the delay and keep track of when it happens
        timer.Create("RdmtBlergRespawnTimer_" .. sid, respawntimer, 1, function()
            victim:PrintMessage(HUD_PRINTTALK, "You're back! Try to survive without weapons for " .. weapondelay .. " seconds")
            victim:PrintMessage(HUD_PRINTCENTER, "You're back! Try to survive without weapons for " .. weapondelay .. " seconds")
            respawntime[sid] = CurTime()
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
end

function EVENT:End()
    for _, p in pairs(player.GetAll()) do
        timer.Remove("RdmtBlergRespawnTimer_" .. p:SteamID64())
        timer.Remove("RdmtBlergWeaponTimer_" .. p:SteamID64())
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"respawntimer", "weapondelay"}) do
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