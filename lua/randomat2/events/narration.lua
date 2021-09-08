local EVENT = {}

EVENT.Title = "Narration"
EVENT.Description = "Narrates common game activities"
EVENT.id = "narration"

util.AddNetworkString("TriggerNarration")
util.AddNetworkString("EndNarration")

local footsteps_pattern = ".*player/footsteps/.*%..*"
local reload_sounds = {"weapons/reload/reload1.mp3", "weapons/reload/reload2.mp3", "weapons/reload/reload3.mp3", "weapons/reload/reload4.mp3", "weapons/reload/reload5.mp3", "weapons/reload/reload6.mp3", "weapons/reload/reload7.mp3", "weapons/reload/reload8.mp3"}
local death_sounds = {"blerg/blerg1.mp3", "blerg/blerg2.mp3", "blerg/blerg3.mp3", "blerg/blerg4.mp3", "blerg/blerg5.mp3", "blerg/blerg6.mp3", "blerg/blerg7.mp3", "blerg/blerg8.mp3", "blerg/blerg9.mp3", "blerg/blerg10.mp3"}
local gunshot_sounds = {"weapons/gunshot/gunshot1.mp3", "weapons/gunshot/gunshot2.mp3", "weapons/gunshot/gunshot3.mp3", "weapons/gunshot/gunshot4.mp3", "weapons/gunshot/gunshot5.mp3", "weapons/gunshot/gunshot6.mp3", "weapons/gunshot/gunshot7.mp3", "weapons/gunshot/gunshot8.mp3"}
local door_opening_sounds = {"door_opening/door_opening1.mp3", "door_opening/door_opening2.mp3", "door_opening/door_opening3.mp3", "door_opening/door_opening4.mp3", "door_opening/door_opening5.mp3"}
local door_closing_sounds = {"door_closing/door_closing1.mp3", "door_closing/door_closing2.mp3", "door_closing/door_closing3.mp3", "door_closing/door_closing4.mp3", "door_opening/door_closing5.mp3"}
local jump_sounds = {"jump/jump1.mp3", "jump/jump2.mp3", "jump/jump3.mp3", "jump/jump4.mp3"}
local sound_mapping = {
    -- Footsteps
    [footsteps_pattern] = {"footsteps/footsteps1.mp3", "footsteps/footsteps2.mp3", "footsteps/footsteps3.mp3", "footsteps/footsteps4.mp3", "footsteps/footsteps5.mp3", "footsteps/footsteps6.mp3", "footsteps/footsteps7.mp3", "footsteps/footsteps8.mp3", "footsteps/footsteps9.mp3"},
    -- Explosions
    [".*weapons/.*explode.*%..*"] = {"explosion/explosion1.mp3", "explosion/explosion2.mp3", "explosion/explosion3.mp3", "explosion/explosion4.mp3", "explosion/explosion5.mp3", "explosion/explosion6.mp3", "explosion/explosion7.mp3", "explosion/explosion8.mp3", "explosion/explosion9.mp3"},
    -- C4 Beeps
    [".*weapons/.*beep.*%..*"] = {"beeping/beeping1.mp3", "beeping/beeping2.mp3", "beeping/beeping3.mp3", "beeping/beeping4.mp3", "beeping/beeping5.mp3", "beeping/beeping6.mp3", "beeping/beeping7.mp3"},
    -- Glass breaking
    [".*physics/glass/.*break.*%..*"] = {"smashing_glass/smashing_glass1.mp3", "smashing_glass/smashing_glass2.mp3", "smashing_glass/smashing_glass3.mp3", "smashing_glass/smashing_glass4.mp3", "smashing_glass/smashing_glass5.mp3", "smashing_glass/smashing_glass6.mp3", "smashing_glass/smashing_glass7.mp3", "smashing_glass/smashing_glass8.mp3"},
    -- Fall damage (which don't work when converted to MP3 for some reason)
    [".*player/damage*."] = {"bones_cracking/bones_cracking1.wav", "bones_cracking/bones_cracking2.wav", "bones_cracking/bones_cracking3.wav", "bones_cracking/bones_cracking4.wav", "bones_cracking/bones_cracking5.wav"},
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
                -- If this is a player "footstep"-ing in mid-air, they are jumping or using a ladder
                if footsteps_pattern == pattern and IsValid(data.Entity) and data.Entity:IsPlayer() and not data.Entity:IsOnGround() then
                    -- Don't replace the sound if the player is on a ladder
                    if data.Entity:GetMoveType() ~= MOVETYPE_LADDER then
                        new_sound = jump_sounds[math.random(1, #jump_sounds)]
                    end
                else
                    new_sound = sounds[math.random(1, #sounds)]
                end
            end
        end

        if new_sound then
            data.SoundName = new_sound
            return true
        -- Door opening/closing
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