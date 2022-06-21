/mob/living/carbon
	gender = MALE
	buckle_flags = CAN_BE_BUCKLED|BUCKLE_PREVENTS_PULL
	var/datum/species/species //Contains icon generation and language information, set during New().

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
						// life should decrease this by 1 every tick

	var/obj/item/restraints/handcuffs/handcuffed //Whether or not the mob is handcuffed

	///Tracks whether we can breath right now. Used for a hud icon and for message generation.
	var/oxygen_alert = FALSE
	var/phoron_alert = FALSE
	var/fire_alert = FALSE
	var/pressure_alert = FALSE

	var/list/internal_organs = list()

	var/drunkenness = 0 //Overall drunkenness - check handle_status_effects() in life.dm for effects

	var/rotate_on_lying = TRUE

	var/traumatic_shock = 0
	var/shock_stage = 0

	///Causes breathing to fail and generate oxyloss instead of recover it, even outside crit.
	var/losebreath = 0
	var/nutrition = NUTRITION_WELLFED

	var/obj/item/back //Human //todo move to human level
	var/obj/item/tank/internal = null//Human //todo move to human level

	var/blood_type
	blood_volume = BLOOD_VOLUME_NORMAL

	var/overeatduration = 0		// How long this guy is overeating

	// halucination vars
	var/hal_screwyhud = SCREWYHUD_NONE
	var/next_hallucination = 0

	/// % Chance of exploding on death, incremented by total damage taken if not initially zero.
	var/gib_chance = 0
