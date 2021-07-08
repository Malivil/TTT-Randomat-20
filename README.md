Thanks to [Dem](https://steamcommunity.com/profiles/76561198076733538) for the 'TTT Randomat 2.0' mod which this is an update to.\
Thanks to [Gamefreak](https://steamcommunity.com/id/realgamefreak) for the 'TTT Randomat' mod which THAT was an update to.
\
\
**Edits the original version to support Custom Roles for TTT and add additional events**

# General Commands
_ttt_randomat_trigger EVENT_ - Triggers a specific randomat event without checking conditions.\
_ttt_randomat_safetrigger EVENT_ - Triggers a specific randomat event after checking conditions.\
_ttt_randomat_clearevent EVENT_ - Clears a specific randomat active event.\
_ttt_randomat_clearevents_ - Clears all active events.\
_ttt_randomat_triggerrandom_ - Triggers a random  randomat event.\
_ttt_randomat_disableall_ - Disables all events.\
_ttt_randomat_enableall_ - Enables all events.\
_ttt_randomat_resetweights_ - Resets all weights to their defaults.\

# General ConVars
_ttt_randomat_auto_ - Default: 0 - Whether the Randomat should automatically trigger on round start.\
_ttt_randomat_auto_chance_ - Default: 1 - Chance of the auto-Randomat triggering.\
_ttt_randomat_chooseevent_ - Default: 0 - Allows you to choose out of a selection of events.\
_ttt_randomat_rebuyable_ - Default: 0 - Whether you can buy more than one Randomat.\
_ttt_randomat_event_weight_ - Default: 1 - The default selection weight each event should use.\
_ttt_randomat_event_hint_ - Default: 0 - Whether the Randomat should print what each event does when they start.\
_ttt_randomat_event_hint_chat_ - Default: 0 - Whether hints should also be put in chat.

# New Events
- A Glitch has been patched
- Betrayed
- Big Head Mode
- Black Market Buyout
- Camp Fire
- Care Package
- Careful...
- Clownin' Around
- Come on and SLAM!
- Communism! Time to learn how to share...
- Compulsive Reloading
- Derptective
- Detraitor
- Don't be so Sensitive
- Don't Let it Go to Your Head
- Double Cross
- Double-Edged Sword
- Election Day
- Evasive Maneuvers
- Flip the Script
- Fog of War
- Flu Season
- Glitch in the Matrix
- I don't think you realise the gravity of the situation.
- Lonely Yogs
- NO NERD HEALING
- Olympic Sprint
- Opposite Day
- Prop Hunt
- Ransomat
- Rock, Paper, Scissors
- Run For Your Life!
- Sharing is Caring
- Shh... It's a Secret!
- Social Distancing
- The Cake is a Lie
- Time Warp
- Total Magnetism
- Wasteful!
- Zom-Bees!

# Events
## \#BringBackOldJester
Converts the Swapper to a Jester
\
\
**ConVars**
\
_ttt_randomat_oldjester_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_oldjester_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_oldjester_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## A Glitch has been patched
Changes a random Glitch into either an Innocent or a Traitor. There is a configurable chance that the player will be turned into an Innocent rather than a Traitor.
\
\
**ConVars**
\
_ttt_randomat_patched_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_patched_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_patched_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_patched_chance_ - Default: 50 - The chance of the Glitch being made a Traitor.

## A player is acting suspicious
Changes a random player to either a Jester or a Traitor. There is a configurable chance that the player will be turned into a Jester rather than a Traitor.
\
\
**ConVars**
\
_ttt_randomat_suspicion_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_suspicion_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_suspicion_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_suspicion_chance_ - Default: 50 - The chance of the player being a Jester.

## A Random Person will explode every X seconds! Watch out! (EXCEPT DETECTIVES)
This one is pretty self-explanitory. Detraitors are also excluded from explosion.
\
\
**ConVars**
\
_ttt_randomat_explode_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_explode_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_explode_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_explode_timer_ - Default: 30 - The time between explosions.

## A traitor will explode in X seconds!
This one is pretty self-explanitory
\
\
**ConVars**
\
_ttt_randomat_texplode_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_texplode_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_texplode_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_texplode_timer_ - Default: 60 - The time before the traitor explodes.\
_randomat_texplode_radius_ - Default: 600 - Radius of the traitor explosion.

## An innocent has been upgraded!
A random vanilla innocent is upgraded to a Mercenary or is given the choice of becoming a Mercenary or a Killer
\
\
**ConVars**
\
_ttt_randomat_upgrade_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_upgrade_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_upgrade_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_upgrade_chooserole_ - Default: 1 - Whether the innocent should choose their new role.

## Bad Gas
Drops random grenades (from the enabled types) at random players' feet on a configurable interval
\
\
**ConVars**
\
_ttt_randomat_gas_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_gas_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_gas_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_gas_timer_ - Default: 15 - Changes the time between grenade drops.\
_randomat_gas_affectall_ - Default: 0 - Set to 1 for the event to drop a grenade at everyone's feet on trigger.\
_randomat_gas_discombob_ - Default: 1 - Whether discombobs drop.\
_randomat_gas_incendiary_ - Default: 0 - Whether incendiaries drop.\
_randomat_gas_smoke_ - Default: 0 - Whether smokes drop.

## Bad Trip
Causes any player who is off the ground (by jumping, falling, etc.) to turn into a ragdoll temporarily
\
\
**ConVars**
\
_ttt_randomat_ragdoll_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_ragdoll_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_ragdoll_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_ragdoll_time_ - Default: 1.5 - The time the player is ragdolled.\
_randomat_ragdoll_delay_ - Default: 1.5 - The time between ragdolls.

## Betrayed
Randomly converts one vanilla Traitor to be a Glitch
\
\
**ConVars**
\
_ttt_randomat_betrayed_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_betrayed_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_betrayed_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Big Head Mode
Causes all players to have their heads grow to massive proportions.\
**NOTE**: Not all custom models are supported -- some have their hair detached from their head which looks creepy when the head scales the hair doesn't. I tried a few ways to fix it but that ended up breaking other stuff.
\
\
**ConVars**
\
_ttt_randomat_bighead_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_bighead_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_bighead_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_bighead_scale_ - Default: 2 - Head size multiplier.

## Black Market Buyout
Disables Traitor and Detective shop, but periodically gives out free items from both
\
\
**ConVars**
\
_ttt_randomat_blackmarket_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_blackmarket_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_blackmarket_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_blackmarket_blocklist_ - Default: - The comma-separated list of weapon IDs to not give out. For example: "ttt_m9k_harpoon,weapon_ttt_slam".
_randomat_blackmarket_timer_traitor_ - Default: 25 - How often (in seconds) traitors should get items.\
_randomat_blackmarket_timer_detective_ - Default: 15 - How often (in seconds) detectives should get items.

## Blind Traitors (aka All traitors have been blinded for X seconds!)
Blinds all traitors for a configurable amount of seconds
\
\
**ConVars**
\
_ttt_randomat_blind_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_blind_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_blind_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_blind_duration_ - Default: 39 - The duration the players should be blinded for.

## Butterfingers
Causes weapons to periodically slip out of players' hands
\
\
**ConVars**
\
_ttt_randomat_butter_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_butter_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_butter_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_butter_timer_ - Default: 10 - The time between each weapon drop.\
_randomat_butter_affectall_ - Default: 0 -Whether to affect every player at once rather than just a single random player.

## Camp Fire
Sets any player that is camping (has not moved far enough in the configurable time) on fire. Any player who is set on fire this way will be extinguished when they move.
\
\
**ConVars**
\
_ttt_randomat_campfire_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_campfire_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_campfire_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_campfire_timer_ - Default: 20 - Amount of time (in seconds) a player must camp before they are punished.\
_randomat_campfire_distance_ - Default: 35 - The distance a player must move before they are considered not camping anymore.

## Can't stop, won't stop.
Causes every player to constantly move forward
\
\
**ConVars**
\
_ttt_randomat_cantstop_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_cantstop_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_cantstop_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_cantstop_disableback_ - Default: 1 - Whether the "s" key is disabled.

## Care Package
Spawns an ammo crate somewhere in the map that contains a free item from the various role shops.
\
\
**ConVars**
\
_ttt_randomat_package_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_package_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_package_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_package_blocklist_ - Default: - The comma-separated list of weapon IDs to not give out. For example: "ttt_m9k_harpoon,weapon_ttt_slam".

## Careful...
Set all Jesters and Swappers to a reduced (and configurable) amount of health.
\
\
**ConVars**
\
_ttt_randomat_careful_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_careful_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_careful_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_careful_health_ - Default: 1 - Health to set Jester/Swapper to.

## Choose an Event!
Presents random events to be chosen, either by a single player or by vote
\
\
**ConVars**
\
_ttt_randomat_choose_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_choose_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_choose_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_choose_choices_ - Default: 3 - Number of events you can choose from.\
_randomat_choose_vote_ - Default: 0 - Allows all players to vote on the event.\
_randomat_choose_votetimer_ - Default: 10 - How long players have to vote on the event.\
_randomat_choose_deadvoters_ - Default: 0 - Dead people can vote.

## Clownin' Around (aka We All Float Down Here)
Converts a Jester/Swapper to a Killer Clown
\
\
**ConVars**
\
_ttt_randomat_clowninaround - Default: 1 - Whether this event is enabled.\
_ttt_randomat_clowninaround_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_clowninaround_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Come on and SLAM!
Gives everyone an M4 SLAM and only allows players to use the M4 SLAM for the duration of the event. Will not trigger if there is a Jester or a Swapper since they cannot win during this event.
\
\
**ConVars**
\
_ttt_randomat_slam_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_slam_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_slam_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_slam_timer_ - Default: 3 - Time between being given slams.\
_randomat_slam_strip_ - Default: 1 - The event strips your other weapons.\
_randomat_slam_weaponid_ - Default: weapon_ttt_slam - Id of the weapon given.

## Communism! Time to learn how to share...!
Whenever anyone buys a weapon from a shop, all other players get that weapon too. They must not have anything in that slot already.
\
\
**ConVars**
\
_ttt_randomat_communist_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_communist_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_communist_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_communist_show_roles_ - Default: 1 - Whether to show the role of the purchasing player.

## Compulsive Reloading
Slowly drains a user's ammo over time if they haven't fired recently.
\
\
**ConVars**
\
_ttt_randomat_reload_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_reload_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_reload_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_reload_wait_time_ - Default: 5.0 - Seconds after last shot to wait before draining.\
_randomat_reload_drain_time_ - Default: 2.0 - Seconds between each ammo drain.\
_randomat_reload_keep_ammo_ - Default: 1 - Whether drained ammo is kept (1) or destroyed (0).\
_randomat_reload_affectbuymenu_ - Default: 0 - Whether buy menu weapons lose ammo too.

## Crabs are People
Spawns a configurable number of hostile headcrabs when a player is killed
\
\
**ConVars**
\
_ttt_randomat_crabs_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_crabs_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_crabs_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_crabs_count_ - Default: 5 - The amount of crabs spawned when someone dies.

## Dead Men Tell no Tales
Prevents corpses from being searched
\
\
**ConVars**
\
_ttt_randomat_search_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_search_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_search_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Derptective
Forces the detective(s) and detraitor(s) to use the M249 H.U.G.E. with infinite ammo and an adjusted rate of fire.
\
\
**ConVars**
\
_ttt_randomat_derptective_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_derptective_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_derptective_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_derptective_rate_of_fire_ - Default: 2 - Rate of Fire multiplier for the H.U.G.E..

## Detraitor
The Detective has been corrupted and joined the Traitor team!
\
\
**ConVars**
\
_ttt_randomat_detraitor_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_detraitor_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_detraitor_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Don't be so Sensitive
Periodically changes each player's mouse sensitivity to a number within the configurable range
\
\
**ConVars**
\
_ttt_randomat_sensitive_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_sensitive_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_sensitive_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_sensitive_change_interval_ - Default: 15 - How often to change each player's sensitivity.\
_randomat_sensitive_scale_min_ - Default: 25 - The minimum sensitivity to use.\
_randomat_sensitive_scale_max_ - Default: 500 - The maximum sensitivity to use.

## Don't. Blink.
Spawns a configurable number of Weeping Angels, each attached to a different player. The Weeping Angel will kill their assigned player when the player's back is turned
\
\
**ConVars**
\
_ttt_randomat_blink_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_blink_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_blink_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_blink_cap_ - Default: 12 - Maximum number of Weeping Angels spawned.\
_randomat_blink_delay_ - Default: 0.5 - Delay before Weeping Angels are spawned.

## Don't Let it Go to Your Head
Grows a player's head by a set amount each time they kill. Also grows by the same size of their victim's head.
\
\
**ConVars**
\
_ttt_randomat_headgrow_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_headgrow_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_headgrow_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_headgrow_max_ - Default: 2.5 - The maximum head size multiplier.\
_randomat_headgrow_per_kill_ - Default: 0.25 - The head size increase per kill.\
_randomat_headgrow_steal_ - Default: 1 - Whether to steal a player's head size on kill.

## Double Cross
Changes a random vanilla Innocent into either a Glitch or a Traitor. There is a configurable chance that the player will be turned into a Glitch rather than a Traitor.
\
\
**ConVars**
\
_ttt_randomat_doublecross_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_doublecross_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_doublecross_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_doublecross_chance_ - Default: 50 - The chance of the Innocent being made a Traitor.

## Double-Edged Sword
Reflects 1/2 of the damage you do back on yourself, but you also heal self-damage slowly.
\
\
**ConVars**
\
_ttt_randomat_doubleedge_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_doubleedge_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_doubleedge_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_doubleedge_interval_ - Default: 1 - How often (in seconds) to heal self-damage.\
_randomat_doubleedge_amount_ - Default: 2 - How much self-damage to heal per interval.

## Election Day
Starts a two-part election. In the first part, players will nominate other players to become the president. The detective is not allowed to be nominate as they are already a President (per the GET DOWN MR. PRESIDENT Event).\
In the second part of the election, the two nominees with the most nominations will take part in a run-off vote, winner takes all.\
If a member of the innocent team wins, they are promoted to a Detective and given credits as a reward.\
If a member of the traitor team wins, all traitors are given credits as a reward, but the new President's role is revealed.\
If a Jester wins, they are killed by whoever owned the Randomat, winning the round.\
If a Swapper wins, they are killed by a random player, after which they swap roles.\
If a Killer wins, all non-Jester/Swapper players are killed, winning the round for the Killer.\
If a Zombie wins, the RISE FROM YOUR GRAVE event is triggered, silently.\
If a Vampire wins, the configured team (see _randomat_election_vamp_turn_innocents_ below) are converted to Vampires.\
If a Drunk wins, they will instantly remember what role they are supposed to be.\
If the Old Man wins, everyone else will become as frail as they are (e.g. reduced to 1 health).\
If the Clown wins, whichever team (Innocent or Traitor) has more players will be killed, causing the Clown to instantly trigger and go on a rampage. If only one team has players alive, a random living player from that team will be sacrificed to help the Clown toward victory.\
If the Beggar wins, an innocent or traitor team member will be chosen randomly to give the beggar a random shop weapon, causing the beggar to join that team.
\
\
**ConVars**
\
_ttt_randomat_election_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_election_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_election_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_election_timer_ - Default: 40 - The number of seconds each round of voting lasts.\
_randomat_election_winner_credits_ - Default: 2 - The number of credits given as a reward, if appropriate.\
_randomat_election_vamp_turn_innocents_ - Default: 0 - Whether Vampires turn innocents. Otherwise, turns traitors.\
_randomat_election_show_votes_ - Default: 1 - Whether to show who each player voted for in chat.\
_randomat_election_trigger_mrpresident_ - Default: 0 - Whether to trigger Get Down Mr. President if an Innocent wins.\
_randomat_election_break_ties_ - Default: 0 - Whether to break ties by choosing a random winner.

## Evasive Maneuvers
Causes players who are shot to "dodge" out of the way of further bullets
\
\
**ConVars**
\
_ttt_randomat_evasive_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_evasive_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_evasive_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_evasive_force_ - Default: 2000 - Amount of force to push players with.\
_randomat_evasive_jumping_force_ - Default: 1000 - Amount of force to push jumping players with.

## Everything is as fast as Flash now! (XX% faster)
Causes everything (movement, firing speed, timers, etc.) to run a configurable amount faster than normal
\
\
**ConVars**
\
_ttt_randomat_flash_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_flash_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_flash_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_flash_scale_ - Default: 50 - The percentage the speed should increase. Treated as an additive increase on multiple uses (e.g. 1.0 -> 1.5 -> 2.0 (1.5 + 0.5) rather than 1.0 -> 1.5 -> 2.25 (1.5 + 1.5x0.5)

## Flip the Script
Inverses everyone's health
\
\
**ConVars**
\
_ttt_randomat_flipthescript_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_flipthescript_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_flipthescript_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Flu Season
Randomly infects a player with the flu, causing them to sneeze occasionally. Also has a chance to spread to other players within a configurable distance
\
\
**ConVars**
\
_ttt_randomat_flu_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_flu_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_flu_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_flu_timer_ - Default: 1 - Time a player must be near someone before it spreads.\
_randomat_flu_interval_ - Default: 10 - How often effects happen to infected.\
_randomat_flu_distance_ - Default: 100 - Distance a player must be from another to be considered "near".\
_randomat_flu_chance_ - Default: 25 - Spreading chance.\
_randomat_flu_speed_factor_ - Default: 0.8 - What speed the infected player should be reduced to.

## Fog of War
Covers the map in a fog which restricts player view
\
\
**ConVars**
\
_ttt_randomat_fogofwar_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_fogofwar_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_fogofwar_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_fogofwar_default_ - Default: 1.0 - The fog distance scale for non-traitors.\
_randomat_fogofwar_traitor_ - Default: 1.5 - The fog distance scale for traitors.

## FREEZE!
aka Winter has come at last.\
aka The Ice Man cometh.\
aka In this universe, there is only one absolute: everything freezes!\
aka Tonight, Hell freezes over.\
aka I'm afraid my condition has left me cold to your pleas of mercy.\
aka Cool party.\
aka You are not sending me to the cooler.\
aka Stay cool, bird boy.\
aka Alright, everyone! Chill!\
aka It's a cold town.\
aka Tonight's forecast: a freeze is coming!\
aka What killed the dinosaurs?! The ice age!\
aka Let's kick some ice!\
aka Can you feel it coming? The icy cold of space!\
aka Freeze in hell, Batman!\
\
All Innocents will Freeze (and become immune) every X seconds
\
\
**ConVars**
\
_ttt_randomat_freeze_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_freeze_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_freeze_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_freeze_duration_ - Default: 5 - Duration of the Freeze (in seconds).\
_randomat_freeze_timer_ - Default: 30 - How often (in seconds) the Freeze occurs.\
_randomat_freeze_hint_ - Default: 1 - Whether to explain the event after triggering.

## Gaining life for killing people? Is it really worth it...
Heals players who kill other players
\
\
**ConVars**
\
_ttt_randomat_lifesteal_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_lifesteal_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_lifesteal_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_lifesteal_health_ - Default: 25 - The health gained per kill.\
_randomat_lifesteal_cap_ - Default: 0 - The maximum health a player can get from killing people. Set to 0 to disable.

## Get Down Mr President!
Gives all Detectives extra health, but kills all members of the Innocent team if they get killed
\
\
**ConVars**
\
_ttt_randomat_president_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_president_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_president_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_president_bonushealth_ - Default: 100 - Extra health gained by the detective.

## Glitch in the Matrix
Randomly changes everyone's role to be either Glitch or Traitor based on the configurable values
\
\
**ConVars**
\
_ttt_randomat_glitch_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_glitch_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_glitch_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_glitch_blocklist_ - Default: - The comma-separated list of weapon IDs to not give out. For example: "ttt_m9k_harpoon,weapon_ttt_slam".\
_randomat_glitch_traitor_pct_ - Default: 25 - The percentage of players that will be traitors.\
_randomat_glitch_damage_scale_ - Default: 1.0 - The multiplier for damage that the Glitches will take.\
_randomat_glitch_max_glitches_ - Default: 0 - The maximum number of Glitches this event will create. Setting to 0 will not limit the number of Glitches.\
_randomat_glitch_starting_health_ - Default: 100 - The amount of health the Glitches should start with.\
_randomat_glitch_min_traitors_ - Default: 0 - The minimum number of Traitors before this event will run.

## Gun Game
Periodically gives players random weapons that would normally be found throughout the map
\
\
**ConVars**
\
_ttt_randomat_gungame_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_gungame_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_gungame_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_gungame_timer_ - Default: 5 - Time between weapon changes.

## Gunpowder, Treason, and Plot
Spawns explosive barrels around every player repeatedly until the event ends
\
\
**ConVars**
\
_ttt_randomat_barrels_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_barrels_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_barrels_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_barrels_count_ - Default: 3 - Number of barrels spawned per person.\
_randomat_barrels_range_ - Default: 100 - Distance barrels spawn from the player.\
_randomat_barrels_timer_ - Default: 60 - Time between barrel spawns.

## Harpooooooooooooooooooooon!!
Gives everyone a Harpoon and only allows players to use the Harpoon for the duration of the event.
\
\
**ConVars**
\
_ttt_randomat_harpoon_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_harpoon_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_harpoon_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_harpoon_timer_ - Default: 3 - Time between being given harpoons.\
_randomat_harpoon_strip_ - Default: 1 - The event strips your other weapons.\
_randomat_harpoon_weaponid_ - Default: ttt_m9k_harpoon - Id of the weapon given.

## Honey, I shrunk the terrorists
Scales each player's size by a configurable ratio
\
\
**ConVars**
\
_ttt_randomat_shrink_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_shrink_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_shrink_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_shrink_scale_ - Default: 0.5 - The shrinking scale factor.

## I don't think you realise the gravity of the situation.
Gravity is changed every few seconds for a short period of time before reverting to normal.  
It goes gack and forth between being lowered and raised each time.
\
\
**ConVars**
\
_ttt_randomat_gravity_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_gravity_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_gravity_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_gravity_timer_ - Default: 30 - How long between changes.\
_randomat_gravity_duration_ - Default: 3 - How many seconds the change lasts.\
_randomat_gravity_minimum_ - Default: 70 - The gravity when it is lowered.\
_randomat_gravity_maximum_ - Default: 2000 - The gravity when it is raised.

## I love democracy, I love the republic.
Allows players to vote to kill someone repeatedly until the event ends
\
\
**ConVars**
\
_ttt_randomat_democracy_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_democracy_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_democracy_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_democracy_timer_ - Default: 40 - The number of seconds each round of voting lasts.\
_randomat_democracy_tiekills_ - Default: 1 - If 1, ties result in a coin toss; if 0, nobody dies in a tied vote.\
_randomat_democracy_totalpct_ - Default: 50 - Percent of total player votes required for a vote to pass, set to 0 to disable.\
_randomat_democracy_jestermode_ - Default: 0 - What to do when a Jester/Swapper is voted for. 0 - Kill a random player that voted for them. 1 - Kill the Jester/Swapper, activating their "ability". 2 - Let the Jester/Swapper choose who of their voters to kill.

## I see dead people
Drops a Visualizer whenever a player is killed
\
\
**ConVars**
\
_ttt_randomat_visualiser_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_visualiser_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_visualiser_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Infinite Ammo!
Gives all weapons infinite ammo, allowing players to constantly shoot without reloading
\
\
**ConVars**
\
_ttt_randomat_ammo_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_ammo_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_ammo_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_ammo_affectbuymenu_ - Default: 0 - Whether it gives buy menu weapons infinite ammo too.

## Infinite Credits for Everyone!
Gives all players essentially infinite credits for use in their shop menus (if they have one)
\
\
**ConVars**
\
_ttt_randomat_credits_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_credits_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_credits_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Lonely Yogs
Drops a discombob between two players who get too close.
\
\
**ConVars**
\
_ttt_randomat_lonelyyogs_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_lonelyyogs_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_lonelyyogs_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_lonelyyogs_distance_ - Default: 200 - The minimum distance allowed between players.\
_randomat_lonelyyogs_interval_ - Default: 2 - The number of seconds between discombob blasts.

## Malfunction
Causes players to randomly shoot their gun
\
\
**ConVars**
\
_ttt_randomat_malfunction_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_malfunction_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_malfunction_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_malfunction_upper_ - Default: 15 - The upper limit for the random timer.\
_randomat_malfunction_lower_ - Default: 1 - The lower limit for the random timer.\
_randomat_malfunction_affectall_ - Default: 0 - Set to 1 for the event to affect everyone at once.\
_randomat_malfunction_duration_ - Default: 0.5 - Duration of gun malfunction (set to 0 for 1 shot).

## No more Fall Damage!
Prevents any player from taking damage when they fall
\
\
**ConVars**
\
_ttt_randomat_falldamage_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_falldamage_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_falldamage_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## NO NERD HEALING
Prevents any player from regaining lost health
\
\
**ConVars**
\
_ttt_randomat_noheal_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_noheal_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_noheal_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## No one can hide from my sight
Puts a green outline around every player
\
\
**ConVars**
\
_ttt_randomat_wallhack_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_wallhack_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_wallhack_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## NOT THE BEES!
Spawns bees randomly around players
\
\
**ConVars**
\
_ttt_randomat_bees_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_bees_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_bees_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_bees_count_ - Default: 4 - The number of bees spawned per player.

## Olympic Sprint
Disables sprint stamina consumption, allowing players to sprint forever.\
NOTE: Only works with the latest Custom Roles version and will auto-disable on older versions.
\
\
**ConVars**
\
_ttt_randomat_olympicsprint_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_olympicsprint_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_olympicsprint_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## One traitor, One Detective. Everyone else is a Jester. Detective is stronger.
This one is pretty self-explanitory except for the "Detective is stronger" part. That just means the detective has 200 health.\
NOTE: This event is automatically disabled in the outdated version of Custom Roles for TTT. This is due to an issue where the round would not end if a Jester was killed and there were multiple Jesters.
\
\
**ConVars**
\
_ttt_randomat_jesters_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_jesters_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_jesters_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Opposite Day
Swaps movement keys to their opposites (e.g. Left is Right, Forward is Backward) and swaps the Fire and Reload keys.\
NOTE: Sprinting will only work when going backwards in the outdated version of Custom Roles for TTT.
\
\
**ConVars**
\
_ttt_randomat_opposite_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_opposite_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_opposite_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_opposite_hardmode_ - Default: 1 - Whether to enable hard mode and switch Jump/Crouch.

## Prop Hunt
Converts all Jester/Swapper and innocent team members to the Innocent role, strip their weapons, and gives them a Prop Disguiser. Converts all monster and traitor team members to the Traitor role.
\
\
**ConVars**
\
_ttt_randomat_prophunt_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_prophunt_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_prophunt_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_prophunt_timer_ - Default: 3 - Time between being given prop disguisers.\
_randomat_prophunt_strip_ - Default: 1 - The event strips your other weapons.\
_randomat_prophunt_blind_time_ = Default: 0 - How long to blind the hunters for at the start.\
_randomat_prophunt_round_time_ = Default: 0 - How many seconds the Prop Hunt round should last.\
_randomat_prophunt_weaponid_ - Default: weapon_ttt_prophide - Id of the weapon given.

## Quake Pro
Increases each player's Field of View (FOV) so it looks like you're playing Quake
\
\
**ConVars**
\
_ttt_randomat_fov_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_fov_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_fov_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_fov_scale_ - Default: 1.5 - Scale of the FOV increase.

## Random Health for everyone!
Gives everyone a random amount of health within the configurable boundaries
\
\
**ConVars**
\
_ttt_randomat_randomhealth_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_randomhealth_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_randomhealth_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_randomhealth_upper_ - Default: 100 - The upper limit of health gained.\
_randomat_randomhealth_lower_ - Default: 0 - The lower limit of health gained.

## Random xN
Triggers a configurable number of random events, one every 5 seconds
\
\
**ConVars**
\
_ttt_randomat_randomxn_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_randomxn_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_randomxn_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_randomxn_triggers_ - Default: 5 - Number of Randomat events activated.\
_randomat_randomxn_timer_ - Default: 5 - How often (in seconds) a random event will be triggered.\
_randomat_randomxn_multiple_ - Default: 1 - Allow event to run multiple times.\
_randomat_randomxn_triggerbyotherrandom_ - Default: 1 - Allow being triggered by other events like Randomness Intensifies.

## Randomness Intensifies
Periodically triggers random Randomat events for the duration of this event
\
\
**ConVars**
\
_ttt_randomat_intensifies_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_intensifies_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_intensifies_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_intensifies_timer_ - Default: 20 - How often (in seconds) a random event will be triggered.\
_randomat_intensifies_triggerbyotherrandom_ - Default: 1 - Allow being triggered by other events like Random xN.

## Ransomat
Chooses a random person with a buy menu and forces them to buy an item from the shop or else they die
\
\
**ConVars**
\
_ttt_randomat_ransom_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_ransom_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_ransom_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_ransom_traitorsonly_ - Default: 0 - Only target Traitors for the event.\
_randomat_ransom_deathtimer_ - Default: 60 - The amount of time the person has to buy something.

## RISE FROM YOUR GRAVE
Causes anyone who dies to be resurrected as a Zombie
\
\
**ConVars**
\
_ttt_randomat_grave_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_grave_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_grave_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_grave_health_ - Default: 30 - The health that the Zombies respawn with.

## Rock, Paper, Scissors
Starts a game of Rock, Paper, Scissors between two players... to the death! A tie results in the players being soulbound to eachother.
\
\
**ConVars**
\
_ttt_randomat_rockpaperscissors_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_rockpaperscissors_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_rockpaperscissors_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_rockpaperscissors_bestof_ - Default: 3 - How many rounds to play.

## Run For Your Life!
Hurts a player while they are sprinting
\
\
**ConVars**
\
_ttt_randomat_runforyourlife_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_runforyourlife_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_runforyourlife_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_runforyourlife_delay_ - Default: 0.2 - Time between player taking damage.\
_randomat_runforyourlife_damage_ - Default: 3 - Amount of damage a player takes.

## Sharing is Caring
When a player kills another, their inventory is swapped with thier victim's.
\
\
**ConVars**
\
_ttt_randomat_sharingiscaring_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_sharingiscaring_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_sharingiscaring_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Shh... It's a Secret!
Runs another random Randomat event without notifying the players. Also silences all future Randomat events while this event is active.
\
\
**ConVars**
\
_ttt_randomat_secret_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_secret_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_secret_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## SHUT UP!
Disables all sounds for the duration of the event
\
\
**ConVars**
\
_ttt_randomat_shutup_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_shutup_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_shutup_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## So that's it. What, we're some kind of suicide squad? (aka Detonators)
Gives everyone a detonator for a random other player. When that detonator is used, the target player is exploded.
\
\
**ConVars**
\
_ttt_randomat_suicide_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_suicide_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_suicide_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Social Distancing
Does a small amount of damage over time to players who spend too much time close to eachother.
\
\
**ConVars**
\
_ttt_randomat_distancing_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_distancing_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_distancing_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_distancing_timer_ - Default: 10 - Seconds a player must be near another player before damage starts.\
_randomat_distancing_interval_ - Default: 2 - How often damage is done when players are too close.\
_randomat_distancing_distance_ - Default: 100 - Distance a player must be from another to be considered "near".\
_randomat_distancing_damage_ - Default: 1 - Damage done to each player who is too close.

## Sosig.
Changes all primary weapon shooting sounds to "Sosig"
\
\
**ConVars**
\
_ttt_randomat_sosig_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_sosig_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_sosig_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Soulmates
Pairs random players together. When either of the paired players is killed, the other is automatically killed as well
\
\
**ConVars**
\
_ttt_randomat_soulmates_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_soulmates_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_soulmates_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_soulmates_affectall_ - Default: 0 - Whether everyone should have a soulmate.\
_randomat_soulmates_sharedhealth_ - Default: 0 - Whether soulmates should have shared health.

## Sudden Death!
Changes everyone to have only 1 health
\
\
**ConVars**
\
_ttt_randomat_suddendeath_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_suddendeath_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_suddendeath_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Taking Inventory
Swaps player inventories periodically throughout the round. There are some caveats to how this event interacts with special roles:
- Non-prime Zombies are excluded
- Prime Zombies will keep their claws
- Players who received a Killer's inventory will be given a crowbar instead of the Killer's knife

**ConVars**
\
_ttt_randomat_inventory_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_inventory_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_inventory_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_inventory_timer_ - Default: 15 - Time between inventory swaps.

## The 'bar has been raised!
Increases the damage and push force of the crowbar
\
\
**ConVars**
\
_ttt_randomat_crowbar_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_crowbar_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_crowbar_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_crowbar_damage_ - Default: 2.5 - Damage multiplier for the crowbar.\
_randomat_crowbar_push_ - Default: 30 - Push force multiplier for the crowbar.

## The Cake is a Lie
Rains cakes down around players which have a 50/50 chance or either healing or hurting when eaten
\
\
**ConVars**
\
_ttt_randomat_cakes_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_cakes_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_cakes_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_cakes_count_ - Default: 2 - Number of cakes spawned per person.\
_randomat_cakes_range_ - Default: 200 - Distance cakes spawn from the player.\
_randomat_cakes_timer_ - Default: 60 - Time between cake spawns, in seconds.\
_randomat_cakes_health_ - Default: 25 - The amount of health the player will regain from eating a cake.\
_randomat_cakes_damage_ - Default: 25 - The amount of health the player will lose from eating a cake.\
_randomat_cakes_damage_time_ - Default: 30 - The amount of time the player will take damage after eating a cake, in seconds.\
_randomat_cakes_damage_interval_ - Default: 1 - How often the player will take damage after eating a cake, in seconds.\
_randomat_cakes_damage_over_time_ - Default: 1 - The amount of health the player will lose each tick after eating a cake.

## There's this game my father taught me years ago, it's called "Switch"
Randomly switches positions of two players on a configurable interval
\
\
**ConVars**
\
_ttt_randomat_switch_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_switch_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_switch_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_switch_timer_ - Default: 15 - How often players are switched.

## Time Warp
Causes everything (movement, firing speed, timers, etc.) to run a configurable amount faster than normal and intensifies on a configurable interval
\
\
**ConVars**
\
_ttt_randomat_timewarp_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_timewarp_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_timewarp_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_timewarp_scale_ - Default: 50 - The percentage the speed should increase. Treated as an additive increase on multiple uses (e.g. 1.0 -> 1.5 -> 2.0 (1.5 + 0.5) rather than 1.0 -> 1.5 -> 2.25 (1.5 + 1.5x0.5).\
_randomat_timewarp_scale_max_ - Default: 8 - The maximum scale the speed should increase to.\
_randomat_timewarp_timer_ - Default: 15 - How often (in seconds) the speed will be increased.

## Total Magnetism
When a player dies, all nearby players will be pulled toward their corpse
\
\
**ConVars**
\
_ttt_randomat_magnetism_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_magnetism_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_magnetism_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_magnetism_radius_ - Default: 1000 - The radius around the dead player for magnetism.

## Total Mayhem
Causes players to explode when killed
\
\
**ConVars**
\
_ttt_randomat_mayhem_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_mayhem_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_mayhem_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Try your best...
Gives each player a random pistol and main weapon that they cannot drop
\
\
**ConVars**
\
_ttt_randomat_randomweapon_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_randomweapon_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_randomweapon_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Wasteful!
Every gun shot uses two bullets
\
\
**ConVars**
\
_ttt_randomat_wasteful_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_wasteful_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_wasteful_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## We learned how to heal over time, its hard, but definitely possible... (aka Regeneration)
Causes players to slowly regenerate lost health over time
\
\
**ConVars**
\
_ttt_randomat_regeneration_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_regeneration_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_regeneration_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_regeneration_delay_ - Default: 10 - How long after taking damage you will start to regen health.\
_randomat_regeneration_health_ - Default: 1 - How much health per second you heal.

## We've updated our privacy policy.
Alerts all players when an item is bought from a shop
\
\
**ConVars**
\
_ttt_randomat_privacy_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_privacy_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_privacy_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## What? Moon Gravity on Earth?
Changes the gravity of each player to the configurable scale
\
\
**ConVars**
\
_ttt_randomat_moongravity_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_moongravity_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_moongravity_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_moongravity_gravity_ - Default: 0.1 - The gravity scale.

## What did I find in my pocket?
Gives each player a random buyable weapon
\
\
**ConVars**
\
_ttt_randomat_pocket_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_pocket_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_pocket_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_pocket_blocklist_ - Default: - The comma-separated list of weapon IDs to not give out. For example: "ttt_m9k_harpoon,weapon_ttt_slam".

## What gamemode is this again? (aka Murder)
Changes the rules so the round plays like the Murder gamemode:
- Detectives are given a revolver which will kill players in 1 shot
- Traitors are given a knife that does a configurable amount of damage
- Non-traitor players can gather gun parts (by picking up guns off the ground) to build themselves a revolver
- Traitors destroy all gun parts they find

Player roles are also adjusted when this event begins:
- Traitor and Monster team members are converted to vanilla traitors
- Detectives and Killers are left alone
- Everyone else is converted to a vanilla innocent

**ConVars**
\
_ttt_randomat_murder_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_murder_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_murder_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_murder_pickups_pct_ - Default: 1.5 - Ratio of weapons required to get a revolver. Value = (ConVarValue x TotalWeapons)/Players.\
_randomat_murder_knifespeed_ - Default: 1.2 - Player move speed multiplier whilst knife is held.\
_randomat_murder_knifedmg_ - Default: 50 - Damage of the traitor's knife.\
_randomat_murder_highlight_gun_ - Default: 1 - Whether to highlight dropped revolvers.\
_randomat_murder_allow_shop_ - Default: 0 - Whether to allow the shop to be used.

## You can only jump once.
Kills any player who jumps a second time after this event has triggered
\
\
**ConVars**
\
_ttt_randomat_jump_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_jump_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_jump_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_jump_jesterspam_ - Default: 0 - Whether to show the message multiple times for a Jester/Swapper.

## Zom-Bees!
Spawns bees who spread zombiism to their victims. See "NOT THE BEES!" and "RISE FROM YOUR GRAVE" events for additional configuration.
\
\
**ConVars**
\
_ttt_randomat_zombees_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_zombees_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_zombees_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

# ULX Support
This version of the Randomat 2.0 should be compatible with all versions of the ULX Module for Randomat 2.0 (other than any new events or ConVars or renamed ConVars).\
That being said, I have created my [own version of the ULX Module](https://steamcommunity.com/sharedfiles/filedetails/?id=2096758509) which supports these new events as well as dynamic event loading with little-to-no developer interaction.

# Description Support
One of the additions made in this version of the Randomat 2.0 is the ability to print a description of an event on screen and/or in chat when the event starts.\
All existing events have been updated to support this functionality and any external events that exist will still operate as they have done before.\
If a developer of an external Randomat event would like to add support for this functionality, simply add a `Description` property to the event definition.\
\
Another thing that was added is the concept of an event "type". This is currently being used to make sure multiple events that override weapons (like Harpoon, Slam, Prop Hunt, etc.) don't run concurrently. To set your event to not conflict with those as well, set the `Type` property to `EVENT_TYPE_WEAPON_OVERRIDE`.

# Special Thanks
- [Dem](https://steamcommunity.com/profiles/76561198076733538) for the "TTT Randomat 2.0" mod which this is an update to
- [Gamefreak](https://steamcommunity.com/id/realgamefreak) for the "TTT Randomat" mod which THAT was an update to
- [Grodbert](https://steamcommunity.com/id/Grodbert) for the [SCP-871](https://steamcommunity.com/sharedfiles/filedetails/?id=1992626478) model which is used in the "The Cake is a Lie" event
- u/LegateLaurie on Reddit for the idea for the "Shh... It's a Secret!" event
- u/Shark_Shooter on Reddit for the idea for the "Come on and SLAM!" event
- u/zoxzix89 on Reddit for the idea for the "Time Warp" event
- u/Mad_Hatt3r on Reddit for the idea for the "Don't be so Sensitive" event
- u/ttimo123456 on Reddit for the idea for the "Prop Hunt" event
- u/alt----f4 on Reddit for the idea for the "A Glitch has been patched" event
- u/dinnaehuv1 on Reddit for the idea for the "Double Cross" event
- u/Grizzledude8 on Reddit for the idea for the "Social Distancing" event
- u/A_Very_Lonely_Waffle and u/Agenta521 on Reddit for the idea for the "Election Day" event
- u/Slowghost16 on Reddit for the idea for the _randomat_soulmates_sharedhealth_ ConVar for the "Soulmates" event
- u/MysticBloodWolf on Reddit for the idea for the "Big Head Mode", "Rock, Paper, Scissors", and "Run For Your Life!" events
- u/Speedlovar on Reddit for the idea for the "Care Package", "Careful...", "Compulsive Reloading", "Derptective", and "Opposite Day" events
- u/haladur on Reddit for the idea for the "Zom-Bees!" event
- u/Ill_Worry7895 on Reddit for the idea for the "Black Market Buyout", "Double-Edged Sword", "Evasive Maneuvers", "Sharing is Caring", and "Total Magnetism" events
- u/PM_ME_OODS on Reddit for the idea for the "Lonely Yogs" event
- Alex, Rhettg32, and Bartez from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "Flu Season" event
- Alex from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the fix for traitors not being completely blinded in the "Blind Traitors" event
- Bartez from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "NO NERD HEALING", "Don't Let it Go to Your Head", and "Wasteful!" events
- CrimsonDude from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the name of the "Opposite Day" event
- Pardzival from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "Flip the Script" event 
- Angela from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "Ransomat" event
- Hyper from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "Olympic Sprint" event
- Lewis of the Yogscast for the idea for the "Detraitor" event and the concept of events starting in secret
- [Guardian954](https://steamcommunity.com/id/guardianreborn) for the initial "Communism! Time to learn how to share..." event
- [Mattyp92](https://steamcommunity.com/id/mattyp92) for converting Communism for use with "Custom Roles for TTT" instead of "Town of Terror", for the "I don't think you realise the gravity of the situation." event, for the "Ransomat" event, and for the idea for the "Betrayed" and "Clownin' Around" events
- [The Stig](https://steamcommunity.com/id/The-Stig-294) for the idea of adding a round time ConVar to the "Prop Hunt" event and for the idea (and code) for the "Fog of War" event
- [Freepik](https://www.flaticon.com/authors/freepik) for the "Cut" and "Stones" images used in the "Rock, Paper, Scissors" event
- [Pixel perfect](https://www.flaticon.com/authors/pixel-perfect) for the "Copy" image used in the "Rock, Paper, Scissors" event
- [Tygron](https://steamcommunity.com/id/Tygron), [The Stig](https://steamcommunity.com/id/The-Stig-294), and [TilSchwantje](https://github.com/TilSchwantje) for providing feedback and verifying bug fixes

# Steam Workshop
https://steamcommunity.com/sharedfiles/filedetails/?id=2055805086
