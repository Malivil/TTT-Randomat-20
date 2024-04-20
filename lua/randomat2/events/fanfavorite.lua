local EVENT = {}

util.AddNetworkString("FanFavoriteEventBegin")
util.AddNetworkString("FanFavoriteEventEnd")
util.AddNetworkString("FanFavoritePlayerVoted")
util.AddNetworkString("FanFavoriteReset")

CreateConVar("randomat_fanfavorite_timer", 40, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of seconds each round of voting lasts", 10, 90)
CreateConVar("randomat_fanfavorite_tiereses", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether ties result in a coin toss; otherwise, nobody is resurrected")
CreateConVar("randomat_fanfavorite_totalpct", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "% of player votes needed for a vote to pass, set to 0 to disable", 0, 100)
CreateConVar("randomat_fanfavorite_show_votes", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show when a target is voted for in chat")
CreateConVar("randomat_fanfavorite_show_votes_anon", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to hide who voted in chat")

EVENT.Title = "Fan Favorite"
EVENT.Description = "Cast your vote to resurrect a dead player"
EVENT.id = "fanfavorite"
EVENT.Type = {EVENT_TYPE_VOTING, EVENT_TYPE_RESPAWN}
EVENT.MinRoundCompletePercent = 30
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local playervotes = {}
local votableplayers = {}
local playersvoted = {}
local aliveplys = {}
local noneLabel = "None of the Above"

function EVENT:Begin()
    net.Start("FanFavoriteEventBegin")
    net.Broadcast()
    local fanfavoritetimer = GetConVar("randomat_fanfavorite_timer"):GetInt()

    playervotes = {}
    votableplayers = {}
    playersvoted = {}
    aliveplys = {}
    local skipres = 0
    local resedply = 0

    for k, v in player.Iterator() do
        if not v:Alive() or v:IsSpec() then
            votableplayers[k] = v
            playervotes[k] = 0
        end
    end
    votableplayers[noneLabel] = noneLabel
    playervotes[noneLabel] = 0

    local repeater = 0

    timer.Create("RdmtFanFavoriteTimer", 1, 0, function()
        repeater = repeater + 1
        if fanfavoritetimer > 19 and repeater == fanfavoritetimer - 10 then
            self:SmallNotify("10 seconds left on voting!")
        elseif repeater == fanfavoritetimer then
            repeater = 0
            local votenumber = 0
            for _, v in pairs(playervotes) do -- Tally up votes
                votenumber = votenumber + v
            end
            for _, v in ipairs(self:GetAlivePlayers()) do
                table.insert(aliveplys, v)
            end

            local endVote = false
            if votenumber >= #aliveplys*(GetConVar("randomat_fanfavorite_totalpct"):GetInt()/100) and votenumber ~= 0 then --If at least 1 person voted, and votes exceed cap determine who gets resurrected
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

                if GetConVar("randomat_fanfavorite_tiereses"):GetBool() then
                    resedply = votableplayers[maxk[math.random(#maxk)]]
                elseif #maxk > 1 then
                    self:SmallNotify("The vote was a tie. Nobody was resurrected. For now.")
                    skipres = 1
                else
                    resedply = votableplayers[maxk[1]]
                end

                if skipres == 0 then
                    endVote = true
                    if resedply == noneLabel then
                        self:SmallNotify("'" .. resedply .. "' was voted for so nobody will be resurrected.")
                    else
                        -- Resurrect the player
                        local body = resedply.server_ragdoll or resedply:GetRagdollEntity()

                        Randomat:PrintMessage(resedply, MSG_PRINTBOTH, "You have been resurrected by your peers and given one more chance... don't waste it.")
                        resedply:SpawnForRound(true)
                        if IsValid(body) then
                            local credits = CORPSE.GetCredits(body, 0) or 0
                            resedply:SetCredits(credits)
                            resedply:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
                            resedply:SetPos(FindRespawnLocation(body:GetPos()) or body:GetPos())
                            body:Remove()
                        end
                        self:SmallNotify(resedply:Nick() .. " was voted for.")
                    end
                else
                    skipres = 0
                end
            elseif votenumber == 0 then --If nobody votes
                self:SmallNotify("Nobody was voted for. Nobody was resurrected. For now.")
            else
                self:SmallNotify("Not enough players voted. Nobody was resurrected. For now.")
            end

            table.Empty(playersvoted)
            table.Empty(aliveplys)

            if endVote then
                net.Start("FanFavoriteEventEnd")
                net.Broadcast()
                timer.Remove("RdmtFanFavoriteTimer")
            else
                net.Start("FanFavoriteReset")
                net.Broadcast()
            end

            for k, _ in pairs(playervotes) do
                playervotes[k] = 0
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtFanFavoriteTimer")
    net.Start("FanFavoriteEventEnd")
    net.Broadcast()
end

function EVENT:Condition()
    return #self:GetDeadPlayers() > 1
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
    for _, v in ipairs({"tiereses", "show_votes", "show_votes_anon"}) do
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

net.Receive("FanFavoritePlayerVoted", function(ln, ply)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            return
        end
    end

    local votee = net.ReadString()
    local num
    if votee == noneLabel then
        playervotes[votee] = playervotes[votee] + 1
        num = playervotes[votee]
    else
        for k, v in pairs(votableplayers) do
            if IsPlayer(v) and v:Nick() == votee then --find which player was voted for
                playersvoted[ply] = v --insert player and target into table

                if GetConVar("randomat_fanfavorite_show_votes"):GetBool() then
                    local anon = GetConVar("randomat_fanfavorite_show_votes_anon"):GetBool()
                    local name
                    if anon then
                        name = "Someone"
                    else
                        name = ply:Nick()
                    end
                    Randomat:SendChatToAll(name .. " has voted to resurrect " .. votee)
                end

                playervotes[k] = playervotes[k] + 1
                num = playervotes[k]
                break
            end
        end
    end

    net.Start("FanFavoritePlayerVoted")
        net.WriteString(votee)
        net.WriteInt(num, 32)
    net.Broadcast()
end)

Randomat:register(EVENT)