local EVENT = {}

EVENT.Title = "Can't stop, won't stop."
EVENT.id = "cantstop"

CreateConVar("randomat_cantstop_disableback", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Disables the \"s\" key")

function EVENT:Begin()
	local plys = {}
	for k, v in pairs(player.GetAll()) do
		plys[k] = v
	end
	hook.Add("Think", "ForceWalk", function()
		for k, v in pairs(plys) do
			if v:Alive() and not v:IsSpec() then
				v:ConCommand("+forward")
				if GetConVar("randomat_cantstop_disableback"):GetBool() then
					v:ConCommand("-back")
				end
			else
				v:ConCommand("-forward")
				plys[k] = nil
			end
		end
	end)
end

function EVENT:End()
	hook.Remove("Think", "ForceWalk")
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("-forward")
	end
end

Randomat:register(EVENT)