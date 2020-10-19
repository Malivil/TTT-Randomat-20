local EVENT = {}

EVENT.Title = "Shh... It's a Secret!"
EVENT.id = "secret"

function EVENT:Begin()
    Randomat:TriggerRandomEvent(self.owner)
end

Randomat:register(EVENT)