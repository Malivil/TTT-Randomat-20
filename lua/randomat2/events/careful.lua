local EVENT = {}

CreateConVar("randomat_careful_health", 1, FCVAR_NONE, "Health to set Jester/Swapper to", 1, 10)

EVENT.Title = "Careful..."
EVENT.Description = "Set all Jesters and Swappers to a reduced amount of health"
EVENT.id = "careful"
EVENT.Categories = {"moderateimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description =  "Set all " .. Randomat:GetRolePluralString(ROLE_JESTER) .. " and " .. Randomat:GetRolePluralString(ROLE_SWAPPER) .. " to a reduced amount of health"
end

function EVENT:Begin()
    local health = GetConVar("randomat_careful_health"):GetInt()
    for _, ply in ipairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_JESTER or ply:GetRole() == ROLE_SWAPPER then
            ply:SetHealth(health)
            ply:SetMaxHealth(health)
        end
    end
end

function EVENT:Condition()
    -- Only run if there is at least one jester/swapper living
    for _, v in ipairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_JESTER or v:GetRole() == ROLE_SWAPPER then
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