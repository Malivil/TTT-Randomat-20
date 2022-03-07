local EVENT = {}

EVENT.Title = "Bullseye"
EVENT.Description = "Only headshots do damage"
EVENT.id = "bullseye"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

function EVENT:Begin()
    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmginfo)
        -- Let the barnacle still do the damage or else people can just get stuck in there
        if IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "npc_barnacle" then return end

        -- If the player doesn't have a head hitbox then they take damage as normal
        local box = ply:GetHitBoxBone(HITGROUP_HEAD, 0)
        if box and hitgroup ~= HITGROUP_HEAD then
            dmginfo:ScaleDamage(0)
        end
    end)
end

Randomat:register(EVENT)