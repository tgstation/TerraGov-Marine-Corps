/datum/xeno_caste/ravager
	caste_name = "Ravager"
	display_name = "Ravager"
	upgrade_name = ""
	caste_desc = "A brutal, devastating front-line attacker."
	caste_type_path = /mob/living/carbon/xenomorph/ravager
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "ravager" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 30
	attack_delay = 7

	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 15
	plasma_regen_limit = 0.5
	plasma_icon_state = "fury"

	// *** Health *** //
	max_health = 350

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/hunter

	// *** Flags *** //
	caste_flags = CASTE_INNATE_PLASMA_REGEN|CASTE_PLASMADRAIN_IMMUNE|CASTE_EVOLUTION_ALLOWED
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_LEADER
	caste_traits = null

	// *** Defense *** //
	soft_armor = list(MELEE = 50, BULLET = 55, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 40, FIRE = 70, ACID = 40)

	// *** Minimap Icon *** //
	minimap_icon = "ravager"

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage,
	)

/datum/xeno_caste/ravager/on_caste_applied(mob/xenomorph)
	. = ..()
	xenomorph.AddElement(/datum/element/plasma_on_attack, 1.5)
	xenomorph.AddElement(/datum/element/plasma_on_attacked, 0.5)

/datum/xeno_caste/ravager/on_caste_removed(mob/xenomorph)
	. = ..()
	xenomorph.RemoveElement(/datum/element/plasma_on_attack, 1.5)
	xenomorph.RemoveElement(/datum/element/plasma_on_attacked, 0.5)

/datum/xeno_caste/ravager/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/ravager/primordial
	upgrade_name = "Primordial"
	caste_desc = "Red like the blood of those that try to stop its rampage."
	primordial_message = "Our frenzy is eternal. Rip and tear, until it is done."
	upgrade = XENO_UPGRADE_PRIMO

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/charge,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/rage,
		/datum/action/ability/xeno_action/vampirism,
	)
