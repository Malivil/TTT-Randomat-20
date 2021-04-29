local EVENT = {}

util.AddNetworkString("OppositeDayBegin")
util.AddNetworkString("OppositeDayEnd")

EVENT.Title = "Opposite Day"
EVENT.Description = "Swaps movement keys to their opposites (e.g. Left is Right, Forward is Backward) and swaps the Fire and Reload keys"
EVENT.id = "opposite"

function EVENT:Begin()
    for _, p in pairs(self:GetAlivePlayers()) do
        p:SetLadderClimbSpeed(-200)
        net.Start("OppositeDayBegin")
        net.Send(p)
    end

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        victim:SetLadderClimbSpeed(200)
        net.Start("OppositeDayEnd")
        net.Send(victim)
    end)

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        ply:SetLadderClimbSpeed(-200)
        net.Start("OppositeDayBegin")
        net.Send(ply)
    end)
end

function EVENT:End()
    for _, p in pairs(self:GetAlivePlayers()) do
        p:SetLadderClimbSpeed(200)
    end
    net.Start("OppositeDayEnd")
    net.Broadcast()
end

Randomat:register(EVENT)