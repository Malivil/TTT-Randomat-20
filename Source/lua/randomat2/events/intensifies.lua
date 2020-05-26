local EVENT = {}

CreateConVar("randomat_intensifies_timer", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How often (in seconds) a random event will be triggered")

EVENT.Title = "Randomness Intensifies"
EVENT.id = "intensifies"

function EVENT:Begin()
    timer.Create("RandomatIntensifiesTimer", GetConVar("randomat_intensifies_timer"):GetInt() , 0, function()
        Randomat:TriggerRandomEvent(self.Owner)
    end)
end

function EVENT:End()
    timer.Remove("RandomatIntensifiesTimer")
end

Randomat:register(EVENT)