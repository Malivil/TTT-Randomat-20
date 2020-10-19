local EVENT = {}

EVENT.Title = "I see dead people"
EVENT.id = "visualiser"

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(ply)
        local cse = ents.Create("ttt_cse_proj")
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

Randomat:register(EVENT)