local EVENT = {}

EVENT.Title = "You can only jump once."
EVENT.id = "jump"

function EVENT:Begin()
    self:AddHook("KeyPress", function(ply, key)
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

Randomat:register(EVENT)