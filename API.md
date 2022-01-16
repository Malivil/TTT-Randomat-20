# Application Programming Interface (API)
## Overview
This document aims to explain the things that have been added to the Randomat 2.0 that are usable by other developers for integration.

## Table of Contents
1. [Enumerations](#Enumerations)
1. [Events](#Events)
    1. [Methods](#Methods)
    1. [Properties](#Properties)
1. [Hooks](#Hooks)
1. [Net Messages](#Net-Messages)
1. [Randomat Namespace](#Randomat-Namespace)
    1. [Methods](#Methods-1)
    1. [Tables](#Tables)

## Enumerations
Enumerations available globally (within the defined realm).

**EVENT_TYPE_\*** - What type the event is. By default, multiple events with the same (non-default) type cannot run at the same time.\
*Realm:* Client and Server\
*Values:*
- EVENT_TYPE_DEFAULT - This event doesn't match any of the other types or doesn't specify a type
- EVENT_TYPE_WEAPON_OVERRIDE - This event changes what weapons a player has and can use
- EVENT_TYPE_VOTING - This event shows a voting UI for each player
- EVENT_TYPE_SMOKING - This event uses a smoking effect on the players
- EVENT_TYPE_SPECTATOR_UI - This event uses a custom interface for spectators

## Events
Creating an Randomat event involves defining the object with its associated methods and properties and then registering it. This section will detail the common methods and properties available when creating your event.

### Methods

**EVENT:AddHook(hooktype, callbackfunc)** - .\
*Realm:* Server\
*Parameters:*
- *hooktype* - 
- *callbackfunc* - 

**EVENT:Begin(...)** - .\
*Realm:* Server\
*Parameters:*
- *...* - 

**EVENT:CleanUpHooks()** - .\
*Realm:* Server

**EVENT:Condition()** - .\
*Realm:* Server

**EVENT:Enabled()** - .\
*Realm:* Server

**EVENT:End()** - .\
*Realm:* Server

**EVENT:GetAlivePlayers(shuffle)** - .\
*Realm:* Server\
*Parameters:*
- *shuffle* - 

**EVENT:GetConVars()** - .\
*Realm:* Server

**EVENT:GetPlayers(shuffle)** - .\
*Realm:* Server\
*Parameters:*
- *shuffle* - 

**EVENT:GetRoleName(ply, hide_secret_roles)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *hide_secret_roles* - 

**EVENT:HandleWeaponAddAndSelect(ply, addweapons)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *addweapons* - 

**EVENT:RemoveHook(hooktype)** .\
*Realm:* Server\
*Parameters:*
- *hooktype* - 

**EVENT:RenameWeps(name)** - .\
*Realm:* Server\
*Parameters:*
- *name* - 

**EVENT:ResetAllPlayerScales()** - .\
*Realm:* Server

**EVENT:SetAllPlayerScales(scale)** - .\
*Realm:* Server\
*Parameters:*
- *scale* - 

**EVENT:SmallNotify(msg, length, target)** - .\
*Realm:* Server\
*Parameters:*
- *msg* - 
- *length* - 
- *target* - 

**EVENT:StripRoleWeapons(ply)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 

**EVENT:SwapWeapons(ply, weapon_list, from_killer)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *weapon_list* - 
- *from_killer* - 

### Properties

## Hooks
Custom and modified event hooks available within the defined realm. A list of default TTT hooks is available [here](https://www.troubleinterroristtown.com/development/hooks/) but note that they may have been modified (see below).

***NOTE:*** When using a hook with multiple return values, you *must* return a non-`nil` value for all properties up to the one(s) you are modifying or the hook results will be ignored entirely.

For example, if there is a hook that returns three parameters: `first`, `second`, and `third` and you want to modify the `second` parameter you must return the `first` parameter as non-`nil` as well, like this: `return first, newSecond`. Any return parameters after `second` can be omitted and the default value will be used.

***NOTE:*** Be careful that you only return from a hook when you absolutely want to change something. Due to the way GMod hooks work, whichever hook instance returns first causes the *remaining hook instances to be completely skipped*. This is useful for certain hooks when you want to stop a behavior from happening, but it can also accidentally cause functionality to break because its code is completely ignored.

**TTTOrderedEquipment(ply, equipment, is_item, from_randomat)** - Changed to pass a new fourth parameter, `from_randomat`, to indicate that this hook was called from within the Randomat.\
*Realm:* Server\
*Parameters:*
- *ply* - The player who ordered the equipment
- *equipment - Either the weapon class name (e.g., “weapon_ttt_knife”) or an item ID (e.g., EQUIP_ARMOR)
- *is_item - If `true`, `equipment` represents an item ID. Otherwise, `equipment` represents a weapon class name
- *from_randomat - Whether this hook was called from within the Randomat

**TTTRandomatTriggered(event_id, ply)** - Called when a Randomat event is started.\
*Realm:* Server\
*Parameters:*
- *event_id* - The ID of the event that was triggered
- *ply* - The player who triggered the event

## Net Messages
Messages that the Randomat is set up to listen to in the defined realm.

**randomat_message** - Displays a message on the local player's screen. Also plays a sound.\
*Realm:* Client\
*Parameters:*
- *Bool* - Whether the message being displayed should be large
- *String* - The message being displayed 
- *UInt(8)* - The number of seconds the message should be displayed for

**randomat_message_silent** - Displays a message on the local player's screen. Does not play a sound.\
*Realm:* Client\
*Parameters:*
- *Bool* - Whether the message being displayed should be large
- *String* - The message being displayed 
- *UInt(8)* - The number of seconds the message should be displayed for

**RdmtRemoveSpeedMultiplier** - Removes a speed multiplier for the local player.\
*Realm:* Client\
*Parameters:*
- *String* - The unique key for the speed multiplier to remove

**RdmtRemoveSpeedMultipliers** - Removes all speed multipliers for the local player which have keys that start with the given string.\
*Realm:* Client\
*Parameters:*
- *String* - The value that multiplier keys must start with to be removed

**RdmtSetSpeedMultiplier** - Registers a speed multiplier for the local player.\
*Realm:* Client\
*Parameters:*
- *Float* - The speed multiplier to record
- *String* - The unique key for the speed multiplier. Used to remove the multiplier later

**RdmtSetSpeedMultiplier_WithWeapon** - .\
*Realm:* Client\
*Parameters:*
- *Float* - The speed multiplier to record
- *String* - The unique key for the speed multiplier. Used to remove the multiplier later
- *String* - The weapon class the local player must have equipped for the speed multiplier to be in effect

## Randomat Namespace

### Methods

**Randomat:CallShopHooks(isequip, id, ply)** - .\
*Realm:* Server\
*Parameters:*
- *isequip* - 
- *id* - 
- *ply* - 

**Randomat:CanEventRun(event, ignore_history)** - .\
*Realm:* Server\
*Parameters:*
- *event* - 
- *ignore_history* - 

**Randomat:CanUseShop(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:Capitalize(msg, skip_lower)** - .\
*Realm:* Client and Server\
*Parameters:*
- *msg* - 
- *skip_lower* - 

**Randomat:ChatDescription(ply, event, has_description)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *event* - 
- *has_description* - 

**Randomat:ChatNotify(ply, msg)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *msg* - 

**Randomat:EndActiveEvent(id)** - .\
*Realm:* Server\
*Parameters:*
- *id* - 

**Randomat:EventNotify(title)** - .\
*Realm:* Server\
*Parameters:*
- *title* - 

**Randomat:EventNotifySilent(title)** - .\
*Realm:* Server\
*Parameters:*
- *title* - 

**Randomat:GetEventTitle(event)** - .\
*Realm:* Server\
*Parameters:*
- *event* - 

**Randomat:GetItemName(item, role)** - .\
*Realm:* Client\
*Parameters:*
- *item* - 
- *role* - 

**Randomat:GetPlayers(shuffle, alive_only, dead_only)** - .\
*Realm:* Server\
*Parameters:*
- *shuffle* - 
- *alive_only* - 
- *dead_only* - 

**Randomat:GetRandomEvent(skip_history, can_run)** - .\
*Realm:* Server\
*Parameters:*
- *skip_history* - 
- *can_run* - 

**Randomat:GetRoleColor(role)** - .\
*Realm:* Client and Server\
*Parameters:*
- *role* - 

**Randomat:GetRoleExtendedString(role, hide_secret_roles)** - .\
*Realm:* Client and Server\
*Parameters:*
- *role* - 
- *hide_secret_roles* - 

**Randomat:GetRolePluralString(role)** - .\
*Realm:* Client and Server\
*Parameters:*
- *role* - 
- *hide_secret_roles* - 

**Randomat:GetRoleString(role)** - .\
*Realm:* Client and Server\
*Parameters:*
- *role* - 
- *hide_secret_roles* - 

**Randomat:GetRoundCompletePercent()** - .\
*Realm:* Client and Server

**Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *roles* - 
- *blocklist* - 
- *include_equipment* - 
- *tracking* - 
- *settrackingvar* - 
- *droppable_only* - 

**Randomat:GetValidRoles(roles, check)** - .\
*Realm:* Client and Server\
*Parameters:*
- *roles* - 
- *check* - 

**Randomat:GetWeaponName(item)** - .\
*Realm:* Client\
*Parameters:*
- *item* - 

**Randomat:GiveRandomShopItem(ply, roles, blocklist, include_equipment, gettrackingvar, settrackingvar, onitemgiven, droppable_only)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *roles* - 
- *blocklist* - 
- *include_equipment* - 
- *gettrackingvar* - 
- *settrackingvar* - 
- *onitemgiven* - 
- *droppable_only* - 

**Randomat:HandleEntitySmoke(tbl, client, pred, color, max_dist)** - .\
*Realm:* Client\
*Parameters:*
- *tbl* - 
- *client* - 
- *pred* - 
- *color* - 
- *max_dist* - 

**Randomat:HandlePlayerSmoke(client, pred, color, max_dist)** - .\
*Realm:* Client\
*Parameters:*
- *client* - 
- *pred* - 
- *color* - 
- *max_dist* - 

**Randomat:IsEventActive(id)** - .\
*Realm:* Server\
*Parameters:*
- *id* - 

**Randomat:IsDetectiveLike(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsEvilDetectiveLike(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsGoodDetectiveLike(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsIndependentTeam(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsInnocentTeam(ply, skip_detective)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 
- *skip_detective* - 

**Randomat:IsJesterTeam(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsMonsterTeam(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsPlayerInvisible(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:IsTraitorTeam(ply, skip_evil_detective)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 
- *skip_evil_detective* - 

**Randomat:IsZombifying(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:NotifyDescription(event)** - .\
*Realm:* Server\
*Parameters:*
- *event* - 

**Randomat:LogEvent(msg)** - .\
*Realm:* Server\
*Parameters:*
- *msg* - 

**Randomat:OverrideWeaponSound(wep, chosen_sound)** - .\
*Realm:* Client and Server\
*Parameters:*
- *wep* - 
- *chosen_sound* - 

**Randomat:OverrideWeaponSoundData(wep, chosen_sound)** - .\
*Realm:* Client and Server\
*Parameters:*
- *wep* - 
- *chosen_sound* - 

**Randomat:PaintBar(r, x, y, w, h, colors, value)** - .\
*Realm:* Client\
*Parameters:*
- *r* - 
- *x* - 
- *y* - 
- *w* - 
- *h* - 
- *colors* - 
- *value* - 

**Randomat:register(event)** - .\
*Realm:* Server\
*Parameters:*
- *event* - 

**Randomat:RemoveEquipmentItem(ply, item_id)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *item_id* - 

**Randomat:RemovePhdFlopper(ply, block_message)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *block_message* - 

**Randomat:ResetPlayerScale(ply, id)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 
- *id* - 

**Randomat:RestoreWeaponSound(wep)** - .\
*Realm:* Client and Server\
*Parameters:*
- *wep* - 

**Randomat:RoundedMeter(bs, x, y, w, h, color)** - .\
*Realm:* Client\
*Parameters:*
- *bs* - 
- *x* - 
- *y* - 
- *w* - 
- *h* - 
- *color* - 

**Randomat:SetRole(ply, role)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *role* - 

**Randomat:SetPlayerInvisible(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:SetPlayerVisible(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:SafeTriggerEvent(id, ply, error_if_unsafe, ...)** - .\
*Realm:* Server\
*Parameters:*
- *id* - 
- *ply* - 
- *error_if_unsafe* - 
- *...* - 

**Randomat:ShouldActLikeJester(ply)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 

**Randomat:SetPlayerScale(ply, scale, id, skip_speed)** - .\
*Realm:* Client and Server\
*Parameters:*
- *ply* - 
- *scale* - 
- *id* - 
- *skip_speed* - 

**Randomat:SilentTriggerEvent(id, ply, ...)** - .\
*Realm:* Server\
*Parameters:*
- *id* - 
- *ply* - 
- *...* - 

**Randomat:SilentTriggerRandomEvent(ply)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 

**Randomat:SmallNotify(msg, length, target)** - .\
*Realm:* Server\
*Parameters:*
- *msg* - 
- *length* - 
- *target* - 

**Randomat:SpawnBarrel(pos, range, min_range, ignore_negative)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *range* - 
- *min_range* - 
- *ignore_negative* - 

**Randomat:SpawnBee(ply, color, height)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *color* - 
- *height* - 

**Randomat:SpawnNPC(ply, pos, cls)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 
- *pos* - 
- *cls* - 

**Randomat:TriggerEvent(id, ply, ...)** - .\
*Realm:* Server\
*Parameters:*
- *id* - 
- *ply* - 
- *...* - 

**Randomat:TriggerRandomEvent(ply)** - .\
*Realm:* Server\
*Parameters:*
- *ply* - 

**Randomat:unregister(id)** - .\
*Realm:* Server\
*Parameters:*
- *id* - 

### Tables
Tables which are used to track different data and which are available globally via the Randomat namespace

**Randomat.ActiveEvents** - Table containing all currently-running events.\
*Realm:* Server

**Randomat.EventHistory** - Table containing the list of the events that were previously started. Used to prevent running the same events too often.\
*Realm:* Server

**Randomat.Events** - Table containing all defined events with the key being the event ID.\
*Realm:* Server
