local EVENT = {}

util.AddNetworkString("ReverseDemocracyEventBegin")
util.AddNetworkString("ReverseDemocracyEventEnd")
util.AddNetworkString("ReverseDemocracyPlayerVoted")
util.AddNetworkString("ReverseDemocracyReset")

CreateConVar("randomat_reversedemocracy_timer", 40, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of seconds each round of voting lasts", 10, 90)
CreateConVar("randomat_reversedemocracy_tiesaves", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether ties result in a coin toss; otherwise, nobody is saved")
CreateConVar("randomat_reversedemocracy_totalpct", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "% of player votes needed for a vote to pass, set to 0 to disable", 0, 100)
CreateConVar("randomat_reversedemocracy_show_votes", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show when a target is voted for in chat")
CreateConVar("randomat_reversedemocracy_show_votes_anon", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to hide who voted in chat")

EVENT.Title = "A power you can't learn from the Jedi"
EVENT.AltTitle = "ycarcomeD"
EVENT.Description = "Cast your vote to save a player from dying one time. Vote will only happen once"
EVENT.id = "reversedemocracy"
EVENT.Type = {EVENT_TYPE_VOTING, EVENT_TYPE_RESPAWN}
EVENT.MaxRoundCompletePercent = 15
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local playervotes = {}
local votableplayers = {}
local playersvoted = {}
local aliveplys = {}

function EVENT:Begin()
    net.Start("ReverseDemocracyEventBegin")
    net.Broadcast()
    local reversedemocracytimer = GetConVar("randomat_reversedemocracy_timer"):GetInt()

    playervotes = {}
    votableplayers = {}
    playersvoted = {}
    aliveplys = {}
    local skipsave = 0
    local savedply = 0

    for k, v in ipairs(player.GetAll()) do
        if not (v:Alive() and v:IsSpec()) then
            votableplayers[k] = v
            playervotes[k] = 0
        end
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
                    savedply = votableplayers[maxk[math.random(1, #maxk)]]
                elseif #maxk > 1 then
                    self:SmallNotify("The vote was a tie. Nobody was saved. For now.")
                    skipsave = 1
                else
                    savedply = votableplayers[maxk[1]]
                end

                if skipsave == 0 then
                    endVote = true
                    -- Mark the player as "saved" for later
                    savedply:SetNWBool("RdmtReverseDemocracySaved", true)
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
            local body = ply.server_ragdoll or ply:GetRagdollEntity()

            ply:PrintMessage(HUD_PRINTTALK, "You have been saved from death and given one more chance... don't waste it.")
            ply:PrintMessage(HUD_PRINTCENTER, "You have been saved from death and given one more chance... don't waste it.")
            ply:SpawnForRound(true)
            ply:SetNWBool("RdmtReverseDemocracySaved", false)
            if IsValid(body) then
                local credits = CORPSE.GetCredits(body, 0) or 0
                ply:SetCredits(credits)
                ply:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
                ply:SetPos(FindRespawnLocation(body:GetPos()) or body:GetPos())
                body:Remove()
            end
        end)
    end)
end

function EVENT:End()
    timer.Remove("RdmtReverseDemocracyTimer")
    timer.Remove("RdmtReverseDemocracyRespawnTimer")
    net.Start("ReverseDemocracyEventEnd")
    net.Broadcast()
    for _, v in ipairs(player.GetAll()) do
        v:SetNWBool("RdmtReverseDemocracySaved", false)
    end
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
            --return
        end
    end

    local votee = net.ReadString()
    local num
    for k, v in pairs(votableplayers) do
        if v:Nick() == votee then --find which player was voted for
            playersvoted[ply] = v --insert player and target into table

            if GetConVar("randomat_reversedemocracy_show_votes"):GetBool() then
                local anon = GetConVar("randomat_reversedemocracy_show_votes_anon"):GetBool()
                for _, va in ipairs(player.GetAll()) do
                    local name
                    if anon then
                        name = "Someone"
                    else
                        name = ply:Nick()
                    end
                    va:PrintMessage(HUD_PRINTTALK, name.." has voted to save "..votee)
                end
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