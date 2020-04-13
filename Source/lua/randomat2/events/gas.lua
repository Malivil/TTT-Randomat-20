local EVENT = {}

CreateConVar("randomat_gas_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Changes the time between grenade drops")
CreateConVar("randomat_gas_affectall", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set to 1 for the event to drop a grenade at everyone's feet on trigger")
CreateConVar("randomat_gas_discombob", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether discombobs drop")
CreateConVar("randomat_gas_incendiary", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether incendiaries drop")
CreateConVar("randomat_gas_smoke", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether smokes drop")

potatoTable = {}

EVENT.Title = "Bad Gas"
EVENT.id = "gas"

function EVENT:Begin()
	if GetConVar("randomat_gas_discombob"):GetBool() then
		potatoTable[1] = "ttt_confgrenade_proj"
	end
	if GetConVar("randomat_gas_smoke"):GetBool() then
		potatoTable[2] = "ttt_smokegrenade_proj"
	end
	if GetConVar("randomat_gas_incendiary"):GetBool() then
		potatoTable[3] = "ttt_firegrenade_proj"
	end

	timer.Create("gastimer", GetConVar("randomat_gas_timer"):GetInt() , 0, function()
		local x = 0
		for k, ply in pairs( self:GetAlivePlayers(true)) do
			if x == 0 or GetConVar("randomat_gas_affectall"):GetBool() then
				local gren = ents.Create(potatoTable[math.random(#potatoTable)])
				if not IsValid(gren) then return end
				gren:SetPos(ply:GetPos())
				gren:SetOwner(ply)
				gren:SetThrower(ply)
				gren:SetGravity(0.4)
				gren:SetFriction(0.2)
				gren:SetElasticity(0.45)
				gren:Spawn()
				gren:PhysWake()
				gren:SetDetonateExact(1)
				x = 1
			end
		end
	end)
end

function EVENT:End()
	timer.Remove("gastimer")
end

Randomat:register(EVENT)