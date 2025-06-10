local EVENT = {}

EVENT.Title = "Ghostly Apparition"
EVENT.Description = "Dead players become ghosts who leave a trail of smoke as they drift through the world"
EVENT.id = "apparition"
EVENT.Type = EVENT_TYPE_SMOKING
EVENT.Categories = {"spectator", "smallimpact"}

local function SetSpectatorValues(p)
    local pos = p:GetPos()
    local ang = p:EyeAngles()
    p:Spectate(OBS_MODE_ROAMING)
    p:SpectateEntity(nil)
    p:SetPos(pos)
    p:SetEyeAngles(ang)
    PROPSPEC.Clear(p)
end

local ghosts = {}
local function CreateGhost(p)
    local ghost = ents.Create("npc_kleiner")
    ghost:SetPos(p:GetPos())
    ghost:SetRenderMode(RENDERMODE_NONE)
    ghost:SetNotSolid(true)
    ghost:SetNWBool("RdmtApparition", true)
    ghost:AddFlags(FL_NOTARGET)
    ghost:Spawn()
    ghosts[p:SteamID64()] = ghost
end

local dead = {}
local function SetupGhost(p)
    -- Haunting phantoms (or enhanced mediums) and infecting parasites shouldn't be ghosts
    if p:GetNWBool("PhantomHaunting", false) or p:GetNWBool("MediumHaunting", false) or p:GetNWBool("ParasiteInfecting", false) then return end

    dead[p:SteamID64()] = true
    SetSpectatorValues(p)
    CreateGhost(p)
end

local function StopGhost(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    dead[sid] = false
    if IsValid(ghosts[sid]) then
        ghosts[sid]:Remove()
    end
    ghosts[sid] = nil
    timer.Remove("RdmtApparitionStart_" .. sid)
end

function EVENT:Begin()
    ghosts = {}
    dead = {}

    for _, p in ipairs(self:GetDeadPlayers()) do
        SetupGhost(p)
    end

    self:AddHook("KeyPress", function(ply, key)
        if not IsValid(ply) then return end
        if ply.propspec then return end
        if dead[ply:SteamID64()] then return false end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        StopGhost(ply)
    end)
    self:AddHook("PlayerDisconnected", StopGhost)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        timer.Create("RdmtApparitionStart_" .. victim:SteamID64(), 1, 1, function()
            SetupGhost(victim)
        end)
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
    for _, p in player.Iterator() do
        timer.Remove("RdmtApparitionStart_" .. p:SteamID64())
    end

    table.Empty(ghosts)
    table.Empty(dead)
end

Randomat:register(EVENT)