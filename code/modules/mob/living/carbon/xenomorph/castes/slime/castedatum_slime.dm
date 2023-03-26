/datum/xeno_caste/slime
	caste_name = "Slime"
	display_name = "Slime"
	upgrade_name = ""
	caste_desc = "A creature whose body is made of an oozy substance that melts anything it touches."
	caste_type_path = /mob/living/carbon/xenomorph/slime

	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = null
	melee_damage = 14
	melee_damage_type = BURN
	speed = -0.1
	plasma_max = 125
	plasma_gain = 12
	max_health = 225
	evolution_threshold = 80
	upgrade_threshold = TIER_ONE_YOUNG_THRESHOLD
	evolves_to = list(
		/mob/living/carbon/xenomorph/hunter,
		/mob/living/carbon/xenomorph/wraith,
	)
	can_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL, TRAIT_STAGGER_RESISTANT)
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 0, FIRE = 0, ACID = 0)
	sunder_max = 0
	minimap_icon = "warlock"
	additional_stacks = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/slime_pounce,
		/datum/action/xeno_action/spread_tendrils,
		/datum/action/xeno_action/activable/extend_tendril,
	)

/datum/xeno_caste/slime/on_caste_applied(mob/xenomorph)
	. = ..()
	RegisterSignal(xenomorph, COMSIG_MOVABLE_MOVED, PROC_REF(move_bonus))
	RegisterSignal(xenomorph, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(attack_bonus))

/datum/xeno_caste/slime/on_caste_removed(mob/xenomorph)
	. = ..()
	UnregisterSignal(xenomorph, list(COMSIG_MOVABLE_MOVED, COMSIG_XENOMORPH_ATTACK_LIVING))

/datum/xeno_caste/slime/proc/move_bonus()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = src
	new /obj/effect/xenomorph/spray(get_turf(xeno_owner), SLIME_MOVEMENT_ACID_DURATION, SLIME_MOVEMENT_ACID_DAMAGE)
	for(var/obj/O in get_turf(xeno_owner))
		O.acid_spray_act(xeno_owner)

/datum/xeno_caste/slime/proc/attack_bonus(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	if(living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = living_target.has_status_effect(STATUS_EFFECT_INTOXICATED)
		debuff.add_stacks(debuff.stacks)
		return
	living_target.apply_status_effect(STATUS_EFFECT_INTOXICATED, additional_stacks)

/datum/xeno_caste/slime/young
	upgrade_name = "Young"
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/slime/mature
	upgrade_name = "Mature"
	upgrade = XENO_UPGRADE_ONE
	plasma_max = 150
	plasma_gain = 15
	max_health = 250
	upgrade_threshold = TIER_ONE_MATURE_THRESHOLD

/datum/xeno_caste/slime/elder
	upgrade_name = "Elder"
	upgrade = XENO_UPGRADE_TWO
	melee_damage = 15
	speed = -0.2
	plasma_max = 175
	plasma_gain = 17
	max_health = 275
	upgrade_threshold = TIER_ONE_ELDER_THRESHOLD
	soft_armor = list(MELEE = 55, BULLET = 55, LASER = 0, ENERGY = 0, BOMB = 55, BIO = 0, FIRE = 0, ACID = 0)
	additional_stacks = 1

/datum/xeno_caste/slime/ancient
	upgrade_name = "Ancient"
	ancient_message = "Let us consume everything."
	upgrade = XENO_UPGRADE_THREE
	melee_damage = 16
	speed = -0.3
	plasma_max = 200
	plasma_gain = 20
	max_health = 300
	upgrade_threshold = TIER_ONE_ANCIENT_THRESHOLD
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 0, FIRE = 0, ACID = 0)
	additional_stacks = 2

/datum/xeno_caste/slime/primordial
	upgrade_name = "Primordial"
	ancient_message = "All will be eroded to oblivion."
	upgrade = XENO_UPGRADE_FOUR
	melee_damage = 18
	speed = -0.3
	plasma_max = 200
	plasma_gain = 20
	max_health = 300
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 0, FIRE = 0, ACID = 0)
	additional_stacks = 3
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/slime_pounce,
		/datum/action/xeno_action/spread_tendrils,
		/datum/action/xeno_action/activable/extend_tendril,
		/datum/action/xeno_action/toxic_burst,
	)
