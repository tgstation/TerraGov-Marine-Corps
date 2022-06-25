/datum/xeno_caste/boiler
	caste_name = "Boiler"
	display_name = "Boiler"
	upgrade_name = ""
	caste_desc = "Gross!"

	caste_type_path = /mob/living/carbon/xenomorph/boiler

	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "boiler" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 17

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_YOUNG_THRESHOLD

	deevolves_to = /mob/living/carbon/xenomorph/spitter

	// *** Darksight *** ///
	conscious_see_in_dark = 20

	// *** Flags *** //
	caste_flags = CASTE_ACID_BLOOD
	can_flags =CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER|CASTE_CAN_BECOME_KING

	// *** Defense *** //
	soft_armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 0, "bio" = 30, "rad" = 30, "fire" = 40, "acid" = 30)

	// *** Ranged Attack *** //
	spit_delay = 4 SECONDS
	spit_types = list(/datum/ammo/xeno/boiler_gas, /datum/ammo/xeno/boiler_gas/corrosive)

	// *** Minimap Icon *** //
	minimap_icon = "boiler"

	// *** Boiler Abilities *** //
	max_ammo = 4
	bomb_strength = 1 //Multiplier to the effectiveness of the boiler glob.
	bomb_delay = 32 SECONDS
	ammo_multiplier = 1.5 SECONDS

	acid_spray_duration = 10 SECONDS
	acid_spray_damage = 16
	acid_spray_damage_on_hit = 35
	acid_spray_structure_damage = 45

	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/create_boiler_bomb,
		/datum/action/xeno_action/activable/bombard,
		/datum/action/xeno_action/toggle_long_range,
		/datum/action/xeno_action/toggle_bomb,
		/datum/action/xeno_action/activable/spray_acid/line/boiler,
	)

/datum/xeno_caste/boiler/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/boiler/mature
	upgrade_name = "Mature"
	caste_desc = "Some sort of abomination. It looks a little more dangerous."
	upgrade = XENO_UPGRADE_ONE

	// *** Speed *** //
	speed = 0.2

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_MATURE_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = 0, "bio" = 33, "rad" = 33, "fire" = 45, "acid" = 33)

	// *** Ranged Attack *** //
	spit_delay = 3 SECONDS

	acid_spray_damage_on_hit = 39
	acid_spray_structure_damage = 53

	// *** Boiler Abilities *** //
	max_ammo = 5
	bomb_strength = 1.1

	bomb_delay = 32 SECONDS

/datum/xeno_caste/boiler/elder
	upgrade_name = "Elder"
	caste_desc = "Some sort of abomination. It looks pretty strong."
	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ELDER_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 45, "laser" = 45 , "energy" = 45, "bomb" = 0, "bio" = 35, "rad" = 35, "fire" = 45, "acid" = 35)

	// *** Ranged Attack *** //
	spit_delay = 2 SECONDS

	acid_spray_damage_on_hit = 43
	acid_spray_structure_damage = 61

	// *** Boiler Abilities *** //
	max_ammo = 6
	bomb_strength = 1.2

	bomb_delay = 32 SECONDS

/datum/xeno_caste/boiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "A devastating piece of alien artillery."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "We are the master of ranged artillery. Let's bring death from above."

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 325

	// *** Evolution *** //
	upgrade_threshold = TIER_THREE_ANCIENT_THRESHOLD

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = 0, "bio" = 37, "rad" = 37, "fire" = 45, "acid" = 37)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS

	acid_spray_damage_on_hit = 47
	acid_spray_structure_damage = 69

	// *** Boiler Abilities *** //
	max_ammo = 7
	bomb_strength = 1.3

	bomb_delay = 27 SECONDS

/datum/xeno_caste/boiler/primordial
	upgrade_name = "Primordial"
	caste_desc = "A horrendously effective alien siege engine."
	upgrade = XENO_UPGRADE_FOUR
	primordial_message = "We have refined the art of bombardement to perfection. End them before they can utter a desperate plea."

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 325

	// *** Defense *** //
	soft_armor = list("melee" = 45, "bullet" = 45, "laser" = 45, "energy" = 45, "bomb" = 0, "bio" = 37, "rad" = 37, "fire" = 45, "acid" = 37)

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/boiler_gas, /datum/ammo/xeno/boiler_gas/lance, /datum/ammo/xeno/boiler_gas/corrosive, /datum/ammo/xeno/boiler_gas/corrosive/lance)

	acid_spray_damage_on_hit = 47
	acid_spray_structure_damage = 69

	// *** Boiler Abilities *** //
	max_ammo = 7
	bomb_strength = 1.3

	bomb_delay = 27 SECONDS

	actions = list(
		/datum/action/xeno_action/show_hivestatus,
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/place_acidwell,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/create_boiler_bomb,
		/datum/action/xeno_action/activable/bombard,
		/datum/action/xeno_action/toggle_long_range,
		/datum/action/xeno_action/toggle_bomb,
		/datum/action/xeno_action/activable/spray_acid/line/boiler,
	)
