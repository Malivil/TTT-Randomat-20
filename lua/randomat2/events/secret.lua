local EVENT = {}

EVENT.Title = "Shh... It's a Secret!"
EVENT.Description = "Silences all event notifications and triggers another random event"
EVENT.id = "secret"
EVENT.Categories = {"fun", "largeimpact"}

function EVENT:Begin(target_event)
    if target_event then
        Randomat:TriggerEvent(target_event, self.owner)
    else
        Randomat:TriggerRandomEvent(self.owner)
    end
end

Randomat:register(EVENT)