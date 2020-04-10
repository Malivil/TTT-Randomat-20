local EVENT = {}

util.AddNetworkString("DemocracyEventBegin")
util.AddNetworkString("DemocracyEventEnd")
util.AddNetworkString("DemocracyPlayerVoted")
util.AddNetworkString("DemocracyReset")
CreateConVar("randomat_democracy_timer", 40, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Length of the democracy timer")
CreateConVar("randomat_democracy_tiekills", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "If 1, ties result in a coin toss; if 0, nobody dies in a tied vote.")
CreateConVar("randomat_democracy_totalpct", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Percent of total player votes required for a vote to pass, set to 0 to disable")
local ROLE_JESTER = ROLE_JESTER or false

EVENT.Title = "I love democracy, I love the republic."
EVENT.id = "democracy"


function EVENT:Begin()
	net.Start("DemocracyEventBegin")
	net.Broadcast()
	local democracytimer = GetConVar("randomat_democracy_timer"):GetInt()
	
	playervotes = {}
	votableplayers = {}
	playersvoted = {}
	aliveplys = {}
	local skipkill = 0
	local slainply = 0
	
	for k, v in pairs(player.GetAll()) do
		if not (v:Alive() and v:IsSpec()) then
			votableplayers[k] = v
			playervotes[k] = 0
		end
	end
	
	local repeater = 0
	
	timer.Create("votekilltimer", 1, 0, function()	
		repeater = repeater + 1
		if democracytimer > 19 and repeater == democracytimer - 10 then
			self:SmallNotify("10 seconds left on voting!")
		elseif repeater == democracytimer then
			repeater = 0
			local votenumber = 0
			for k, v in pairs(playervotes) do -- Tally up votes
				votenumber = votenumber + v
			end
			for k, v in pairs(self:GetAlivePlayers(true)) do
				table.insert(aliveplys, v)
			end
		
			if votenumber >= #aliveplys*(GetConVar("randomat_democracy_totalpct"):GetInt()/100) and votenumber ~= 0 then --If at least 1 person voted, and votes exceed cap determine who gets killed
				local maxv = 0
				local maxk = {}

				for k, v in pairs(playervotes) do
					if v > maxv then
						maxv = v
						maxk[1] = k
					end
				end

				for k, v in pairs(playervotes) do
					if v == maxv and k ~= maxk[1] then
						table.insert(maxk, k)
					end
				end
				
				if GetConVar("randomat_democracy_tiekills"):GetBool() then
					slainply = votableplayers[maxk[math.random(1, #maxk)]]
				elseif #maxk > 1 then
					self:SmallNotify("The vote was a tie. Everyone stays alive. For now.")
					skipkill = 1
				else
					slainply = votableplayers[maxk[1]]
					print(votableplayers[maxk[1]]:Nick())
				end

				if skipkill == 0 then
					if slainply:GetRole() == ROLE_JESTER then
						local jesterrepeater = 0
						for voter, tgt in RandomPairs(playersvoted) do
							if jesterrepeater == 0 and voter:GetRole() ~= ROLE_JESTER and tgt == slainply then
								jesterrepeater = 1
								voter:Kill()
								self:SmallNotify(voter:Nick().." was dumb enough to vote for the Jester!")
							end
						end
					else
						slainply:Kill()
						self:SmallNotify(slainply:Nick() .. " was voted for.")
					end
				else
					skipkill = 0
				end
			elseif votenumber == 0 then --If nobody votes
				self:SmallNotify("Nobody was voted for. Everyone stays alive. For now.")
			else
				self:SmallNotify("Not enough players voted. Everyone stays alive. For now.")
			end
			
			ClearTable(playersvoted)
			ClearTable(aliveplys)

			net.Start("DemocracyReset")
			net.Broadcast()

			for k, v in pairs(playervotes) do
				playervotes[k] = 0
			end
		end	
	end)
end

function EVENT:End()
	timer.Remove("votekilltimer")
	hook.Remove("VoteKillHook")
	net.Start("DemocracyEventEnd")
	net.Broadcast()
end

net.Receive("DemocracyPlayerVoted", function(ln, ply)
	local voterepeatblock = 0
	local votee = net.ReadString()
	local num

	for k, v in pairs(playersvoted) do
		if k == ply then voterepeatblock = 1 end
		ply:PrintMessage(HUD_PRINTTALK, "you have already voted.")
	end

	for k, v in pairs(votableplayers) do
		if v:Nick() == votee and voterepeatblock == 0 then --find which player was voted for
			playersvoted[ply] = v --insert player and target into table

			for ka, va in pairs(player.GetAll()) do
				va:PrintMessage(HUD_PRINTTALK, ply:Nick().." has voted to kill "..votee) --tell everyone who they voted for
			end

			playervotes[k] = playervotes[k] + 1
			num = playervotes[k]
		end
	end

	net.Start("DemocracyPlayerVoted")
		net.WriteString(votee)
		net.WriteInt(num, 32)
	net.Broadcast()
end)

function ClearTable(table)
	for k, v in pairs(table) do
		table[k] = nil
	end
end

Randomat:register(EVENT)