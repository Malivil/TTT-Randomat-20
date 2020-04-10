local EVENT = {}

CreateConVar("randomat_randomxn_triggers", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Number of randomats activated.")

EVENT.Title = ""
EVENT.AltTitle = "Random x"..GetConVar("randomat_randomxn_triggers"):GetInt()
EVENT.id = "randomxn"

function EVENT:Begin()
	Randomat:EventNotifySilent("Random x"..GetConVar("randomat_randomxn_triggers"):GetInt())
	timer.Create("RandomxnTimer", 5, GetConVar("randomat_randomxn_triggers"):GetInt(), function()
		Randomat:TriggerRandomEvent()
	end)
end

function EVENT:End()
	timer.Remove("RandomxnTimer")
end

Randomat:register(EVENT)