local EVENT = {}

util.AddNetworkString("RdmtCorpseHighlightStart")
util.AddNetworkString("RdmtCorpseHighlightEnd")

EVENT.Title = "No one can die from my sight"
EVENT.Description = "Puts a green outline around every dead player"
EVENT.id = "corpsehighlight"
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

function EVENT:Begin()
    net.Start("RdmtCorpseHighlightStart")
    net.Broadcast()

    -- Bypass culling so you can always see bodies through walls
    self:AddEntityCullingBypass(nil, nil, "prop_ragdoll")
end

function EVENT:End()
    net.Start("RdmtCorpseHighlightEnd")
    net.Broadcast()
end

Randomat:register(EVENT)