local EVENT = {}

util.AddNetworkString("DemocracyEventBegin")
util.AddNetworkString("DemocracyJesterRevenge")
util.AddNetworkString("DemocracyEventEnd")
util.AddNetworkString("DemocracyPlayerVoted")
util.AddNetworkString("DemocracyJesterVoted")
util.AddNetworkString("DemocracyReset")
CreateConVar("randomat_democracy_timer", 40, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of seconds each round of voting lasts", 10, 90)
CreateConVar("randomat_democracy_tiekills", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether ties result in a coin toss; otherwise, nobody dies")
CreateConVar("randomat_democracy_totalpct", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "% of player votes needed for a vote to pass, set to 0 to disable", 0, 100)
CreateConVar("randomat_democracy_jestermode", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How to handle when Jester/Swapper is voted for. See documentation", 0, 2)

EVENT.Title = "I love democracy, I love the republic."
EVENT.AltTitle = "Democracy"
EVENT.id = "democracy"

local playervotes = {}
local votableplayers = {}
local playersvoted = {}
local aliveplys = {}

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
            for _, v in pairs(playervotes) do -- Tally up votes
                votenumber = votenumber + v
            end
            for _, v in pairs(self:GetAlivePlayers()) do
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
                end

                if skipkill == 0 then
                    if slainply:GetRole() == ROLE_JESTER or slainply:GetRole() == ROLE_SWAPPER then
                        local jestervoters = {}
                        for voter, tgt in RandomPairs(playersvoted) do
                            if voter:Alive() and not voter:IsSpec() and voter:GetRole() ~= ROLE_JESTER and voter:GetRole() ~= ROLE_SWAPPER and tgt == slainply then
                                table.insert(jestervoters, voter)
                            end
                        end

                        local jestermode = GetConVar("randomat_democracy_jestermode"):GetInt()
                        if jestermode == 2 then
                            net.Start("DemocracyJesterRevenge")
                            net.WriteTable(jestervoters)
                            net.Send(slainply)
                        else
                            local voter = nil
                            for _, v in RandomPairs(jestervoters) do
                                if voter == nil then
                                    voter = v
                                end
                            end
                            self:SmallNotify(voter:Nick().." was dumb enough to vote for the Jester!")

                            if jestermode == 1 then
                                -- Delay slightly to show the message above before the round potentially ends
                                timer.Simple(1, function()
                                    local dmginfo = DamageInfo()
                                    dmginfo:SetDamage(10000)
                                    dmginfo:SetAttacker(voter)
                                    dmginfo:SetInflictor(game.GetWorld())
                                    dmginfo:SetDamageType(DMG_BULLET)
                                    dmginfo:SetDamageForce(Vector(0, 0, 0))
                                    dmginfo:SetDamagePosition(voter:GetPos())
                                    slainply:TakeDamageInfo(dmginfo)
                                end)
                            else
                                voter:Kill()
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

            for k, _ in pairs(playervotes) do
                playervotes[k] = 0
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("votekilltimer")
    net.Start("DemocracyEventEnd")
    net.Broadcast()
end

function EVENT:Condition()
    return not Randomat:IsEventActive("election")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"timer", "totalpct", "jestermode"}) do
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
    for _, v in pairs({"tiekills"}) do
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

net.Receive("DemocracyPlayerVoted", function(ln, ply)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            return
        end
    end

    local votee = net.ReadString()
    local num
    for k, v in pairs(votableplayers) do
        if v:Nick() == votee then --find which player was voted for
            playersvoted[ply] = v --insert player and target into table

            for _, va in pairs(player.GetAll()) do
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

net.Receive("DemocracyJesterVoted", function(ln, ply)
    local votee = net.ReadString()
    for _, v in pairs(votableplayers) do
        -- Find which player was voted for and kill them
        if v:Nick() == votee then
            v:Kill()

            for _, va in pairs(player.GetAll()) do
                va:PrintMessage(HUD_PRINTTALK, ply:Nick().." has decided to take revenge on "..votee.." for their vote")
            end
            return
        end
    end
end)

function ClearTable(table)
    for k, v in pairs(table) do
        table[k] = nil
    end
end

Randomat:register(EVENT)