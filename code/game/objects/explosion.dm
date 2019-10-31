//TODO: Flash range does nothing currently

//A very crude linear approximatiaon of pythagoras theorem.
/proc/cheap_pythag(dx, dy)
	dx = abs(dx); dy = abs(dy);
	if(dx>=dy)	return dx + (0.5*dy)	//The longest side add half the shortest side approximates the hypotenuse
	else		return dy + (0.5*dx)

/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, z_transfer = FALSE, flame_range = 0)
	INVOKE_ASYNC(GLOBAL_PROC, /proc/do_explosion, epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, z_transfer, flame_range)

/proc/do_explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, z_transfer = FALSE, flame_range = 0)
	epicenter = get_turf(epicenter)
	if(!epicenter) return

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)
	//playsound(epicenter, 'sound/effects/explosionfar.ogg', 75, 1, round(devastation_range*2,1) )
	//playsound(epicenter, "explosion", 100, 1, round(devastation_range,1) )

// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.

// Stereo users will also hear the direction of the explosion!

// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.

// 3/7/14 will calculate to 80 + 35
	var/far_dist = 0
	far_dist += heavy_impact_range * 5
	far_dist += devastation_range * 20
	var/frequency = GET_RANDOM_FREQ
	for(var/mob/M in GLOB.player_list)
		// Double check for client
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && M_turf.z == epicenter.z)
				var/dist = get_dist(M_turf, epicenter)
				// If inside the blast radius + world.view - 2
				if(dist <= round(max_range + world.view - 2, 1))
					if(devastation_range > 0)
						M.playsound_local(epicenter, get_sfx("explosion"), 75, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound
					else
						M.playsound_local(epicenter, get_sfx("explosion_small"), 75, 1, frequency, falloff = 5)

					//You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.

				else if(dist <= far_dist)
					var/far_volume = CLAMP(far_dist, 30, 50) // Volume is based on explosion size and dist
					far_volume += (dist <= far_dist * 0.5 ? 75 : 75) // add 50 volume if the mob is pretty close to the explosion
					if(devastation_range > 0)
						M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)
					else
						M.playsound_local(epicenter, 'sound/effects/explosionsmallfar.ogg', far_volume, 1, frequency, falloff = 5)

	var/close = trange(world.view + round(devastation_range, 1), epicenter)
	var/sound/S = sound('sound/effects/explosionfar.ogg', channel = open_sound_channel())
	//To all distanced mobs play a different sound
	for(var/mob/M in GLOB.mob_list)
		if(M.z != epicenter.z)
			continue

		if(M in close)
			continue

		if(isliving(M))
			var/mob/living/L = M
			if(L.ear_deaf > 0 || isspaceturf(L.loc))
				continue

		SEND_SOUND(M, S)


	if(adminlog)
		log_explosion("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in [AREACOORD(epicenter)].")
		if(!is_centcom_level(epicenter.z))
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in [ADMIN_VERBOSEJMP(epicenter)].")

	//postpone processing for a bit
	var/postponeCycles = max(round(devastation_range / 8), 1)
	SSlighting.postpone(postponeCycles)
	SSmachines.postpone(postponeCycles)

	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/E = new/datum/effect_system/explosion()
		E.set_up(1, 0, epicenter)
		E.start()

	var/x0 = epicenter.x
	var/y0 = epicenter.y

	for(var/turf/T in trange(max_range, epicenter))
		var/dist = cheap_pythag(T.x - x0,T.y - y0)

		if(dist < devastation_range)		dist = 1
		else if(dist < heavy_impact_range)	dist = 2
		else if(dist < light_impact_range)	dist = 3
		else if(dist < flame_range)			dist = 4
		else								continue

		if(T == epicenter) // Ensures explosives detonating from bags trigger other explosives in that bag
			T.ex_act(dist)
			var/list/items = list()
			for(var/I in T)
				var/atom/A = I
				if(A.prevent_content_explosion())
					continue
				items += A.GetAllContents()
			for(var/O in items)
				var/atom/A = O
				if(QDELETED(A))
					continue
				A.ex_act(dist)

		if(dist > 0)
			T.ex_act(dist)
			for(var/i in T)
				var/atom/movable/AM = i
				if(QDELETED(AM))
					continue
				AM.ex_act(dist)


		//------- TURF FIRES -------

		if(T)
			if(dist < flame_range && prob(40) && !isspaceturf(T))
				var/obj/effect/particle_effect/fire/F = new /obj/effect/particle_effect/fire(T)
				if(istype(F))
					F.life = rand(6,10)

	sleep(8)

	SSmachines.makepowernets()

	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in trange(range, epicenter))
		tile.ex_act(2)

