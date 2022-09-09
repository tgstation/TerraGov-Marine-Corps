/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB

/datum/keybinding/xeno/headbite
	name = "headbite"
	full_name = "Headbite / Psydrain"
	description = "Permanently kill a target. / Gather psy and larva points from a body."
	keybind_signal = COMSIG_XENOABILITY_HEADBITE

/datum/keybinding/xeno/regurgitate
	name = "regurgitate"
	full_name = "Regurgitate / Cocoon"
	description = "Vomit whatever you have devoured. / Cocoon the targeted body, which will produce psy and larva points over time."
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE

/datum/keybinding/xeno/blessingmenu
	name = "blessings menu"
	full_name = "Open Blessings Menu"
	description = "Opens the Queen Mothers Blessings menu, where hive upgrades are bought"
	keybind_signal = COMSIG_XENOABILITY_BLESSINGSMENU

/datum/keybinding/xeno/drop_weeds
	hotkey_keys = list("V")
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	keybind_signal = COMSIG_XENOABILITY_DROP_WEEDS

/datum/keybinding/xeno/choose_weeds
	hotkey_keys = list("Space")
	name = "choose_weeds"
	full_name = "Choose Weed"
	description = "Choose what weed you will drop."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_WEEDS

/datum/keybinding/xeno/secrete_resin
	name = "secrete_resin"
	full_name = "Secrete Resin"
	description = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN

/datum/keybinding/xeno/emit_recovery
	name = "emit_recovery"
	full_name = "Emit Recovery Pheromones"
	description = "Increases healing for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_RECOVERY

/datum/keybinding/xeno/emit_warding
	name = "emit_warding"
	full_name = "Emit Warding Pheromones"
	description = "Increases armor for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_WARDING

/datum/keybinding/xeno/emit_frenzy
	name = "emit_frenzy"
	full_name = "Emit Frenzy Pheromones"
	description = "Increases damage for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_FRENZY

/datum/keybinding/xeno/corrosive_acid
	name = "corrosive_acid"
	full_name = "Corrosive Acid"
	description = "Cover an object with acid to slowly melt it. Takes a few seconds."
	keybind_signal = COMSIG_XENOABILITY_CORROSIVE_ACID

/datum/keybinding/xeno/spray_acid
	name = "spray_acid"
	full_name = "Acid Spray"
	description = "Sprays some acid"
	keybind_signal = COMSIG_XENOABILITY_SPRAY_ACID

/datum/keybinding/xeno/xeno_spit
	name = "xeno_spit"
	full_name = "Spit"
	description = "Spit neurotoxin or acid at your target up to 7 tiles away."
	keybind_signal = COMSIG_XENOABILITY_XENO_SPIT

/datum/keybinding/xeno/xenohide
	name = "xenohide"
	full_name = "Hide"
	description = "Causes your sprite to hide behind certain objects and under tables. Not the same as stealth. Does not use plasma."
	keybind_signal = COMSIG_XENOABILITY_HIDE

/datum/keybinding/xeno/neurotox_sting
	name = "neurotox_sting"
	full_name = "Neurotoxin Sting"
	description = "A channeled melee attack that injects the target with neurotoxin over a few seconds, temporarily stunning them."
	keybind_signal = COMSIG_XENOABILITY_NEUROTOX_STING

/datum/keybinding/xeno/ozelomelyn_sting
	name = "ozelomelyn_sting"
	full_name = "Ozelomelyn Sting"
	description = "A channeled melee attack that injects the target with Ozelomelyn over a few seconds, purging chemicals and dealing minor toxin damage to a moderate cap while inside them."
	keybind_signal = COMSIG_XENOABILITY_OZELOMELYN_STING

/datum/keybinding/xeno/transfer_plasma
	name = "transfer_plasma"
	full_name = "Transfer Plasma"
	description = "Give some of your plasma to a teammate."
	keybind_signal = COMSIG_XENOABILITY_TRANSFER_PLASMA

/datum/keybinding/xeno/pounce
	name = "pounce"
	full_name = "Pounce"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_POUNCE

/datum/keybinding/xeno/nurogasnade
	name = "neurogas"
	full_name = "Sentinel: Neurogas Grenade"
	description = "Throws a gas emitting grenade at the targetted area"
	keybind_signal = COMSIG_XENOABILITY_NEUROGAS_GRENADE


/datum/keybinding/xeno/plow_charge
	name = "plow_charge"
	full_name = "Bull: Plow Charge"
	description = "A charge that plows through the victims."
	keybind_signal = COMSIG_XENOABILITY_BULLCHARGE

/datum/keybinding/xeno/headbutt_charge
	name = "headbutt_charge"
	full_name = "Bull: Headbutt Charge"
	description = "A charge that tosses the victim forward or backwards, depending on intent."
	keybind_signal = COMSIG_XENOABILITY_BULLHEADBUTT

/datum/keybinding/xeno/gore_charge
	name = "gore_charge"
	full_name = "Bull: Gore Charge"
	description = "A charge that gores the victim."
	keybind_signal = COMSIG_XENOABILITY_BULLGORE

/datum/keybinding/xeno/long_range_sight
	name = "long_range_sight"
	full_name = "Boiler: Long Range Sight"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT

/datum/keybinding/xeno/toggle_bomb
	name = "toggle_bomb"
	full_name = "Boiler: Toggle Bombard Type"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB

/datum/keybinding/xeno/toggle_bomb_radial
	name = "toggle_bomb_radial"
	full_name = "Boiler: Select Bombard Type (Radial)"
	description = "Will use the default toggle if you have two or less available glob types."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL

/datum/keybinding/xeno/create_bomb
	name = "create_bomb"
	full_name = "Boiler: Create Bombard Ammo"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREATE_BOMB

/datum/keybinding/xeno/bombard
	name = "bombard"
	full_name = "Boiler: Bombard"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_BOMBARD

/datum/keybinding/xeno/throw_hugger
	name = "throw_hugger"
	full_name = "Carrier: Throw Hugger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_THROW_HUGGER

/datum/keybinding/xeno/place_trap
	name = "place_trap"
	full_name = "Carrier: Place Trap"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PLACE_TRAP

/datum/keybinding/xeno/spawn_hugger
	name = "spawn_hugger"
	full_name = "Carrier: Spawn Hugger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SPAWN_HUGGER

/datum/keybinding/xeno/switch_hugger
	name = "switch_hugger"
	full_name = "Carrier: Switch Hugger"
	description = "Cycles the hugger type you will deploy with the Throw Hugger ability."
	keybind_signal = COMSIG_XENOABILITY_SWITCH_HUGGER

/datum/keybinding/xeno/choose_hugger
	name = "choose_hugger"
	full_name = "Carrier: Choose Hugger"
	description = "Prompt a wheel to choose which hugger you will deploy with the Throw Hugger ability."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_HUGGER

/datum/keybinding/xeno/drop_all_hugger
	name = "drop_all_hugger"
	full_name = "Carrier: Drop All Facehugger"
	description = "Drop all stored huggers in a fit of panic. Uses all remaining plasma!"
	keybind_signal = COMSIG_XENOABILITY_DROP_ALL_HUGGER

/datum/keybinding/xeno/stomp
	name = "stomp"
	full_name = "Crusher: Stomp"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_STOMP

/datum/keybinding/xeno/toggle_charge
	name = "toggle_charge"
	full_name = "Crusher: Toggle Charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_CHARGE

/datum/keybinding/xeno/cresttoss
	name = "cresttoss"
	full_name = "Crusher: Crest Toss"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CRESTTOSS

/datum/keybinding/xeno/advance
	name = "advance"
	full_name = "Crusher: Rapid Advance"
	description = "Charges up the crushers charge, then unleashes the full bulk of the crusher into a direction."
	keybind_signal = COMSIG_XENOABILITY_ADVANCE

/datum/keybinding/xeno/devour
	name = "devour"
	full_name = "Gorger: Devour"
	description = "Devour your victim to be able to carry it faster."
	keybind_signal = COMSIG_XENOABILITY_DEVOUR

/datum/keybinding/xeno/drain
	name = "drain"
	full_name = "Gorger: Drain"
	description = "Stagger a marine and drain some of their blood. When used on a dead human, you heal gradually and don't gain blood."
	keybind_signal = COMSIG_XENOABILITY_DRAIN

/datum/keybinding/xeno/transfusion
	name = "transfusion"
	full_name = "Gorger: Transfusion"
	description = "Restores some of the health of another xenomorph, or overheals, at the cost of blood."
	keybind_signal = COMSIG_XENOABILITY_TRANSFUSION

/datum/keybinding/xeno/rejuvenate
	name = "rejuvenate"
	full_name = "Gorger: Rejuvenate"
	description = "Drains blood continuosly, slows you down and reduces damage taken, while restoring some health over time. Cancel by activating again."
	keybind_signal = COMSIG_XENOABILITY_REJUVENATE

/datum/keybinding/xeno/psychic_link
	name = "psychic link"
	full_name = "Gorger: Psychic Link"
	description = "Link to a xenomorph and take some damage in their place. During this time, you can't move. Use rest action to cancel."
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_LINK

/datum/keybinding/xeno/carnage
	name = "carnage"
	full_name = "Gorger: Carnage"
	description = "For a while your attacks drain blood and heal you. During Feast you also heal nearby allies."
	keybind_signal = COMSIG_XENOABILITY_CARNAGE

/datum/keybinding/xeno/feast
	name = "feast"
	full_name = "Gorger: Feast"
	description = "Enter a state of rejuvenation. During this time you use a small amount of blood and heal. You can cancel this early."
	keybind_signal = COMSIG_XENOABILITY_FEAST

/datum/keybinding/xeno/forward_charge
	name = "forward charge"
	full_name = "Defender: Forward charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_FORWARD_CHARGE

/datum/keybinding/xeno/tail_sweep
	name = "tail_sweep"
	full_name = "Defender: Tail Sweep"
	description = "Hit all adjacent units around you, knocking them away and down."
	keybind_signal = COMSIG_XENOABILITY_TAIL_SWEEP

/datum/keybinding/xeno/crest_defense
	name = "crest_defense"
	full_name = "Defender: Crest Defense"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREST_DEFENSE

/datum/keybinding/xeno/fortify
	name = "fortify"
	full_name = "Defender: Fortify"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_FORTIFY

/datum/keybinding/xeno/regenerate_skin
	name = "regenerate_skin"
	full_name = "Defender: Regenerate Skin"
	description = "Regenerate your skin, restoring some health and removing all armor sunder."
	keybind_signal = COMSIG_XENOABILITY_REGENERATE_SKIN

/datum/keybinding/xeno/centrifugal_force
	name = "centrifugal_force"
	full_name = "Defender: Centrifugal Force"
	description = "Rapidly spin and hit all adjacent humans around you, knocking them away and down."
	keybind_signal = COMSIG_XENOABILITY_CENTRIFUGAL_FORCE

/datum/keybinding/xeno/emit_neurogas
	name = "emit_neurogas"
	full_name = "Defiler: Emit Neurogas"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/keybinding/xeno/select_reagent
	name = "select_reagent"
	full_name = "Defiler: Select Reagent"
	description = "Cycles through reagents to choose one for Defiler abilities."
	keybind_signal = COMSIG_XENOABILITY_SELECT_REAGENT

/datum/keybinding/xeno/radial_select_reagent
	name = "radial_select_reagent"
	full_name = "Defiler: Select Reagent (Radial)"
	description = "Chooses a reagent from a radial menu to use for Defiler abilities."
	keybind_signal = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT

/datum/keybinding/xeno/reagent_slash
	name = "reagent_slash"
	full_name = "Defiler: Reagent Slash"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_REAGENT_SLASH

/datum/keybinding/xeno/defile
	name = "defile"
	full_name = "Defiler: Defile"
	description = "Purges xeno toxins in exchange for dealing toxin damage and generating toxic sanguinal smoke."
	keybind_signal = COMSIG_XENOABILITY_DEFILE

/datum/keybinding/xeno/tentacle
	name = "tentacle"
	full_name = "Defiler: Tentacle"
	description = "Allows the defiler to grab a tallhost or item from range and bring it towards the defiler."
	keybind_signal = COMSIG_XENOABILITY_TENTACLE

/datum/keybinding/xeno/resin_walker
	name = "resin_walker"
	full_name = "Hivelord: Toggle Resin Walker"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RESIN_WALKER

/datum/keybinding/xeno/build_tunnel
	name = "build_tunnel"
	full_name = "Hivelord: Build Tunnel"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_BUILD_TUNNEL

/datum/keybinding/xeno/place_jelly_pod
	name = "place_jelly_pod"
	full_name = "Hivelord: Place Jelly Pod"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PLACE_JELLY_POD

/datum/keybinding/xeno/create_jelly
	name = "create_jelly"
	full_name = "Hivelord: Create Jelly"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREATE_JELLY

/datum/keybinding/xeno/toggle_stealth
	name = "toggle_stealth"
	full_name = "Hunter: Toggle Stealth"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH

/datum/keybinding/xeno/mirage
	name = "mirage"
	full_name = "Hunter: Mirage"
	description = "Creates multiple mirror images of the xeno."
	keybind_signal = COMSIG_XENOABILITY_MIRAGE

/datum/keybinding/xeno/psychic_whisper
	name = "psychic_whisper"
	full_name = "Psychic Whisper"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_WHISPER

/datum/keybinding/xeno/lay_egg
	name = "lay_egg"
	full_name = "Lay Egg"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_LAY_EGG

/datum/keybinding/xeno/call_of_the_burrowed
	name = "call_of_the_burrowed"
	full_name = "Call of the Burrowed"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED

/datum/keybinding/xeno/psychic_fling
	name = "psychic_fling"
	full_name = "Shrike: Psychic Fling"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_FLING

/datum/keybinding/xeno/unrelenting_force
	name = "unrelenting_force"
	full_name = "Shrike: Unrelenting Force"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_UNRELENTING_FORCE

/datum/keybinding/xeno/unrelenting_force_select
	name = "unrelenting_force_select"
	full_name = "Shrike: Select Unrelenting Force"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_UNRELENTING_FORCE_SELECT

/datum/keybinding/xeno/psychic_heal
	name = "psychic_cure"
	full_name = "Shrike: Psychic Cure"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE


/datum/keybinding/xeno/gravity_grenade
	name = "gravnade"
	full_name = "Shrike: Gravity Grenade"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_GRAV_NADE

/datum/keybinding/xeno/screech
	name = "screech"
	full_name = "Queen: Screech"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SCREECH

/datum/keybinding/xeno/toggle_queen_zoom
	name = "toggle_queen_zoom"
	full_name = "Queen: Toggle Zoom"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM

/datum/keybinding/xeno/xeno_leaders
	name = "xeno_leaders"
	full_name = "Queen: Set Leader"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_XENO_LEADERS

/datum/keybinding/xeno/queen_heal
	name = "queen_heal"
	full_name = "Queen: Give Heal"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HEAL

/datum/keybinding/xeno/queen_give_plasma
	name = "queen_give_plasma"
	full_name = "Queen: Give Plasma"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA

/datum/keybinding/xeno/queen_hive_message
	name = "queen_hive_message"
	full_name = "Queen: Hive Message"
	description = "Instantly displays a bolded announcement to all xenos in the hive."
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HIVE_MESSAGE

/datum/keybinding/xeno/deevolve
	name = "deevolve"
	full_name = "Queen: Devolve Xeno"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_DEEVOLVE

/datum/keybinding/xeno/ravager_charge
	name = "ravager_charge"
	full_name = "Ravager: Eviscerating Charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

/datum/keybinding/xeno/ravager_endure
	name = "ravager_endure"
	full_name = "Ravager: Endure"
	description = "For the next few moments you will not go into crit and become resistant to explosives and immune to stagger and slowdown, but you still die if you take damage exceeding your crit health."
	keybind_signal = COMSIG_XENOABILITY_ENDURE

/datum/keybinding/xeno/ravager_rage
	name = "ravager_rage"
	full_name = "Ravager: Rage"
	description = "While active, you will temporarily recover plasma and sunder and gain a bonus to speed and melee damage in proportion to the percentage of your missing health. At negative HP your ability cooldowns reset and your slash damage restores health."
	keybind_signal = COMSIG_XENOABILITY_RAGE

/datum/keybinding/xeno/ravager_vampirism
	name = "togglevampirism"
	full_name = "Ravager: Toggle vampirism"
	description = "While active, will increase the ravagers healing for a while for every time it hits a new enemy. Effects stack."
	keybind_signal = COMSIG_XENOABILITY_VAMPIRISM

/datum/keybinding/xeno/ravage
	name = "ravage"
	full_name = "Ravager: Ravage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGE

/datum/keybinding/xeno/ravage_select
	name = "ravage select"
	full_name = "Ravager: Select Ravage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGE_SELECT

/datum/keybinding/xeno/acid_dash
	name = "acid_dash"
	full_name = "Praetorian : Acid Dash"
	description = "Quickly dash, leaving acid in your path and knocking down the first marine hit. Has reset potential."
	keybind_signal = COMSIG_XENOABILITY_ACID_DASH

/datum/keybinding/xeno/toggle_savage
	name = "toggle_savage"
	full_name = "Runner: Toggle Savage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_SAVAGE

/datum/keybinding/xeno/evasion
	name = "evasion"
	full_name = "Runner: Evasion"
	description = "Take evasive action, forcing non-friendly projectiles that would hit you to miss so long as you keep moving."
	keybind_signal = COMSIG_XENOABILITY_EVASION

/datum/keybinding/xeno/snatch
	name = "snatch"
	full_name = "Runner: Snatch"
	description = "Take an item equipped by your target in your mouth, and carry it away."
	keybind_signal = COMSIG_XENOABILITY_SNATCH

/datum/keybinding/xeno/toggle_agility
	name = "toggle_agility"
	full_name = "Warrior: Toggle Agility"
	description = "Toggles Agility mode. While in Agility mode, you move much more quickly but can't use abilities and your armor is greatly reduced."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_AGILITY

/datum/keybinding/xeno/lunge
	name = "lunge"
	full_name = "Warrior: Lunge"
	description = "Charges towards a target, then neckgrabs them if they're adjacent to you. Stuns on upon grabbing for 1 second."
	keybind_signal = COMSIG_XENOABILITY_LUNGE

/datum/keybinding/xeno/fling
	name = "fling"
	full_name = "Warrior: Fling"
	description = "Quickly flings a target 4 tiles away and inflicts a short stun. Shared cooldown with Grapple Toss."
	keybind_signal = COMSIG_XENOABILITY_FLING

/datum/keybinding/xeno/grapple_toss
	name = "grapple_toss"
	full_name = "Warrior: Grapple Toss"
	description = "Throw a target you're grabbing up to 5 tiles away. Inflicts a short stun and stagger and slow stacks. Shared cooldown with Fling."
	keybind_signal = COMSIG_XENOABILITY_GRAPPLE_TOSS

/datum/keybinding/xeno/punch
	name = "punch"
	full_name = "Warrior: Punch"
	description = "Punch a hostile creature, a structure or piece of machinery. Damage and status durations are doubled vs creatures you are grabbing. Damage is quadrupled vs structures and machinery."
	keybind_signal = COMSIG_XENOABILITY_PUNCH

/datum/keybinding/xeno/jab
	name = "jab"
	full_name = "Warrior: Jab"
	description = "Precisely strike your target from further away, slowing and confusing them. Resets punch cooldown."
	keybind_signal = COMSIG_XENOABILITY_JAB

/datum/keybinding/xeno/inject_egg_neurogas
	name = "inject_egg_neurogas"
	full_name = "Inject Egg (Neurogas)"
	description = "Inject an egg with neurogas, killing the little one inside"
	keybind_signal = COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS

/datum/keybinding/xeno/rally_hive
	name = "rally_hive"
	full_name = "Rally Hive"
	description = "Rallies the hive to a target location."
	keybind_signal = COMSIG_XENOABILITY_RALLY_HIVE

/datum/keybinding/xeno/rally_minion
	name = "rally_minion"
	full_name = "Rally Minions"
	description = "Rallies the minions to a target location, or yourself."
	keybind_signal = COMSIG_XENOABILITY_RALLY_MINION

/datum/keybinding/xeno/command_minions
	name = "command_minion"
	full_name = "Command Minions"
	description = "Order the minions escorting you to be either agressive or passive."
	keybind_signal = COMSIG_XENOABILITY_MINION_BEHAVIOUR

/datum/keybinding/xeno/healing_infusion
	name = "healing_infusion"
	full_name = "Hivelord: Healing Infusion"
	description = "Imbues a target xeno with healing energy, restoring extra Sunder and Health once every 2 seconds up to 5 times whenever it regenerates normally. 60 second duration."
	keybind_signal = COMSIG_XENOABILITY_HEALING_INFUSION

/datum/keybinding/xeno/scatter_spit
	name = "scatter_spit"
	full_name = "Spitter: Scatter Spit"
	description = "Fires a scattershot of 6 acid globules which create acid puddles on impact or at the end of their range."
	keybind_signal = COMSIG_XENOABILITY_SCATTER_SPIT

/datum/keybinding/xeno/rewind
	name = "rewind"
	full_name = "Wraith: Time Shift"
	description = "Save the location and status of the target. When the time is up, the target location and status are restored"
	keybind_signal = COMSIG_XENOABILITY_REWIND

/datum/keybinding/xeno/portal
	name = "portal"
	full_name = "Wraith: Portal"
	description = "Place the first portal on your location. You can travel from portal one to portal two and vice versa."
	keybind_signal =COMSIG_XENOABILITY_PORTAL

/datum/keybinding/xeno/portal_two
	name = "portal_two"
	full_name = "Wraith: Portal two"
	description = "Place the second portal on your location. You can travel from portal one to portal two and vice versa."
	keybind_signal =COMSIG_XENOABILITY_PORTAL_ALTERNATE

/datum/keybinding/xeno/blink
	name = "wraith_blink"
	full_name = "Wraith: Blink"
	description = "Teleport to a space a short distance away within line of sight. Can teleport mobs you're dragging with you at the cost of higher cooldown."
	keybind_signal = COMSIG_XENOABILITY_BLINK

/datum/keybinding/xeno/banish
	name = "banish"
	full_name = "Wraith: Banish"
	description = "Banish a creature or object a short distance away within line of sight to null space. Can target oneself and allies. Can be manually cancelled with Recall."
	keybind_signal = COMSIG_XENOABILITY_BANISH

/datum/keybinding/xeno/recall
	name = "recall"
	full_name = "Wraith: Recall"
	description = "Recall a target from netherspace, ending Banish's effect."
	keybind_signal = COMSIG_XENOABILITY_RECALL

/datum/keybinding/xeno/timestop
	name = "timestop"
	full_name = "Wraith: Time stop"
	description = "Freezes bullets in their course, and they will start to move again only after a certain time"
	keybind_signal = COMSIG_XENOABILITY_TIMESTOP

/datum/keybinding/xeno/nightfall
	name = "nightfall"
	full_name = "King: Nightfall"
	description = "Shut down all nearby electric lights for 10 seconds"
	keybind_signal = COMSIG_XENOABILITY_NIGHTFALL

/datum/keybinding/xeno/gravity_crush
	name = "gravity_crush"
	full_name = "King: Gravity Crush"
	description = "Increases the localized gravity in an area and crushes everything in it."
	keybind_signal = COMSIG_XENOABILITY_GRAVITY_CRUSH

/datum/keybinding/xeno/psychic_summon
	name = "psychic_summon"
	full_name = "King: Psychic Summon"
	description = "Summons all xenos in a hive to the caller's location, uses all plasma to activate."
	keybind_signal = COMSIG_XENOABILITY_HIVE_SUMMON

/datum/keybinding/xeno/vent
	name = "vent"
	full_name = "Vent crawl"
	description = "Enter an air vent and crawl through the pipe system."
	keybind_signal = COMSIG_XENOABILITY_VENTCRAWL

/datum/keybinding/xeno/sow
	name = "sow"
	full_name = "Drone : Sow"
	description = "Plant the seeds of an alien plant."
	keybind_signal = COMSIG_XENOABILITY_DROP_PLANT

/datum/keybinding/xeno/sow_select_plant
	name = "choose_plant"
	full_name = "Drone : Choose plant"
	description = "Pick what type of plant to sow."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_PLANT

/datum/keybinding/xeno/vent/down(client/user)
	. = ..()
	if(!isxeno(user.mob))
		return
	var/mob/living/carbon/xenomorph/xeno = user.mob
	xeno.vent_crawl()
