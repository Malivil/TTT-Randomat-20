local EVENT = {}

util.AddNetworkString("RdmtKillJesterBegin")
util.AddNetworkString("RdmtKillJesterEnd")

EVENT.Title = "Fiends for Life"
EVENT.Description = "Innocents win if they kill the jester, but traitors want them alive"
EVENT.id = "killjester"
EVENT.Categories = {"largeimpact"}

local origPlayerDeath

function EVENT:BeforeEventTrigger(ply, options, ...)
    -- Update this in case the role names have been changed
    self.Description = Randomat:GetRolePluralString(ROLE_INNOCENT) .. " win if they kill the " .. Randomat:GetRoleString(ROLE_JESTER):lower() .. ", but " .. Randomat:GetRolePluralString(ROLE_TRAITOR):lower() .. " want them alive"
end

function EVENT:Begin()
    net.Start("RdmtKillJesterBegin")
    net.Broadcast()

    -- Save the original hook and remove it
    if not origPlayerDeath then
        origPlayerDeath = hook.GetTable()["PlayerDeath"]["Jester_WinCheck_PlayerDeath"]
        hook.Remove("PlayerDeath", "Jester_WinCheck_PlayerDeath")
    end

    self:AddHook("TTTCheckForWin", function()
        -- If the jester is dead, the innocents win
        for _, p in ipairs(self:GetDeadPlayers()) do
            if p:GetRole() == ROLE_JESTER then
                return WIN_INNOCENT
            end
        end
    end)
end

function EVENT:End()
    net.Start("RdmtKillJesterEnd")
    net.Broadcast()

    -- Restore the original hook
    if origPlayerDeath then
        hook.Add("PlayerDeath", "Jester_WinCheck_PlayerDeath", origPlayerDeath)
        origPlayerDeath = nil
    end
end

function EVENT:Condition()
    -- The "TTTScoringWinTitle" hook is only available in the new CR
    if not CR_VERSION then return false end

    for _, p in ipairs(self:GetAlivePlayers()) do
        if p:GetRole() == ROLE_JESTER then
            return true
        end
    end

    return false
end

Randomat:register(EVENT)