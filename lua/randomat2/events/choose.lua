local EVENT = {}

util.AddNetworkString("ChooseEventTrigger")
util.AddNetworkString("ChooseVoteTrigger")
util.AddNetworkString("ChooseEventEnd")
util.AddNetworkString("ChoosePlayerChose")
util.AddNetworkString("ChoosePlayerVoted")

CreateConVar("randomat_choose_choices", 3, FCVAR_NONE, "Number of events you can choose from", 2, 5)
CreateConVar("randomat_choose_vote", 0, FCVAR_NONE, "Allows all players to vote on the event")
CreateConVar("randomat_choose_votetimer", 10, FCVAR_NONE, "How long players have to vote on the event", 5, 60)
CreateConVar("randomat_choose_deadvoters", 0, FCVAR_NONE, "Dead people can vote")
CreateConVar("randomat_choose_secret", 0, FCVAR_NONE, "Whether to include secret events")
CreateConVar("randomat_choose_limitchoosetime", 0, FCVAR_NONE, "Whether single player choosing has limited time")
CreateConVar("randomat_choose_limitchoosetime_random", 0, FCVAR_NONE, "Whether to choose a random event if time runs out")

local EventChoices = {}
local owner = nil
local allow_dead = false

local EventVotes = {}
local PlayersVoted = {}

local function GetEventDescription(vote, choosetimer)
    local target
    local extra = ""
    if vote then
        target = "vote"
    else
        if IsValid(owner) then
            target = owner:Nick()
        else
            target = "someone"
        end
        if choosetimer > 0 then
            extra = " within " .. choosetimer .. " seconds"
        end
    end
    return "Presents random events to be chosen by " .. target .. extra
end

EVENT.Title = "Choose an Event!"
EVENT.Description = GetEventDescription(0)
EVENT.id = "choose"
EVENT.Categories = {"eventtrigger", "moderateimpact"}

local function StartEventAndAddToHistory(id)
    Randomat:TriggerEvent(id, owner)
    Randomat:AddEventToHistory(id)
end

local function GetVote(vote)
    if type(vote) ~= "boolean" then
        vote = GetConVar("randomat_choose_vote"):GetBool()
    end
    return vote
end

function EVENT:BeforeEventTrigger(ply, options, vote, dead_can_vote, vote_predicate, choices, choice_list)
    local votetimer = GetConVar("randomat_choose_votetimer"):GetInt()
    local limitchoosetime = GetConVar("randomat_choose_limitchoosetime"):GetBool()
    self.Description = GetEventDescription(GetVote(vote), limitchoosetime and votetimer or 0)
end

function EVENT:Begin(vote, dead_can_vote, vote_predicate, choices, choice_list)
    owner = self.owner

    vote = GetVote(vote)
    allow_dead = dead_can_vote
    choices = choices or GetConVar("randomat_choose_choices"):GetInt()

    local votetimer = GetConVar("randomat_choose_votetimer"):GetInt()
    local limitchoosetime = GetConVar("randomat_choose_limitchoosetime"):GetBool()
    local limitchoosetime_random = GetConVar("randomat_choose_limitchoosetime_random"):GetBool()

    EventChoices = {}
    PlayersVoted = {}
    EventVotes = {}
    local secret = GetConVar("randomat_choose_secret"):GetBool()
    for _, v in RandomPairs(Randomat.Events) do
        if #EventChoices >= choices then break end

        if v.id == self.id then continue end
        if not Randomat:CanEventRun(v) then continue end
        if choice_list and not table.HasValue(choice_list, v.id) then continue end

        local title = Randomat:GetEventTitle(v)

        -- If this is a secret event
        if v.StartSecret then
            -- Skip it if secret events are not enabled
            if not secret then continue end
            -- Otherwise use the title of "secret" so the actual event is hidden
            title = Randomat:GetEventTitle(Randomat.Events["secret"])
        end

        table.insert(EventChoices, {
            title = title,
            id = v.id
        })
        EventVotes[v.id] = 0
    end

    if vote then
        net.Start("ChooseVoteTrigger")
        net.WriteInt(choices, 32)
        net.WriteTable(EventChoices, true)
        if type(vote_predicate) == "function" then
            net.Send(GetPlayerFilter(vote_predicate))
        else
            net.Broadcast()
        end

        timer.Create("RdmtChooseVoteTimer", votetimer, 1, function()
            local vts = -1
            local evnt = ""
            for k, v in RandomPairs(EventVotes) do
                if vts < v then
                    vts = v
                    evnt = k
                end
            end
            StartEventAndAddToHistory(evnt)
            net.Start("ChooseEventEnd")
            if type(vote_predicate) == "function" then
                net.Send(GetPlayerFilter(vote_predicate))
            else
                net.Broadcast()
            end
            EventVotes = {}
        end)
    else
        net.Start("ChooseEventTrigger")
        net.WriteInt(choices, 32)
        net.WriteTable(EventChoices, true)
        net.Send(owner)

        if limitchoosetime then
            timer.Create("RdmtChooseTimer", votetimer, 1, function()
                local message = "You took too long to choose!"
                if limitchoosetime_random then
                    message = message .. " Choosing a random one for you..."
                    local choice = EventChoices[math.random(#EventChoices)]
                    StartEventAndAddToHistory(choice.id)
                end
                Randomat:PrintMessage(owner, MSG_PRINTBOTH, message)
                net.Start("ChooseEventEnd")
                net.Send(owner)
            end)
        end
    end
end

function EVENT:End()
    timer.Remove("RdmtChooseVoteTimer")
    timer.Remove("RdmtChooseTimer")
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"choices", "votetimer"}) do
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
    for _, v in ipairs({"vote", "deadvoters", "secret", "limitchoosetime", "limitchoosetime_random"}) do
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

net.Receive("ChoosePlayerChose", function()
    timer.Remove("RdmtChooseTimer")

    local str = net.ReadString()
    StartEventAndAddToHistory(str)
end)

net.Receive("ChoosePlayerVoted", function(ln, ply)
    local voted = false
    for _, v in pairs(PlayersVoted) do
        if v == ply then
            voted = true
            break
        end
    end

    if (ply:Alive() and not ply:IsSpec()) or allow_dead or GetConVar("randomat_choose_deadvoters"):GetBool() then
        if not voted then
            local str = net.ReadString()
            EventVotes[str] = EventVotes[str] + 1
            net.Start("ChoosePlayerVoted")
            net.WriteString(str)
            net.Broadcast()
            table.insert(PlayersVoted, ply)
        else
            ply:PrintMessage(HUD_PRINTTALK, "You have already voted.")
        end
    else
        ply:PrintMessage(HUD_PRINTTALK, "Dead players can't vote.")
    end
end)

Randomat:register(EVENT)