local EVENT = {}

util.AddNetworkString("RdmtGaseousBegin")
util.AddNetworkString("RdmtGaseousEnd")

EVENT.Title = "Gaseous Snake"
EVENT.Description = "Turns everyone invisible but envelopes them in smoke"
EVENT.id = "gaseous"

local function SetPlayerInvisible(ply)
    ply:SetColor(Color(255, 255, 255, 0))
    ply:SetMaterial("sprites/heatwave")
end

local function SetPlayerVisible(ply)
    ply:SetColor(Color(255, 255, 255, 255))
    ply:SetMaterial("models/glass")
end

function EVENT:Begin()
    net.Start("RdmtGaseousBegin")
    net.Broadcast()

    for _, p in ipairs(self:GetAlivePlayers()) do
        SetPlayerInvisible(p)
    end

    self:AddHook("PlayerSpawn", function(ply)
        SetPlayerInvisible(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        SetPlayerVisible(victim)
    end)
end

function EVENT:End()
    net.Start("RdmtGaseousEnd")
    net.Broadcast()

    for _, p in ipairs(player.GetAll()) do
        SetPlayerVisible(p)
    end
end

Randomat:register(EVENT)