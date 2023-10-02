local EVENT = {}

EVENT.Title = "Good Cop, Bad Cop"
EVENT.Description = "Instead of a detective, you now have two deputies... or is one an impersonator?"
EVENT.id = "goodcopbadcop"
EVENT.Categories = {"rolechange", "biased_traitor", "biased", "moderateimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = "Instead of " .. Randomat:GetRoleExtendedString(ROLE_DETECTIVE):lower() .. " , you now have two " .. Randomat:GetRolePluralString(ROLE_DEPUTY):lower() .. "... or is one " .. Randomat:GetRoleExtendedString(ROLE_IMPERSONATOR):lower() .. "?"
end

function EVENT:Begin()
    local detective = nil
    local traitor = nil
    local players = self:GetAlivePlayers(true)
    -- Find a random "detective" and "traitor" player
    -- Also set a random innocent player as the fallback "detective"
    -- and any random player as the fallback "traitor"
    for _, p in ipairs(players) do
        if Randomat:IsDetectiveTeam(p) then
            detective = p
        elseif p:GetRole() == ROLE_TRAITOR then
            traitor = p
        elseif not IsPlayer(detective) and Randomat:IsInnocentTeam(p) then
            detective = p
        elseif not IsPlayer(traitor) then
            traitor = p
        end
    end

    -- Make sure a detective was chosen and make sure it's not the same person twice
    if not IsPlayer(detective) or detective == traitor then
        detective = players[1]
        if detective == traitor then
            detective = players[2]
        end
    end

    -- Update each player, give them credits, and promote them
    Randomat:SetRole(detective, ROLE_DEPUTY)
    detective:SetDefaultCredits()
    detective:HandleDetectiveLikePromotion()

    local new_role = math.random(0, 1) == 1 and ROLE_DEPUTY or ROLE_IMPERSONATOR
    Randomat:SetRole(traitor, new_role)
    traitor:SetDefaultCredits()
    traitor:HandleDetectiveLikePromotion()

    SendFullStateUpdate()

    -- Let the players know they've changed
    timer.Simple(0.25, function()
        detective:PrintMessage(HUD_PRINTCENTER, "You have been changed to be " .. Randomat:GetRoleExtendedString(ROLE_DEPUTY):lower())
        detective:PrintMessage(HUD_PRINTTALK, "You have been changed to be " .. Randomat:GetRoleExtendedString(ROLE_DEPUTY):lower())

        traitor:PrintMessage(HUD_PRINTCENTER, "You have been changed to be " .. Randomat:GetRoleExtendedString(new_role):lower())
        traitor:PrintMessage(HUD_PRINTTALK, "You have been changed to be " .. Randomat:GetRoleExtendedString(new_role):lower())
    end)
end

function EVENT:Condition()
    local deputy_enabled = ConVarExists("ttt_deputy_enabled") and GetConVar("ttt_deputy_enabled"):GetBool()
    local impersonator_enabled = ConVarExists("ttt_impersonator_enabled") and GetConVar("ttt_impersonator_enabled"):GetBool()

    -- If one of the roles isn't enabled, don't allow this event
    if not deputy_enabled or not impersonator_enabled then
        return false
    end

    -- Don't do this if we already have a deputy or impersonator or there aren't enough innocents (specifically detectives) and traitors alive
    local innocent_count = 0
    local traitor_count = 0
    for _, p in ipairs(self:GetAlivePlayers()) do
        local role = p:GetRole()
        if role == ROLE_DEPUTY or role == ROLE_IMPERSONATOR then
            return false
        end

        if Randomat:IsDetectiveTeam(p) then
            innocent_count = innocent_count + 1
        elseif Randomat:IsTraitorTeam(p) then
            traitor_count = traitor_count + 1
        end
    end

    return innocent_count > 1 and traitor_count > 1
end

Randomat:register(EVENT)