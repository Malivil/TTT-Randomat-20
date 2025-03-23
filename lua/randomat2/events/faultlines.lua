local EVENT = {}

CreateConVar("randomat_faultline_min_delay", "20", FCVAR_NONE, "The minimum delay between quakes", 5, 120)
CreateConVar("randomat_faultline_severity_max", "10", FCVAR_NONE, "The maximum severity the earthquakes will have", 1, 10)
CreateConVar("randomat_faultline_aftershocks", "3", FCVAR_NONE, "The number of smaller quakes to happen after the peak", 0, 9)

EVENT.Title = "Fault Lines"
EVENT.Description = "This map is located on a fault line, watch out for the quakes!"
EVENT.ExtDescription = "Shakes all props, weapons, and ammo on the map with increasing severity"
EVENT.id = "faultline"
EVENT.SingleUse = false
EVENT.Categories = {"fun", "moderateimpact"}

local function GetDelay(severity, min_delay)
    -- 5 * severity is Earthquake's formula
    local length = 5 * severity
    return math.max(length, min_delay)
end

function EVENT:Begin()
    local min_delay = GetConVar("randomat_faultline_min_delay"):GetInt()
    local max = GetConVar("randomat_faultline_severity_max"):GetInt()
    local severity = 1
    local owner = self.owner
    timer.Create("RdmtFaultLines", GetDelay(severity, min_delay), max, function()
        -- Increase the severity after each quake
        Randomat:SilentTriggerEvent("earthquake", owner, severity)
        severity = severity + 1

        -- If we're done, start the aftershocks
        if severity > max then
            timer.Remove("RdmtFaultLines")

            -- Decrease the aftershock severity back down to 1 based on how many shocks there will be
            local aftershocks = GetConVar("randomat_faultline_aftershocks"):GetInt()
            local severity_per_shock = math.floor(max / aftershocks)

            timer.Create("RdmtFaultLines_AfterShocks", min_delay, aftershocks, function()
                -- Announce the aftershocks when we start them
                if severity > max then
                    self:SmallNotify("Aftershocks!")
                    severity = max
                end

                -- Ensure the minimum severity of 1
                severity = severity - severity_per_shock
                if severity <= 0 then
                    severity = 1
                end

                Randomat:SilentTriggerEvent("earthquake", owner, severity)

                timer.Adjust("RdmtFaultLines_AfterShocks", GetDelay(severity, min_delay), nil, nil)
            end)
        else
            timer.Adjust("RdmtFaultLines", GetDelay(severity, min_delay), nil, nil)
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtFaultLines")
    timer.Remove("RdmtFaultLines_AfterShocks")
    Randomat:EndActiveEvent("earthquake", true)
end

function EVENT:Condition()
    return Randomat.Events["earthquake"]:Condition()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"min_delay", "severity_max", "aftershocks"}) do
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