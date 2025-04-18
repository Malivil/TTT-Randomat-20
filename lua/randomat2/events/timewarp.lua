local EVENT = {}

CreateConVar("randomat_timewarp_scale", 40, FCVAR_NONE, "The percentage the speed should increase", 1, 200)
CreateConVar("randomat_timewarp_scale_max", 4, FCVAR_NONE, "The maximum scale the speed should increase to", 2, 50)
CreateConVar("randomat_timewarp_timer", 15, FCVAR_NONE, "How often (in seconds) the speed will be increased", 1, 60)

EVENT.Title = "Time Warp"
EVENT.Description = "Causes everything (movement, firing speed, timers, etc.) to run increasingly faster"
EVENT.id = "timewarp"
EVENT.Categories = {"fun", "largeimpact"}

function EVENT:Begin()
    timer.Create("RandomatTimeWarpTimer", GetConVar("randomat_timewarp_timer"):GetInt(), 0, function()
        local ts = game.GetTimeScale()
        local max = GetConVar("randomat_timewarp_scale_max"):GetInt()
        -- If the current time scale is already at or over the max, don't do anything
        if ts >= max then return end

        -- Don't allow the new value to exceed the maximum
        local newts = math.Clamp(ts + GetConVar("randomat_timewarp_scale"):GetInt()/100, 0, max)
        Randomat:EventNotifySilent("Let's do the Time Warp again!")
        game.SetTimeScale(newts)
    end)
end

function EVENT:End()
    timer.Remove("RandomatTimeWarpTimer")
    game.SetTimeScale(1)
end

function EVENT:Condition()
    return not Randomat:IsEventActive("reversetimewarp")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"scale", "scale_max", "timer"}) do
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