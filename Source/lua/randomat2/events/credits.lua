local EVENT = {}

EVENT.Title = "Infinite Credits for everyone!"
EVENT.id = "credits"

function EVENT:Begin()
	timer.Create("GiveCredsTimer", 0, 0, function() 
		for k, ply in pairs(player.GetAll()) do
			ply:SetCredits(1) 
		end
	end)
end

function EVENT:End()
	timer.Remove("GiveCredsTimer")
end

Randomat:register(EVENT)