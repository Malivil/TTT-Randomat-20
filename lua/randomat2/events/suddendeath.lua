local EVENT = {}

EVENT.Title = "Sudden Death!"
EVENT.id = "suddendeath"

function EVENT:Begin()
	timer.Create("suddendeathtimer", 1, 0, function()
		for k, ply in pairs(self:GetAlivePlayers()) do
			ply:SetHealth(1)
			ply:SetMaxHealth(1)
		end
	end)
end

function EVENT:End()
	timer.Remove("suddendeathtimer")
end

Randomat:register(EVENT)