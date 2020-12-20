local EVENT = {}

CreateConVar("randomat_intensifies_timer", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often (in seconds) a random event will be triggered", 5, 60)

EVENT.Title = "Randomness Intensifies"
EVENT.id = "intensifies"

function EVENT:Begin()
    timer.Create("RandomatIntensifiesTimer", GetConVar("randomat_intensifies_timer"):GetInt() , 0, function()
        Randomat:TriggerRandomEvent(self.owner)
    end)
end

function EVENT:End()
    timer.Remove("RandomatIntensifiesTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer"}) do
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