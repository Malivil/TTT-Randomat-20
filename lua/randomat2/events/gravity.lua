local EVENT = {}

CreateConVar("randomat_gravity_timer", 30, FCVAR_NONE, "Timer", 5, 90)
CreateConVar("randomat_gravity_duration", 3, FCVAR_NONE, "Duration", 1, 15)
CreateConVar("randomat_gravity_minimum", 70, FCVAR_NONE, "The minimum gravity", 10, 500)
CreateConVar("randomat_gravity_maximum", 2000, FCVAR_NONE, "The maximum gravity", 700, 4000)

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
    local duration = GetConVar("randomat_gravity_duration"):GetFloat()
    local resetTimer = GetConVar("randomat_gravity_timer"):GetFloat()

    local state = true
    -- Change the gravity immediately
    local increase = ChangeGravity(true)
    timer.Create("RdmtGravityChange", duration, 0, function()
        if state then
            timer.Adjust("RdmtGravityChange", resetTimer, 0)
            SetGravity(defaultGravity)
        else
            timer.Adjust("RdmtGravityChange", duration, 0)
            increase = ChangeGravity(increase)
        end
        state = not state
    end)
end

function EVENT:End()
    timer.Remove("RdmtGravityChange")
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
