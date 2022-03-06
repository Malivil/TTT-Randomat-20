local EVENT = {}

EVENT.Title = "No one can hide from my sight"
EVENT.Description = "Puts a green outline around every player"
EVENT.id = "wallhack"
EVENT.Categories = {"biased", "largeimpact"}

util.AddNetworkString("haloeventtrigger")
util.AddNetworkString("haloeventend")

function EVENT:Begin()
    net.Start("haloeventtrigger")
    net.Broadcast()
end

function EVENT:End()
    net.Start("haloeventend")
    net.Broadcast()
end

Randomat:register(EVENT)