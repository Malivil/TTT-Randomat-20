local EVENT = {}

EVENT.Title = "##BringBackOldJester"
EVENT.Description = "Converts the swapper to a jester"
EVENT.id = "oldjester"
EVENT.Categories = {"rolechange", "smallimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description =  "Converts the " .. Randomat:GetRoleString(ROLE_SWAPPER):lower() .. " to " .. Randomat:GetRoleExtendedString(ROLE_JESTER):lower()
end

function EVENT:Begin()
    for _, j in ipairs(self:GetAlivePlayers()) do
        if j:GetRole() == ROLE_SWAPPER then
            Randomat:SetRole(j, ROLE_JESTER)

            for _, t in ipairs(self:GetAlivePlayers()) do
                if Randomat:IsTraitorTeam(t) then
                    t:PrintMessage(HUD_PRINTTALK, j:Nick() .. " is the " .. Randomat:GetRoleString(ROLE_JESTER):lower())
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