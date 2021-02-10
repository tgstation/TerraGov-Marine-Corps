/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB

/datum/keybinding/xeno/headbite
	name = "headbite"
	full_name = "Headbite"
	description = "Permanently kill a target."
	keybind_signal = COMSIG_XENOABILITY_HEADBITE

/datum/keybinding/xeno/regurgitate
	name = "regurgitate"
	full_name = "Regurgitate"
	description = "Vomit whatever you have devoured."
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE

/datum/keybinding/xeno/drop_weeds
	hotkey_keys = list("V")
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	keybind_signal = COMSIG_XENOABILITY_DROP_WEEDS

/datum/keybinding/xeno/choose_resin
	name = "choose_resin"
	full_name = "Choose Resin Structure"
	description = "Selects which structure you will build with the (secrete resin) ability."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_RESIN

/datum/keybinding/xeno/secrete_resin
	name = "secrete_resin"
	full_name = "Secrete Resin"
	description = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN

/datum/keybinding/xeno/secrete_resin_silo
	name = "secrete_resin_silo"
	full_name = "Secrete Resin Silo"
	description = "Builds a resin silo. Requires a number of dead bodies on a nest."
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN_SILO

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

/datum/keybinding/xeno/larval_growth_sting
	name = "larval_growth_sting"
	full_name = "Larval Growth Sting"
	description = "Inject an impregnated host with growth serum, causing the larva inside to grow quicker."
	keybind_signal = COMSIG_XENOABILITY_LARVAL_GROWTH_STING

/datum/keybinding/xeno/shift_spits
	name = "shift_spits"
	full_name = "Toggle Spit Type"
	description = "Switch from neurotoxin to acid spit."
	keybind_signal = COMSIG_XENOABILITY_SHIFT_SPITS

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

/datum/keybinding/xeno/retrieve_egg
	name = "retrieve_egg"
	full_name = "Carrier: Retrieve Egg"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RETRIEVE_EGG

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

/datum/keybinding/xeno/headbutt
	name = "headbutt"
	full_name = "Defender: Headbutt"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_HEADBUTT

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

/datum/keybinding/xeno/emit_neurogas
	name = "emit_neurogas"
	full_name = "Defiler: Emit Neurogas"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/keybinding/xeno/select_reagent
	name = "select_reagent"
	full_name = "Defiler: Select Reagent"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SELECT_REAGENT

/datum/keybinding/xeno/reagent_slash
	name = "reagent_slash"
	full_name = "Defiler: Reagent Slash"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_REAGENT_SLASH

/datum/keybinding/xeno/salvage_plasma
	name = "salvage_plasma"
	full_name = "Drone: Salvage Biomass"
	description = "Salvage plasma, upgrade and evolution points from the corpse of another xenomorph, gibbing it."
	keybind_signal = COMSIG_XENOABILITY_SALVAGE_PLASMA

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

/datum/keybinding/xeno/haunt
	name = "haunt"
	full_name = "Hunter: Haunt"
	description = "Haunt the target, causing minor hallucinations"
	keybind_signal = COMSIG_XENOABILITY_HAUNT

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

/datum/keybinding/xeno/psychic_heal
	name = "psychic_cure"
	full_name = "Shrike: Psychic Cure"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE

/datum/keybinding/xeno/screech
	name = "screech"
	full_name = "Queen: Screech"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SCREECH

/datum/keybinding/xeno/watch_xeno
	name = "watch_xeno"
	full_name = "Queen: Watch Xeno"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_WATCH_XENO

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

/datum/keybinding/xeno/queen_give_order
	name = "queen_give_order"
	full_name = "Queen: Give Order"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_ORDER

/datum/keybinding/xeno/deevolve
	name = "deevolve"
	full_name = "Queen: Devolve Xeno"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_DEEVOLVE

/datum/keybinding/xeno/queen_larval_growth
	name = "queen_larval_growth"
	full_name = "Queen: Larva Growth"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_LARVAL_GROWTH

/datum/keybinding/xeno/ravager_charge
	name = "ravager_charge"
	full_name = "Ravager: Eviscerating Charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

/datum/keybinding/xeno/ravager_ignore_pain
	name = "ravager_ignore_pain"
	full_name = "Ravager: Ignore Pain"
	description = "While active, you will not go into crit and can take increased damage before dying. You will still die when the effect ends."
	keybind_signal = COMSIG_XENOABILITY_IGNORE_PAIN

/datum/keybinding/xeno/ravage
	name = "ravage"
	full_name = "Ravager: Ravage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGE

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

/datum/keybinding/xeno/healing_infusion
	name = "healing_infusion"
	full_name = "Hivelord: Healing Infusion"
	description = "Imbues a target xeno with healing energy, restoring extra Sunder and Health once every 2 seconds up to 5 times whenever it regenerates normally. 60 second duration."
	keybind_signal = COMSIG_XENOABILITY_HEALING_INFUSION

