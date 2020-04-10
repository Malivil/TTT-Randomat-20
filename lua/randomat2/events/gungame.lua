local EVENT = {}

EVENT.Title = "Gun Game"
EVENT.id = "gungame"

CreateConVar("randomat_gungame_timer", 5, {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "Time between weapon changes")

function EVENT:Begin()
	local weps = {}
	for k, ent in pairs(ents.GetAll()) do
		if ent.Base == "weapon_tttbase" and ent.AutoSpawnable then
			ent:Remove()
		end
	end
	for k, wep in pairs(weapons.GetList()) do
		if wep.AutoSpawnable and (wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL) then
			table.insert(weps, wep)
		end
	end
	timer.Create("RdmtWeaponShuffle", GetConVar("randomat_gungame_timer"):GetInt(), 0, function()
		for k, v in pairs(player.GetAll()) do
			local ac = false
			if v:GetActiveWeapon().Kind == WEAPON_HEAVY or v:GetActiveWeapon().Kind == WEAPON_PISTOL then
				ac = true
			end
			for _, wep in pairs(v:GetWeapons()) do
				if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
					v:StripWeapon(wep.ClassName)
				end
			end
			local wepGiven = table.Random(weps)
			v:Give(wepGiven.ClassName)
			v:SetFOV(0, 0.2)
			if ac then
				v:SelectWeapon(wepGiven.ClassName)
			end
		end
	end)	
end

function EVENT:End()
	timer.Remove("RdmtWeaponShuffle")
end

Randomat:register(EVENT)