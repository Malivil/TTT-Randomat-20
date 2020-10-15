local EVENT = {}

EVENT.Title = "Shh... It's a Secret!"
EVENT.id = "secret"

function EVENT:Begin()
    Randomat:TriggerRandomEvent(self.owner)
end

function EVENT:End() end

Randomat:register(EVENT)