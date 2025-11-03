/datum/xeno_caste/boiler
	caste_name = "Boiler"
	display_name = "Boiler"
	upgrade_name = ""
	caste_desc = "Gross!"
	base_strain_type = /mob/living/carbon/xenomorph/boiler
	caste_type_path = /mob/living/carbon/xenomorph/boiler

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "boiler" //used to match appropriate wound overlays

	gib_flick = "gibbed-a-boiler"

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 380

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_THRESHOLD

	deevolves_to = /datum/xeno_caste/spitter

	// *** Flags *** //
	caste_flags = CASTE_ACID_BLOOD|CASTE_EVOLUTION_ALLOWED|CASTE_MUTATIONS_ALLOWED
	can_flags = parent_type::can_flags|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 45, ENERGY = 45, BOMB = 0, BIO = 35, FIRE = 45, ACID = 35)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS

	// *** Minimap Icon *** //
	minimap_icon = "boiler"

	// *** Boiler Abilities *** //
	max_ammo = 7
	bomb_strength = 1.3
	// Spit types are handled in Toggle Bombard Type, one of Boiler's abilities.

	acid_spray_duration = 10 SECONDS
	acid_spray_damage = 30
	acid_spray_damage_on_hit = 60
	acid_spray_structure_damage = 45

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/xeno_action/create_boiler_bomb,
		/datum/action/ability/activable/xeno/bombard,
		/datum/action/ability/xeno_action/toggle_long_range,
		/datum/action/ability/xeno_action/toggle_bomb,
		/datum/action/ability/activable/xeno/spray_acid/line/boiler,
		/datum/action/ability/activable/xeno/acid_shroud,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/staggered_panic,
		/datum/mutation_upgrade/shell/thick_containment,
		/datum/mutation_upgrade/shell/dim_containment,
		/datum/mutation_upgrade/spur/gaseous_spray,
		/datum/mutation_upgrade/spur/hip_fire,
		/datum/mutation_upgrade/spur/rapid_fire,
		/datum/mutation_upgrade/veil/acid_trail,
		/datum/mutation_upgrade/veil/chemical_mixing,
		/datum/mutation_upgrade/veil/binoculars
	)

/datum/xeno_caste/boiler/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/boiler/sizzler/normal
	upgrade = XENO_UPGRADE_NORMAL

/datum/xeno_caste/boiler/primordial
	upgrade_name = "Primordial"
	caste_desc = "A horrendously effective alien siege engine."
	upgrade = XENO_UPGRADE_PRIMO
	primordial_message = "We have refined the art of bombardement to perfection. End them before they can utter a desperate plea."
	// Primordial Upgrade: Corrosive Lance and Neurotoxin Lance are now selectable spit types in Toggle Bombard Type, one of Boiler's abilities.

/datum/xeno_caste/boiler/sizzler
	caste_type_path = /mob/living/carbon/xenomorph/boiler/sizzler
	upgrade_name = ""
	caste_name = "Sizzler Boiler"
	display_name = "Sizzler"
	upgrade = XENO_UPGRADE_BASETYPE
	caste_desc = "Gross! The large creature is venting a hot steam."

		// *** Ranged Attack *** //
	spit_delay = 0.75 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/airburst)

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/xeno_action/smokescreen_spit,
		/datum/action/ability/activable/xeno/spray_acid/line/boiler,
		/datum/action/ability/xeno_action/steam_rush,
	)

	mutations = list(
		/datum/mutation_upgrade/shell/gaseous_trail,
		/datum/mutation_upgrade/spur/neurotoxin_swap,
		/datum/mutation_upgrade/veil/fast_acid
	)

/datum/xeno_caste/boiler/sizzler/primordial
	upgrade_name = "Primordial"
	upgrade = XENO_UPGRADE_PRIMO
	caste_desc = "A living steam engine. Its body spews hot gas."
	primordial_message = "Our steam is ceaseless. We are the hive's living engine. May our enemies perish in our scalding radiance."

	actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/corrosive_acid/strong,
		/datum/action/ability/activable/xeno/xeno_spit,
		/datum/action/ability/xeno_action/smokescreen_spit,
		/datum/action/ability/activable/xeno/spray_acid/line/boiler,
		/datum/action/ability/xeno_action/steam_rush,
		/datum/action/ability/activable/xeno/high_pressure_spit,
	)
