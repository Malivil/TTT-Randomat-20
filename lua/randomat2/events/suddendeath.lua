local EVENT = {}

EVENT.Title = "Sudden Death!"
EVENT.Description = "Changes everyone to have only 1 health"
EVENT.id = "suddendeath"

function EVENT:Begin(...)
    local params = ...
    local health = 1
    if params ~= nil and params[1] ~= nil then
        health = params[1]
    end

    timer.Create("suddendeathtimer", 1, 0, function()
        for _, ply in ipairs(self:GetAlivePlayers()) do
            local player_health = math.min(ply:Health(), health)
            ply:SetHealth(player_health)
            ply:SetMaxHealth(health)
        end
    end)
end

function EVENT:End()
    timer.Remove("suddendeathtimer")
end

Randomat:register(EVENT)