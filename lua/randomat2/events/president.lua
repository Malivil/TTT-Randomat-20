local EVENT = {}

EVENT.Title = "Get Down Mr President!"
EVENT.Description = "Gives all Detectives extra health, but kills all members of the Innocent team if they get killed"
EVENT.id = "president"
EVENT.Categories = {"rolechange", "deathtrigger", "biased_traitor", "biased", "largeimpact"}

CreateConVar("randomat_president_bonushealth", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Extra health gained by the detective", 1, 200)
CreateConVar("randomat_president_announce", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to announce when the president dies")

function EVENT:Begin(target)
    -- Update this in case the role names have been changed
    EVENT.Description = "Gives all " .. Randomat:GetRolePluralString(ROLE_DETECTIVE) .. " extra health, but kills all members of the " .. Randomat:GetRoleString(ROLE_INNOCENT) .. " team if they get killed"

    -- Default to the player passed as a paramter, if there is one
    if not target then
        target = self.owner
    end

    local has_detective = false
    if not IsValid(target) or not target:Alive() or not Randomat:IsGoodDetectiveLike(target) then
        for _, v in ipairs(self:GetAlivePlayers(true)) do
            if Randomat:IsGoodDetectiveLike(v) then
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

    local announce = GetConVar("randomat_president_announce"):GetBool()
    self:AddHook("PlayerDeath", function(tgt, dmg, ply)
        if IsValid(tgt) and tgt == target then
            if announce then
                self:SmallNotify("The President has been killed!")
            end
            for _, v in ipairs(self:GetAlivePlayers()) do
                if Randomat:IsInnocentTeam(v) then
                    v:Kill()
                end
            end
        end
    end)
end

function EVENT:Condition()
    local has_detective = false
    for _, v in ipairs(self:GetAlivePlayers()) do
        -- If there is a detraitor or a promoted impersonator, don't run this because it makes their jobs too easy
        if Randomat:IsEvilDetectiveLike(v) then
            return false
        elseif Randomat:IsGoodDetectiveLike(v) then
            has_detective = true
        end
    end

    return has_detective
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"bonushealth"}) do
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

    local checks = {}
    for _, v in ipairs({"announce"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end
    return sliders, checks
end

Randomat:register(EVENT)