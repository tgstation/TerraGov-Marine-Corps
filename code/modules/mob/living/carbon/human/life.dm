//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/human/Life()

	set invisibility = 0
	set background = 1

	if(monkeyizing)
		return
	if(!loc) //Fixing a null error that occurs when the mob isn't found in the world -- TLE
		return

	..()

	blinded = null
	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.

	//TODO: seperate this out
	//update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	voice = GetVoice()
	if(stat == DEAD && species.name == "Zombie" && regenZ)
		handle_chemicals_in_body()
		return
	//No need to update all of these procs if the guy is dead.
	if(!in_stasis)
		if(stat != DEAD)
			if(life_tick % 2 == 0 || failed_last_breath || (health < config.health_threshold_crit)) //First, resolve location and get a breath
				breathe() //Only try to take a breath every 4 ticks, unless suffocating

			else //Still give containing object the chance to interact
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src)

			// Moved this from /mob/living/carbon/Life()
			// Increase germ_level regularly
			if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
				germ_level++

			//Mutations and radiation
			handle_mutations_and_radiation()

			//Chemicals in the body
			handle_chemicals_in_body()

			//Disabilities
			handle_disabilities()

			//Organs and blood
			handle_organs()
			handle_blood()

			//Random events (vomiting etc)
			handle_random_events()

			//effects of being grabbed aggressively by another mob
			if(pulledby && pulledby.grab_level)
				handle_grabbed()

			handle_shock()

			handle_pain()

			handle_medical_side_effects()

			//In case we want them to do something unique every life cycle, like twitch or moan, or whatever.
			species.handle_unique_behavior(src)

		else //Dead
			if(!undefibbable)
				if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > revive_grace_period))	//We are dead beyond revival, or we're junk mobs spawned like the clowns on the clown shuttle
					undefibbable = TRUE
					med_hud_set_status()

	else
		handle_stasis_bag()


	stabilize_body_temperature() //Body temperature adjusts itself (self-regulation) (even when dead)

	//Handle temperature/pressure differences between body and environment
	handle_environment() //Optimized a good bit.

	//Status updates, death etc.
	handle_regular_status_updates() //Optimized a bit

	updatehealth()

	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	//name = get_visible_name() //moved out to the relevant places to be updated on demand.

	handle_regular_hud_updates()

	pulse = handle_pulse()

	//Grabbing
	for(var/obj/item/grab/G in src)
		G.process()
