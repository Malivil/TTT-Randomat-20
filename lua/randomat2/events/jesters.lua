local EVENT = {}

EVENT.Title = "One traitor, One Detective. Everyone else is a Jester. Detective is stronger."
EVENT.id = "jesters"

function EVENT:Begin()
    local tx = 0
    local dx = 0
    for _, ply in pairs(self:GetAlivePlayers(true)) do
        if (ply:GetRole() == ROLE_TRAITOR and tx == 0) or (ply:GetRole() == ROLE_DETECTIVE and dx == 0) then
            if ply:GetRole() ~= ROLE_DETECTIVE then
                tx = 1
                ply:SetMaxHealth(100)
            else
                dx = 1
                ply:SetHealth(200)
                ply:SetMaxHealth(200)
            end
        else
            Randomat:SetRole(ply, ROLE_JESTER)
            ply:SetCredits(0)
            ply:SetMaxHealth(100)
            for _, wep in pairs(ply:GetWeapons()) do
                if wep.Kind == WEAPON_EQUIP1 or wep.Kind == WEAPON_EQUIP2 then
                    ply:StripWeapon(wep:GetClass())
                end
            end
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    -- Don't run this event if Jesters don't win when they are killed by traitors
    if ConVarExists("ttt_jester_win_by_traitors") and not GetConVar("ttt_jester_win_by_traitors"):GetBool() then
        return false
    end

    local has_detective = false
    local has_traitor = false
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_DETECTIVE then
            has_detective = true
        elseif v:GetRole() == ROLE_TRAITOR then
            has_traitor = true
        end
    end
    return has_traitor and has_detective
end

Randomat:register(EVENT)