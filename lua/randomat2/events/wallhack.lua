local EVENT = {}

util.AddNetworkString("RdmtWallhackStart")
util.AddNetworkString("RdmtWallhackEnd")

EVENT.Title = "No one can hide from my sight"
EVENT.Description = "Puts a green outline around every player"
EVENT.id = "wallhack"
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

function EVENT:Begin()
    -- Bypass culling so you can always see everyone through walls
    self:AddCullingBypass()
end

Randomat:register(EVENT)