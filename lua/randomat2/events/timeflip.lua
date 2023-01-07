local EVENT = {}

CreateConVar("randomat_timeflip_timer", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often the time scale should change", 5, 90)
CreateConVar("randomat_timeflip_duration_slow", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long the time scale should change for when slow", 1, 30)
CreateConVar("randomat_timeflip_duration_fast", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long the time scale should change for when fast", 1, 120)
CreateConVar("randomat_timeflip_minimum", 0.33, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum time scale", 0.15, 0.9)
CreateConVar("randomat_timeflip_maximum", 2.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum time scale", 1.1, 4)

EVENT.Title = "Praw emiTime Warp"
EVENT.AltTitle = "Time Flip"
EVENT.Description = "Time scale is changed every few seconds for a short period of time before reverting to normal"
EVENT.id = "timeflip"
EVENT.Categories = {"fun", "largeimpact"}

local function SetTimeScale(ts)
    if ts == nil then return end
    print("Time Scale set to " .. ts)
    game.SetTimeScale(ts)
end

local function ChangeTimeScale(increase)
    if increase then
        SetTimeScale(GetConVar("randomat_timeflip_maximum"):GetFloat())
    else
        SetTimeScale(GetConVar("randomat_timeflip_minimum"):GetFloat())
    end

    Randomat:EventNotifySilent("Let's do the Praw emiTime Warp again!")
    return not increase
end

function EVENT:StartChangeTimer(increase)
    timer.Create("RandomatTimeFlipChange", GetConVar("randomat_timeflip_timer"):GetFloat(), 1, function()
        increase = ChangeTimeScale(increase)
        self:StartResetTimer(increase)
    end)
end

function EVENT:StartResetTimer(increase)
    local durationConVar = "randomat_timeflip_duration_fast"
    if increase then
        durationConVar = "randomat_timeflip_duration_slow"
    end
    timer.Create("RandomatTimeFlipReset", GetConVar(durationConVar):GetFloat(), 1, function()
        SetTimeScale(1)
        self:StartChangeTimer(increase)
    end)
end

function EVENT:Begin()
    -- Start the change timer, with minimum (false) first
    self:StartChangeTimer(false)
end

function EVENT:End()
    timer.Remove("RandomatTimeFlipReset")
    timer.Remove("RandomatTimeFlipChange")
    SetTimeScale(1)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "duration_slow", "duration_fast"}) do
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

    for _, v in ipairs({"minimum", "maximum"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)
