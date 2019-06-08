/datum/xeno_caste/runner
	caste_name = "Runner"
	display_name = "Runner"
	upgrade_name = ""
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	caste_type_path = /mob/living/carbon/xenomorph/runner
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_delay = 6

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -1.7

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 1

	// *** Health *** //
	max_health = 100

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/xenomorph/hunter)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 5

	// *** Ranged Attack *** //
	charge_type = 1 //Pounce - Runner
	pounce_delay = 3.5 SECONDS

/datum/xeno_caste/runner/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/runner/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1.8

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

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 35

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.9

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
	upgrade = XENO_UPGRADE_THREE
	wound_type = "runner" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -2

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
	