/**
 * HITBOX
 * The core of multitile. Acts as a relay for damage and stops people from walking onto the multitle sprite
 * has changed bounds and as thus must always be forcemoved so it doesnt break everything
 * I would use pixel movement but the maptick caused by it is way too high and a fake tile based movement might work? but I want this to at least pretend to be generic
 * Thus we just use this relay. it's an obj so we can make sure all the damage procs that work on root also work on the hitbox
 */
/obj/hitbox
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	bound_x = -32
	bound_y = -32
	max_integrity = INFINITY
	move_resist = INFINITY // non forcemoving this could break gliding so lets just say no
	explosion_block = 1
	///people riding on this hitbox that we want to move with us
	var/list/atom/movable/tank_desants
	///The "parent" that this hitbox is attached to and to whom it will relay damage
	var/obj/vehicle/root = null
	///Length of the vehicle. Assumed to be longer than it is wide
	var/vehicle_length = 96
	///Width of the vehicle
	var/vehicle_width = 96

/obj/hitbox/Initialize(mapload, obj/vehicle/new_root)
	. = ..()
	bound_height = vehicle_length
	bound_width = vehicle_width
	root = new_root
	allow_pass_flags = root.allow_pass_flags
	atom_flags = root.atom_flags
	resistance_flags = root.resistance_flags
	RegisterSignal(new_root, COMSIG_MOVABLE_MOVED, PROC_REF(root_move))
	RegisterSignal(new_root, COMSIG_QDELETING, PROC_REF(root_delete))
	RegisterSignals(new_root, list(COMSIG_RIDDEN_DRIVER_MOVE, COMSIG_VEHICLE_MOVE), PROC_REF(on_attempt_drive))
	RegisterSignal(new_root, COMSIG_ATOM_DIR_CHANGE, PROC_REF(owner_turned))

	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_cross_hitbox),
		COMSIG_TURF_JUMP_ENDED_HERE = PROC_REF(on_jump_landed),
		COMSIG_TURF_THROW_ENDED_HERE = PROC_REF(on_stop_throw),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/hitbox/Destroy(force)
	if(!force) // only when the parent is deleted
		return QDEL_HINT_LETMELIVE
	for(var/atom/movable/desant AS in tank_desants)
		remove_desant(desant)
	root?.hitbox = null
	root = null
	return ..()

/obj/hitbox/Shake(pixelshiftx = 2, pixelshifty = 2, duration = 2.5 SECONDS, shake_interval = 0.02 SECONDS)
	root.Shake(pixelshiftx, pixelshifty, duration, shake_interval)

/obj/hitbox/footstep_override(atom/movable/source, list/footstep_overrides)
	footstep_overrides[FOOTSTEP_HULL] = 4.5

///signal handler for handling PASS_WALKOVER
/obj/hitbox/proc/can_cross_hitbox(datum/source, atom/mover)
	SIGNAL_HANDLER
	if(locate(src) in mover.loc)
		return TRUE

///Signal handler to spin the desants as well when the tank turns
/obj/hitbox/proc/owner_turned(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!new_dir || new_dir == old_dir)
		return FALSE
	if(vehicle_length != vehicle_width)
		return TRUE //handled by child types
	for(var/atom/movable/desant AS in tank_desants)
		if(desant.loc == root.loc)
			continue
		var/turf/new_pos
		//doesnt work with diags, but that shouldnt happen, right?
		if(REVERSE_DIR(old_dir) == new_dir)
			new_pos = get_step(root, REVERSE_DIR(get_dir(desant, root)))
		else if(turn(old_dir, 90) == new_dir)
			new_pos = get_step(root, turn(get_dir(desant, root), -90))
		else
			new_pos = get_step(root, turn(get_dir(desant, root), 90))
		desant.set_glide_size(32)
		desant.forceMove(new_pos)

	return FALSE

///Adds a new desant
/obj/hitbox/proc/add_desant(atom/movable/new_desant)
	if(HAS_TRAIT(new_desant, TRAIT_TANK_DESANT))
		return
	ADD_TRAIT(new_desant, TRAIT_TANK_DESANT, VEHICLE_TRAIT)
	new_desant.add_nosubmerge_trait(VEHICLE_TRAIT)
	LAZYSET(tank_desants, new_desant, PLANE_TO_TRUE(new_desant.plane))
	SET_PLANE_IMPLICIT(new_desant, ABOVE_GAME_PLANE)
	RegisterSignal(new_desant, COMSIG_QDELETING, PROC_REF(on_desant_del))
	root.add_desant(new_desant)

///Removes a desant
/obj/hitbox/proc/remove_desant(atom/movable/desant)
	SET_PLANE_IMPLICIT(desant, LAZYACCESS(tank_desants, desant))
	desant.remove_traits(list(TRAIT_TANK_DESANT, TRAIT_NOSUBMERGE), VEHICLE_TRAIT)
	LAZYREMOVE(tank_desants, desant)
	UnregisterSignal(desant, COMSIG_QDELETING)
	root.remove_desant(desant)

///signal handler when someone jumping lands on us
/obj/hitbox/proc/on_jump_landed(datum/source, atom/movable/lander)
	SIGNAL_HANDLER
	add_desant(lander)

///signal handler when something thrown lands on us
/obj/hitbox/proc/on_stop_throw(datum/source, atom/movable/thrown_movable)
	SIGNAL_HANDLER
	add_desant(thrown_movable)

///signal handler when we leave a turf under the hitbox
/obj/hitbox/proc/on_exited(atom/source, atom/movable/AM, direction)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(AM, TRAIT_TANK_DESANT))
		return
	if(AM.loc in locs)
		return
	remove_desant(AM)

	var/obj/hitbox/new_hitbox = locate(/obj/hitbox) in AM.loc //walking onto another vehicle
	if(new_hitbox)
		new_hitbox.add_desant(AM)

///cleanup riders on deletion
/obj/hitbox/proc/on_desant_del(datum/source)
	SIGNAL_HANDLER
	LAZYREMOVE(tank_desants, source)

///when root deletes is the only time we want to be deleting
/obj/hitbox/proc/root_delete()
	SIGNAL_HANDLER
	qdel(src, TRUE)

///when the owner moves, let's move with them!
/obj/hitbox/proc/root_move(atom/movable/mover, atom/oldloc, direction, forced, list/turf/old_locs)
	SIGNAL_HANDLER
	//direction is null here, so we improvise
	direction = get_dir(oldloc, mover)
	var/move_dist = get_dist(oldloc, mover)
	forceMove(mover.loc)
	var/new_z = (z != oldloc.z)
	for(var/atom/movable/tank_desant AS in tank_desants)
		tank_desant.set_glide_size(root.glide_size)
		if(new_z)
			tank_desant.abstract_move(loc) //todo: have some better code to actually preserve their location
		else
			tank_desant.forceMove(get_step(tank_desant, direction))
		if(move_dist > 1)
			continue
		var/throw_dist = 2
		if(isobj(tank_desant) && !isitem(tank_desant))
			continue
		if(ismob(tank_desant))
			if(!isliving(tank_desant))
				continue
			var/mob/living/living_rider = tank_desant
			if(!living_rider.stat)
				if(isxeno(tank_desant))
					continue
				if(!living_rider.l_hand || !living_rider.r_hand)
					continue
			balloon_alert(living_rider, "poor grip!")
			throw_dist = 3

		var/away_dir = REVERSE_DIR(get_dir(tank_desant, root) || pick(GLOB.alldirs))
		var/turf/target = get_ranged_target_turf(tank_desant, away_dir, throw_dist)
		tank_desant.throw_at(target, throw_dist, 3, root)

///called when the tank is off movement cooldown and someone tries to move it
/obj/hitbox/proc/on_attempt_drive(atom/movable/movable_parent, mob/living/user, direction)
	SIGNAL_HANDLER
	if(ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/vehicle/sealed/armored/armor = root
	var/is_strafing = FALSE
	if(armor?.strafe)
		is_strafing = TRUE
		for(var/mob/driver AS in armor.return_drivers())
			if(driver.client?.keys_held["Alt"])
				is_strafing = FALSE
				break
	if((root.dir == direction) || (root.dir == REVERSE_DIR(direction)))
		is_strafing = FALSE
	else if(!is_strafing) //we turn
		root.setDir(direction)
		return COMPONENT_DRIVER_BLOCK_MOVE
	///
	//Due to this being a hot proc this part here is inlined and set on a by-hitbox-size basis
	/////////////////////////////
	var/turf/centerturf = get_step(get_step(root, direction), direction)
	var/list/enteringturfs = list(centerturf)
	enteringturfs += get_step(centerturf, turn(direction, 90))
	enteringturfs += get_step(centerturf, turn(direction, -90))
	/////////////////////////////
	var/canstep = TRUE
	for(var/turf/T AS in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(!T.Enter(root, direction))	//Check if we can cross the turf first/bump the turf
			canstep = FALSE

		for(var/atom/movable/AM AS in T.contents) // this is checked in turf/enter but it doesnt return false so lmao
			if(AM.pass_flags & PASS_TANK) //rather than add it to AM/CanAllowThrough for this one interaction, lets just check it manually
				continue
			if(AM.CanPass(root))	// Then check for obstacles to crush
				continue
			root.Bump(AM) //manually call bump on everything
			canstep = FALSE
	return canstep ? NONE : COMPONENT_DRIVER_BLOCK_MOVE

/obj/hitbox/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if((allow_pass_flags & PASS_TANK) && (mover.pass_flags & PASS_TANK))
		return TRUE

/obj/hitbox/projectile_hit(atom/movable/projectile/proj)
	if(proj.shot_from == root)
		return FALSE
	return root.projectile_hit(arglist(args))

/obj/hitbox/bullet_act(atom/movable/projectile/proj)
	SHOULD_CALL_PARENT(FALSE) // this is an abstract object: we have to avoid everything on parent
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, proj)
	return root.bullet_act(proj)

/obj/hitbox/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	return root.take_damage(arglist(args))

/obj/hitbox/ex_act(severity)
	root.ex_act(severity)

/obj/hitbox/lava_act()
	root.lava_act()

/obj/hitbox/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage((10 * S.strength) * 0.2 , BURN, ACID)

///Returns the turf where primary weapon projectiles should source from
/obj/hitbox/proc/get_projectile_loc(obj/item/armored_weapon/weapon)
	if(!isarmoredvehicle(root))
		return loc
	var/obj/vehicle/sealed/armored/armored_root = root
	return get_step(src, armored_root.turret_overlay.dir)

///2x2 hitbox version
/obj/hitbox/medium
	vehicle_length = 64
	vehicle_width = 64
	bound_x = 0
	bound_y = -32

/obj/hitbox/medium/on_attempt_drive(atom/movable/movable_parent, mob/living/user, direction)
	if(ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/vehicle/sealed/armored/armor = root
	var/is_strafing = FALSE
	if(armor?.strafe)
		is_strafing = TRUE
		for(var/mob/driver AS in armor.return_drivers())
			if(driver.client?.keys_held["Alt"])
				is_strafing = FALSE
				break
	if((root.dir == direction) || (root.dir == REVERSE_DIR(direction)))
		is_strafing = FALSE
	else if(!is_strafing) //we turn
		root.setDir(direction)
		return COMPONENT_DRIVER_BLOCK_MOVE
	///////////////////////////
	var/turf/centerturf = get_step(root, direction)
	var/list/enteringturfs = list()
	switch(direction)
		if(NORTH)
			enteringturfs += get_step(centerturf, turn(direction, -90))
		if(SOUTH)
			centerturf = get_step(centerturf, direction)
			enteringturfs += get_step(centerturf, turn(direction, 90))
		if(EAST)
			centerturf = get_step(centerturf, direction)
			enteringturfs += get_step(centerturf, turn(direction, -90))
		if(WEST)
			enteringturfs += get_step(centerturf, turn(direction, 90))
	enteringturfs += centerturf
	////////////////////////////////////
	var/canstep = TRUE
	for(var/turf/T AS in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(!T.Enter(root, direction))	//Check if we can cross the turf first/bump the turf
			canstep = FALSE

		for(var/atom/movable/O AS in T.contents) // this is checked in turf/enter but it doesnt return false so lmao
			if(O.CanPass(root))	// Then check for obstacles to crush
				continue
			root.Bump(O) //manually call bump on everything
			canstep = FALSE

	return canstep ? NONE : COMPONENT_DRIVER_BLOCK_MOVE

//3x4
/obj/hitbox/rectangle

	bound_x = -32
	bound_y = -64
	vehicle_length = 128
	vehicle_width = 96

/obj/hitbox/rectangle/owner_turned(datum/source, old_dir, new_dir)
	. = ..()
	if(!.)
		return
	var/list/old_locs = locs.Copy()
	switch(new_dir)
		if(NORTH)
			bound_height = vehicle_length
			bound_width = vehicle_width
			bound_x = -32
			bound_y = -32
			root.pixel_x = -65
			root.pixel_y = -48
		if(SOUTH)
			bound_height = vehicle_length
			bound_width = vehicle_width
			bound_x = -32
			bound_y = -64
			root.pixel_x = -65
			root.pixel_y = -80
		if(WEST)
			bound_height = vehicle_width
			bound_width = vehicle_length
			bound_x = -64
			bound_y = -32
			root.pixel_x = -80
			root.pixel_y = -56
		if(EAST)
			bound_height = vehicle_width
			bound_width = vehicle_length
			bound_x = -32
			bound_y = -32
			root.pixel_x = -48
			root.pixel_y = -56

	var/angle_change = dir2angle(new_dir) - dir2angle(old_dir)
	//north needing to be considered 0 OR 360 is inconvenient, I'm sure there is a non ungabrain way to do this
	switch(angle_change)
		if(-270)
			angle_change = 90
		if(270)
			angle_change = -90
	for(var/atom/movable/desant AS in tank_desants)
		if(desant.loc == root.loc)
			continue
		var/new_x
		var/new_y
		if(angle_change > 0) //clockwise turn
			new_x = root.x + (desant.y - root.y)
			new_y = root.y - (desant.x - root.x)
		else //anti-clockwise
			new_x = root.x - (desant.y - root.y)
			new_y = root.y + (desant.x - root.x)

		desant.forceMove(locate(new_x, new_y, z))

	SEND_SIGNAL(src, COMSIG_MULTITILE_VEHICLE_ROTATED, loc, new_dir, null, old_locs)

/obj/hitbox/rectangle/on_attempt_drive(atom/movable/movable_parent, mob/living/user, direction)
	if(ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/vehicle/sealed/armored/armor = root
	var/is_strafing = FALSE
	if(armor?.strafe)
		is_strafing = TRUE
		for(var/mob/driver AS in armor.return_drivers())
			if(driver.client?.keys_held["Alt"])
				is_strafing = FALSE
				break
	if((root.dir == direction) || (root.dir == REVERSE_DIR(direction)))
		is_strafing = FALSE


	/////////////////////////////
	var/turf/centerturf = get_turf(root)
	var/dist_count = 3
	if(root.dir != direction)
		dist_count =2
	for(var/i in 1 to dist_count)
		centerturf = get_step(centerturf, direction)
	var/list/enteringturfs = list(centerturf)
	enteringturfs += get_step(centerturf, turn(direction, 90))
	enteringturfs += get_step(centerturf, turn(direction, -90))
	/////////////////////////////
	if(is_strafing)
		centerturf = get_step(centerturf, root.dir)
		centerturf = get_step(centerturf, root.dir)
		enteringturfs += centerturf
	var/canstep = TRUE
	for(var/turf/T AS in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(!T.Enter(root, direction))	//Check if we can cross the turf first/bump the turf
			canstep = FALSE

		for(var/atom/movable/O AS in T.contents) // this is checked in turf/enter but it doesnt return false so lmao
			if(O.CanPass(root))	// Then check for obstacles to crush
				continue
			root.Bump(O) //manually call bump on everything
			canstep = FALSE

	if(canstep)
		if((root.dir != direction) && (root.dir != REVERSE_DIR(direction)) && (!is_strafing))
			root.setDir(direction)
			return COMPONENT_DRIVER_BLOCK_MOVE
		else
			return NONE
	return COMPONENT_DRIVER_BLOCK_MOVE

//Some hover specific stuff for the SOM tank
/obj/hitbox/rectangle/som_tank/get_projectile_loc(obj/item/armored_weapon/weapon)
	return get_step(get_step(src, root.dir), root.dir)
