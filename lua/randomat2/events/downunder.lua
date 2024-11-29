local EVENT = {}

EVENT.Title = "Down Under"
EVENT.Description = "Flips your view upside-down"
EVENT.id = "downunder"
EVENT.Categories = {"largeimpact"}

function EVENT:Begin()
    -- Inverts sidewards movement to make this event easier to control
    self:AddHook("SetupMove", function(ply, mv, cmd)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end

        local sidespeed = mv:GetSideSpeed()
        mv:SetSideSpeed(-sidespeed)
    end)
end

Randomat:register(EVENT)