/datum/xeno_caste/crusher
	caste_name = "Crusher"
	display_name = "Crusher"
	upgrade_name = ""
	caste_desc = "A huge tanky xenomorph."
	caste_type_path = /mob/living/carbon/xenomorph/crusher

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "crusher" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 21
	attack_delay = 8

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 10

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/bull

	// *** Flags *** //
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 70, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 100, "bio" = 80, "rad" = 80, "fire" = 25, "acid" = 80)

	// *** Minimap Icon *** //
	minimap_icon = "crusher"

	// *** Crusher Abilities *** //
	stomp_damage = 45
	crest_toss_distance = 3

	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/stomp,
		/datum/action/xeno_action/ready_charge,
		/datum/action/xeno_action/activable/cresttoss,
	)

/datum/xeno_caste/crusher/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	xenomorph.RegisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK, /mob/living/carbon/xenomorph.proc/grabbed_self_attack)

/datum/xeno_caste/crusher/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	xenomorph.UnregisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK)

/datum/xeno_caste/crusher/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/crusher/mature
	upgrade_name = "Mature"
	caste_desc = "A huge tanky xenomorph. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 15

	// *** Health *** //
	max_health = 345

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 75, "bullet" = 65, "laser" = 65, "energy" = 65, "bomb" = 100, "bio" = 90, "rad" = 90, "fire" = 30, "acid" = 90)

	// *** Abilities *** //
	stomp_damage = 50
	crest_toss_distance = 4

/datum/xeno_caste/crusher/elder
	upgrade_name = "Elder"
	caste_desc = "A huge tanky xenomorph. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 370

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 80, "bullet" = 70, "laser" = 70, "energy" = 70, "bomb" = 100, "bio" = 95, "rad" = 95, "fire" = 35, "acid" = 95)

	// *** Abilities *** //
	stomp_damage = 55
	crest_toss_distance = 5

/datum/xeno_caste/crusher/ancient
	upgrade_name = "Ancient"
	caste_desc = "It always has the right of way."
	ancient_message = "We are the physical manifestation of a Tank. Almost nothing can harm us."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 400

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 90, "bullet" = 75, "laser" = 75, "energy" = 75, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 100)
	// *** Abilities *** //
	stomp_damage = 60
	crest_toss_distance = 6


/datum/xeno_caste/crusher/primordial
	upgrade_name = "Primordial"
	caste_desc = "Behemoth of the hive. Nothing will remain in its way"
	ancient_message = "We are an unstoppable force. Crush. Kill. Destroy."
	upgrade = XENO_UPGRADE_FOUR

	// *** Melee Attacks *** //
	melee_damage = 24

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 30

	// *** Health *** //
	max_health = 400

	// *** Defense *** //
	soft_armor = list("melee" = 90, "bullet" = 75, "laser" = 75, "energy" = 75, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 100)
	// *** Abilities *** //
	stomp_damage = 60
	crest_toss_distance = 6

	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/stomp,
		/datum/action/xeno_action/ready_charge,
		/datum/action/xeno_action/activable/cresttoss,
		/datum/action/xeno_action/activable/advance,
	)
