local EVENT = {}

util.AddNetworkString("RdmtSpecBeesBegin")
util.AddNetworkString("RdmtSpecBeesEnd")

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
    local bee = ents.Create("prop_dynamic")
    bee:SetModel("models/lucian/props/stupid_bee.mdl")
    bee:SetPos(p:GetPos())
    bee:SetNotSolid(true)
    bee:SetNWBool("RdmtSpecBee", true)
    bee:Spawn()
    bee:EmitSound(engineSound)
    bee:EmitSound(bladeSound)
    bees[p:SteamID64()] = bee
end

local dead = {}
local function SetupBee(p)
    -- Haunting phantoms and infecting parasites shouldn't be bees
    if p:GetNWBool("Haunting", false) or p:GetNWBool("Infecting", false) then return end

    dead[p:SteamID64()] = true
    SetSpectatorValues(p)
    CreateBee(p)
end

local function DestroyBee(b)
    b:StopSound(engineSound)
    b:StopSound(bladeSound)
    b:Remove()
end

function EVENT:Begin()
    bees = {}
    dead = {}

    net.Start("RdmtSpecBeesBegin")
    net.Broadcast()

    for _, p in ipairs(self:GetDeadPlayers()) do
        SetupBee(p)
    end

    self:AddHook("KeyPress", function(ply, key)
        if not IsValid(ply) then return end
        if ply.propspec then return end
        if dead[ply:SteamID64()] then return false end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        timer.Remove("RdmtSpecBeesStart_" .. sid)
        dead[sid] = false
        if IsValid(bees[sid]) then
            DestroyBee(bees[sid])
        end
        bees[sid] = nil
    end)

    self:AddHook("PlayerDisconnected", function(ply)
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        dead[sid] = false
        if IsValid(bees[sid]) then
            DestroyBee(bees[sid])
        end
        bees[sid] = nil
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        timer.Create("RdmtSpecBeesStart_" .. victim:SteamID64(), 1, 1, function()
            SetupBee(victim)
        end)
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
        if IsValid(b) then
            DestroyBee(b)
        end
    end
    for _, p in pairs(player.GetAll()) do
        timer.Remove("RdmtSpecBeesStart_" .. p:SteamID64())
    end

    table.Empty(bees)
    table.Empty(dead)

    net.Start("RdmtSpecBeesEnd")
    net.Broadcast()
end

Randomat:register(EVENT)