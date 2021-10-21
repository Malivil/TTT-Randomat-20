local EVENT = {}

local eventnames = {}
table.insert(eventnames, "Winter has come at last.")
table.insert(eventnames, "The Ice Man cometh.")
table.insert(eventnames, "In this universe, there is only one absolute: everything freezes!")
table.insert(eventnames, "Tonight, Hell freezes over.")
table.insert(eventnames, "I'm afraid my condition has left me cold to your pleas of mercy.")
table.insert(eventnames, "Cool party.")
table.insert(eventnames, "You are not sending me to the cooler.")
table.insert(eventnames, "Stay cool, bird boy.")
table.insert(eventnames, "Alright, everyone! Chill!")
table.insert(eventnames, "It's a cold town.")
table.insert(eventnames, "Tonight's forecast: a freeze is coming!")
table.insert(eventnames, "What killed the dinosaurs?! The ice age!")
table.insert(eventnames, "Let's kick some ice!")
table.insert(eventnames, "Can you feel it coming? The icy cold of space!")
table.insert(eventnames, "Freeze in hell, Batman!")

CreateConVar("randomat_freeze_duration", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Duration of the Freeze (in seconds)", 1, 60)
CreateConVar("randomat_freeze_timer", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often (in seconds) the Freeze occurs", 5, 60)

local function GetEventDescription()
    return "All Innocents will Freeze (and become immune) every "..GetConVar("randomat_freeze_timer"):GetInt().." seconds"
end

EVENT.Title = table.Random(eventnames)
EVENT.AltTitle = "Freeze"
EVENT.Description = GetEventDescription()
EVENT.id = "freeze"

function EVENT:Begin()
    -- Update this in case the CVar has been changed
    EVENT.Description = GetEventDescription()

    local tmr = GetConVar("randomat_freeze_timer"):GetInt()
    timer.Create("RdmtFreezeTimer", tmr, 0, function()
        self:SmallNotify("Freeze!")
        for _, v in ipairs(self:GetAlivePlayers()) do
            if Randomat:IsInnocentTeam(v, true) then
                v:Freeze(true)
                v.isFrozen = true
                timer.Simple(GetConVar("randomat_freeze_duration"):GetInt(), function()
                    v:Freeze(false)
                    v.isFrozen = false
                end)
            end
        end

    end)

    self:AddHook("EntityTakeDamage", function(ply, dmg)
        if IsValid(ply) and ply.isFrozen then
            dmg:ScaleDamage(0)
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtFreezeTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"duration", "timer"}) do
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