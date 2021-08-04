util.AddNetworkString("randomat_message")
util.AddNetworkString("randomat_message_silent")
util.AddNetworkString("AlertTriggerFinal")
util.AddNetworkString("alerteventtrigger")
util.AddNetworkString("RdmtSetSpeedMultiplier")
util.AddNetworkString("RdmtSetSpeedMultiplier_WithWeapon")
util.AddNetworkString("RdmtRemoveSpeedMultiplier")
util.AddNetworkString("RdmtRemoveSpeedMultipliers")
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

Randomat.Events = Randomat.Events or {}
Randomat.ActiveEvents = {}

local randomat_meta =  {}
randomat_meta.__index = randomat_meta

local function EndEvent(evt)
    evt:CleanUpHooks()
    evt:End()
end

local function NotifyDescription(event)
    -- Show this if "secret" is active if we're specifically showing the description for "secret"
    if event.Id ~= "secret" and Randomat:IsEventActive("secret") then return end
    net.Start("randomat_message")
    net.WriteBool(false)
    net.WriteString(event.Description)
    net.WriteUInt(0, 8)
    net.Broadcast()
end

local function ChatDescription(ply, event, has_description)
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

local function TriggerEvent(event, ply, silent, ...)
    if not silent then
        -- If this event is supposed to start secretly, trigger "secret" with this specific event chosen
        -- Unless "secret" is already running in which case we don't care, just let it go
        if event.StartSecret and not Randomat:IsEventActive("secret") then
            TriggerEvent(Randomat.Events["secret"], ply, false, event.id)
            return
        end

        Randomat:EventNotify(event.Title)
    end

    local owner = Randomat:GetValidPlayer(ply)
    local index = #Randomat.ActiveEvents + 1
    Randomat.ActiveEvents[index] = event
    Randomat.ActiveEvents[index].owner = owner
    Randomat.ActiveEvents[index]:Begin(...)

    -- Run this after the "Begin" so we have the latest title and description
    local title = Randomat:GetEventTitle(event)
    Randomat:LogEvent("[RANDOMAT] Event '" .. title .. "' (" .. event.Id .. ") started by " .. owner:Nick())

    if not silent then
        local has_description = event.Description ~= nil and #event.Description > 0
        if has_description and GetConVar("ttt_randomat_event_hint"):GetBool() then
            -- Show the small description message but don't use SmallNotify because it specifically mutes when "secret" is running and we want to show this if this event IS "secret"
            NotifyDescription(event)
        end
        if GetConVar("ttt_randomat_event_hint_chat"):GetBool() then
            for _, p in ipairs(player.GetAll()) do
                ChatDescription(p, event, has_description)
            end
        end
    end
end

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

function Randomat:GetPlayers(shuffle, alive_only, dead_only)
    local plys = {}
    -- Optimize this to get the full raw list if both alive and dead should be included
    if alive_only == dead_only then
        plys = player.GetAll()
    else
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and
            -- Anybody
            ((not alive_only and not dead_only) or
            -- Alive and non-spec
                (alive_only and (ply:Alive() and not ply:IsSpec())) or
            -- Dead or spec
                (dead_only and (not ply:Alive() or ply:IsSpec()))) then
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

function Randomat:SetRole(ply, role)
    -- Reset the Veteran damage bonus
    if ply:GetRole() == ROLE_VETERAN and role ~= ROLE_VETERAN then
        ply:SetNWBool("VeteranActive", false)
    end
    -- Heal the Old Man back to full when they are converted
    if ply:GetRole() == ROLE_OLDMAN and role ~= ROLE_OLDMAN then
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
    end
    ply:SetRole(role)

    net.Start("TTT_RoleChanged")
    net.WriteString(ply:SteamID64())
    net.WriteUInt(role, 8)
    net.Broadcast()
end

function Randomat:register(tbl)
    local id = tbl.id
    tbl.Id = id
    tbl.__index = tbl
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
    setmetatable(tbl, randomat_meta)

    Randomat.Events[id] = tbl

    CreateConVar("ttt_randomat_"..id, 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
    CreateConVar("ttt_randomat_"..id.."_min_players", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
    local weight = CreateConVar("ttt_randomat_"..id.."_weight", -1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
    local default_weight = GetConVar("ttt_randomat_event_weight"):GetInt()

    -- If the current weight matches the default, update the per-event weight to the new default of -1
    if weight:GetInt() == default_weight then
        print("Event '" .. id .. "' weight (" .. weight:GetInt() .. ") matches default weight (" .. default_weight .. "), resetting to -1")
        weight:SetInt(-1)
    end
end

function Randomat:unregister(id)
    if not Randomat.Events[id] then return end
    Randomat.Events[id] = nil
end

function Randomat:CanEventRun(event)
    if type(event) ~= "table" then
        event = Randomat.Events[event]
    end
    if event == nil then return false end

    -- Don't allow multiple events of the same type to run at once
    if event.Type ~= EVENT_TYPE_DEFAULT then
        for _, evt in pairs(Randomat.ActiveEvents) do
            if type(evt.Type) == "table" then
                -- If both are tables don't allow any matching types
                if type(event.Type) == "table" then
                    for _, t in ipairs(event.Type) do
                        if table.HasValue(evt.Type, t) then
                            return false
                        end
                    end
                -- If only one is a table, don't allow it to contain the other's type
                elseif table.HasValue(evt.Type, event.Type) then
                    return false
                end
            -- If only one is a table, don't allow it to contain the other's type
            elseif type(event.Type) == "table" then
                if table.HasValue(event.Type, evt.Type) then
                    return false
                end
            -- If neither are tables, don't allow the types to match
            elseif evt.Type == event.Type then
                return false
            end
        end
    end

    local min_players = GetConVar("ttt_randomat_"..event.Id.."_min_players"):GetInt()
    local player_count = player.GetCount()
    return event:Enabled() and event:Condition() and (min_players <= 0 or player_count >= min_players) and (not event.SingleUse or not Randomat:IsEventActive(event.Id))
end

local function GetRandomWeightedEvent(events)
    local weighted_events = {}
    for id, _ in pairs(events) do
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

function Randomat:GetRandomEvent()
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

    local event = GetRandomWeightedEvent(events)
    while not Randomat:CanEventRun(event) do
        event = GetRandomWeightedEvent(events)
    end
    return event
end

function Randomat:TriggerRandomEvent(ply)
    local event = Randomat:GetRandomEvent()
    TriggerEvent(event, ply, false)
end

function Randomat:SilentTriggerRandomEvent(ply)
    local event = Randomat:GetRandomEvent()
    TriggerEvent(event, ply, true)
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

function Randomat:ChatNotify(ply, msg)
    if Randomat:IsEventActive("secret") then return end
    if not IsValid(ply) then return end
    ply:PrintMessage(HUD_PRINTTALK, msg)
end

function Randomat:LogEvent(msg)
    net.Start("TTT_LogInfo")
    net.WriteString(msg)
    net.Broadcast()
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

local function GetRandomRoleWeapon(roles, blocklist, droppable_only)
    local selected = math.random(1, #roles)
    local tbl = table.Copy(EquipmentItems[roles[selected]]) or {}
    for _, v in ipairs(weapons.GetList()) do
        if v and not v.Spawnable and v.CanBuy and
            (type(droppable_only) ~= "boolean" or not droppable_only or v.AllowDrop) and
            (not blocklist or not table.HasValue(blocklist, v.ClassName)) then
            table.insert(tbl, v)
        end
    end
    table.Shuffle(tbl)

    local item = table.Random(tbl)
    local item_id = tonumber(item.id)
    local swep_table = (not item_id) and weapons.GetStored(item.ClassName) or nil
    return item, item_id, swep_table
end

function Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
    if tracking == nil then tracking = 0 end
    if tracking >= 500 then return nil, nil, nil end
    tracking = tracking + 1
    settrackingvar(tracking)

    local item, item_id, swep_table = GetRandomRoleWeapon(roles, blocklist, droppable_only)
    if item_id then
        -- If this is an item and we shouldn't get players items or the player already has this item, try again
        if not include_equipment or ply:HasEquipmentItem(item_id) then
            return Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
        -- Otherwise return it
        else
            settrackingvar(0)
            return item, item_id, swep_table
        end
    elseif swep_table then
        -- If this player can use this weapon, give it to them
        if ply:CanCarryWeapon(swep_table) then
            settrackingvar(0)
            return item, item_id, swep_table
        -- Otherwise try again
        else
            return Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
        end
    end
    return nil, nil, nil
end

local function GiveWep(ply, roles, blocklist, include_equipment, tracking, settrackingvar, onitemgiven, droppable_only)
    local item, item_id, swep_table = Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)
    -- Give the player whatever was found
    if item_id then
        onitemgiven(true, item_id)
        ply:GiveEquipmentItem(item_id)
    elseif swep_table then
        onitemgiven(false, item.ClassName)
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
    net.Start("TTT_BoughtItem")
    net.WriteBit(isequip)
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

function Randomat:RemoveEquipmentItem(ply, item_id)
    -- Keep track of what equipment the player had
    local i = 1
    local equip = {}
    local credits = 0
    local removed = false
    while i < EQUIP_MAX do
        if ply:HasEquipmentItem(i) then
            -- Remove and refund the specific equipment item we're removing
            if i == item_id then
                removed = true
                credits = credits + 1
            else
                table.insert(equip, i)
            end
        end
        -- Double the index since this is a bit-mask
        i = i * 2
    end

    -- Give the player enough credits to compensate for the equipment they can no longer use
    ply:AddCredits(credits)

    -- Remove all their equipment
    ply:ResetEquipment()

    -- Add back the others (since we only want to remove the given item)
    for _, id in ipairs(equip) do
        ply:GiveEquipmentItem(id)
    end

    return removed
end

function Randomat:SpawnBee(ply, color)
    local spos = ply:GetPos() + Vector(math.random(-75,75), math.random(-75,75), math.random(200,250))
    local headBee = SpawnNPC(ply, spos, "npc_manhack")
    headBee:SetNPCState(2)

    local bee = ents.Create("prop_dynamic")
    bee:SetModel("models/lucian/props/stupid_bee.mdl")
    bee:SetPos(spos)
    bee:SetParent(headBee)
    if color and type(color) == "table" then
        bee:SetColor(color)
    end

    headBee:SetNoDraw(true)
    headBee:SetHealth(1000)
end

--[[
 Randomat Meta
]]--

-- Valid players not spec
function randomat_meta:GetPlayers(shuffle)
    return Randomat:GetPlayers(shuffle)
end

function randomat_meta:GetAlivePlayers(shuffle)
    return Randomat:GetPlayers(shuffle, true)
end

function randomat_meta:GetDeadPlayers(shuffle)
    return Randomat:GetPlayers(shuffle, false, true)
end

function randomat_meta:SmallNotify(msg, length, targ)
    Randomat:SmallNotify(msg, length, targ)
end

function randomat_meta:AddHook(hooktype, callbackfunc)
    callbackfunc = callbackfunc or self[hooktype]

    hook.Add(hooktype, "RandomatEvent." .. self.Id .. ":" .. hooktype, function(...)
        return callbackfunc(...)
    end)

    self.Hooks = self.Hooks or {}

    table.insert(self.Hooks, {hooktype, "RandomatEvent." .. self.Id .. ":" .. hooktype})
end

function randomat_meta:RemoveHook(hooktype)
    local id = "RandomatEvent." .. self.Id .. ":" .. hooktype
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
function randomat_meta:GetRoleName(ply, hide_secret_roles)
    local role = ply:GetRole()
    if role == ROLE_TRAITOR then
        return "A traitor"
    elseif role == ROLE_HYPNOTIST then
        return "A hypnotist"
    elseif role == ROLE_ASSASSIN then
        return "An assassin"
    -- Hide detraitors so they don't get outed
    elseif role == ROLE_DETECTIVE or (hide_secret_roles and role == ROLE_DETRAITOR) then
        return "A detective"
    elseif role == ROLE_MERCENARY then
        return "A mercenary"
    elseif role == ROLE_ZOMBIE then
        return "A zombie"
    elseif role == ROLE_VAMPIRE then
        return "A vampire"
    elseif role == ROLE_KILLER then
        return "A killer"
    elseif role == ROLE_INNOCENT then
        return "An innocent"
    elseif role == ROLE_GLITCH then
        return "A glitch"
    elseif role == ROLE_PHANTOM then
        return "A phantom"
    -- Hide imposters so they don't get outed
    elseif role == ROLE_DEPUTY or (hide_secret_roles and role == ROLE_IMPERSONATOR) then
        return "A deputy"
    end

    -- Use the role strings for every other role
    local role_string = ROLE_STRINGS_EXT and ROLE_STRINGS_EXT[role] or nil
    if role_string then
        return role_string:sub(1, 1):upper() .. role_string:sub(2):lower()
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
    if ply:HasWeapon("weapon_bod_bodysnatch") then
        ply:StripWeapon("weapon_bod_bodysnatch")
    end
    if ply:HasWeapon("weapon_doc_defib") then
        ply:StripWeapon("weapon_doc_defib")
    end
    if ply:GetRole() == ROLE_DOCTOR and ply:HasWeapon("weapon_ttt_health_station") and GetConVar("ttt_doctor_mode"):GetInt() == DOCTOR_MODE_STATION then
        ply:StripWeapon("weapon_ttt_health_station")
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
    if ply:HasWeapon("weapon_qua_bomb_station") then
        ply:StripWeapon("weapon_qua_bomb_station")
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

function randomat_meta:SwapWeapons(ply, weapons, from_killer)
    local had_brainwash = ply:HasWeapon("weapon_hyp_brainwash")
    local had_bodysnatch = ply:HasWeapon("weapon_bod_bodysnatch")
    local had_doctor_defib = ply:HasWeapon("weapon_doc_defib")
    local had_doctor_station = ply:GetRole() == ROLE_DOCTOR and ply:HasWeapon("weapon_ttt_health_station") and GetConVar("ttt_doctor_mode"):GetInt() == DOCTOR_MODE_STATION
    local had_bomb_station = ply:HasWeapon("weapon_qua_bomb_station")
    local had_scanner = ply:HasWeapon("weapon_ttt_wtester")
    self:HandleWeaponAddAndSelect(ply, function()
        ply:StripWeapons()
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)

        -- Have roles keep their special weapons
        if ply:GetRole() == ROLE_ZOMBIE then
            ply:Give("weapon_zom_claws")
        elseif ply:GetRole() == ROLE_VAMPIRE then
            ply:Give("weapon_vam_fangs")
        elseif had_brainwash then
            ply:Give("weapon_hyp_brainwash")
        elseif had_bodysnatch then
            ply:Give("weapon_bod_bodysnatch")
        elseif had_scanner then
            ply:Give("weapon_ttt_wtester")
        elseif had_doctor_defib then
            ply:Give("weapon_doc_defib")
        elseif had_doctor_station then
            ply:Give("weapon_ttt_health_station")
        elseif had_bomb_station then
            ply:Give("weapon_qua_bomb_station")
        elseif ply:GetRole() == ROLE_KILLER then
            if ConVarExists("ttt_killer_knife_enabled") and GetConVar("ttt_killer_knife_enabled"):GetBool() then
                ply:Give("weapon_kil_knife")
            end
            if ConVarExists("ttt_killer_crowbar_enabled") and GetConVar("ttt_killer_crowbar_enabled"):GetBool() then
                ply:StripWeapon("weapon_zm_improvised")
                ply:Give("weapon_kil_crowbar")
            end
        end

        -- If the player that swapped to this player was a killer then they no longer have a crowbar
        if from_killer then
            ply:Give("weapon_zm_improvised")
        end

        -- Handle inventory weapons last to make sure the roles get their specials
        for _, v in ipairs(weapons) do
            local wep_class = WEPS.GetClass(v)
            -- Don't give players the detective's tester
            if wep_class ~= "weapon_ttt_wtester" then
                ply:Give(wep_class)
            end
        end
    end)
end

function randomat_meta:SetAllPlayerScales(scale)
    for _, ply in ipairs(self:GetAlivePlayers()) do
        Randomat:SetPlayerScale(ply, scale, self.id)
    end

    -- Reduce the player speed on the server
    self:AddHook("TTTSpeedMultiplier", function(ply, mults)
        if not ply:Alive() or ply:IsSpec() then return end
        local speed_factor = math.Clamp(ply:GetStepSize() / 9, 0.25, 1)
        table.insert(mults, speed_factor)
    end)
end

function randomat_meta:ResetAllPlayerScales()
    for _, ply in ipairs(self:GetAlivePlayers()) do
        Randomat:ResetPlayerScale(ply, self.id)
    end

    self:RemoveHook("TTTSpeedMultiplier")
end

--[[
 Commands
]]--

local function EndActiveEvents()
    if Randomat.ActiveEvents ~= {} then
        for _, evt in pairs(Randomat.ActiveEvents) do
            EndEvent(evt)
        end

        Randomat.ActiveEvents = {}
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

concommand.Add("ttt_randomat_clearevents", EndActiveEvents, nil, "Clears all active events", FCVAR_SERVER_CAN_EXECUTE)

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

--[[
 Override TTT Stuff
]]--

hook.Add("TTTEndRound", "RandomatEndRound", EndActiveEvents)
hook.Add("TTTPrepareRound", "RandomatPrepareRound", function()
    -- End ALL events rather than just active ones to prevent some event effects which maintain over map changes
    for _, v in pairs(Randomat.Events) do
        EndEvent(v)
    end
end)
hook.Add("ShutDown", "RandomatMapChange", EndActiveEvents)
