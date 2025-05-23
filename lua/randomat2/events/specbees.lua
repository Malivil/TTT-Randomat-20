local EVENT = {}

EVENT.Title = "RISE FROM YOUR... Bees?"
EVENT.Description = "Dead players become harmless bees"
EVENT.id = "specbees"
EVENT.Categories = {"spectator", "entityspawn", "moderateimpact"}

local function SetSpectatorValues(p)
    local pos = p:GetPos()
    local ang = p:EyeAngles()
    p:Spectate(OBS_MODE_ROAMING)
    p:SpectateEntity(nil)
    p:SetPos(pos)
    p:SetEyeAngles(ang)
    PROPSPEC.Clear(p)
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
    if p:GetNWBool("PhantomHaunting", false) or p:GetNWBool("ParasiteInfecting", false) then return end

    dead[p:SteamID64()] = true
    SetSpectatorValues(p)
    CreateBee(p)
end

local function DestroyBee(b)
    b:StopSound(engineSound)
    b:StopSound(bladeSound)
    b:Remove()
end

local function StopBee(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    dead[sid] = false
    if IsValid(bees[sid]) then
        DestroyBee(bees[sid])
    end
    bees[sid] = nil
    timer.Remove("RdmtSpecBeesStart_" .. sid)
end

function EVENT:Begin()
    bees = {}
    dead = {}

    for _, p in ipairs(self:GetDeadPlayers()) do
        SetupBee(p)
    end

    self:AddHook("KeyPress", function(ply, key)
        if not IsValid(ply) then return end
        if ply.propspec then return end
        if dead[ply:SteamID64()] then return false end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        -- "PlayerSpawn" also gets called when a player is moved to AFK
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        StopBee(ply)
    end)
    self:AddHook("PlayerDisconnected", StopBee)

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
    for _, p in player.Iterator() do
        timer.Remove("RdmtSpecBeesStart_" .. p:SteamID64())
    end

    table.Empty(bees)
    table.Empty(dead)
end

Randomat:register(EVENT)