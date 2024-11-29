local EVENT = {}
EVENT.id = "killjester"

function EVENT:Begin()
    self:AddHook("TTTScoringSecondaryWins", function(wintype, secondary_wins)
        -- Jester can only share win with the traitors
        if wintype ~= WIN_TRAITOR then return end

        local jester_alive = false
        for _, p in player.Iterator() do
            if p:Alive() and not p:IsSpec() and p:GetRole() == ROLE_JESTER then
                jester_alive = true
                break
            end
        end

        -- If the jester is alive then they share the win with the traitors
        if jester_alive then
            table.insert(secondary_wins, ROLE_JESTER)
        end
    end)
end

Randomat:register(EVENT)