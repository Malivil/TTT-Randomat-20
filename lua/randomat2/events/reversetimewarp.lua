local EVENT = {}

CreateConVar("randomat_reversetimewarp_scale", 15, FCVAR_NONE, "The percentage the speed should decrease", 1, 200)
CreateConVar("randomat_reversetimewarp_scale_min", 0.15, FCVAR_NONE, "The minimum scale the speed should decrease to", 0.1, 0.9)
CreateConVar("randomat_reversetimewarp_timer", 15, FCVAR_NONE, "How often (in seconds) the speed will be decreased", 1, 60)

EVENT.Title = "praW emiT"
EVENT.AltTitle = "Reverse Time Warp"
EVENT.Description = "Causes everything (movement, firing speed, timers, etc.) to run increasingly SLOWER"
EVENT.id = "reversetimewarp"
EVENT.Categories = {"fun", "largeimpact"}

function EVENT:Begin()
    timer.Create("RandomatReverseTimeWarpTimer", GetConVar("randomat_reversetimewarp_timer"):GetInt(), 0, function()
        local ts = game.GetTimeScale()
        local min = GetConVar("randomat_reversetimewarp_scale_min"):GetFloat()
        -- If the current time scale is already at or under the min, don't do anything
        if ts <= min then return end

        -- Don't allow the new value to be below the minimum
        local newts = math.Clamp(math.Truncate(ts - GetConVar("randomat_reversetimewarp_scale"):GetInt()/100, 2), min, 1)
        Randomat:EventNotifySilent("Let's do the praW emiT again!")
        game.SetTimeScale(newts)
    end)
end

function EVENT:End()
    timer.Remove("RandomatReverseTimeWarpTimer")
    game.SetTimeScale(1)
end

function EVENT:Condition()
    return not Randomat:IsEventActive("timewarp")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"scale", "scale_min", "timer"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm =  v == "scale_min" and 2 or 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)