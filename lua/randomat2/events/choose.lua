local EVENT = {}

util.AddNetworkString("ChooseEventTrigger")
util.AddNetworkString("ChooseVoteTrigger")
util.AddNetworkString("ChooseEventEnd")
util.AddNetworkString("ChoosePlayerChose")
util.AddNetworkString("ChoosePlayerVoted")

CreateConVar("randomat_choose_choices", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of events you can choose from", 2, 5)
CreateConVar("randomat_choose_vote", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allows all players to vote on the event")
CreateConVar("randomat_choose_votetimer", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long players have to vote on the event", 5, 60)
CreateConVar("randomat_choose_deadvoters", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Dead people can vote")
CreateConVar("randomat_choose_limitchoosetime", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether single player choosing has limited time")
CreateConVar("randomat_choose_limitchoosetime_random", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to choose a random event if time runs out")

local EventChoices = {}
local owner = nil
local allow_dead = false

local EventVotes = {}
local PlayersVoted = {}

local function GetEventDescription(choosetimer)
    local target
    local extra = ""
    if GetConVar("randomat_choose_vote"):GetBool() then
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

function EVENT:Begin(vote, dead_can_vote, vote_predicate)
    local votetimer = GetConVar("randomat_choose_votetimer"):GetInt()
    local limitchoosetime = GetConVar("randomat_choose_limitchoosetime"):GetBool()
    local limitchoosetime_random = GetConVar("randomat_choose_limitchoosetime_random"):GetBool()
    owner = self.owner
    allow_dead = dead_can_vote
    EVENT.Description = GetEventDescription(limitchoosetime and votetimer or 0)

    EventChoices = {}
    PlayersVoted = {}
    EventVotes = {}
    local choices = GetConVar("randomat_choose_choices"):GetInt()
    local x = 0
    for _, v in RandomPairs(Randomat.Events) do
        if x < choices then
            if Randomat:CanEventRun(v) and v.id ~= self.id and not v.StartSecret then
                x = x+1
                local title = Randomat:GetEventTitle(v)
                EventChoices[x] = {
                    title = title,
                    id = v.id
                }
                EventVotes[v.id] = 0
            end
        end
    end

    if vote or GetConVar("randomat_choose_vote"):GetBool() then
        net.Start("ChooseVoteTrigger")
        net.WriteInt(choices, 32)
        net.WriteTable(EventChoices)
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
            Randomat:TriggerEvent(evnt, owner)
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
        net.WriteTable(EventChoices)
        net.Send(owner)

        if limitchoosetime then
            timer.Create("RdmtChooseTimer", votetimer, 1, function()
                local message = "You took too long to choose!"
                if limitchoosetime_random then
                    message = message .. " Choosing a random one for you..."
                    local choice = EventChoices[math.random(1, #EventChoices)]
                    StartEventByTitle(choice)
                end
                owner:PrintMessage(HUD_PRINTTALK, message)
                owner:PrintMessage(HUD_PRINTCENTER, message)
                net.Start("ChooseEventEnd")
                net.Send(owner)
            end)
        end
    end
end

function EVENT:End()
    timer.Remove("RdmtChooseVoteTimer")
    timer.Remove("RdmtChooseTimer")

    if owner == nil then return end
    net.Start("ChooseEventEnd")
    net.Broadcast()
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
    for _, v in ipairs({"vote", "deadvoters", "limitchoosetime", "limitchoosetime_random"}) do
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
    Randomat:TriggerEvent(str, owner)
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