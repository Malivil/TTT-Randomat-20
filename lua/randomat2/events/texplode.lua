local EVENT = {}

CreateConVar("randomat_texplode_timer", 60, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Changes the time before the traitor explodes in the event \"A traitor will explode in x seconds!\"")
CreateConVar("randomat_texplode_radius", 600, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Radius of the traitor explosion")

EVENT.Title = ""
EVENT.AltTitle = "A traitor will explode in "..GetConVar("randomat_texplode_timer"):GetInt().." seconds!"
EVENT.id = "texplode"

function EVENT:Begin()
	local convarvalue = GetConVar("randomat_texplode_timer"):GetInt()
	Randomat:EventNotifySilent("A traitor will explode in "..convarvalue.." seconds!")
	local x = 0
	local block = 0
	for k, ply in RandomPairs(self:GetAlivePlayers(true)) do
		if ply:GetRole() == ROLE_TRAITOR then
			if block == 0 then
				tgt = ply
				tgt:PrintMessage(HUD_PRINTTALK, "You have been chosen to explode. Watch out, and stay close to innocents.")
				block = 1
			else
				ply:PrintMessage(HUD_PRINTTALK, tgt:Nick().." has been chosen to explode. Be careful.")
			end
		end
	end

	local effectdata = EffectData()

	timer.Create("RandomatTraitorExplode",1,convarvalue, function()
		x = x+1
		if convarvalue >= 45 and x == convarvalue - 30 then
			self:SmallNotify("30 seconds until the traitor explodes!")
		elseif convarvalue >= 20 and x == convarvalue - 10 then
			self:SmallNotify("10 seconds remaining!")
		elseif x == convarvalue then
			self:SmallNotify("The traitor has exploded!")
			tgt:EmitSound(Sound("ambient/explosions/explode_4.wav"))

			util.BlastDamage(tgt, tgt, tgt:GetPos(), GetConVar("randomat_texplode_radius"):GetInt(), 10000)

			effectdata:SetStart(tgt:GetPos() + Vector(0,0,10))
			effectdata:SetOrigin(tgt:GetPos() + Vector(0,0,10))
			effectdata:SetScale(1)

			util.Effect("HelicopterMegaBomb", effectdata)			
		end
	end)
end

function EVENT:End()
	timer.Remove("RandomatTraitorExplode")
end

function EVENT:Condition()
	local t = 0
	for k, v in pairs(self:GetAlivePlayers()) do
		if v:GetRole() == ROLE_TRAITOR then
			t = t+1
		end
	end

	if t > 1 then
		return true
	else
		return false
	end
end

Randomat:register(EVENT)