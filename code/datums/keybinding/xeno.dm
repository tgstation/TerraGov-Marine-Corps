/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB

//
// Universal or multi-caste
//

/datum/keybinding/xeno/headbite
	name = "headbite"
	full_name = "Headbite / Psydrain"
	description = "Permanently kill a target. / Gather psy and larva points from a body."
	keybind_signal = COMSIG_XENOABILITY_HEADBITE
	hotkey_keys = list("J")

/datum/keybinding/xeno/regurgitate
	name = "regurgitate"
	full_name = "Regurgitate / Cocoon"
	description = "Vomit whatever you have devoured. / Cocoon the targeted body, which will produce psy and larva points over time."
	keybind_signal = COMSIG_XENOABILITY_REGURGITATE
	hotkey_keys = list("K")

/datum/keybinding/xeno/blessingmenu
	name = "blessings menu"
	full_name = "Open Blessings Menu"
	description = "Opens the Queen Mothers Blessings menu, where hive upgrades are bought"
	keybind_signal = COMSIG_XENOABILITY_BLESSINGSMENU
	hotkey_keys = list("P")

/datum/keybinding/xeno/drop_weeds
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	keybind_signal = COMSIG_XENOABILITY_DROP_WEEDS
	hotkey_keys = list("V")

/datum/keybinding/xeno/place_pattern
	name = "place_pattern"
	full_name = "Place Pattern"
	description = "Place a template of hive walls."
	keybind_signal = COMSIG_XENOABILITY_PLACE_PATTERN
	hotkey_keys = list("E")

/datum/keybinding/xeno/select_pattern
	name = "select_pattern"
	full_name = "Select Pattern"
	description = "Select the template to use when using Place Pattern"
	keybind_signal = COMSIG_XENOABILITY_SELECT_PATTERN
	hotkey_keys = list("Q")

/datum/keybinding/xeno/choose_weeds
	name = "choose_weeds"
	full_name = "Choose Weed"
	description = "Choose what weed you will drop."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_WEEDS

/datum/keybinding/xeno/secrete_resin
	name = "secrete_resin"
	full_name = "Secrete Resin"
	description = "Builds whatever you've selected with (choose resin structure) on your tile."
	keybind_signal = COMSIG_XENOABILITY_SECRETE_RESIN
	hotkey_keys = list("R")

/datum/keybinding/xeno/secrete_special_resin
	name = "secrete_special_resin"
	full_name = "Secrete Special Resin"
	description = "Builds whatever special resin you have selected."
	keybind_signal = COMSIG_XENOABILITY_SECRETE_SPECIAL_RESIN
	hotkey_keys = list("ShiftR")

/datum/keybinding/xeno/recycle
	name = "Recycle"
	full_name = "Recycle xenomorph"
	description = "Recycles a fellow dead xenomorph"
	keybind_signal = COMSIG_XENOABILITY_RECYCLE
	hotkey_keys = list("ShiftE")

/datum/keybinding/xeno/place_acid_well
	name = "place_acid_well"
	full_name = "Place acid well"
	description = "Builds acid well on your tile."
	keybind_signal = COMSIG_XENOABILITY_PLACE_ACID_WELL
	hotkey_keys = list("G")

/datum/keybinding/xeno/emit_frenzy
	name = "emit_frenzy"
	full_name = "Emit Frenzy Pheromones"
	description = "Increases damage for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_FRENZY
	hotkey_keys = list("7")

/datum/keybinding/xeno/emit_warding
	name = "emit_warding"
	full_name = "Emit Warding Pheromones"
	description = "Increases armor for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_WARDING
	hotkey_keys = list("8")

/datum/keybinding/xeno/emit_recovery
	name = "emit_recovery"
	full_name = "Emit Recovery Pheromones"
	description = "Increases healing for yourself and nearby teammates."
	keybind_signal = COMSIG_XENOABILITY_EMIT_RECOVERY
	hotkey_keys = list("9")

/datum/keybinding/xeno/corrosive_acid
	name = "corrosive_acid"
	full_name = "Corrosive Acid"
	description = "Cover an object with acid to slowly melt it. Takes a few seconds."
	keybind_signal = COMSIG_XENOABILITY_CORROSIVE_ACID
	hotkey_keys = list("X")

/datum/keybinding/xeno/spray_acid
	name = "spray_acid"
	full_name = "Acid Spray"
	description = "Sprays some acid"
	keybind_signal = COMSIG_XENOABILITY_SPRAY_ACID
	hotkey_keys = list("F")

/datum/keybinding/xeno/xeno_spit
	name = "xeno_spit"
	full_name = "Spit"
	description = "Spit neurotoxin or acid at your target up to 7 tiles away."
	keybind_signal = COMSIG_XENOABILITY_XENO_SPIT
	hotkey_keys = list("Q")

/datum/keybinding/xeno/long_range_sight
	name = "long_range_sight"
	full_name = "Long Range Sight"
	description = "Toggles the zoom in."
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT
	hotkey_keys = list("E")

/datum/keybinding/xeno/xenohide
	name = "xenohide"
	full_name = "Hide"
	description = "Causes your sprite to hide behind certain objects and under tables. Not the same as stealth. Does not use plasma."
	keybind_signal = COMSIG_XENOABILITY_HIDE
	hotkey_keys = list("C")

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
	hotkey_keys = list("ShiftE")

/datum/keybinding/xeno/transfer_plasma
	name = "transfer_plasma"
	full_name = "Transfer Plasma"
	description = "Give some of your plasma to a teammate."
	keybind_signal = COMSIG_XENOABILITY_TRANSFER_PLASMA
	hotkey_keys = list("N")

/datum/keybinding/xeno/toggle_charge
	name = "toggle_charge"
	full_name = "Toggle Charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_CHARGE
	hotkey_keys = list("Space")

/datum/keybinding/xeno/toxic_spit
	name = "toxic_spit"
	full_name = "Sentinel: Toxic Spit"
	description = "A type of spit that inflicts the Intoxicated debuff, dealing damage over time."
	keybind_signal = COMSIG_XENOABILITY_TOXIC_SPIT
	hotkey_keys = list("E")

/datum/keybinding/xeno/vent
	name = "vent"
	full_name = "Vent crawl"
	description = "Enter an air vent and crawl through the pipe system."
	keybind_signal = COMSIG_XENOABILITY_VENTCRAWL

/datum/keybinding/xeno/vent/down(client/user)
	. = ..()
	if(!isxeno(user.mob))
		return
	var/mob/living/carbon/xenomorph/xeno = user.mob
	xeno.vent_crawl()

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
	hotkey_keys = list("ShiftQ")

/datum/keybinding/xeno/call_of_the_burrowed
	name = "call_of_the_burrowed"
	full_name = "Call of the Burrowed"
	description = "Attempts to summon all currently burrowed larva."
	keybind_signal = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED

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

//
// Single caste, alphabetical order
//
/datum/keybinding/xeno/baneling_explode
	name = "Explode"
	full_name = "Baneling: Explode"
	description = "Detonate yourself, spreading your currently selected reagent. Size depends on current stored plasma, more plasma is more reagent."
	keybind_signal = COMSIG_XENOABILITY_BANELING_EXPLODE
	hotkey_keys = list("E")

/datum/keybinding/xeno/select_reagent/baneling
	name = "Select Reagent"
	full_name = "Baneling: Select Reagent"
	description = "Choose a reagent that will be spread upon death. Costs plasma to change."
	keybind_signal = COMSIG_XENOABILITY_BANELING_CHOOSE_REAGENT
	hotkey_keys = list("C")

/datum/keybinding/xeno/toggle_bomb
	name = "toggle_bomb"
	full_name = "Boiler: Toggle Bombard Type"
	description = "Toggles the type of glob ."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB

/datum/keybinding/xeno/toggle_bomb_radial
	name = "toggle_bomb_radial"
	full_name = "Boiler: Select Bombard Type (Radial)"
	description = "Will use the default toggle if you have two or less available glob types."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB_RADIAL
	hotkey_keys = list("X")

/datum/keybinding/xeno/create_bomb
	name = "create_bomb"
	full_name = "Boiler: Create Bombard Ammo"
	description = "Create new globs to fire."
	keybind_signal = COMSIG_XENOABILITY_CREATE_BOMB
	hotkey_keys = list("F")

/datum/keybinding/xeno/bombard
	name = "bombard"
	full_name = "Boiler: Bombard"
	description = "Fire globules."
	keybind_signal = COMSIG_XENOABILITY_BOMBARD
	hotkey_keys = list("R")

/datum/keybinding/xeno/acid_shroud
	name = "acid_shroud"
	full_name = "Boiler: Acid Shroud"
	description = "Create a smokescreen for a getaway."
	keybind_signal = COMSIG_XENOABILITY_ACID_SHROUD
	hotkey_keys = list("Q")

/datum/keybinding/xeno/acid_shroud_melter
	name = "Melter: Acid Shroud"
	full_name = "Melter: Acid Shroud"
	description = "Create a smokescreen for a getaway."
	keybind_signal = COMSIG_XENOABILITY_ACID_SHROUD_MELTER

/datum/keybinding/xeno/acid_shroud_select
	name = "select_acid_shroud"
	full_name = "Boiler: Select Acid Shroud"
	description = "Create a smokescreen for a getaway."
	keybind_signal = COMSIG_XENOABILITY_ACID_SHROUD_SELECT

/datum/keybinding/xeno/smokescreen_spit
	name = "smokescreen_spit"
	full_name = "Sizzler: Smokescreen Spit"
	description = "Empowers your next spit to create a smokescreen."
	keybind_signal = COMSIG_XENOABILITY_SMOKESCREEN_SPIT
	hotkey_keys = list("C")

/datum/keybinding/xeno/steam_rush
	name = "steam_rush"
	full_name = "Sizzler: Steam Rush"
	description = "Speeds up and increases slash damage."
	keybind_signal = COMSIG_XENOABILITY_STEAM_RUSH
	hotkey_keys = list("Space")

/datum/keybinding/xeno/high_pressure_spit
	name = "high_pressure_spit"
	full_name = "Sizzler: High Pressure Spit"
	description = "Fires a high pressure glob of acid that shatters and massively knocksback the target."
	keybind_signal = COMSIG_XENOABILITY_HIGH_PRESSURE_SPIT
	hotkey_keys = list("E")

/datum/keybinding/xeno/plow_charge
	name = "plow_charge"
	full_name = "Bull: Plow Charge"
	description = "A charge that plows through the victims."
	keybind_signal = COMSIG_XENOABILITY_BULLCHARGE
	hotkey_keys = list("Q")

/datum/keybinding/xeno/headbutt_charge
	name = "headbutt_charge"
	full_name = "Bull: Headbutt Charge"
	description = "A charge that tosses the victim forward or backwards, depending on intent."
	keybind_signal = COMSIG_XENOABILITY_BULLHEADBUTT
	hotkey_keys = list("F")

/datum/keybinding/xeno/gore_charge
	name = "gore_charge"
	full_name = "Bull: Gore Charge"
	description = "A charge that gores the victim."
	keybind_signal = COMSIG_XENOABILITY_BULLGORE
	hotkey_keys = list("R")

/datum/keybinding/xeno/throw_hugger
	name = "throw_hugger"
	full_name = "Carrier: Throw Hugger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_THROW_HUGGER
	hotkey_keys = list("E")

/datum/keybinding/xeno/call_younger
	name = "call_younger"
	full_name = "Carrier: Call of Younger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CALL_YOUNGER
	hotkey_keys = list("C")

/datum/keybinding/xeno/place_trap
	name = "place_trap"
	full_name = "Carrier: Place Trap"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PLACE_TRAP
	hotkey_keys = list("Q")

/datum/keybinding/xeno/spawn_hugger
	name = "spawn_hugger"
	full_name = "Carrier: Spawn Hugger"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_SPAWN_HUGGER
	hotkey_keys = list("F")

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
	hotkey_keys = list("X")

/datum/keybinding/xeno/drop_all_hugger
	name = "drop_all_hugger"
	full_name = "Carrier: Carrier Panic"
	description = "Drop all stored huggers in a fit of panic. Uses all remaining plasma!"
	keybind_signal = COMSIG_XENOABILITY_DROP_ALL_HUGGER
	hotkey_keys = list("Space")

/datum/keybinding/xeno/build_hugger_turret
	name = "build_hugger_turret"
	full_name = "Carrier: Build Hugger Turret"
	description = "Build a hugger turret."
	keybind_signal = COMSIG_XENOABILITY_BUILD_HUGGER_TURRET
	hotkey_keys = list("R")

/datum/keybinding/xeno/stomp
	name = "stomp"
	full_name = "Crusher: Stomp"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_STOMP
	hotkey_keys = list("Q")

/datum/keybinding/xeno/cresttoss
	name = "cresttoss"
	full_name = "Crusher: Crest Toss"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CRESTTOSS
	hotkey_keys = list("E")

/datum/keybinding/xeno/advance
	name = "advance"
	full_name = "Crusher: Rapid Advance"
	description = "Charges up the crushers charge, then unleashes the full bulk of the crusher into a direction."
	keybind_signal = COMSIG_XENOABILITY_ADVANCE
	hotkey_keys = list("F")

/datum/keybinding/xeno/forward_charge
	name = "forward charge"
	full_name = "Defender: Forward charge"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_FORWARD_CHARGE
	hotkey_keys = list("R")

/datum/keybinding/xeno/tail_sweep
	name = "tail_sweep"
	full_name = "Defender: Tail Sweep"
	description = "Hit all adjacent units around you, knocking them away and down."
	keybind_signal = COMSIG_XENOABILITY_TAIL_SWEEP
	hotkey_keys = list("E")

/datum/keybinding/xeno/crest_defense
	name = "crest_defense"
	full_name = "Defender: Crest Defense"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREST_DEFENSE
	hotkey_keys = list("Z")

/datum/keybinding/xeno/fortify
	name = "fortify"
	full_name = "Defender: Fortify"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_FORTIFY
	hotkey_keys = list("Space")

/datum/keybinding/xeno/regenerate_skin
	name = "regenerate_skin"
	full_name = "Defender: Regenerate Skin"
	description = "Regenerate your skin, restoring some health and removing all armor sunder."
	keybind_signal = COMSIG_XENOABILITY_REGENERATE_SKIN
	hotkey_keys = list("F")

/datum/keybinding/xeno/centrifugal_force
	name = "centrifugal_force"
	full_name = "Defender: Centrifugal Force"
	description = "Rapidly spin and hit all adjacent humans around you, knocking them away and down."
	keybind_signal = COMSIG_XENOABILITY_CENTRIFUGAL_FORCE
	hotkey_keys = list("X")

/datum/keybinding/xeno/emit_neurogas
	name = "emit_neurogas"
	full_name = "Defiler: Emit Neurogas"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS
	hotkey_keys = list("E")

/datum/keybinding/xeno/select_reagent
	name = "select_reagent"
	full_name = "Defiler: Select Reagent"
	description = "Cycles through reagents to choose one for Defiler abilities."
	keybind_signal = COMSIG_XENOABILITY_SELECT_REAGENT
	hotkey_keys = list("C")

/datum/keybinding/xeno/radial_select_reagent
	name = "radial_select_reagent"
	full_name = "Defiler: Select Reagent (Radial)"
	description = "Chooses a reagent from a radial menu to use for Defiler abilities."
	keybind_signal = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT
	hotkey_keys = list("X")

/datum/keybinding/xeno/reagent_slash
	name = "reagent_slash"
	full_name = "Defiler: Reagent Slash"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_REAGENT_SLASH
	hotkey_keys = list("R")

/datum/keybinding/xeno/defile
	name = "defile"
	full_name = "Defiler: Defile"
	description = "Purges xeno toxins in exchange for dealing toxin damage and generating toxic sanguinal smoke."
	keybind_signal = COMSIG_XENOABILITY_DEFILE
	hotkey_keys = list("F")

/datum/keybinding/xeno/tentacle
	name = "tentacle"
	full_name = "Defiler: Tentacle"
	description = "Allows the defiler to grab a tallhost or item from range and bring it towards the defiler."
	keybind_signal = COMSIG_XENOABILITY_TENTACLE
	hotkey_keys = list("Q")

/datum/keybinding/xeno/inject_egg_neurogas
	name = "inject_egg_neurogas"
	full_name = "Defiler: Inject Egg (Neurogas)"
	description = "Inject an egg with neurogas, killing the little one inside"
	keybind_signal = COMSIG_XENOABILITY_INJECT_EGG_NEUROGAS

/datum/keybinding/xeno/acidic_salve
	name = "acidic_salve"
	full_name = "Drone: Acidic Salve"
	description = "Heal a xenomorph with this."
	keybind_signal = COMSIG_XENOABILITY_ACIDIC_SALVE
	hotkey_keys = list("F")

/datum/keybinding/xeno/essence_link
	name = "essence_link"
	full_name = "Drone: Essence Link"
	description = "Establish a link of plasma with a sister."
	keybind_signal = COMSIG_XENOABILITY_ESSENCE_LINK
	hotkey_keys = list("Q")

/datum/keybinding/xeno/essence_link_remove
	name = "essence_link_remove"
	full_name = "Drone: End Essence Link"
	description = "Forcibly end an Essence Link."
	keybind_signal = COMSIG_XENOABILITY_ESSENCE_LINK_REMOVE
	hotkey_keys = list("E")

/datum/keybinding/xeno/enhancement
	name = "enhancement"
	full_name = "Drone: Enhancement"
	description = "Using an Essence Link, increase a sister's capabilities beyond their limits."
	keybind_signal = COMSIG_XENOABILITY_ENHANCEMENT
	hotkey_keys = list("R")

/datum/keybinding/xeno/devour
	name = "devour"
	full_name = "Gorger: Devour"
	description = "Devour your victim to be able to carry it faster."
	keybind_signal = COMSIG_XENOABILITY_DEVOUR
	hotkey_keys = list("X")

/datum/keybinding/xeno/drain
	name = "drain"
	full_name = "Gorger: Drain"
	description = "Stagger a marine and drain some of their blood. When used on a dead human, you heal gradually and don't gain blood."
	keybind_signal = COMSIG_XENOABILITY_DRAIN
	hotkey_keys = list("E")

/datum/keybinding/xeno/transfusion
	name = "transfusion"
	full_name = "Gorger: Transfusion"
	description = "Restores some of the health of another xenomorph, or overheals, at the cost of blood."
	keybind_signal = COMSIG_XENOABILITY_TRANSFUSION
	hotkey_keys = list("H")

/datum/keybinding/xeno/oppose
	name = "oppose"
	full_name = "Gorger: Oppose"
	description = "Violently suffuse the nearby ground with stored blood, staggering nearby marines and healing nearby xenomorphs."
	keybind_signal = COMSIG_XENOABILITY_OPPOSE
	hotkey_keys = list("R")

/datum/keybinding/xeno/psychic_link
	name = "psychic link"
	full_name = "Gorger: Psychic Link"
	description = "Link to a xenomorph and take some damage in their place. During this time, you can't move. Use rest action to cancel."
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_LINK
	hotkey_keys = list("Q")

/datum/keybinding/xeno/carnage
	name = "carnage"
	full_name = "Gorger: Carnage"
	description = "For a while your attacks drain blood and heal you. During Feast you also heal nearby allies."
	keybind_signal = COMSIG_XENOABILITY_CARNAGE
	hotkey_keys = list("C")

/datum/keybinding/xeno/feast
	name = "feast"
	full_name = "Gorger: Feast"
	description = "Enter a state of rejuvenation. During this time you use a small amount of blood and heal. You can cancel this early."
	keybind_signal = COMSIG_XENOABILITY_FEAST
	hotkey_keys = list("F")

/datum/keybinding/xeno/resin_walker
	name = "resin_walker"
	full_name = "Hivelord: Toggle Resin Walker"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RESIN_WALKER
	hotkey_keys = list("E")

/datum/keybinding/xeno/build_tunnel
	name = "build_tunnel"
	full_name = "Hivelord: Build Tunnel"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_BUILD_TUNNEL
	hotkey_keys = list("ShiftQ")

/datum/keybinding/xeno/place_jelly_pod
	name = "place_jelly_pod"
	full_name = "Hivelord: Place Jelly Pod"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PLACE_JELLY_POD

/datum/keybinding/xeno/place_recovery_pylon
	name = "Hivelord: Place Recovery Pylon"
	full_name = "Hivelord: Recovery Pylon"
	description = "Plants a recovery pylon that increases the amount of regeneration power restored."
	keybind_signal = COMSIG_XENOABILITY_PLACE_RECOVERY_PYLON

/datum/keybinding/xeno/create_jelly
	name = "create_jelly"
	full_name = "Hivelord: Create Jelly"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_CREATE_JELLY
	hotkey_keys = list("F")

/datum/keybinding/xeno/healing_infusion
	name = "healing_infusion"
	full_name = "Hivelord: Healing Infusion"
	description = "Imbues a target xeno with healing energy, restoring extra Sunder and Health once every 2 seconds up to 5 times whenever it regenerates normally. 60 second duration."
	keybind_signal = COMSIG_XENOABILITY_HEALING_INFUSION
	hotkey_keys = list("H")

/datum/keybinding/xeno/sow
	name = "sow"
	full_name = "Hivelord: Sow"
	description = "Plant the seeds of an alien plant."
	keybind_signal = COMSIG_XENOABILITY_DROP_PLANT
	hotkey_keys = list("C")

/datum/keybinding/xeno/sow_select_plant
	name = "choose_plant"
	full_name = "Hivelord: Choose plant"
	description = "Pick what type of plant to sow."
	keybind_signal = COMSIG_XENOABILITY_CHOOSE_PLANT

/datum/keybinding/xeno/change_form
	name = "change_form"
	full_name = "Hivemind: Change Form"
	description = "Change form to/from incorporeal."
	keybind_signal = COMSIG_XENOMORPH_HIVEMIND_CHANGE_FORM
	hotkey_keys = list("F")

/datum/keybinding/xeno/teleport_minimap
	name = "teleport_minimap"
	full_name = "Hivemind: Open teleportation minimap"
	description = "Opens up the minimap which, when you click somewhere, tries to teleport you to the selected location"
	keybind_signal = COMSIG_XENOMORPH_HIVEMIND_TELEPORT
	hotkey_keys = list("C")

/datum/keybinding/xeno/hunter_pounce
	name = "hunter_pounce"
	full_name = "Hunter: Pounce"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_HUNTER_POUNCE
	hotkey_keys = list("E")

/datum/keybinding/xeno/toggle_stealth
	name = "toggle_stealth"
	full_name = "Hunter: Toggle Stealth"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH
	hotkey_keys = list("Q")

/datum/keybinding/xeno/toggle_disguise
	name = "toggle_disguise"
	full_name = "Hunter: Toggle Disguise"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_DISGUISE
	hotkey_keys = list("F")

/datum/keybinding/xeno/mirage
	name = "mirage"
	full_name = "Hunter: Mirage"
	description = "Creates multiple mirror images of the xeno."
	keybind_signal = COMSIG_XENOABILITY_MIRAGE
	hotkey_keys = list("R")

/datum/keybinding/xeno/silence
	name = "impair senses"
	full_name = "Hunter: Silence"
	description = "Impairs the ability of hostile living creatures we can see in a 5x5 area. Targets will be unable to speak and hear for 10 seconds."
	keybind_signal = COMSIG_XENOABILITY_SILENCE
	hotkey_keys = list("X")

/datum/keybinding/xeno/mark
	name = "mark"
	full_name = "Hunter: Mark"
	description = "Mark that lonely marine so that you can track with Psychic Trace."
	keybind_signal = COMSIG_XENOABILITY_HUNTER_MARK
	hotkey_keys = list("C")

/datum/keybinding/xeno/psychic_trace
	name = "psychic_trace"
	full_name = "Hunter: Psychic Trace"
	description = "Locate direction of marine that you've marked."
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_TRACE
	hotkey_keys = list("G")

/datum/keybinding/xeno/nightfall
	hotkey_keys = list("F")
	name = "nightfall"
	full_name = "King: Nightfall"
	description = "Shut down all nearby electric lights for 10 seconds"
	keybind_signal = COMSIG_XENOABILITY_NIGHTFALL

/datum/keybinding/xeno/petrify
	hotkey_keys = list("E")
	name = "petrify"
	full_name = "King: Petrify"
	description = "Petrifies all humans within view. While petrified humans can neither be damaged or take any actions."
	keybind_signal = COMSIG_XENOABILITY_PETRIFY

/datum/keybinding/xeno/off_guard
	hotkey_keys = list("Q")
	name = "off_guard"
	full_name = "King: Off-guard"
	description = "Muddles the mind of an enemy, increasing their scatter for a while."
	keybind_signal = COMSIG_XENOABILITY_OFFGUARD

/datum/keybinding/xeno/shattering_roar
	hotkey_keys = list("R")
	name = "shattering_roar"
	full_name = "King: Shattering roar"
	description = "Unleash a mighty psychic roar, knocking down any foes in your path and weakening them."
	keybind_signal = COMSIG_XENOABILITY_SHATTERING_ROAR

/datum/keybinding/xeno/zero_form_beam
	hotkey_keys = list("R")
	name = "zero_form_beam"
	full_name = "King: Zero-form beam"
	description = "After a windup, concentrates the hives energy into a forward-facing beam that pierces everything, but only hurts living beings."
	keybind_signal = COMSIG_XENOABILITY_ZEROFORMBEAM

/datum/keybinding/xeno/psychic_summon
	name = "psychic_summon"
	full_name = "King: Psychic Summon"
	description = "Summons all xenos in a hive to the caller's location, uses all plasma to activate."
	keybind_signal = COMSIG_XENOABILITY_HIVE_SUMMON

/datum/keybinding/xeno/conqueror_dash
	name = "Conqueror's Dash"
	full_name = "Conqueror: Dash"
	description = "Move in a burst of speed. Double tap any movement direction to dash towards it."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_DASH

/datum/keybinding/xeno/conqueror_will
	name = "Conqueror's Will"
	full_name = "Conqueror: Conqueror's Will"
	description = "Imbue your punches with charged plasma. Upgrades attacks, and allows you to execute powerful combos while this ability is selected."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_WILL
	hotkey_keys = list("C")

/datum/keybinding/xeno/conqueror_endurance_hold
	name = "Conqueror's Endurance (Hold)"
	full_name = "Conqueror: Endurance (Hold)"
	description = "While the button is held, you will block attacks with your forearms, reducing damage received."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_HOLD
	hotkey_keys = list("Z")

/datum/keybinding/xeno/conqueror_endurance_hold/up(client/user)
	SEND_SIGNAL(user, COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_UP, TRUE)
	return ..()

/datum/keybinding/xeno/conqueror_endurance_toggle
	name = "Conqueror's Endurance (Toggle)"
	full_name = "Conqueror: Endurance (Toggle)"
	description = "While toggled, you will block attacks with your forearms, reducing damage received."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_TOGGLE

/datum/keybinding/xeno/conqueror_dominance
	name = "Conqueror's Domination"
	full_name = "Conqueror: Domination"
	description = "Teleport towards a target location, distorting reality, and creating powerful shockwaves upon reappearing."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_DOMINATION
	hotkey_keys = list("E")

/datum/keybinding/xeno/conqueror_obliteration_hold
	name = "Conqueror's Obliteration (Hold)"
	full_name = "Conqueror: Obliteration (Hold)"
	description = "Unleash your latent power. While the button is held, you will create an area of effect that will slowly expand. Releasing the button will attack everyone caught within it."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_HOLD
	hotkey_keys = list("F")

/datum/keybinding/xeno/conqueror_obliteration_hold/up(client/user)
	SEND_SIGNAL(user, COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_UP, TRUE)
	return ..()

/datum/keybinding/xeno/conqueror_obliteration_toggle
	name = "Conqueror's Obliteration (Toggle)"
	full_name = "Conqueror: Obliteration (Toggle)"
	description = "Unleash your latent power. While enabled, you will create an area of effect that will slowly expand. Using the ability again will attack everyone caught within it."
	keybind_signal = COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_TOGGLE

/datum/keybinding/xeno/acid_dash
	name = "acid_dash"
	full_name = "Praetorian: Acid Dash"
	description = "Quickly dash, leaving acid in your path and knocking down the first marine hit. Has reset potential."
	keybind_signal = COMSIG_XENOABILITY_ACID_DASH
	hotkey_keys = list("E")

/datum/keybinding/xeno/acid_dash_melter
	name = "Melter: Acid Dash"
	full_name = "Melter: Acid Dash"
	description = "Quickly dash, leaving acid in your path and knocking down the first marine hit. Has reset potential."
	keybind_signal = COMSIG_XENOABILITY_ACID_DASH_MELTER

/datum/keybinding/xeno/acidic_missile
	name = "Melter: Acidic Missile"
	full_name = "Melter: Acid Missile"
	description = "Begin building up acid. If you're already building up acid, launch yourself at a target and splash acid all around you."
	keybind_signal = COMSIG_XENOABILITY_ACIDIC_MISSILE

/datum/keybinding/xeno/dodge
	name = "Dodge"
	full_name = "Dancer: Dodge"
	description = "Flood your body with adrenaline, gaining a speed boost upon activation and the ability to pass through mobs. Enemies automatically receive bump attacks when passed."
	keybind_signal = COMSIG_XENOABILITY_DODGE

/datum/keybinding/xeno/impale
	name = "Impale"
	full_name = "Dancer: Impale"
	description = "Skewer an object next to you with your tail. The more debuffs on a living target, the greater the damage done. Penetrates the armor of marked targets."
	keybind_signal = COMSIG_XENOABILITY_IMPALE

/datum/keybinding/xeno/tail_trip
	name = "Tail Trip"
	full_name = "Dancer: Tail Trip"
	description = "Twirl your tail around low to the ground, knocking over and disorienting any adjacent marines. Marked enemies receive stronger debuffs and are briefly stunned."
	keybind_signal = COMSIG_XENOABILITY_TAIL_TRIP

/datum/keybinding/xeno/tail_hook
	name = "Tail Hook"
	full_name = "Dancer: Tail Hook"
	description = "Swing your tail high, sending the hooked edge gouging into any targets within 2 tiles. Hooked marines have their movement slowed and are dragged, spinning, towards you. Marked marines are slowed for longer and briefly knocked over."
	keybind_signal = COMSIG_XENOABILITY_TAILHOOK

/datum/keybinding/xeno/baton_pass
	name = "Baton Pass"
	full_name = "Dancer: Baton Pass"
	description = "Inject another xenomorph with your built-up adrenaline, increasing their movement speed considerably for 6 seconds. Puts dodge on cooldown when used. Less effect on quick xenos."
	keybind_signal = COMSIG_XENOABILITY_BATONPASS

/datum/keybinding/xeno/abduct
	name = "Abduct"
	full_name = "Oppressor: Abduct"
	description = "After a delay, grab marines from a 7 tiles away. Canceling early has consequences."
	keybind_signal = COMSIG_XENOABILITY_ABDUCT

/datum/keybinding/xeno/dislocate
	name = "Dislocate"
	full_name = "Oppressor: Dislocate"
	description = "Punch a marine and knock them back by two tiles."
	keybind_signal = COMSIG_XENOABILITY_DISLOCATE

/datum/keybinding/xeno/item_throw
	name = "Item Throw"
	full_name = "Oppressor: Item Throw"
	description = "Pick up an item and throw it. Damage and range varies based on item's size."
	keybind_signal = COMSIG_XENOABILITY_ITEM_THROW

/datum/keybinding/xeno/tail_lash
	name = "Tail Lash"
	full_name = "Oppressor: Tail Lash"
	description = "Knock back marines in a 2x3 radius where you're facing by two tiles."
	keybind_signal = COMSIG_XENOABILITY_TAIL_LASH

/datum/keybinding/xeno/tail_lash_select
	name = "Tail Lash (Select)"
	full_name = "Oppressor: Select Tail Lash"
	description = "Knock back marines in a 2x3 radius where you're facing by two tiles."
	keybind_signal = COMSIG_XENOABILITY_TAIL_LASH_SELECT

/datum/keybinding/xeno/advance_oppressor
	name = "Advance (Oppressor)"
	full_name = "Oppressor: Advance"
	description = "Launch yourself with tremendous speed toward a location. Hitting a marine will cause them to be launched incredibly far."
	keybind_signal = COMSIG_XENOABILITY_ADVANCE_OPPRESSOR

/datum/keybinding/xeno/screech
	name = "screech"
	full_name = "Queen: Screech"
	description = "Screech, shortly stunning and deafening all nearby marines."
	keybind_signal = COMSIG_XENOABILITY_SCREECH
	hotkey_keys = list("E")

/datum/keybinding/xeno/screech_switch
	name = "screech_switch"
	full_name = "Queen: Screech Switch"
	description = "Switches the type of Screech that will be performed."
	keybind_signal = COMSIG_XENOABILITY_SCREECH_SWITCH

/datum/keybinding/xeno/toggle_queen_zoom
	name = "toggle_queen_zoom"
	full_name = "Queen: Toggle Zoom"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_QUEEN_ZOOM
	hotkey_keys = list("C")

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
	hotkey_keys = list("H")

/datum/keybinding/xeno/queen_give_plasma
	name = "queen_give_plasma"
	full_name = "Queen: Give Plasma"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA
	hotkey_keys = list("N")

/datum/keybinding/xeno/queen_give_plasma_quickcast
	name = "queen_give_plasma_quickcast"
	full_name = "Queen: Give Plasma (Quickcast)"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_QUEEN_GIVE_PLASMA_QUICKCAST

/datum/keybinding/xeno/queen_hive_message
	name = "queen_hive_message"
	full_name = "Queen: Hive Message"
	description = "Instantly displays a bolded announcement to all xenos in the hive."
	keybind_signal = COMSIG_XENOABILITY_QUEEN_HIVE_MESSAGE

/datum/keybinding/xeno/queen_bulwark
	name = "queen_bulwark"
	full_name = "Queen: Bulwark"
	description = "Forms an area around you that reduces damage taken by friendly xenomorphs."
	keybind_signal = COMSIG_XENOABILITY_QUEEN_BULWARK
	hotkey_keys = list("F")

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
	hotkey_keys = list("E")

/datum/keybinding/xeno/ravager_endure
	name = "ravager_endure"
	full_name = "Ravager: Endure"
	description = "For the next few moments you will not go into crit and become resistant to explosives and immune to stagger and slowdown, but you still die if you take damage exceeding your crit health."
	keybind_signal = COMSIG_XENOABILITY_ENDURE
	hotkey_keys = list("F")

/datum/keybinding/xeno/ravager_rage
	name = "ravager_rage"
	full_name = "Ravager: Rage"
	description = "While active, you will temporarily recover plasma and sunder and gain a bonus to speed and melee damage in proportion to the percentage of your missing health. At negative HP your ability cooldowns reset and your slash damage restores health."
	keybind_signal = COMSIG_XENOABILITY_RAGE
	hotkey_keys = list("Space")

/datum/keybinding/xeno/ravager_vampirism
	name = "togglevampirism"
	full_name = "Ravager: Toggle vampirism"
	description = "While active, will increase the ravagers healing for a while for every time it hits a new enemy. Effects stack."
	keybind_signal = COMSIG_XENOABILITY_VAMPIRISM

/datum/keybinding/xeno/ravager_deathmark
	name = "deathmark"
	full_name = "Bloodthirster: Deathmark"
	description = "Mark yourself for death, filling your bloodthirst, but failing to deal enough damage to living creatures while it is active instantly kills you."
	keybind_signal = COMSIG_XENOABILITY_DEATHMARK

/datum/keybinding/xeno/ravage
	name = "ravage"
	full_name = "Ravager: Ravage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGE
	hotkey_keys = list("R")

/datum/keybinding/xeno/ravage_select
	name = "ravage select"
	full_name = "Ravager: Select Ravage"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RAVAGE_SELECT

/datum/keybinding/xeno/pounce
	name = "pounce"
	full_name = "Runner: Pounce"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_RUNNER_POUNCE
	hotkey_keys = list("E")

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
	hotkey_keys = list("Z")

/datum/keybinding/xeno/auto_evasion
	name = "auto_evasion"
	full_name = "Runner: Toggle Auto Evasion"
	description = "Toggles Auto Evasion on or off. While active, Auto Evasion will automatically use Evasion when you gain its cooldown reset bonus."
	keybind_signal = COMSIG_XENOABILITY_AUTO_EVASION

/datum/keybinding/xeno/snatch
	name = "snatch"
	full_name = "Runner: Snatch"
	description = "Take an item equipped by your target in your mouth, and carry it away."
	keybind_signal = COMSIG_XENOABILITY_SNATCH
	hotkey_keys = list("Q")

/datum/keybinding/xeno/toxic_slash
	name = "toxic_slash"
	full_name = "Sentinel: Toxic Slash"
	description = "Imbue your claws with toxins, inflicting the Intoxicated debuff on hit and dealing damage over time."
	keybind_signal = COMSIG_XENOABILITY_TOXIC_SLASH
	hotkey_keys = list("R")

/datum/keybinding/xeno/drain_sting
	name = "drain_sting"
	full_name = "Sentinel: Drain Sting"
	description = "Sting a victim, draining any Intoxicated debuffs they may have, restoring you and dealing damage."
	keybind_signal = COMSIG_XENOABILITY_DRAIN_STING
	hotkey_keys = list("F")

/datum/keybinding/xeno/toxicgrenade
	name = "toxic_grenade"
	full_name = "Sentinel: Toxic Grenade"
	description = "Throws a ball of resin containing a toxin that inflicts the Intoxicated debuff, dealing damage over time."
	keybind_signal = COMSIG_XENOABILITY_TOXIC_GRENADE
	hotkey_keys = list("Q")

/datum/keybinding/xeno/psychic_fling
	name = "psychic_fling"
	full_name = "Shrike: Psychic Fling"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_FLING
	hotkey_keys = list("E")

/datum/keybinding/xeno/unrelenting_force
	name = "unrelenting_force"
	full_name = "Shrike: Unrelenting Force"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_UNRELENTING_FORCE
	hotkey_keys = list("R")

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
	hotkey_keys = list("F")

/datum/keybinding/xeno/psychic_storm
	name = "gravnade"
	full_name = "Shrike: Psychic Vortex"
	description = ""
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_VORTEX
	hotkey_keys = list("X")

/datum/keybinding/xeno/scatter_spit
	name = "scatter_spit"
	full_name = "Spitter: Scatter Spit"
	description = "Fires a scattershot of 6 acid globules which create acid puddles on impact or at the end of their range."
	keybind_signal = COMSIG_XENOABILITY_SCATTER_SPIT
	hotkey_keys = list("E")

/datum/keybinding/xeno/toss_grenade
	name = "toss_grenade"
	full_name = "Globadier: Toss Grenade"
	description = "Toss a grenade at your target."
	keybind_signal = COMSIG_XENOABILITY_TOSS_GRENADE
	hotkey_keys = list("R")

/datum/keybinding/xeno/pick_grenade
	name = "pick_grenade"
	full_name = "Globadier: Pick Grenade"
	description = "Pick which grenade to use with Toss Grenade."
	keybind_signal = COMSIG_XENOABILITY_PICK_GRENADE
	hotkey_keys = list("F")

/datum/keybinding/xeno/acid_mine
	name = "acid_mine"
	full_name = "Globadier: Place Mine"
	description = "Place a Mine at your location. Its effects depend on your selected grenade."
	keybind_signal = COMSIG_XENOABILITY_ACID_MINE
	hotkey_keys = list("G")

/datum/keybinding/xeno/gas_mine
	name = "gas_mine"
	full_name = "Globadier: Gas Mine"
	description = "Place a Gas Mine at your location."
	keybind_signal = COMSIG_XENOABILITY_GAS_MINE
	hotkey_keys = list("H")

/datum/keybinding/xeno/acid_rocket
	name = "acid_rocket"
	full_name = "Globadier: Acid Rocket"
	description = "Fire a acid rocket at your target, after a short charge up."
	keybind_signal = COMSIG_XENOABILITY_ACID_ROCKET
	hotkey_keys = list("Y")

/datum/keybinding/xeno/psychic_shield
	name = "Psychic Shield"
	full_name = "Warlock: Psychic Shield"
	description = "Channel a psychic shield at your current location that can reflect most projectiles. Activate again while the shield is active to detonate the shield forcibly, producing knockback."
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_SHIELD
	hotkey_keys = list("E")

/datum/keybinding/xeno/trigger_psychic_shield
	name = "Trigger Psychic Shield"
	full_name = "Warlock: Trigger Psychic Shield"
	description = "Triggers the Psychic Shield ability without selecting it."
	keybind_signal = COMSIG_XENOABILITY_TRIGGER_PSYCHIC_SHIELD

/datum/keybinding/xeno/psychic_blast
	name = "Psychic Blast"
	full_name = "Warlock: Psychic Blast"
	description = "Fire a lightly-damaging AOE psychic beam which knocks back enemies after a short charge-up."
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_BLAST
	hotkey_keys = list("R")

/datum/keybinding/xeno/psychic_crush
	name = "Psychic Crush"
	full_name = "Warlock: Psychic Crush"
	description = "Channel an expanding AOE crush effect, activating it again pre-maturely crushes enemies over an area."
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CRUSH
	hotkey_keys = list("Q")

/datum/keybinding/xeno/toggle_agility
	name = "toggle_agility"
	full_name = "Warrior: Toggle Agility"
	description = "Toggles Agility mode. While in Agility mode, you move much more quickly but can't use abilities and your armor is greatly reduced."
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_AGILITY
	hotkey_keys = list("Space")

/datum/keybinding/xeno/lunge
	name = "lunge"
	full_name = "Warrior: Lunge"
	description = "Charges towards a target, then neckgrabs them if they're adjacent to you. Stuns on upon grabbing for 1 second."
	keybind_signal = COMSIG_XENOABILITY_LUNGE
	hotkey_keys = list("E")

/datum/keybinding/xeno/fling
	name = "fling"
	full_name = "Warrior: Fling"
	description = "Quickly flings a target 4 tiles away and inflicts a short stun. Shared cooldown with Grapple Toss."
	keybind_signal = COMSIG_XENOABILITY_FLING
	hotkey_keys = list("Q")

/datum/keybinding/xeno/grapple_toss
	name = "grapple_toss"
	full_name = "Warrior: Grapple Toss"
	description = "Throw a target you're grabbing up to 5 tiles away. Inflicts a short stun and stagger and slow stacks. Shared cooldown with Fling."
	keybind_signal = COMSIG_XENOABILITY_GRAPPLE_TOSS
	hotkey_keys = list("F")

/datum/keybinding/xeno/punch
	name = "punch"
	full_name = "Warrior: Punch"
	description = "Punch a hostile creature, a structure or piece of machinery. Damage and status durations are doubled vs creatures you are grabbing. Damage is quadrupled vs structures and machinery."
	keybind_signal = COMSIG_XENOABILITY_PUNCH
	hotkey_keys = list("R")

/datum/keybinding/xeno/jab
	name = "jab"
	full_name = "Warrior: Jab"
	description = "Precisely strike your target from further away, slowing and confusing them. Resets punch cooldown."
	keybind_signal = COMSIG_XENOABILITY_JAB
	hotkey_keys = list("E")

/datum/keybinding/xeno/burrow
	name = "burrow"
	full_name = "Widow: Burrow"
	description = "Dig to the ground, making you invisible."
	keybind_signal = COMSIG_XENOABILITY_BURROW
	hotkey_keys = list("C")

/datum/keybinding/xeno/web_spit
	name = "Web Spit"
	full_name = "Widow: Web Spit"
	description = "Spit web at your target. Hitting the target will impede their functions depending on their hit location."
	keybind_signal = COMSIG_XENOABILITY_WEB_SPIT
	hotkey_keys = list("Q")

/datum/keybinding/xeno/leash_ball
	name = "Leash Ball"
	full_name = "Widow: Leash Ball"
	description = "Spit a huge web ball of web that snares groups of targets for a brief while."
	keybind_signal = COMSIG_XENOABILITY_LEASH_BALL
	hotkey_keys = list("E")

/datum/keybinding/xeno/create_spiderling
	name = "Birth Spiderling"
	full_name = "Widow: Birth Spiderling"
	description = "Give birth to a spiderling after a short charge-up."
	keybind_signal = COMSIG_XENOABILITY_CREATE_SPIDERLING
	hotkey_keys = list("F")

/datum/keybinding/xeno/create_spiderling_using_cc
	name = "Birth Spiderling using Cannibalise charges"
	full_name = "Widow: Birth Spiderling using Cannibalise charges"
	description = "Give birth to a spiderling after a short charge-up if you have any Cannibalise charges available."
	keybind_signal = COMSIG_XENOABILITY_CREATE_SPIDERLING_USING_CC
	hotkey_keys = list("H")

/datum/keybinding/xeno/attach_spiderlings
	name = "Attach Spiderlings"
	full_name = "Widow: Attach Spiderlings"
	description = "Scoop up and carry your spawn with you."
	keybind_signal = COMSIG_XENOABILITY_ATTACH_SPIDERLINGS
	hotkey_keys = list("X")

/datum/keybinding/xeno/cannibalise
	name = "Cannibalise Spiderling"
	full_name = "Widow: Cannibalise Spiderling"
	description = "Eat your own young and store their biomass for later."
	keybind_signal = COMSIG_XENOABILITY_CANNIBALISE_SPIDERLING
	hotkey_keys = list("G")

/datum/keybinding/xeno/web_hook
	name = "Web Hook"
	full_name = "Widow: Web Hook"
	description = "Shoot a strong web and pull yourself towards whatever it hits."
	keybind_signal = COMSIG_XENOABILITY_WEB_HOOK
	hotkey_keys = list("R")

/datum/keybinding/xeno/spiderling_mark
	name = "Spiderling Mark"
	full_name = "Widow: Spiderling Mark"
	description = "Signal your spawn to a target they shall attack."
	keybind_signal = COMSIG_XENOABILITY_SPIDERLING_MARK
	hotkey_keys = list("V")

/datum/keybinding/xeno/rewind
	name = "rewind"
	full_name = "Wraith: Time Shift"
	description = "Save the location and status of the target. When the time is up, the target location and status are restored"
	keybind_signal = COMSIG_XENOABILITY_REWIND
	hotkey_keys = list("C")

/datum/keybinding/xeno/portal
	name = "portal"
	full_name = "Wraith: Portal"
	description = "Place the first portal on your location. You can travel from portal one to portal two and vice versa."
	keybind_signal =COMSIG_XENOABILITY_PORTAL
	hotkey_keys = list("E")

/datum/keybinding/xeno/portal_two
	name = "portal_two"
	full_name = "Wraith: Portal two"
	description = "Place the second portal on your location. You can travel from portal one to portal two and vice versa."
	keybind_signal =COMSIG_XENOABILITY_PORTAL_ALTERNATE
	hotkey_keys = list("R")

/datum/keybinding/xeno/timestop
	name = "timestop"
	full_name = "Wraith: Time stop"
	description = "Freezes bullets in their course, and they will start to move again only after a certain time"
	keybind_signal = COMSIG_XENOABILITY_TIMESTOP
	hotkey_keys = list("V")

/datum/keybinding/xeno/flay
	name = "Flay"
	full_name = "Puppeteer: Flay"
	description = "Takes a chunk of flesh from the victim marine through a quick swiping motion, adding 100 biomass to your biomass collection."
	keybind_signal = COMSIG_XENOABILITY_FLAY

/datum/keybinding/xeno/pincushion
	name = "Pincushion"
	full_name = "Puppeteer: Pincushion"
	description = "Launch a spine from your tail. This attack will help deter any organic as well as support your puppets and teammates in direct combat."
	keybind_signal = COMSIG_XENOABILITY_PINCUSHION

/datum/keybinding/xeno/dread
	name = "Dreadful Presence"
	full_name = "Puppeteer: Dreadful Presence"
	description = "Emit a menacing presence, striking fear into the organics and slowing them for a short duration."
	keybind_signal = COMSIG_XENOABILITY_DREADFULPRESENCE

/datum/keybinding/xeno/refurbish_husk
	name = "Refurbish Husk"
	full_name = "Puppeteer: Refurbish Husk"
	description = "Harvest the biomass and organs of a body in order to create a meat puppet to do your bidding."
	keybind_signal = COMSIG_XENOABILITY_REFURBISHHUSK

/datum/keybinding/xeno/stitch_puppet
	name = "Stitch Puppet"
	full_name = "Puppeteer: Stitch Puppet"
	description = "Uses 350 biomass to create a flesh homunculus to do your bidding, at an adjacent target location."
	keybind_signal = COMSIG_XENOABILITY_PUPPET

/datum/keybinding/xeno/organic_bomb
	name = "Organic Bomb"
	full_name = "Puppeteer: Organic Bomb"
	description = "Causes one of our puppets to detonate on selection, spewing acid out of the puppet's body in all directions, gibbing the puppet."
	keybind_signal = COMSIG_XENOABILITY_ORGANICBOMB

/datum/keybinding/xeno/tendrils
	name = "Tendrils"
	full_name = "Puppeteer: Tendrils"
	description = "Burrow freshly created tendrils to tangle organics in a 3x3 patch."
	keybind_signal = COMSIG_XENOABILITY_TENDRILS

/datum/keybinding/xeno/unleash_puppet
	name = "Unleash puppets"
	full_name = "Puppeteer: Unleash puppets"
	description = "Unleash puppets to attack nearby humans."
	keybind_signal = COMSIG_XENOABILITY_UNLEASHPUPPETS

/datum/keybinding/xeno/recall_puppet
	name = "Recall puppets"
	full_name = "Puppeteer: Recall puppets"
	description = "Recalls your puppets, making them follow you once more"
	keybind_signal = COMSIG_XENOABILITY_RECALLPUPPETS

/datum/keybinding/xeno/bestow_blessing
	name = "Bestow Blessings"
	full_name = "Puppeteer: Bestow Blessings"
	description = "Give blessings to your puppets."
	keybind_signal = COMSIG_XENOABILITY_BESTOWBLESSINGS

/datum/keybinding/xeno/behemoth_roll
	name = "Roll"
	full_name = "Behemoth: Roll"
	description = "Curl up into a ball, sacrificing some offensive capabilities in exchange for greater movement speed."
	keybind_signal = COMSIG_XENOABILITY_BEHEMOTH_ROLL

/datum/keybinding/xeno/landslide
	name = "Landslide"
	full_name = "Behemoth: Landslide"
	description = "Rush forward in the selected direction, damaging enemies caught in a wide path."
	keybind_signal = COMSIG_XENOABILITY_LANDSLIDE

/datum/keybinding/xeno/cancel_landslide
	name = "Cancel Landslide"
	full_name = "Behemoth: Cancel Landslide"
	description = "Cancels landslide without having to select the ability"
	keybind_signal = COMSIG_XENOABILITY_CANCEL_LANDSLIDE

/datum/keybinding/xeno/earth_riser
	name = "Earth Riser"
	full_name = "Behemoth: Earth Riser"
	description = "Raise a pillar of earth at the selected location. This solid structure can be used for defense, and it interacts with other abilities for offensive usage."
	keybind_signal = COMSIG_XENOABILITY_EARTH_RISER

/datum/keybinding/xeno/earth_riser_alternate
	name = "Destroy Earth Pillar"
	full_name = "Behemoth: Destroy Earth Pillar"
	description = "Destroy active Earth Pillars created by Earth Riser, starting by the oldest one."
	keybind_signal = COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE

/datum/keybinding/xeno/seismic_fracture
	name = "Seismic Fracture"
	full_name = "Behemoth: Seismic Fracture"
	description = "Blast the earth around the selected location, inflicting heavy damage in a large radius."
	keybind_signal = COMSIG_XENOABILITY_SEISMIC_FRACTURE

/datum/keybinding/xeno/primal_wrath
	name = "Primal Wrath"
	full_name = "Behemoth: Primal Wrath"
	description = "Unleash your wrath. Enhances your abilities, changing their functionality and allowing them to apply a damage over time debuff."
	keybind_signal = COMSIG_XENOABILITY_PRIMAL_WRATH

/datum/keybinding/xeno/firecharge
	name = "Fire Charge"
	full_name = "Pyrogen: Fire Charge"
	description = "Charge forward and attack a marine, extinguishing them if they're on fire, but dealing extra burn damage depending on how many firestacks they have."
	keybind_signal = COMSIG_XENOABILITY_FIRECHARGE

/datum/keybinding/xeno/firenado
	name = "Fire Storm"
	full_name = "Pyrogen: Fire Storm"
	description = "Unleash 3 firenados that will slowly move towards your targeted turf."
	keybind_signal = COMSIG_XENOABILITY_FIRENADO

/datum/keybinding/xeno/fireball
	name = "Fireball"
	full_name = "Pyrogen: Fireball"
	description = "Unleash a fireball after a small windup."
	keybind_signal = COMSIG_XENOABILITY_FIREBALL

/datum/keybinding/xeno/inferno
	name = "Inferno"
	full_name = "Pyrogen: Inferno"
	description = "Immediately release a large radius of fire and burning nearby marines in the process."
	keybind_signal = COMSIG_XENOABILITY_INFERNO

/datum/keybinding/xeno/infernal_trigger
	name = "Infernal Trigger"
	full_name = "Pyrogen: Infernal Trigger"
	description = "After a windup, cause a marine who is on fire to explode their flames outward and set on fire those around them."
	keybind_signal = COMSIG_XENOABILITY_INFERNAL_TRIGGER

/datum/keybinding/xeno/backhand
	name = "Backhand"
	full_name = "Dragon: Backhand"
	description = "Smack a group of marines in front of you away and stun them."
	keybind_signal = COMSIG_XENOABILITY_BACKHAND
	hotkey_keys = list("Z")

/datum/keybinding/xeno/fly
	name = "Fly"
	full_name = "Dragon: Fly"
	description = "After a windup, begin to fly away. If you're already flying, land."
	keybind_signal = COMSIG_XENOABILITY_FLY
	hotkey_keys = list("F")

/datum/keybinding/xeno/dragon_breath
	name = "Dragon Breath"
	full_name = "Dragon: Dragon Breath"
	description = "After a windup, continuously blast fire in a cardinal direction."
	keybind_signal = COMSIG_XENOABILITY_DRAGON_BREATH
	hotkey_keys = list("C")

/datum/keybinding/xeno/wind_current
	name = "Wind Current"
	full_name = "Dragon: Wind Current"
	description = "After a windup, clear gas and knock away marines in a cone in front of you."
	keybind_signal = COMSIG_XENOABILITY_WIND_CURRENT
	hotkey_keys = list("V")

/datum/keybinding/xeno/grab
	name = "Grab"
	full_name = "Dragon: Grab"
	description = "After a windup, firmly grab an nearby marine in front of you and prevent them from moving away."
	keybind_signal = COMSIG_XENOABILITY_GRAB
	hotkey_keys = list("B")

/datum/keybinding/xeno/scorched_land
	name = "Scorched Land"
	full_name = "Dragon: Scorched Land"
	description = "While flying, blast a line of fire in a direction."
	keybind_signal = COMSIG_XENOABILITY_SCORCHED_LAND
	hotkey_keys = list("G")

