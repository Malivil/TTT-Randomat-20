local EVENT = {}

CreateConVar("randomat_soundright_blocklist", "weapon_pulserif,weapon_ttt_dislocator,tfa_jetgun", FCVAR_ARCHIVE, "The comma-separated list of weapon IDs to not use for sounds")

EVENT.Title = "That Doesn't Sound Right"
EVENT.Description = "Shuffles weapon sounds"
EVENT.id = "soundright"
EVENT.Type = EVENT_TYPE_GUNSOUNDS
EVENT.Categories = {"fun", "smallimpact"}

util.AddNetworkString("RdmtSoundRightUpdate")

local sounds = {}
local wep_sounds = {}
local function GetRandomWeaponSound(wep)
    local wep_class = WEPS.GetClass(wep)
    if not wep_sounds[wep_class] then
        local chosen_sound
        -- Choose a random (but valid) sound that is different than the one the weapon already has
        repeat
            local idx = math.random(#sounds)
            chosen_sound = sounds[idx]
        until chosen_sound and #chosen_sound > 0 and (not wep.Primary or wep.Primary.Sound ~= chosen_sound)

        -- If this is a sound script, extract the file out of it.
        -- Some weapons have to be overwritten by the EntityEmitSound hook and that can't use scripts
        local sound_props = sound.GetProperties(chosen_sound)
        if sound_props then
            local sound_property = sound_props.sound
            -- Choose a random sound from the options
            if type(sound_property) == "table" then
                sound_property = sound_property[math.random(#sound_property)]
            end
            chosen_sound = sound_property
        end

        wep_sounds[wep_class] = chosen_sound
    end
    return wep_sounds[wep_class]
end

local function SetRandomWeaponSound(ply, wep)
    local chosen_sound = GetRandomWeaponSound(wep)
    Randomat:OverrideWeaponSound(wep, chosen_sound)

    net.Start("RdmtSoundRightUpdate")
    net.WriteString(WEPS.GetClass(wep))
    net.WriteString(chosen_sound)
    net.Send(ply)
end

function EVENT:Begin()
    local blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_soundright_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    -- Add all non-blocked weapon sounds
    for _, v in pairs(weapons.GetList()) do
        if v and v.Primary and v.Primary.Sound and not table.HasValue(blocklist, v.ClassName) and not string.find(v.Primary.Sound, "base") then
            table.insert(sounds, v.Primary.Sound)
        end
    end

    for _, ply in player.Iterator() do
        for _, wep in ipairs(ply:GetWeapons()) do
            SetRandomWeaponSound(ply, wep)
        end
    end

    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("SoundRightDelay", 0.1, 1, function()
            SetRandomWeaponSound(ply, wep)
        end)
    end)

    self:AddHook("EntityEmitSound", function(data)
        if not IsPlayer(data.Entity) or not data.Entity.GetActiveWeapon then return end
        local wep = data.Entity:GetActiveWeapon()
        if not IsValid(wep) then return end

        local chosen_sound = GetRandomWeaponSound(wep)
        return Randomat:OverrideWeaponSoundData(data, chosen_sound)
    end)
end

function EVENT:End()
    table.Empty(sounds)
    table.Empty(wep_sounds)
    timer.Remove("SoundRightDelay")
    for _, ply in player.Iterator() do
        for _, wep in ipairs(ply:GetWeapons()) do
            Randomat:RestoreWeaponSound(wep)
        end
    end
end

Randomat:register(EVENT)