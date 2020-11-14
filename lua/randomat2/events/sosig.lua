local EVENT = {}

EVENT.Title = "Sosig."
EVENT.id = "sosig"

util.AddNetworkString("TriggerSosig")
util.AddNetworkString("EndSosig")

local sosig_sound = "weapons/sosig.mp3"

local function FixWeapon(wep)
    wep.Primary.OriginalSound = wep.Primary.Sound
    wep.Primary.Sound = sosig_sound
end

function EVENT:Begin()
    net.Start("TriggerSosig")
    net.Broadcast()
    for _, ply in pairs(player.GetAll()) do
        for _, wep in pairs(ply:GetWeapons()) do
            FixWeapon(wep)
        end
    end
    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("SosigDelay", 0.1, 1, function()
            net.Start("TriggerSosig")
            net.Send(ply)
            FixWeapon(wep)
        end)
    end)

    self:AddHook("EntityEmitSound", function(data)
        local owner = data.Entity
        if not IsValid(owner) then return end
        local sound = data.SoundName:lower()
        local weap_start, _ = string.find(sound, "weapons/")
        local fire_start, _ = string.find(sound, "fire")
        if weap_start and fire_start then
            data.SoundName = sosig_sound
            return true
        end
    end)
end

function EVENT:End()
    net.Start("EndSosig")
    net.Broadcast()
end

Randomat:register(EVENT)