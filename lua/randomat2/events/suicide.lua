AddCSLuaFile()

local EVENT = {}

EVENT.Title = "So that's it. What, we some kind of suicide squad?"
EVENT.id = "suicide"

local ROLE_JESTER = ROLE_JESTER or false

plylist = {}

function EVENT:Begin()
	local plysize = 0

	plylist = {}

	for k, v in pairs(self:GetAlivePlayers(true)) do
		plysize = plysize + 1

		plylist[plysize] = {}
		plylist[plysize]["ply"] = v
		plylist[plysize]["tgt"] = v

	end

	for k, v in pairs(plylist) do

		if plysize > 1 and k < plysize then

			plylist[k]["tgt"] = plylist[k+1]["ply"]	

		elseif plysize > 1 then
			
			plylist[k]["tgt"] = plylist[1]["ply"]

		end

		timer.Create("RandomatDetTimer", 1, 5, function() plylist[k]["ply"]:PrintMessage(HUD_PRINTCENTER, "You have a detonator for "..plylist[k]["tgt"]:Nick()) end)
		
		plylist[k]["ply"]:PrintMessage(HUD_PRINTTALK, "You have a detonator for "..plylist[k]["tgt"]:Nick())

		for i, wep in pairs(plylist[k]["ply"]:GetWeapons()) do
			if wep.Kind == WEAPON_EQUIP2 then
				plylist[k]["ply"]:StripWeapon(wep:GetClass())
			end
		end

		plylist[k]["ply"]:Give("weapon_ttt_randomatdet")

		plylist[k]["ply"]:GetWeapon("weapon_ttt_randomatdet").Target = plylist[k]["tgt"]

	end
end

function PlayerDetonate(owner, ply)
	local effectdata = EffectData()
	if owner:GetRole() ~= ROLE_JESTER then
		local explode = ents.Create("env_explosion")
		explode:SetPos(ply:GetPos())
		explode:SetOwner(owner)
		explode:Spawn()
		explode:SetKeyValue("iMagnitude", "230")
		explode:Fire("Explode", 0,0)
		explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
	end
	for _, v in pairs(player.GetAll()) do
		v:PrintMessage(HUD_PRINTTALK, owner:Nick().." has detonated "..ply:Nick())
	end
end

function EVENT:End()
	timer.Remove("RandomatDetTimer")
end

Randomat:register(EVENT)