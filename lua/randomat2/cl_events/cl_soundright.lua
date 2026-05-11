local EVENT = {}
EVENT.id = "soundright"

local wep_sounds = {}
function EVENT:Begin()
    self:AddHook("EntityEmitSound", function(data)
        if not IsPlayer(data.Entity) or not data.Entity.GetActiveWeapon then return end
        local wep = data.Entity:GetActiveWeapon()
        if not IsValid(wep) then return end

        local wep_class = WEPS.GetClass(wep)
        if not wep_sounds[wep_class] then
            return
        end

        local chosen_sound = wep_sounds[wep_class]
        return Randomat:OverrideWeaponSoundData(data, chosen_sound)
    end)
end

function EVENT:End()
    table.Empty(wep_sounds)

    -- If we don't have a client it's because we're not loaded yet
    -- This can happen because the Randomat "ends" all events during the Prep phase so if
    -- a player is still loading at that point then `LocalPlayer` would return a NULL Entity
    if not Randomat.Client or not IsPlayer(Randomat.Client) or not Randomat.Client.GetWeapons then return end

    for _, wep in ipairs(Randomat.Client:GetWeapons()) do
        Randomat:RestoreWeaponSound(wep)
    end
end

Randomat:register(EVENT)

net.Receive("RdmtSoundRightUpdate", function()
    local wep_class = net.ReadString()
    local chosen_sound = net.ReadString()
    wep_sounds[wep_class] = chosen_sound

    for _, wep in ipairs(Randomat.Client:GetWeapons()) do
        if WEPS.GetClass(wep) == wep_class then
            Randomat:OverrideWeaponSound(wep, chosen_sound)
            return
        end
    end
end)