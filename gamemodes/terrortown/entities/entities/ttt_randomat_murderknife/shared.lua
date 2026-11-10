AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName		= "Thrown Knife"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/weapons/w_knife_t.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(false)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end

        -- Safety cleanup timer if it never settles
        self:Fire("kill", "", 30)

        self.HitSomething = false
    end

    -- Native GMod collision hook for scripted entities
    function ENT:PhysicsCollide(data, phys)
        if self.HitSomething then return end

        local victim = data.HitEntity
        local owner = self:GetOwner()

        if IsValid(victim) and IsPlayer(victim) and victim ~= owner then
            self.HitSomething = true

            local dmg = DamageInfo()
            dmg:SetDamage(120)
            dmg:SetAttacker(IsValid(owner) and owner or self)
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_SLASH)
            victim:TakeDamageInfo(dmg)

            self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav")
        else
            -- Mark that it has hit the world / ground
            self.HitSomething = true
        end
    end

    function ENT:Think()
        -- Once it has collided and slowed down to a stop, turn back into a weapon
        if self.HitSomething and self:GetVelocity():Length2D() < 20 then
            local wep = ents.Create("weapon_ttt_randomatmurderknife")
            if IsValid(wep) then
                wep:SetPos(self:GetPos())
                wep:SetAngles(self:GetAngles())
                wep:Spawn()

                local phys = wep:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(self:GetVelocity())
                end
            end
            self:Remove()
            return
        end

        self:NextThink(CurTime() + 0.1)
        return true
    end
end

if CLIENT then
    function ENT:Initialize()
        self.Emitter = ParticleEmitter(self:GetPos())
        self.NextPart = CurTime()
    end

    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:Think()
        local pos = self:GetPos()
        local client = LocalPlayer()

        if IsValid(client) and client:GetPos():Distance(pos) <= 1000 then
            if (self.NextPart or 0) < CurTime() then
                if self.Emitter then
                    self.Emitter:SetPos(pos)
                    self.NextPart = CurTime() + math.Rand(0, 0.02)

                    local vec = VectorRand() * 3
                    local particlePos = self:LocalToWorld(vec)
                    local particle = self.Emitter:Add("particle/snow.vmt", particlePos)
                    if particle then
                        particle:SetVelocity(Vector(0, 0, 4))
                        particle:SetDieTime(7)
                        particle:SetStartAlpha(140)
                        particle:SetEndAlpha(0)
                        particle:SetStartSize(5)
                        particle:SetEndSize(6)
                        particle:SetRoll(0)
                        particle:SetRollDelta(0)
                        particle:SetColor(0, 0, 0)
                    end
                end
            end
        end
    end

    function ENT:OnRemove()
        if self.Emitter then
            self.Emitter:Finish()
        end
    end
end