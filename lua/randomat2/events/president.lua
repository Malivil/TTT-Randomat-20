local EVENT = {}

EVENT.Title = "Get Down Mr President!"
EVENT.Description = "Gives all Detectives extra health, but kills all members of the Innocent team if they get killed"
EVENT.id = "president"

CreateConVar("randomat_president_bonushealth", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Extra health gained by the detective", 1, 200)

function EVENT:Begin(...)
    local params = ...
    local target = self.owner
    local has_detective = false

    -- Default to the player passed as a paramter, if there is one
    if params ~= nil and params[1] ~= nil then
        target = params[1]
    end

    if not IsValid(target) or not target:Alive() or target:GetRole() ~= ROLE_DETECTIVE then
        for _, v in pairs(self:GetAlivePlayers(true)) do
            if v:GetRole() == ROLE_DETECTIVE then
                has_detective = true
                target = v
            end
        end
        if not has_detective then
            target = self.owner
        end
        Randomat:SetRole(target, ROLE_DETECTIVE)
        SendFullStateUpdate()
    end
    target:SetMaxHealth(target:GetMaxHealth()+GetConVar("randomat_president_bonushealth"):GetInt())
    target:SetHealth(target:GetMaxHealth())

    self:AddHook("PlayerDeath", function(tgt, dmg, ply)
        if tgt:IsValid() and tgt == target then
            for _, v in pairs(self:GetAlivePlayers()) do
                if Randomat:IsInnocentTeam(v) then
                    v:Kill()
                end
            end
        end
    end)
end

function EVENT:Condition()
    local has_detective = false
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_DETECTIVE then
            has_detective = true
        elseif v:GetRole() == ROLE_DETRAITOR then
            return false
        end
    end

    return has_detective
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"bonushealth"}) do
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