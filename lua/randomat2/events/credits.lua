local EVENT = {}

EVENT.Title = "Infinite Credits for Everyone!"
EVENT.ExtDescription = "Continuously sets each player to have 10 credits, allowing them to buy anything they can hold"
EVENT.id = "credits"
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    timer.Create("GiveCredsTimer", 0, 0, function()
        for _, ply in player.Iterator() do
            ply:SetCredits(10)
        end
    end)
end

function EVENT:End()
    timer.Remove("GiveCredsTimer")
end

Randomat:register(EVENT)