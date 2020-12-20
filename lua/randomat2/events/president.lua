local EVENT = {}

EVENT.Title = "Get Down Mr President!"
EVENT.Description = "Gives all Detectives extra health, but kills all members of the Innocent team if they get killed"
EVENT.id = "president"

CreateConVar("randomat_president_bonushealth", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Extra health gained by the detective", 1, 200)

function EVENT:Begin()
    local owner
    local d = 0
    if self.owner:GetRole() ~= ROLE_DETECTIVE then
        for _, v in pairs(self:GetAlivePlayers(true)) do
            if v:GetRole() == ROLE_DETECTIVE then
                d = 1
                owner = v
            end
        end
        if d ~= 1 then
            owner = self.owner
        end
        Randomat:SetRole(owner, ROLE_DETECTIVE)
        SendFullStateUpdate()
    else
        owner = self.owner
    end
    owner:SetMaxHealth(owner:GetMaxHealth()+GetConVar("randomat_president_bonushealth"):GetInt())
    owner:SetHealth(owner:GetMaxHealth())

    self:AddHook("PlayerDeath", function(tgt, dmg, ply)
        if tgt:IsValid() and tgt == owner then
            for _, v in pairs(self:GetAlivePlayers()) do
                if v:GetRole() == ROLE_INNOCENT or v:GetRole() == ROLE_PHANTOM or v:GetRole() == ROLE_MERCENARY or v:GetRole() == ROLE_GLITCH or v:GetRole() == ROLE_DETECTIVE then
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