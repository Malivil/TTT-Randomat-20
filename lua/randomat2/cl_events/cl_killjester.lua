net.Receive("RdmtKillJesterBegin", function()
    hook.Add("TTTScoringWinTitle", "RdmtKillJesterWinScoring", function(wintype, wintitle, title)
        local jester_alive = false
        for _, p in ipairs(player.GetAll()) do
            if p:Alive() and not p:IsSpec() and p:GetRole() == ROLE_JESTER then
                jester_alive = true
                break
            end
        end

        if jester_alive then
            return title, ROLE_JESTER
        end
    end)
end)

net.Receive("RdmtKillJesterEnd", function()
    hook.Remove("TTTScoringWinTitle", "RdmtKillJesterWinScoring")
end)