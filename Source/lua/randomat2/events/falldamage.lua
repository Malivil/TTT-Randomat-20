local EVENT = {}

EVENT.Title = "No more Falldamage!"
EVENT.id = "falldamage"
--EVENT.Time = 120

function EVENT:Begin(notify)
    self:AddHook("EntityTakeDamage", function(ent, dmginfo)
        if IsValid(ent) and ent:IsPlayer() and dmginfo:IsFallDamage() then
            return true
        end
    end)
end

Randomat:register(EVENT)