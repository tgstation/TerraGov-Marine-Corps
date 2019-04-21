//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/human/Life()

	if(monkeyizing)
		return
	if(!loc) //Fixing a null error that occurs when the mob isn't found in the world -- TLE
		return

	..()

	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.


	//TODO: seperate this out
	//update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	voice = GetVoice()
	if(stat == DEAD)
		if(!check_tod())
			SSmobs.stop_processing(src)
	//No need to update all of these procs if the guy is dead.

	if(!in_stasis)
		if(stat != DEAD)

			// Moved this from /mob/living/carbon/Life()
			// Increase germ_level regularly
			if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
				germ_level++

			//Mutations and radiation
			handle_mutations_and_radiation()

			//blood
			handle_blood()

			//Random events (vomiting etc)
			handle_random_events()

			//effects of being grabbed aggressively by another mob
			if(pulledby && pulledby.grab_level)
				handle_grabbed()

			handle_shock()

			handle_pain()

			//In case we want them to do something unique every life cycle, like twitch or moan, or whatever.
			species.handle_unique_behavior(src)

		else //Dead
			if(!undefibbable && timeofdeath && life_tick > 5 && life_tick % 2 == 0)
				if(timeofdeath < 5 || !check_tod())	//We are dead beyond revival, or we're junk mobs spawned like the clowns on the clown shuttle
					undefibbable = TRUE
					med_hud_set_status()
				else if((world.time - timeofdeath) > (CONFIG_GET(number/revive_grace_period) * 0.4) && (world.time - timeofdeath) < (CONFIG_GET(number/revive_grace_period) * 0.8))
					med_hud_set_status()
				else if((world.time - timeofdeath) > (CONFIG_GET(number/revive_grace_period) * 0.8))
					med_hud_set_status()

	stabilize_body_temperature() //Body temperature adjusts itself (self-regulation) (even when dead)

	//Handle temperature/pressure differences between body and environment
	handle_environment() //Optimized a good bit.

	//Update our name based on whether our face is obscured/disfigured
	//name = get_visible_name() //moved out to the relevant places to be updated on demand.

	pulse = handle_pulse()

	//Grabbing
	for(var/obj/item/grab/G in src)
		G.process()
