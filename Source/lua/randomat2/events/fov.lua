local EVENT = {}

CreateConVar("randomat_fov_scale", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Scale of the fov increase")

EVENT.Title = "Quake Pro"
EVENT.id = "fov"

function EVENT:Begin()
	StartingPlys = {}
	local ChangedFOV = {}

	for k, v in pairs(player.GetAll()) do

		StartingPlys[k] = v

		ChangedFOV[v] = v:GetFOV()*GetConVar("randomat_fov_scale"):GetFloat()

	end

	timer.Create("RandomatFOVTimer", 0.1, 0, function()

		for k, v in pairs(StartingPlys) do
			
			if v:Alive() and not v:IsSpec() then
				v:SetFOV( ChangedFOV[v], 0 )
			else
				v:SetFOV(0,0)
			end

		end

	end)

end

function EVENT:End()

	timer.Remove("RandomatFOVTimer")

	for k, v in pairs(StartingPlys) do
		
		v:SetFOV(0,0)

	end

end

Randomat:register(EVENT)