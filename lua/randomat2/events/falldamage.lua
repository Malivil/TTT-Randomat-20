local EVENT = {}

EVENT.Title = "No more Fall Damage!"
EVENT.id = "falldamage"

function EVENT:Begin()
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if IsPlayer(ent) and dmginfo:IsFallDamage() then
            return true
        end
    end)
end

Randomat:register(EVENT)