local EVENT = {}

CreateConVar("randomat_crabs_count", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Changes the ammount of crabs spawned when someone dies in the event \"Crabs are People\"")

EVENT.Title = "Crabs are People"
EVENT.id = "crabs"

function EVENT:Begin()
	local plys = {}
	for k, ply in pairs(player.GetAll()) do
		if not ply:IsSpec() then
			plys[k] = ply
		end
	end

	timer.Create("headcrabtimer", 1, 0, function()
		for k, ply in pairs(plys) do
			if not ply:Alive() then
				for i = 1, GetConVar("randomat_crabs_count"):GetInt() do
					local crab = ents.Create("npc_headcrab")
					crab:SetPos(ply:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), 0) )
					crab:Spawn()
					plys[k] = nil
				end
			end
		end
	end)
end

function EVENT:End()
	timer.Remove("headcrabtimer")
end

Randomat:register(EVENT)