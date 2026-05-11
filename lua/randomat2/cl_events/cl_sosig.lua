local EVENT = {}
EVENT.id = "sosig"

local sosig_sound = "weapons/sosig.mp3"
local function UpdateWeaponSounds()
    for _, wep in ipairs(Randomat.Client:GetWeapons()) do
        Randomat:OverrideWeaponSound(wep, sosig_sound)
    end
end

function EVENT:Begin()
    self:AddHook("EntityEmitSound", function(data)
        return Randomat:OverrideWeaponSoundData(data, sosig_sound)
    end)

    UpdateWeaponSounds()
end

function EVENT:End()
    -- If we don't have a client it's because we're not loaded yet
    -- This can happen because the Randomat "ends" all events during the Prep phase so if
    -- a player is still loading at that point then `LocalPlayer` would return a NULL Entity
    if not Randomat.Client or not IsPlayer(Randomat.Client) or not Randomat.Client.GetWeapons then return end

    for _, wep in ipairs(Randomat.Client:GetWeapons()) do
        Randomat:RestoreWeaponSound(wep)
    end
end

Randomat:register(EVENT)

net.Receive("RdmtSosigUpdateWeaponSounds", UpdateWeaponSounds)