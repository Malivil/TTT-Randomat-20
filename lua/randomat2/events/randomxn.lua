local EVENT = {}

CreateConVar("randomat_randomxn_triggers", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Number of Randomat events activated.", 1, 10)

EVENT.Title = ""
EVENT.AltTitle = "Random x"..GetConVar("randomat_randomxn_triggers"):GetInt()
EVENT.id = "randomxn"
EVENT.SingleUse = false

local timers = {}

function EVENT:Begin()
    Randomat:EventNotifySilent("Random x"..GetConVar("randomat_randomxn_triggers"):GetInt())

    local timernum = table.Count(timers) + 1
    local timername = "RandomxnTimer"..timernum
    table.insert(timers, timername)
    timer.Create(timername, 5, GetConVar("randomat_randomxn_triggers"):GetInt(), function()
        Randomat:TriggerRandomEvent(self.owner)
    end)
end

function EVENT:End()
    for _, v in pairs(timers) do
        timer.Remove(v)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"triggers"}) do
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