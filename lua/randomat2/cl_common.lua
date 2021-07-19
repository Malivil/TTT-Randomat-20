function Randomat:HandlePlayerSmoke(client, pred)
    for _, v in ipairs(player.GetAll()) do
        if pred(v) then
            if not v.RdmtSmokeEmitter then v.RdmtSmokeEmitter = ParticleEmitter(v:GetPos()) end
            if not v.RdmtSmokeNextPart then v.RdmtSmokeNextPart = CurTime() end
            local pos = v:GetPos() + Vector(0, 0, 30)
            if v.RdmtSmokeNextPart < CurTime() then
                if client:GetPos():Distance(pos) <= 3000 then
                    v.RdmtSmokeEmitter:SetPos(pos)
                    v.RdmtSmokeNextPart = CurTime() + math.Rand(0.003, 0.01)
                    local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
                    local particle = v.RdmtSmokeEmitter:Add("particle/snow.vmt", v:LocalToWorld(vec))
                    particle:SetVelocity(Vector(0, 0, 4) + VectorRand() * 3)
                    particle:SetDieTime(math.Rand(0.5, 2))
                    particle:SetStartAlpha(math.random(150, 220))
                    particle:SetEndAlpha(0)
                    local size = math.random(4, 7)
                    particle:SetStartSize(size)
                    particle:SetEndSize(size + 1)
                    particle:SetRoll(0)
                    particle:SetRollDelta(0)
                    particle:SetColor(0, 0, 0)
                end
            end
        else
            if v.RdmtSmokeEmitter then
                v.RdmtSmokeEmitter:Finish()
                v.RdmtSmokeEmitter = nil
            end
        end
    end
end