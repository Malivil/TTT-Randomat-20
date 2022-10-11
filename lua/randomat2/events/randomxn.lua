local EVENT = {}

CreateConVar("randomat_randomxn_triggers", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Number of Randomat events activated.", 1, 10)
CreateConVar("randomat_randomxn_timer", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often (in seconds) a random event will be triggered.", 1, 60)
CreateConVar("randomat_randomxn_multiple", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow event to run multiple times.")
CreateConVar("randomat_randomxn_triggerbyotherrandom", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow being triggered by other events like Randomness Intensifies.")

EVENT.Title = ""
EVENT.AltTitle = "Random x" .. GetConVar("randomat_randomxn_triggers"):GetInt()
EVENT.Description = "Triggers a number of random events with a slight delay between each"
EVENT.id = "randomxn"
EVENT.SingleUse = false
EVENT.Categories = {"eventtrigger", "largeimpact"}

local timers = {}

function EVENT:Begin()
    if not self.Silent then
        Randomat:EventNotifySilent("Random x" .. GetConVar("randomat_randomxn_triggers"):GetInt())
    end

    local timernum = table.Count(timers) + 1
    local timername = "RandomxnTimer" .. timernum
    table.insert(timers, timername)
    timer.Create(timername, GetConVar("randomat_randomxn_timer"):GetInt(), GetConVar("randomat_randomxn_triggers"):GetInt(), function()
        Randomat:TriggerRandomEvent(self.owner)
    end)
end

function EVENT:End()
    for _, v in ipairs(timers) do
        timer.Remove(v)
    end
end

function EVENT:Condition()
    -- Don't allow this event to run multiple times
    if not GetConVar("randomat_randomxn_multiple"):GetBool() and Randomat:IsEventActive("randomxn") then return false end
    -- Don't allow this event to be triggered by other Random-inducing events like Randomness Intensifies
    if not GetConVar("randomat_randomxn_triggerbyotherrandom"):GetBool() and Randomat:IsEventActive("intensifies") then return false end
    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"triggers", "timer"}) do
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
    for _, v in ipairs({"multiple", "triggerbyotherrandom"}) do
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