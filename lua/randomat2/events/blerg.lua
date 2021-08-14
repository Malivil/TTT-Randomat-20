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
            victim:SpawnForRound(true)
        end)
    end)

    -- Stop the timer if something else resurrects them
    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        permadead[sid] = false
        timer.Remove("RdmtBlergRespawnTimer_" .. sid)
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