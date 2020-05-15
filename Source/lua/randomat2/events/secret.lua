local EVENT = {}

EVENT.Title = "Shh... It's a Secret"
EVENT.id = "secret"

function EVENT:Begin(notify)
    Randomat:TriggerRandomEvent(self.Owner, false)
end

function EVENT:End() end

Randomat:register(EVENT)