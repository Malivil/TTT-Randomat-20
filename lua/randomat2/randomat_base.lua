util.AddNetworkString("randomat_message")
util.AddNetworkString("randomat_message_silent")
util.AddNetworkString("AlertTriggerFinal")
util.AddNetworkString("alerteventtrigger")
util.AddNetworkString("RdmtSetSpeedMultiplier")
util.AddNetworkString("RdmtSetSpeedMultiplier_WithWeapon")
util.AddNetworkString("RdmtSetSpeedMultiplier_Sprinting")
util.AddNetworkString("RdmtRemoveSpeedMultiplier")
util.AddNetworkString("RdmtRemoveSpeedMultipliers")
util.AddNetworkString("RdmtEventBegin")
util.AddNetworkString("RdmtEventEnd")
util.AddNetworkString("TTT_RoleChanged")
util.AddNetworkString("TTT_LogInfo")

ROLE_JESTER = ROLE_JESTER or -1
ROLE_SWAPPER = ROLE_SWAPPER or -1
ROLE_GLITCH = ROLE_GLITCH or -1
ROLE_PHANTOM = ROLE_PHANTOM or ROLE_PHOENIX or -1
ROLE_HYPNOTIST = ROLE_HYPNOTIST or -1
ROLE_REVENGER = ROLE_REVENGER or -1
ROLE_DRUNK = ROLE_DRUNK or -1
ROLE_CLOWN = ROLE_CLOWN or -1
ROLE_DEPUTY = ROLE_DEPUTY or -1
ROLE_IMPERSONATOR = ROLE_IMPERSONATOR or -1
ROLE_BEGGAR = ROLE_BEGGAR or -1
ROLE_OLDMAN = ROLE_OLDMAN or -1
ROLE_MERCENARY = ROLE_MERCENARY or ROLE_SURVIVALIST or -1
ROLE_BODYSNATCHER = ROLE_BODYSNATCHER or -1
ROLE_VETERAN = ROLE_VETERAN or -1
ROLE_ASSASSIN = ROLE_ASSASSIN or -1
ROLE_KILLER = ROLE_KILLER or ROLE_SERIALKILLER or -1
ROLE_ZOMBIE = ROLE_ZOMBIE or ROLE_INFECTED or -1
ROLE_VAMPIRE = ROLE_VAMPIRE or -1
ROLE_DOCTOR = ROLE_DOCTOR or -1
ROLE_QUACK = ROLE_QUACK or -1
ROLE_PARASITE = ROLE_PARASITE or -1
ROLE_TRICKSTER = ROLE_TRICKSTER or -1
ROLE_DETRAITOR = ROLE_DETRAITOR or -1
ROLE_LOOTGOBLIN = ROLE_LOOTGOBLIN or -1

Randomat.ConVars = {
    "ttt_randomat_allow_client_list",
    "ttt_randomat_always_silently_trigger",
    "ttt_randomat_auto",
    "ttt_randomat_auto_chance",
    "ttt_randomat_auto_choose",
    "ttt_randomat_auto_min_rounds",
    "ttt_randomat_auto_silent",
    "ttt_randomat_chooseevent",
    "ttt_randomat_event_hint",
    "ttt_randomat_event_hint_chat",
    "ttt_randomat_event_hint_chat_secret",
    "ttt_randomat_event_history",
    "ttt_randomat_event_weight",
    "ttt_randomat_rebuyable"
}
Randomat.Events = Randomat.Events or {}
Randomat.ActiveEvents = Randomat.ActiveEvents or {}

local randomat_meta =  {}
randomat_meta.__index = randomat_meta

local concommand = concommand
local ents = ents
local file = file
local hook = hook
local ipairs = ipairs
local IsValid = IsValid
local math = math
local net = net
local pairs = pairs
local player = player
local string = string
local table = table
local timer = timer

local CallHook = hook.Call
local EntsCreate = ents.Create
local EntsFindByClass = ents.FindByClass
local GetAllPlayers = player.GetAll
local GetAllEnts = ents.GetAll
local PlayerIterator = player.Iterator

local COLOR_BLANK = Color(0, 0, 0, 0)

--[[
 Event History
]]--

Randomat.EventHistory = Randomat.EventHistory or {}

local function TruncateEventHistory(count)
    if count <= 0 then return end

    -- Make sure we only keep the configured number of events
    if #Randomat.EventHistory > count then
        local extra = #Randomat.EventHistory - count
        local keep = {}
        for i = extra + 1, #Randomat.EventHistory, 1 do
            table.insert(keep, Randomat.EventHistory[i])
        end
        Randomat.EventHistory = keep
    end
end

local function SaveEventHistory()
    -- Save each event ID on a new line
    local history = table.concat(Randomat.EventHistory, "\n")
    file.Write("randomat/history.txt", history)
end

local function CheckEventHistoryFile()
    -- Make sure the directory exists
    if not file.IsDir("randomat", "DATA") then
        if file.Exists("randomat", "DATA") then
            ErrorNoHalt("Item named 'randomat' already exists in garrysmod/data but it is not a directory\n")
            return false
        end

        file.CreateDir("randomat")
    end

    -- Make sure the file exists
    if not file.Exists("randomat/history.txt", "DATA") then
        file.Write("randomat/history.txt", "")
    end

    return true
end

local function LoadEventHistory()
    local count = GetConVar("ttt_randomat_event_history"):GetInt()
    if count <= 0 then return end

    if not CheckEventHistoryFile() then return end

    -- Read each entry from the file and save them
    local history = string.Split(file.Read("randomat/history.txt", "DATA"), "\n")
    for _, h in ipairs(history) do
        if #h > 0 then
            table.insert(Randomat.EventHistory, h)
        end
    end

    TruncateEventHistory(count)
    SaveEventHistory()
end
LoadEventHistory()

function Randomat:IsEventInHistory(event)
    if type(event) ~= "table" then
        event = Randomat.Events[event]
    end
    if event == nil then return end

    return table.HasValue(Randomat.EventHistory, event.Id)
end

function Randomat:AddEventToHistory(event)
    local count = GetConVar("ttt_randomat_event_history"):GetInt()
    if count <= 0 then return end

    if not CheckEventHistoryFile() then return end

    if type(event) ~= "table" then
        event = Randomat.Events[event]
    end
    if event == nil then return end

    table.insert(Randomat.EventHistory, event.Id)
    TruncateEventHistory(count)
    SaveEventHistory()
end

concommand.Add("ttt_randomat_clearhistory", function(ply, cc, arg)
    table.Empty(Randomat.EventHistory)
    SaveEventHistory()
    CallHook("TTTRandomatCommand", nil, ply, cc, arg)
end)

--[[
 Event Notifications
]]--

function Randomat:ChatDescription(ply, event, has_description)
    -- Show this if "secret" is active if we're specifically showing the description for "secret"
    if event.Id ~= "secret" and Randomat:IsEventActive("secret") then return end
    if not IsValid(ply) then return end

    local title = Randomat:GetEventTitle(event)
    local description = ""
    if has_description then
        description = " | " .. event.Description
    end

    ply:PrintMessage(HUD_PRINTTALK, "[RANDOMAT] " .. title .. description)
end

--[[
 Event Control
]]--

local function EndEvent(evt, skipNetMessage)
    evt:CleanUpHooks()

    if type(evt.End) == "function" then
        local function End()
            evt:End()
        end
        local function Catch(err)
            ErrorNoHalt("WARNING: Randomat event '" .. evt.Id .. "' caused an error when it was being Ended. Please report to the addon developer with the following error:\n", err, "\n")
        end
        xpcall(End, Catch)
    end

    if skipNetMessage then return end

    net.Start("RdmtEventEnd")
    net.WriteString(evt.Id)
    net.Broadcast()
end

-- Prints the names of any secret events that triggered to chat at the end of the round
local secret_event_chat_msgs = {}
local function PrintSecretEventsList()
    if #secret_event_chat_msgs > 0 then
        PrintMessage(HUD_PRINTTALK, "[RANDOMAT] Secret events this round:")

        for _, msg in ipairs(secret_event_chat_msgs) do
            PrintMessage(HUD_PRINTTALK, msg)
        end

        table.Empty(secret_event_chat_msgs)
    end
end

local function TriggerEvent(event, ply, options, ...)
    options = options or {}

    local owner = Randomat:GetValidPlayer(ply)
    event:BeforeEventTrigger(owner, options, ...)

    local silent = options.Silent
    if not silent then
        -- If this event is supposed to start secretly, trigger "secret" with this specific event chosen
        -- Unless "secret" is already running in which case we don't care, just let it go
        if event.StartSecret and not Randomat:IsEventActive("secret") then
            TriggerEvent(Randomat.Events["secret"], owner, nil, event.Id)
            return
        end

        Randomat:EventNotify(event.Title)
    end

    table.insert(Randomat.ActiveEvents, event)
    event.owner = owner
    event.Owner = owner
    event.Silent = silent
    event.StartTime = CurTime()
    event:Begin(...)

    -- Run this after the "Begin" so we have the latest title and description
    local title = Randomat:GetEventTitle(event)
    local message = "[RANDOMAT] Event '" .. title .. "' (" .. event.Id .. ") started by " .. owner:Nick()
    Randomat:LogEvent(message)
    MsgN(message)

    if not silent then
        local has_description = event.Description ~= nil and #event.Description > 0
        -- Show description on screen if it has one, the notification is enabled,
        -- and if "secret" is not active or if we're specifically showing the description for "secret"
        if has_description and GetConVar("ttt_randomat_event_hint"):GetBool() and (not Randomat:IsEventActive("secret") or event.Id == "secret") then
            Randomat:SmallNotify(event.Description, nil, nil, false, true)
        end
        if GetConVar("ttt_randomat_event_hint_chat"):GetBool() then
            for _, p in PlayerIterator() do
                Randomat:ChatDescription(p, event, has_description)
            end
        end
    end

    -- Broadcast this to every client, but hide what it really is if secret is active (and this isn't secret itself)
    local should_hide = options.Hidden or event.Id ~= "secret" and Randomat:IsEventActive("secret")
    net.Start("RdmtEventBegin")
    if should_hide then
        net.WriteString("???")
        net.WriteString("A 'Secret' Event")
        net.WriteString(options.HiddenMessage or ("This event is hidden by '" .. Randomat:GetEventTitle(Randomat.Events["secret"]) .. "'"))
    else
        net.WriteString(event.Id)
        net.WriteString(title)
        net.WriteString(event.Description or "")
    end
    net.Broadcast()

    -- Getting info for printing the names and descriptions of secret randomats in chat if enabled
    if GetConVar("ttt_randomat_event_hint_chat_secret"):GetBool() and should_hide then
        local msg = title
        if event.Description ~= nil and #event.Description > 0 then
            msg = msg .. " | " .. event.Description
        end
        table.insert(secret_event_chat_msgs, msg)
    end

    -- Let other addons know that an event was started
    CallHook("TTTRandomatTriggered", nil, event.Id, owner)
end

--[[
 Randomat Namespace
]]--

-- Events

function Randomat:EndActiveEvent(id, skip_error)
    for k, evt in pairs(Randomat.ActiveEvents) do
        if evt.Id == id then
            EndEvent(evt)
            table.remove(Randomat.ActiveEvents, k)
            return
        end
    end

    if not skip_error then
        error("Could not find active event '" .. id .. "'")
    end
end

function Randomat:EndActiveEvents()
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            EndEvent(evt)
        end

        Randomat.ActiveEvents = {}
    end
end

function Randomat:GetEventTitle(event)
    if event.Title == "" then
        return event.AltTitle
    end
    return event.Title
end

function Randomat:register(tbl)
    local default_weight = GetConVar("ttt_randomat_event_weight"):GetInt()

    local id = tbl.id or tbl.Id
    tbl.Id = id
    tbl.id = id
    tbl.__index = tbl
    -- Default IsEnabled to true if it isn't specified
    if tbl.IsEnabled ~= false then
        tbl.IsEnabled = true
    end
    -- Default SingleUse to true if it isn't specified
    if tbl.SingleUse ~= false then
        tbl.SingleUse = true
    end
    -- Default StartSecret to false if it isn't specified
    if tbl.StartSecret ~= true then
        tbl.StartSecret = false
    end
    -- Default the event type if it's not specified
    if tbl.Type == nil then
        tbl.Type = EVENT_TYPE_DEFAULT
    end
    -- Default MinPlayers to 0 if it's not specified
    if type(tbl.MinPlayers) ~= "table" then
        tbl.MinPlayers = {
            Min = 0,
            Max = 32,
            Default = tbl.MinPlayers or 0
        }
    end
    -- Ensure the pieces of MinPlayers make sense with each other
    tbl.MinPlayers.Min = tbl.MinPlayers.Min or 0
    tbl.MinPlayers.Max = tbl.MinPlayers.Max or 32
    if tbl.MinPlayers.Min > tbl.MinPlayers.Min then
        tbl.MinPlayers.Min = tbl.MinPlayers.Min
    end
    tbl.MinPlayers.Default = tbl.MinPlayers.Default or tbl.MinPlayers.Min or 0
    if tbl.MinPlayers.Default < tbl.MinPlayers.Min then
        tbl.MinPlayers.Default = tbl.MinPlayers.Min
    end

    -- Default Weight to -1 if it's not specified or matches the global default
    if tbl.Weight == nil or tbl.Weight == default_weight then
        tbl.Weight = -1
    end
    -- Normalize the categories by lowercasing them all
    if type(tbl.Categories) == "table" then
        local lower_cats = {}
        for _, v in ipairs(tbl.Categories) do
            if v and #v > 0 then
                table.insert(lower_cats, v:lower())
            end
        end
        tbl.Categories = lower_cats
    end
    -- Make sure the list of convars exists
    if type(tbl.ConVars) ~= "table" then
        tbl.ConVars = {}
    end
    -- And then save the default ones into it
    table.insert(tbl.ConVars, "ttt_randomat_" .. id)
    table.insert(tbl.ConVars, "ttt_randomat_" .. id .. "_min_players")
    table.insert(tbl.ConVars, "ttt_randomat_" .. id .. "_weight")

    setmetatable(tbl, randomat_meta)

    Randomat.Events[id] = tbl

    CreateConVar("ttt_randomat_" .. id, tbl.IsEnabled and 1 or 0, FCVAR_NONE, "Whether this event is enabled.", 0, 1)
    local minPlayers = CreateConVar("ttt_randomat_" .. id .. "_min_players", tbl.MinPlayers.Default, FCVAR_NONE, "The minimum number of players required for this event to start.", tbl.MinPlayers.Min, tbl.MinPlayers.Max)
    -- Update the value of the convar if it already exists but the min value has been changed
    if minPlayers:GetInt() < tbl.MinPlayers.Min then
        minPlayers:SetInt(tbl.MinPlayers.Min)
    end
    local weight = CreateConVar("ttt_randomat_" .. id .. "_weight", tbl.Weight, FCVAR_NONE, "The weight this event should use during the randomized event selection process.", -1, 50)

    -- If the current weight matches the default, update the per-event weight to the new default of -1
    if weight:GetInt() == default_weight then
        MsgN("Event '" .. id .. "' weight (" .. weight:GetInt() .. ") matches default weight (" .. default_weight .. "), resetting to -1")
        weight:SetInt(-1)
    end

    if type(tbl.Initialize) == "function" then
        tbl:Initialize()
    end
end

function Randomat:unregister(id)
    if not Randomat.Events[id] then return end
    Randomat.Events[id] = nil
end

function Randomat:CanEventRun(event, ignore_history)
    if type(event) ~= "table" then
        event = Randomat.Events[event]
    end
    -- Basic checks
    if event == nil then return false, "No such event" end

    local can_run, reason = hook.Call("TTTRandomatCanEventRun", nil, event)
    if type(can_run) == "boolean" then
        return can_run, reason or "Blocked by 'TTTRandomatCanEventRun' hook"
    end

    if not event:Enabled() then return false, "Not enabled" end
    if not event:Condition() then return false, "Condition not fulfilled" end

    -- Check there are enough players
    local min_players = GetConVar("ttt_randomat_" .. event.Id .. "_min_players"):GetInt()
    local player_count = player.GetCount()
    if min_players > 0 and player_count < min_players then return false, "Not enough players (" .. player_count .. " vs. " .. min_players .. " required)" end

    -- Check that the round has run the correct amount of time
    local round_percent_complete = Randomat:GetRoundCompletePercent()
    if (event.MinRoundCompletePercent and event.MinRoundCompletePercent > round_percent_complete) or
        (event.MaxRoundCompletePercent and event.MaxRoundCompletePercent < round_percent_complete) then
        return false, "Round percent complete mismatch (" .. round_percent_complete .. ")"
    end

    -- Don't allow single use events to run twice
    if event.SingleUse and Randomat:IsEventActive(event.Id) then return false, "Single use event is already running" end

    -- Don't use the same events over and over again
    if not ignore_history and Randomat:IsEventInHistory(event) then return false, "Event is in recent history" end

    -- Don't allow multiple events of the same type to run at once
    if event.Type ~= EVENT_TYPE_DEFAULT then
        for _, evt in pairs(Randomat.ActiveEvents) do
            if type(evt.Type) == "table" then
                -- If both are tables don't allow any matching types
                if type(event.Type) == "table" then
                    for _, t in ipairs(event.Type) do
                        if table.HasValue(evt.Type, t) then
                            return false, "Event with same type (" .. t .. ") is already running"
                        end
                    end
                -- If only one is a table, don't allow it to contain the other's type
                elseif table.HasValue(evt.Type, event.Type) then
                    return false, "Event with same type (" .. event.Type .. ") is already running"
                end
            -- If only one is a table, don't allow it to contain the other's type
            elseif type(event.Type) == "table" then
                if table.HasValue(event.Type, evt.Type) then
                    return false, "Event with same type (" .. evt.Type .. ") is already running"
                end
            -- If neither are tables, don't allow the types to match
            elseif evt.Type == event.Type then
                return false, "Event with same type (" .. event.Type .. ") is already running"
            end
        end
    end

    return true
end

local function GetRandomWeightedEvent(events, can_run)
    local weighted_events = {}
    for id, event in pairs(events) do
        if can_run and not can_run(event) then continue end

        local weight = GetConVar("ttt_randomat_" .. id .. "_weight"):GetInt()
        local default_weight = GetConVar("ttt_randomat_event_weight"):GetInt()
        -- Use the default if the per-event weight is invalid
        if weight < 0 then
            weight = default_weight
        end
        for _ = 1, weight do
            table.insert(weighted_events, id)
        end
    end

    -- Randomize the weighted list
    table.Shuffle(weighted_events)

    -- Then get a random index from the random list for more randomness
    local count = table.Count(weighted_events)
    local idx = math.random(count)
    local key = weighted_events[idx]

    return events[key]
end

function Randomat:GetRandomEvent(skip_history, can_run)
    local events = Randomat.Events

    local found = false
    for _, v in pairs(events) do
        if Randomat:CanEventRun(v) and ((not can_run) or can_run(v)) then
            found = true
            break
        end
    end

    if not found then
        error("Could not find valid event, consider enabling more")
    end

    local event = GetRandomWeightedEvent(events, can_run)
    while not Randomat:CanEventRun(event) do
        event = GetRandomWeightedEvent(events, can_run)
    end

    -- Only add randomly selected events to the history so specifically-triggered events don't get tracked
    if not skip_history then
        Randomat:AddEventToHistory(event)
    end

    return event
end

function Randomat:TriggerRandomEvent(ply)
    local event = Randomat:GetRandomEvent()
    TriggerEvent(event, ply)
end

function Randomat:SilentTriggerRandomEvent(ply)
    local event = Randomat:GetRandomEvent()
    TriggerEvent(event, ply, {Silent=true})
end

function Randomat:TriggerEvent(cmd, ply, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        TriggerEvent(event, ply, nil, ...)
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:SafeTriggerEvent(cmd, ply, error_if_unsafe, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        local can_run, reason = Randomat:CanEventRun(event)
        if can_run then
            TriggerEvent(event, ply, nil, ...)
        elseif error_if_unsafe then
            error("Conditions for event not met: " .. reason)
        end
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:SilentTriggerEvent(cmd, ply, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        TriggerEvent(event, ply, {Silent=true}, ...)
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:TriggerHiddenEvent(cmd, ply, reason, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        TriggerEvent(event, ply, {Hidden=true,HiddenMessage=reason}, ...)
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:SilentTriggerHiddenEvent(cmd, ply, reason, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        TriggerEvent(event, ply, {Silent=true,Hidden=true,HiddenMessage=reason}, ...)
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:LogEvent(msg)
    net.Start("TTT_LogInfo")
    net.WriteString(msg)
    net.Broadcast()
end

-- Event Categories

function Randomat:GetReadableCategory(category)
    if category == "smallimpact" then
        return "Small Impact"
    elseif category == "moderateimpact" then
        return "Moderate Impact"
    elseif category == "largeimpact" then
        return "Large Impact"
    elseif category == "rolechange" then
        return "Role Change"
    elseif category == "eventtrigger" then
        return "Event Trigger"
    elseif category == "deathtrigger" then
        return "Death Trigger"
    elseif category == "gamemode" then
        return "Game Mode"
    elseif category == "entityspawn" then
        return "Entity Spawn"
    elseif category == "modelchange" then
        return "Model Change"
    elseif string.StartsWith(category, "biased_") then
        local parts = string.Explode("_", category)
        for k, p in ipairs(parts) do
            parts[k] = Randomat:Capitalize(p)
        end
        return table.concat(parts, " - ")
    end
    return Randomat:Capitalize(category)
end

function Randomat:GetAllEventCategories(readable)
    local categories = {}
    for _, e in pairs(Randomat.Events) do
        if type(e.Categories) ~= "table" then continue end

        for _, c in ipairs(e.Categories) do
            if not c or #c == 0 then continue end

            local cat = c:lower()
            if readable then
                cat = Randomat:GetReadableCategory(cat)
            end
            if table.HasValue(categories, cat) then continue end

            table.insert(categories, cat)
        end
    end
    return categories
end

function Randomat:GetEventCategories(event, readable)
    if type(event) ~= "table" then
        event = Randomat.Events[event]
    end
    if event == nil then return nil end
    if type(event.Categories) ~= "table" then return nil end

    local categories
    if readable then
        categories = {}
        for _, c in ipairs(event.Categories) do
            table.insert(categories, Randomat:GetReadableCategory(c))
        end
    else
        categories = event.Categories
    end

    return table.concat(categories, ", ")
end

function Randomat:GetEventsByCategory(category, active)
    if not category or #category == 0 then return {} end
    local tbl
    if not active then
        tbl = Randomat.Events
    else
        tbl = Randomat.ActiveEvents
    end

    local events = {}
    local lower_cat = category:lower()
    for _, e in pairs(tbl) do
        if type(e.Categories) == "table" and table.HasValue(e.Categories, lower_cat) then
            table.insert(events, e)
        end
    end
    return events
end

function Randomat:GetEventsByCategories(categories, active)
    if not categories or #categories == 0 then return {} end
    local tbl
    if not active then
        tbl = Randomat.Events
    else
        tbl = Randomat.ActiveEvents
    end

    local events = {}
    for _, e in pairs(tbl) do
        if type(e.Categories) ~= "table" then continue end

        local has_all = true
        for _, category in ipairs(categories) do
            local lower_cat = category:lower()
            if not table.HasValue(e.Categories, lower_cat) then
                has_all = false
            end
        end

        if has_all then
            table.insert(events, e)
        end
    end
    return events
end

function Randomat:IsEventCategoryActive(category)
    if not category or #category == 0 then return false end

    local lower_cat = category:lower()
    for _, e in pairs(Randomat.ActiveEvents) do
        if type(e.Categories) == "table" and table.HasValue(e.Categories, lower_cat) then
            return true
        end
    end
    return false
end

-- Event Types

function Randomat:GetEventsByType(etype)
    if type(etype) ~= "number" then return {} end

    local events = {}
    for _, e in pairs(Randomat.Events) do
        if (e.Type == etype) or (type(e.Type) == "table" and table.HasValue(e.Type, etype)) then
            table.insert(events, e)
        end
    end
    return events
end

-- Players

function Randomat:GetPlayers(shuffle, alive_only, dead_only, dead_includes_spec)
    local plys = {}
    -- Optimize this to get the full raw list if both alive and dead should be included
    if alive_only == dead_only then
        plys = GetAllPlayers()
    else
        for _, ply in PlayerIterator() do
            if IsValid(ply) and
            -- Anybody
            ((not alive_only and not dead_only) or
            -- Alive and non-spec
                (alive_only and (ply:Alive() and not ply:IsSpec())) or
            -- Dead but not spec unless that's enabled
                (dead_only and (not ply:Alive() or ply:IsSpec()) and (dead_includes_spec or ply:GetRole() ~= ROLE_NONE))) then
                table.insert(plys, ply)
            end
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

    return Randomat:GetPlayers(true, true)[1]
end

-- Roles

function Randomat:SetRole(ply, role, set_max_hp, scale_hp)
    local old_role = ply:GetRole()
    ply:SetRole(role)

    -- Set the player's max HP for their new role (Defaults to true)
    if set_max_hp ~= false and SetRoleMaxHealth then
        local current_max = ply:GetMaxHealth()
        SetRoleMaxHealth(ply)

        local new_max = ply:GetMaxHealth()
        if scale_hp ~= false and current_max ~= new_max then
            local fraction = ply:Health() / current_max
            local new_hp = math.Round(fraction * new_max)
            ply:SetHealth(new_hp)
        end
    end
    -- Heal the Old Man and Loot Goblin back to full when they are converted
    if ((old_role == ROLE_OLDMAN and role ~= ROLE_OLDMAN) or
        (old_role == ROLE_LOOTGOBLIN and role ~= ROLE_LOOTGOBLIN)) and SetRoleStartingHealth then
        SetRoleStartingHealth(ply)
    -- Reset special round logic for roles if we are changing a player away from being the last of that role
    elseif player.IsRoleLiving then
        if old_role == ROLE_GLITCH and role ~= ROLE_GLITCH and GetGlobalBool("ttt_glitch_round", false) and not player.IsRoleLiving(ROLE_GLITCH) then
            SetGlobalBool("ttt_glitch_round", false)
        elseif old_role == ROLE_ZOMBIE and role ~= ROLE_ZOMBIE and GetGlobalBool("ttt_zombie_round", false) and not player.IsRoleLiving(ROLE_ZOMBIE) then
            SetGlobalBool("ttt_zombie_round", false)
        end
    end

    net.Start("TTT_RoleChanged")
    net.WriteString(ply:SteamID64())
    if CR_VERSION then
        net.WriteInt(role, 8)
    else
        net.WriteUInt(role, 8)
    end
    net.Broadcast()
end

-- Notifications

local function SendNotify(msg, big, length, targ, silent, allow_secret, font_color)
    -- Don't broadcast anything when "Secret" is running unless we're told to bypass that
    if not allow_secret and Randomat:IsEventActive("secret") then return end
    if not isnumber(length) then length = 0 end
    net.Start(silent and "randomat_message_silent" or "randomat_message")
    net.WriteBool(big)
    net.WriteString(msg)
    net.WriteUInt(length, 8)
    net.WriteColor(font_color or COLOR_BLANK)
    if not targ then net.Broadcast() else net.Send(targ) end
end

function Randomat:SmallNotify(msg, length, targ, silent, allow_secret, font_color)
    SendNotify(msg, false, length, targ, silent, allow_secret, font_color)
end

function Randomat:Notify(msg, length, targ, silent, allow_secret, font_color)
    SendNotify(msg, true, length, targ, silent, allow_secret, font_color)
end

function Randomat:EventNotify(title)
    SendNotify(title, true)
end

function Randomat:EventNotifySilent(title)
    SendNotify(title, true, nil, nil, true)
end

function Randomat:ChatNotify(ply, msg)
    if Randomat:IsEventActive("secret") then return end
    if not IsValid(ply) then return end
    ply:PrintMessage(HUD_PRINTTALK, msg)
end

-- Weapons/Equipment

local function CanIncludeWeapon(role, weap, blocklist, droppable_only)
    -- Must be valid
    if not weap then return false end
    -- Must not spawn on the map
    if weap.AutoSpawnable then return false end
    -- Must be droppable if droppable_only is true
    if droppable_only and not weap.AllowDrop then return false end
    -- Must be buyable by the given role
    if not Randomat:IsWeaponBuyable(weap) or not table.HasValue(weap.CanBuy, role) then return false end
    -- Must not be blocked
    if blocklist and table.HasValue(blocklist, WEPS.GetClass(weap)) then return false end
    return true
end

local function GetRandomRoleWeapon(roles, blocklist, droppable_only)
    local tbl = {}
    for _, role in ipairs(roles) do
        for _, i in ipairs(table.Copy(EquipmentItems[role]) or {}) do
            tbl[i.id] = i
        end

        for _, v in ipairs(weapons.GetList()) do
            if CanIncludeWeapon(role, v, blocklist, droppable_only) then
                tbl[v.ClassName] = v
            end
        end
    end

    if #tbl == 0 then
        return nil, nil, nil
    end

    local item, _ = table.Random(tbl)
    local item_id = tonumber(item.id)
    local swep_table = (not item_id) and weapons.GetStored(item.ClassName) or nil
    return item, item_id, swep_table
end

function Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
    -- Allow singular roles
    if type(roles) ~= "table" then
        roles = {roles}
    end
    -- Make this a no-op if it's not provided
    if type(settrackingvar) ~= "function" then
        settrackingvar = function(arg) end
    end

    if type(tracking) ~= "number" then tracking = 0 end
    if tracking >= 500 then return nil, nil, nil end
    tracking = tracking + 1
    settrackingvar(tracking)

    local item, item_id, swep_table = GetRandomRoleWeapon(roles, blocklist, droppable_only)
    if item_id then
        -- If this is an item and we shouldn't get players items or the player already has this item, try again
        if not include_equipment or not ply or ply:HasEquipmentItem(item_id) then
            return Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
        -- Otherwise return it
        else
            settrackingvar(0)
            return item, item_id, swep_table
        end
    elseif swep_table then
        -- If this player can use this weapon, give it to them
        if not ply or ply:CanCarryWeapon(swep_table) then
            settrackingvar(0)
            return item, item_id, swep_table
        -- Otherwise try again
        else
            return Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
        end
    end

    -- If nothing valid was found, try again
    return Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
end

local function GiveWep(ply, roles, blocklist, include_equipment, tracking, settrackingvar, onitemgiven, droppable_only)
    local item, item_id, swep_table = Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
    -- Give the player whatever was found
    if item_id then
        onitemgiven(item_id, item_id)
        ply:GiveEquipmentItem(item_id)
    elseif swep_table then
        onitemgiven(nil, item.ClassName)
        ply:Give(item.ClassName)
        if swep_table.WasBought then
            swep_table:WasBought(ply)
        end
    end
end

function Randomat:GiveRandomShopItem(ply, roles, blocklist, include_equipment, gettrackingvar, settrackingvar, onitemgiven, droppable_only)
    GiveWep(ply, roles, blocklist, include_equipment, gettrackingvar(), settrackingvar, onitemgiven, droppable_only)
end

function Randomat:CallShopHooks(isequip, id, ply)
    hook.Call("TTTOrderedEquipment", GAMEMODE, ply, id, isequip, true)
    ply:AddBought(id)

    net.Start("TTT_BoughtItem")
    -- Not a boolean so we can't write it directly
    if isequip then
        net.WriteBit(true)
    else
        net.WriteBit(false)
    end
    if isequip then
        local bits = 16
        -- Only use 32 bits if the number of equipment items we have requires it
        if EQUIP_MAX >= 2^bits then
            bits = 32
        end

        net.WriteInt(id, bits)
    else
        net.WriteString(id)
    end
    net.Send(ply)
end

-- Entities

-- Adapted from Sandbox code by Jenssons
function Randomat:SpawnNPC(ply, pos, cls)
    local npc_list = list.Get("NPC")
    local npc_data = npc_list[cls]

    -- Don't let them spawn this entity if it isn't in our NPC Spawn list.
    -- We don't want them spawning any entity they like!
    if not npc_data then
        if IsValid(ply) then
            ply:SendLua("Derma_Message(\"Sorry! You can't spawn that NPC!\")")
        end
        return
    end

    -- Create NPC
    local npc_ent = EntsCreate(npc_data.Class)
    if not IsValid(npc_ent) then return end

    npc_ent:SetPos(pos)

    --
    -- This NPC has a special model we want to define
    --
    if npc_data.Model then
        npc_ent:SetModel(npc_data.Model)
    end

    --
    -- Spawn Flags
    --
    local spawn_flags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
    if npc_data.SpawnFlags then spawn_flags = bit.bor(spawn_flags, npc_data.SpawnFlags) end
    if npc_data.TotalSpawnFlags then spawn_flags = npc_data.TotalSpawnFlags end
    npc_ent:SetKeyValue("spawnflags", spawn_flags)

    --
    -- Optional Key Values
    --
    if npc_data.KeyValues then
        for k, v in pairs(npc_data.KeyValues) do
            npc_ent:SetKeyValue(k, v)
        end
    end

    --
    -- This NPC has a special skin we want to define
    --
    if npc_data.Skin then
        npc_ent:SetSkin(npc_data.Skin)
    end

    npc_ent:Spawn()
    npc_ent:Activate()

    if not npc_data.NoDrop and not npc_data.OnCeiling then
        npc_ent:DropToFloor()
    end

    return npc_ent
end

function Randomat:SpawnBee(ply, color, height)
    local spos = ply:GetPos() + Vector(math.random(-75, 75), math.random(-75, 75), height or math.random(200, 250))
    local headBee = Randomat:SpawnNPC(ply, spos, "npc_manhack")
    headBee:SetNPCState(NPC_STATE_ALERT)

    local bee = EntsCreate("prop_dynamic")
    bee:SetModel("models/lucian/props/stupid_bee.mdl")
    bee:SetPos(spos)
    bee:SetParent(headBee)
    if color and type(color) == "table" then
        bee:SetColor(color)
    end

    headBee:SetNoDraw(true)
    headBee:SetHealth(1000)
    return headBee
end

function Randomat:SpawnBarrel(pos, range, min_range, ignore_negative)
    local ent = EntsCreate("prop_physics")
    if not IsValid(ent) then return end

    if not min_range then
        min_range = range
    end

    local x = math.random(min_range, range)
    local y = math.random(min_range, range)
    if not ignore_negative then
        if math.random(0, 1) == 1 then x = -x end
        if math.random(0, 1) == 1 then y = -y end
    end

    ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
    ent:SetPos(pos + Vector(x, y, math.random(5, range)))
    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then ent:Remove() return end
end

--[[
 Randomat Meta
]]--

-- Skeleton

function randomat_meta:Begin(...) end

function randomat_meta:Condition()
    return true
end

function randomat_meta:Enabled()
    return GetConVar("ttt_randomat_" .. self.Id):GetBool()
end

function randomat_meta:GetConVars() end

function randomat_meta:BeforeEventTrigger(ply, options, ...) end

-- Players

-- Valid players not spec
function randomat_meta:GetPlayers(shuffle)
    return Randomat:GetPlayers(shuffle)
end

function randomat_meta:GetAlivePlayers(shuffle)
    return Randomat:GetPlayers(shuffle, true)
end

function randomat_meta:GetDeadPlayers(shuffle, include_spec)
    return Randomat:GetPlayers(shuffle, false, true, include_spec)
end

-- Notifications

function randomat_meta:SmallNotify(msg, length, targ, silent, allow_secret, font_color)
    Randomat:SmallNotify(msg, length, targ, silent, allow_secret, font_color)
end

-- Hooks

function randomat_meta:AddHook(hooktype, callbackfunc, suffix)
    callbackfunc = callbackfunc or self[hooktype]

    local id = "RandomatEvent." .. self.Id .. ":" .. hooktype
    if suffix and type(suffix) == "string" and #suffix > 0 then
        id = id .. ":" .. suffix
    end
    hook.Add(hooktype, id, function(...)
        return callbackfunc(...)
    end)

    self.Hooks = self.Hooks or {}

    table.insert(self.Hooks, {hooktype, id})
end

function randomat_meta:RemoveHook(hooktype, suffix)
    local id = "RandomatEvent." .. self.Id .. ":" .. hooktype
    if suffix and type(suffix) == "string" and #suffix > 0 then
        id = id .. ":" .. suffix
    end
    for idx, ahook in ipairs(self.Hooks or {}) do
        if ahook[1] == hooktype and ahook[2] == id then
            hook.Remove(ahook[1], ahook[2])
            table.remove(self.Hooks, idx)
            return
        end
    end
end

function randomat_meta:CleanUpHooks()
    if not self.Hooks then return end

    for _, ahook in ipairs(self.Hooks) do
        hook.Remove(ahook[1], ahook[2])
    end

    table.Empty(self.Hooks)
end

-- Roles

function randomat_meta:GetRoleName(ply, hide_secret_roles)
    local role = ply:GetRole()
    -- If this is an impersonator, use the correct role to hide them depending on whether they are activated
    if hide_secret_roles and CR_VERSION and ply:IsImpersonator() then
        -- If they are active, pretend they are a deputy
        if ply:IsRoleActive() then
            role = ROLE_DEPUTY
        -- Otherwise pretend they are a traitor because deputies (probably) can't buy anything and without this Communism will give them away
        else
            role = ROLE_TRAITOR
        end
    end
    return Randomat:GetRoleExtendedString(role, hide_secret_roles)
end

-- Weapons/Equipment

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

function randomat_meta:StripRoleWeapons(ply, skip_add_crowbar)
    if not IsValid(ply) then return end

    if ply.StripRoleWeapons then
        ply:StripRoleWeapons()
    else
        if ply:HasWeapon("weapon_hyp_brainwash") then
            ply:StripWeapon("weapon_hyp_brainwash")
        end
        if ply:HasWeapon("weapon_vam_fangs") then
            ply:StripWeapon("weapon_vam_fangs")
        end
        if ply:HasWeapon("weapon_zom_claws") then
            ply:StripWeapon("weapon_zom_claws")
        end
        if ply:HasWeapon("weapon_kil_knife") then
            ply:StripWeapon("weapon_kil_knife")
        end
        if ply:HasWeapon("weapon_kil_crowbar") then
            ply:StripWeapon("weapon_kil_crowbar")
        end
        if ply:HasWeapon("weapon_ttt_wtester") then
            ply:StripWeapon("weapon_ttt_wtester")
        end
    end

    if not skip_add_crowbar then
        ply:Give("weapon_zm_improvised")
    end
end

function randomat_meta:HandleWeaponAddAndSelect(ply, addweapons)
    local active_class = nil
    local active_kind = WEAPON_UNARMED
    if IsValid(ply:GetActiveWeapon()) then
        active_class = WEPS.GetClass(ply:GetActiveWeapon())
        active_kind = WEPS.TypeForWeapon(active_class)
    end

    -- Handle adding weapons
    addweapons(active_class, active_kind)

    -- Try to find the correct weapon to select so the transition is less jarring
    local select_class = nil
    for _, w in ipairs(ply:GetWeapons()) do
        local w_class = WEPS.GetClass(w)
        local w_kind = WEPS.TypeForWeapon(w_class)
        if (active_class ~= nil and w_class == active_class) or w_kind == active_kind then
            select_class = w_class
        end
    end

    -- Only try to select a weapon if one was found
    if select_class ~= nil then
        -- Delay seems to be necessary to reliably change weapons after having them all added
        timer.Simple(0.25, function()
            ply:SelectWeapon(select_class)
        end)
    -- Otherwise switch to unarmed to we don't show other players our potentially-illegal first weapon (e.g. Killer's knife)
    else
        ply:SelectWeapon("weapon_ttt_unarmed")
    end
end

function randomat_meta:HandleWeaponPAP(weap, upgrade)
    -- If PAP is installed, this weapon was given successfully, and the old one was PAP'd, then PAP the new one too
    if not TTTPAP then return end
    if not upgrade then return end
    if not IsValid(weap) then return end

    TTTPAP:ApplyUpgrade(weap, upgrade)
end

function randomat_meta:SwapWeapons(ply, weapon_list)
    local role_weapons = {}
    local new_cr = false
    -- If this is a version of CR for TTT that has role weapons defined, keep track of them
    if WEAPON_CATEGORY_ROLE then
        new_cr = true
        for _, w in ipairs(ply:GetWeapons()) do
            if w.Category == WEAPON_CATEGORY_ROLE then
                table.insert(role_weapons, w)
            end
        end
    end

    -- Hardcode these for backwards compatibility
    local had_brainwash = ply:HasWeapon("weapon_hyp_brainwash")
    local had_scanner = ply:HasWeapon("weapon_ttt_wtester")
    local old_unarmed = ply:GetWeapon("weapon_ttt_unarmed")
    local old_carry = ply:GetWeapon("weapon_zm_carry")
    local old_improvised = ply:GetWeapon("weapon_zm_improvised")
    self:HandleWeaponAddAndSelect(ply, function()
        ply:StripWeapons()
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)

        -- Have roles keep their special weapons if we're not already tracking them in the role_weapons table
        if not new_cr then
            if ply:GetRole() == ROLE_ZOMBIE then
                ply:Give("weapon_zom_claws")
            elseif ply:GetRole() == ROLE_VAMPIRE then
                ply:Give("weapon_vam_fangs")
            elseif had_brainwash then
                ply:Give("weapon_hyp_brainwash")
            elseif had_scanner then
                ply:Give("weapon_ttt_wtester")
            elseif ply:GetRole() == ROLE_KILLER then
                if ConVarExists("ttt_killer_knife_enabled") and GetConVar("ttt_killer_knife_enabled"):GetBool() then
                    ply:Give("weapon_kil_knife")
                end
                if ConVarExists("ttt_killer_crowbar_enabled") and GetConVar("ttt_killer_crowbar_enabled"):GetBool() then
                    ply:StripWeapon("weapon_zm_improvised")
                    ply:Give("weapon_kil_crowbar")
                end
            end
        end

        -- Give their role weapon(s) back
        for _, v in ipairs(role_weapons) do
            self:HandleWeaponPAP(ply:Give(WEPS.GetClass(v)), v.PAPUpgrade)
        end

        -- Make sure everyone has these weapons
        -- Roles that shouldn't, like the non-prime Zombie, won't be able to pick them up anyway
        self:HandleWeaponPAP(ply:Give("weapon_ttt_unarmed"), old_unarmed.PAPUpgrade)
        self:HandleWeaponPAP(ply:Give("weapon_zm_carry"), old_carry.PAPUpgrade)
        self:HandleWeaponPAP(ply:Give("weapon_zm_improvised"), old_improvised.PAPUpgrade)

        -- Handle inventory weapons last to make sure the roles get their specials
        for _, v in ipairs(weapon_list) do
            local wep_class = WEPS.GetClass(v)
            -- Don't give players the detective's tester or other role weapons
            if wep_class ~= "weapon_ttt_wtester" and (not WEAPON_CATEGORY_ROLE or v.Category ~= WEAPON_CATEGORY_ROLE) then
                self:HandleWeaponPAP(ply:Give(wep_class), v.PAPUpgrade)
            end
        end
    end)
end

-- Players

function randomat_meta:SetAllPlayerScales(scale)
    for _, ply in ipairs(self:GetAlivePlayers()) do
        Randomat:SetPlayerScale(ply, scale, self.Id)
    end

    -- Reduce the player speed on the server
    self:AddHook("TTTSpeedMultiplier", function(ply, mults)
        if not ply:Alive() or ply:IsSpec() then return end
        local speed_factor = math.Clamp(ply:GetStepSize() / 9, 0.25, 1)
        table.insert(mults, speed_factor)
    end)
end

function randomat_meta:ResetAllPlayerScales()
    for _, ply in PlayerIterator() do
        Randomat:ResetPlayerScale(ply, self.Id)
    end

    self:RemoveHook("TTTSpeedMultiplier")
end

function randomat_meta:AddCullingBypass(ply_pred, tgt_pred)
    self:AddHook("SetupPlayerVisibility", function(ply)
        if ply.ShouldBypassCulling and not ply:ShouldBypassCulling() then return end
        if ply_pred and not ply_pred(ply) then return end

        for _, v in PlayerIterator() do
            if tgt_pred and not tgt_pred(ply, v) then continue end
            if ply:TestPVS(v) then continue end

            local pos = v:GetPos()
            if not ply.IsOnScreen or ply:IsOnScreen(pos) then
                AddOriginToPVS(pos)
            end
        end
    end, "Players")
end

-- Entities

function randomat_meta:AddEntityCullingBypass(ply_pred, tgt_pred, class)
    self:AddHook("SetupPlayerVisibility", function(ply)
        if ply.ShouldBypassCulling and not ply:ShouldBypassCulling() then return end
        if ply_pred and not ply_pred(ply) then return end

        local ent_table
        if class then
            ent_table = EntsFindByClass(class)
        else
            ent_table = GetAllEnts()
        end

        for _, v in ipairs(ent_table) do
            if tgt_pred and not tgt_pred(ply, v) then continue end
            if ply:TestPVS(v) then continue end

            local pos = v:GetPos()
            if not ply.IsOnScreen or ply:IsOnScreen(pos) then
                AddOriginToPVS(pos)
            end
        end
    end, "Entities")
end

-- Misc.

function randomat_meta:NotifyTeamChange(newMembers, roleTeam)
    -- This method only works with CR for TTT
    if not CR_VERSION then return end
    if #newMembers <= 0 then return end

    local members = Randomat:GetPlayerNameListString(newMembers, true)
    local verb = " has "
    if #newMembers > 1 then
        verb = " have "
    end

    -- Delay this message slightly in case it's being shown when an event starts
    -- The delay pushes it below the event description chat message
    timer.Simple(0.1, function()
        local extendedReason = " due to being a role incompatible with a running event"

        local joinedTeamMessage = members .. verb .. "joined your team"
        local extendedJoinedTeamMessage = joinedTeamMessage .. extendedReason

        local changedTeamMessage = "You have joined the " .. Randomat:GetRoleTeamName(roleTeam) .. " team"
        local extendedChangedTeamMessage = changedTeamMessage .. extendedReason

        player.ExecuteAgainstTeamPlayers(roleTeam, true, false, function(ply)
            -- Tell players that changed teams what team they joined and why
            if table.HasValue(newMembers, ply) then
                Randomat:PrintMessage(ply, MSG_PRINTCENTER, changedTeamMessage)
                ply:PrintMessage(HUD_PRINTTALK, extendedChangedTeamMessage)
            -- Tell members of their new team who has joined them
            else
                Randomat:PrintMessage(ply, MSG_PRINTCENTER, joinedTeamMessage)
                ply:PrintMessage(HUD_PRINTTALK, extendedJoinedTeamMessage)
            end
        end)
    end)
end

-- Credit to The Stig
function randomat_meta:DisableRoundEndSounds()
    -- Disables round end sounds mod and 'Ending Flair' event
    -- So events that that play sounds at the end of the round can do so without overlapping with other sounds/music
    SetGlobalBool("StopEndingFlairRandomat", true)
    local roundEndSounds = false

    if ConVarExists("ttt_roundendsounds") and GetConVar("ttt_roundendsounds"):GetBool() then
        GetConVar("ttt_roundendsounds"):SetBool(false)
        roundEndSounds = true
    end

    self:AddHook("TTTEndRound", function()
        -- Re-enable round end sounds and 'Ending Flair' event
        timer.Simple(1, function()
            SetGlobalBool("StopEndingFlairRandomat", false)

            -- Don't turn on round end sounds if they weren't on already
            if roundEndSounds then
                GetConVar("ttt_roundendsounds"):SetBool(true)
            end
        end)
    end, "DisableRoundEndSounds")
end

--[[
 Commands
]]--

local function ClearAutoComplete(cmd, args)
    local name = string.Trim(args):lower()
    local options = {}
    for _, v in pairs(Randomat.ActiveEvents) do
        if string.find(v.Id:lower(), name) then
            table.insert(options, cmd .. " " .. v.Id)
        end
    end
    return options
end

concommand.Add("ttt_randomat_clearevent", function(ply, cc, arg)
    local cmd = arg[1]
    if not cmd or #cmd == 0 then
        ErrorNoHalt("Required 'ID' parameter not provided")
        return
    end
    Randomat:EndActiveEvent(cmd)
    CallHook("TTTRandomatCommand", nil, ply, cc, arg)
end, ClearAutoComplete, "Clears a specific randomat active event", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_clearevents", function(ply, cc, arg)
    Randomat:EndActiveEvents()
    CallHook("TTTRandomatCommand", nil, ply, cc, arg)
end, nil, "Clears all active events", FCVAR_SERVER_CAN_EXECUTE)

local function TriggerAutoComplete(cmd, args)
    local name = string.Trim(args):lower()
    local options = {}
    for _, v in pairs(Randomat.Events) do
        if string.find(v.Id:lower(), name) then
            table.insert(options, cmd .. " " .. v.Id)
        end
    end
    return options
end

concommand.Add("ttt_randomat_safetrigger", function(ply, cc, arg)
    Randomat:SafeTriggerEvent(arg[1], nil, true)
    CallHook("TTTRandomatCommand", nil, ply, cc, arg)
end, TriggerAutoComplete, "Triggers a specific randomat event with conditions", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_trigger", function(ply, cc, arg)
    Randomat:TriggerEvent(arg[1], nil)
    CallHook("TTTRandomatCommand", nil, ply, cc, arg)
end, TriggerAutoComplete, "Triggers a specific randomat event without conditions", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_triggerrandom", function(ply, cc, arg)
    local rdmply = Randomat:GetValidPlayer(nil)
    Randomat:TriggerRandomEvent(rdmply)
    CallHook("TTTRandomatCommand", nil, ply, cc, arg)
end, nil, "Triggers a random  randomat event", FCVAR_SERVER_CAN_EXECUTE)

--[[
 Override TTT Stuff
]]--

hook.Add("TTTEndRound", "RandomatEndRound", function()
    Randomat:EndActiveEvents()
    PrintSecretEventsList()
end)
hook.Add("TTTPrepareRound", "RandomatPrepareRound", function()
    -- End ALL events rather than just active ones to prevent some event effects which maintain over map changes
    for _, v in pairs(Randomat.Events) do
        EndEvent(v, true)
    end
end)
hook.Add("ShutDown", "RandomatMapChange", function()
    Randomat:EndActiveEvents()
end)