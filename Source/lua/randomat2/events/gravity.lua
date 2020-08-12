local EVENT = {}

CreateConVar("randomat_gravity_timer", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Timer", 5,90)
CreateConVar("randomat_gravity_duration", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Duration", 1,15)
CreateConVar("randomat_gravity_minimum", 70, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum gravity",10,500)
CreateConVar("randomat_gravity_maximum", 2000, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum gravity",700,4000)

EVENT.Title = "I don't think you realise the gravity of the situation."
EVENT.id = "gravity"
EVENT.AltTitle = "Gravity Changer"

local defaultGravity = 600

local function SetGravity(increase)
    if increase then
        RunConsoleCommand("sv_gravity", GetConVar("randomat_gravity_maximum"):GetFloat())
    else
        RunConsoleCommand("sv_gravity", GetConVar("randomat_gravity_minimum"):GetFloat())
    end
    return not increase
end

function EVENT:Begin()
    if SERVER then
        defaultGravity = GetConVar("sv_gravity"):GetFloat()
        SetGravity(true)
        timer.Simple(GetConVar("randomat_gravity_duration"):GetFloat(), function()
            RunConsoleCommand("sv_gravity", defaultGravity)
        end)
    end
    self:Timer()
end

function EVENT:Timer()
    local delay = GetConVar("randomat_gravity_timer"):GetFloat()
    local duration = GetConVar("randomat_gravity_duration"):GetFloat()
    local increase = false -- false for min, true for max

    timer.Create("RandomatGravityChange", delay,0, function()
        if SERVER then
            increase = SetGravity(increase)
            timer.Simple(duration, function()
                RunConsoleCommand("sv_gravity", defaultGravity)
            end)
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatGravityChange")
    if SERVER then
        RunConsoleCommand("sv_gravity", defaultGravity)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer", "duration", "minimum", "maximum"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText(), -- The description of the ConVar
                min = convar:GetMin(),      -- The minimum value for this slider-based ConVar
                max = convar:GetMax(),      -- The maximum value for this slider-based ConVar
                dcm = 0                     -- The number of decimal points to support in this slider-based ConVar
            })
        end
    end

    return sliders, {}, {}
end

Randomat:register(EVENT)
