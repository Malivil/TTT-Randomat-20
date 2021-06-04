local EVENT = {}

EVENT.Title = "##BringBackOldJester"
EVENT.Description = "Converts the Swapper to a Jester"
EVENT.id = "oldjester"

function EVENT:Begin()
    for _, j in ipairs(self:GetAlivePlayers()) do
        if j:GetRole() == ROLE_SWAPPER then
            Randomat:SetRole(j, ROLE_JESTER)

            for _, t in ipairs(self:GetAlivePlayers()) do
                if t:GetRole() == ROLE_TRAITOR then
                    t:PrintMessage(HUD_PRINTTALK, j:Nick().." is the Jester")
                end
            end
        end
    end

    SendFullStateUpdate()
end

function EVENT:End()
end

function EVENT:Condition()
    for _, v in ipairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_SWAPPER then
            return true
        end
    end

    return false
end

Randomat:register(EVENT)