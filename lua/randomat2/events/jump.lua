local EVENT = {}

EVENT.Title = "You can only jump once."
EVENT.id = "jump"

function EVENT:Begin()
	hook.Add("KeyPress", "RdmtJumpHook", function(ply, key)

		if key == IN_JUMP and ply:Alive() and not ply:IsSpec() then 
			if ply.rdmtJumps then
				util.BlastDamage(ply, ply, ply:GetPos(), 100, 500)
				self:SmallNotify(ply:Nick().." tried to jump twice..")
				ply.rdmtJumps = nil
			else
				ply.rdmtJumps = 1
			end
		end

	end)
end

function EVENT:End()
	hook.Remove("KeyPress", "RdmtJumpHook")
end

Randomat:register(EVENT)