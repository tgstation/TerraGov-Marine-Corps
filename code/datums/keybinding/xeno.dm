/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB

/datum/keybinding/xeno/New()
	. = ..()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

/datum/keybinding/xeno/down(client/user)
	if(SEND_SIGNAL(user.mob, keybind_signal) & COMSIG_KB_ACTIVATED)
		return TRUE

	return FALSE

/datum/keybinding/xeno/regurgitate
	key = "Unbound"
	name = "regurgitate"
	full_name = "Regurgitate"
	description = "Vomit whatever you have devoured."
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE

/datum/keybinding/xeno/drop_weeds
	key = "V"
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	keybind_signal = COMSIG_XENOABILITY_DROP_WEEDS

/datum/keybinding/xeno/choose_resin
	key = "Unbound"
	name = "choose_resin"
	full_name = "Choose Resin Structure"
	description = "Selects which structure you will build with the (secrete resin) ability."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_RESIN

/datum/keybinding/xeno/secrete_resin
	key = "Unbound"
	name = "secrete_resin"
	full_name = "Secrete Resin"
	description = "Builds whatever you’ve selected with (choose resin structure) on your tile."
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN

/datum/keybinding/xeno/emit_recovery
	key = "Unbound"
	name = "emit_recovery"
	full_name = "Emit Recovery Pheromones"
	description = "Increases healing for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_RECOVERY

/datum/keybinding/xeno/emit_warding
	key = "Unbound"
	name = "emit_warding"
	full_name = "Emit Warding Pheromones"
	description = "Increases armor for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_WARDING

/datum/keybinding/xeno/emit_frenzy
	key = "Unbound"
	name = "emit_frenzy"
	full_name = "Emit Frenzy Pheromones"
	description = "Increases damage for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_FRENZY

/datum/keybinding/xeno/transfer_plasma
	key = "Unbound"
	name = "transfer_plasma"
	full_name = "Drone: Transfer Plasma"
	description = "Give some of your plasma to a teammate."
	keybind_signal = COMSIG_XENOABILITY_TRANSFER_PLASMA

/datum/keybinding/xeno/larval_growth_sting
	key = "Unbound"
	name = "larval_growth_sting"
	full_name = "Xeno: Larval Growth Sting"
	description = "Inject an impregnated host with growth serum, causing the larva inside to grow quicker."
	keybind_signal = COMSIG_XENOABILITY_LARVAL_GROWTH_STING

/datum/keybinding/xeno/shift_spits
	key = "Unbound"
	name = "shift_spits"
	full_name = "Xeno: Toggle Spit Type"
	description = "Switch from neurotoxin to acid spit."
	keybind_signal = COMSIG_XENOABILITY_SHIFT_SPITS

/datum/keybinding/xeno/corrosive_acid
	key = "Unbound"
	name = "corrosive_acid"
	full_name = "Xeno: Corrosive Acid"
	description = "Cover an object with acid to slowly melt it. Takes a few seconds."
	keybind_signal = COMSIG_XENOABILITY_CORROSIVE_ACID

/datum/keybinding/xeno/spray_acid
	key = "Unbound"
	name = "spray_acid"
	full_name = "Xeon: Acid spary"
	description = "Sprays some acid"
	keybind_signal = COMSIG_XENOABILITY_SPRAY_ACID

/datum/keybinding/xeno/xeno_spit
	key = "Unbound"
	name = "xeno_spit"
	full_name = "Xeno: Spit"
	description = "Spit neurotoxin or acid at your target up to 7 tiles away."
	keybind_signal = COMSIG_XENOABILITY_XENO_SPIT

/datum/keybinding/xeno/xenohide
	key = "Unbound"
	name = "xenohide"
	full_name = "Xeno: Hide"
	description = "Causes your sprite to hide behind certain objects and under tables. Not the same as stealth. Does not use plasma."
	keybind_signal = COMSIG_XENOABILITY_HIDE

/datum/keybinding/xeno/neurotox_sting
	key = "Unbound"
	name = "neurotox_sting"
	full_name = "Xeno: Neurotoxin Sting"
	description = "A channeled melee attack that injects the target with neurotoxin over a few seconds, temporarily stunning them."
	keybind_signal = COMSIG_XENOABILITY_NEUROTOX_STING
	
/datum/keybinding/xeno/long_range_sight
	key = "Unbound"
	name = "long_range_sight"
	full_name = "Boiler: Long Range Sight"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT

/datum/keybinding/xeno/toggle_bomb
	key = "Unbound"
	name = "toggle_bomb"
	full_name = "Boiler: Toggle Bombard Type"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB

/datum/keybinding/xeno/bombard
	key = "Unbound"
	name = "bombard"
	full_name = "Boiler: Bombard"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_BOMBARD

/datum/keybinding/xeno/throw_hugger
	key = "Unbound"
	name = "throw_hugger"
	full_name = "Carrier: Throw Hugger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_THROW_HUGGER

/datum/keybinding/xeno/retrieve_egg
	key = "Unbound"
	name = "retrieve_egg"
	full_name = "Carrier: Retrieve Egg"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RETRIEVE_EGG

/datum/keybinding/xeno/place_trap
	key = "Unbound"
	name = "place_trap"
	full_name = "Carrier: Place Trap"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PLACE_TRAP

/datum/keybinding/xeno/spawn_hugger
	key = "Unbound"
	name = "spawn_hugger"
	full_name = "Carrier: Spawn Hugger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SPAWN_HUGGER

/datum/keybinding/xeno/stomp
	key = "Unbound"
	name = "stomp"
	full_name = "Crusher: Stomp"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_STOMP

/datum/keybinding/xeno/toggle_charge
	key = "Unbound"
	name = "toggle_charge"
	full_name = "Crusher: Toggle Charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_CHARGE

/datum/keybinding/xeno/cresttoss
	key = "Unbound"
	name = "cresttoss"
	full_name = "Crusher: Crest Toss"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CRESTTOSS

/datum/keybinding/xeno/headbutt
	key = "Unbound"
	name = "headbutt"
	full_name = "Defender: Headbutt"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_HEADBUTT

/datum/keybinding/xeno/tail_sweep
	key = "Unbound"
	name = "tail_sweep"
	full_name = "Defender: Tail Sweep"
	description = "Hit all adjacent units around you, knocking them away and down."
	keybind_signal = COMSIG_XENOABILITY_TAIL_SWEEP

/datum/keybinding/xeno/crest_defense
	key = "Unbound"
	name = "crest_defense"
	full_name = "Defender: Crest Defense"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREST_DEFENSE

/datum/keybinding/xeno/fortify
	key = "Unbound"
	name = "fortify"
	full_name = "Defender: Fortify"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_FORTIFY

/datum/keybinding/xeno/neuroclaws
	key = "Unbound"
	name = "neuroclaws"
	full_name = "Defiler: Toggle Neuroclaws"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_NEUROCLAWS

/datum/keybinding/xeno/emit_neurogas
	key = "Unbound"
	name = "emit_neurogas"
	full_name = "Defiler: Emit Neurogas"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/keybinding/xeno/salvage_plasma
	key = "Unbound"
	name = "salvage_plasma"
	full_name = "Drone: Salvage Plasma"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SALVAGE_PLASMA

/datum/keybinding/xeno/resin_walker
	key = "Unbound"
	name = "resin_walker"
	full_name = "Hivelord: Toggle Resin Walker"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RESIN_WALKER

/datum/keybinding/xeno/build_tunnel
	key = "Unbound"
	name = "build_tunnel"
	full_name = "Hivelord: Build Tunnel"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_BUILD_TUNNEL

/datum/keybinding/xeno/toggle_stealth
	key = "Unbound"
	name = "toggle_stealth"
	full_name = "Hunter: Toggle Stealth"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH

/datum/keybinding/xeno/screech
	key = "Unbound"
	name = "screech"
	full_name = "Queen: Screech"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SCREECH

/datum/keybinding/xeno/grow_ovipositor
	key = "Unbound"
	name = "grow_ovipositor"
	full_name = "Queen: Grow Ovipositor"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_GROW_OVIPOSITOR

/datum/keybinding/xeno/remove_eggsac
	key = "Unbound"
	name = "remove_eggsac"
	full_name = "Queen: Remove eggsac"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_REMOVE_EGGSAC

/datum/keybinding/xeno/watch_xeno
	key = "Unbound"
	name = "watch_xeno"
	full_name = "Queen: Watch xeno"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_WATCH_XENO

/datum/keybinding/xeno/psychic_whisper
	key = "Unbound"
	name = "psychic_whisper"
	full_name = "Queen: Psychic Whisper"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_WHISPER

/datum/keybinding/xeno/lay_egg
	key = "Unbound"
	name = "lay_egg"
	full_name = "Lay Egg"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_LAY_EGG

/datum/keybinding/xeno/call_of_the_burrowed
	key = "Unbound"
	name = "call_of_the_burrowed"
	full_name = "Call of the Burrowed"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED

/datum/keybinding/xeno/psychic_fling
	key = "Unbound"
	name = "psychic_fling"
	full_name = "Psychic Fling"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_FLING

/datum/keybinding/xeno/psychic_choke
	key = "Unbound"
	name = "psychic_choke"
	full_name = "Psychic Choke"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CHOKE

/datum/keybinding/xeno/psychic_heal
	key = "Unbound"
	name = "psychic_cure"
	full_name = "Psychic Cure"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE

/datum/keybinding/xeno/toggle_queen_zoom
	key = "Unbound"
	name = "toggle_queen_zoom"
	full_name = "Queen: Toggle Zoom"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM

/datum/keybinding/xeno/xeno_leaders
	key = "Unbound"
	name = "xeno_leaders"
	full_name = "Queen: Set leader"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_XENO_LEADERS

/datum/keybinding/xeno/queen_heal
	key = "Unbound"
	name = "queen_heal"
	full_name = "Queen: Give heal"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HEAL

/datum/keybinding/xeno/queen_give_plasma
	key = "Unbound"
	name = "queen_give_plasma"
	full_name = "Queen: Give plasma"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA

/datum/keybinding/xeno/queen_give_order
	key = "Unbound"
	name = "queen_give_order"
	full_name = "Queen: Give order"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_ORDER

/datum/keybinding/xeno/deevolve
	key = "Unbound"
	name = "deevolve"
	full_name = "Queen: Devolve xeno"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_DEEVOLVE

/datum/keybinding/xeno/queen_larval_growth
	key = "Unbound"
	name = "queen_larval_growth"
	full_name = "Queen: Larva Growth"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_LARVAL_GROWTH

/datum/keybinding/xeno/ravager_charge
	key = "Unbound"
	name = "ravager_charge"
	full_name = "Ravager: Charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

/datum/keybinding/xeno/ravage
	key = "Unbound"
	name = "ravage"
	full_name = "Ravager: Ravage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGE

/datum/keybinding/xeno/second_wind
	key = "Unbound"
	name = "second_wind"
	full_name = "Ravager: Second Wind"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SECOND_WIND

/datum/keybinding/xeno/toggle_savage
	key = "Unbound"
	name = "toggle_savage"
	full_name = "Ravager: Toggle Savage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_SAVAGE

/datum/keybinding/xeno/pounce
	key = "Unbound"
	name = "pounce"
	full_name = "Runner: Pounce"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_POUNCE

/datum/keybinding/xeno/toggle_agility
	key = "Unbound"
	name = "toggle_agility"
	full_name = "Warrior: Toggle Agility"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_AGILITY

/datum/keybinding/xeno/lunge
	key = "Unbound"
	name = "lunge"
	full_name = "Warrior: Lunge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_LUNGE

/datum/keybinding/xeno/fling
	key = "Unbound"
	name = "toggle_fling"
	full_name = "Warrior: Toggle Fling"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_FLING

/datum/keybinding/xeno/punch
	key = "Unbound"
	name = "punch"
	full_name = "Warrior: Punch"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PUNCH

