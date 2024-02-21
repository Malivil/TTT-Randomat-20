local EVENT = {}

EVENT.Title = "We All Float Down Here"
EVENT.AltTitle = "Clownin' Around"
EVENT.Description = "Converts a Jester/Swapper to a Clown"
EVENT.id = "clowninaround"
EVENT.StartSecret = true
EVENT.Categories = {"rolechange", "smallimpact"}

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = "Converts a " .. Randomat:GetRoleString(ROLE_JESTER) .. "/" .. Randomat:GetRoleString(ROLE_SWAPPER) .. " to a " .. Randomat:GetRoleString(ROLE_CLOWN)
end

function EVENT:Begin()
    for _, v in ipairs(self:GetAlivePlayers(true)) do
        if v:GetRole() == ROLE_JESTER or v:GetRole() == ROLE_SWAPPER then
            Randomat:SetRole(v, ROLE_CLOWN)
            timer.Create("RdmtClowninAroundNotify", 5, 1, function()
                Randomat:PrintMessage(v, MSG_PRINTBOTH, "You've been inspired by the story of Pennywise the Clown. Prepare for your ramapge...")
            end)
            SendFullStateUpdate()
            return
        end
    end
end

function EVENT:End()
    timer.Remove("RdmtClowninAroundNotify")
end

function EVENT:Condition()
    -- Don't allow this if there is no Clown enabled
    if not Randomat:CanRoleSpawn(ROLE_CLOWN) then
        return false
    end

    -- Only run if there is at least one Jester living
    for _, v in ipairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_JESTER or v:GetRole() == ROLE_SWAPPER then
            return true
        end
    end

    return false
end

Randomat:register(EVENT)