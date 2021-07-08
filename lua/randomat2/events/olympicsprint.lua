local EVENT = {}

util.AddNetworkString("RdmtOlympicSprintBegin")
util.AddNetworkString("RdmtOlympicSprintEnd")

EVENT.Title = "Olympic Sprint"
EVENT.AltTitle = "Infinite Sprint"
EVENT.Description = "Disables sprint stamina consumption, allowing players to sprint forever"
EVENT.id = "olympicsprint"

function EVENT:Begin()
    net.Start("RdmtOlympicSprintBegin")
    net.Broadcast()
end

function EVENT:End()
    net.Start("RdmtOlympicSprintEnd")
    net.Broadcast()
end

function EVENT:Condition()
    return CR_VERSION and CRVersion("1.0.2")
end

Randomat:register(EVENT)