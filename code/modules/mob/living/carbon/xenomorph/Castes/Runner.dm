/datum/xeno_caste/runner
	caste_name = "Runner"
	display_name = "Runner"
	upgrade_name = "Young"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	caste_type_path = /mob/living/carbon/Xenomorph/Runner
	tier = 1
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_delay = -4 

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -1.8

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 1

	// *** Health *** //
	max_health = 100

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/Xenomorph/Hunter) 

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 5

	// *** Ranged Attack *** //
	charge_type = 1 //Pounce - Runner
	pounce_delay = 3.5 SECONDS

/datum/xeno_caste/runner/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_delay = -4 

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1.9

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 2

	// *** Health *** //
	max_health = 120

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 10

	// *** Ranged Attack *** //
	pounce_delay = 3.5 SECONDS

/datum/xeno_caste/runner/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 35
	attack_delay = -4 

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -2.0

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 2

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 10

	// *** Ranged Attack *** //
	pounce_delay = 3.0 SECONDS

/datum/xeno_caste/runner/ancient
	upgrade_name = "Ancient"
	caste_desc = "Not what you want to run into in a dark alley. It looks fucking deadly."
	ancient_message = "You are the fastest assassin of all time. Your speed is unmatched."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35
	attack_delay = -4 

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -2.1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 2

	// *** Health *** //
	max_health = 160

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 10

	// *** Ranged Attack *** //
	pounce_delay = 3.0 SECONDS

/mob/living/carbon/Xenomorph/Runner
	caste_base_type = /mob/living/carbon/Xenomorph/Runner
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	speed = -1.8
	flags_pass = PASSTABLE
	tier = 1
	upgrade = 0
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/toggle_savage,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
