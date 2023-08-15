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
- EVENT_TYPE_RESPAWN - This event causes players to respawn under the correct circumstances
- EVENT_TYPE_GUNSOUNDS - This event overrides weapon sounds
- EVENT_TYPE_JUMPING - This event changes jumping in some extreme way

## Events
Creating an Randomat event involves defining the object with its associated methods and properties and then registering it. This section will detail the common methods and properties available when creating your event.

### Methods
All methods below are automatically defined for every event but events can override them as needed.

**EVENT:AddCullingBypass(ply_pred, tgt_pred)** - Adds behavior which bypasses map vis leafs and culling to have Target ID icons and highlighting show more consistently through walls.\
*Realm:* Server\
*Parameters:*
- *ply_pred* - An optional function predicate that is given a player and returns whether that player should have their culling behavior bypassed
- *tgt_pred* - An optional function predicate that is given a player and a target and returns whether that player should have their culling behavior bypassed for that target

**EVENT:AddEntityCullingBypass(ply_pred, tgt_pred, class)** - Adds behavior which bypasses map vis leafs and culling to have things like highlighting show more consistently through walls.\
*Realm:* Server\
*Parameters:*
- *ply_pred* - An optional function predicate that is given a player and returns whether that player should have their culling behavior bypassed
- *tgt_pred* - An optional function predicate that is given a player and a target entity and returns whether that player should have their culling behavior bypassed for that target
- *class* - An optional entity class that will filter the list of entities being processed

**EVENT:AddHook(hooktype, callbackfunc, suffix)** - Registers a new hook for this event.\
*Realm:* Server\
*Parameters:*
- *hooktype* - The type of hook to add
- *callbackfunc* - The function to call for the hook
- *suffix* - An optional suffix for the generated ID. Useful for when the same event wants to hook the same type multiple times.

**EVENT:Begin(...)** - Called when an event is started. **Must be defined to for an event to work**.\
*Realm:* Server\
*Parameters:*
- *...* - All parameters that could be passed into this event. This is only used when one of the `TriggerEvent` methods is called, allowing you to change aspects of an event based on what code calls it

**EVENT:CleanUpHooks()** - Removes all hooks registered to this event.\
*Realm:* Server

**EVENT:Condition()** - Called when the Randomat is attempting to determine if an event can be started.\
*Realm:* Server

*Returns:* `true` by default, meaning an event should run. If overridden and changed to return `false`, this event will never start

**EVENT:DisableRoundEndSounds()** - Disables the various methods that normally would play sounds at the end of the round. Credit to The Stig.\
*Realm:* Server

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

**EVENT:NotifyTeamChange(newMembers, roleTeam)** - Sends a message to the members of the targeted team, telling them the players in the `newMembers` list have joined them.
*Realm:* Server\
*Parameters:*
- *newMembers* - The table of players who have switched teams
- *roleTeam* - The `ROLE_TEAM_*` value from Custom Roles for TTT, specifying which team to send the message to

**EVENT:RemoveHook(hooktype, suffix)** - Removes the hook of the given hook type bound to this event.\
*Realm:* Server\
*Parameters:*
- *hooktype* - The type of event to be removed
- *suffix* - An optional suffix for the generated ID being removed. Useful for when the same event wants to hook the same type multiple times.

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

**EVENT:SmallNotify(msg, length, target, silent, allow_secret, font_color)** - Displays a small notification message on all players' screens. If the "secret" event is active, this call is ignored unless `allow_secret` is `true`.\
*Realm:* Server\
*Parameters:*
- *msg* - The message to display
- *length* - The length of time (in seconds) the message should be displayed for (Optional, defaults to 5)
- *target* - The player to send the notification to. If not provided or `nil`, the notification is sent to all players (Optional)
- *silent* - Whether the notification should not make a sound when it is displayed (Optional, defaults to `false`)
- *allow_secret* - Whether to allow this message to go through even when the `secret` event is running (Optional, defaults to `false`)
- *font_color* - The [Color](https://wiki.facepunch.com/gmod/Color) of the font (Optional, defaults to rgb(255, 200, 0))

**EVENT:StripRoleWeapons(ply, skip_add_crowbar)** - Removes all role-specific weapons from the given player and gives them a crowbar (to replace the killer's crowbar).\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose role-specific events are being removed
- *skip_add_crowbar* - Whether to skip giving the player a replacement crowbar

**EVENT:SwapWeapons(ply, weapon_list)** - Swaps all weapons from the given player with the specified list of weapons.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose weapons are being swapped
- *weapon_list* - The list of weapons to give the target player

### Properties
Properties used to define and describe an event and its running conditions

**AltTitle** - The alternate title to use for this event. Used to prevent an event from sending an automatic "started" notification (if `Title` is not defined) and to allow for a second searchable title in the Randomat 2.0 ULX module. Defaults to `nil`.\
*Realm:* Server

**Categories** - What categories this event belongs to. Useful for finding events with specific purposes. Also displayed in the ULX admin menu.\
*Realm:* Server

**Description** - The description for this event. Automatically shown on screen and in each player's chat if event notifications are enabled. Also shown on each event's page in the Randomat 2.0 ULX module. Defaults to `nil`.\
*Realm:* Server

**ExtDescription** - The extended description for this event. Shown on each event's page in the Randomat 2.0 ULX module instead of the `Description`. Defaults to `nil`.\
*Realm:* Server

**Id (aka id)** - The unique identifier for this event. **This must be defined for the event to work**.\
*Realm:* Server

**IsEnabled** - Whether this event should be enabled by default. This changes the default value for created the `ttt_randomat_{EVENT_ID}` convar. Changing this after the event has already been loaded on a server will only change the default convar value, not the current value. Defaults to `true`.\
*Realm:* Server

**MinPlayers** - The minimum number of players that must be in the server before this event can be chosen. This changes the default value for created the `ttt_randomat_{EVENT_ID}_min_players` convar. Changing this after the event has already been loaded on a server will only change the default convar value, not the current value.Defaults to `0`.\
*Realm:* Server

**MaxRoundCompletePercent** - The maximum percentage of the current round that can be completed for this event to be randomly chosen to be started. Defaults to `nil`.\
*Realm:* Server

**MinRoundCompletePercent** - The minimum percentage of the current round that can be completed for this event to be randomly chosen to be started. Defaults to `nil`.\
*Realm:* Server

**Owner (aka owner)** - The player who started this event.\
*Realm:* Server

**Silent** - Whether this event was started silently.\
*Realm:* Server

**SingleUse** - Whether this event should not be allowed to start if it's already running. Defaults to `true`.\
*Realm:* Server

**StartSecret** - Whether this event should be started in secret. Defaults to `false`.\
*Realm:* Server

**StartTime** - The time that this event was started. Useful for when a unique "running instance" identifier is needed.\
*Realm:* Server

**Title** - The title to use for this event. If this is not defined (and `AltTitle` is instead) the automatic "started" notification for this event will not happen.\
*Realm:* Server

**Type** - The *EVENT_TYPE_\** value to use for this event.\
*Realm:* Server

**Weight** - The selection weight to use for this event when randomly choosing events. A higher weight means the event will be chosen more often. A weight of -1 means it should use the shared `ttt_randomat_event_weight` convar value. This changes the default value for created the `ttt_randomat_{EVENT_ID}_weight` convar. Changing this after the event has already been loaded on a server will only change the default convar value, not the current value. Defaults to `-1`.\
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
- *equipment - Either the weapon class name (e.g., "weapon_ttt_knife") or an item ID (e.g., EQUIP_ARMOR)
- *is_item - If `true`, `equipment` represents an item ID. Otherwise, `equipment` represents a weapon class name
- *from_randomat - Whether this hook was called from within the Randomat

**TTTRandomatCanEventRun(event)** - Called when a Randomat event is checking if it can run.\
*Realm:* Server\
*Parameters:*
- *event* - The event object to check

*Return:*
- *can_run* - `true` to allow the event to run or `false` to prevent it from running
- *reason* - The string message used in the error message when an event is prevented from running (Optional)

*Note:* Return nothing to allow the default logic to run

***TTTRandomatCommand(ply, cmd, args)** - Called when a Randomat console command is run.\
*Realm:* Server\
*Parameters:*
- *ply* - The player who ran the command
- *cmd* - Which command was run
- *args* - The arguments passed in to the command

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

**RdmtSetSpeedMultiplier_Sprinting** - Registers a speed multiplier for when the local player is sprinting.\
*Realm:* Client\
*Parameters:*
- *Float* - The speed multiplier to record
- *String* - The unique key for the speed multiplier. Used to remove the multiplier later

## Randomat Namespace
The methods and properties belonging to the static `Randomat` namespace, available globally

### Methods
Methods belonging to the `Randomat` namespace that are available globally, within the defined realm

**Randomat:AddEventToHistory(event)** - Adds the given event to tracking history.\
*Realm:* Server\
*Parameters:*
- *event* - The event or event id to add to tracking history

**Randomat:CallShopHooks(isequip, id, ply)** - Calls expected hooks, net messages, and player methods to indicate that a player has bought a weapon. This is used when the Randomat gives a player a weapon.\
*Realm:* Server\
*Parameters:*
- *isequip* - The numerical form of `id` which is used to determine whether the item the player received was an equipment item
- *id* - The weapon class name (e.g., "weapon_ttt_knife") or item ID (e.g., EQUIP_ARMOR) that the player received
- *ply* - The player who received the shop item

**Randomat:CanEventRun(event, ignore_history)** - Determines whether the given event can start based on whether it conforms to the following conditions:
1. It exists
1. It's `Enabled` method returns `true` (By default, this means whether the `ttt_randomat_{EVENT_ID}` convar is `1`)
1. It's `Condition` method returns `true` (By default, this always returns `true`)
1. There are enough players in the round compared to it's `ttt_randomat_{EVENT_ID}_min_players` convar value (By default, there is no minimum set)
1. The correct amount of time has passed to fit within it's `MinRoundCompletePercent` and `MaxRoundCompletePercent` properties (By default, there is no required percentage set)
1. It's either not `SingleUse` or an instance of this event is not already running
1. `ignore_history` is `true`, event history is disabled, or this event hasn't been started in recent history
1. It's `Type` property is `EVENT_TYPE_DEFAULT` or no other events with the same type value are currently running

*Realm:* Server\
*Parameters:*
- *event* - The event object or event ID to check
- *ignore_history* - Whether to ignore the event history check

*Returns:*
- *can_run* - `true` if the event can be started, `false` otherwise
- *failure_reason* - If `can_run` is `false`, this will be a string representing the reason for the failure

**Randomat:CanUseShop(ply)** - Whether the given player can open the shop.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the shop can be opened, `false` otherwise

**Randomat:Capitalize(msg, skip_lower)** - Capitalizes the given message by changing the first letter to uppercase and the rest to lowercase.\
*Realm:* Client and Server\
*Parameters:*
- *msg* - The message to capitalize
- *skip_lower* - Whether to skip changing the rest of the message to lowercase

*Returns:* The capitalized message

**Randomat:ChatDescription(ply, event, has_description)** - Prints the given event's title and description in the chat for the specified player. If the "secret" event is active, this call is ignored.\
*Realm:* Server\
*Parameters:*
- *ply* - The player to print for
- *event* - The event whose information is being printed
- *has_description* - Whether this event has a description to be printed

**Randomat:ChatNotify(ply, msg)** - Prints the given message in the chat for the specified player. If the "secret" event is active, this call is ignored.\
*Realm:* Server\
*Parameters:*
- *ply* - The player to print for
- *msg* - The message to print

**Randomat:EndActiveEvent(id, skip_error)** - Ends the event with the given ID.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event to end
- *skip_error* - Whether to skip causing an error if the event is not running

**Randomat:EndActiveEvents()** - Ends all active events.\
*Realm:* Server

**Randomat:EventNotify(title)** - Displays the given event title on all players' screens. Also plays a sound. If the "secret" event is active, this call is ignored.\
*Realm:* Server\
*Parameters:*
- *title* - The event title

**Randomat:EventNotifySilent(title)** - Displays the given event title on all players' screens. Does not play a sound. If the "secret" event is active, this call is ignored.\
*Realm:* Server\
*Parameters:*
- *title* - The event title

**Randomat:ForceResetAllPlayermodels()** - Resets each player's model and associated data back to what it was at the start of the round. Credit to The Stig.\
*Realm:* Client and Server\

**Randomat:ForceSetPlayermodel(ply, data)** - Sets the given player's model and associated data (including model file path, skin data, bodygroups, etc.) to the given values. Credit to The Stig.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The target player
- *data* - The playermodel data table, including model file path, skin data, bodygroups, etc.

**Randomat:GetAllEventCategories(readable)** - Gets the list of all categories used by registered events.\
*Realm:* Server\
*Parameters:*
- *readable* - Whether the list of event categories should be in human-readable form. Defaults to `false`

*Returns:* The list of all used event categories

**Randomat:GetEventCategories(event, readable)** - Gets the comma-delimited list of categories for an event.\
*Realm:* Server\
*Parameters:*
- *event* - The event object or ID of the event whose categories are being retrieved
- *readable* - Whether the list of event categories should be in human-readable form. Defaults to `false`

*Returns:* The comma-delimited list of categories for the given event

**Randomat:GetEventTitle(event)** - Gets the given event's `Title` or `AltTitle` property, whichever is defined.\
*Realm:* Server\
*Parameters:*
- *event* - The event object whose title is being retrieved

*Returns:* The event's usable title

**Randomat:GetEventsByCategory(category, active)** - Gets the list of events with the given category.\
*Realm:* Server\
*Parameters:*
- *category* - The category of events to find
- *active* - Whether to check active (running) events. Defaults to `false`

*Returns:* The list of events with the given category

**Randomat:GetEventsByCategories(categories, active)** - Gets the list of events with all of the given categories.\
*Realm:* Server\
*Parameters:*
- *categories* - The categories that the events should have
- *active* - Whether to check active (running) events. Defaults to `false`

*Returns:* The list of events with all of the given categories.

**Randomat:GetEventsByType(type)** - Gets the list of all registered events with the given type.\
*Realm:* Server\
*Parameters:*
- *type* - The type of events to find

*Returns:* The list of events with the given type

**Randomat:GetItemName(item, role)** - Gets the name of the given equipment item for the provided role.\
*Realm:* Client\
*Parameters:*
- *item* - The equipment item ID (e.g. EQUIP_RADAR) whose name is being retrieved
- *role* - The role ID which can buy the specified item

*Returns:* The item's human-readable name

**Randomat:GetPlayerNameListString(players, includeAnd)** - Gets a comma-delimited list of the names of the players from the given list.\
*Realm:* Client and Server\
*Parameters:*
*players* - The table of players to process
*includeAnd* - Whether to have an "and" between the last two entries in the list

*Returns:* List of player names separated by a comma

**Randomat:GetPlayers(shuffle, alive_only, dead_only)** - Gets a list of players.\
*Realm:* Server\
*Parameters:*
- *shuffle* - Whether to shuffle the list after generating it
- *alive_only* - Whether only alive players should be in the list
- *dead_only* - Whether only dead players should be in the list

*Returns:* The list of players

*Note:* Passing the same value for `alive_only` and `dead_only` with result in a list of all players

**Randomat:GetPlayerModelData(ply)** - Gets the model data for the given player, including model file path, skin data, bodygroups, etc. Credit to The Stig.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The target player

*Returns:* A table of the playermodel data

**Randomat:GetRandomEvent(skip_history, can_run)** - Gets a random event that can be started.\
*Realm:* Server\
*Parameters:*
- *skip_history* - If `true`, the found event is not added to the history list
- *can_run* - Optional predicate function which is used to determine if the event can run in addition to the normal `Randomat.CanEventRun` checks
  - *evt* - The event being checked

*Returns:* A random event that can be started

**Randomat:GetReadableCategory(category)** - Gets the human-readable form of the given category.\
*Realm:* Server\
*Parameters:*
- *category* - The event category to translate

*Returns:* The category in human-readable form

**Randomat:GetRoleColor(role)** - Gets the [Color](https://wiki.facepunch.com/gmod/Color) associated with the provided role.\
*Realm:* Client and Server\
*Parameters:*
- *role* - The ID of the role whose [Color](https://wiki.facepunch.com/gmod/Color) is being retrieved *or* the player whose role [Color](https://wiki.facepunch.com/gmod/Color) is being retrieved 

*Returns:* The [Color](https://wiki.facepunch.com/gmod/Color) for the given role

**Randomat:GetRoleExtendedString(role, hide_secret_roles)** - Gets the extended role string (e.g. "An innocent" or "A traitor") for the given role.\
*Realm:* Client and Server\
*Parameters:*
- *role* - The ID of the role whose extended string is being retrieved
- *hide_secret_roles* - Whether to hide roles that should remain secret (e.g. Detraitor and Impersonator)

*Returns:* The extended name string for the given role

**Randomat:GetRolePluralString(role)** - Gets the plural role string for the given role.\
*Realm:* Client and Server\
*Parameters:*
- *role* - The ID of the role whose plural string is being retrieved
- *hide_secret_roles* - Whether to hide roles that should remain secret (e.g. Detraitor and Impersonator)

*Returns:* The plural name string for the given role

**Randomat:GetRoleString(role)** - Gets the role string for the given role.\
*Realm:* Client and Server\
*Parameters:*
- *role* - The ID of the role whose string is being retrieved
- *hide_secret_roles* - Whether to hide roles that should remain secret (e.g. Detraitor and Impersonator)

*Returns:* The name string for the given role

**Randomat:GetRoleTeamName(roleTeam)** - Gets the team name string for the given role team.\
*Realm:* Client and Server\
*Parameters:*
- *roleTeam* - The `ROLE_TEAM_*` value from Custom Roles for TTT, specifying which team to get the name of

*Returns:* The team name string for the given role team

**Randomat:GetRoundCompletePercent()** - Gets the percentage of the current round that is complete.\
*Realm:* Server

*Returns:* The round complete percentage

**Randomat:GetRoundLimit()** - Gets the maximum number of rounds there can be.\
*Realm:* Server

*Returns:* The maximum number of rounds there can be

**Randomat:GetRoundsComplete()** - Gets the number of completed rounds.\
*Realm:* Server

*Returns:* The number of completed rounds

**Randomat:GetRoundsLeft()** - Gets the number of rounds left before map change.\
*Realm:* Server

*Returns:* The number of rounds left before map change

**Randomat:GetShopEquipment(ply, roles, blocklist, include_equipment, tracking, settrackingvar, droppable_only)** - Gets a random buyable item/weapon out of the list of role shops provided which can be given to the specified player.\
*Realm:* Server\
*Parameters:*
- *ply* - The player to check for shop item/weapon compatibility
- *roles* - The role or list of roles whose shops will be searched for a valid item/weapon
- *blocklist* - The list of weapon class names (e.g. "weapon_ttt_knife") that shouldn't be retrieved. *Optional, defaults to an empty list*
- *include_equipment* - Whether to include equipment items (e.g. Radar, Body Armor, etc.). *Optional, defaults to `false`*
- *tracking* - The current iteration value used to ensure we don't infinite loop looking for an item. *Optional, defaults to `0`*
- *settrackingvar* - The callback method allowing the caller to use the updated tracking variable value. Normally used to track the iteration count per-player. *Optional, defaults to no-op*
- *droppable_only* - Whether only droppable weapons should be found. *Optional, defaults to `false`*

*Returns:*
- *item* - The item/weapon information from the shop. `nil` if no valid items/weapons are found
- *item_id* - The item ID (e.g. EQUIP_RADAR) if it's an item, `nil` otherwise
- *swep_table* - The stored SWEP table for the weapon (if it is one), `nil` otherwise

**Randomat:GetValidRoles(roles, check)** - Gets the list of roles from those provided which pass the given check function.\
*Realm:* Client and Server\
*Parameters:*
- *roles* - The list of roles to check
- *check* - The predicate function which returns `true` to indicate a role should be kept and `false` otherwise
  - *role* - The role being checked

*Returns:* The list of valid roles

**Randomat:GetWeaponName(item)** - Gets the name of the given weapon.\
*Realm:* Client\
*Parameters:*
- *item* - The weapon class name (e.g. "weapon_ttt_knife") whose name is being retrieved

*Returns:* The weapon's human-readable name

**Randomat:GiveRandomShopItem(ply, roles, blocklist, include_equipment, gettrackingvar, settrackingvar, onitemgiven, droppable_only)** - Gives a random buyable item/weapon out of the list of role shops provided to the specified player.\
*Realm:* Server\
*Parameters:*
- *ply* - The player who is being given a weapon
- *roles* - The list of roles whose shops will be searched for a valid item/weapon
- *blocklist* - The list of weapon class names (e.g. "weapon_ttt_knife") that shouldn't be given
- *include_equipment* - Whether to include equipment items (e.g. Radar, Body Armor, etc.)
- *gettrackingvar* - The callback method allowing the caller to provide of the value used to track search iterations so we don't infinite loop looking for an item
- *settrackingvar* - The callback method allowing the caller to use the updated tracking variable value. Normally used to track the iteration count per-player. *Optional, defaults to no-op*
- *onitemgiven* - The callback method for after the player is given an item/weapon
- *droppable_only* - Whether only droppable weapons should be found. *Optional, defaults to `false`*

**Randomat:HandleEntitySmoke(tbl, client, pred, color, max_dist, min_size, max_size)** - Handles rendering smoke for all entities in the given table that match the specified predicate.\
*Realm:* Client\
*Parameters:*
- *tbl* - The list of entities to check and potentially add smoke to
- *client* - The local player
- *pred* - The function used to determine if the current entity should have smoke added. Return `true` to have smoke added to the entity, `false` otherwise
  - *ent* - The entity being checked
- *color* - The [Color](https://wiki.facepunch.com/gmod/Color) of the smoke *or* a function used to determine the current entity's smoke [Color](https://wiki.facepunch.com/gmod/Color).
- *max_dist* - The max distance away smoke should be visible (Defaults to 3000)
- *min_size* - The minimum size for the smoke particles
- *max_size* - The maximum size for the smoke particles

**Randomat:HandlePlayerSmoke(client, pred, color, max_dist)** - Handles rendering smoke for all players that match the specified predicate.\
*Realm:* Client\
*Parameters:*
- *client* - The local player
- *pred* - The function used to determine if the current entity should have smoke added. Return `true` to have smoke added to the entity, `false` otherwise
  - *ent* - The entity being checked
- *color* - The [Color](https://wiki.facepunch.com/gmod/Color) of the smoke
- *max_dist* - The max distance away smoke should be visible (Defaults to 3000)

**Randomat:IsEventActive(id)** - Determines whether the event with the provided ID is current running.\
*Realm:* Client and Server\
*Parameters:*
- *id* - The ID of the event to search for

*Returns:* `true` if the event id active, `false` otherwise

**Randomat:IsEventCategoryActive(category)** - Determines whether an event with the provided category is current running.\
*Realm:* Client and Server\
*Parameters:*
- *category* - The category of event to search for

*Returns:* `true` if an event with the given category is active, `false` otherwise

**Randomat:IsEventInHistory(event)** - Checks whether the given event is in tracking history.\
*Realm:* Server\
*Parameters:*
- *event* - The event or event id to check in tracking history

*Returns:* `true` if the event is in the tracking history, `false` otherwise

**Randomat:IsDetectiveLike(ply)** - Determines whether the given player is a Detective-like role.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsDetectiveTeam(ply)** - Determines whether the given player is on the Detective team.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsEvilDetectiveLike(ply)** - Determines whether the given player is a Detective-like role on the Traitor team.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsGoodDetectiveLike(ply)** - Determines whether the given player is a Detective-like role on the Innocent team.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsIndependentTeam(ply)** - Determines whether the given player is an Independent player.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsInnocentTeam(ply, skip_detective)** - Determines whether the given player is on the Innocent team.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check
- *skip_detective* - Whether to not include Detective-like roles in this check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsJesterTeam(ply)** - Determines whether the given player is a Jester role.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsMonsterTeam(ply)** - Determines whether the given player is on the Monster team.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsPlayerInVehicle(ply)** - Determines whether the given player is in a vehicle.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:*
- *in_vehicle* - `true` if the player passes the check, `false` otherwise
- *ent* - The vehicle entity the given player is in

**Randomat:IsPlayerInvisible(ply)** - Determines whether the given player is invisible.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsTraitorTeam(ply, skip_evil_detective)** - Determines whether the given player is on the Traitor team.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check
- *skip_evil_detective* - 

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:IsZombifying(ply)** - Determines whether the given player is in the process of converting to be a Zombie.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:LogEvent(msg)** - Logs the given message to the event log using the `TTT_LogInfo` net message.\
*Realm:* Server\
*Parameters:*
- *msg* - The message to log

**Randomat:Notify(msg, length, target, silent, allow_secret, font_color)** - Displays a notification message on all players' screens. If the "secret" event is active, this call is ignored unless `allow_secret` is `true`.\
*Realm:* Server\
*Parameters:*
- *msg* - The message to display
- *length* - The length of time (in seconds) the message should be displayed for (Optional, defaults to 5)
- *target* - The player to send the notification to. If not provided or `nil`, the notification is sent to all players (Optional)
- *silent* - Whether the notification should not make a sound when it is displayed (Optional, defaults to `false`)
- *allow_secret* - Whether to allow this message to go through even when the `secret` event is running (Optional, defaults to `false`)
- *font_color* - The [Color](https://wiki.facepunch.com/gmod/Color) of the font (Optional, defaults to rgb(255, 200, 0))

**Randomat:OverrideWeaponSound(wep, chosen_sound)** - Overrides the given weapon's `Primary.Sound` property with the given sound.\
*Realm:* Client and Server\
*Parameters:*
- *wep* - The weapon to override
- *chosen_sound* - The chosen replacement sound

**Randomat:OverrideWeaponSoundData(wep, chosen_sound)** - Overrides the given weapon's sound data `SoundName` property with the given sound. Used in conjunction with the `EntityEmitSound` hook.\
*Realm:* Client and Server\
*Parameters:*
- *wep* - The weapon to override
- *chosen_sound* - The chosen replacement sound

*Returns:* `true` if the sound is overridden, nothing otherwise

**Randomat:PaintBar(r, x, y, w, h, colors, value)** - Draws a progress bar with the given parameters.\
*Realm:* Client\
*Parameters:*
- *r* - Corner radius
- *x* - X position
- *y* - Y position
- *w* - Width
- *h* - Height
- *colors* - Table representing [Color](https://wiki.facepunch.com/gmod/Color)s being used for various purpose
  - *background* - The background for the bar
  - *fill* - The filled portion of the bar
- *value* - Decimal number between 0 and 1 representing the percentage this bar should be filled

**Randomat:register(event)** - Registers the given table as a Randomat event and allows it to be chosen to be selected. **Must be called for event to function**.\
*Realm:* Server\
*Parameters:*
- *event* - Event table to register

**Randomat:RemoveEquipmentItem(ply, item_id)** - Removes and refunds a piece of equipment by ID.\
*Realm:* Server\
*Parameters:*
- *ply* - The player to remove equipment from
- *item_id* - The item ID to remove (e.g. EQUIP_RADAR)

*Returns:* `true` if the item was found and removed, `false` otherwise

**Randomat:RemovePhdFlopper(ply, block_message)** - Removes and refunds the PHD Flopper from the given player.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose PHD Flopper is being removed
- *block_message* - Whether to prevent the message explaining the the PHD Flopper has been removed

**Randomat:ResetPlayerScale(ply, id)** - Resets a player's model scale back to the default.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player whose scale is being reset
- *id* - The unique ID to use when tracking the cause of this player scale change. Used, specifically, for tracking movement speed changes

**Randomat:RestoreWeaponSound(wep)** - Restores the given weapon back to their default primary fire sound.\
*Realm:* Client and Server\
*Parameters:*
- *wep* - The weapon to restore

**Randomat:RoundedMeter(bs, x, y, w, h, color)** - Draws a rounded bar with the given parameters.\
*Realm:* Client\
*Parameters:*
- *bs* - Corner radius
- *x* - X position
- *y* - Y position
- *w* - Width
- *h* - Height
- *color* - The [Color](https://wiki.facepunch.com/gmod/Color) to use for the meter

**Randomat:SetRole(ply, role, set_max_hp, scale_hp)** - Sets the given player's role to the provided value. Automatically broadcasts the change via the `TTT_RoleChanged` net message.\
*Realm:* Server\
*Parameters:*
- *ply* - The player whose role is being changed
- *role* - The role the player is changing to
- *set_max_hp* - Whether to set the max HP of the player after their role is changed. Only works for the updated Custom Roles for TTT by Noxx and Malivil (Defaults to `true`)
- *scale_hp* - Whether to scale the player's health to maintain the same health fraction after their max health is changed. Requires `set_max_hp` to be `true`. Only works for the updated Custom Roles for TTT by Noxx and Malivil (Defaults to `true`)

**Randomat:SetPlayerInvisible(ply)** - Sets the given player to being invisible.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player who is being made invisible

**Randomat:SetPlayerVisible(ply)** - Sets the given player to being visible.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player who is being made visible

**Randomat:SafeTriggerEvent(id, ply, error_if_unsafe, ...)** - Safely triggers the event with the given ID.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event being started
- *ply* - The player who caused this event to be started
- *error_if_unsafe* - Whether to show an error message if the event cannot be started
- *...* - All parameters that could be passed into this event. Allows you to change aspects of an event based on what code calls it

**Randomat:SetPlayerScale(ply, scale, id, skip_speed)** - Sets the given player's model scale.\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player whose scale is being changed
- *scale* - The scale factor to apply to the player. A value of 1.5, for example, will make someone appear as 150% the size they normally would
- *id* - The unique ID to use when tracking the cause of this player scale change. Used, specifically, for tracking movement speed changes
- *skip_speed* - Whether to skip changing the player's movement speed

**Randomat:SendChatToAll(msg, tbl)** - Sends the message to all players in the given `tbl` (or all players if `tbl` is `nil`).\
*Realm:* Client and Server\
*Parameters:*
- *msg* - The message to send
- *tbl* - The table of players to send the message to. If not given or `nil`, the table of all players will be used instead

**Randomat:SendMessageToTeam(msg, roleTeam, detectivesAreInnocent, aliveOnly, printTypes)** - .\
*Realm:* Server\
*Parameters:*
- *msg* - The message to send
- *roleTeam* - The `ROLE_TEAM_*` value from Custom Roles for TTT, specifying which team to send the message to
- *detectivesAreInnocent* - Whether to also send to members of the detective team when `ROLE_TEAM_INNOCENTS` is given for `roleTeam`
- *aliveOnly* - Whether only alive players should be sent the message
- *printTypes* - The [HUD_PRINT*](https://wiki.facepunch.com/gmod/Enums/HUD) value(s) specifying how the message should be displayed. Can be a single value or a table of values. If not provided, defaults to `HUD_PRINTTALK`
- *excludedPlayers* - The table of players that should be skipped, even if they are on the target team

**Randomat:ShouldActLikeJester(ply)** - Determines whether the given player should be acting like a Jester (e.g. not taking fall damage, not doing weapon damage, etc.).\
*Realm:* Client and Server\
*Parameters:*
- *ply* - The player to check

*Returns:* `true` if the player passes the check, `false` otherwise

**Randomat:SilentTriggerEvent(id, ply, ...)** - Triggers the event with the given ID without notifying the players.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event being started
- *ply* - The player who caused this event to be started
- *...* - All parameters that could be passed into this event. Allows you to change aspects of an event based on what code calls it

**Randomat:SilentTriggerHiddenEvent(id, ply, reason, ...)** - Triggers the event with the given ID without notifying the players and also doesn't show it in the list of active events.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event being started
- *ply* - The player who caused this event to be started
- *reason* - A message explaining the reason why this event is hidden
- *...* - All parameters that could be passed into this event. Allows you to change aspects of an event based on what code calls it

**Randomat:SilentTriggerRandomEvent(ply)** - Triggers a random event without notifying the players.\
*Realm:* Server\
*Parameters:*
- *ply* - The player who caused this event to be started

**Randomat:SmallNotify(msg, length, target, silent, allow_secret, font_color)** - Displays a small notification message on all players' screens. If the "secret" event is active, this call is ignored unless `allow_secret` is `true`.\
*Realm:* Server\
*Parameters:*
- *msg* - The message to display
- *length* - The length of time (in seconds) the message should be displayed for (Optional, defaults to 5)
- *target* - The player to send the notification to. If not provided or `nil`, the notification is sent to all players (Optional)
- *silent* - Whether the notification should not make a sound when it is displayed (Optional, defaults to `false`)
- *allow_secret* - Whether to allow this message to go through even when the `secret` event is running (Optional, defaults to `false`)
- *font_color* - The [Color](https://wiki.facepunch.com/gmod/Color) of the font (Optional, defaults to rgb(255, 200, 0))

**Randomat:SpawnBarrel(pos, range, min_range, ignore_negative)** - Spawns an explosive barrel near the provided position.\
*Realm:* Server\
*Parameters:*
- *pos* - The position to spawn the barrel at
- *range* - The range away from the given position to spawn the barrel
- *min_range* - The minimum range away from the given position to spawn the barrel. (Optional, defaults to `range`)
- *ignore_negative* - Whether to disallow negative ranges

*Note:* If `range` and `min_range` are provided, a random range between `min_range` and `range` is selected for the X and Y locations

**Randomat:SpawnBee(ply, color, height)** - Spawns a bee near the given player.\
*Realm:* Server\
*Parameters:*
- *ply* - The player near which a bee is being spawned
- *color* - The [Color](https://wiki.facepunch.com/gmod/Color) of the bee to spawn (Optional)
- *height* - The height above the player to spawn the bee (Optional, defaults to a random value between 200 and 250)

*Returns:* The bee spawned

**Randomat:SpawnNPC(ply, pos, cls)** - Spawns an NPC of the provided class near the given player.\
*Realm:* Server\
*Parameters:*
- *ply* - The player responsible for the NPC being spawned
- *pos* - The position where the NPC is being spawned
- *cls* - The class of NPC being spawned

*Returns:* The NPC spawned

**Randomat:TriggerEvent(id, ply, ...)** - Triggers the event with the given ID.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event being started
- *ply* - The player who caused this event to be started
- *...* - All parameters that could be passed into this event. Allows you to change aspects of an event based on what code calls it

**Randomat:TriggerHiddenEvent(id, ply, reason, ...)** - Triggers the event with the given ID, but doesn't show it in the list of active events.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event being started
- *ply* - The player who caused this event to be started
- *reason* - A message explaining the reason why this event is hidden
- *...* - All parameters that could be passed into this event. Allows you to change aspects of an event based on what code calls it

**Randomat:TriggerRandomEvent(ply)** - Triggers a random event.\
*Realm:* Server\
*Parameters:*
- *ply* - The player who caused this event to be started

**Randomat:unregister(id)** - Un-registers the event with the given ID, preventing it from being found or starting.\
*Realm:* Server\
*Parameters:*
- *id* - The ID of the event being un-registered

### Tables
Tables which are used to track different data and which are available globally via the `Randomat` namespace

**Randomat.ActiveEvents** - Table containing all currently-running events.\
*Realm:* Server

**Randomat.EventHistory** - Table containing the list of the events that were previously started. Used to prevent running the same events too often.\
*Realm:* Server

**Randomat.Events** - Table containing all defined events with the key being the event ID.\
*Realm:* Server
