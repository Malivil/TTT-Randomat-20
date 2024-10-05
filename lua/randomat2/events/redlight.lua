local EVENT = {}

CreateConVar("randomat_redlight_mindelay", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Minimum time for each phase", 1, 30)
CreateConVar("randomat_redlight_maxdelay", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Maximum time for each phase", 1, 30)
CreateConVar("randomat_redlight_damage", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Amount of damage a player takes per second", 1, 10)

EVENT.Title = "Red Light, Green Light"
EVENT.Description = "Hurts a player if they move during a red light"
EVENT.id = "redlight"
EVENT.Categories = {"gamemode", "largeimpact"}

local MathAbs = math.abs
local MathRandom = math.random

local function GetDelay()
    local min = GetConVar("randomat_redlight_mindelay"):GetInt()
    local max = GetConVar("randomat_redlight_maxdelay"):GetInt()
    if min < max then
        return max
    end

    return MathRandom(min, max)
end

local function DoDamage(ply, damage)
    local health = ply:Health() - damage
    if health <= 0 then
        ply:Kill()
    else
        ply:SetHealth(health)
    end
end

local function GetPlayerVelocity(ply)
    -- If this player is in a vehicle, use the velocity of the vehicle instead
    local vel = ply:GetVelocity()
    local in_vehicle, parent = Randomat:IsPlayerInVehicle(ply)
    if in_vehicle then
        vel = parent:GetVelocity()
    end
    return vel
end

local function IsPlayerMoving(ply)
    local vel = GetPlayerVelocity(ply)
    -- We can't use 0,0,0 because when a player is in a vehicle, like an airboat, their velocity is something like this when stopped: Vector(0.005939, -0.000339, -0.000001)
    return MathAbs(vel.x) >= 1 or MathAbs(vel.y) >= 1 or MathAbs(vel.z) >= 1
end

function EVENT:Begin()
    local damage = GetConVar("randomat_redlight_damage"):GetInt()
    local delay = GetDelay()
    local isgreen = true
    timer.Create("RdmtRedLightTimer", delay, 0, function()
        isgreen = not isgreen

        local color = "Red"
        if isgreen then
            color = "Green"
            for _, p in player.Iterator() do
                timer.Remove("RdmtRedLightDamageTimer_" .. p:SteamID64())
            end
        end

        delay = GetDelay()
        timer.Adjust("RdmtRedLightTimer", delay)

        -- Tell everyone
        Randomat:Notify(color .. " Light!", delay)
    end)

    self:AddHook("FinishMove", function(ply, mv)
        if isgreen then return end
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        local moving = IsPlayerMoving(ply)

        -- If there is already a timer, don't start it again
        local timerId = "RdmtRedLightDamageTimer_" .. ply:SteamID64()
        if timer.Exists(timerId) then
            -- And if they aren't moving, clear the existing timer
            if not moving then
                timer.Remove(timerId)
            end
            return
        end

        -- Don't damage the player if they aren't moving
        if not moving then return end

        -- Hurt the player for X damage every second
        DoDamage(ply, damage)
        timer.Create(timerId, 1, 0, function()
            -- Double-check they are still moving
            if not IsPlayerMoving(ply) then return end

            DoDamage(ply, damage)
        end)
    end)

    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        timer.Remove("RdmtRedLightDamageTimer_" .. ply:SteamID64())
    end)
end

function EVENT:End()
    timer.Remove("RdmtRedLightTimer")
    for _, p in player.Iterator() do
        timer.Remove("RdmtRedLightDamageTimer_" .. p:SteamID64())
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"mindelay", "maxdelay", "damage"}) do
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