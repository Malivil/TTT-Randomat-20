local EVENT = {}

EVENT.Title = "I see dead people"
EVENT.id = "visualiser"

function EVENT:Begin()
	hook.Add("PlayerDeath", "RandomatVisualiser", function(ply)
		cse = ents.Create("ttt_cse_proj")
		if IsValid(cse) then
			cse:SetPos(ply:GetPos())
			cse:SetOwner(ply)
			cse:SetThrower(ply)
			cse:Spawn()
			cse:PhysWake()
			local phys = cse:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(0,0,0))
			end
		end
	end)
end

function EVENT:End()
	hook.Remove("PlayerDeath", "RandomatVisualiser")
end

Randomat:register(EVENT)