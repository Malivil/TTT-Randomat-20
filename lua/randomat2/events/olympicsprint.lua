local EVENT = {}

util.AddNetworkString("RdmtOlympicSprintBegin")
util.AddNetworkString("RdmtOlympicSprintEnd")

EVENT.Title = "Olympic Sprint"
EVENT.AltTitle = "Infinite Sprint"
EVENT.Description = "Disables sprint stamina consumption, allowing players to sprint forever"
EVENT.id = "olympicsprint"
EVENT.Categories = {"fun", "smallimpact"}

function EVENT:Begin()
    net.Start("RdmtOlympicSprintBegin")
    net.Broadcast()
end

function EVENT:End()
    net.Start("RdmtOlympicSprintEnd")
    net.Broadcast()
end

function EVENT:Condition()
    -- Check that this variable exists by double negating
    -- We can't just return the variable directly because it's not a boolean
    -- The "TTTSprintStaminaPost" hook is only available in the new CR
    return not not CR_VERSION
end

Randomat:register(EVENT)