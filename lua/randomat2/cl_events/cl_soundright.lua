local EVENT = {}
EVENT.id = "soundright"

local wep_sounds = {}
function EVENT:Begin()
    hook.Add("EntityEmitSound", "SoundRightOverrideHook", function(data)
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
    hook.Remove("EntityEmitSound", "SoundRightOverrideHook")

    table.Empty(wep_sounds)
    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        Randomat:RestoreWeaponSound(wep)
    end
end

Randomat:register(EVENT)

net.Receive("RdmtSoundRightUpdate", function()
    local client = LocalPlayer()
    if not IsValid(client) then return end

    local wep_class = net.ReadString()
    local chosen_sound = net.ReadString()
    wep_sounds[wep_class] = chosen_sound

    for _, wep in ipairs(client:GetWeapons()) do
        if WEPS.GetClass(wep) == wep_class then
            Randomat:OverrideWeaponSound(wep, chosen_sound)
            return
        end
    end
end)