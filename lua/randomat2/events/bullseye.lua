local EVENT = {}

EVENT.Title = "Bullseye"
EVENT.Description = "Only headshots do damage"
EVENT.id = "bullseye"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

function EVENT:Begin()
    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        -- If the player doens't have a head hitbox then they take damage as normal
        local box = ply:GetHitBoxBone(HITGROUP_HEAD, 0)
        if box and hitgroup ~= HITGROUP_HEAD then
            dmginfo:ScaleDamage(0)
        end
    end)
end

Randomat:register(EVENT)