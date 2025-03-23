local EVENT = {}

CreateConVar("randomat_intensifies_timer", 20, FCVAR_NONE, "How often (in seconds) a random event will be triggered.", 5, 60)
CreateConVar("randomat_intensifies_triggerbyotherrandom", 1, FCVAR_NONE, "Allow being triggered by other events like Random xN.")

EVENT.Title = "Randomness Intensifies"
EVENT.Description = "Continuously triggers random events for the rest of the round"
EVENT.id = "intensifies"
EVENT.Categories = {"eventtrigger", "largeimpact"}

function EVENT:Begin()
    timer.Create("RandomatIntensifiesTimer", GetConVar("randomat_intensifies_timer"):GetInt() , 0, function()
        Randomat:TriggerRandomEvent(self.owner)
    end)
end

function EVENT:End()
    timer.Remove("RandomatIntensifiesTimer")
end

function EVENT:Condition()
    -- Don't allow this event to be triggered by other Random-inducing events like Randomn xN
    if not GetConVar("randomat_intensifies_triggerbyotherrandom"):GetBool() and Randomat:IsEventActive("randomxn") then return false end
    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer"}) do
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

    local checks = {}
    for _, v in ipairs({"triggerbyotherrandom"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

Randomat:register(EVENT)