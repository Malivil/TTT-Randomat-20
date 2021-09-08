local EVENT = {}

EVENT.Title = "Narration"
EVENT.Description = "Narrates common game activities"
EVENT.id = "narration"

util.AddNetworkString("TriggerNarration")
util.AddNetworkString("EndNarration")

local reload_sounds = {"weapons/reload/reload1.mp3", "weapons/reload/reload2.mp3"}
local death_sounds = {"blerg/blerg1.mp3", "blerg/blerg2.mp3", "blerg/blerg3.mp3", "blerg/blerg4.mp3", "blerg/blerg5.mp3", "blerg/blerg6.mp3", "blerg/blerg7.mp3", "blerg/blerg8.mp3", "blerg/blerg9.mp3", "blerg/blerg10.mp3"}
local gunshot_sounds = {"weapons/gunshot/gunshot1.mp3"}
local door_opening_sounds = {"door_opening/door_opening1.mp3"}
local door_closing_sounds = {"door_closing/door_closing1.mp3"}
local sound_mapping = {
    -- Footsteps
    [".*player/footsteps/.*%..*"] = {"footsteps/footsteps1.mp3", "footsteps/footsteps2.mp3"},
    -- Explosions
    [".*weapons/.*explode.*%..*"] = {"explosion/explosion1.mp3", "explosion/explosion2.mp3", "explosion/explosion3.mp3"},
    -- C4 Beeps
    [".*weapons/.*beep.*%..*"] = {"beeping/beeping1.mp3", "beeping/beeping2.mp3"},
    -- Glass breaking
    [".*physics/glass/.*break.*%..*"] = {"smashing_glass/smashing_glass1.mp3", "smashing_glass/smashing_glass2.mp3"},
    -- Fall damage
    [".*player/damage*.%.mp3"] = {"bones_cracking/bones_cracking1.mp3"},
    -- Player death
    [".*player/death.*%.mp3"] = death_sounds,
    [".*vo/npc/male01/pain*.%.mp3"] = death_sounds,
    [".*vo/npc/barney/ba_pain*.%.mp3"] = death_sounds,
    [".*vo/npc/barney/ba_ohshit03%.mp3"] = death_sounds,
    [".*vo/npc/barney/ba_no01%.mp3"] = death_sounds,
    [".*vo/npc/male01/no02%.mp3"] = death_sounds,
    [".*hostage/hpain/hpain.*%.mp3"] = death_sounds,
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
		return door:GetInternalVariable( "m_toggle_state" ) == 0
	elseif doorClass == "prop_door_rotating" then
		return door:GetInternalVariable( "m_eDoorState" ) ~= 0
    end
    return false
end

function EVENT:Begin()
    net.Start("TriggerNarration")
    net.Broadcast()
    for _, ply in ipairs(player.GetAll()) do
        for _, wep in ipairs(ply:GetWeapons()) do
            local chosen_sound = gunshot_sounds[math.random(1, #gunshot_sounds)]
            Randomat:OverrideWeaponSound(wep, chosen_sound)
        end
    end

    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("NarrationDelay", 0.1, 1, function()
            net.Start("TriggerNarration")
            net.Send(ply)
            local chosen_sound = gunshot_sounds[math.random(1, #gunshot_sounds)]
            Randomat:OverrideWeaponSound(wep, chosen_sound)
        end)
    end)

    self:AddHook("EntityEmitSound", function(data)
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
        elseif current_sound == "doors/default_move.wav" then
            if DoorIsOpen(data.Entity) then
                data.SoundName = door_closing_sounds[math.random(1, #door_closing_sounds)]
            else
                data.SoundName = door_opening_sounds[math.random(1, #door_opening_sounds)]
            end
            -- Increase the volume of these so they can be heard
            data.Volume = 2
            data.SoundLevel = 100
            return true
        else
            local chosen_sound = gunshot_sounds[math.random(1, #gunshot_sounds)]
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