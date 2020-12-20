local EVENT = {}

CreateConVar("randomat_bees_count", 4, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of bees spawned per player")

EVENT.Title = "NOT THE BEES!"
EVENT.Description = "Spawns hostile bees randomly around around players"
EVENT.id = "bees"

function EVENT:Begin()
    local x = 0
    local plys = {}
    for _, v in pairs(self:GetAlivePlayers()) do
        x = x+1
        table.insert(plys, v)
    end
    timer.Create("randomatbees", 0.1, GetConVar("randomat_bees_count"):GetInt()*x, function()
        local rdmply = plys[math.random(1,#plys)]
        while not rdmply:Alive() and rdmply:IsSpec() do
            rdmply = plys[math.random(1,#plys)]
        end
        local spos = rdmply:GetPos() + Vector(math.random(-75,75),math.random(-75,75),math.random(200,250))
        local headBee = SpawnNPC(rdmply, spos, "npc_manhack")
        headBee:SetNPCState(2)
        local bee = ents.Create("prop_dynamic")
        bee:SetModel("models/lucian/props/stupid_bee.mdl")
        bee:SetPos(spos)
        bee:SetParent(headBee)
        headBee:SetNoDraw(true)
        headBee:SetHealth(1000)
    end)
end

function EVENT:End()
    timer.Remove("randomatbees")
end

Randomat:register(EVENT)