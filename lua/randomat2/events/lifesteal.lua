local EVENT = {}

CreateConVar("randomat_lifesteal_health", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The health gained per kill", 1, 100)
CreateConVar("randomat_lifesteal_cap", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The max health a player can get (0 to disable)", 0, 100)

EVENT.Title = "Gaining life for killing people? Is it really worth it..."
EVENT.Description = "Heals players who kill other players"
EVENT.id = "lifesteal"

function EVENT:Begin()
    local cap = GetConVar("randomat_lifesteal_cap"):GetInt()
    local health = GetConVar("randomat_lifesteal_health"):GetInt()
    self:AddHook("PlayerDeath", function(victim, inflictor, attacker)
        local new_health = attacker:Health() + health
        if cap > 0 and new_health > cap then
            new_health = cap
        end
        attacker:SetHealth(new_health)
    end)
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"health", "cap"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)