util.AddNetworkString("randomat_message")
util.AddNetworkString("randomat_message_silent")
util.AddNetworkString("AlertTriggerFinal")
util.AddNetworkString("alerteventtrigger")

if SERVER then
    util.AddNetworkString("TTT_RoleChanged")
end

Randomat.Events = Randomat.Events or {}
Randomat.ActiveEvents = {}

local randomat_meta =  {}
randomat_meta.__index = randomat_meta

local function CommandAutoComplete(cmd, args)
    local name = string.lower(string.Trim(args))
    local options = {}
    for _, v in pairs(Randomat.Events) do
        if string.find(string.lower(v.Id), name) then
            table.insert(options, cmd .. " " .. v.Id)
        end
    end
    return options
end

concommand.Add("ttt_randomat_safetrigger", function(ply, cc, arg)
    local cmd = arg[1]
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        if event:Condition() and event:Enabled() then
            local index = #Randomat.ActiveEvents + 1
            Randomat:EventNotify(event.Title)
            Randomat.ActiveEvents[index] = event
            Randomat.ActiveEvents[index].owner = Randomat:GetValidPlayer(nil)
            Randomat.ActiveEvents[index]:Begin()
        else
            error("Conditions for event not met")
        end
    else
        error("Could not find event '"..cmd.."'")
    end
end, CommandAutoComplete, "Triggers a specific randomat event with conditions",FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_trigger", function(ply, cc, arg)
    local cmd = arg[1]
    if Randomat.Events[cmd] ~= nil then
        local index = #Randomat.ActiveEvents + 1
        local event = Randomat.Events[cmd]
        Randomat:EventNotify(event.Title)
        Randomat.ActiveEvents[index] = event
        Randomat.ActiveEvents[index].owner = Randomat:GetValidPlayer(nil)
        Randomat.ActiveEvents[index]:Begin()
    else
        error("Could not find event '"..cmd.."'")
    end
end, CommandAutoComplete, "Triggers a specific randomat event without conditions",FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_clearevents",function(ply)
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            evt:End()
        end

        Randomat.ActiveEvents = {}
    end
end)

 function Randomat:IsEventActive(id)
    for _, v in pairs(Randomat.ActiveEvents) do
        if v.id == id then
            return true
        end
    end
    return false
end

function Randomat:GetEventTitle(event)
    if event.Title == "" then
        return event.AltTitle
    end
    return event.Title
end

function Randomat:GetAlivePlayers(shuffle)
    local plys = {}
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and (not ply:IsSpec()) and ply:Alive() then
            table.insert(plys, ply)
        end
    end

    if shuffle then
        table.Shuffle(plys)
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
        net.WriteString(ply:UniqueID())
        net.WriteUInt(role, 8)
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

local function GetRandomEvent(events)
    local count = table.Count(events)
    local idx = math.random(count)
    local key = table.GetKeys(events)[idx]
    return events[key]
end

function Randomat:TriggerRandomEvent(ply)
    local events = Randomat.Events

    local found = false
    for _, v in pairs(events) do
        if v:Condition() and v:Enabled() then
            found = true
            break
        end
    end

    if not found then
        error("Could not find valid event, consider enabling more")
    end

    local event = GetRandomEvent(events)
    while not event:Condition() or not event:Enabled() do
        event = GetRandomEvent(events)
    end

    local index = #Randomat.ActiveEvents + 1
    Randomat:EventNotify(event.Title)
    Randomat.ActiveEvents[index] = event
    Randomat.ActiveEvents[index].owner = ply
    Randomat.ActiveEvents[index]:Begin()
end

function Randomat:TriggerEvent(cmd, ply)
    if Randomat.Events[cmd] ~= nil then
        local index = #Randomat.ActiveEvents + 1
        local event = Randomat.Events[cmd]
        Randomat:EventNotify(event.Title)
        Randomat.ActiveEvents[index] = event
        Randomat.ActiveEvents[index].owner = ply
        Randomat.ActiveEvents[index]:Begin()
    else
        error("Could not find event '"..cmd.."'")
    end
end

function Randomat:SilentTriggerEvent(cmd, ply)
    if Randomat.Events[cmd] ~= nil then
        local index = #Randomat.ActiveEvents + 1
        Randomat.ActiveEvents[index] = Randomat.Events[cmd]

        Randomat.ActiveEvents[index].owner = ply
        Randomat.ActiveEvents[index]:Begin()
    else
        error("Could not find event '"..cmd.."'")
    end
end

concommand.Add("ttt_randomat_triggerrandom", function()
    local rdmply = Randomat:GetValidPlayer(nil)
    Randomat:TriggerRandomEvent(rdmply)
end)

function Randomat:EventNotify(title)
    -- Don't broadcast anything when "Secret" is running
    if Randomat:IsEventActive("secret") then return end
    net.Start("randomat_message")
    net.WriteBool(true)
    net.WriteString(title)
    net.WriteUInt(0, 8)
    net.Broadcast()
end

function Randomat:EventNotifySilent(title)
    -- Don't broadcast anything when "Secret" is running
    if Randomat:IsEventActive("secret") then return end
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
        -- Don't broadcast anything when "Secret" is running
        if Randomat:IsEventActive("secret") then return end
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

function randomat_meta:Begin() end

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

-- What role is a player?
function randomat_meta:GetRoleName(ply)
    if ply:GetRole() == ROLE_TRAITOR then
        return "A traitor"
    elseif ply:GetRole() == ROLE_HYPNOTIST then
        return "A hypnotist"
    elseif ply:GetRole() == ROLE_ASSASSIN then
        return "An assassin"
    elseif ply:GetRole() == ROLE_DETECTIVE then
        return "A detective"
    elseif ply:GetRole() == ROLE_MERCENARY then
        return "A mercenary"
    elseif ply:GetRole() == ROLE_ZOMBIE then
        return "A zombie"
    elseif ply:GetRole() == ROLE_VAMPIRE then
        return "A vampire"
    elseif ply:GetRole() == ROLE_KILLER then
        return "A killer"
    elseif ply:GetRole() == ROLE_INNOCENT then
        return "An innocent"
    elseif ply:GetRole() == ROLE_GLITCH then
        return "A glitch"
    elseif ply:GetRole() == ROLE_PHANTOM then
        return "A phantom"
    end

    return "Someone"
end

-- Rename stock weapons so they are readable
function randomat_meta:RenameWeps(name)
    if name == "sipistol_name" then
        return "Silenced Pistol"
    elseif name == "knife_name" then
        return "Knife"
    elseif name == "newton_name" then
        return "Newton Launcher"
    elseif name == "tele_name" then
        return "Teleporter"
    elseif name == "hstation_name" then
        return "Health Station"
    elseif name == "flare_name" then
        return "Flare Gun"
    elseif name == "decoy_name" then
        return "Decoy"
    elseif name == "radio_name" then
        return "Radio"
    elseif name == "polter_name" then
        return "Poltergeist"
    elseif name == "vis_name" then
        return "Visualizer"
    elseif name == "defuser_name" then
        return "Defuser"
    elseif name == "stungun_name" then
        return "UMP Prototype"
    elseif name == "binoc_name" then
        return "Binoculars"
    end

    return name
end

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

