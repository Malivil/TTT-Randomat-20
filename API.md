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
All methods below are automatically defined for every event but events can override them as needed.

**EVENT:AddHook(hooktype, callbackfunc)** - Registers a new hook for this event.\
*Realm:* Server\
*Parameters:*
- *hooktype* - The type of hook to add
- *callbackfunc* - The function to call for the hook

**EVENT:Begin(...)** - Called when an event is started. **Must be defined to for an event to work**.\
*Realm:* Server\
*Parameters:*
- *...* - All parameters that could be passed into this event. This is only used when one of the `TriggerEvent` methods is called, allowing you to change aspects of an event based on what code calls it

**EVENT:CleanUpHooks()** - Removes all hooks registered to this event.\
*Realm:* Server

**EVENT:Condition()** - Called when the Randomat is attempting to determine if an event can be started.\
*Realm:* Server

*Returns:* `true` by default, meaning an event should run. If overridden and changed to return `false`, this event will never start

**EVENT:Enabled()** - Called when determining if an event is enabled.\
*Realm:* Server

*Returns:* The current value of the the automatically-generated `ttt_randomat_{EVENT_ID}` convar. If overridden and changed to return `false`, this event will never start

**EVENT:End()** - Called when an event is stopped. Used to do manual cleanup of processes started in the event.\
*Realm:* Server

*NOTE:* **All** events are automatically ended during every round prep phase to ensure leftover event processes are stopped between events

**EVENT:GetAlivePlayers(shuffle)** - Gets a table of all living players.\
*Realm:* Server\
*Parameters:*
- *shuffle* - Whether to shuffle the table after generating it

*Returns:* A table of all living players

**EVENT:GetConVars()** - Gets tables of the convars defined for an event. Used primarily by the Randomat 2.0 ULX module to dynamically create configuration pages for each event.\
*Realm:* Server

*Returns:*
- *sliders* - Table of convar objects that should be configurable using numeric sliders
  - *cmd* - The portion of the convar name that comes after `randomat_{EVENT_ID}_` (e.g. "interval" from `randomat_lonelyyogs_interval`)
  - *dsc* - The description of this convar
  - *min* - The minimum value for this convar
  - *max* - The maximum value for this convar
  - *dcm* - The number of decimal points to use for the slider for this convar
- *checks* - Table of convar objects that should be configurable using checkboxes
  - *cmd* - The portion of the convar name that comes after `randomat_{EVENT_ID}_` (e.g. "interval" from `randomat_lonelyyogs_interval`)
  - *dsc* - The description of this convar
- *textboxes* - Table of convar objects that should be configurable using textboxes
  - *cmd* - The portion of the convar name that comes after `randomat_{EVENT_ID}_` (e.g. "interval" from `randomat_lonelyyogs_interval`)
  - *dsc* - The description of this convar

**EVENT:GetPlayers(shuffle)** - Gets a table of all players.\
*Realm:* Server\
*Parameters:*
- *shuffle* - Whether to shuffle the table after generating it

**EVENT:GetRoleName(ply, hide_secret_roles)** - Calls `Randomat:GetRoleExtendedString` for the given player's role.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose role name is being retrieved
- *hide_secret_roles* - Whether to hide roles that should remain secret (e.g. Detraitor and Impersonator)

**EVENT:HandleWeaponAddAndSelect(ply, addweapons)** - Handles adding weapons to the given player and selecting the weapon which is as close to their current weapon as possible.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose weapons are being modified
- *addweapons* - The callback function that will be called to add weapons
  - *Parameters:*
    - *active_class* - The player's current weapon class
    - *active_kind* - The player's current weapon kind

**EVENT:RemoveHook(hooktype)** - Removes the hook of the given hook type bound to this event.\
*Realm:* Server\
*Parameters:*
- *hooktype* - The type of event to be removed

**EVENT:RenameWeps(name)** - Gets the human-readable name of the given weapon name string.\
*Realm:* Server\
*Parameters:*
- *name* - The weapon name string to be translated

**EVENT:ResetAllPlayerScales()** - Resets all player scales to their defaults.\
*Realm:* Server

**EVENT:SetAllPlayerScales(scale)** - Sets the scale of all living players to the given value.\
*Realm:* Server\
*Parameters:*
- *scale* - The player scale to be set

**EVENT:SmallNotify(msg, length, target)** - Displays a small notification message on all players' screens. If the "secret" event is active, this call is ignored.\
*Realm:* Server\
*Parameters:*
- *msg* - The message to display
- *length* - The length of time (in seconds) the message should be displayed for (Defaults to 5)
- *target* - The player to send the notification to. If not provided or `nil`, the notification is sent to all players

**EVENT:StripRoleWeapons(ply)** - Removes all role-specific weapons from the given player.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose role-specific events are being removed

**EVENT:SwapWeapons(ply, weapon_list, from_killer)** - Swaps all weapons from the given player with the specified list of weapons.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose weapons are being swapped
- *weapon_list* - The list of weapons to give the target player
- *from_killer* - Whether the weapons being given came from a player with the Killer role

### Properties

**AltTitle** - The alternate title to use for this event. Used to prevent an event from sending an automatic "started" notification (if `Title` is not defined) and to allow for a second searchable title in the Randomat 2.0 ULX module. Defaults to `nil`.\
*Realm:* Server

**Description** - The description for this event. Automatically shown on screen and in each player's chat if event notifications are enabled. Also shown on each event's page in the Randomat 2.0 ULX module. Defaults to `nil`.\
*Realm:* Server

**Id (aka id)** - The unique identifier for this event.\
*Realm:* Server

**MaxRoundCompletePercent** - The maximum percentage of the current round that can be completed for this event to be randomly chosen to be started. Defaults to `nil`.\
*Realm:* Server

**MinRoundCompletePercent** - The minimum percentage of the current round that can be completed for this event to be randomly chosen to be started. Defaults to `nil`.\
*Realm:* Server

**SingleUse** - Whether this event should not be allowed to start if it's already running. Defaults to `true`.\
*Realm:* Server

**StartSecret** - Whether this event should be started in secret. Defaults to `false`.\
*Realm:* Server

**Title** - The title to use for this event. If this is not defined (and `AltTitle` is instead) the automatic "started" notification for this event will not happen.\
*Realm:* Server

**Type** - The *EVENT_TYPE_\** value to use for this event.\
*Realm:* Server

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

**RdmtSetSpeedMultiplier_WithWeapon** - Registers a speed multiplier for the local player that only takes effect when they have a specific weapon equipped.\
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

**Randomat:GetRoleExtendedString(role, hide_secret_roles)** - Gets the extended role string (e.g. "An innocent" or "A traitor") for the given role.\
*Realm:* Client and Server\
*Parameters:*
- *role* - The ID of the role whose extended string is being retrieved
- *hide_secret_roles* - Whether to hide roles that should remain secret (e.g. Detraitor and Impersonator)

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
