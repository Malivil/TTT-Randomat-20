local EVENT = {}

EVENT.Title = "Narration"
EVENT.Description = "Narrates common game activities"
EVENT.id = "narration"
EVENT.Type = EVENT_TYPE_GUNSOUNDS
EVENT.Categories = {"fun", "smallimpact"}

util.AddNetworkString("TriggerNarration")
util.AddNetworkString("EndNarration")

local StringFormat = string.format

-- Sound file paths
local beeping_sound_path = "beeping/beeping%s.mp3"
local blerg_sound_path = "blerg/blerg%s.mp3"
local bones_cracking_sound_path = "bones_cracking/bones_cracking%s.wav"
local door_opening_sound_path = "door_opening/door_opening%s.mp3"
local door_closing_sound_path = "door_closing/door_closing%s.mp3"
local explosion_sound_path = "explosion/explosion%s.mp3"
local footsteps_sound_path = "footsteps/footsteps%s.mp3"
local gunshot_sound_path = "weapons/gunshot/gunshot%s.mp3"
local jump_sound_path = "jump/jump%s.mp3"
local reload_sound_path = "weapons/reload/reload%s.mp3"
local smashing_glass_sound_path = "smashing_glass/smashing_glass%s.mp3"

-- Sound file counts
local beeping_sound_count = 7
local blerg_sound_count = 10
local bones_cracking_sound_count = 5
local door_opening_sound_count = 5
local door_closing_sound_count = 5
local explosion_sound_count = 9
local footsteps_sound_count = 9
local gunshot_sound_count = 8
local jump_sound_count = 5
local reload_sound_count = 8
local smashing_glass_sound_count = 8

-- Sound patterns and path-count mappings
local footsteps_pattern = ".*player/footsteps/.*%..*"
local reload_sounds = {reload_sound_path, reload_sound_count}
local death_sounds = {blerg_sound_path, blerg_sound_count}
local smashing_glass_sounds = {smashing_glass_sound_path, smashing_glass_sound_count}
local sound_mapping = {
    -- Footsteps
    [footsteps_pattern] = {footsteps_sound_path, footsteps_sound_count},
    -- Explosions
    [".*weapons/.*explode.*%..*"] = {explosion_sound_path, explosion_sound_count},
    -- C4 Beeps
    [".*weapons/.*beep.*%..*"] = {beeping_sound_path, beeping_sound_count},
    -- Glass breaking
    [".*physics/glass/.*break.*%..*"] = smashing_glass_sounds,
    [".*physics/glass/glass_impact_.*%..*"] = smashing_glass_sounds,
    -- Fall damage (which don't work when converted to MP3 for some reason)
    [".*player/damage*."] = {bones_cracking_sound_path, bones_cracking_sound_count},
    -- Player death
    [".*player/death.*"] = death_sounds,
    [".*vo/npc/male01/pain*."] = death_sounds,
    [".*vo/npc/barney/ba_pain*."] = death_sounds,
    [".*vo/npc/barney/ba_ohshit03.*"] = death_sounds,
    [".*vo/npc/barney/ba_no01.*"] = death_sounds,
    [".*vo/npc/male01/no02.*"] = death_sounds,
    [".*hostage/hpain/hpain.*"] = death_sounds,
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

local function DoorIsOpen(door)
    if not IsValid(door) then return false end

    local doorClass = door:GetClass()
    if doorClass == "func_door" or doorClass == "func_door_rotating" then
        return door:GetInternalVariable("m_toggle_state") == 0
    elseif doorClass == "prop_door_rotating" then
        return door:GetInternalVariable("m_eDoorState") ~= 0
    end
    return false
end

function EVENT:Begin()
    net.Start("TriggerNarration")
    net.Broadcast()
    for _, ply in ipairs(player.GetAll()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            local chosen_sound = StringFormat(gunshot_sound_path, math.random(1, gunshot_sound_count))
            Randomat:OverrideWeaponSound(wep, chosen_sound)
        end
    end

    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("NarrationDelay", 0.1, 1, function()
            net.Start("TriggerNarration")
            net.Send(ply)
            local chosen_sound = StringFormat(gunshot_sound_path, math.random(1, gunshot_sound_count))
            Randomat:OverrideWeaponSound(wep, chosen_sound)
        end)
    end)

    self:AddHook("EntityEmitSound", function(data)
        local current_sound = data.SoundName:lower()
        local new_sound = nil
        for pattern, sounds in pairs(sound_mapping) do
            if string.find(current_sound, pattern) then
                -- If this is a player "footstep"-ing in mid-air, they are jumping or using a ladder
                if footsteps_pattern == pattern and IsPlayer(data.Entity) and not data.Entity:IsOnGround() then
                    -- Don't replace the sound if the player is on a ladder
                    if data.Entity:GetMoveType() ~= MOVETYPE_LADDER then
                        new_sound = StringFormat(jump_sound_path, math.random(1, jump_sound_count))
                    end
                else
                    local sound_path = sounds[1]
                    local sound_index = math.random(1, sounds[2])
                    new_sound = StringFormat(sound_path, sound_index)
                end
                break
            end
        end

        if new_sound then
            data.SoundName = new_sound
            return true
        -- Door opening/closing
        elseif current_sound == "doors/default_move.wav" then
            if DoorIsOpen(data.Entity) then
                data.SoundName = StringFormat(door_closing_sound_path, math.random(1, door_closing_sound_count))
            else
                data.SoundName = StringFormat(door_opening_sound_path, math.random(1, door_opening_sound_count))
            end
            -- Increase the volume of these so they can be heard
            data.Volume = 2
            data.SoundLevel = 100
            return true
        else
            local chosen_sound = StringFormat(gunshot_sound_path, math.random(1, gunshot_sound_count))
            return Randomat:OverrideWeaponSoundData(data, chosen_sound)
        end
    end)
end

function EVENT:End()
    net.Start("EndNarration")
    net.Broadcast()
    timer.Remove("NarrationDelay")
    for _, ply in ipairs(player.GetAll()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            Randomat:RestoreWeaponSound(wep)
        end
    end
end

Randomat:register(EVENT)