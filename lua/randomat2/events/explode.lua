local EVENT = {}

CreateConVar("randomat_explode_timer", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Changes the time between explosions in the event \"A Random Person will explode every x seconds\".")

EVENT.Title = ""
EVENT.AltTitle = "A Random Person will explode every "..GetConVar("randomat_explode_timer"):GetInt().." seconds! Watch out! (EXCEPT DETECTIVES)"
EVENT.id = "explode"

function EVENT:Begin()

	Randomat:EventNotifySilent("A Random Person will explode every "..GetConVar("randomat_explode_timer"):GetInt().." seconds! Watch out! (EXCEPT DETECTIVES)")

	local effectdata = EffectData()

	timer.Create("RandomatExplode",GetConVar("randomat_explode_timer"):GetInt() ,0, function()
		local plys = {}
		for _, ply in pairs(self:GetPlayers(true)) do
			if !ply:GetDetective() then
				table.insert(plys, ply)
			end
		end
		local ply = plys[math.random(#plys)]

		if IsValid(ply) then
			self:SmallNotify(ply:Nick() .. " exploded!")
			ply:EmitSound(Sound("ambient/explosions/explode_4.wav"))

			util.BlastDamage(ply, ply, ply:GetPos(), 300, 10000)

			effectdata:SetStart(ply:GetPos() + Vector(0,0,10))
			effectdata:SetOrigin(ply:GetPos() + Vector(0,0,10))
			effectdata:SetScale(1)

			util.Effect("HelicopterMegaBomb", effectdata)
		else
			self:SmallNotify("No one exploded!")
		end
	end)
end

function EVENT:End()
	timer.Remove("RandomatExplode")
end

Randomat:register(EVENT)