/datum/xeno_caste/spitter
	caste_name = "Spitter"
	display_name = "Spitter"
	upgrade_name = "Young"
	caste_desc = "Ptui!"
	caste_type_path = /mob/living/carbon/Xenomorph/Spitter
	tier = 2
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 30 

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 25

	// *** Health *** //
	max_health = 180

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	evolves_to = list(/mob/living/carbon/Xenomorph/Boiler)
	deevolves_to = /mob/living/carbon/Xenomorph/Sentinel 

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 20 

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/acid/heavy) //Gotta give them their own version of heavy acid; kludgy but necessary as 100 plasma is way too costly.

/datum/xeno_caste/spitter/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged damage dealer. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 35 

	// *** Speed *** //
	speed = -0.6

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 30

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 25

	// *** Ranged Attack *** //
	spit_delay = 2.0 SECONDS

	acid_delay = 30 SECONDS //30 second delay on acid spray. Reduced by -3/-2/-1 per upgrade.

/datum/xeno_caste/spitter/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged damage dealer. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.7

	// *** Plasma *** //
	plasma_max = 1100
	plasma_gain = 33

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 30

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS

/datum/xeno_caste/spitter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A ranged destruction machine."
	ancient_message = "You are a master of ranged stuns and damage. Go fourth and generate salt."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 1150
	plasma_gain = 35

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 45

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS

/mob/living/carbon/Xenomorph/Spitter
	caste_base_type = /mob/living/carbon/Xenomorph/Spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Spitter Walking"
	health = 180
	maxHealth = 180
	plasma_stored = 150
	speed = -0.5
	pixel_x = 0
	old_x = 0
	tier = 2
	upgrade = 0
	acid_cooldown = 0
	
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

