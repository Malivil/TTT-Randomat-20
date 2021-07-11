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

local EventChoices = {}
local owner = nil

local EventVotes = {}
local PlayersVoted = {}

local function GetEventDescription()
    local target
    if GetConVar("randomat_choose_vote"):GetBool() then
        target = "vote"
    elseif IsValid(owner) then
        target = owner:Nick()
    else
        target = "someone"
    end
    return "Presents random events to be chosen by " .. target
end

EVENT.Title = "Choose an Event!"
EVENT.Description = GetEventDescription()
EVENT.id = "choose"

function EVENT:Begin()
    owner = self.owner
    EVENT.Description = GetEventDescription()

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
                EventChoices[x] = title
                EventVotes[title] = 0
            end
        end
    end

    if GetConVar("randomat_choose_vote"):GetBool() then
        net.Start("ChooseVoteTrigger")
        net.WriteInt(choices, 32)
        net.WriteTable(EventChoices)
        net.Broadcast()

        timer.Create("RdmtChooseVoteTimer", GetConVar("randomat_choose_votetimer"):GetInt(), 1, function()
            local vts = -1
            local evnt = ""
            for k, v in RandomPairs(EventVotes) do
                if vts < v then
                    vts = v
                    evnt = k
                end
            end
            for _, v in pairs(Randomat.Events) do
                local title = Randomat:GetEventTitle(v)
                if title == evnt then
                    Randomat:TriggerEvent(v.id, owner)
                end
            end
            net.Start("ChooseEventEnd")
            net.Broadcast()
            EventVotes = {}
        end)
    else
        net.Start("ChooseEventTrigger")
        net.WriteInt(choices, 32)
        net.WriteTable(EventChoices)
        net.Send(owner)
    end
end

function EVENT:End()
    timer.Remove("RdmtChooseVoteTimer")

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
    for _, v in ipairs({"vote", "deadvoters"}) do
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
    local str = net.ReadString()
    for _, v in pairs(Randomat.Events) do
        local title = Randomat:GetEventTitle(v)
        if title == str then
            Randomat:TriggerEvent(v.id, owner)
        end
    end
end)

net.Receive("ChoosePlayerVoted", function(ln, ply)
    local voted = false
    for _, v in pairs(PlayersVoted) do
        if v == ply then
            voted = true
            break
        end
    end

    if (ply:Alive() and not ply:IsSpec()) or GetConVar("randomat_choose_deadvoters"):GetBool() then
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