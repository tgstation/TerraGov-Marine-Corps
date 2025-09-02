/datum/xeno_caste/crusher
	caste_name = "Crusher"
	display_name = "Crusher"
	upgrade_name = ""
	caste_desc = "A huge tanky xenomorph."
	base_strain_type = /mob/living/carbon/xenomorph/crusher
	caste_type_path = /mob/living/carbon/xenomorph/crusher

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "crusher" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 25
	attack_delay = 8

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 520
	plasma_gain = 40

	// *** Health *** //
	max_health = 445

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/bull

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA
	caste_traits = list(TRAIT_STOPS_TANK_COLLISION)

	// *** Defense *** //
	soft_armor = list(MELEE = 90, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 130, BIO = 100, FIRE = 50, ACID = 100)

	// *** Sunder *** //
	sunder_multiplier = 0.85

	// *** Minimap Icon *** //
	minimap_icon = "crusher"

	// *** Crusher Abilities *** //
	crest_toss_distance = 6

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/stomp,
		/datum/action/ability/xeno_action/ready_charge,
		/datum/action/ability/activable/xeno/cresttoss,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/tough_rock,
		/datum/mutation_upgrade/spur/earthquake,
		/datum/mutation_upgrade/veil/friendly_chest
	)

/datum/xeno_caste/crusher/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	xenomorph.RegisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK, TYPE_PROC_REF(/mob/living/carbon/xenomorph, grabbed_self_attack))

/datum/xeno_caste/crusher/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/crusher)
	xenomorph.UnregisterSignal(xenomorph, COMSIG_GRAB_SELF_ATTACK)

/datum/xeno_caste/crusher/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/crusher/primordial
	upgrade_name = "Primordial"
	caste_desc = "Behemoth of the hive. Nothing will remain in its way"
	primordial_message = "We are an unstoppable force. Crush. Kill. Destroy."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/stomp,
		/datum/action/ability/xeno_action/ready_charge,
		/datum/action/ability/activable/xeno/cresttoss,
		/datum/action/ability/activable/xeno/advance,
	)
