local EVENT = {}

EVENT.Title = "Total Mayhem"
EVENT.Description = "Causes players to explode when killed"
EVENT.id = "mayhem"

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(tgt, src, ply)
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
        timer.Remove("RdmtBombDelay"..tgt:Nick())
    end)
end

Randomat:register(EVENT)