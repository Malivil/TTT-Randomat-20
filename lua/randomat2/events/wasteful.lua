local EVENT = {}

EVENT.Title = "Wasteful!"
EVENT.Description = "Every gun shot uses two bullets"
EVENT.id = "wasteful"
-- Mark this as a weapon override type because the weapons used in weapon override types don't have ammo
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

function EVENT:Begin()
    self:AddHook("EntityFireBullets", function(ent, data)
        if not IsValid(ent) or not ent:IsPlayer() then return end

        local wep = ent:GetActiveWeapon()
        if not IsValid(wep) or not wep.Primary or wep.Primary.ClipSize <= 0 then return end

        local ammo = wep:Clip1()
        if ammo <= 0 then return end

        wep:SetClip1(math.max(0, ammo - 1))
    end)
end

Randomat:register(EVENT)