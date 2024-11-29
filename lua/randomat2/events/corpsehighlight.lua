local EVENT = {}

EVENT.Title = "No one can die from my sight"
EVENT.Description = "Puts a green outline around every dead player"
EVENT.id = "corpsehighlight"
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

function EVENT:Begin()
    -- Bypass culling so you can always see bodies through walls
    self:AddEntityCullingBypass(nil, nil, "prop_ragdoll")
end

Randomat:register(EVENT)