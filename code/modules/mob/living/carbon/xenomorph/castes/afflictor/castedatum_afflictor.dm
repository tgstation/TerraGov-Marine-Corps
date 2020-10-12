/datum/xeno_caste/afflictor
	caste_name = "Afflictor"
	display_name = "Afflictor"
	upgrade_name = ""
	caste_desc = "A small larva-like creatue with a spiked tail."
	caste_type_path = /mob/living/carbon/xenomorph/afflictor
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "larva" //used to match appropriate wound overlays

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 4

	// *** Health *** //
	max_health = 210

	// *** Evolution *** //
	evolution_threshold = 80
	upgrade_threshold = 50

	evolves_to = list(/mob/living/carbon/xenomorph/Defiler)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = XENO_BOMB_RESIST_0, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 0)

	// *** Ranged Attack *** //
	charge_type = CHARGE_TYPE_SMALL
	pounce_delay = 35.0 SECONDS

	// *** Abilities *** ///
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/xenohide,
		/datum/action/xeno_action/activable/pounce/afflictor,
		/datum/action/xeno_action/select_reagent,
		/datum/action/xeno_action/activable/reagent_sting/afflictor,
		/datum/action/xeno_action/xeno_camouflage,
		)

/datum/xeno_caste/afflictor/young
	upgrade_name = "Young"

	upgrade = XENO_UPGRADE_ZERO
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
	)

/datum/xeno_caste/afflictor/mature
	upgrade_name = "Mature"
	caste_desc = "A small larva-like creatue with a spiked tail. It looks a little more dangerous."
	ancient_message = "Our gands evolve. We are able to synthesize Praelide!"

	upgrade = XENO_UPGRADE_ONE
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		/datum/reagent/toxin/xeno_praelide,
	)
	// *** Speed *** //
	speed = -1

	// *** Plasma *** //
	plasma_max = 180
	plasma_gain = 6

	// *** Health *** //
	max_health = 230

	// *** Evolution *** //
	upgrade_threshold = 100

	// *** Defense *** //
	soft_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = XENO_BOMB_RESIST_0, "bio" = 3, "rad" = 3, "fire" = 15, "acid" = 3)

	// *** Ranged Attack *** //
	pounce_delay = 30.0 SECONDS

/datum/xeno_caste/afflictor/elder
	upgrade_name = "Elder"
	caste_desc = "A small larva-like creatue with a spiked tail. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 16


	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1.2

	// *** Plasma *** //
	plasma_max = 220
	plasma_gain = 8

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	soft_armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = XENO_BOMB_RESIST_0, "bio" = 5, "rad" = 5, "fire" = 20, "acid" = 5)

	// *** Ranged Attack *** //
	pounce_delay = 25.0 SECONDS

/datum/xeno_caste/afflictor/ancient
	upgrade_name = "Ancient"
	caste_desc = "The ultimate meta predator."
	ancient_message = "We are the ultimate apothecary. Decay Accelerant available. All will fall before our sting."
	upgrade = XENO_UPGRADE_THREE
	available_reagents_define = list(
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		/datum/reagent/toxin/xeno_decaytoxin_catalyst,
		/datum/reagent/toxin/xeno_praelide,
	)
	// *** Melee Attacks *** //
	melee_damage = 16


	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -1.4

	// *** Plasma *** //
	plasma_max = 260
	plasma_gain = 10

	// *** Health *** //
	max_health = 270

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	soft_armor = list("melee" = 24, "bullet" = 24, "laser" = 24, "energy" = 124, "bomb" = XENO_BOMB_RESIST_0, "bio" = 7, "rad" = 7, "fire" = 24, "acid" = 7)

	// *** Ranged Attack *** //
	pounce_delay = 25.0 SECONDS
