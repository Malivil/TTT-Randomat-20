local EVENT = {}

EVENT.Title = "Shh... It's a Secret!"
EVENT.Description = "Silences all Randomat event notifications while this event is active and triggers another random event"
EVENT.id = "secret"

function EVENT:Begin()
    Randomat:TriggerRandomEvent(self.owner)
end

Randomat:register(EVENT)