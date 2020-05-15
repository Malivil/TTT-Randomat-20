util.AddNetworkString("randomat_message")
util.AddNetworkString("randomat_message_silent")
if SERVER then
    util.AddNetworkString("TTT_RoleChanged")
end

Randomat.Events = Randomat.Events or {}
Randomat.ActiveEvents = {}

local randomat_meta =  {}
randomat_meta.__index = randomat_meta

concommand.Add("ttt_randomat_safetrigger", function(ply, cc , arg)
    local cmd = arg[1]
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        if event:Condition() and event:Enabled() then
            local index = #Randomat.ActiveEvents + 1
            Randomat.ActiveEvents[index] = Randomat.Events[cmd]

            local rdmply = {}
            for k, v in RandomPairs(player.GetAll()) do
                if v:Alive() and not v:IsSpec() then
                    table.insert(rdmply, v)
                end
            end

            Randomat.ActiveEvents[index].owner = rdmply[1]
            Randomat:EventNotify(Randomat.ActiveEvents[index].Title)
            Randomat.ActiveEvents[index]:Begin(true)
        else
            error("Conditions for event not met")
        end
    else
        error("Could not find event '"..cmd.."'")
    end
end,"Triggers a specific randomat event with conditions",FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_trigger", function(ply, cc , arg)
    local cmd = arg[1]
    if Randomat.Events[cmd] ~= nil then
        local index = #Randomat.ActiveEvents + 1
        Randomat.ActiveEvents[index] = Randomat.Events[cmd]

        local rdmply = {}
        for k, v in RandomPairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() then
                table.insert(rdmply, v)
            end
        end

        Randomat.ActiveEvents[index].owner = rdmply[1]
        Randomat:EventNotify(Randomat.ActiveEvents[index].Title)
        Randomat.ActiveEvents[index]:Begin(true)
    else
        error("Could not find event '"..cmd.."'")
    end
end,"Triggers a specific randomat event without conditions",FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_clearevents",function(ply)
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            evt:End()
        end

        Randomat.ActiveEvents = {}
    end
end)

local function shuffleTable(t)
    math.randomseed(os.time())
    local rand = math.random

    local interactions = #t
    local j

    for i = interactions, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function Randomat:GetAlivePlayers(shuffle)
    local plys = {}

    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and (not ply:IsSpec()) and ply:Alive() then
            table.insert(plys, ply)
        end
    end

    if shuffle then
        shuffleTable(plys)
    end

    return plys
end

function Randomat:GetValidPlayer(ply)
    if IsValid(ply) and ply:Alive() and not ply:IsSpec() then
        return ply
    end

    local rdmply = Randomat:GetAlivePlayers(true)
    return rdmply[1]
end

function Randomat:SetRole(ply, role)
    ply:SetRole(role)

    if SERVER then
        net.Start("TTT_RoleChanged")
        net.WriteInt(ply:UserID(), 8)
        net.WriteInt(role, 8)
        net.Broadcast()
    end
end

function Randomat:register(tbl)
    local id = tbl.id
    tbl.Id = id
    tbl.__index = tbl
    setmetatable(tbl, randomat_meta)

    Randomat.Events[id] = tbl

    CreateConVar("ttt_randomat_"..id, 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
end

function Randomat:unregister(id)
    if not Randomat.Events[id] then return end
    Randomat.Events[id] = nil
end

function Randomat:TriggerRandomEvent(ply, notify)
    if notify == nil then notify = true end
    local events = Randomat.Events

    shuffleTable(events)

    local x = 0
    for _, v in pairs(events) do
        if v:Condition() and v:Enabled() then
            x = 1
        end
    end

    if x == 0 then
        error("Could not find valid event, consider enabling more")
    end

    local event = table.Random(events)

    while not event:Condition() or not event:Enabled() do
        event = table.Random(events)
    end

    local index = #Randomat.ActiveEvents + 1

    Randomat.ActiveEvents[index] = event
    Randomat.ActiveEvents[index].owner = ply

    if notify then
        Randomat:EventNotify(Randomat.ActiveEvents[index].Title)
    end

    Randomat.ActiveEvents[index]:Begin(notify)
end

function Randomat:TriggerEvent(event, ply, notify)
    if notify == nil then notify = true end
    local cmd = event
    if Randomat.Events[cmd] ~= nil then
        local index = #Randomat.ActiveEvents + 1
        Randomat.ActiveEvents[index] = Randomat.Events[cmd]

        Randomat.ActiveEvents[index].owner = ply
        if notify then
            Randomat:EventNotify(Randomat.ActiveEvents[index].Title)
        end
        Randomat.ActiveEvents[index]:Begin(notify)
    else
        error("Could not find event '"..cmd.."'")
    end
end

function Randomat:SilentTriggerEvent(event, ply, notify)
    if notify == nil then notify = true end
    local cmd = event
    if Randomat.Events[cmd] ~= nil then
        local index = #Randomat.ActiveEvents + 1
        Randomat.ActiveEvents[index] = Randomat.Events[cmd]

        Randomat.ActiveEvents[index].owner = ply
        Randomat.ActiveEvents[index]:Begin(notify)
    else
        error("Could not find event '"..cmd.."'")
    end
end

concommand.Add("ttt_randomat_triggerrandom", function()
    local rdmply = GetValidPlayer(nil)
    Randomat:TriggerRandomEvent(rdmply, true)
end)

function Randomat:EventNotify(title)
    net.Start("randomat_message")
    net.WriteBool(true)
    net.WriteString(title)
    net.WriteUInt(0, 8)
    net.Broadcast()
end

function Randomat:EventNotifySilent(title)
    net.Start("randomat_message_silent")
    net.WriteBool(true)
    net.WriteString(title)
    net.WriteUInt(0, 8)
    net.Broadcast()
end

--[[
 Randomat Meta
]]--

-- Valid players not spec
function randomat_meta:GetPlayers(shuffle)
    return self:GetAlivePlayers(shuffle)
end

function randomat_meta:GetAlivePlayers(shuffle)
    return Randomat:GetAlivePlayers(shuffle)
end

if SERVER then
    function randomat_meta:SmallNotify(msg, length, targ)
        if not isnumber(length) then length = 0 end
        net.Start("randomat_message")
        net.WriteBool(false)
        net.WriteString(msg)
        net.WriteUInt(length, 8)
        if not targ then net.Broadcast() else net.Send(targ) end
    end
end

function randomat_meta:AddHook(hooktype, callbackfunc)
    callbackfunc = callbackfunc or self[hooktype]

    hook.Add(hooktype, "RandomatEvent." .. self.Id .. ":" .. hooktype, function(...)
        return callbackfunc(...)
    end)

    self.Hooks = self.Hooks or {}

    table.insert(self.Hooks, {hooktype, "RandomatEvent." .. self.Id .. ":" .. hooktype})
end

function randomat_meta:CleanUpHooks()
    if not self.Hooks then return end

    for _, ahook in pairs(self.Hooks) do
        hook.Remove(ahook[1], ahook[2])
    end

    table.Empty(self.Hooks)
end

function randomat_meta:Begin(notify) end

function randomat_meta:End()
    self:CleanUpHooks()
end

function randomat_meta:Condition()
    return true
end

function randomat_meta:Enabled()
    if GetConVar("ttt_randomat_"..self.id):GetBool() then
        return true
    else
        return false
    end
end

function randomat_meta:GetConVars() end

RDMT_BOOL = 0
RDMT_INT = 1
RDMT_FLOAT = 2

function randomat_meta:CreateCmd(str, val, desc, slider)
    CreateConVar("randomat_"..self.id..str, val, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, desc)
    if not self.cmds then
        self.cmds = {}
    end
    table.insert(self.cmds, {})
end


--[[
 Override TTT Stuff
]]--
hook.Add("TTTEndRound", "RandomatEndRound", function()
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            evt:End()
        end

        Randomat.ActiveEvents = {}
    end
end)

hook.Add("TTTPrepareRound", "RandomatEndRound", function()
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            evt:End()
        end

        Randomat.ActiveEvents = {}
    end
end)

