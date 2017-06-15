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
	var/datum/gas_mixture/environment = loc.return_air()

	if(life_tick % 30 == 15)
		hud_updateflag = 1022

	voice = GetVoice()

	//No need to update all of these procs if the guy is dead.
	if(!in_stasis)
		if(stat != DEAD)
			if(air_master.current_cycle % 4 == 2 || failed_last_breath || (health < config.health_threshold_crit)) //First, resolve location and get a breath
				breathe() //Only try to take a breath every 4 ticks, unless suffocating

			else //Still give containing object the chance to interact
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)

			//Mutations and radiation
			handle_mutations_and_radiation()

			//Chemicals in the body
			handle_chemicals_in_body()

			//Disabilities
			handle_disabilities()

			//Organs and blood
			handle_organs()
			handle_blood()
			stabilize_body_temperature() //Body temperature adjusts itself (self-regulation)

			//Random events (vomiting etc)
			handle_random_events()

			handle_virus_updates()

			//stuff in the stomach
			handle_stomach()

			//effects of being grabbed aggressively by another mob
			if(pulledby && pulledby.grab_level)
				handle_grabbed()

			handle_shock()

			handle_pain()

			handle_medical_side_effects()

			//In case we want them to do something unique every life cycle, like twitch or moan, or whatever.
			species.handle_unique_behavior(src)
	else
		handle_stasis_bag()

	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > revive_grace_period))	//We are dead beyond revival, or we're junk mobs spawned like the clowns on the clown shuttle
		if(defib_icon_flick) //However, we have one last task to accomplish before cutting the HUD updates forever
			handle_defib_flick()
		return //We go ahead and process them 5 times for HUD images and other stuff though.

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment) //Optimized a good bit.

	//Status updates, death etc.
	handle_regular_status_updates() //Optimized a bit
	update_canmove()

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	handle_regular_hud_updates()

	pulse = handle_pulse()

	//Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()
