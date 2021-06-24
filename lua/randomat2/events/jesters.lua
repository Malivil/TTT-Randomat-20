local EVENT = {}

EVENT.Title = "One traitor, One Detective. Everyone else is a Jester. Detective is stronger."
EVENT.id = "jesters"

function EVENT:Begin()
    local tx = 0
    local dx = 0
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        if (ply:GetRole() == ROLE_TRAITOR and tx == 0) or (Randomat:IsGoodDetectiveLike(ply) and dx == 0) then
            if Randomat:IsGoodDetectiveLike(ply) then
                dx = 1
                ply:SetHealth(200)
                ply:SetMaxHealth(200)
            else
                tx = 1
                ply:SetMaxHealth(100)
            end
        else
            ply:SetCredits(0)
            ply:SetMaxHealth(100)
            -- Heal the Old Man back to full when they are converted
            if ply:GetRole() == ROLE_OLDMAN then
                ply:SetHealth(100)
            end
            Randomat:SetRole(ply, ROLE_JESTER)
            for _, wep in ipairs(ply:GetWeapons()) do
                if wep.Kind == WEAPON_EQUIP1 or wep.Kind == WEAPON_EQUIP2 then
                    ply:StripWeapon(wep:GetClass())
                end
            end

            self:StripRoleWeapons(ply)
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    -- Don't run this event if this ConVar doesn't exist
    -- It indicates that the version of Custom Roles being run doesn't support multiple Jesters
    if not ConVarExists("ttt_jester_win_by_traitors") then
        return false
    end

    -- Don't run this event if Jesters don't win when they are killed by traitors
    if not GetConVar("ttt_jester_win_by_traitors"):GetBool() then
        return false
    end

    local has_detective = false
    local has_traitor = false
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(v) then
            has_detective = true
        elseif v:GetRole() == ROLE_TRAITOR then
            has_traitor = true
        end
    end
    return has_traitor and has_detective
end

Randomat:register(EVENT)