local EVENT = {}

EVENT.Title = "Taking Inventory"
EVENT.id = "inventory"

CreateConVar("randomat_inventory_timer", 15, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time between inventory swaps")

function EVENT:Begin()
	local ply1
	local ply2
	timer.Create("RdmtInventoryTimer", GetConVar("randomat_inventory_timer"):GetInt(), 0, function()
		local x = 0
		for k, v in pairs(self:GetAlivePlayers(true)) do
			x = x+1
			if x == 1 then
				ply1 = v
			elseif x == 2 then
				ply2 = v
			end
		end

		local ply1weps = ply1:GetWeapons()
		ply1:StripWeapons()
		for k, v in pairs(ply2:GetWeapons()) do
			ply1:Give(v.ClassName)
			ply1:SetFOV(0, 0.2)
		end

		ply2:StripWeapons()
		for k, v in pairs(ply1weps) do
			ply2:Give(v.ClassName)
			ply2:SetFOV(0, 0.2)
		end
	end)
end

function EVENT:End()
	timer.Remove("RdmtInventoryTimer")
end

Randomat:register(EVENT)