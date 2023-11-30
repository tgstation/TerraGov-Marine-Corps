



//////////////////////////////////// dropship weapon ammunition ////////////////////////////

/obj/structure/ship_ammo
	icon = 'icons/Marine/mainship_props.dmi'
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
	coverage = 20
	interaction_flags = INTERACT_OBJ_DEFAULT|INTERACT_POWERLOADER_PICKUP_ALLOWED_BYPASS_ANCHOR
	///Time before the ammo impacts
	var/travelling_time = 10 SECONDS
	///type of equipment that accept this type of ammo.
	var/equipment_type
	var/ammo_count
	var/max_ammo_count
	var/ammo_name = "rounds" //what to call the ammo in the ammo transfering message
	var/ammo_id
	///whether the ammo inside this magazine can be transfered to another magazine.
	var/transferable_ammo = FALSE
	///sound played mere seconds before impact
	var/warning_sound = 'sound/machines/hydraulics_2.ogg'
	var/ammo_used_per_firing = 1
	var/point_cost = 0 //how many points it costs to build this with the fabricator, set to 0 if unbuildable.
	///Type of ammo
	var/ammo_type

	///Range of the centre of the explosion
	var/devastating_explosion_range = 0
	///Range of the middle bit of the explosion
	var/heavy_explosion_range = 0
	///Range of the outer radius of the explosion
	var/light_explosion_range = 0
	///Fire radius, for incendiary weapons
	var/fire_range = 0
	///Type of CAS dot indicator effect to be used
	var/cas_effect = /obj/effect/overlay/blinking_laser
	///CAS impact prediction type to use. Explosive, incendiary, etc
	var/prediction_type = CAS_AMMO_HARMLESS


/obj/structure/ship_ammo/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	. = ..()
	if(.)
		return

	if(!attached_clamp.loaded || !istype(attached_clamp.loaded, type))
		return

	var/obj/structure/ship_ammo/SA = attached_clamp.loaded

	if(!SA.transferable_ammo || !SA.ammo_count) //not transferable
		return

	var/transf_amt = min(max_ammo_count - ammo_count, SA.ammo_count)
	if(!transf_amt)
		return

	ammo_count += transf_amt
	SA.ammo_count -= transf_amt
	to_chat(user, span_notice("You transfer [transf_amt] [ammo_name] to [src]."))
	playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
	if(!SA.ammo_count)
		attached_clamp.loaded = null
		attached_clamp.update_icon()
		qdel(SA)


//what to show to the user that examines the weapon we're loaded on.
/obj/structure/ship_ammo/proc/show_loaded_desc(mob/user)
	return "It's loaded with \a [src]."

/obj/structure/ship_ammo/proc/detonate_on(turf/impact, attackdir = NORTH)
	return

//CAS impact prediction.

/// Gets the turfs this ammo type would affect. Attackdir can be left alone if the ammo type is not directional
/obj/structure/ship_ammo/proc/get_turfs_to_impact(turf/epicenter, attackdir = NORTH)
	switch(prediction_type)
		if(CAS_AMMO_EXPLOSIVE)
			return get_explosion_impact(epicenter)
		if(CAS_AMMO_INCENDIARY)
			return filled_turfs(epicenter, fire_range, "circle")

	//If it's CAS_AMMO_HARMLESS, we don't need to do anything

	return //For anything else needed, add a special version of this proc in the subtype


/// "Mini" version of explode() code, returns the tiles that *would* be hit if an explosion were to happen
/obj/structure/ship_ammo/proc/get_explosion_impact(turf/impact)
	var/turf/epicenter = get_turf(impact)
	if(!epicenter)
		return

	var/max_range = max(devastating_explosion_range, heavy_explosion_range, light_explosion_range)

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

	var/current_exp_block = epicenter.density ? epicenter.explosion_block : 0
	for(var/obj/blocking_object in epicenter)
		if(!blocking_object.density)
			continue
		current_exp_block += ( (blocking_object.explosion_block == EXPLOSION_BLOCK_PROC) ? blocking_object.GetExplosionBlock(0) : blocking_object.explosion_block ) //0 is the result of get_dir between two atoms on the same tile.

	var/list/turfs_by_dist = list()
	turfs_by_dist[epicenter] = current_exp_block
	turfs_in_range[epicenter] = current_exp_block

	var/list/turfs_impacted = list(epicenter)
	var/list/outline_turfs_impacted = list()

	for(var/turf/affected_turf AS in turfs_in_range)

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

			if(isnull(turfs_by_dist[expansion_wave_loc]))
				turfs_by_dist[expansion_wave_loc] = dist
				if(devastating_explosion_range > dist || heavy_explosion_range > dist || light_explosion_range > dist)
					turfs_impacted += expansion_wave_loc
				else
					outline_turfs_impacted += expansion_wave_loc
					break //Explosion ran out of gas, no use continuing.

			else if(turfs_by_dist[expansion_wave_loc] > dist)
				turfs_by_dist[expansion_wave_loc] = dist

			dist += turfs_in_range[expansion_wave_loc]

			if(dist >= max_range)
				break //Explosion ran out of gas, no use continuing.

		while(expansion_wave_loc != affected_turf)

		if(isnull(turfs_by_dist[affected_turf]))
			turfs_by_dist[affected_turf] = 9999

	return turfs_impacted

///////////////

//30mm gun

/obj/structure/ship_ammo/cas/heavygun
	name = "\improper 30mm ammo crate"
	icon_state = "30mm_crate"
	desc = "A crate full of 30mm bullets used on the dropship heavy guns. Moving this will require some sort of lifter."
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/heavygun
	travelling_time = 6 SECONDS
	ammo_count = 2000
	max_ammo_count = 2000
	transferable_ammo = TRUE
	ammo_used_per_firing = 200
	point_cost = 100
	///Radius of the square that the bullets will strafe
	var/bullet_spread_range = 2
	///Width of the square we are attacking, so you can make rectangular attacks later
	var/attack_width = 3
	ammo_type = CAS_30MM
	cas_effect = /obj/effect/overlay/blinking_laser/heavygun

/obj/structure/ship_ammo/cas/heavygun/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] round\s."

/obj/structure/ship_ammo/cas/heavygun/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] containing [ammo_count] round\s."

/obj/structure/ship_ammo/cas/heavygun/get_turfs_to_impact(turf/impact, attackdir = NORTH)
	var/turf/beginning = impact
	var/revdir = REVERSE_DIR(attackdir)
	for(var/i=0 to bullet_spread_range)
		beginning = get_step(beginning, revdir)
	var/list/strafelist = list(beginning)
	strafelist += get_step(beginning, turn(attackdir, 90))
	strafelist += get_step(beginning, turn(attackdir, -90)) //Build this list 3 turfs at a time for strafe_turfs
	for(var/b=0 to bullet_spread_range*2)
		beginning = get_step(beginning, attackdir)
		strafelist += beginning
		strafelist += get_step(beginning, turn(attackdir, 90))
		strafelist += get_step(beginning, turn(attackdir, -90))

	return strafelist

/obj/structure/ship_ammo/cas/heavygun/detonate_on(turf/impact, attackdir = NORTH)
	playsound(impact, 'sound/effects/casplane_flyby.ogg', 40)
	strafe_turfs(get_turfs_to_impact(impact, attackdir))

///Takes the top 3 turfs and miniguns them, then repeats until none left
/obj/structure/ship_ammo/cas/heavygun/proc/strafe_turfs(list/strafelist)
	var/turf/strafed
	playsound(strafelist[1], get_sfx("explosion"), 40, 1, 20, falloff = 3)
	for(var/i=1 to attack_width)
		strafed = strafelist[1]
		strafelist -= strafed
		strafed.ex_act(EXPLODE_LIGHT)
		new /obj/effect/temp_visual/heavyimpact(strafed)
		for(var/atom/movable/AM AS in strafed)
			if(QDELETED(AM))
				continue
			//This may seem a bit wacky as we're exploding the turf's content twice, but doing it another way would be even more wacky because of how hard it is to modify explosion damage without adding a whole other explosion type
			AM.ex_act(EXPLODE_LIGHT)

	if(length(strafelist))
		addtimer(CALLBACK(src, PROC_REF(strafe_turfs), strafelist), 2)


/obj/structure/ship_ammo/cas/heavygun/highvelocity
	name = "high-velocity 30mm ammo crate"
	icon_state = "30mm_crate_hv"
	desc = "A crate full of 30mm high-velocity bullets used on the dropship heavy guns. Moving this will require some sort of lifter."
	travelling_time = 3 SECONDS
	point_cost = 225


//railgun
/obj/structure/ship_ammo/railgun
	name = "Railgun Ammo"
	desc = "This is not meant to exist. Moving this will require some sort of lifter."
	icon_state = "30mm_crate_hv"
	icon = 'icons/Marine/mainship_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/minirocket_pod
	ammo_count = 400
	max_ammo_count = 400
	ammo_name = "railgun"
	ammo_used_per_firing = 10
	travelling_time = 0 SECONDS
	transferable_ammo = TRUE
	point_cost = 0
	ammo_type = RAILGUN_AMMO
	devastating_explosion_range = 0
	heavy_explosion_range = 2
	light_explosion_range = 4
	prediction_type = CAS_AMMO_EXPLOSIVE

/obj/structure/ship_ammo/railgun/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range, adminlog = FALSE, color = COLOR_CYAN)//no messaging admin, that'd spam them.
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last railgun has fired and impacted the ground.

/obj/structure/ship_ammo/railgun/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] containing [ammo_count] slug\s."


/obj/structure/ship_ammo/railgun/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] slug\s."

//laser battery

/obj/structure/ship_ammo/cas/laser_battery
	name = "high-capacity laser battery"
	icon_state = "laser_battery"
	desc = "A high-capacity laser battery used to power laser beam weapons. Moving this will require some sort of lifter."
	travelling_time = 1 SECONDS
	ammo_count = 100
	max_ammo_count = 100
	ammo_used_per_firing = 40
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/laser_beam_gun
	ammo_name = "charge"
	transferable_ammo = TRUE
	ammo_used_per_firing = 10
	warning_sound = 'sound/effects/nightvision.ogg'
	point_cost = 150
	///The length of the beam that will come out of when we fire do both ends xxxoxxx where o is where you click
	var/laze_radius = 4
	ammo_type = CAS_LASER_BATTERY
	cas_effect = /obj/effect/overlay/blinking_laser/laser

/obj/structure/ship_ammo/cas/laser_battery/examine(mob/user)
	. = ..()
	. += "It's at [round(100*ammo_count/max_ammo_count)]% charge."


/obj/structure/ship_ammo/cas/laser_battery/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] at [round(100*ammo_count/max_ammo_count)]% charge."

/obj/structure/ship_ammo/cas/laser_battery/get_turfs_to_impact(turf/epicenter, attackdir = NORTH)
	var/turf/beginning = epicenter
	var/turf/end = epicenter
	var/revdir = REVERSE_DIR(attackdir)
	for(var/i=0 to laze_radius)
		beginning = get_step(beginning, revdir)
		end = get_step(end, attackdir)
	return getline(beginning, end)

/obj/structure/ship_ammo/cas/laser_battery/detonate_on(turf/impact, attackdir = NORTH)
	var/list/turf/lazertargets = get_turfs_to_impact(impact, attackdir)
	process_lazer(lazertargets)
	if(!ammo_count)
		QDEL_IN(src, laze_radius+1) //deleted after last laser beam is fired and impact the ground.

///takes the top lazertarget on the stack and fires the lazer at it
/obj/structure/ship_ammo/cas/laser_battery/proc/process_lazer(list/lazertargets)
	laser_burn(lazertargets[1])
	lazertargets -= lazertargets[1]
	if(length(lazertargets))
		INVOKE_NEXT_TICK(src, PROC_REF(process_lazer), lazertargets)

///Lazer ammo acts on the turf passed in
/obj/structure/ship_ammo/cas/laser_battery/proc/laser_burn(turf/T)
	playsound(T, 'sound/effects/pred_vision.ogg', 30, 1)
	for(var/mob/living/L in T)
		L.adjustFireLoss(120)
		L.adjust_fire_stacks(20)
		L.IgniteMob()
	T.ignite(5, 30) //short but intense


//Rockets

/obj/structure/ship_ammo/cas/rocket
	name = "abstract rocket"
	icon_state = "single"
	icon = 'icons/Marine/mainship_props64.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/rocket_pod
	ammo_count = 1
	max_ammo_count = 1
	ammo_name = "rocket"
	ammo_id = ""
	bound_width = 64
	bound_height = 32
	travelling_time = 4 SECONDS
	point_cost = 0
	ammo_type = CAS_MISSILE

/obj/structure/ship_ammo/cas/rocket/detonate_on(turf/impact, attackdir = NORTH)
	qdel(src)


//this one is air-to-air only
/obj/structure/ship_ammo/cas/rocket/widowmaker
	name = "\improper AIM-224 'Widowmaker'"
	desc = "The AIM-224 is the latest in air to air missile technology. Earning the nickname of 'Widowmaker' from various dropship pilots after improvements to its guidence warhead prevents it from being jammed leading to its high kill rate. Not well suited for ground bombardment, but its high velocity makes it reach its target quickly. Moving this will require some sort of lifter."
	icon_state = "single"
	travelling_time = 3 SECONDS //not powerful, but reaches target fast
	ammo_id = ""
	point_cost = 225
	devastating_explosion_range = 2
	heavy_explosion_range = 4
	light_explosion_range = 7
	prediction_type = CAS_AMMO_EXPLOSIVE
	cas_effect = /obj/effect/overlay/blinking_laser/widowmaker

/obj/structure/ship_ammo/cas/rocket/widowmaker/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range)
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/banshee
	name = "\improper AGM-227 'Banshee'"
	desc = "The AGM-227 missile is a mainstay of the overhauled dropship fleet against any mobile or armored ground targets. It's earned the nickname of 'Banshee' from the sudden wail that it emitts right before hitting a target. Useful to clear out large areas. Moving this will require some sort of lifter."
	icon_state = "banshee"
	ammo_id = "b"
	point_cost = 225
	devastating_explosion_range = 2
	heavy_explosion_range = 4
	light_explosion_range = 7
	fire_range = 7
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/banshee

/obj/structure/ship_ammo/cas/rocket/banshee/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range, flame_range = fire_range) //more spread out, with flames
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/keeper
	name = "\improper GBU-67 'Keeper II'"
	desc = "The GBU-67 'Keeper II' is the latest in a generation of laser guided weaponry that spans all the way back to the 20th century. Earning its nickname from a shortening of 'Peacekeeper' which comes from the program that developed its guidance system and the various uses of it during peacekeeping conflicts. Its payload is designed to devastate armored targets. Moving this will require some sort of lifter."
	icon_state = "keeper"
	ammo_id = "k"
	point_cost = 300
	devastating_explosion_range = 4
	heavy_explosion_range = 4
	light_explosion_range = 5
	prediction_type = CAS_AMMO_EXPLOSIVE

/obj/structure/ship_ammo/cas/rocket/keeper/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range) //tighter blast radius, but more devastating near center
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/fatty
	name = "\improper SM-17 'Fatty'"
	desc = "The SM-17 'Fatty' is the most devestating rocket in TGMC arsenal, only second after its big cluster brother in Orbital Cannon. These rocket are also known for highest number of Friendly-on-Friendly incidents due to secondary cluster explosions as well as range of these explosions, TGMC recommends pilots to encourage usage of signal flares or laser for 'Fatty' support. Moving this will require some sort of lifter."
	icon_state = "fatty"
	ammo_id = "f"
	point_cost = 325
	devastating_explosion_range = 2
	heavy_explosion_range = 3
	light_explosion_range = 4
	prediction_type = CAS_AMMO_EXPLOSIVE
	cas_effect = /obj/effect/overlay/blinking_laser/fatty

/obj/structure/ship_ammo/cas/rocket/fatty/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range) //first explosion is small to trick xenos into thinking its a minirocket.
	addtimer(CALLBACK(src, PROC_REF(delayed_detonation), impact), 3 SECONDS)

/**
 * proc/delayed_detonation(turf/impact)
 *
 * this proc is responsable for calculation and executing explosion in cluster like fashion
 * * (turf/impact): targets impacted turf from first explosion
 */

/obj/structure/ship_ammo/cas/rocket/fatty/proc/delayed_detonation(turf/impact)
	var/list/impact_coords = list(list(-3,3),list(0,4),list(3,3),list(-4,0),list(4,0),list(-3,-3),list(0,-4), list(3,-3))
	for(var/i=1 to 8)
		var/list/coords = impact_coords[i]
		var/turf/detonation_target = locate(impact.x+coords[1],impact.y+coords[2],impact.z)
		detonation_target.ceiling_debris_check(2)
		explosion(detonation_target, devastating_explosion_range, heavy_explosion_range, light_explosion_range, adminlog = FALSE)
	qdel(src)

/obj/structure/ship_ammo/cas/rocket/napalm
	name = "\improper XN-99 'Napalm'"
	desc = "The XN-99 'Napalm' is an incendiary rocket used to turn specific targeted areas into giant balls of fire for a long time. Moving this will require some sort of lifter."
	icon_state = "napalm"
	ammo_id = "n"
	point_cost = 250
	devastating_explosion_range = 2
	heavy_explosion_range = 3
	light_explosion_range = 4
	fire_range = 5
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/incendiary

/obj/structure/ship_ammo/cas/rocket/napalm/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range) //relatively weak
	flame_radius(fire_range, impact, 60, 30) //cooking for a long time
	var/datum/effect_system/smoke_spread/phosphorus/warcrime = new
	warcrime.set_up(fire_range + 1, impact, 7)
	warcrime.start()
	qdel(src)


//minirockets

/obj/structure/ship_ammo/cas/minirocket
	name = "mini rocket stack"
	desc = "A pack of explosive laser guided mini rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket"
	icon = 'icons/Marine/mainship_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/cas/weapon/minirocket_pod
	ammo_count = 6
	max_ammo_count = 6
	ammo_name = "minirocket"
	travelling_time = 2 SECONDS
	transferable_ammo = TRUE
	point_cost = 175
	ammo_type = CAS_MINI_ROCKET
	devastating_explosion_range = 0
	heavy_explosion_range = 2
	light_explosion_range = 3
	prediction_type = CAS_AMMO_EXPLOSIVE
	cas_effect = /obj/effect/overlay/blinking_laser/minirocket

/obj/structure/ship_ammo/cas/minirocket/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range, adminlog = FALSE)//no messaging admin, that'd spam them.
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last minirocket has fired and impacted the ground.

/obj/structure/ship_ammo/cas/minirocket/show_loaded_desc(mob/user)
	return "It's loaded with \a [src] containing [ammo_count] minirocket\s."

/obj/structure/ship_ammo/cas/minirocket/examine(mob/user)
	. = ..()
	. += "It has [ammo_count] minirocket\s."


/obj/structure/ship_ammo/cas/minirocket/incendiary
	name = "incendiary mini rocket stack"
	desc = "A pack of laser guided incendiary mini rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket_inc"
	point_cost = 250
	travelling_time = 4 SECONDS
	light_explosion_range = 3 //Slightly weaker than standard minirockets
	fire_range = 3 //Fire range should be the same as the explosion range. Explosion should leave fire, not vice versa
	prediction_type = CAS_AMMO_INCENDIARY
	cas_effect = /obj/effect/overlay/blinking_laser/incendiary

/obj/structure/ship_ammo/cas/minirocket/incendiary/detonate_on(turf/impact, attackdir = NORTH)
	. = ..()
	flame_radius(fire_range, impact)

/obj/structure/ship_ammo/cas/minirocket/smoke
	name = "smoke mini rocket stack"
	desc = "A pack of laser guided screening smoke mini rockets. Moving this will require some sort of lifter."
	icon_state = "minirocket_smoke"
	point_cost = 75
	travelling_time = 4 SECONDS
	cas_effect = /obj/effect/overlay/blinking_laser/smoke
	devastating_explosion_range = 0
	heavy_explosion_range = 0
	light_explosion_range = 2

/obj/structure/ship_ammo/cas/minirocket/smoke/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	var/datum/effect_system/smoke_spread/tactical/S = new
	S.set_up(7, impact)// Large radius, but dissipates quickly
	S.start()

/obj/structure/ship_ammo/cas/minirocket/tangle
	name = "Tanglefoot mini rocket stack"
	desc = "A pack of laser guided mini rockets loaded with plasma-draining Tanglefoot gas. Moving this will require some sort of lifter."
	icon_state = "minirocket_tfoot"
	point_cost = 200
	devastating_explosion_range = 0
	travelling_time = 4 SECONDS
	heavy_explosion_range = 0
	light_explosion_range = 2
	cas_effect = /obj/effect/overlay/blinking_laser/tfoot

/obj/structure/ship_ammo/cas/minirocket/tangle/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, devastating_explosion_range, heavy_explosion_range, light_explosion_range, throw_range = 0)
	var/datum/effect_system/smoke_spread/plasmaloss/S = new
	S.set_up(9, impact, 9)// Between grenade and mortar
	S.start()

/obj/structure/ship_ammo/cas/minirocket/illumination
	name = "illumination rocket flare stack"
	desc = "A pack of laser guided mini rockets, each loaded with a payload of white-star illuminant and a parachute, while extremely ineffective at damaging the enemy, it is very effective at lighting the battlefield so marines can damage the enemy. Moving this will require some sort of lifter."
	icon_state = "minirocket_ilm"
	point_cost = 50 // Not a real rocket, so its cheap
	travelling_time = 4 SECONDS
	cas_effect = /obj/effect/overlay/blinking_laser/flare
	devastating_explosion_range = 0
	heavy_explosion_range = 0
	light_explosion_range = 0
	prediction_type = CAS_AMMO_HARMLESS

/obj/structure/ship_ammo/cas/minirocket/illumination/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	addtimer(CALLBACK(src, PROC_REF(drop_cas_flare), impact), 1.5 SECONDS)
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last minirocket has fired and impacted the ground.

/obj/structure/ship_ammo/cas/minirocket/illumination/proc/drop_cas_flare(turf/impact)
	new /obj/effect/temp_visual/above_flare(impact)
