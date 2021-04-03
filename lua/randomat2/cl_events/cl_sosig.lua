
local sosig_sound = "weapons/sosig.mp3"
local hooked = false

local function FixWeapon(wep)
    if not IsValid(wep) or not wep.Primary then return end
    if wep.Primary.OriginalSound == nil then
        wep.Primary.OriginalSound = wep.Primary.Sound
    end
    wep.Primary.Sound = sosig_sound
end

net.Receive("TriggerSosig", function()
    for _, wep in pairs(LocalPlayer():GetWeapons()) do
        FixWeapon(wep)
    end

    -- This even can be called multiple times but we only want to add the hook once
    if hooked then return end

    hook.Add("EntityEmitSound", "SosigOverrideHook", function(data)
        local owner = data.Entity
        if not IsValid(owner) then return end
        local sound = data.SoundName:lower()
        local weap_start, _ = string.find(sound, "weapons/")
        local fire_start, _ = string.find(sound, "fire")
        local shot_start, _ = string.find(sound, "shot")
        if weap_start and (fire_start or shot_start) then
            data.SoundName = sosig_sound
            return true
        end
    end)
    hooked = true
end)

net.Receive("EndSosig", function()
    for _, wep in pairs(LocalPlayer():GetWeapons()) do
        if wep.Primary and wep.Primary.OriginalSound then
            wep.Primary.Sound = wep.Primary.OriginalSound
        end
    end
    hook.Remove("EntityEmitSound", "SosigOverrideHook")
    hooked = false
end)