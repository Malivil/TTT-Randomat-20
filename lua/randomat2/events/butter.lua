local EVENT = {}

CreateConVar("randomat_butter_timer", 10, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Changes the timer between each weapon drop for the event \"Butterfingers\"")
CreateConVar("randomat_butter_affectall", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "Set to 1 to make the event \"Butterfingers\" affect everyone at once, rather than one person at a time.")

EVENT.Title = "Butterfingers"
EVENT.id = "butter"

function EVENT:Begin()
	local x = 0
	timer.Create("weapondrop", GetConVar("randomat_butter_timer"):GetInt(), 0, function()
		for k, ply in pairs( self:GetAlivePlayers(true)) do
			x = x+1
			if x == 1 or GetConVar("randomat_butter_affectall"):GetBool() then
				if ply:GetActiveWeapon().AllowDrop then
					ply:DropWeapon(ply:GetActiveWeapon())
					ply:SetFOV(0, 0.2)
					ply:EmitSound("vo/npc/Barney/ba_pain01.wav")
				end
			end
		end
		x = 0
	end)
end

function EVENT:End()
	timer.Remove("weapondrop")
end

Randomat:register(EVENT)