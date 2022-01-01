local EVENT = {}

util.AddNetworkString("RdmtDownUnderBegin")
util.AddNetworkString("RdmtDownUnderEnd")

EVENT.Title = "Down Under"
EVENT.Description = "Flips your view upside-down"
EVENT.id = "downunder"

function EVENT:Begin()
    net.Start("RdmtDownUnderBegin")
    net.Broadcast()

    -- Inverts sidewards movement to make this event easier to control
    self:AddHook("SetupMove", function(ply, mv, cmd)
        local sidespeed = mv:GetSideSpeed()
        mv:SetSideSpeed(-sidespeed)
    end)
end

function EVENT:End()
    net.Start("RdmtDownUnderEnd")
    net.Broadcast()
end

Randomat:register(EVENT)