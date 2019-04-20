/mob/living/carbon
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/list/stomach_contents = list()

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
					  // life should decrease this by 1 every tick

	var/obj/item/handcuffed //Whether or not the mob is handcuffed
	var/obj/item/legcuffed  //Same as handcuffs but for legs. Bear traps use this.
	//Active emote/pose
	var/pose = null

	var/failed_last_breath = FALSE //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/oxygen_alert = 0
	var/phoron_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0

	var/pulse = PULSE_NORM	//current pulse level
	var/list/internal_organs = list()

	var/drunkenness = 0 //Overall drunkenness - check handle_status_effects() in life.dm for effects

	var/rotate_on_lying = TRUE

	var/halloss = 0		//Hallucination damage. 'Fake' damage obtained through hallucinating or the holodeck. Sleeping should cause it to wear off.

	var/traumatic_shock = 0
	var/shock_stage = 0

	var/acid_process_cooldown //Variable to store the last world time the person was exposed to acid, in order to make it temporarily invulnerable to it for a time..

	//Stagger vars
	var/slowdown = 0 //Temporary penalty on movement. Regenerates each tick.
	var/stagger = 0 //Temporary inability to use special actions; hurts accuracy. Regenerates each tick.

	var/disabilities = 0	//Carbon
	var/monkeyizing			//Carbon
	var/losebreath = 0		//Carbon
	var/nutrition = 400		//Carbon

	var/obj/item/back //Human/Monkey
	var/obj/item/tank/internal = null//Human/Monkey

	var/datum/dna/dna //Carbon
	var/list/viruses = list()
	//see: setup.dm for list of mutations