AddCSLuaFile()
ENT.Type = "anim"

function ENT:Initialize()
    self:SetModel("models/871/871.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetHealth(1)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmgInfo)
    self:Remove()
    return true
end

function ENT:Think()
end

local function TakeDamage(dmg, activator)
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(dmg)
    dmginfo:SetAttacker(game.GetWorld())
    dmginfo:SetInflictor(game.GetWorld())
    dmginfo:SetDamageType(DMG_BULLET)
    dmginfo:SetDamageForce(Vector(0, 0, 0))
    activator:TakeDamageInfo(dmginfo)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:Alive() or activator:IsSpec() then return end

    if math.random(0, 1) == 0 then
        local healamount = GetConVar("randomat_cakes_health"):GetInt()
        local hp = activator:Health()
        local newhp = hp + healamount
        activator:SetHealth(newhp)
        activator:ChatPrint("Delicious cake!")
        timer.Remove(activator:GetName() .. "RdmtCakeDamageTimer")
    else
        local damageAmount = GetConVar("randomat_cakes_damage"):GetInt()
        TakeDamage(damageAmount, activator)
        activator:ChatPrint("You overate! Wait it out or try to eat another piece of cake to see if that stops the pain... somehow")

        local totaltime = GetConVar("randomat_cakes_damage_time"):GetInt()
        local interval = GetConVar("randomat_cakes_damage_interval"):GetInt()
        local repetitions = totaltime / interval
        timer.Create(activator:GetName() .. "RdmtCakeDamageTimer", interval, repetitions, function()
            local dotAmount =  GetConVar("randomat_cakes_damage_over_time"):GetInt()
            TakeDamage(dotAmount, activator)
        end)
    end
    self:Remove()
end

function ENT:Break()
end
