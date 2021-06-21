
local sosig_sound = "weapons/sosig.mp3"
local hooked = false

local function FixWeapon(wep)
    if not IsValid(wep) or not wep.Primary then return end
    if wep.Primary.OriginalSound == nil then
        wep.Primary.OriginalSound = wep.Primary.Sound
    end
    wep.Primary.Sound = sosig_sound
end

local function UnfixWeapon(wep)
    if not IsValid(wep) or not wep.Primary then return end
    if wep.Primary.OriginalSound then
        wep.Primary.Sound = wep.Primary.OriginalSound
    end
end

net.Receive("TriggerSosig", function()
    -- This event can be called multiple times but we only want to add the hook once
    if not hooked then
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
    end

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        FixWeapon(wep)
    end
end)

net.Receive("EndSosig", function()
    hook.Remove("EntityEmitSound", "SosigOverrideHook")
    hooked = false

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        UnfixWeapon(wep)
    end
end)