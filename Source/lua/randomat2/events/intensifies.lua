local EVENT = {}

CreateConVar("randomat_intensifies_timer", 20, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Changes how often you get a randomat in the event \"Randomness Intensifies\"")

EVENT.Title = "Randomness Intensifies"
EVENT.id = "intensifies"

function EVENT:Begin()
	timer.Create("RandomatRandomatTimer", GetConVar("randomat_intensifies_timer"):GetInt() , 0, function()
		Randomat:TriggerRandomEvent()
	end)
end

function EVENT:End()
	timer.Remove("RandomatRandomatTimer")
end

Randomat:register(EVENT)