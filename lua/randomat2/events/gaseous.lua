local EVENT = {}

util.AddNetworkString("RdmtGaseousBegin")
util.AddNetworkString("RdmtGaseousEnd")

EVENT.Title = "Gaseous Snake"
EVENT.Description = "Turns everyone invisible but envelopes them in smoke"
EVENT.id = "gaseous"
EVENT.Type = EVENT_TYPE_SMOKING
EVENT.Categories = {"moderateimpact"}

function EVENT:Begin()
    net.Start("RdmtGaseousBegin")
    net.Broadcast()

    for _, p in ipairs(self:GetAlivePlayers()) do
        Randomat:SetPlayerInvisible(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        Randomat:SetPlayerInvisible(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        Randomat:SetPlayerVisible(victim)
    end)

    -- Ensure things that make players visible don't permanently break this randomat
    timer.Create("RdmtGaseousTimer", 0.5, 0, function()
        for _, p in ipairs(self:GetAlivePlayers()) do
            if p:GetMaterial() ~= "sprites/heatwave" then
                Randomat:SetPlayerInvisible(p)
            end
        end
    end)
end

function EVENT:End()
    net.Start("RdmtGaseousEnd")
    net.Broadcast()

    for _, p in player.Iterator() do
        Randomat:SetPlayerVisible(p)
    end

    timer.Remove("RdmtGaseousTimer")
end

Randomat:register(EVENT)