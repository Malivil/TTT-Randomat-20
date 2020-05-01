AddCSLuaFile()
ENT.Type = "anim"

CreateConVar("randomat_cakes_health", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the player will regain from eating a cake")
CreateConVar("randomat_cakes_damage", 25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the player will lose from eating a cake")
CreateConVar("randomat_cakes_damage_time", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of time the player will take damage after eating a cake")
CreateConVar("randomat_cakes_damage_interval", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often the player will take damage after eating a cake")
CreateConVar("randomat_cakes_damage_over_time", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The amount of health the player will lose each tick after eating a cake")

function ENT:Initialize()
	self.Entity:SetModel("models/871/871.mdl")
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetModelScale(2)
    self.Entity:SetHealth(1)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
        phys:Wake()
    end

    hook.Add("TTTEndRound", "RdmtCakeTimerRoundEndRemove", function()
        for _, ply in pairs(player.GetAll()) do
            timer.Remove(ply:GetName() .. "RdmtCakeDamageTimer")
        end
    end)
    hook.Add("PlayerDeath", "RdmtCakeTimerDeathRemove", function(victim, entity, killer)
        if not IsValid(victim) then return end
        timer.Remove(victim:GetName() .. "RdmtCakeDamageTimer")
    end)
end

function ENT:OnRemove()
end

function ENT:OnTakeDamage(dmgInfo)
    self.Entity:Remove()
    return true
end

function ENT:Think()
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
        activator:TakeDamage(damageAmount, nil, nil)
        activator:ChatPrint("You overate! Wait it out or try to eat another piece of cake to see if that stops the pain... somehow")

        local totaltime = GetConVar("randomat_cakes_damage_time"):GetInt()
        local interval = GetConVar("randomat_cakes_damage_interval"):GetInt()
        local repetitions = totaltime / interval
        timer.Create(activator:GetName() .. "RdmtCakeDamageTimer", interval, repetitions,function()
            local dotAmount =  GetConVar("randomat_cakes_damage_over_time"):GetInt()
            activator:TakeDamage(dotAmount, nil, nil)
        end)
    end
	self:Remove()
end

function ENT:Break()
end
