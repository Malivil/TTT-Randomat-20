local sosig_sound = "weapons/sosig.mp3"
local hooked = false

net.Receive("TriggerSosig", function()
    -- This event can be called multiple times but we only want to add the hook once
    if not hooked then
        hook.Add("EntityEmitSound", "SosigOverrideHook", function(data)
            return Randomat:OverrideWeaponSoundData(data, sosig_sound)
        end)
        hooked = true
    end

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        Randomat:OverrideWeaponSound(wep, sosig_sound)
    end
end)

net.Receive("EndSosig", function()
    hook.Remove("EntityEmitSound", "SosigOverrideHook")
    hooked = false

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        Randomat:RestoreWeaponSound(wep)
    end
end)