local EVENT = {}

EVENT.Title = "Sosig."
EVENT.Description = "Sosig."
EVENT.ExtDescription = "Replaces all gun sounds with 'Sosig'"
EVENT.id = "sosig"
EVENT.Type = EVENT_TYPE_GUNSOUNDS
EVENT.Categories = {"fun", "smallimpact"}

util.AddNetworkString("RdmtSosigUpdateWeaponSounds")

local sosig_sound = "weapons/sosig.mp3"

function EVENT:Begin()
    for _, ply in player.Iterator() do
        for _, wep in ipairs(ply:GetWeapons()) do
            Randomat:OverrideWeaponSound(wep, sosig_sound)
        end
    end

    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("SosigDelay", 0.1, 1, function()
            net.Start("RdmtSosigUpdateWeaponSounds")
            net.Send(ply)
            Randomat:OverrideWeaponSound(wep, sosig_sound)
        end)
    end)

    self:AddHook("EntityEmitSound", function(data)
        return Randomat:OverrideWeaponSoundData(data, sosig_sound)
    end)
end

function EVENT:End()
    timer.Remove("SosigDelay")
    for _, ply in player.Iterator() do
        for _, wep in ipairs(ply:GetWeapons()) do
            Randomat:RestoreWeaponSound(wep)
        end
    end
end

Randomat:register(EVENT)