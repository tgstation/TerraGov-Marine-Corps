/datum/xeno_caste/hivelord
	caste_name = "Hivelord"
	display_name = "Hivelord"
	upgrade_name = "Young"
	caste_desc = "A builder of REALLY BIG hives."
	caste_type_path = /mob/living/carbon/Xenomorph/Hivelord
	tier = 2
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 50

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	deevolves_to = /mob/living/carbon/Xenomorph/Drone

	evolves_to = list(/mob/living/carbon/Xenomorph/Defiler)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor_deflection = 10

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky)

	// *** Pheromones *** //
	aura_strength = 2 //Hivelord's aura is not extremely strong, but better than Drones.
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/hivelord/mature
	upgrade_name = "Mature"
	caste_desc = "A builder of REALLY BIG hives. It looks a little more dangerous."
	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = 0.3

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 60

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky)

	// *** Pheromones *** //
	aura_strength = 2.6

/datum/xeno_caste/hivelord/elder
	upgrade_name = "Elder"
	caste_desc = "A builder of REALLY BIG hives. It looks pretty strong."
	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = 0.2

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 63

	// *** Health *** //
	max_health = 290

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 18

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky)

	// *** Pheromones *** //
	aura_strength = 2.9

/datum/xeno_caste/hivelord/ancient
	upgrade_name = "Ancient"
	caste_desc = "An extreme construction machine. It seems to be building walls..."
	ancient_message = "You are the builder of walls. Ensure that the marines are the ones who pay for them."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 1200
	plasma_gain = 65

	// *** Health *** //
	max_health = 300

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/sticky)

	// *** Pheromones *** //
	aura_strength = 3

/mob/living/carbon/Xenomorph/Hivelord
	caste_base_type = /mob/living/carbon/Xenomorph/Hivelord
	name = "Hivelord"
	desc = "A huge ass xeno covered in weeds! Oh shit!"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hivelord Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 200
	pixel_x = -16
	old_x = -16
	speed = 0.4
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	var/speed_activated = 0
	tier = 2
	upgrade = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin/hivelord,
		/datum/action/xeno_action/activable/transfer_plasma/improved,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/build_tunnel,
		/datum/action/xeno_action/toggle_speed,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/xeno_spit
		)



/mob/living/carbon/Xenomorph/Hivelord/movement_delay()
	. = ..()

	if(speed_activated)
		if(locate(/obj/effect/alien/weeds) in loc)
			. -= 1.5

/mob/living/carbon/Xenomorph/Hivelord/Initialize()
	. = ..()
	update_spits()
