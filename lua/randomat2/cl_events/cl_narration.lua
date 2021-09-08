local hooked = false
local reload_sounds = {"weapons/reload/reload1.wav", "weapons/reload/reload2.wav"}
local death_sounds = {"blerg/blerg1.wav", "blerg/blerg2.wav", "blerg/blerg3.wav", "blerg/blerg4.wav", "blerg/blerg5.wav", "blerg/blerg6.wav", "blerg/blerg7.wav", "blerg/blerg8.wav", "blerg/blerg9.wav", "blerg/blerg10.wav"}
local gunshot_sounds = {"weapons/gunshot/gunshot1.wav"}
local sound_mapping = {
    -- Footsteps
    [".*player/footsteps/.*%..*"] = {"footsteps/footsteps1.wav", "footsteps/footsteps2.wav"},
    -- Explosions
    [".*weapons/.*explode.*%..*"] = {"explosion/explosion1.wav", "explosion/explosion2.wav", "explosion/explosion3.wav"},
    -- C4 Beeps
    [".*weapons/.*beep.*%..*"] = {"beeping/beeping1.wav", "beeping/beeping2.wav"},
    -- Glass breaking
    [".*physics/glass/.*break.*%..*"] = {"smashing_glass/smashing_glass1.wav", "smashing_glass/smashing_glass2.wav"},
    -- Fall damage
    [".*player/damage*.%.wav"] = {"bones_cracking/bones_cracking1.wav"},
    -- Player death
    [".*player/death.*%.wav"] = death_sounds,
    [".*vo/npc/male01/pain*.%.wav"] = death_sounds,
    [".*vo/npc/barney/ba_pain*.%.wav"] = death_sounds,
    [".*vo/npc/barney/ba_ohshit03%.wav"] = death_sounds,
    [".*vo/npc/barney/ba_no01%.wav"] = death_sounds,
    [".*vo/npc/male01/no02%.wav"] = death_sounds,
    [".*hostage/hpain/hpain.*%.wav"] = death_sounds,
    -- Reload
    [".*weapons/.*out%..*"] = reload_sounds,
    [".*weapons/.*in%..*"] = reload_sounds,
    [".*weapons/.*reload.*%..*"] = reload_sounds,
    [".*weapons/.*boltcatch.*%..*"] = reload_sounds,
    [".*weapons/.*insertshell.*%..*"] = reload_sounds,
    [".*weapons/.*selectorswitch.*%..*"] = reload_sounds,
    [".*weapons/.*rattle.*%..*"] = reload_sounds,
    [".*weapons/.*lidopen.*%..*"] = reload_sounds,
    [".*weapons/.*fetchmag.*%..*"] = reload_sounds,
    [".*weapons/.*beltjingle.*%..*"] = reload_sounds,
    [".*weapons/.*beltalign.*%..*"] = reload_sounds,
    [".*weapons/.*lidclose.*%..*"] = reload_sounds,
    [".*weapons/.*magslap.*%..*"] = reload_sounds
}
net.Receive("TriggerNarration", function()
    -- This event can be called multiple times but we only want to add the hook once
    if not hooked then
        hook.Add("EntityEmitSound", "NarrationOverrideHook", function(data)
            local current_sound = data.SoundName:lower()
            local new_sound = nil
            for pattern, sounds in pairs(sound_mapping) do
                if string.find(current_sound, pattern) then
                    new_sound = sounds[math.random(1, #sounds)]
                end
            end

            if new_sound then
                data.SoundName = new_sound
                return true
            else
                local chosen_sound = gunshot_sounds[math.random(1, #gunshot_sounds)]
                return Randomat:OverrideWeaponSoundData(data, chosen_sound)
            end
        end)
        hooked = true
    end

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        local chosen_sound = gunshot_sounds[math.random(1, #gunshot_sounds)]
        Randomat:OverrideWeaponSound(wep, chosen_sound)
    end
end)

net.Receive("EndNarration", function()
    hook.Remove("EntityEmitSound", "NarrationOverrideHook")
    hooked = false

    local client = LocalPlayer()
    if not IsValid(client) then return end

    for _, wep in ipairs(client:GetWeapons()) do
        Randomat:RestoreWeaponSound(wep)
    end
end)