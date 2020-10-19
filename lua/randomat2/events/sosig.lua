local EVENT = {}

EVENT.Title = "Sosig."
EVENT.id = "sosig"

util.AddNetworkString("TriggerSosig")

function EVENT:Begin()
    net.Start("TriggerSosig")
    net.Broadcast()
    for _, ply in pairs(player.GetAll()) do
        for _, wep in pairs(ply:GetWeapons()) do
            wep.Primary.Sound = "weapons/sosig.mp3"
        end
    end
    self:AddHook("WeaponEquip", function(wep, ply)
        timer.Create("SosigDelay", 0.1, 1, function()
            net.Start("TriggerSosig")
            net.Send(ply)
            for _, p in pairs(player.GetAll()) do
                for _, w in pairs(p:GetWeapons()) do
                    w.Primary.Sound = "weapons/sosig.mp3"
                end
            end
        end)
    end)
end

Randomat:register(EVENT)