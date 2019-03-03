/mob/living/carbon
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/list/stomach_contents = list()

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick

	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.
	//Active emote/pose
	var/pose = null

	var/failed_last_breath = FALSE //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/oxygen_alert = 0
	var/co2_alert = 0
	var/phoron_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/temperature_alert = 0

	var/pulse = PULSE_NORM	//current pulse level
	var/butchery_progress = 0
	var/list/internal_organs = list()

	var/drunkenness = 0 //Overall drunkenness - check handle_status_effects() in life.dm for effects

	var/rotate_on_lying = 1

	var/halloss = 0		//Hallucination damage. 'Fake' damage obtained through hallucinating or the holodeck. Sleeping should cause it to wear off.

	var/traumatic_shock = 0
	var/shock_stage = 0

	var/acid_process_cooldown = null //Variable to store the last world time the person was exposed to acid, in order to make it temporarily invulnerable to it for a time..

	//Stagger vars
	var/slowdown = 0 //Temporary penalty on movement. Regenerates each tick.
	var/stagger = 0 //Temporary inability to use special actions; hurts accuracy. Regenerates each tick.
