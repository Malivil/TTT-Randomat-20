local EVENT = {}

EVENT.Title = "Try your best..."
EVENT.id = "randomweapon"

function EVENT:Begin()
	local tbl1 = {}
	local tbl2 = {}

	for _, wep in RandomPairs(weapons.GetList()) do
		if wep.AutoSpawnable and wep.Kind == WEAPON_HEAVY then
			table.insert(tbl1, wep)
		end

		if wep.AutoSpawnable and wep.Kind == WEAPON_PISTOL then
			table.insert(tbl2, wep)
		end
	end

	for i, ply in pairs(self:GetPlayers()) do
		for _, wep in pairs(ply:GetWeapons()) do
			if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
				ply:StripWeapon(wep:GetClass())
			end
		end

		local rdmwep1 = table.Random(tbl1)
		local rdmwep2 = table.Random(tbl2)

		local wep1 = ply:Give(rdmwep1.ClassName)
		local wep2 = ply:Give(rdmwep2.ClassName)

		wep1.AllowDrop = false
		wep2.AllowDrop = false
	end
end

Randomat:register(EVENT)