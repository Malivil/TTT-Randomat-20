local EVENT = {}

EVENT.Title = "Infinite Credits for Everyone!"
EVENT.id = "credits"

function EVENT:Begin()
    timer.Create("GiveCredsTimer", 0, 0, function()
        for _, ply in pairs(player.GetAll()) do
            ply:SetCredits(5)
        end
    end)
end

function EVENT:End()
    timer.Remove("GiveCredsTimer")
end

Randomat:register(EVENT)