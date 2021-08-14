local EVENT = {}

EVENT.Title = "Detraitor"
EVENT.Description = "The Detective has been corrupted and joined the Traitor team!"
EVENT.id = "detraitor"
EVENT.StartSecret = true

function EVENT:Begin()
    -- Update this in case the role names have been changed
    EVENT.Description = "The " .. Randomat:GetRoleString(ROLE_DETECTIVE) .. " has been corrupted and joined the " .. Randomat:GetRoleString(ROLE_TRAITOR) .. " team!"

    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(v) then
            if ROLE_IMPERSONATOR ~= -1 then
                Randomat:SetRole(v, ROLE_IMPERSONATOR)
                v:SetNWBool("HasPromotion", true)
            else
                Randomat:SetRole(v, ROLE_DETRAITOR)
            end
            timer.Create("RdmtDetraitorNotify", 5, 1, function()
                v:PrintMessage(HUD_PRINTTALK, "You have been corrupted and joined the " .. Randomat:GetRoleString(ROLE_TRAITOR) .. " Team! Only your new allies can tell the difference.")
                v:PrintMessage(HUD_PRINTCENTER, "You have been corrupted and joined the " .. Randomat:GetRoleString(ROLE_TRAITOR) .. " Team! Only your new allies can tell the difference.")
            end)
            SendFullStateUpdate()
            return
        end
    end
end

function EVENT:End()
    timer.Remove("RdmtDetraitorNotify")
end

function EVENT:Condition()
    -- Make sure the Impersonator or Detraitor exists
    local evil_exists = (ROLE_IMPERSONATOR ~= -1 and GetConVar("ttt_impersonator_enabled"):GetBool()) or
                            (ROLE_DETRAITOR ~= -1 and GetConVar("ttt_detraitor_enabled"):GetBool())
    if not evil_exists then
        return false
    end

    -- Only run if there is at least one good detective-like player living
    for _, v in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(v) then
            return true
        end
    end

    return false
end

Randomat:register(EVENT)