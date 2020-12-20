local EVENT = {}

CreateConVar("randomat_lifesteal_health", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The health gained per kill")
CreateConVar("randomat_lifesteal_cap", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum health a player can get from killing people. Set to 0 to disable")

EVENT.Title = "Gaining life for killing people? Is it really worth it..."
EVENT.Description = "Heals players who kill other players"
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