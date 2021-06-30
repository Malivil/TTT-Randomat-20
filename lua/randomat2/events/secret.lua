local EVENT = {}

EVENT.Title = "Shh... It's a Secret!"
EVENT.Description = "Silences all Randomat event notifications while this event is active and triggers another random event"
EVENT.id = "secret"

function EVENT:Begin(...)
    local params = ...
    if params ~= nil and params[1] ~= nil then
        local target_event = params[1]
        Randomat:TriggerEvent(target_event, self.owner)
    else
        Randomat:TriggerRandomEvent(self.owner)
    end
end

Randomat:register(EVENT)