/datum/xeno_caste/afflictor
	caste_name = "Afflictor"
	display_name = "Afflictor"
	upgrade_name = ""
	caste_desc = "A dark, slender creature with scythe-like claws, coated with some kind of liquid."
	caste_type_path = /mob/living/carbon/xenomorph/afflictor
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "afflictor" //used to match appropriate wound overlays


	// *** Melee Attacks *** //
	melee_damage = 10

	// *** Tackle *** //
	tackle_damage = 20

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 4

	// *** Health *** //
	max_health = 210

	// *** Evolution *** //
	evolution_threshold = 180
	upgrade_threshold = 120

	evolves_to = list(/mob/living/carbon/xenomorph/Defiler)
	deevolves_to = /mob/living/carbon/xenomorph/sentinel

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 10, "rad" = 10, "fire" = 15, "acid" = 10)

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/select_reagent,
		/datum/action/xeno_action/activable/reagent_slash,
		/datum/action/xeno_action/xeno_camouflage,
	)

/datum/xeno_caste/afflictor/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
	)

/datum/xeno_caste/afflictor/mature
	upgrade_name = "Mature"
	caste_desc = "A dark, slender creature with scythe-like claws, coated with some kind of liquid. It looks a little more dangerous."
	ancient_message = "Our gands evolve. We are able to synthesize Transvitox!"

	upgrade = XENO_UPGRADE_ONE
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
	)
	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 180
	plasma_gain = 6

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	upgrade_threshold = 240

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 15, "rad" = 15, "fire" = 20, "acid" = 15)

/datum/xeno_caste/afflictor/elder
	upgrade_name = "Elder"
	caste_desc = "A dark, slender creature with scythe-like claws, coated with some kind of liquid. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
	)

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 220
	plasma_gain = 8

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 18, "fire" = 25, "acid" = 18)

/datum/xeno_caste/afflictor/ancient
	upgrade_name = "Ancient"
	caste_desc = "It appears to be changing colours."
	ancient_message = "We are the ultimate apothecary. All will fall before our poisons. Praelyx available."
	upgrade = XENO_UPGRADE_THREE
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		/datum/reagent/toxin/xeno_praelyx,
	)

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 260
	plasma_gain = 10

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 480

	// *** Defense *** //
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = XENO_BOMB_RESIST_0, "bio" = 18, "rad" = 18, "fire" = 30, "acid" = 18)
