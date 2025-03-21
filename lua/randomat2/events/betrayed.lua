local EVENT = {}

EVENT.Title = "Betrayed"
EVENT.Description = "Randomly converts one vanilla traitor to be a glitch"
EVENT.id = "betrayed"
EVENT.StartSecret = true
EVENT.Categories = {"rolechange", "moderateimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = "Randomly converts one vanilla " .. Randomat:GetRoleString(ROLE_TRAITOR):lower() .. " to be " .. Randomat:GetRoleExtendedString(ROLE_GLITCH):lower()
end

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers(true)) do
        if v:GetRole() == ROLE_TRAITOR then
            Randomat:SetRole(v, ROLE_GLITCH)
            timer.Create("RdmtBetrayedNotify", 3, 1, function()
                Randomat:PrintMessage(v, MSG_PRINTBOTH, "Your conscience has gotten the better of you and you've betrayed your former team!")
            end)
            SendFullStateUpdate()
            return
        end
    end
end

function EVENT:End()
    timer.Remove("RdmtBetrayedNotify")
end

function EVENT:Condition()
    -- Don't allow this if there is no Glitch enabled
    if not Randomat:CanRoleSpawn(ROLE_GLITCH) then
        return false
    end

    local tcount = 0
    local teamcount = 0
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsTraitorTeam(v) then
            teamcount = teamcount + 1
            if v:GetRole() == ROLE_TRAITOR then
                tcount = tcount + 1
            end
        end
    end

    -- Only run this if the traitor team has more than 2 players and at least one of them is a vanilla traitor
    return teamcount > 2 and tcount > 0
end

Randomat:register(EVENT)