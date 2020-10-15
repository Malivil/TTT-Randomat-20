local EVENT = {}

EVENT.Title = "We learned how to heal over time, its hard, but definitely possible..."
EVENT.id = "regeneration"

CreateConVar("randomat_regeneration_delay", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long after taking damage you will start to regen health")
CreateConVar("randomat_regeneration_health", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How much health per second you heal")

function EVENT:Begin()
    for _, ply in pairs(self:GetAlivePlayers()) do
        ply.rmdregeneration = CurTime() + 1
    end

    self:AddHook("Think", function() self:Regeneration() end)

    self:AddHook("EntityTakeDamage", function(victim, dmg)
        if IsValid(victim) and victim:IsPlayer() and victim:IsTerror() and dmg:GetDamage() < victim:Health() then
            victim.rmdregeneration = CurTime() + GetConVar("randomat_regeneration_delay"):GetInt()
        end
    end)
end

function EVENT:Regeneration()
    for _, ply in pairs(self:GetAlivePlayers()) do
        if ply.rmdregeneration <= CurTime() then
            ply:SetHealth(math.Clamp(ply:Health() + GetConVar("randomat_regeneration_health"):GetInt(), 0, ply:GetMaxHealth()))
            ply.rmdregeneration = CurTime() + 1
        end
    end
end

Randomat:register(EVENT)