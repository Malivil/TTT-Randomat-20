local EVENT = {}

EVENT.Title = "Get Down Mr President!"
EVENT.id = "president"

CreateConVar("randomat_president_bonushealth", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Extra health gained by the detective")

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

    hook.Add("PlayerDeath", "RandomatPresident", function(tgt, dmg, ply)
        if tgt:IsValid() and tgt == owner then
            for _, v in pairs(self:GetAlivePlayers(true)) do
                if v:GetRole() == ROLE_INNOCENT or v:GetRole() == ROLE_PHANTOM or v:GetRole() == ROLE_MERCENARY or v:GetRole() == ROLE_GLITCH or v:GetRole() == ROLE_DETECTIVE then
                    v:Kill()
                end
            end
        end
    end)
end

function EVENT:End()
    hook.Remove("PlayerDeath", "RandomatPresident")
end

function EVENT:Condition()
    local d = 0
    for k, v in pairs(self:GetAlivePlayers(true)) do
        if v:GetRole() == ROLE_DETECTIVE then
            d = 1
        end
    end

    if d == 1 then
        return true
    end
end

Randomat:register(EVENT)