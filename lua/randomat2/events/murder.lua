local EVENT = {}

EVENT.Title = "What gamemode is this again?"
EVENT.id = "murder"

CreateConVar("randomat_murder_pickups_pct", 1.5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Weapons required to get a revolver = (ConVarValue*TotalWeapons)/Players")
CreateConVar("randomat_murder_knifespeed", 1.2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Player movespeed whilst knife is held.")

util.AddNetworkString("RandomatRevolverHalo")
util.AddNetworkString("MurderEventActive")

function EVENT:Begin()
	local players = 0
	local wepspawns = 0

	for k, v in pairs(self:GetAlivePlayers(true)) do
		players = players+1
	end

	for k, v in pairs(ents.GetAll()) do
		if v.Base == "weapon_tttbase" and v.AutoSpawnable then
			wepspawns = wepspawns+1
		end
	end
	print("wepspawns = "..wepspawns)
	print("players = "..players)
	print("wepsneeded ="..wepspawns/players)
	local pck = math.ceil(wepspawns/players)
	net.Start("MurderEventActive")
	net.WriteBool(true)
	net.WriteInt(pck, 32)
	net.Broadcast()
	for k, v in pairs(self.GetAlivePlayers(true)) do
		if v:GetRole() == ROLE_DETECTIVE then
			timer.Create("RandomatRevolverTimer", 0.15, 1, function()
				v:Give("weapon_ttt_randomatrevolver")
				v:SetNWBool("RdmMurderRevolver", true)
			end)
        elseif v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ZOMBIE or v:GetRole() == ROLE_VAMPIRE then
            v:SetRole(ROLE_TRAITOR)
			timer.Create("RandomatKnifeTimer"..v:Nick(), 0.15, 1, function()
				v:Give("weapon_ttt_randomatknife")
            end)
        -- Anyone else becomes an innocent
        else
            v:SetRole(ROLE_INNOCENT)
		end
		if v:GetRole() == ROLE_INNOCENT then
			v:PrintMessage(HUD_PRINTTALK, "Stay alive and gather weapons! Gathering "..pck.." weapons will give you a revolver!")
		end
	end
	SendFullStateUpdate()

	timer.Create("RandomatMurderTimer", 0.1, 0, function()
		for k, v in pairs(self.GetAlivePlayers(true)) do
			for _, wep in pairs(v:GetWeapons()) do
				if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE or wep.ClassName == "weapon_zm_improvised"  then
					v:StripWeapon(wep.ClassName)
					v:SetFOV(0, 0.2)
				end
			end
			if v:GetNWInt("MurderWeaponsEquipped") >= pck then
				v:SetNWInt("MurderWeaponsEquipped", 0)
				if v:GetRole() ~= ROLE_ZOMBIE then
					v:Give("weapon_ttt_randomatrevolver")
				end
				v:SetNWBool("RdmMurderRevolver", true)
			end
		end
	end)

	hook.Add("EntityTakeDamage", "RandomatMurderDMG", function(tgt, dmg)
		if tgt:IsPlayer() and tgt:GetRole() ~= ROLE_TRAITOR and dmg:IsBulletDamage() then
			dmg:ScaleDamage(0.25)
		end
	end)

	hook.Add("WeaponEquip", "RandomatRevolverPickup", function(wep, ply)
		if wep.ClassName ~= "weapon_ttt_randomatrevolver" and wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL or wep.Kind == WEAPON_NADE then
			ply:SetNWInt("MurderWeaponsEquipped", ply:GetNWInt("MurderWeaponsEquipped") +1)
		end
	end)

	hook.Add("TTTPlayerSpeed", "RdmtMurderSpeed" , function(ply)
		if ply:GetActiveWeapon().ClassName == "weapon_ttt_randomatknife" then
			return  GetConVar("randomat_murder_knifespeed"):GetFloat()
		else 
			return 1
		end
	end)

	hook.Add("PlayerDeath", "DropRdmtRevolver", function(tgt, wep, ply)
		if table.HasValue(player.GetAll(), ply) then
			if IsValid(ply) and ply:Alive() and not ply:IsSpec() then
			  if ply:GetActiveWeapon().ClassName == "weapon_ttt_randomatrevolver" and not IsEvil(tgt) and not IsEvil(ply) then
			     ply:DropWeapon(ply:GetActiveWeapon())
			     ply:SetNWBool("RdmtShouldBlind", true)
			     timer.Create("RdmtBlindEndDelay"..ply:Nick(), 5, 1, function()
			        ply:SetNWBool("RdmtShouldBlind", false)
			     end)
			  end
			end
		end
	end)
end

function EVENT:End()
	timer.Remove("RandomatMurderTimer")
	hook.Remove("WeaponEquip", "RandomatRevolverPickup")
	hook.Remove("DrawOverlay", "RdmtMurderBlind")
	hook.Remove("EntityTakeDamage", "RandomatMurderDMG")
	hook.Add("TTTPlayerSpeed", "RdmtMurderSpeed")
	for k, v in pairs(player.GetAll()) do
		v:SetNWInt("MurderWeaponsEquipped", 0)
		v:SetNWBool("RdmMurderRevolver", false)
	end
	net.Start("MurderEventActive")
	net.WriteBool(false)
	net.Broadcast()
	hook.Remove("PlayerDeath", "DropRdmtRevolver")
end

function EVENT:Condition()
	local d = 0
	local t = 0
	for k, v in pairs(player.GetAll()) do
		if v:Alive() and not v:IsSpec() then
			if v:GetRole() == ROLE_DETECTIVE then
				d = d+1
			elseif v:GetRole() == ROLE_TRAITOR or v:GetRole() == ROLE_HYPNOTIST or v:GetRole() == ROLE_ASSASSIN or v:GetRole() == ROLE_ZOMBIE or v:GetRole() == ROLE_VAMPIRE then
				t = t+1
			end
		end
	end
	if d > 0 and t > 1 then
		return true
	else
		return false
	end
end

Randomat:register(EVENT)