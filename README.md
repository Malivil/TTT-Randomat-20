Thanks to [Jenssons](https://steamcommunity.com/profiles/76561198044525091) for the 'TTT Randomat 2.0' mod which this is an update to.\
Thanks to [Gamefreak](https://steamcommunity.com/id/realgamefreak) for the 'TTT Randomat' mod which THAT was an update to.
\
\
**Edits the original version to support Custom Roles for TTT and add additional events**

# New Events
- Camp Fire
- Come on and SLAM!
- Shh... It's a Secret!
- The Cake is a Lie

# Events
## A Random Person will explode every X seconds! Watch out! (EXCEPT DETECTIVES)
This one is pretty self-explanitory
\
\
**ConVars**
\
_randomat_explode_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_explode_timer_ - Default: 30 - The time between explosions.

## Blind Traitors (aka All traitors have been blinded for X seconds!)
Blinds all traitors for a configurable amount of seconds
\
\
**ConVars**
\
_randomat_blind_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_blind_duration_ - Default: 39 - The duration the players should be blinded for.

## Butterfingers
Causes weapons to periodically slip out of players' hands
\
\
**ConVars**
\
_randomat_butter_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_butter_timer_ - Default: 10 - The time between each weapon drop.\
_randomat_butter_affectall_ - Default: 0 -Whether to affect every player at once rather than just a single random player.

## Camp Fire
Sets any player that is camping (has not moved far enough in the configurable time) on fire. Any player who is set on fire this way will be extinguished when they move.
\
\
**ConVars**
\
_randomat_campfire_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_campfire_timer_ - Default: 20 - Amount of time (in seconds) a player must camp before they are punished.\
_randomat_campfire_distance_ - Default: 35 - The distance a player must move before they are considered not camping anymore.

## Can't stop, won't stop.
Causes every player to constantly move forward
\
\
**ConVars**
\
_randomat_cantstop_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_cantstop_disableback_ - Default: 1 - Whether the "s" key is disabled.

## Choose an Event!
Presents random events to be chosen, either by a single player or by vote
\
\
**ConVars**
\
_randomat_choose_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_choose_choices_ - Default: 3 - Number of events you can choose from.\
_randomat_choose_vote_ - Default: 0 - Allows all players to vote on the event.\
_randomat_choose_votetimer_ - Default: 10 - How long players have to vote on the event.\
_randomat_choose_deadvoters_ - Default: 0 - Dead people can vote.

## Crabs are People
Spawns a configurable number of hostile headcrabs when a player is killed
\
\
**ConVars**
\
_randomat_crabs_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_crabs_count_ - Default: 5 - The amount of crabs spawned when someone dies.

## Don't. Blink.
Spawns a configurable number of Weeping Angels, each attached to a different player. The Weepiong Angel  will kill their assigned player when the player's back is turned
\
\
**ConVars**
\
_randomat_blink_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_blink_cap_ - Default: 12 - Maximum number of Weeping Angels spawned.\
_randomat_blink_delay_ - Default: 0.5 - Delay before Weeping Angels are spawned.

## Gunpowder, Treason, and Plot
Spawns barrels around every player repeatedly until the event ends
\
\
**ConVars**
\
_randomat_barrels_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_barrels_count_ - Default: 3 - Number of barrels spawned per person.\
_randomat_barrels_range_ - Default: 100 - Distance barrels spawn from the player.\
_randomat_barrels_timer_ - Default: 60 - Time between barrel spawns.

## I love democracy, I love the republic.
Allows players to vote to kill someone repeatedly until the event ends
\
\
**ConVars**
\
_randomat_democracy_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_democracy_timer_ - Default: 40 - The number of seconds each round of voting lasts.\
_randomat_democracy_tiekills_ - Default: 1 - If 1, ties result in a coin toss; if 0, nobody dies in a tied vote.\
_randomat_democracy_totalpct_ - Default: 50 - Percent of total player votes required for a vote to pass, set to 0 to disable.

## Infinite Ammo!
Gives all weapons infinite ammo, allowing players to constantly shoot without reloading
\
\
**ConVars**
\
_randomat_ammo_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_ammo_affectbuymenu_ - Default: 0 - Whether it gives buy menu weapons infinite ammo too.

## Infinite Credits for Everyone!
Gives all players essentially infinite credits for use in their shop menus (if they have one)
\
\
**ConVars**
\
_randomat_credits_enabled_ - Default: 1 - Whether this event is enabled.\

## NOT THE BEES!
Spawns bees randomly around around players
\
\
**ConVars**
\
_randomat_bees_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_bees_count_ - Default: 4 - The number of bees spawned per player.

## The 'bar has been raised!
Increases the damage and push force of the crowbar
\
\
**ConVars**
\
_randomat_crowbar_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_crowbar_damage_ - Default: 2.5 - Damage multiplier for the crowbar.\
_randomat_crowbar_push_ - Default: 30 - Push force multiplier for the crowbar.

## The Cake is a Lie
Rains cakes down around players which have a 50/50 chance or either healing or hurting when eaten
\
\
**ConVars**
\
_randomat_cakes_enabled_ - Default: 1 -  Whether this event is enabled.\
_randomat_cakes_count_ - Default: 2 -  Number of cakes spawned per person.\
_randomat_cakes_range_ - Default: 200 -  Distance cakes spawn from the player.\
_randomat_cakes_timer_ - Default: 60 -  Time between cake spawns, in seconds.\
_randomat_cakes_health_ - Default: 25 -  The amount of health the player will regain from eating a cake.\
_randomat_cakes_damage_ - Default: 25 -  The amount of health the player will lose from eating a cake.\
_randomat_cakes_damage_time_ - Default: 30 -  The amount of time the player will take damage after eating a cake, in seconds.\
_randomat_cakes_damage_interval_ - Default: 1 -  How often the player will take damage after eating a cake, in seconds.\
_randomat_cakes_damage_over_time_ - Default: 1 -  The amount of health the player will lose each tick after eating a cake.

# ULX Support
This version of the Randomat 2.0 should be compatible with all versions of the ULX Module for Randomat 2.0
That being said, I have created my [own version of the ULX Module](https://steamcommunity.com/sharedfiles/filedetails/?id=2096758509) which supports these new events as well as dynamic event loading with little-to-no developer interaction

# Special Thanks
- [Jenssons](https://steamcommunity.com/profiles/76561198044525091) for the 'TTT Randomat 2.0' mod which this is an update to.
- [Gamefreak](https://steamcommunity.com/id/realgamefreak) for the 'TTT Randomat' mod which THAT was an update to.
- Alex from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the fix for traitors not being completely blinded.
- [Grodbert](https://steamcommunity.com/id/Grodbert) for the [SCP-871](https://steamcommunity.com/sharedfiles/filedetails/?id=1992626478) model which is used in the 'The Cake is a Lie' event
- u/LegateLaurie on Reddit for the idea for the "Shh... It's a Secret!" event
- u/Shark_Shooter on Reddit for the idea for the "Come on and SLAM!" event
