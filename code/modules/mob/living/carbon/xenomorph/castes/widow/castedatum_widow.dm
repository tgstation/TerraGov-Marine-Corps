/datum/xeno_caste/widow
	caste_name = "Widow"
	display_name = "Widow"
	upgrade_name = ""
	caste_desc = "You don't think you've seen a tarantula this giant before."
	caste_type_path = /mob/living/carbon/xenomorph/widow

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "widow"

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 55

	// *** Health *** //
	max_health = 450

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = list(/mob/living/carbon/xenomorph/hunter, /mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/puppeteer)

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 10, FIRE = 15, ACID = 10)

	// *** Minimap Icon *** //
	minimap_icon = "widow"

	// *** Widow Abilities *** //
	max_spiderlings = 5

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/web_spit,
		/datum/action/xeno_action/burrow,
		/datum/action/xeno_action/activable/leash_ball,
		/datum/action/xeno_action/create_spiderling,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/attach_spiderlings,
		/datum/action/xeno_action/activable/cannibalise,
		/datum/action/xeno_action/activable/spiderling_mark,
	)

/datum/xeno_caste/widow/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/wall_speedup, WIDOW_SPEED_BONUS)
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/widow)

/datum/xeno_caste/widow/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/wall_speedup, WIDOW_SPEED_BONUS)
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/widow)

/datum/xeno_caste/widow/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/widow/primordial
	upgrade_name = "Primordial"
	caste_desc = "At times, life is just like a web. You fall, and a spider called accident, at the center, takes you to hell."
	primordial_message = "We weave the threads of fate that our victims life hangs from."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/activable/web_spit,
		/datum/action/xeno_action/burrow,
		/datum/action/xeno_action/activable/leash_ball,
		/datum/action/xeno_action/create_spiderling,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/attach_spiderlings,
		/datum/action/xeno_action/activable/cannibalise,
		/datum/action/xeno_action/activable/spiderling_mark,
		/datum/action/xeno_action/activable/web_hook,
	)
