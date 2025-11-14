/datum/xeno_caste/spitter
	caste_name = "Spitter"
	display_name = "Spitter"
	upgrade_name = ""
	caste_desc = "Gotta dodge!"
	base_strain_type = /mob/living/carbon/xenomorph/spitter
	caste_type_path = /mob/living/carbon/xenomorph/spitter
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "spitter" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 925
	plasma_gain = 40

	// *** Health *** //
	max_health = 360

	// *** Evolution *** //
	evolution_threshold = 225
	upgrade_threshold = TIER_TWO_THRESHOLD

	deevolves_to = /datum/xeno_caste/sentinel

	// *** Flags *** //
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_RIDE_CRUSHER
	caste_traits = list(TRAIT_CAN_VENTCRAWL)

	// *** Defense *** //
	soft_armor = list(MELEE = 25, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 0, BIO = 20, FIRE = 35, ACID = 20)

	// *** Minimap Icon *** //
	minimap_icon = "spitter"

	// *** Ranged Attack *** //
	spit_delay = 0.5 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/medium) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.

	acid_spray_duration = 10 SECONDS
	acid_spray_damage_on_hit = 45
	acid_spray_damage = 20
	acid_spray_structure_damage = 45

	// *** Abilities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/activable/xeno/spray_acid/line,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/acid_sweat,
		/datum/mutation_upgrade/spur/hit_and_run,
		/datum/mutation_upgrade/veil/wet_claws
	)

/datum/xeno_caste/spitter/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/spitter/primordial
	upgrade_name = "Primordial"
	caste_desc = "Master of ranged combat, this xeno knows no equal."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "Our suppression is unmatched! Let nothing show its head!"
	caste_flags = CASTE_EVOLUTION_ALLOWED|CASTE_ACID_BLOOD|CASTE_MUTATIONS_ALLOWED

	spit_delay = 0.3 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/auto, /datum/ammo/xeno/acid/medium)

/datum/xeno_caste/spitter/globadier
	caste_type_path = /mob/living/carbon/xenomorph/spitter/globadier
	upgrade_name = ""
	caste_name = "Globadier"
	display_name = "Globadier"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "A mutated variant of a spitter. It carries round globs of acid on its back"

	// *** Melee Attacks *** //
	melee_damage = 18

	// *** Speed *** //
	speed = -0.8

	// *** Health *** //
	max_health = 320

	// *** Ablities *** //
	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/toss_grenade,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/xeno_action/acid_mine,
		/datum/action/ability/xeno_action/acid_mine/gas_mine,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/self_explosion,
		/datum/mutation_upgrade/spur/blood_grenades,
		/datum/mutation_upgrade/veil/repurposed_capacity
	)

/datum/xeno_caste/spitter/globadier/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/spitter/globadier/primordial
	upgrade_name = "Primordial"
	caste_desc = "A master of area control, covered in strange globulets."
	primordial_message = "Let no cover guard our enemies."
	upgrade = XENO_UPGRADE_PRIMO

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/toss_grenade,
		/datum/action/ability/activable/xeno/scatter_spit,
		/datum/action/ability/xeno_action/acid_mine,
		/datum/action/ability/xeno_action/acid_mine/gas_mine,
		/datum/action/ability/activable/xeno/acid_rocket,
	)
