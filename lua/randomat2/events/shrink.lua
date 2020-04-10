local EVENT = {}

EVENT.Title = "Honey, I shrunk the terrorists"
EVENT.id = "shrink"

CreateConVar("randomat_shrink_scale", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Changes the shrinking scale factor for the event \"Honey, I shrunk the terrorists\"")

local rat = GetConVar("randomat_shrink_scale"):GetFloat() --ratio used for event stacking

function EVENT:Begin()
	local sc = GetConVar("randomat_shrink_scale"):GetFloat() --scale factor
	for k, ply in pairs(self:GetAlivePlayers(true)) do
		ply:SetStepSize(ply:GetStepSize()*sc)
		ply:SetModelScale( ply:GetModelScale()*sc, 1 )
		ply:SetViewOffset( ply:GetViewOffset()*sc )	
		ply:SetViewOffsetDucked( ply:GetViewOffsetDucked()*sc)
		local a, b = ply:GetHull()
		ply:SetHull( a*sc, b*sc )
		a, b = ply:GetHullDuck()
		ply:SetHullDuck( a*sc, b*sc )
		rat = ply:GetStepSize()/18
		ply:SetHealth(math.floor(rat*100))
		hook.Add("TTTPlayerSpeed", "RdmtShrinkMoveSpeed", function()
			return math.Clamp(ply:GetStepSize()/9, 0.25, 1)
		end)
	end
	local x = 0
	timer.Create("hptimer", 1, 0, function()
		for k, ply in pairs(self:GetAlivePlayers(true)) do
			rat = ply:GetStepSize()/18
			if ply:Health() > math.floor(rat*100) then
				ply:SetHealth(math.floor(rat*100))
			end
			ply:SetMaxHealth(math.floor(rat*100))
		end
	end)
end

function EVENT:End()
	hook.Remove("TTTPlayerSpeed", "RdmtShrinkMoveSpeed")
	for k, ply in pairs(player.GetAll()) do
		ply:SetModelScale( 1, 1 )
		ply:SetViewOffset( Vector(0,0,64) )
		ply:SetViewOffsetDucked( Vector(0, 0, 32) )
		ply:ResetHull()
		ply:SetStepSize(18)
		timer.Remove("hptimer")
	end
end

Randomat:register(EVENT)