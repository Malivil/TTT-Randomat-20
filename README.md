Thanks to [Dem](https://steamcommunity.com/profiles/76561198076733538) for the 'TTT Randomat 2.0' mod which this is an update to.\
Thanks to [Gamefreak](https://steamcommunity.com/id/realgamefreak) for the 'TTT Randomat' mod which THAT was an update to.
\
\
**Edits the original version to support Custom Roles for TTT and add additional events**

# New Events
- A Glitch has been patched
- Camp Fire
- Come on and SLAM!
- Communism! Time to learn how to share...
- Don't be so Sensitive
- Double Cross
- Flu Season
- Glitch in the Matrix
- NO NERD HEALING
- Prop Hunt
- Shh... It's a Secret!
- Social Distancing
- The Cake is a Lie
- Time Warp

# Events
## \#BringBackOldJester
Converts the Swapper to a Jester
\
\
**ConVars**
\
_randomat_oldjester_enabled_ - Default: 1 - Whether this event is enabled.

## A Glitch has been patched
Changes a random Glitch into either an Innocent or a Traitor. There is a configurable chance that the player will be turned into an Innocent rather than a Traitor.
\
\
**ConVars**
\
_randomat_patched_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_patched_chance_ - Default: 50 - The chance of the Glitch being made a Traitor.

## A player is acting suspicious
Changes a random player to either a Jester or a Traitor. There is a configurable chance that the player will be turned into a Jester rather than a Traitor.
\
\
**ConVars**
\
_randomat_suspicion_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_suspicion_chance_ - Default: 50 - The chance of the player being a Jester.

## A Random Person will explode every X seconds! Watch out! (EXCEPT DETECTIVES)
This one is pretty self-explanitory
\
\
**ConVars**
\
_randomat_explode_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_explode_timer_ - Default: 30 - The time between explosions.

## A traitor will explode in X seconds!
This one is pretty self-explanitory
\
\
**ConVars**
\
_randomat_texplode_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_texplode_timer_ - Default: 60 - The time before the traitor explodes.\
_randomat_texplode_radius_ - Default: 600 - Radius of the traitor explosion.

## An innocent has been upgraded!
A random vanilla innocent is upgraded to a Mercenary or is given the choice of becoming a Mercenary or a Killer
\
\
**ConVars**
\
_randomat_upgrade_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_upgrade_chooserole_ - Default: 1 - Whether the innocent should choose their new role.

## Bad Gas
Drops random enabled grenades are random players feet on a configurable interval
\
\
**ConVars**
\
_randomat_gas_enabled_ - Default: 1 - Whether this event is enabled.\
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
_randomat_ragdoll_enabled_ - Default: 1 - Whether this event is enabled.

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

## Come on and SLAM!
Gives everyone an M4 SLAM and only allows players to use the M4 SLAM for the duration of the event. Will not trigger if there is a Jester or a Swapper since they cannot win during this event.
\
\
**ConVars**
\
_randomat_slam_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_slam_timer_ - Default: 3 - Time between being given slams.\
_randomat_slam_strip_ - Default: 1 - The event strips your other weapons.\
_randomat_slam_weaponid_ - Default: weapon_ttt_slam - Id of the weapon given.

## Communism! Time to learn how to share...!
Whenever anyone buys a weapon from a shop, all other players get that weapon too. They must not have anything in that slot already.
\
\
**ConVars**
\
_randomat_communist_enabled_ - Default: 1 - Whether this event is enabled.\

## Crabs are People
Spawns a configurable number of hostile headcrabs when a player is killed
\
\
**ConVars**
\
_randomat_crabs_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_crabs_count_ - Default: 5 - The amount of crabs spawned when someone dies.

## Dead Men Tell no Tales
Prevents corpses from being searched
\
\
**ConVars**
\
_randomat_search_enabled_ - Default: 1 - Whether this event is enabled.

## Don't be so Sensitive
Periodically changes each player's mouse sensitivity to a number within the configurable range
\
\
**ConVars**
\
_randomat_sensitive_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_sensitive_change_interval_ - Default: 15 - How often to change each player's sensitivity.\
_randomat_sensitive_scale_min_ - Default: 25 - The minimum sensitivity to use.\
_randomat_sensitive_scale_max_ - Default: 500 - The maximum sensitivity to use.

## Don't. Blink.
Spawns a configurable number of Weeping Angels, each attached to a different player. The Weepiong Angel  will kill their assigned player when the player's back is turned
\
\
**ConVars**
\
_randomat_blink_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_blink_cap_ - Default: 12 - Maximum number of Weeping Angels spawned.\
_randomat_blink_delay_ - Default: 0.5 - Delay before Weeping Angels are spawned.

## Double Cross
Changes a random vanilla Innocent into either a Glitch or a Traitor. There is a configurable chance that the player will be turned into a Glitch rather than a Traitor.
\
\
**ConVars**
\
_randomat_doublecross_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_doublecross_chance_ - Default: 50 - The chance of the Innocent being made a Traitor.

## Everything is as fast as Flash now! (XX% faster)
Causes everything (movement, firing speed, timers, etc.) to run a configurable amount faster than normal
\
\
**ConVars**
\
_randomat_flash_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_flash_scale_ - Default: 50 - The percentage the speed should increase. Treated as an additive increase on multiple uses (e.g. 1.0 -> 1.5 -> 2.0 (1.5 + 0.5) rather than 1.0 -> 1.5 -> 2.25 (1.5 + 1.5x0.5)

## Flu Season
Randomly infects a player with the flu, causing them to sneeze occasionally. Also has a chance to spread to other players within a configurable distance
\
\
**ConVars**
\
_randomat_flu_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_flu_timer_ - Default: 1 - Time a player must be near someone before it spreads.\
_randomat_flu_interval_ - Default: 10 - How often effects happen to infected.\
_randomat_flu_distance_ - Default: 100 - Distance a player must be from another to be considered "near".\
_randomat_flu_chance_ - Default: 25 - Spreading chance.\
_randomat_flu_speed_factor_ - Default: 0.8 - What speed the infected player should be reduced to.

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
_randomat_freeze_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_freeze_duration_ - Default: 5 - Duration of the Freeze (in seconds).\
_randomat_freeze_timer_ - Default: 30 - How often (in seconds) the Freeze occurs.\
_randomat_freeze_hint_ - Default: 1 - Whether to explain the event after triggering.

## Gaining life for killing people? Is it really worth it...
Heals players who kill other players
\
\
**ConVars**
\
_randomat_lifesteal_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_lifesteal_health_ - Default: 25 - The health gained per kill.\
_randomat_lifesteal_cap_ - Default: 0 - The maximum health a player can get from killing people. Set to 0 to disable.

## Get Down Mr President!
Gives all Detectives extra health, but kills all members of the Innocent team if they get killed
\
\
**ConVars**
\
_randomat_president_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_president_bonushealth_ - Default: 100 - Extra health gained by the detective.

## Glitch in the Matrix
Randomly changes everyone's role to be either Glitch or Traitor based on the configurable values
\
\
**ConVars**
\
_randomat_glitch_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_glitch_blocklist_ - Default: - The comma-separated list of weapon IDs to not give out. For example: "ttt_m9k_harpoon,weapon_ttt_slam".\
_randomat_glitch_traitor_pct_ - Default: 25 - The percentage of players that will be traitors.\
_randomat_glitch_damage_scale_ - Default: 1.0 - The multiplier for damage that the Glitches will take.\
_randomat_glitch_max_glitches_ - Default: 0 - The maximum number of Glitches this event will create. Setting to 0 will not limit the number of Glitches.\
_randomat_glitch_starting_health_ - Default: 100 - The amount of health the Glitches should start with.

## Gun Game
Periodically gives players random weapons that would normally be found throughout the map
\
\
**ConVars**
\
_randomat_gungame_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_gungame_timer_ - Default: 5 - Time between weapon changes.

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

## Harpooooooooooooooooooooon!!
Gives everyone a Harpoon and only allows players to use the Harpoon for the duration of the event.
\
\
**ConVars**
\
_randomat_harpoon_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_harpoon_timer_ - Default: 3 - Time between being given harpoons.\
_randomat_harpoon_strip_ - Default: 1 - The event strips your other weapons.\
_randomat_harpoon_weaponid_ - Default: ttt_m9k_harpoon - Id of the weapon given.

## Honey, I shrunk the terrorists
Scales each player's size by a configurable ratio
\
\
**ConVars**
\
_randomat_shrink_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_shrink_scale_ - Default: 0.5 - The shrinking scale factor.

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

## I see dead people
Drops a Visualizer whenever a player is killed
\
\
**ConVars**
\
_randomat_visualiser_enabled_ - Default: 1 - Whether this event is enabled.

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
_randomat_credits_enabled_ - Default: 1 - Whether this event is enabled.

## Malfunction
Causes players to randomly shoot their gun
\
\
**ConVars**
\
_randomat_malfunction_enabled_ - Default: 1 - Whether this event is enabled.\
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
_randomat_falldamage_enabled_ - Default: 1 - Whether this event is enabled.

## NO NERD HEALING
Prevents any player from regaining lost health
\
\
**ConVars**
\
_randomat_noheal_enabled_ - Default: 1 - Whether this event is enabled.

## No one can hide from my sight
Puts a green outline around every player
\
\
**ConVars**
\
_randomat_wallhack_enabled_ - Default: 1 - Whether this event is enabled.

## NOT THE BEES!
Spawns bees randomly around around players
\
\
**ConVars**
\
_randomat_bees_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_bees_count_ - Default: 4 - The number of bees spawned per player.

## One traitor, One Detective. Everyone else is a Jester. Detective is stronger.
This one is pretty self-explanitory except for the "Detective is stronger" part. That just means the detective has 200 health.
\
\
**ConVars**
\
_randomat_jesters_enabled_ - Default: 1 - Whether this event is enabled.

**Prop Hunt**
Converts all Jester/Swapper and innocent team members to the Innocent role, strip their weapons, and gives them a Prop Disguiser. Converts all monster and traitor team members to the Traitor role.
\
\
**ConVars**
\
_randomat_prophunt_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_prophunt_timer_ - Default: 3 - Time between being given prop disguisers.\
_randomat_prophunt_strip_ - Default: 1 - The event strips your other weapons.\
_randomat_prophunt_weaponid_ - Default: weapon_ttt_prophide - Id of the weapon given.

## Random Health for everyone!
Gives everyone a random amount of health within the configurable boundaries
\
\
**ConVars**
\
_randomat_randomhealth_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_randomhealth_upper_ - Default: 100 - The upper limit of health gained.\
_randomat_randomhealth_lower_ - Default: 0 - The lower limit of health gained.

## Random xN
Triggers a configurable number of random events, one every 5 seconds
\
\
**ConVars**
\
_randomat_randomxn_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_randomxn_triggers_ - Default: 5 - Number of Randomat events activated.

## Randomness Intensifies
Periodically triggers random Randomat events for the duration of this event
\
\
**ConVars**
\
_randomat_intensifies_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_intensifies_timer_ - Default: 20 - How often (in seconds) a random event will be triggered

## RISE FROM YOUR GRAVE
Causes anyone who dies to be resurrected as a Zombie
\
\
**ConVars**
\
_randomat_grave_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_grave_health_ - Default: 30 - The health that the Zombies respawn with.

## Shh... It's a Secret!
Runs another random Randomat event without notifying the players. Also silences all future Randomat events while this event is active.
\
\
**ConVars**
\
_randomat_secret_enabled_ - Default: 1 - Whether this event is enabled.

## SHUT UP!
Disables all sounds for the duration of the event
\
\
**ConVars**
\
_randomat_shutup_enabled_ - Default: 1 - Whether this event is enabled.

## So that's it. What, we some kind of suicide squad? (aka Detonators)
Gives everyone a detonator for a random other player. When that detonator is used, the target player is exploded.
\
\
**ConVars**
\
_randomat_suicide_enabled_ - Default: 1 - Whether this event is enabled.

## Social Distancing
Does a small amount of damage over time to players who spend too much time close to eachother.
\
\
**ConVars**
\
_randomat_distancing_enabled_ - Default: 1 - Whether this event is enabled.\
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
_randomat_sosig_enabled_ - Default: 1 - Whether this event is enabled.

## Soulmates
Pairs random players together. When either of the paired players is killed, the other is automatically killed as well
\
\
**ConVars**
\
_randomat_soulmates_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_soulmates_affectall_ - Default: 0 - Whether everyone should have a soulmate.

## Sudden Death!
Changes everyone to have only 1 health
\
\
**ConVars**
\
_randomat_suddendeath_enabled_ - Default: 1 - Whether this event is enabled.

## Taking Inventory
Swaps player inventories periodically throughout the round. There are some caveats to how this event interacts with special roles:
- Non-prime Zombies are excluded
- Prime Zombies will keep their claws
- Players who received a Killer's inventory will be given a crowbar instead of the Killer's knife

**ConVars**
\
_randomat_inventory_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_inventory_timer_ - Default: 15 - Time between inventory swaps.

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

## There's this game my father taught me years ago, it's called "Switch"
Randomly switches positions of two players on a configurable interval
\
\
**ConVars**
\
_randomat_switch_enabled_ - Default: 1 -  Whether this event is enabled.\
_randomat_switch_timer_ - Default: 15 - How often players are switched.

## Time Warp
Causes everything (movement, firing speed, timers, etc.) to run a configurable amount faster than normal and intensifies on a configurable interval
\
\
**ConVars**
\
_randomat_timewarp_enabled_ - Default: 1 - Whether this event is enabled.\
_randomat_timewarp_scale_ - Default: 50 - The percentage the speed should increase. Treated as an additive increase on multiple uses (e.g. 1.0 -> 1.5 -> 2.0 (1.5 + 0.5) rather than 1.0 -> 1.5 -> 2.25 (1.5 + 1.5x0.5).\
_randomat_timewarp_scale_max_ - Default: 8 - The maximum scale the speed should increase to.\
_randomat_timewarp_timer_ - Default: 15 - How often (in seconds) the speed will be increased.

## Total Mayhem
Causes players to explode when killed
\
\
**ConVars**
\
_randomat_mayhem_enabled_ - Default: 1 -  Whether this event is enabled.

## Try your best...
Gives each player a random pistol and main weapon that they cannot drop
\
\
**ConVars**
\
_randomat_randomweapon_enabled_ - Default: 1 -  Whether this event is enabled.

## Quake Pro
Increases each player's Field of View (FOV) so it looks like you're playing Quake
\
\
**ConVars**
\
_randomat_fov_enabled_ - Default: 1 -  Whether this event is enabled.\
_randomat_fov_scale_ - Default: 1.5 - Scale of the FOV increase.

## We learned how to heal over time, its hard, but definitely possible... (aka Regeneration)
Causes players to slowly regenerate lost health over time
\
\
**ConVars**
\
_randomat_regeneration_enabled_ - Default: 1 -  Whether this event is enabled.\
_randomat_regeneration_delay_ - Default: 10 - How long after taking damage you will start to regen health.\
_randomat_regeneration_health_ - Default: 1 - How much health per second you heal.

## We've updated our privacy policy.
Alerts all players when an item is bought from a shop
\
\
**ConVars**
\
_randomat_privacy_enabled_ - Default: 1 -  Whether this event is enabled.

## What? Moon Gravity on Earth?
Changes the gravity of each player to the configurable scale
\
\
**ConVars**
\
_randomat_moongravity_enabled_ - Default: 1 -  Whether this event is enabled.\
_randomat_moongravity_gravity_ - Default: 0.1 - The gravity scale.

## What did I find in my pocket?
Gives each player a random buyable weapon
\
\
**ConVars**
\
_randomat_pocket_enabled_ - Default: 1 -  Whether this event is enabled.\
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
_randomat_murder_enabled_ - Default: 1 -  Whether this event is enabled.\
_randomat_murder_pickups_pct_ - Default: 1.5 - Ratio of weapons required to get a revolver. Value = (ConVarValue x TotalWeapons)/Players.\
_randomat_murder_knifespeed_ - Default: 1.2 - Player move speed multiplier whilst knife is held.\
_randomat_murder_knifedmg_ - Default: 50 - Damage of the traitor's knife.\
_randomat_murder_highlight_gun_ - Default: 1 - Whether to highlight dropped revolvers.

## You can only jump once.
Kills any player who jumps a second time after this event has triggered
\
\
**ConVars**
\
_randomat_jump_enabled_ - Default: 1 -  Whether this event is enabled.

# ULX Support
This version of the Randomat 2.0 should be compatible with all versions of the ULX Module for Randomat 2.0
That being said, I have created my [own version of the ULX Module](https://steamcommunity.com/sharedfiles/filedetails/?id=2096758509) which supports these new events as well as dynamic event loading with little-to-no developer interaction

# Special Thanks
- [Dem](https://steamcommunity.com/profiles/76561198076733538) for the 'TTT Randomat 2.0' mod which this is an update to.
- [Gamefreak](https://steamcommunity.com/id/realgamefreak) for the 'TTT Randomat' mod which THAT was an update to.
- Alex from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the fix for traitors not being completely blinded.
- [Grodbert](https://steamcommunity.com/id/Grodbert) for the [SCP-871](https://steamcommunity.com/sharedfiles/filedetails/?id=1992626478) model which is used in the 'The Cake is a Lie' event
- u/LegateLaurie on Reddit for the idea for the "Shh... It's a Secret!" event
- u/Shark_Shooter on Reddit for the idea for the "Come on and SLAM!" event
- u/zoxzix89 on Reddit for the idea for the "Time Warp" event
- u/Mad_Hatt3r on Reddit for the idea for the "Don't be so Sensitive" event
- u/ttimo123456 on Reddit for the idea for the "Prop Hunt" event
- u/alt----f4 on Reddit for the idea for the "A Glitch has been patched" event
- u/dinnaehuv1 on Reddit for the idea for the "Double Cross" event
- u/Grizzledude8 on Reddit for the idea for the "Social Distancing" event
- Alex, Rhettg32, and Bartez from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "Flu Season" event
- Bartez from the [Lonely Yogs](https://lonely-yogs.co.uk/) Discord for the idea for the "NO NERD HEALING" event
- [Guardian954](https://steamcommunity.com/id/guardianreborn) for the initial "Communism! Time to learn how to share..." event and
 [Mattyp92](https://steamcommunity.com/id/mattyp92) for converting it for use with "Custom Roles for TTT" instead of "Town of Terror"
- Tygron for providing feedback and verifying bug fixes
