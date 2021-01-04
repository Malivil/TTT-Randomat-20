util.AddNetworkString("randomat_message")
util.AddNetworkString("randomat_message_silent")
util.AddNetworkString("AlertTriggerFinal")
util.AddNetworkString("alerteventtrigger")

if SERVER then
    util.AddNetworkString("TTT_RoleChanged")
    util.AddNetworkString("TTT_LogInfo")
end

ROLE_MERCENARY = ROLE_MERCENARY or ROLE_SURVIVALIST or -1
ROLE_PHANTOM = ROLE_PHANTOM or ROLE_PHOENIX or -1
ROLE_KILLER = ROLE_KILLER or ROLE_SERIALKILLER or -1
ROLE_ZOMBIE = ROLE_ZOMBIE or ROLE_INFECTED or -1
ROLE_SWAPPER = ROLE_SWAPPER or -1
ROLE_GLITCH = ROLE_GLITCH or -1
ROLE_HYPNOTIST = ROLE_HYPNOTIST or -1
ROLE_ASSASSIN = ROLE_ASSASSIN or -1
ROLE_DETRAITOR = ROLE_DETRAITOR or -1
ROLE_VAMPIRE = ROLE_VAMPIRE or -1

Randomat.Events = Randomat.Events or {}
Randomat.ActiveEvents = {}

local randomat_meta =  {}
randomat_meta.__index = randomat_meta

local function EndEvent(evt)
    evt:End()
    evt:CleanUpHooks()
end

local function TriggerEvent(event, ply, silent, ...)
    if not silent then
        Randomat:EventNotify(event.Title)
    end

    local owner = Randomat:GetValidPlayer(ply)
    local index = #Randomat.ActiveEvents + 1
    Randomat.ActiveEvents[index] = event
    Randomat.ActiveEvents[index].owner = owner
    Randomat.ActiveEvents[index]:Begin(...)

    -- Run this after the "Begin" so we have the latest title and description
    if SERVER then
        local title = Randomat:GetEventTitle(event)
        net.Start("TTT_LogInfo")
        net.WriteString("Randomat event '" .. title .. "' (" .. event.Id .. ") started by " .. owner:Nick())
        net.Broadcast()

        if not silent and event.Description ~= nil and string.len(event.Description) > 0 then
            if GetConVar("ttt_randomat_event_hint"):GetBool() then
                Randomat:SmallNotify(event.Description)
            end
            if GetConVar("ttt_randomat_event_hint_chat"):GetBool() then
                for _, p in pairs(player.GetAll()) do
                    p:PrintMessage(HUD_PRINTTALK, "[RANDOMAT] " .. title .. " | " .. event.Description)
                end
            end
        end
    end
end

local function ClearAutoComplete(cmd, args)
    local name = string.lower(string.Trim(args))
    local options = {}
    for _, v in pairs(Randomat.ActiveEvents) do
        if string.find(string.lower(v.Id), name) then
            table.insert(options, cmd .. " " .. v.Id)
        end
    end
    return options
end

concommand.Add("ttt_randomat_clearevent", function(ply, cc, arg)
    local cmd = arg[1]
    Randomat:EndActiveEvent(cmd)
end, ClearAutoComplete, "Clears a specific randomat active event", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_clearevents",function(ply, cc, arg)
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            EndEvent(evt)
        end

        Randomat.ActiveEvents = {}
    end
end, nil, "Clears all active events", FCVAR_SERVER_CAN_EXECUTE)

function Randomat:EndActiveEvent(id)
    for k, evt in pairs(Randomat.ActiveEvents) do
        if evt.Id == id then
            EndEvent(evt)
            table.remove(Randomat.ActiveEvents, k)
            return
        end
    end

    error("Could not find active event '" .. id .. "'")
end

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

function Randomat:GetPlayers(shuffle, alive)
    local plys = {}
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and (not ply:IsSpec()) and (not alive or ply:Alive()) then
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

    return Randomat:GetPlayers(true, true)[1]
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
    -- Default SingleUse to true if it isn't specified
    if tbl.SingleUse ~= false then
        tbl.SingleUse = true
    end
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

function Randomat:CanEventRun(event)
    return event:Enabled() and event:Condition() and (not event.SingleUse or not Randomat:IsEventActive(event.Id))
end

function Randomat:TriggerRandomEvent(ply)
    local events = Randomat.Events

    local found = false
    for _, v in pairs(events) do
        if Randomat:CanEventRun(v) then
            found = true
            break
        end
    end

    if not found then
        error("Could not find valid event, consider enabling more")
    end

    local event = GetRandomEvent(events)
    while not Randomat:CanEventRun(event) do
        event = GetRandomEvent(events)
    end

    TriggerEvent(event, ply, false)
end

function Randomat:TriggerEvent(cmd, ply, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        TriggerEvent(event, ply, false, ...)
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:SafeTriggerEvent(cmd, ply, error_if_unsafe, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        if Randomat:CanEventRun(event) then
            TriggerEvent(event, ply, false, ...)
        elseif error_if_unsafe then
            error("Conditions for event not met")
        end
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

function Randomat:SilentTriggerEvent(cmd, ply, ...)
    if Randomat.Events[cmd] ~= nil then
        local event = Randomat.Events[cmd]
        TriggerEvent(event, ply, true, ...)
    else
        error("Could not find event '" .. cmd .. "'")
    end
end

local function TriggerAutoComplete(cmd, args)
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
    Randomat:SafeTriggerEvent(arg[1], nil, true)
end, TriggerAutoComplete, "Triggers a specific randomat event with conditions", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_trigger", function(ply, cc, arg)
    Randomat:TriggerEvent(arg[1], nil)
end, TriggerAutoComplete, "Triggers a specific randomat event without conditions", FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("ttt_randomat_triggerrandom", function()
    local rdmply = Randomat:GetValidPlayer(nil)
    Randomat:TriggerRandomEvent(rdmply)
end, nil, "Triggers a random  randomat event", FCVAR_SERVER_CAN_EXECUTE)

if SERVER then
    function Randomat:SmallNotify(msg, length, targ)
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

local function GetRandomRoleWeapon(roles, blocklist)
    local selected = math.random(1,#roles)
    local tbl = table.Copy(EquipmentItems[roles[selected]])
    for _, v in pairs(weapons.GetList()) do
        if v and v.CanBuy and not table.HasValue(blocklist, v.ClassName) then
            table.insert(tbl, v)
        end
    end
    table.Shuffle(tbl)

    local item = table.Random(tbl)
    local item_id = tonumber(item.id)
    local swep_table = (not item_id) and weapons.GetStored(item.ClassName) or nil
    return item, item_id, swep_table
end

local function GiveWep(ply, roles, blocklist, include_equipment, tracking, settrackingvar, onitemgiven)
    if tracking == nil then tracking = 0 end
    if tracking >= 500 then return end
    tracking = tracking + 1
    settrackingvar(tracking)

    local item, item_id, swep_table = GetRandomRoleWeapon(roles, blocklist)
    if item_id then
        -- If this is an item and we shouldn't give players items or the player already has this item, try again
        if not include_equipment or ply:HasEquipmentItem(item_id) then
            GiveWep(ply, roles, blocklist, include_equipment, tracking, settrackingvar, onitemgiven)
        -- Otherwise give it to them
        else
            ply:GiveEquipmentItem(item_id)
            onitemgiven(true, item_id)
            settrackingvar(0)
        end
    elseif swep_table then
        -- If this player can use this weapon, give it to them
        if ply:CanCarryWeapon(swep_table) then
            ply:Give(item.ClassName)
            onitemgiven(false, item.ClassName)
            if swep_table.WasBought then
                swep_table:WasBought(ply)
            end
            settrackingvar(0)
        -- Otherwise try again
        else
            GiveWep(ply, roles, blocklist, include_equipment, tracking, settrackingvar, onitemgiven)
        end
    end
end

function Randomat:GiveRandomShopItem(ply, roles, blocklist, include_equipment, gettrackingvar, settrackingvar, onitemgiven)
    GiveWep(ply, roles, blocklist, include_equipment, gettrackingvar(), settrackingvar, onitemgiven)
end

--[[
 Randomat Meta
]]--

-- Valid players not spec
function randomat_meta:GetPlayers(shuffle)
    return Randomat:GetPlayers(shuffle, false)
end

function randomat_meta:GetAlivePlayers(shuffle)
    return Randomat:GetPlayers(shuffle, true)
end

if SERVER then
    function randomat_meta:SmallNotify(msg, length, targ)
        Randomat:SmallNotify(msg, length, targ)
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

function randomat_meta:Begin(...) end

function randomat_meta:End() end

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
function randomat_meta:GetRoleName(ply, hide_detraitor)
    if ply:GetRole() == ROLE_TRAITOR then
        return "A traitor"
    elseif ply:GetRole() == ROLE_HYPNOTIST then
        return "A hypnotist"
    elseif ply:GetRole() == ROLE_ASSASSIN then
        return "An assassin"
    elseif ply:GetRole() == ROLE_DETECTIVE or (ply:GetRole() == ROLE_DETRAITOR and hide_detraitor) then
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
    elseif ply:GetRole() == ROLE_DETRAITOR then
        return "A detraitor"
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

function randomat_meta:StripRoleWeapons(ply)
    if not IsValid(ply) then return end
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
    if ply:HasWeapon("weapon_ttt_wtester") then
        ply:StripWeapon("weapon_ttt_wtester")
    end
end

function randomat_meta:CreateCmd(str, val, desc, slider)
    CreateConVar("randomat_"..self.id..str, val, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, desc)
    if not self.cmds then
        self.cmds = {}
    end
    table.insert(self.cmds, {})
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
    end
end

--[[
 Override TTT Stuff
]]--
hook.Add("TTTEndRound", "RandomatEndRound", function()
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            EndEvent(evt)
        end

        Randomat.ActiveEvents = {}
    end
end)

hook.Add("TTTPrepareRound", "RandomatEndRound", function()
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            EndEvent(evt)
        end

        Randomat.ActiveEvents = {}
    end
end)

