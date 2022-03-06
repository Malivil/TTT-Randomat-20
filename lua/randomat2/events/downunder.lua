local EVENT = {}

util.AddNetworkString("RdmtDownUnderBegin")
util.AddNetworkString("RdmtDownUnderEnd")

EVENT.Title = "Down Under"
EVENT.Description = "Flips your view upside-down"
EVENT.id = "downunder"
EVENT.Categories = {"largeimpact"}

function EVENT:Begin()
    net.Start("RdmtDownUnderBegin")
    net.Broadcast()

    -- Inverts sidewards movement to make this event easier to control
    self:AddHook("SetupMove", function(ply, mv, cmd)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        local sidespeed = mv:GetSideSpeed()
        mv:SetSideSpeed(-sidespeed)
    end)
end

function EVENT:End()
    net.Start("RdmtDownUnderEnd")
    net.Broadcast()
end

Randomat:register(EVENT)