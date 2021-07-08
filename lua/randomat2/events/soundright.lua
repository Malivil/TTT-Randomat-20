local EVENT = {}

EVENT.Title = "That Doesn't Sound Right"
EVENT.Description = "Shuffles weapon sounds"
EVENT.id = "soundright"
EVENT.SingleUse = true

util.AddNetworkString("RdmtSoundRightBegin")
util.AddNetworkString("RdmtSoundRightUpdate")
util.AddNetworkString("RdmtSoundRightEnd")

local wep_sounds = {}
local function GetRandomWeaponSound(wep, sounds)
    local wep_class = WEPS.GetClass(wep)
    if not wep_sounds[wep_class] then
        local chosen_sound = nil
        -- Choose a random (but valid) sound
        repeat
            local idx = math.random(1, #sounds)
            chosen_sound = sounds[idx]
        until chosen_sound and string.len(chosen_sound) > 0

        -- If this is a sound script, extract the file out of it.
        -- Some weapons have to be overwritten by the EntityEmitSound hook and that can't use scripts
        local properties = sound.GetProperties(chosen_sound)
        if properties then
            local sound_property = properties.sound
            -- Choose a random sound from the options
            if type(sound_property) == "table" then
                sound_property = sound_property[math.random(1, #sound_property)]
            end
            chosen_sound = sound_property
        end

        wep_sounds[wep_class] = chosen_sound
    end
    return wep_sounds[wep_class]
end

local function SetRandomWeaponSound(ply, wep, sounds)
    local chosen_sound = GetRandomWeaponSound(wep, sounds)
    Randomat:OverrideWeaponSound(wep, chosen_sound)

    net.Start("RdmtSoundRightUpdate")
    net.WriteString(WEPS.GetClass(wep))
    net.WriteString(chosen_sound)
    net.Send(ply)
end

function EVENT:Begin()
    local sounds = {}
    for _, v in pairs(weapons.GetList()) do
        if v and v.Primary.Sound then
            table.insert(sounds, v.Primary.Sound)
        end
    end

    for _, ply in ipairs(player.GetAll()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            SetRandomWeaponSound(ply, wep, sounds)
        end
    end

    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("SoundRightDelay", 0.1, 1, function()
            SetRandomWeaponSound(ply, wep, sounds)
        end)
    end)

    self:AddHook("EntityEmitSound", function(data)
        if not IsValid(data.Entity) or not data.Entity:IsPlayer() or not data.Entity.GetActiveWeapon then return end
        local wep = data.Entity:GetActiveWeapon()
        if not IsValid(wep) then return end

        local chosen_sound = GetRandomWeaponSound(wep, sounds)
        return Randomat:OverrideWeaponSoundData(data, chosen_sound)
    end)

    net.Start("RdmtSoundRightBegin")
    net.Broadcast()
end

function EVENT:End()
    net.Start("RdmtSoundRightEnd")
    net.Broadcast()
    timer.Remove("SoundRightDelay")
    for _, ply in ipairs(player.GetAll()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            Randomat:RestoreWeaponSound(wep)
        end
    end
end

Randomat:register(EVENT)