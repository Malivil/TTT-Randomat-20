local EVENT = {}

EVENT.Title = "Sosig."
EVENT.id = "sosig"

util.AddNetworkString("TriggerSosig")

function EVENT:Begin()
	net.Start("TriggerSosig")
	net.Broadcast()
	for k, ply in pairs(player.GetAll()) do
		for _, wep in pairs(ply:GetWeapons()) do
			wep.Primary.Sound = "weapons/sosig.mp3"
		end
	end
	hook.Add("WeaponEquip", "RandomatSosig", function(wep, ply)
		timer.Create("SosigDelay", 0.1, 1, function()
			net.Start("TriggerSosig")
			net.Send(ply)
			for k, ply in pairs(player.GetAll()) do
				for _, wep in pairs(ply:GetWeapons()) do
					wep.Primary.Sound = "weapons/sosig.mp3"
				end
			end	
		end)
	end)
end

function EVENT:End()
	hook.Remove("WeaponEquip", "RandomatSosig")
end

Randomat:register(EVENT)