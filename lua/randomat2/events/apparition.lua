local EVENT = {}

util.AddNetworkString("RdmtApparitionBegin")
util.AddNetworkString("RdmtApparitionEnd")

EVENT.Title = "Ghostly Apparition"
EVENT.Description = "Dead players become ghosts who leave a trail of smoke as they drift through the world"
EVENT.id = "apparition"
EVENT.Type = EVENT_TYPE_SMOKING

local function SetSpectatorValues(p)
    local pos = p:GetPos()
    local ang = p:EyeAngles()
    p:Spectate(OBS_MODE_ROAMING)
    p:SpectateEntity(nil)
    p:SetPos(pos)
    p:SetEyeAngles(ang)
end

function EVENT:Begin()
    net.Start("RdmtApparitionBegin")
    net.Broadcast()

    local dead = {}
    for _, p in ipairs(player.GetAll()) do
        if not p:Alive() or p:IsSpec() then
            dead[p:SteamID64()] = true
            SetSpectatorValues(p)
        end
    end

    self:AddHook("KeyPress", function(ply, key)
        if not IsValid(ply) then return end
        if ply.propspec then return end
        if dead[ply:SteamID64()] then return false end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        dead[ply:SteamID64()] = false
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        dead[victim:SteamID64()] = true
        SetSpectatorValues(victim)
    end)
end

function EVENT:End()
    net.Start("RdmtApparitionEnd")
    net.Broadcast()
end

Randomat:register(EVENT)