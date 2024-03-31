/mob/living/proc/Life(seconds, times_fired)
	set waitfor = FALSE
	set invisibility = 0

	if((movement_type & FLYING) && !(movement_type & FLOATING))	//TODO: Better floating
		float(on = TRUE)

	if (client)
		var/turf/T = get_turf(src)
		if(!T)
			for(var/obj/effect/landmark/error/E in GLOB.landmarks_list)
				forceMove(E.loc)
				break
			var/msg = "[ADMIN_LOOKUPFLW(src)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
			message_admins(msg)
			send2irc_adminless_only("Mob", msg, R_ADMIN)
			log_game("[key_name(src)] was found to have no .loc with an attached client.")

		// This is a temporary error tracker to make sure we've caught everything
		else if (registered_z != T.z)
#ifdef TESTING
			message_admins("[ADMIN_LOOKUPFLW(src)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
			log_game("Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
	else if (registered_z)
		log_game("Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
		update_z(null)

	if (notransform)
		return
	if(!loc)
		return

	if(!IS_IN_STASIS(src))

		//Mutations and radiation
		handle_mutations_and_radiation()
		//Breathing, if applicable
		handle_breathing(times_fired)
		if(HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			handle_wounds()
			handle_blood()
			handle_embedded_objects()
			heal_wounds(1)

		handle_diseases()// DEAD check is in the proc itself; we want it to spread even if the mob is dead, but to handle its disease-y properties only if you're not.

		if (QDELETED(src)) // diseases can qdel the mob via transformations
			return

		//Random events (vomiting etc)
		handle_random_events()
		//Handle temperature/pressure differences between body and environment
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment)
			handle_environment(environment)

		handle_gravity()

		handle_traits() // eye, ear, brain damages
		handle_status_effects() //all special effects, stun, knockdown, jitteryness, hallucination, sleeping, etc

	update_sneak_invis()
	handle_fire()

	if(machine)
		machine.check_eye(src)

	handle_typing_indicator()

	if(istype(loc, /turf/open/water))
		handle_inwater()

	if(stat != DEAD)
		return 1

/mob/living
	var/last_deadlife

/mob/living/proc/DeadLife()
	set invisibility = 0
	if (notransform)
		return
	if(!loc)
		return
	if(!IS_IN_STASIS(src))
		if(HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			handle_blood()
			handle_embedded_objects()
	update_sneak_invis()
	handle_fire()
	handle_typing_indicator()
	if(istype(loc, /turf/open/water))
		handle_inwater()

/mob/living/proc/handle_breathing(times_fired)
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals
	return

/mob/living/proc/handle_diseases()
	return

/mob/living/proc/handle_random_events()
	//random painstun
	if(!stat && !HAS_TRAIT(src, TRAIT_NOPAINSTUN))
		if(world.time > mob_timers["painstun"] + 600)
			if(getBruteLoss() + getFireLoss() >= (STAEND * 10))
				var/probby = 53 - (STAEND * 2)
				if(!(mobility_flags & MOBILITY_STAND))
					probby = probby - 20
				if(prob(probby))
					mob_timers["painstun"] = world.time
					Immobilize(10)
					emote("painscream")
					visible_message("<span class='warning'>[src] freezes in pain!</span>",
								"<span class='warning'>I'm frozen in pain!</span>")
					sleep(10)
					Stun(110)
					Knockdown(110)

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

/mob/living/proc/handle_fire()
	if(fire_stacks < 0) //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks + 1)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
//		testing("handlefyre0 [src]")
		return TRUE //the mob is no longer on fire, no need to do the rest.
//	testing("handlefyre1 [src]")
	if(fire_stacks > 0)
		adjust_fire_stacks(-0.05) //the fire is slowly consumed
	else
		ExtinguishMob()
		return TRUE //mob was put out, on_fire = FALSE via ExtinguishMob(), no need to update everything down the chain.
//	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
//	if(!G.gases[/datum/gas/oxygen] || G.gases[/datum/gas/oxygen][MOLES] < 1)
//		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
//		return TRUE
	update_fire()
	var/turf/location = get_turf(src)
	location.hotspot_expose(700, 50, 1)

//this updates all special effects: knockdown, druggy, stuttering, etc..
/mob/living/proc/handle_status_effects()
	if(confused)
		confused = max(confused - 1, 0)
	if(slowdown)
		slowdown = max(slowdown - 1, 0)
	if(slowdown <= 0)
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_SLOWDOWN_STATUS)

/mob/living/proc/handle_traits()
	//Eyes
	if(eye_blind)	//blindness, heals slowly over time
		if(HAS_TRAIT_FROM(src, TRAIT_BLIND, EYES_COVERED)) //covering your eyes heals blurry eyes faster
			adjust_blindness(-3)
		else if(!stat && !(HAS_TRAIT(src, TRAIT_BLIND)))
			adjust_blindness(-1)
	else if(eye_blurry)			//blurry eyes heal slowly
		adjust_blurriness(-1)

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_gravity()
	var/gravity = mob_has_gravity()
	update_gravity(gravity)

	if(gravity > STANDARD_GRAVITY)
		gravity_animate()
		handle_high_gravity(gravity)

/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	INVOKE_ASYNC(src, .proc/gravity_pulse_animation)

/mob/living/proc/gravity_pulse_animation()
	animate(get_filter("gravity"), y = 1, time = 10)
	sleep(10)
	animate(get_filter("gravity"), y = 0, time = 10)

/mob/living/proc/handle_high_gravity(gravity)
	if(gravity >= GRAVITY_DAMAGE_TRESHOLD) //Aka gravity values of 3 or more
		var/grav_stregth = gravity - GRAVITY_DAMAGE_TRESHOLD
		adjustBruteLoss(min(grav_stregth,3))
