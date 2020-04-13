local EVENT = {}

EVENT.Title = "The 'bar has been raised!"
EVENT.id = "crowbar"

CreateConVar("randomat_crowbar_damage", 2.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Damage multiplier for the crowbar")
CreateConVar("randomat_crowbar_push", 20, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Push force multiplier for the crowbar")

local push = 0

function EVENT:Begin()
	push = GetConVar("ttt_crowbar_pushforce"):GetInt()
	RunConsoleCommand("ttt_crowbar_pushforce", push*GetConVar("randomat_crowbar_push"):GetFloat())
	for k, v in pairs(player.GetAll()) do
		for _, wep in pairs(v:GetWeapons()) do
			if wep:GetClass() == "weapon_zm_improvised" then
				wep.Primary.Damage = wep.Primary.Damage * GetConVar("randomat_crowbar_damage"):GetFloat()
			end
		end
	end
end

function EVENT:End()
	RunConsoleCommand("ttt_crowbar_pushforce", push)
end

Randomat:register(EVENT)