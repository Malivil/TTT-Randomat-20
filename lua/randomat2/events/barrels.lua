local EVENT = {}

CreateConVar("randomat_barrels_count", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of barrels spawned per person")
CreateConVar("randomat_barrels_range", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Distance barrels spawn from the player")
CreateConVar("randomat_barrels_timer", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between barrel spawns")

EVENT.Title = "Gunpowder, Treason, and Plot"
EVENT.id = "barrels"

local function TriggerBarrels()
	local plys = {}
	for k, ply in pairs(player.GetAll()) do
		if not ply:IsSpec() then
			plys[k] = ply
		end
	end

	for k, ply in pairs(plys) do
		if ply:Alive() and not ply:IsSpec() then
			for i = 1, GetConVar("randomat_barrels_count"):GetInt() do
				if ( CLIENT ) then return end

				local ent = ents.Create( "prop_physics" )
				
				if ( !IsValid( ent ) ) then return end

				ent:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
				local sc = GetConVar("randomat_barrels_range"):GetInt()
				ent:SetPos( ply:GetPos() + Vector(math.random(-sc, sc), math.random(-sc, sc), math.random(5, sc)) )
				ent:Spawn()

				local phys = ent:GetPhysicsObject()
				if ( !IsValid( phys ) ) then ent:Remove() return end
			end
		end
	end
end

function EVENT:Begin()
	TriggerBarrels()
	timer.Create("RdmtBarrelSpawnTimer",GetConVar("randomat_barrels_timer"):GetInt(),0, TriggerBarrels)
end

function EVENT:End()
	timer.Remove("RdmtBarrelSpawnTimer")
end


Randomat:register(EVENT)