local EVENT = {}

EVENT.Title = "RISE FROM YOUR GRAVE"
EVENT.id = "grave"

CreateConVar("randomat_grave_health", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Changes the health that the Zombies respawn with in the event \"RISE FROM YOUR GRAVE\"")

function EVENT:Begin()
	timer.Create("infrespawntimer", 1, 0, function()
		for k, ply in pairs(player.GetAll()) do
			if not ply:Alive() and ply:GetRole() ~= ROLE_ZOMBIE then
				ply:SetRole(ROLE_ZOMBIE)
				ply:SpawnForRound(true)
				ply:SetHealth(GetConVar("randomat_grave_health"):GetInt())
                ply:SetMaxHealth(GetConVar("randomat_grave_health"):GetInt())
                ply:SetZombiePrime(false)
                ply:StripWeapons()
                ply:Give("weapon_zom_claws")
				SendFullStateUpdate()
			end
		end
	end)
end

function EVENT:End()
	timer.Remove("infrespawntimer")
end

Randomat:register(EVENT)