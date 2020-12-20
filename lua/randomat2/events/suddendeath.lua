local EVENT = {}

EVENT.Title = "Sudden Death!"
EVENT.Description = "Changes everyone to have only 1 health"
EVENT.id = "suddendeath"

function EVENT:Begin()
    timer.Create("suddendeathtimer", 1, 0, function()
        for _, ply in pairs(self:GetAlivePlayers()) do
            ply:SetHealth(1)
            ply:SetMaxHealth(1)
        end
    end)
end

function EVENT:End()
    timer.Remove("suddendeathtimer")
end

Randomat:register(EVENT)