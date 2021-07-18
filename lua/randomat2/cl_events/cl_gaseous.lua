net.Receive("RdmtGaseousBegin", function()
    local client = LocalPlayer()
    hook.Add("Think", "RdmtGaseousThink", function()
        for _, v in ipairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() then
                if not v.SmokeEmitter then v.SmokeEmitter = ParticleEmitter(v:GetPos()) end
                if not v.SmokeNextPart then v.SmokeNextPart = CurTime() end
                local pos = v:GetPos() + Vector(0, 0, 30)
                if v.SmokeNextPart < CurTime() then
                    if client:GetPos():Distance(pos) <= 3000 then
                        v.SmokeEmitter:SetPos(pos)
                        v.SmokeNextPart = CurTime() + math.Rand(0.003, 0.01)
                        local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
                        local particle = v.SmokeEmitter:Add("particle/snow.vmt", v:LocalToWorld(vec))
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
                if v.SmokeEmitter then
                    v.SmokeEmitter:Finish()
                    v.SmokeEmitter = nil
                end
            end
        end
    end)
end)

net.Receive("RdmtGaseousEnd", function()
    hook.Remove("Think", "RdmtGaseousThink")
end)