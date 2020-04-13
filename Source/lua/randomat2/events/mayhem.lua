local EVENT = {}


EVENT.Title = "Total Mayhem"
EVENT.id = "mayhem"

function EVENT:Begin()

	local effectdata = EffectData()

	hook.Add("PlayerDeath","RdmtBomb", function(tgt, src, ply)
		ExplodeTgt(tgt, ply)
	end)
end

function ExplodeTgt(tgt, ply)
	timer.Create("RdmtBombDelay"..tgt:Nick(), 0.1, 1, function()
		local explode = ents.Create("env_explosion")
		explode:SetPos(tgt:GetPos())
		explode:SetOwner(ply)
		explode:Spawn()
		explode:SetKeyValue("iMagnitude", "150")
		explode:Fire("Explode", 0,0)
		explode:EmitSound("ambient/explosions/explode_4.wav", 400, 400)
	end)
end

function EVENT:End()
	hook.Remove("PlayerDeath", "RdmtBomb")
end

Randomat:register(EVENT)