local EVENT = {}

CreateConVar("randomat_gravity_timer", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Timer", 5, 90)
CreateConVar("randomat_gravity_duration", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Duration", 1, 15)
CreateConVar("randomat_gravity_minimum", 70, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum gravity", 10, 500)
CreateConVar("randomat_gravity_maximum", 2000, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum gravity", 700, 4000)

EVENT.Title = "I don't think you realise the gravity of the situation."
EVENT.AltTitle = "Gravity Changer"
EVENT.Description = "Gravity is changed every few seconds for a short period of time before reverting to normal"
EVENT.id = "gravity"
EVENT.Categories = {"fun", "moderateimpact"}

local defaultGravity = nil
local function SetGravity(gravity)
    if gravity == nil then return end
    RunConsoleCommand("sv_gravity", gravity)
end

local function ChangeGravity(increase)
    if increase then
        SetGravity(GetConVar("randomat_gravity_maximum"):GetFloat())
    else
        SetGravity(GetConVar("randomat_gravity_minimum"):GetFloat())
    end
    return not increase
end

function EVENT:Begin()
    defaultGravity = GetConVar("sv_gravity"):GetFloat()

    -- Change the gravity immediately
    ChangeGravity(true)
    -- Reset back to default after the configured amount of time
    self:StartResetTimer(true)
end

function EVENT:StartChangeTimer()
    local increase = false -- false for min, true for max
    timer.Create("RandomatGravityChange", GetConVar("randomat_gravity_timer"):GetFloat(), 0, function()
        increase = ChangeGravity(increase)
        self:StartResetTimer(false)
    end)
end

function EVENT:StartResetTimer(start)
    timer.Create("RandomatGravityReset", GetConVar("randomat_gravity_duration"):GetFloat(), 1, function()
        SetGravity(defaultGravity)
        if start then
            self:StartChangeTimer()
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatGravityReset")
    timer.Remove("RandomatGravityChange")
    SetGravity(defaultGravity)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "duration", "minimum", "maximum"}) do
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
