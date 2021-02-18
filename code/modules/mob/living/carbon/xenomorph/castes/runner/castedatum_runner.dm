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
	melee_damage = 17
	attack_delay = 6

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 17

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 2

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 60

	evolves_to = list(
		/mob/living/carbon/xenomorph/hunter,
		/mob/living/carbon/xenomorph/bull,
	)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 0)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_SMALL
	pounce_delay = 13 SECONDS

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/toggle_savage,
		/datum/action/xeno_action/evasion,
	)

/datum/xeno_caste/runner/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/runner/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 17

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 3

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 120

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 3, "rad" = 3, "fire" = 10, "acid" = 3)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/runner/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, four-legged terror, but weak in sustained combat. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 21

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 21

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 3

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 15, "acid" = 5)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/runner/ancient
	upgrade_name = "Ancient"
	caste_desc = "Not what you want to run into in a dark alley. It looks extremely deadly."
	ancient_message = "We are the fastest assassin of all time. Our speed is unmatched."
	upgrade = XENO_UPGRADE_THREE
	wound_type = "runner" //used to match appropriate wound overlays

	savage_cooldown = 30 SECONDS

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Tackle *** //
	tackle_damage = 21

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 3

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 19, "bullet" = 19, "laser" = 19, "energy" = 19, "bomb" = XENO_BOMB_RESIST_0, "bio" = 7, "rad" = 7, "fire" = 19, "acid" = 7)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/roony
	caste_name = "Roony"
	display_name = "Roony"
	upgrade_name = ""
	caste_desc = "A fast, four-legged adorable, out-of-place terror, but weak in sustained combat."
	caste_type_path = /mob/living/carbon/xenomorph/roony
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "runner" //used to match appropriate wound overlays

	gib_anim = "gibbed-a-corpse-runner"
	gib_flick = "gibbed-a-runner"

	// *** Melee Attacks *** //
	melee_damage = 17
	attack_delay = 6

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 17

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 2

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 60

	evolves_to = list(
		/mob/living/carbon/xenomorph/hunter,
		/mob/living/carbon/xenomorph/bull,
	)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 5, "acid" = 0)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_SMALL
	pounce_delay = 13 SECONDS

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/toggle_savage,
		/datum/action/xeno_action/evasion,
	)

/datum/xeno_caste/roony/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/roony/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, four-legged adorable, out-of-place terror, but weak in sustained combat. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 17

	// *** Speed *** //
	speed = -1.3

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 3

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 120

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = XENO_BOMB_RESIST_0, "bio" = 3, "rad" = 3, "fire" = 10, "acid" = 3)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/roony/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, four-legged adorable, out-of-place terror, but weak in sustained combat. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 21

	savage_cooldown = 30 SECONDS

	// *** Tackle *** //
	tackle_damage = 21

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 3

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 15, "acid" = 5)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS

/datum/xeno_caste/roony/ancient
	upgrade_name = "Ancient"
	caste_desc = "Not what you want to run into in a dark alley. It looks extremely adorable, yet it thirsts for your blood!"
	ancient_message = "We are the fastest assassin of all time. Our speed is unmatched."
	upgrade = XENO_UPGRADE_THREE
	wound_type = "runner" //used to match appropriate wound overlays

	savage_cooldown = 30 SECONDS

	// *** Melee Attacks *** //
	melee_damage = 21

	// *** Tackle *** //
	tackle_damage = 21

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 3

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 19, "bullet" = 19, "laser" = 19, "energy" = 19, "bomb" = XENO_BOMB_RESIST_0, "bio" = 7, "rad" = 7, "fire" = 19, "acid" = 7)

	// *** Ranged Attack *** //
	pounce_delay = 13 SECONDS
