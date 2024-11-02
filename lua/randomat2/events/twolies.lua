local EVENT = {}

CreateConVar("randomat_twolies_blocklist", "", FCVAR_ARCHIVE, "The comma-separated list of event IDs to not start")

EVENT.Title = "Two Lies and a Truth"
EVENT.Description = "One of these three events has been started... but which one?"
EVENT.id = "twolies"
EVENT.Categories = {"eventtrigger", "largeimpact"}

function EVENT:Begin()
    local blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_twolies_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    timer.Create("RdmtTwoLiesDelay", 0.5, 1, function()
        local chosen = {}
        while #chosen < 3 do
            -- Get a random event that isn't "secret", doesn't start secret, and isn't in the chosen list already
            local event = Randomat:GetRandomEvent(true, function(evt)
                return evt.Id ~= "secret" and not evt.StartSecret and not table.HasValue(chosen, evt.Id) and not table.HasValue(blocklist, evt.Id)
            end)
            table.insert(chosen, event)
        end

        -- Tell everyone what's happening
        for _, p in player.Iterator() do
            p:PrintMessage(HUD_PRINTTALK, "[RANDOMAT] One of these events has been started:")
            for _, e in ipairs(chosen) do
                local has_description = e.Description ~= nil and #e.Description > 0
                Randomat:ChatDescription(p, e, has_description)
            end
        end

        -- This is the one we're actually going to run
        local event = chosen[math.random(3)]
        Randomat:SilentTriggerHiddenEvent(event.Id, self.owner, "This event is hidden by '" .. Randomat:GetEventTitle(EVENT) .. "'")
    end)
end

function EVENT:End()
    timer.Remove("RdmtTwoLiesDelay")
end

Randomat:register(EVENT)