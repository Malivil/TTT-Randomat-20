local EVENT = {}

EVENT.Title = "Get Down Mr. Romero!"
EVENT.Description = "Gives Detectives extra health, but if they get killed, all living members of the Innocent team are converted to Zombies"
EVENT.id = "romero"
EVENT.Categories = {"rolechange", "deathtrigger", "biased_zombie", "biased", "largeimpact"}

CreateConVar("randomat_romero_bonushealth", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Extra health gained by the detective", 1, 200)
CreateConVar("randomat_romero_announce", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to announce when Mr. Romero dies")

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = "Gives " .. Randomat:GetRolePluralString(ROLE_DETECTIVE) .. " extra health, but if they get killed, all living members of the " .. Randomat:GetRoleString(ROLE_INNOCENT) .. " are converted to " .. Randomat:GetRolePluralString(ROLE_ZOMBIE)
end

function EVENT:Begin(target)
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
    target:SetMaxHealth(target:GetMaxHealth() + GetConVar("randomat_romero_bonushealth"):GetInt())
    target:SetHealth(target:GetMaxHealth())

    local announce = GetConVar("randomat_romero_announce"):GetBool()
    self:AddHook("PlayerDeath", function(tgt, dmg, ply)
        if IsValid(tgt) and tgt == target then
            if announce then
                self:SmallNotify("Mr. Romero has been killed!")
            end
            local zombified = false
            for _, v in ipairs(self:GetAlivePlayers()) do
                if Randomat:IsInnocentTeam(v) then
                    net.Start("TTT_Zombified")
                    net.WriteString(v:Nick())
                    net.Broadcast()

                    v:SetCredits(0)
                    v:SetRole(ROLE_ZOMBIE)
                    if v.SetZombiePrime then
                        v:SetZombiePrime(false)
                    end
                    v:StripWeapons()
                    v:Give("weapon_zom_claws")
                    zombified = true
                end
            end

            if zombified then
                SendFullStateUpdate()
            end
        end
    end)
end

function EVENT:Condition()
    if not ConVarExists("ttt_zombie_enabled") or not GetConVar("ttt_zombie_enabled"):GetBool() then
        return false
    end

    local has_detective = false
    for _, v in ipairs(self:GetAlivePlayers()) do
        -- If there is a detraitor or a promoted impersonator, don't run this because it makes their jobs too easy
        if Randomat:IsEvilDetectiveLike(v) then
            return false
        -- Also makes it too easy for the Mad Scientist
        elseif v:GetRole() == ROLE_MADSCIENTIST then
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