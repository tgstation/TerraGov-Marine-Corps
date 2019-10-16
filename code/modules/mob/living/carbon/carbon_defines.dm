/mob/living/carbon
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/list/stomach_contents = list()

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
						// life should decrease this by 1 every tick

	var/obj/item/restraints/handcuffs/handcuffed //Whether or not the mob is handcuffed
	var/obj/item/restraints/legcuffs/legcuffed  //Same as handcuffs but for legs. Bear traps use this.

	var/failed_last_breath = FALSE //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/oxygen_alert = FALSE
	var/phoron_alert = FALSE
	var/fire_alert = FALSE
	var/pressure_alert = FALSE

	var/list/internal_organs = list()

	var/drunkenness = 0 //Overall drunkenness - check handle_status_effects() in life.dm for effects

	var/rotate_on_lying = TRUE

	var/halloss = 0		//Hallucination damage. 'Fake' damage obtained through hallucinating or the holodeck. Sleeping should cause it to wear off.

	var/traumatic_shock = 0
	var/shock_stage = 0

	//Stagger vars
	var/slowdown = 0 //Temporary penalty on movement. Regenerates each tick.
	var/stagger = 0 //Temporary inability to use special actions; hurts accuracy. Regenerates each tick.

	var/losebreath = 0
	var/nutrition = 400

	var/obj/item/back //Human/Monkey
	var/obj/item/tank/internal = null//Human/Monkey

	var/blood_type
	blood_volume = BLOOD_VOLUME_NORMAL

	var/overeatduration = 0		// How long this guy is overeating

	var/afk_timer_id
