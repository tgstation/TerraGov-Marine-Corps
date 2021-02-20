/mob/living/carbon/human/Life()
	. = ..()

	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.


	//update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	if(!HAS_TRAIT(src, TRAIT_STASIS))
		if(stat != DEAD)

			// Increase germ_level regularly
			if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
				germ_level++


			//blood
			handle_blood()

			if(stat == CONSCIOUS && getToxLoss() >= 45 && nutrition > 20)
				vomit()

			handle_shock()

			handle_pain()

			//In case we want them to do something unique every life cycle, like twitch or moan, or whatever.
			species.handle_unique_behavior(src)

		else //Dead
			if(!undefibbable && timeofdeath && life_tick > 5)
				dead_ticks ++
				if(timeofdeath < 5 || check_tod(src) || !is_revivable())	//We are dead beyond revival, or we're junk mobs spawned like the clowns on the clown shuttle
					set_undefibbable()
				else
					med_hud_set_status()

	stabilize_body_temperature() //Body temperature adjusts itself (self-regulation) (even when dead)

	//Handle temperature/pressure differences between body and environment
	handle_environment() //Optimized a good bit.


/mob/living/carbon/human/proc/set_undefibbable()
	undefibbable = TRUE
	SSmobs.stop_processing(src) //Last round of processing.

	if(CHECK_BITFIELD(status_flags, XENO_HOST))
		var/obj/item/alien_embryo/parasite = locate(/obj/item/alien_embryo) in src
		if(parasite) //The larva cannot survive without a host.
			qdel(parasite)
		DISABLE_BITFIELD(status_flags, XENO_HOST)

	med_hud_set_status()
