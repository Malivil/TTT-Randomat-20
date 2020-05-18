local EVENT = {}

EVENT.Title = "Shh... It's a Secret!"
EVENT.id = "secret"

function EVENT:Begin()
    Randomat:TriggerRandomEvent(self.Owner)
end

function EVENT:End() end

Randomat:register(EVENT)