local EVENT = {}

util.AddNetworkString("RdmtKillJesterBegin")
util.AddNetworkString("RdmtKillJesterEnd")

EVENT.Title = "Fiends for Life"
EVENT.Description = "Innocents win if they kill the jester, but traitors want them alive"
EVENT.id = "killjester"
EVENT.Categories = {"biased", "largeimpact"}

function EVENT:Begin()
    -- Update this in case the role names have been changed
    EVENT.Description = Randomat:GetRolePluralString(ROLE_INNOCENT) .. " win if they kill the " .. Randomat:GetRoleString(ROLE_JESTER):lower() .. ", but " .. Randomat:GetRolePluralString(ROLE_TRAITOR):lower() .. " will share the win"

    net.Start("RdmtKillJesterBegin")
    net.Broadcast()

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
end

function EVENT:Condition()
    if not CR_VERSION then return false end

    for _, p in ipairs(self:GetAlivePlayers()) do
        if p:GetRole() == ROLE_JESTER then
            return true
        end
    end

    return false
end

Randomat:register(EVENT)