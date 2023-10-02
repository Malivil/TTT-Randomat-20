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
                v:PrintMessage(HUD_PRINTTALK, "Your conscious has gotten the better of you and you've betrayed your former team!")
                v:PrintMessage(HUD_PRINTCENTER, "Your conscious has gotten the better of you and you've betrayed your former team!")
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
    if ROLE_GLITCH == -1 or not GetConVar("ttt_glitch_enabled"):GetBool() then
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