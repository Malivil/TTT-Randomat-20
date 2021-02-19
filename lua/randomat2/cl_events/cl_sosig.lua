
local sosig_sound = "weapons/sosig.mp3"

net.Receive("TriggerSosig", function()
    for _, wep in pairs(LocalPlayer():GetWeapons()) do
        wep.Primary.OriginalSound = wep.Primary.Sound
        wep.Primary.Sound = sosig_sound
    end

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
end)

net.Receive("EndSosig", function()
    for _, wep in pairs(LocalPlayer():GetWeapons()) do
        wep.Primary.Sound = wep.Primary.OriginalSound
    end
    hook.Remove("EntityEmitSound", "SosigOverrideHook")
end)