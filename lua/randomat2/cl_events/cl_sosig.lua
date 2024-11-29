local EVENT = {}
EVENT.id = "sosig"

local sosig_sound = "weapons/sosig.mp3"
local function UpdateWeaponSounds()
    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        Randomat:OverrideWeaponSound(wep, sosig_sound)
    end
end

function EVENT:Begin()
    hook.Add("EntityEmitSound", "SosigOverrideHook", function(data)
        return Randomat:OverrideWeaponSoundData(data, sosig_sound)
    end)

    UpdateWeaponSounds()
end

function EVENT:End()
    hook.Remove("EntityEmitSound", "SosigOverrideHook")

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        Randomat:RestoreWeaponSound(wep)
    end
end

Randomat:register(EVENT)

net.Receive("RdmtSosigUpdateWeaponSounds", UpdateWeaponSounds)