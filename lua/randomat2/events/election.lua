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

CreateConVar("randomat_election_timer", 40, FCVAR_NONE, "The number of seconds each round of voting lasts", 30, 180)
CreateConVar("randomat_election_winner_credits", 2, FCVAR_NONE, "The number of credits given as a reward, if appropriate", 1, 10)
CreateConVar("randomat_election_vamp_turn_innocents", 0, FCVAR_NONE, "Whether Vampires turn innocents. Otherwise, turns traitors")
CreateConVar("randomat_election_show_votes", 1, FCVAR_NONE, "Whether to show when a target is voted for in chat")
CreateConVar("randomat_election_show_votes_anon", 0, FCVAR_NONE, "Whether to hide who voted in chat")
CreateConVar("randomat_election_trigger_mrpresident", 0, FCVAR_NONE, "Whether to trigger Get Down Mr. President if an Innocent wins")
CreateConVar("randomat_election_break_ties", 0, FCVAR_NONE, "Whether to break ties by choosing a random winner")

EVENT.Title = "Election Day"
EVENT.Description = "Nominate and then elect players to become President. Each role gets a different reward for being elected"
EVENT.id = "election"
EVENT.Type = {EVENT_TYPE_VOTING, EVENT_TYPE_RESPAWN}
EVENT.Categories = {"rolechange", "eventtrigger", "largeimpact"}

local playersvoted = {}
local votableplayers = {}
local playervotes = {}

local function ResetVotes()
    table.Empty(playersvoted)

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
                ResetVotes()
            end
        end
    end)
end

local function ResetNominations()
    table.Empty(playersvoted)

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
        local winnerRole = winner:GetRole()
        -- Just in case
        if winnerRole == -1 then
            Randomat:EndActiveEvent(self.id)
            return
        end

        -- Innocent - Promote to Detective, give credits
        if Randomat:IsInnocentTeam(winner) then
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
            self:SmallNotify("The President is " .. self:GetRoleName(winner):lower() .. "! Their team has been paid for their support.")

            for _, v in ipairs(self:GetAlivePlayers()) do
                if Randomat:IsTraitorTeam(v) then
                    v:AddCredits(credits)
                end
            end
        -- Jester Team
        -- Barrel Mimic - Wins by killing someone with their barrel but we can't really do that so... they just win I guess
        elseif winnerRole == ROLE_BARRELMIMIC then
            Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You were elected by your peers and no longer feel the need to explode to win... you can just relax =)")
            net.Start("TTT_UpdateBarrelMimicWins")
            net.Broadcast()
        -- Beggar/Hermit - Give a random buyable weapon to have them join a random team
        elseif winnerRole == ROLE_BEGGAR or winnerRole == ROLE_HERMIT then
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
                -- Set the "BoughtBy" property to the found user to make this beggar join their team
                if IsValid(wep) and WEPS.GetClass(wep) == given and winner == ply then
                    wep.BoughtBy = source
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
        -- Bodysnatcher - Choose the role of a random dead player (or a random enabled role if none are dead) and give it to the bodysnatcher
        elseif winnerRole == ROLE_BODYSNATCHER then
            local role = nil
            for _, ply in ipairs(self:GetDeadPlayers(true)) do
                role = ply:GetRole()
                break
            end

            -- If there are no dead players, get a random enabled role
            if not role then
                local hasIndependent = false
                for _, ply in ipairs(self:GetAlivePlayers()) do
                    if Randomat:IsIndependentTeam(ply) or Randomat:IsJesterTeam(ply) then
                        hasIndependent = true
                        break
                    end
                end

                local roles = {}
                for r = 0, ROLE_MAX do
                    -- Don't make them another jester and if there is already an independent, don't choose one of those either
                    if not JESTER_ROLES[r] and (not hasIndependent or not INDEPENDENT_ROLES[r]) then
                        if Randomat:CanRoleSpawn(r) then
                            table.insert(roles, r)
                        end
                    end
                end

                role = roles[math.random(#roles)]
            end

            Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You have pulled the knowledge how of to be " .. ROLE_STRINGS_EXT[role] .. " from the ether.")

            self:StripRoleWeapons(winner)
            Randomat:SetRole(winner, role)
            SendFullStateUpdate()

            -- Make sure they get their loadout weapons
            hook.Call("PlayerLoadout", GAMEMODE, winner)
        -- Boxer - Wins by knocking everyone out after they are activated, knock out everyone that voted for them
        elseif winnerRole == ROLE_BOXER then
            if winner:Alive() and not winner:IsSpec() then
                -- Find the people who voted for this person but ignore the winner themselves
                for voter, votee in pairs(playersvoted) do
                    if votee ~= winner then continue end
                    if voter == winner then continue end
                    if not voter:Alive() or voter:IsSpec() then continue end
                    voter:BoxerKnockout()
                    Randomat:PrintMessage(voter, MSG_PRINTBOTH, "You have been knocked out by " .. winner:Nick() .. "!")
                end
            end
        -- Cannibal - Wins by eating everyone remaining, so eat everyone who voted for them
        elseif winnerRole == ROLE_CANNIBAL then
            if winner:Alive() and not winner:IsSpec() then
                local eatSounds = {
                    "cannibal/eat1.wav",
                    "cannibal/eat2.wav",
                    "cannibal/eat3.wav"
                }
                -- Find the people who voted for this person but ignore the winner themselves
                for voter, votee in pairs(playersvoted) do
                    if votee ~= winner then continue end
                    if voter == winner then continue end
                    if not voter:Alive() or voter:IsSpec() then continue end

                    voter:Spectate(OBS_MODE_CHASE)
                    voter:SpectateEntity(winner)
                    voter:DrawViewModel(false)
                    voter:DrawWorldModel(false)

                    local sID64 = voter:SteamID64()

                    CANNIBAL.playerWeapons[sID64] = {}

                    for _, v in pairs(voter:GetWeapons()) do
                        local class = WEPS.GetClass(v)
                        table.insert(CANNIBAL.playerWeapons[sID64], {
                            class = class,
                            clip1 = v:Clip1(),
                            clip2 = v:Clip2(),
                            PAPUpgrade = v.PAPUpgrade
                        })
                        voter:StripWeapon(class)
                    end

                    voter:SetFOV(0, 0.2)

                    voter:SetProperty("TTTCannibalEaten", winner:SteamID64())
                    Randomat:PrintMessage(voter, MSG_PRINTBOTH, "You have been eaten by " .. winner:Nick() .. "!")

                    winner:EmitSound(eatSounds[math.random(1, #eatSounds)], 100)
                end
            end
        -- Clown/Detectoclown - Kill all of the larger team so they activate immediately
        elseif winnerRole == ROLE_CLOWN or winnerRole == ROLE_DETECTOCLOWN then
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
                    sacrifice = innocents[math.random(#innocents)]
                else
                    sacrifice = traitors[math.random(#traitors)]
                end

                self:SmallNotify("The President is " .. self:GetRoleName(winner):lower() .. "! " .. sacrifice:Nick() .. " has been sacrificed to make their victory easier.")
                sacrifice:Kill()
            else
                local largest
                local teamName
                if innocentCount > traitorCount then
                    largest = innocents
                    teamName = "innocent"
                elseif traitorCount > innocentCount then
                    largest = traitors
                    teamName = "traitor"
                elseif math.random(0, 1) == 0 then
                    largest = innocents
                    teamName = "innocent"
                else
                    largest = traitors
                    teamName = "traitor"
                end

                self:SmallNotify("The President is " .. self:GetRoleName(winner):lower() .. "! The " .. teamName .. " team has been sacrificed to make their victory easier.")
                for _, v in ipairs(largest) do
                    v:Kill()
                end
            end
        -- Cupid - Wins by their lovers winning, so double the lovers' health and heal them (or respawn them if they are dead)
        elseif winnerRole == ROLE_CUPID then
            local target1 = player.GetBySteamID64(winner:GetNWString("TTTCupidTarget1", ""))
            local target2 = player.GetBySteamID64(winner:GetNWString("TTTCupidTarget2", ""))
            if IsPlayer(target1) and IsPlayer(target2) then
                -- If the lovers are alive, double their max health and heal them, otherwise respawn them
                if target1:Alive() and not target1:IsSpec() then
                    target1:SetMaxHealth(target1:GetMaxHealth() * 2)
                    target1:SetHealth(target1:GetMaxHealth())
                else
                    local body = target1.server_ragdoll or target1:GetRagdollEntity()
                    -- Destroy their old body
                    if IsValid(body) then
                        body:Remove()
                    end
                    target1:SpawnForRound(true)
                end

                if target2:Alive() and not target2:IsSpec() then
                    target2:SetMaxHealth(target2:GetMaxHealth() * 2)
                    target2:SetHealth(target2:GetMaxHealth())
                else
                    local body = target2.server_ragdoll or target2:GetRagdollEntity()
                    -- Destroy their old body
                    if IsValid(body) then
                        body:Remove()
                    end
                    target2:SpawnForRound(true)
                end

                SendFullStateUpdate()
            end
        -- Faker - Wins by using enough fake weapons, give them a fake count (to get them closer to a win) and more credits
        elseif winnerRole == ROLE_FAKER then
            winner:SetNWInt("FakerFakeCount", winner:GetNWInt("FakerFakeCount", 0) + 1)
            winner:AddCredits(credits)
            Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You've used your influence as President to further your goals (and line your pockets)!")
        -- Guesser - Wins by switching to a different role, swap roles with one of their voters
        elseif winnerRole == ROLE_GUESSER then
            local voters = {}
            for voter, votee in pairs(playersvoted) do
                -- Find the people who voted for this person but ignore the winner themselves
                if votee == winner and voter ~= winner then
                    table.insert(voters, voter)
                end
            end

            for _, v in player.Iterator() do
                v:SetNWFloat("TTTGuesserDamageDealt", 0)
            end

            local chosen = voters[math.random(#voters)]

            winner:SetNWBool("TTTGuesserWasGuesser", true)
            Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You have taken " .. chosen:Nick() .. "'s place!")
            hook.Call("TTTPlayerRoleChangedByItem", nil, winner, winner, self)

            chosen:SetNWString("TTTGuesserGuessedBy", winner:Nick())
            Randomat:PrintMessage(chosen, MSG_PRINTBOTH, "Your role was guessed by " .. ROLE_STRINGS_EXT[ROLE_GUESSER] .. " and you have taken their place!")
            hook.Call("TTTPlayerRoleChangedByItem", nil, winner, chosen, self)

            chosen:MoveRoleState(winner)


            self:StripRoleWeapons(winner)
            Randomat:SetRole(winner, chosen:GetRole())
            hook.Run("PlayerLoadout", winner)

            self:StripRoleWeapons(chosen)
            Randomat:SetRole(chosen, ROLE_GUESSER)
            hook.Run("PlayerLoadout", chosen)

            SendFullStateUpdate()

            net.Start("TTT_GuesserGuessed")
                net.WriteBool(true)
                net.WriteString(chosen:Nick())
                net.WriteString(winner:Nick())
            net.Broadcast()
        -- Loot Goblin - Wins by surviving, fully heal and double max health
        elseif winnerRole == ROLE_LOOTGOBLIN then
            if winner:Alive() and not winner:IsSpec() then
                winner:SetMaxHealth(winner:GetMaxHealth() * 2)
                winner:SetHealth(winner:GetMaxHealth())
                Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You feel healthier and more able to survive!")
            end
        -- Wheel Boy - Wins by spinning enough, reduce spin cooldown as far as possible without messing with spin already running
        elseif winnerRole == ROLE_WHEELBOY then
            local wheel_time = GetConVar("ttt_wheelboy_wheel_time"):GetInt()
            local recharge_time = GetConVar("ttt_wheelboy_wheel_recharge_time"):GetInt()
            local wait_time = GetConVar("ttt_wheelboy_wheel_end_wait_time"):GetInt()
            local nextSpinTime = winner:GetNWInt("WheelBoyNextSpinTime", 0)
            local totalTime = wheel_time + wait_time

            local curTime = CurTime()
            local remaining = nextSpinTime - curTime
            local elapsed = recharge_time - remaining
            local remainingSpinTime = totalTime - elapsed

            -- If enough time has passed that the wheel has already finished spinning
            -- then set the next spin to now so they can spin immediately
            if remainingSpinTime <= 0 then
                winner:SetNWInt("WheelBoyNextSpinTime", curTime)
                Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You have regained your strength and can spin again!")
            -- Otherwise set it to let them spin as soon as the wheel finishes spinning
            else
                winner:SetNWInt("WheelBoyNextSpinTime", curTime + remainingSpinTime)
                Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You have regained some of your strength so you can spin sooner.")
            end
        -- Jester - Kill them, winning the round
        -- Sponge - Kill them, winning the round
        -- Swapper - Kill them with a random player as the "attacker", swapping their roles
        -- Other Jesters - Kill them, hope that it triggers something
        elseif Randomat:IsJesterTeam(winner) then
            local voters = {}
            for voter, votee in pairs(playersvoted) do
                -- Find the people who voted for this person but ignore the winner themselves
                if votee == winner and voter ~= winner then
                    table.insert(voters, voter)
                end
            end
            local attacker = voters[math.random(#voters)]

            local dmginfo = DamageInfo()
            dmginfo:SetDamage(10000)
            dmginfo:SetAttacker(attacker)
            dmginfo:SetInflictor(game.GetWorld())
            dmginfo:SetDamageType(DMG_BULLET)
            dmginfo:SetDamageForce(Vector(0, 0, 0))
            dmginfo:SetDamagePosition(attacker:GetPos())
            winner:TakeDamageInfo(dmginfo)
        -- Independents
        -- Drunk - Have the drunk immediately remember their role
        elseif winnerRole == ROLE_DRUNK then
            if cvars.Bool("ttt_drunk_become_clown", false) then
                winner:DrunkRememberRole(ROLE_CLOWN, true)
            elseif winner.SoberDrunk then
                winner:SoberDrunk()
            -- Fall back to default logic if we don't have the advanced drunk options
            else
                local role
                if math.random() > GetConVar("ttt_drunk_innocent_chance"):GetFloat() then
                    role = ROLE_TRAITOR
                    winner:SetCredits(GetConVar("ttt_credits_starting"):GetInt())
                else
                    role = ROLE_INNOCENT
                end

                winner:SetNWBool("WasDrunk", true)
                Randomat:SetRole(winner, role)
                Randomat:PrintMessage(winner, MSG_PRINTBOTH, "You have remembered that you are " .. ROLE_STRINGS_EXT[role] .. ".")

                net.Start("TTT_DrunkSober")
                net.WriteString(winner:Nick())
                net.WriteString(ROLE_STRINGS_EXT[role])
                net.Broadcast()

                SendFullStateUpdate()
            end

            if timer.Exists("drunkremember") then timer.Remove("drunkremember") end
            if timer.Exists("waitfordrunkrespawn") then timer.Remove("waitfordrunkrespawn") end
        -- Old Man - Silently start "Sudden Death" so everyone is on the same page
        elseif winnerRole == ROLE_OLDMAN then
            self:SmallNotify("The President is " .. self:GetRoleName(winner):lower() .. "! Their frailty has spread to the rest of you.")

            local health = GetConVar("ttt_oldman_starting_health"):GetInt()
            Randomat:SilentTriggerEvent("suddendeath", winner, health)
        -- Killer - Kill all non-Jesters/Swappers so they win the round
        elseif winnerRole == ROLE_KILLER then
            for _, v in ipairs(self:GetAlivePlayers()) do
                if v:GetRole() ~= ROLE_JESTER and v:GetRole() ~= ROLE_SWAPPER and v ~= winner then
                    v:Kill()
                end
            end
        -- Other Independents - Restore the target's max health to at least 100 and give them 25 HP
        -- If they don't have max health after the 25 HP bonus the heal them to their maximum instead
        elseif Randomat:IsIndependentTeam(winner) then
            local max = winner:GetMaxHealth()
            if max < 100 then
                max = 100
            end

            local hp = winner:Health() + 25
            if hp < max then
                hp = max
            end
            winner:SetMaxHealth(max)
            winner:SetHealth(hp)
        -- Monster Team
        -- Zombie - Silently trigger the RISE FROM YOUR GRAVE event
        elseif winnerRole == ROLE_ZOMBIE then
            self:SmallNotify("The President is " .. self:GetRoleName(winner):lower() .. "!")
            Randomat:SilentTriggerEvent("grave", winner)
        -- Vampire - Convert all of the configured team to vampires
        elseif winnerRole == ROLE_VAMPIRE then
            local turninnocents = GetConVar("randomat_election_vamp_turn_innocents"):GetBool()
            local teamName = turninnocents and "innocent" or "traitor"
            self:SmallNotify("The President is " .. self:GetRoleName(winner):lower() .. "! The " .. teamName .. " team has been converted to be their thralls.")

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
        -- Other Monsters - Convert a random dead player (or live player who voted for them) to that monster's role
        elseif Randomat:IsMonsterTeam(winner) then
            local target = nil
            for _, ply in ipairs(self:GetDeadPlayers(true)) do
                target = ply
                break
            end

            local context_str = ""

            -- Look through the list of players who voted for this person
            if not target then
                local voters = {}
                for voter, votee in pairs(playersvoted) do
                    -- Find the people who voted for this person but ignore the winner themselves
                    if votee == winner and voter ~= winner then
                        table.insert(voters, voter)
                    end
                end

                target = voters[math.random(#voters)]
                Randomat:PrintMessage(target, MSG_PRINTBOTH, "The president you voted for has recruited you to their legion of monsters")
            else
                context_str = "brought back from the dead and "
                Randomat:PrintMessage(target, MSG_PRINTBOTH, "You have been brought back to serve in the president's legion of monsters")
            end

            Randomat:PrintMessage(winner, MSG_PRINTBOTH, target:Nick() .. " has been " .. context_str .. "converted to your role")

            -- Convert the target to the winner's role
            Randomat:SetRole(target, winnerRole)
            -- If they were dead, respawn them
            if not target:Alive() or target:IsSpec() then
                local body = target.server_ragdoll or target:GetRagdollEntity()
                -- Destroy their old body
                if IsValid(body) then
                    body:Remove()
                end
                target:SpawnForRound(true)
            end
            SendFullStateUpdate()

            -- Make sure they get their loadout weapons
            hook.Call("PlayerLoadout", GAMEMODE, target)
        end

        Randomat:EndActiveEvent(self.id)
    end)
end

function EVENT:Begin()
    for k, v in player.Iterator() do
        if not (v:Alive() and v:IsSpec()) then
            votableplayers[k] = v
            playervotes[v:Nick()] = 0
        end
    end

    self:StartNominations()
end

function EVENT:End()
    ResetVotes()
    timer.Remove("ElectionNominateTimer")
    timer.Remove("ElectionVoteTimer")
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
    for _, v in ipairs({"vamp_turn_innocents", "show_votes", "show_votes_anon", "trigger_mrpresident", "break_ties"}) do
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

local function HandleVote(ply, message)
    for k, _ in pairs(playersvoted) do
        if k == ply then
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
            return
        end
    end

    local num = 0
    local votee = net.ReadString()
    for _, v in pairs(votableplayers) do
        if IsPlayer(v) and v:Nick() == votee then
            playersvoted[ply] = v
            playervotes[votee] = playervotes[votee] + 1
            num = playervotes[votee]

            if GetConVar("randomat_election_show_votes"):GetBool() then
                local anon = GetConVar("randomat_election_show_votes_anon"):GetBool()
                for _, va in player.Iterator() do
                    local name
                    if anon then
                        name = "Someone"
                    else
                        name = ply:Nick()
                    end
                    va:PrintMessage(HUD_PRINTTALK, name .. " has voted for " .. votee)
                end
            end
            break
        end
    end

    net.Start(message)
        net.WriteString(votee)
        net.WriteInt(num, 32)
    net.Broadcast()
end

net.Receive("ElectionNominateVoted", function(ln, ply)
    HandleVote(ply, "ElectionNominateVoted")
end)

net.Receive("ElectionVoteVoted", function(ln, ply)
    HandleVote(ply, "ElectionVoteVoted")
end)

Randomat:register(EVENT)