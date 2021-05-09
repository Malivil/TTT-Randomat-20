local EVENT = {}

EVENT.Title = "Zom-Bees!"
EVENT.Description = "Spawns bees who spread zombiism to their victims"
EVENT.id = "zombees"

function EVENT:Begin()
    Randomat:SilentTriggerEvent("bees", self.owner)
    Randomat:SilentTriggerEvent("grave", self.owner, {"npc_manhack"})
end

function EVENT:Condition()
    return Randomat:CanEventRun("bees") and Randomat:CanEventRun("grave")
end

Randomat:register(EVENT)