local EVENT = {}

CreateConVar("randomat_paranoid_timer_min", 15, FCVAR_ARCHIVE, "The minimum time before the sound should play", 1, 120)
CreateConVar("randomat_paranoid_timer_max", 30, FCVAR_ARCHIVE, "The maximum time before the sound should play", 1, 120)
CreateConVar("randomat_paranoid_shots_min", 2, FCVAR_ARCHIVE, "The minimum times the sound should play", 1, 10)
CreateConVar("randomat_paranoid_shots_max", 6, FCVAR_ARCHIVE, "The maximum times the sound should play", 1, 15)
CreateConVar("randomat_paranoid_volume", 125, FCVAR_ARCHIVE, "The volume the sound should play at", 75, 180)
CreateConVar("randomat_paranoid_blocklist", "weapon_pulserif,weapon_ttt_dislocator,tfa_jetgun", FCVAR_ARCHIVE, "The comma-separated list of weapon IDs to not use for sounds")

EVENT.Title = "Paranoid"
EVENT.Description = "Periodically plays gun and death sounds randomly around players"
EVENT.id = "paranoid"
EVENT.StartSecret = true
EVENT.Categories = {"largeimpact"}

function EVENT:GetRandomWeaponSound(sounds)
    local chosen_sound
    -- Choose a random (but valid) sound
    repeat
        local idx = math.random(#sounds)
        chosen_sound = sounds[idx]
    until chosen_sound and #chosen_sound > 0

    return chosen_sound
end

local deathsounds = {
    Sound("player/death1.wav"),
    Sound("player/death2.wav"),
    Sound("player/death3.wav"),
    Sound("player/death4.wav"),
    Sound("player/death5.wav"),
    Sound("player/death6.wav"),
    Sound("vo/npc/male01/pain07.wav"),
    Sound("vo/npc/male01/pain08.wav"),
    Sound("vo/npc/male01/pain09.wav"),
    Sound("vo/npc/male01/pain04.wav"),
    Sound("vo/npc/Barney/ba_pain06.wav"),
    Sound("vo/npc/Barney/ba_pain07.wav"),
    Sound("vo/npc/Barney/ba_pain09.wav"),
    Sound("vo/npc/Barney/ba_ohshit03.wav"), --heh
    Sound("vo/npc/Barney/ba_no01.wav"),
    Sound("vo/npc/male01/no02.wav"),
    Sound("hostage/hpain/hpain1.wav"),
    Sound("hostage/hpain/hpain2.wav"),
    Sound("hostage/hpain/hpain3.wav"),
    Sound("hostage/hpain/hpain4.wav"),
    Sound("hostage/hpain/hpain5.wav"),
    Sound("hostage/hpain/hpain6.wav")
}
local sounds = {}
function EVENT:StartTimer()
    local delay_min = GetConVar("randomat_paranoid_timer_min"):GetInt()
    local delay_max = math.max(delay_min, GetConVar("randomat_paranoid_timer_max"):GetInt())
    local delay = math.random(delay_min, delay_max)
    local volume = GetConVar("randomat_paranoid_volume"):GetInt()
    timer.Create("RdmtParanoidSoundTimer", delay, 1, function()
        -- Get a random player and their position
        local target = self:GetAlivePlayers(true)[1]
        local target_pos = target:GetPos()

        -- Move it around a little
        target_pos.x = target_pos.x + math.random(-50, 50)
        target_pos.y = target_pos.y + math.random(-50, 50)

        -- Play death sounds 1/3 times
        if math.random(3) == 1 then
            local idx = math.random(#deathsounds)
            local chosen_sound = deathsounds[idx]
            sound.Play(chosen_sound, target_pos, volume, 100, 1)

            self:StartTimer()
        else
            local chosen_sound = self:GetRandomWeaponSound(sounds)

            -- Determine how many times to play the sound
            local count_min = GetConVar("randomat_paranoid_shots_min"):GetInt()
            local count_max = math.max(count_min, GetConVar("randomat_paranoid_shots_max"):GetInt())
            local count = math.random(count_min, count_max)

            timer.Create("RdmtParanoidShotTimer", 0.25, count, function()
                sound.Play(chosen_sound, target_pos, volume, 100, 1)

                -- Start the overall timer again once the shots are done
                if timer.RepsLeft("RdmtParanoidShotTimer") == 0 then
                    self:StartTimer()
                end
            end)
        end
    end)
end

function EVENT:Begin()
    local blocklist = {}
    for blocked_id in string.gmatch(GetConVar("randomat_paranoid_blocklist"):GetString(), "([^,]+)") do
        table.insert(blocklist, blocked_id:Trim())
    end

    -- Add all non-blocked weapon sounds
    for _, v in pairs(weapons.GetList()) do
        if v and v.Primary.Sound and not table.HasValue(blocklist, v.ClassName) and not string.find(v.Primary.Sound, "base") then
            table.insert(sounds, v.Primary.Sound)
        end
    end

    self:StartTimer()
end

function EVENT:End()
    timer.Remove("RdmtParanoidSoundTimer")
    timer.Remove("RdmtParanoidShotTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer_min", "timer_max", "shots_min", "shots_max", "volume"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders, {}
end

Randomat:register(EVENT)