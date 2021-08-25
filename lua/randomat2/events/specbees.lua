local EVENT = {}

EVENT.Title = "RISE FROM YOUR... Bees?"
EVENT.Description = "Dead players become harmless bees"
EVENT.id = "specbees"

local function SetSpectatorValues(p)
    local pos = p:GetPos()
    local ang = p:EyeAngles()
    p:Spectate(OBS_MODE_ROAMING)
    p:SpectateEntity(nil)
    p:SetPos(pos)
    p:SetEyeAngles(ang)
end

local engineSound = Sound("NPC_Manhack.EngineSound1")
local bladeSound = Sound("NPC_Manhack.BladeSound")

local bees = {}
local function CreateBee(p)
    local bee = ents.Create("prop_physics")
    bee:SetModel("models/lucian/props/stupid_bee.mdl")
    bee:SetPos(p:GetPos())
    bee:SetNotSolid(true)
    bee:PhysicsInit(SOLID_VPHYSICS)
    bee:SetMoveType(MOVETYPE_VPHYSICS)
    bee:SetSolid(SOLID_VPHYSICS)
    bee:AddFlags(FL_OBJECT)
    bee:EmitSound(engineSound)
    bee:EmitSound(bladeSound)
    bees[p:SteamID64()] = bee
end

function EVENT:Begin()
    bees = {}

    local dead = {}
    for _, p in ipairs(self:GetDeadPlayers()) do
        dead[p:SteamID64()] = true
        SetSpectatorValues(p)
        CreateBee(p)
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
        bees[sid]:Remove()
        bees[sid] = nil
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        dead[victim:SteamID64()] = true
        SetSpectatorValues(victim)
        CreateBee(victim)
    end)

    self:AddHook("FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:IsSpec() then return end

        local bee = bees[ply:SteamID64()]
        if not IsValid(bee) then return end

        local ang = mv:GetAngles()
        bee:SetPos(mv:GetOrigin() + ang:Forward() * 20)
        bee:SetAngles(ang)
    end)
end

function EVENT:End()
    for _, b in pairs(bees) do
        b:StopSound(engineSound)
        b:StopSound(bladeSound)
        b:Remove()
    end
    table.Empty(bees)
end

Randomat:register(EVENT)