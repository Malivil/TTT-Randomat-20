AddCSLuaFile()

EVENT = {}

util.AddNetworkString("OppositeDayBegin")
util.AddNetworkString("OppositeDayEnd")

EVENT.Title = "Opposite Day"
EVENT.id = "opposite"

function EVENT:Begin()
    for _, p in pairs(self:GetAlivePlayers()) do
        net.Start("OppositeDayBegin")
        net.Send(p)
    end
end

function EVENT:End()
    net.Start("OppositeDayEnd")
    net.Broadcast()
end

Randomat:register(EVENT)