local EVENT = {}

CreateConVar("randomat_lifesteal_health", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Changes the health value per kill from the event \"Gaining life for killing people?\"")
CreateConVar("randomat_lifesteal_cap", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sets the health cap from killing people in the event \"Gaining life for killing people?\" (set to 0 to disable cap)")

EVENT.Title = "Gaining life for killing people? Is it really worth it..."
EVENT.id = "lifesteal"

function EVENT:Begin()
    self:AddHook("PlayerDeath", function(victim, inflictor, attacker)
        attacker:SetHealth(attacker:Health() + GetConVar("randomat_lifesteal_health"):GetInt())
        if attacker:Health() > GetConVar("randomat_lifesteal_cap"):GetInt() and GetConVar("randomat_lifesteal_cap"):GetInt() ~= 0 then
            attacker:SetHealth(GetConVar("randomat_lifesteal_cap"):GetInt())
        end
    end)
end

Randomat:register(EVENT)