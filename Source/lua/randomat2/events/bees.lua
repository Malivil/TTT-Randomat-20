local EVENT = {}

CreateConVar("randomat_bees_count", 4,{FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Changes the number of bees spawned per player in the event\"NOT THE BEES!\", must be an integer")

EVENT.Title = "NOT THE BEES!"
EVENT.id = "bees"
BeeNPCClass 		= "npc_manhack"

function EVENT:Begin()
	local x = 0
	local plys = {}
	for k, v in pairs(self:GetAlivePlayers()) do
		x = x+1
		table.insert(plys, v)
	end
	timer.Create("randomatbees", 0.1, GetConVar("randomat_bees_count"):GetInt()*x, function()
		local rdmply = plys[math.random(1,#plys)]
		while not rdmply:Alive() and rdmply:IsSpec() do
			rdmply = plys[math.random(1,#plys)]
		end
		spos = rdmply:GetPos() + Vector(math.random(-75,75),math.random(-75,75),math.random(200,250))
		local headBee = SpawnNPC(ply, spos, BeeNPCClass)	
		headBee:SetNPCState(2)
		local Bee = ents.Create("prop_dynamic")
		Bee:SetModel("models/lucian/props/stupid_bee.mdl")
		Bee:SetPos(spos)
		Bee:SetParent(headBee)
		headBee:SetNoDraw(true)
		headBee:SetHealth(1000)
	end)
end

function EVENT:End()
	timer.Remove("randomatbees")
end

Randomat:register(EVENT)