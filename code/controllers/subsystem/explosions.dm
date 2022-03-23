#define EXPLOSION_THROW_SPEED 1
GLOBAL_LIST_EMPTY(explosions)

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = INIT_ORDER_EXPLOSIONS
	priority = FIRE_PRIORITY_EXPLOSIONS
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/cost_lowTurf = 0
	var/cost_medTurf = 0
	var/cost_highTurf = 0
	var/cost_flameturf = 0

	var/cost_throwTurf = 0

	var/cost_lowMovAtom = 0
	var/cost_medMovAtom = 0
	var/cost_highMovAtom = 0


	var/list/lowTurf = list()
	var/list/medTurf = list()
	var/list/highTurf = list()
	var/list/flameturf = list()

	var/list/throwTurf = list()

	var/list/lowMovAtom = list()
	var/list/medMovAtom = list()
	var/list/highMovAtom = list()

	var/currentpart = SSEXPLOSIONS_TURFS


/datum/controller/subsystem/explosions/stat_entry(msg)
	msg += "C:{"
	msg += "LT:[round(cost_lowTurf,1)]|"
	msg += "MT:[round(cost_medTurf,1)]|"
	msg += "HT:[round(cost_highTurf,1)]|"
	msg += "FT:[round(cost_flameturf,1)]||"

	msg += "LO:[round(cost_lowMovAtom,1)]|"
	msg += "MO:[round(cost_medMovAtom,1)]|"
	msg += "HO:[round(cost_highMovAtom,1)]|"

	msg += "TO:[round(cost_throwTurf,1)]"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[length(lowTurf)]|"
	msg += "MT:[length(medTurf)]|"
	msg += "HT:[length(highTurf)]|"
	msg += "FT:[length(flameturf)]||"

	msg += "LO:[length(lowMovAtom)]|"
	msg += "MO:[length(medMovAtom)]|"
	msg += "HO:[length(highMovAtom)]|"

	msg += "TO:[length(throwTurf)]"

	msg += "} "
	..(msg)


#define SSEX_TURF "turf"
#define SSEX_OBJ "obj"


/proc/dyn_explosion(turf/epicenter, power, flash_range, adminlog = TRUE, ignorecap = TRUE, flame_range = 0, silent = FALSE, smoke = TRUE, animate = FALSE)
	if(!power)
		return
	var/range = 0
	range = round((2 * power)**GLOB.DYN_EX_SCALE)
	explosion(epicenter, round(range * 0.25), round(range * 0.5), round(range), flash_range*range, adminlog, ignorecap, flame_range*range, silent, smoke, animate)

// Using default dyn_ex scale:
// 100 explosion power is a (5, 10, 20) explosion.
// 75 explosion power is a (4, 8, 17) explosion.
// 50 explosion power is a (3, 7, 14) explosion.
// 25 explosion power is a (2, 5, 10) explosion.
// 10 explosion power is a (1, 3, 6) explosion.
// 5 explosion power is a (0, 1, 3) explosion.
// 1 explosion power is a (0, 0, 1) explosion.

/proc/explosion(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range = 0, throw_range, adminlog = TRUE, silent = FALSE, smoke = FALSE, small_animation = FALSE)
	return SSexplosions.explode(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range, throw_range, adminlog, silent, smoke, small_animation)

/datum/controller/subsystem/explosions/proc/explode(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range, throw_range, adminlog, silent, smoke, small_animation)
	epicenter = get_turf(epicenter)
	if(!epicenter)
		return

	if(small_animation)
		new /obj/effect/temp_visual/explosion(epicenter)

	if(isnull(flash_range))
		flash_range = devastation_range

	if(isnull(throw_range))
		throw_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range, throw_range)
	var/started_at = REALTIMEOFDAY
	if(adminlog)
		log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [loc_name(epicenter)]")
		if(is_mainship_level(epicenter.z))
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in [ADMIN_VERBOSEJMP(epicenter)]")

	if(max_range >= 6 || heavy_impact_range)
		new /obj/effect/temp_visual/shockwave(epicenter, max_range)
	// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
	// Stereo users will also hear the direction of the explosion!

	// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
	// 3/7/14 will calculate to 80 + 35

	var/far_dist = 0
	far_dist += heavy_impact_range * 5
	far_dist += devastation_range * 20

	if(!silent)
		var/frequency = GET_RAND_FREQUENCY
		var/sound/explosion_sound = sound(get_sfx("explosion"))
		var/sound/far_explosion_sound = sound(get_sfx("explosion_distant"))
		var/sound/creak_sound = sound(get_sfx("explosion_creak"))

		for(var/MN in GLOB.player_list)
			var/mob/M = MN
			// Double check for client
			var/turf/M_turf = get_turf(M)
			if(M_turf && M_turf.z == epicenter.z)
				var/dist = get_dist(M_turf, epicenter)
				var/baseshakeamount
				if(orig_max_distance - dist > 0)
					baseshakeamount = sqrt((orig_max_distance - dist)*0.1)
				// If inside the blast radius + world.view - 2
				if(dist <= round(max_range + world.view - 2, 1))
					M.playsound_local(epicenter, null, 100, 1, frequency, falloff = 5, S = explosion_sound)
					if(is_mainship_level(epicenter.z))
						M.playsound_local(epicenter, null, 40, 1, frequency, falloff = 5, S = creak_sound)//ship groaning under explosion effect
					if(baseshakeamount > 0)
						shake_camera(M, 15, clamp(baseshakeamount, 0, 5))
				// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
				else if(dist <= far_dist)
					var/far_volume = clamp(far_dist, 30, 60) // Volume is based on explosion size and dist
					far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
					M.playsound_local(epicenter, null, far_volume, 1, frequency, falloff = 5, S = far_explosion_sound)
					if(is_mainship_level(epicenter.z))
						M.playsound_local(epicenter, null, far_volume*3, 1, frequency, falloff = 5, S = creak_sound)//ship groaning under explosion effect
					if(baseshakeamount > 0)
						shake_camera(M, 7, clamp(baseshakeamount*0.15, 0, 1.5))

	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/E
		if(smoke)
			E = new /datum/effect_system/explosion/smoke
		else
			E = new
		E.set_up(epicenter)
		E.start()

	//flash mobs
	if(flash_range)
		for(var/mob/living/carbon/carbon_viewers in viewers(flash_range, epicenter))
			carbon_viewers.flash_act()

	var/list/turfs_in_range = block(
		locate(
			max(epicenter.x - max_range, 1),
			max(epicenter.y - max_range, 1),
			epicenter.z
			),
		locate(
			min(epicenter.x + max_range, world.maxx),
			min(epicenter.y + max_range, world.maxy),
			epicenter.z
			)
		)

	if(devastation_range > 0)
		highTurf[epicenter] += list(epicenter)
	else if(heavy_impact_range > 0)
		medTurf[epicenter] += list(epicenter)
	else if(light_impact_range > 0)
		lowTurf[epicenter] += list(epicenter)
	else
		if(flame_range > 0) //this proc shouldn't be used for flames only, but here we are
			if(usr)
				to_chat(usr, span_narsiesmall("Please don't use explosions for flames-only, use flame_radius()"))
			flameturf += turfs_in_range
		if(throw_range > 0) //admemes, what have you done
			if(usr)
				to_chat(usr, span_narsie("Stop using explosions for memes!"))
			for(var/t in turfs_in_range)
				var/turf/throw_turf = t
				throwTurf[throw_turf] += list(epicenter)
				throwTurf[throw_turf][epicenter] = list(throw_range, get_dir(epicenter, throw_turf))
		return //Our job here is done.

	if(flame_range)
		flameturf += epicenter

	var/current_exp_block = epicenter.density ? epicenter.explosion_block : 0
	for(var/obj/blocking_object in epicenter)
		if(!blocking_object.density)
			continue
		current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(0) : blocking_object.explosion_block ) //0 is the result of get_dir between two atoms on the same tile.

	var/list/turfs_by_dist = list()
	turfs_by_dist[epicenter] = current_exp_block
	turfs_in_range[epicenter] = current_exp_block

	throwTurf[epicenter] += list(epicenter)
	throwTurf[epicenter][epicenter] = list(max_range, 0) //Random direction.

/*
We'll store how much each turf blocks the explosion's movement in turfs_in_range[turf] and how much movement is needed to reach it in turfs_by_dist[turf].
This way we'll be able to draw the explosion's expansion path without having to waste time processing the edge turfs, scanning their contents.
*/

	for(var/t in (turfs_in_range - epicenter))
		if(turfs_by_dist[t]) //Already processed.
			continue
		var/turf/affected_turf = t
		var/dist = turfs_in_range[epicenter]
		var/turf/expansion_wave_loc = epicenter

		do
			var/expansion_dir = get_dir(expansion_wave_loc, affected_turf)
			if(ISDIAGONALDIR(expansion_dir)) //If diagonal we'll try to choose the easy path, even if it might be longer. Damn, we're lazy.
				var/turf/step_NS = get_step(expansion_wave_loc, expansion_dir & (NORTH|SOUTH))
				if(!turfs_in_range[step_NS])
					current_exp_block = step_NS.density ? step_NS.explosion_block : 0
					for(var/obj/blocking_object in step_NS)
						if(!blocking_object.density)
							continue
						current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
					turfs_in_range[step_NS] = current_exp_block

				var/turf/step_EW = get_step(expansion_wave_loc, expansion_dir & (EAST|WEST))
				if(!turfs_in_range[step_EW])
					current_exp_block = step_EW.density ? step_EW.explosion_block : 0
					for(var/obj/blocking_object in step_EW)
						if(!blocking_object.density)
							continue
						current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
					turfs_in_range[step_EW] = current_exp_block

				if(turfs_in_range[step_NS] < turfs_in_range[step_EW])
					expansion_wave_loc = step_NS
				else if(turfs_in_range[step_NS] > turfs_in_range[step_EW])
					expansion_wave_loc = step_EW
				else if(abs(expansion_wave_loc.x - affected_turf.x) < abs(expansion_wave_loc.y - affected_turf.y)) //Both directions offer the same resistance. Lets check if the direction pends towards either cardinal.
					expansion_wave_loc = step_NS
				else //Either perfect diagonal, in which case it doesn't matter, or leaning towards the X axis.
					expansion_wave_loc = step_EW
			else
				expansion_wave_loc = get_step(expansion_wave_loc, expansion_dir)

			dist++

			if(isnull(turfs_in_range[expansion_wave_loc]))
				current_exp_block = expansion_wave_loc.density ? expansion_wave_loc.explosion_block : 0
				for(var/obj/blocking_object in expansion_wave_loc)
					if(!blocking_object.density)
						continue
					current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(get_dir(epicenter, expansion_wave_loc)) : blocking_object.explosion_block )
				turfs_in_range[expansion_wave_loc] = current_exp_block

			if(isnull(turfs_by_dist[expansion_wave_loc]) || turfs_by_dist[expansion_wave_loc] > dist) //Either not processed yet or we found a better path.
				turfs_by_dist[expansion_wave_loc] = dist

			dist += turfs_in_range[expansion_wave_loc]

			if(dist >= max_range)
				break //Explosion ran out of gas, no use continuing.
		while(expansion_wave_loc != affected_turf)

		if(isnull(turfs_by_dist[affected_turf]))
			turfs_by_dist[affected_turf] = 9999 //Edge turfs, they don't even border the explosion. We won't bother calculating their distance as it's irrelevant.

	for(var/t in (turfs_by_dist - epicenter))
		var/dist = turfs_by_dist[t]
		if(devastation_range > dist)
			highTurf[t] += list(epicenter)
		else if(heavy_impact_range > dist)
			medTurf[t] += list(epicenter)
		else if(light_impact_range > dist)
			lowTurf[t] += list(epicenter)
		if(flame_range > dist)
			flameturf += t
		if(throw_range > dist)
			throwTurf[t] += list(epicenter)
			throwTurf[t][epicenter] =  list(max_range - dist, get_dir(epicenter, t))

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_EXPLOSION, epicenter, devastation_range, heavy_impact_range, light_impact_range, (REALTIMEOFDAY - started_at) * 0.1)

/datum/controller/subsystem/explosions/proc/wipe_turf(turf/T)
	highTurf -= T
	medTurf -= T
	lowTurf -= T
	flameturf -= T
	throwTurf -= T

/datum/controller/subsystem/explosions/fire(resumed = FALSE)
	if(!(length(lowTurf) || length(medTurf) || length(highTurf) || length(flameturf) || length(throwTurf) || length(lowMovAtom) || length(medMovAtom) || length(highMovAtom)))
		return
	var/timer
	Master.current_ticklimit = TICK_LIMIT_RUNNING //force using the entire tick if we need it.

	if(currentpart == SSEXPLOSIONS_TURFS)
		currentpart = SSEXPLOSIONS_MOVABLES

		timer = TICK_USAGE_REAL
		var/list/low_turf = lowTurf
		lowTurf = list()
		for(var/t in low_turf)
			var/turf/turf_to_explode = t
			if(QDELETED(turf_to_explode))
				continue
			for(var/explosion_source in low_turf[turf_to_explode])
				turf_to_explode.ex_act(EXPLODE_LIGHT)
				if(QDELETED(turf_to_explode))
					break
		cost_lowTurf = MC_AVERAGE(cost_lowTurf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_turf = medTurf
		medTurf = list()
		for(var/t in med_turf)
			var/turf/turf_to_explode = t
			if(QDELETED(turf_to_explode))
				continue
			for(var/explosion_source in med_turf[turf_to_explode])
				turf_to_explode.ex_act(EXPLODE_HEAVY)
				if(QDELETED(turf_to_explode))
					break
		cost_medTurf = MC_AVERAGE(cost_medTurf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/high_turf = highTurf
		highTurf = list()
		for(var/t in high_turf)
			var/turf/turf_to_explode = t
			if(QDELETED(turf_to_explode))
				continue
			for(var/explosion_source in high_turf[turf_to_explode])
				turf_to_explode.ex_act(EXPLODE_DEVASTATE)
				if(QDELETED(turf_to_explode))
					break
		cost_highTurf = MC_AVERAGE(cost_highTurf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		for(var/flamed_turf in flameturf)
			var/obj/flamer_fire/pre_existing_flame = locate(/obj/flamer_fire) in flamed_turf
			if(pre_existing_flame)
				qdel(pre_existing_flame)
			new /obj/flamer_fire(flamed_turf, max(1, rand(0, 25) + rand(0, 25)), max(1, rand(0, 25) + rand(0, 25)))
		flameturf.Cut()
		cost_flameturf = MC_AVERAGE(cost_flameturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		if(length(low_turf) || length(med_turf) || length(high_turf))
			Master.laggy_byond_map_update_incoming()

	if(currentpart == SSEXPLOSIONS_MOVABLES)
		currentpart = SSEXPLOSIONS_THROWS

		timer = TICK_USAGE_REAL
		var/list/high_mov_atom = highMovAtom
		highMovAtom = list()
		for(var/o in high_mov_atom)
			var/obj/object_to_explode = o
			if(QDELETED(object_to_explode))
				continue
			for(var/explosion_source in high_mov_atom[object_to_explode])
				object_to_explode.ex_act(EXPLODE_DEVASTATE)
				if(QDELETED(object_to_explode))
					break
		cost_highMovAtom = MC_AVERAGE(cost_highMovAtom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/med_mov_atom = medMovAtom
		medMovAtom = list()
		for(var/o in med_mov_atom)
			var/obj/object_to_explode = o
			if(QDELETED(object_to_explode))
				continue
			for(var/explosion_source in med_mov_atom[object_to_explode])
				object_to_explode.ex_act(EXPLODE_HEAVY)
				if(QDELETED(object_to_explode))
					break
		cost_medMovAtom = MC_AVERAGE(cost_medMovAtom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

		timer = TICK_USAGE_REAL
		var/list/low_mov_atom = lowMovAtom
		lowMovAtom = list()
		for(var/o in low_mov_atom)
			var/obj/object_to_explode = o
			if(QDELETED(object_to_explode))
				continue
			for(var/explosion_source in low_mov_atom[object_to_explode])
				object_to_explode.ex_act(EXPLODE_LIGHT)
				if(QDELETED(object_to_explode))
					break
		cost_lowMovAtom = MC_AVERAGE(cost_lowMovAtom, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


	if(currentpart == SSEXPLOSIONS_THROWS)
		currentpart = SSEXPLOSIONS_TURFS
		timer = TICK_USAGE_REAL
		var/list/throw_turf = throwTurf
		throwTurf = list()
		for(var/t in throw_turf)
			var/turf/affected_turf = t
			if(QDELETED(affected_turf))
				continue
			for(var/am in affected_turf)
				var/atom/movable/thing_to_throw = am
				if(thing_to_throw.anchored || thing_to_throw.move_resist == INFINITY)
					continue

				for(var/throw_source in throw_turf[affected_turf])
					thing_to_throw.throw_at(
						get_ranged_target_turf(
							thing_to_throw,
							throw_turf[affected_turf][throw_source][2] ? throw_turf[affected_turf][throw_source][2] : pick(GLOB.alldirs), // Direction
							throw_turf[affected_turf][throw_source][1] // Distance
							),
						throw_turf[affected_turf][throw_source][1], // Distance
						EXPLOSION_THROW_SPEED,
						null, //Thrower
						TRUE //Spin
					)
		cost_throwTurf = MC_AVERAGE(cost_throwTurf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

	currentpart = SSEXPLOSIONS_TURFS
