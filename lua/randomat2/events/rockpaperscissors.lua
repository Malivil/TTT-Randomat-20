local EVENT = {}

util.AddNetworkString("RockPaperScissorsEventBegin")
util.AddNetworkString("RdmtPlayerChoseRock")
util.AddNetworkString("RdmtPlayerChosePaper")
util.AddNetworkString("RdmtPlayerChoseScissors")

EVENT.Title = "Rock, Paper, Scissors"
EVENT.ExtDescription = "Pits two players against eachother in a Rock, Paper, Scissors fight to the death"
EVENT.id = "rockpaperscissors"
EVENT.Categories = {"gamemode", "largeimpact"}

CreateConVar("randomat_rockpaperscissors_bestof", 3, FCVAR_ARCHIVE, "How many rounds to play", 1, 5)
cvars.AddChangeCallback("randomat_rockpaperscissors_bestof", function(convar_name, value_old, value_new)
    -- If this value is even, subtract 1 to make it odd again
    if value_new % 2 == 0 then
        RunConsoleCommand("randomat_rockpaperscissors_bestof", value_new - 1)
    end
end)

local CHOSEN_NONE = "None"
local CHOSEN_ROCK = "Rock"
local CHOSEN_PAPER = "Paper"
local CHOSEN_SCISSORS = "Scissors"

local ply1 = nil
local ply2 = nil

local ply1_last_chosen
local ply2_last_chosen
local score
local rounds_total
local rounds_left

local function HandlePlayerDeath()
    local ply1_alive = ply1:Alive()
    local ply2_alive = ply2:Alive()

    if not ply1_alive and not ply2_alive then
        Randomat:EventNotify("Nobody wins Rock, Paper, Scissors!")
        Randomat:SmallNotify("Both players have died =(")
        Randomat:LogEvent("[RANDOMAT] Ending early because both players are dead")
    elseif not ply1_alive then
        Randomat:EventNotify(ply2:Nick() .. " wins Rock, Paper, Scissors!")
        Randomat:SmallNotify(ply1:Nick() .. " has died =(")
        Randomat:LogEvent("[RANDOMAT] Ending early because " .. ply1:Nick() .. " is dead")
    elseif not ply2_alive then
        Randomat:EventNotify(ply1:Nick() .. " wins Rock, Paper, Scissors!")
        Randomat:SmallNotify(ply2:Nick() .. " has died =(")
        Randomat:LogEvent("[RANDOMAT] Ending early because " .. ply2:Nick() .. " is dead")
    end
end

function EVENT:Begin()
    local players = self:GetAlivePlayers(true)
    ply1 = players[1]
    ply2 = players[2]

    ply1_last_chosen = CHOSEN_NONE
    ply2_last_chosen = CHOSEN_NONE
    score = 0
    rounds_total = GetConVar("randomat_rockpaperscissors_bestof"):GetInt()
    rounds_left = rounds_total
    self.Description = ply1:Nick() .. " vs. " .. ply2:Nick() .. "! Best of " .. rounds_left .. ", TO THE DEATH!"

    net.Start("RockPaperScissorsEventBegin")
    net.Send(ply1)
    net.Start("RockPaperScissorsEventBegin")
    net.Send(ply2)

    net.Receive("RdmtPlayerChoseRock", function()
        local steam64 = net.ReadUInt64()
        self:HandleRound(steam64, CHOSEN_ROCK)
    end)

    net.Receive("RdmtPlayerChosePaper", function()
        local steam64 = net.ReadUInt64()
        self:HandleRound(steam64, CHOSEN_PAPER)
    end)

    net.Receive("RdmtPlayerChoseScissors", function()
        local steam64 = net.ReadUInt64()
        self:HandleRound(steam64, CHOSEN_SCISSORS)
    end)

    -- If one of the players is dead, score the round and end the game that way
    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or (victim ~= ply1 and victim ~= ply2) then return end
        HandlePlayerDeath()
        self:RemoveHook("PlayerDeath")
        self:End()
    end)
end

function EVENT:End()
    timer.Remove("RdmtRockPaperScissorsEndMessageTimer")
    timer.Remove("RdmtRockPaperScissorsEndScoreTimer")
    timer.Remove("RdmtRockPaperScissorsEndSoulTimer")
    timer.Remove("RdmtRockPaperScissorsNextRoundMessageTimer")
    timer.Remove("RdmtRockPaperScissorsNextRoundTimer")
end

function EVENT:Condition()
    for _, v in ipairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_JESTER then
            return false
        end
    end

    return true
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"bestof"}) do
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

    return sliders
end

local function KillPlayer(winner, loser)
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(10000)
    dmginfo:SetAttacker(winner)
    dmginfo:SetInflictor(game.GetWorld())
    dmginfo:SetDamageType(DMG_BULLET)
    dmginfo:SetDamageForce(Vector(0, 0, 0))
    dmginfo:SetDamagePosition(winner:GetPos())
    loser:TakeDamageInfo(dmginfo)
end

function EVENT:ScoreRound()
    if ply1_last_chosen ~= ply2_last_chosen then
        local ply1_wins = true
        if ply1_last_chosen == CHOSEN_ROCK then
            -- Paper beats rock, Player 2 wins
            if ply2_last_chosen == CHOSEN_PAPER then
                ply1_wins = false
            end
            -- Otherwise, rock beats scissors and Player 1 wins
        elseif ply1_last_chosen == CHOSEN_PAPER then
            -- Scissors beats paper, Player 2 wins
            if ply2_last_chosen == CHOSEN_SCISSORS then
                ply1_wins = false
            end
            -- Otherwise paper beats rock and Player 1 wins
        elseif ply1_last_chosen == CHOSEN_SCISSORS then
            -- Rock beats scissors, Player 2 wins
            if ply2_last_chosen == CHOSEN_ROCK then
                ply1_wins = false
            end
            -- Otherwise, scissors beats paper and Player 1 wins
        end

        Randomat:SmallNotify(ply1_last_chosen .. " vs. " .. ply2_last_chosen)
        -- Positive score means Player 1 is winning, negative means Player 2 is winning
        if ply1_wins then
            Randomat:EventNotifySilent(ply1:Nick() .. " wins this round!")
            Randomat:LogEvent("[RANDOMAT] " .. ply1:Nick() .. " won round " .. (rounds_total - rounds_left) + 1 .. " (" .. ply1_last_chosen .. " vs. " .. ply2_last_chosen .. ")")
            score = score + 1
        else
            Randomat:EventNotifySilent(ply2:Nick() .. " wins this round!")
            Randomat:LogEvent("[RANDOMAT] " .. ply2:Nick() .. " won round " .. (rounds_total - rounds_left) + 1 .. " (" .. ply1_last_chosen .. " vs. " .. ply2_last_chosen .. ")")
            score = score - 1
        end
    else
        Randomat:EventNotify("This round was a tie!")
        Randomat:LogEvent("[RANDOMAT] Round " .. (rounds_total - rounds_left) + 1 .. " was a tie! Both players chose " .. ply1_last_chosen)
    end

    ply1_last_chosen = CHOSEN_NONE
    ply2_last_chosen = CHOSEN_NONE
    rounds_left = rounds_left - 1

    local point_of_no_return = (rounds_total / 2)
    -- If one player's score is past 1/2 of the total rounds, there's no point in playing the rest of the rounds
    if math.abs(score) > point_of_no_return then
        rounds_left = 0
        Randomat:LogEvent("[RANDOMAT] Ending early because one player has won a majority (" .. point_of_no_return .. ") of the rounds")
    end

    -- If there are more rounds left, wait a few seconds and then start the next round
    if rounds_left > 0 then
        timer.Create("RdmtRockPaperScissorsNextRoundMessageTimer", 5, 1, function()
            Randomat:SmallNotify("Starting the next round shortly...", 3)
            timer.Create("RdmtRockPaperScissorsNextRoundTimer", 3, 1, function()
                net.Start("RockPaperScissorsEventBegin")
                net.Send(ply1)
                net.Start("RockPaperScissorsEventBegin")
                net.Send(ply2)
            end)
        end)
        return
    end

    timer.Create("RdmtRockPaperScissorsEndMessageTimer", 5, 1, function()
        Randomat:SmallNotify("Game over... checking the scores!", 3)
        timer.Create("RdmtRockPaperScissorsEndScoreTimer", 3, 1, function()
            -- Stop tracking player deaths since the game is now over
            self:RemoveHook("PlayerDeath")

            -- Player 1 wins
            if score > 0 then
                Randomat:EventNotify(ply1:Nick() .. " wins Rock, Paper, Scissors!")
                Randomat:SmallNotify(ply2:Nick() .. " has been killed")
                Randomat:LogEvent("[RANDOMAT] " .. ply1:Nick() .. " wins Rock, Paper, Scissors!")
                KillPlayer(ply1, ply2)
            -- Player 2 wins
            elseif score < 0 then
                Randomat:EventNotify(ply2:Nick() .. " wins Rock, Paper, Scissors!")
                Randomat:SmallNotify(ply1:Nick() .. " has been killed")
                Randomat:LogEvent("[RANDOMAT] " .. ply2:Nick() .. " wins Rock, Paper, Scissors!")
                KillPlayer(ply2, ply1)
            -- It's a tie!
            else
                Randomat:EventNotifySilent("It's a Rock, Paper, Scissors tie!")
                Randomat:SmallNotify("As a result, both players are forever bound!")
                Randomat:LogEvent("[RANDOMAT] Rock, Paper, Scissors ended in a tie!")
                timer.Create("RdmtRockPaperScissorsEndSoulTimer", 5, 1, function()
                    -- Start the "Soul Mates" event after a short delay
                    Randomat:SafeTriggerEvent("soulmates", self.owner, false, ply1, ply2)
                end)
            end
        end)
    end)
end

function EVENT:CheckRound()
    if ply1_last_chosen == CHOSEN_NONE or ply2_last_chosen == CHOSEN_NONE then return end
    self:ScoreRound()
end

function EVENT:HandleRound(steam64, chosen)
    if ply1:SteamID64() == steam64 then
        if ply1_last_chosen ~= CHOSEN_NONE then
            ply1:PrintMessage(HUD_PRINTTALK, "You have already played this round!")
            return
        end
        Randomat:LogEvent("[RANDOMAT] " .. ply1:Nick() .. " chose " .. chosen)
        ply1_last_chosen = chosen
    elseif ply2:SteamID64() == steam64 then
        if ply2_last_chosen ~= CHOSEN_NONE then
            ply2:PrintMessage(HUD_PRINTTALK, "You have already played this round!")
            return
        end
        Randomat:LogEvent("[RANDOMAT] " .. ply2:Nick() .. " chose " .. chosen)
        ply2_last_chosen = chosen
    else
        -- Who even is this?
        return
    end

    self:CheckRound()
end

Randomat:register(EVENT)