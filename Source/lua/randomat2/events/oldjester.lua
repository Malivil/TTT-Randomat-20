local EVENT = {}

EVENT.Title = "##BringBackOldJester"
EVENT.id = "oldjester"

function EVENT:Begin()
    for _, j in pairs(self:GetAlivePlayers(true)) do
        if j:GetRole() == ROLE_SWAPPER then
            Randomat:SetRole(j, ROLE_JESTER)

            for _, t in pairs(self:GetAlivePlayers(true)) do
                if t:GetRole() == ROLE_TRAITOR then
                    t:PrintMessage(HUD_PRINTTALK, j:Nick().." is the jester")
                end
            end
        end
    end

    SendFullStateUpdate()
end

function EVENT:End()
end

function EVENT:Condition()
    for _, v in pairs(player.GetAll()) do
        if v:GetRole() == ROLE_SWAPPER and v:Alive() and not v:IsSpec() then
            return true
        end
    end

    return false
end

Randomat:register(EVENT)