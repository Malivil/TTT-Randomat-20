local EVENT = {}

CreateConVar("randomat_careful_health", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Health to set Jester/Swapper to", 1, 10)

EVENT.Title = "Careful..."
EVENT.Description = "Set all Jesters and Swappers to a reduced amount of health"
EVENT.id = "careful"

function EVENT:Begin()
    local health = GetConVar("randomat_careful_health"):GetInt()
    for _, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsJesterTeam(ply) then
            ply:SetHealth(health)
            ply:SetMaxHealth(health)
        end
    end
end

function EVENT:Condition()
    -- Only run if there is at least one jester/swapper living
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsJesterTeam(v) then
            return true
        end
    end

    return false
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"health"}) do
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