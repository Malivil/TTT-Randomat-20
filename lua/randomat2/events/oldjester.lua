local EVENT = {}

EVENT.Title = "##BringBackOldJester"
EVENT.id = "oldjester"

function EVENT:Begin()
	--[[
    ws = GetConVar("jesterwinstate"):GetInt()
	jt = GetConVar("jestertraitor"):GetInt()
	RunConsoleCommand("jestertraitor", 0)
	RunConsoleCommand("jesterwinstate", 1)
	local x = 0

	for k, j in pairs(self:GetAlivePlayers(true)) do
		if j:GetRole() == ROLE_JESTER then
			for _, t in pairs(self:GetAlivePlayers(true)) do
				if t:GetRole() == ROLE_TRAITOR then
					t:PrintMessage(HUD_PRINTTALK, j:Nick().." is the jester")
				end
			end
		end
    end
    --]]
end

function EVENT:End()
	--RunConsoleCommand("jesterwinstate", ws)
	--RunConsoleCommand("jestertraitor", jt)
end

function EVENT:Condition()
    -- Disable for Custom Roles for TTT
    return false
    --[[local j = 0
	for k, v in pairs(player.GetAll()) do
		if v:GetRole() == ROLE_JESTER and v:Alive() and not v:IsSpec() then
			j = 1
		end
	end

	if j == 1 and GetConVar("jesterwinstate"):GetInt() ~= 1 then
		return true
	else
		return false
	end]]--
end

Randomat:register(EVENT)