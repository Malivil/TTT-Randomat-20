local EVENT = {}

util.AddNetworkString("ReverseDemocracyEventBegin")
util.AddNetworkString("ReverseDemocracyEventEnd")
util.AddNetworkString("ReverseDemocracyPlayerVoted")
util.AddNetworkString("ReverseDemocracyReset")

local eventnames = {}
table.insert(eventnames, "A power you can't learn from the Jedi")
table.insert(eventnames, "He could save others from death, but not himself")

CreateConVar("randomat_reversedemocracy_timer", 40, FCVAR_ARCHIVE, "The number of seconds each round of voting lasts", 10, 90)
CreateConVar("randomat_reversedemocracy_tiesaves", 1, FCVAR_ARCHIVE, "Whether ties result in a coin toss; otherwise, nobody is saved")
CreateConVar("randomat_reversedemocracy_totalpct", 50, FCVAR_ARCHIVE, "% of player votes needed for a vote to pass, set to 0 to disable", 0, 100)
CreateConVar("randomat_reversedemocracy_show_votes", 1, FCVAR_ARCHIVE, "Whether to show when a target is voted for in chat")
CreateConVar("randomat_reversedemocracy_show_votes_anon", 0, FCVAR_ARCHIVE, "Whether to hide who voted in chat")

EVENT.Title = table.Random(eventnames)
EVENT.AltTitle = "ycarcomeD"
EVENT.Description = "Cast your vote to save a player from dying one time. Vote will only happen once"
EVENT.id = "reversedemocracy"
EVENT.Type = {EVENT_TYPE_VOTING, EVENT_TYPE_RESPAWN}
EVENT.MaxRoundCompletePercent = 15
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local playervotes = {}
local votableplayers = {}
local playersvoted = {}

local function RespawnSaved(ply)
    local body = ply.server_ragdoll or ply:GetRagdollEntity()

    Randomat:PrintMessage(ply, MSG_PRINTBOTH, "You have been saved from death and given one more chance... don't waste it.")
    ply:SpawnForRound(true)
    ply:SetNWBool("RdmtReverseDemocracySaved", false)
    if IsValid(body) then
        local credits = CORPSE.GetCredits(body, 0) or 0
        ply:SetCredits(credits)
        ply:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
        ply:SetPos(FindRespawnLocation(body:GetPos()) or body:GetPos())
        body:Remove()
    end
end

function EVENT:Begin()
    net.Start("ReverseDemocracyEventBegin")
    net.Broadcast()
    local reversedemocracytimer = GetConVar("randomat_reversedemocracy_timer"):GetInt()

    playervotes = {}
    votableplayers = {}
    playersvoted = {}
    local aliveplys = {}
    local skipsave = 0
    local savedply = 0

    for k, v in ipairs(self:GetAlivePlayers()) do
        votableplayers[k] = v
        playervotes[k] = 0
    end

    local repeater = 0
    timer.Create("RdmtReverseDemocracyTimer", 1, 0, function()
        repeater = repeater + 1
        if reversedemocracytimer > 19 and repeater == reversedemocracytimer - 10 then
            self:SmallNotify("10 seconds left on voting!")
        elseif repeater == reversedemocracytimer then
            repeater = 0
            local votenumber = 0
            for _, v in pairs(playervotes) do -- Tally up votes
                votenumber = votenumber + v
            end
            for _, v in ipairs(self:GetAlivePlayers()) do
                table.insert(aliveplys, v)
            end

            local endVote = false
            if votenumber >= #aliveplys*(GetConVar("randomat_reversedemocracy_totalpct"):GetInt()/100) and votenumber ~= 0 then --If at least 1 person voted, and votes exceed cap determine who gets saved
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

                if GetConVar("randomat_reversedemocracy_tiesaves"):GetBool() then
                    savedply = votableplayers[maxk[math.random(#maxk)]]
                elseif #maxk > 1 then
                    self:SmallNotify("The vote was a tie. Nobody was saved. For now.")
                    skipsave = 1
                else
                    savedply = votableplayers[maxk[1]]
                end

                if skipsave == 0 then
                    endVote = true
                    -- If the player is still alive, mark them as "saved" for later
                    if savedply:Alive() and not savedply:IsSpec() then
                        savedply:SetNWBool("RdmtReverseDemocracySaved", true)
                    -- Otherwise just respawn them immediately
                    else
                        RespawnSaved(savedply)
                    end
                    self:SmallNotify(savedply:Nick() .. " was voted for.")
                else
                    skipsave = 0
                end
            elseif votenumber == 0 then --If nobody votes
                self:SmallNotify("Nobody was voted for. Nobody was saved. For now.")
            else
                self:SmallNotify("Not enough players voted. Nobody was saved. For now.")
            end

            table.Empty(playersvoted)
            table.Empty(aliveplys)

            if endVote then
                net.Start("ReverseDemocracyEventEnd")
                net.Broadcast()
                timer.Remove("RdmtReverseDemocracyTimer")
            else
                net.Start("ReverseDemocracyReset")
                net.Broadcast()
            end

            for k, _ in pairs(playervotes) do
                playervotes[k] = 0
            end
        end
    end)

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsPlayer(ply) then return end
        if not ply:GetNWBool("RdmtReverseDemocracySaved", false) then return end

        timer.Create("RdmtReverseDemocracyRespawnTimer", 0.25, 1, function()
            RespawnSaved(ply)
        end)
    end)

    self:AddHook("TTTWinCheckBlocks", function(win_blocks)
        table.insert(win_blocks, function(win_type)
            if win_type == WIN_NONE then return win_type end

            -- If the player we're saving is dead, block the win from happening so they can respawn
            for _, p in ipairs(self:GetDeadPlayers()) do
                if p:GetNWBool("RdmtReverseDemocracySaved", false) then
                    return WIN_NONE
                end
            end

            return win_type
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtReverseDemocracyTimer")
    timer.Remove("RdmtReverseDemocracyRespawnTimer")
    net.Start("ReverseDemocracyEventEnd")
    net.Broadcast()
    for _, v in player.Iterator() do
        v:SetNWBool("RdmtReverseDemocracySaved", false)
    end
end

function EVENT:Condition()
    -- Check that this variable exists by double negating
    -- We can't just return the variable directly because it's not a boolean
    -- The "TTTWinCheckBlocks" hook is only available in the new CR
    return not not CR_VERSION
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "totalpct"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    local checks = {}
    for _, v in ipairs({"tiesaves", "show_votes", "show_votes_anon"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

net.Receive("ReverseDemocracyPlayerVoted", function(ln, ply)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            return
        end
    end

    local votee = net.ReadString()
    if ply:Nick() == votee then
        ply:PrintMessage(HUD_PRINTTALK, "You can't vote for yourself.")
        return
    end

    local num
    for k, v in pairs(votableplayers) do
        -- Find which player was voted for
        if IsPlayer(v) and v:Nick() == votee then
            -- Save this player's vote target
            playersvoted[ply] = v

            if GetConVar("randomat_reversedemocracy_show_votes"):GetBool() then
                local anon = GetConVar("randomat_reversedemocracy_show_votes_anon"):GetBool()
                local name
                if anon then
                    name = "Someone"
                else
                    name = ply:Nick()
                end
                Randomat:SendChatToAll(name .. " has voted to save " .. votee)
            end

            playervotes[k] = playervotes[k] + 1
            num = playervotes[k]
            break
        end
    end

    net.Start("ReverseDemocracyPlayerVoted")
        net.WriteString(votee)
        net.WriteInt(num, 32)
    net.Broadcast()
end)

Randomat:register(EVENT)