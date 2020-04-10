local EVENT = {}

EVENT.Title = "SHUT UP!"
EVENT.id = "shutup"

function EVENT:Begin()
	timer.Create("RandomatDeafDelay", 1, 1, function()
		hook.Add("Think", "RandomatDeaf", function()
			for k, v in pairs(player.GetAll()) do
				v:ConCommand("soundfade 100 1")
			end
		end)
	end)
end

function EVENT:End()
	hook.Remove("Think", "RandomatDeaf")
end

Randomat:register(EVENT)