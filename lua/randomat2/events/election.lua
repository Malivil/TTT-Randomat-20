local EVENT = {}

util.AddNetworkString("ElectionNominateBegin")
util.AddNetworkString("ElectionNominateVoted")
util.AddNetworkString("ElectionNominateReset")
util.AddNetworkString("ElectionNominateEnd")
util.AddNetworkString("ElectionVoteBegin")
util.AddNetworkString("ElectionVoteVoted")
util.AddNetworkString("ElectionVoteReset")
util.AddNetworkString("ElectionVoteEnd")
util.AddNetworkString("TTT_DrunkSober")

CreateConVar("randomat_election_timer", 40, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of seconds each round of voting lasts", 30, 180)
CreateConVar("randomat_election_winner_credits", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of credits given as a reward, if appropriate", 1, 10)
CreateConVar("randomat_election_vamp_turn_innocents", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether Vampires turn innocents. Otherwise, turns traitors")
CreateConVar("randomat_election_show_votes", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to show who each player voted for in chat")
CreateConVar("randomat_election_trigger_mrpresident", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to trigger Get Down Mr. President if an Innocent wins")
CreateConVar("randomat_election_break_ties", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether to break ties by choosing a random winner")

EVENT.Title = "Election Day"
EVENT.Description = "Nominate and then elect players to become President. Each role gets a different reward for being elected"
EVENT.id = "election"

local playersvoted = {}
local votableplayers = {}
local playervotes = {}

local function ClearTable(table)
    for k, _ in pairs(table) do
        table[k] = nil
    end
end

local function ResetVotes()
    ClearTable(playersvoted)

    net.Start("ElectionVoteReset")
    net.Broadcast()

    for k, _ in pairs(playervotes) do
        playervotes[k] = 0
    end
end

function EVENT:StartVotes(first, second)
    self:SmallNotify("Nominations are complete. Time to vote for President!")

    net.Start("ElectionVoteBegin")
        net.WriteString(first)
        net.WriteString(second)
    net.Broadcast()

    local electiontime = GetConVar("randomat_election_timer"):GetInt()
    local ticks = 0
    timer.Create("ElectionVoteTimer", 1, 0, function()
        ticks = ticks + 1
        if electiontime > 19 and ticks == electiontime - 10 then
            self:SmallNotify("10 seconds left on voting!")
        elseif ticks == electiontime then
            ticks = 0
            local votecount = 0
            for _, v in pairs(playervotes) do
                votecount = votecount + v
            end

            if votecount > 0 then
                -- Get the top two candidates by the vote count
                local firstcandidate = nil
                local firstvotes = -1
                local secondcandidate = nil
                local secondvotes = -1
                for k, v in SortedPairsByValue(playervotes, true) do
                    if firstvotes < 0 then
                        firstcandidate = k
                        firstvotes = v
                    elseif secondvotes < 0 then
                        secondcandidate = k
                        secondvotes = v
                    end
                end

                local winner = firstcandidate

                -- Make sure there isn't a tie
                if firstvotes == secondvotes then
                    if GetConVar("randomat_election_break_ties"):GetBool() then
                        if math.random(2) == 1 then
                            winner = firstcandidate
                        else
                            winner = secondcandidate
                        end
                    else
                        self:SmallNotify("There was a tie! A new round of voting will begin.")
                        ResetVotes()
                        return
                    end
                end

                timer.Remove("ElectionVoteTimer")
                net.Start("ElectionVoteEnd")
                net.Broadcast()

                -- Swear the president in
                for _, v in pairs(votableplayers) do
                    if v:Nick() == winner then
                        self:SwearIn(v)
                        break
                    end
                end
            else
                self:SmallNotify("Nobody was voted for. A new round of voting will begin.")
            end

            ResetVotes()
        end
    end)
end

local function ResetNominations()
    ClearTable(playersvoted)

    net.Start("ElectionNominateReset")
    net.Broadcast()

    for k, _ in pairs(playervotes) do
        playervotes[k] = 0
    end
end

function EVENT:StartNominations()
    net.Start("ElectionNominateBegin")
    net.Broadcast()

    local electiontime = GetConVar("randomat_election_timer"):GetInt()
    local ticks = 0
    timer.Create("ElectionNominateTimer", 1, 0, function()
        ticks = ticks + 1
        if electiontime > 19 and ticks == electiontime - 10 then
            self:SmallNotify("10 seconds left on voting!")
        elseif ticks == electiontime then
            ticks = 0
            local nominationcount = 0
            -- Only count players with at least one vote
            for _, v in pairs(playervotes) do
                if v > 0 then
                    nominationcount = nominationcount + 1
                end
            end

            -- There has to be at least 2 players nominated to continue
            if nominationcount > 1 then
                -- Get the top three nominations by the vote count
                local first = nil
                local firstvotes = -1
                local second = nil
                local secondvotes = -1
                local thirdvotes = -1
                for k, v in SortedPairsByValue(playervotes, true) do
                    if firstvotes < 0 then
                        first = k
                        firstvotes = v
                    elseif secondvotes < 0 then
                        second = k
                        secondvotes = v
                    elseif thirdvotes < 0 then
                        thirdvotes = v
                    end
                end

                -- If there are more than 2 nominations, make sure there isn't a tie
                if nominationcount > 2 and (firstvotes == secondvotes or secondvotes == thirdvotes) then
                    -- If either of the top pairs matches, that means there is a tie (at least 2-way, if not 3-way)
                    self:SmallNotify("There was a tie! A new round of voting will begin.")
                    ResetNominations()
                    return
                end

                timer.Remove("ElectionNominateTimer")
                net.Start("ElectionNominateEnd")
                net.Broadcast()

                -- Start vote for president
                self:StartVotes(first, second)
            else
                self:SmallNotify("Too few players were nominated. A new round of voting will begin.")
            end

            ResetNominations()
        end
    end)
end

function EVENT:SwearIn(winner)
    self:SmallNotify(winner:Nick() .. " has been elected President!", 3)

    local credits = GetConVar("randomat_election_winner_credits"):GetInt()
    -- Wait 3 seconds before applying the affect
    timer.Simple(3, function()
        -- Drunk - Have the drunk immediately remember their role
        if winner:GetRole() == ROLE_DRUNK then
            if math.random() <= GetConVar("ttt_drunk_innocent_chance"):GetFloat() then
                winner:SetRole(ROLE_INNOCENT)
                winner:SetNWBool("WasDrunk", true)
                winner:PrintMessage(HUD_PRINTTALK, "You have remembered that you are an innocent.")
                winner:PrintMessage(HUD_PRINTCENTER, "You have remembered that you are an innocent.")

                net.Start("TTT_DrunkSober")
                net.WriteString(winner:Nick())
                net.WriteString("an innocent")
                net.Broadcast()
            else
                winner:SetRole(ROLE_TRAITOR)
                winner:SetNWBool("WasDrunk", true)
                winner:SetCredits(GetConVar("ttt_credits_starting"):GetInt())
                winner:PrintMessage(HUD_PRINTTALK, "You have remembered that you are a traitor.")
                winner:PrintMessage(HUD_PRINTCENTER, "You have remembered that you are a traitor.")

                net.Start("TTT_DrunkSober")
                net.WriteString(winner:Nick())
                net.WriteString("a traitor")
                net.Broadcast()
            end

            SendFullStateUpdate()
        -- Old Man - Silently start "Sudden Death" so everyone is on the same page
        elseif winner:GetRole() == ROLE_OLDMAN then
            self:SmallNotify("The President is " .. string.lower(self:GetRoleName(winner)) .. "! Their frailty has spread to the rest of you.")

            local health
            -- TODO: Remove this version check after 1.0.3 is pushed to release
            if CRVersion("1.0.3") then
                health = GetConVar("ttt_oldman_starting_health"):GetInt()
            else
                health = GetConVar("ttt_old_man_starting_health"):GetInt()
            end

            Randomat:SilentTriggerEvent("suddendeath", winner, health)
        -- Innocent - Promote to Detective, give credits
        elseif Randomat:IsInnocentTeam(winner) then
            Randomat:SetRole(winner, ROLE_DETECTIVE)
            winner:AddCredits(credits)
            SendFullStateUpdate()

            -- Trigger "Get Down Mr. President" with the winner as the target, if this feature is enabled
            -- This DOES expose Detraitors if people are paying attention -- This won't trigger if there is a Detraitor because that makes it too easy for them to win
            if GetConVar("randomat_election_trigger_mrpresident"):GetBool() then
                Randomat:SafeTriggerEvent("president", winner, false, winner)
            end
        -- Traitor - Announce their role, and give their whole team free credits
        elseif Randomat:IsTraitorTeam(winner) then
            self:SmallNotify("The President is " .. string.lower(self:GetRoleName(winner)) .. "! Their team has been paid for their support.")

            for _, v in ipairs(self:GetAlivePlayers()) do
                if Randomat:IsTraitorTeam(v) then
                    v:AddCredits(credits)
                end
            end
        -- Clown - Kill all of the larger team so the Clown activates immediately
        elseif winner:GetRole() == ROLE_CLOWN then
            local innocents = {}
            local traitors = {}
            for _, p in ipairs(self:GetAlivePlayers()) do
                if Randomat:IsInnocentTeam(p) then
                    table.insert(innocents, p)
                elseif Randomat:IsTraitorTeam(p) then
                    table.insert(traitors, p)
                end
            end

            local innocentCount = #innocents
            local traitorCount = #traitors

            -- If there is only one team left, kill a random player instead
            if innocentCount == 0 or traitorCount == 0 then
                local sacrifice
                if innocentCount ~= 0 then
                    sacrifice = innocents[math.random(1, #innocents)]
                else
                    sacrifice = traitors[math.random(1, #traitors)]
                end

                self:SmallNotify("The President is " .. string.lower(self:GetRoleName(winner)) .. "! " .. sacrifice:Nick() .. " has been sacrificed to make their victory easier.")
                sacrifice:Kill()
            else
                local largest
                local team
                if innocentCount > traitorCount then
                    largest = innocents
                    team = "innocent"
                elseif traitorCount > innocentCount then
                    largest = traitors
                    team = "traitor"
                elseif math.random(0, 1) == 0 then
                    largest = innocents
                    team = "innocent"
                else
                    largest = traitors
                    team = "traitor"
                end

                self:SmallNotify("The President is " .. string.lower(self:GetRoleName(winner)) .. "! The " .. team .. " team has been sacrificed to make their victory easier.")
                for _, v in ipairs(largest) do
                    v:Kill()
                end
            end
        -- Beggar - Give a random buyable weapon to have them join a random team
        elseif winner:GetRole() == ROLE_BEGGAR then
            local role
            local source
            -- Choose a role and find a person to represent that role
            if math.random(0, 1) == 0 then
                role = {ROLE_DETECTIVE}
                local found = nil
                for _, v in ipairs(self:GetAlivePlayers(true)) do
                    if Randomat:IsInnocentTeam(v) and (found == nil or v:GetRole() == ROLE_DETECTIVE) then
                        found = v
                    end
                end
                source = found
            else
                role = {ROLE_TRAITOR}
                local found = nil
                for _, v in ipairs(self:GetAlivePlayers(true)) do
                    if Randomat:IsTraitorTeam(v) and found == nil then
                        found = v
                        break
                    end
                end
                source = found
            end

            local given = nil
            self:AddHook("WeaponEquip", function(wep, ply)
                -- Set the "BoughtBuy" property to the found user to make this beggar join their team
                if IsValid(wep) and WEPS.GetClass(wep) == given and winner == ply then
                    wep.BoughtBuy = source
                    self:RemoveHook("WeaponEquip")
                end
            end)

            Randomat:GiveRandomShopItem(winner, {role}, {}, false,
                -- gettrackingvar
                function()
                    return winner.electionweptries
                end,
                -- settrackingvar
                function(value)
                    winner.electionweptries = value
                end,
                -- onitemgiven
                function(isequip, id)
                    given = id
                    Randomat:CallShopHooks(isequip, id, winner)
                end)
        -- Jester - Kill them, winning the round
        -- Swapper - Kill them with a random player as the "attacker", swapping their roles
        elseif Randomat:IsJesterTeam(winner) then
            local attacker = self.owner
            if winner:GetRole() == ROLE_SWAPPER or attacker == winner then
                repeat
                    attacker = self:GetAlivePlayers(true)[1]
                until attacker ~= winner
            end

            local dmginfo = DamageInfo()
            dmginfo:SetDamage(10000)
            dmginfo:SetAttacker(attacker)
            dmginfo:SetInflictor(game.GetWorld())
            dmginfo:SetDamageType(DMG_BULLET)
            dmginfo:SetDamageForce(Vector(0, 0, 0))
            dmginfo:SetDamagePosition(attacker:GetPos())
            winner:TakeDamageInfo(dmginfo)
        -- Killer - Kill all non-Jesters/Swappers so they win the round
        elseif winner:GetRole() == ROLE_KILLER then
            for _, v in ipairs(self:GetAlivePlayers()) do
                if v:GetRole() ~= ROLE_JESTER and v:GetRole() ~= ROLE_SWAPPER and v ~= winner then
                    v:Kill()
                end
            end
        -- Zombie - Silently trigger the RISE FROM YOUR GRAVE event
        elseif winner:GetRole() == ROLE_ZOMBIE then
            self:SmallNotify("The President is " .. string.lower(self:GetRoleName(winner)) .. "!")
            Randomat:SilentTriggerEvent("grave", winner)
        -- Vampire - Convert all of the configured team to vampires
        elseif winner:GetRole() == ROLE_VAMPIRE then
            local turninnocents = GetConVar("randomat_election_vamp_turn_innocents"):GetBool()
            local team = turninnocents and "innocent" or "traitor"
            self:SmallNotify("The President is " .. string.lower(self:GetRoleName(winner)) .. "! The " .. team .. " team has been converted to their thalls.")

            for _, v in ipairs(self:GetAlivePlayers()) do
                if turninnocents then
                    if Randomat:IsInnocentTeam(v) then
                        self:StripRoleWeapons(v)
                        Randomat:SetRole(v, ROLE_VAMPIRE)
                    end
                else
                    if Randomat:IsTraitorTeam(v) then
                        self:StripRoleWeapons(v)
                        Randomat:SetRole(v, ROLE_VAMPIRE)
                    end
                end
            end
            SendFullStateUpdate()
        end

        Randomat:EndActiveEvent(self.id)
    end)
end

function EVENT:Begin()
    for k, v in ipairs(player.GetAll()) do
        if not (v:Alive() and v:IsSpec()) then
            votableplayers[k] = v
            playervotes[v:Nick()] = 0
        end
    end

    self:StartNominations()
end

function EVENT:End()
    timer.Remove("ElectionNominateTimer")
    timer.Remove("ElectionVoteTimer")
    net.Start("ElectionNominateEnd")
    net.Broadcast()
    net.Start("ElectionVoteEnd")
    net.Broadcast()
end

function EVENT:Condition()
    return not Randomat:IsEventActive("democracy")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"timer", "winner_credits"}) do
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
    for _, v in ipairs({"vamp_turn_innocents", "show_votes", "trigger_mrpresident", "break_ties"}) do
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

net.Receive("ElectionNominateVoted", function(ln, ply)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            return
        end
    end

    local num = 0
    local votee = net.ReadString()
    for _, v in pairs(votableplayers) do
        if v:Nick() == votee then
            playersvoted[ply] = v
            playervotes[votee] = playervotes[votee] + 1
            num = playervotes[votee]

            if GetConVar("randomat_election_show_votes"):GetBool() then
                for _, va in ipairs(player.GetAll()) do
                    va:PrintMessage(HUD_PRINTTALK, ply:Nick().." has voted for "..votee)
                end
            end
        end
    end

    net.Start("ElectionNominateVoted")
        net.WriteString(votee)
        net.WriteInt(num, 32)
    net.Broadcast()
end)

net.Receive("ElectionVoteVoted", function(ln, ply)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            return
        end
    end

    local num = 0
    local votee = net.ReadString()
    for _, v in pairs(votableplayers) do
        if v:Nick() == votee then
            playersvoted[ply] = v
            playervotes[votee] = playervotes[votee] + 1
            num = playervotes[votee]

            if GetConVar("randomat_election_show_votes"):GetBool() then
                for _, va in ipairs(player.GetAll()) do
                    va:PrintMessage(HUD_PRINTTALK, ply:Nick().." has voted for "..votee)
                end
            end
        end
    end

    net.Start("ElectionVoteVoted")
        net.WriteString(votee)
        net.WriteInt(num, 32)
    net.Broadcast()
end)

Randomat:register(EVENT)