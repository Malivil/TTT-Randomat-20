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

local ghosts = {}
local function CreateGhost(p)
    local ghost = ents.Create("npc_kleiner")
    ghost:SetPos(p:GetPos())
    ghost:SetRenderMode(RENDERMODE_NONE)
    ghost:SetNotSolid(true)
    ghost:SetNWBool("RdmtApparition", true)
    ghost:Spawn()
    ghosts[p:SteamID64()] = ghost
end

function EVENT:Begin()
    ghosts = {}

    net.Start("RdmtApparitionBegin")
    net.Broadcast()

    local dead = {}
    for _, p in ipairs(self:GetDeadPlayers()) do
        dead[p:SteamID64()] = true
        SetSpectatorValues(p)
        CreateGhost(p)
    end

    self:AddHook("KeyPress", function(ply, key)
        if not IsValid(ply) then return end
        if ply.propspec then return end
        if dead[ply:SteamID64()] then return false end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        dead[sid] = false
        if IsValid(ghosts[sid]) then
            ghosts[sid]:Remove()
        end
        ghosts[sid] = nil
    end)

    self:AddHook("PlayerDisconnected", function(ply)
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        dead[sid] = false
        if IsValid(ghosts[sid]) then
            ghosts[sid]:Remove()
        end
        ghosts[sid] = nil
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        dead[victim:SteamID64()] = true
        SetSpectatorValues(victim)
        CreateGhost(victim)
    end)

    self:AddHook("FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:IsSpec() then return end

        local ghost = ghosts[ply:SteamID64()]
        if not IsValid(ghost) then return end

        ghost:SetPos(ply:GetPos())
    end)
end

function EVENT:End()
    for _, g in pairs(ghosts) do
        if IsValid(g) then
            g:Remove()
        end
    end
    table.Empty(ghosts)

    net.Start("RdmtApparitionEnd")
    net.Broadcast()
end

Randomat:register(EVENT)