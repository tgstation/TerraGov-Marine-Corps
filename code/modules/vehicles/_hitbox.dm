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
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	max_integrity = INFINITY
	move_resist = INFINITY // non forcemoving this could break gliding so lets just say no
	///people riding on this hitbox that we want to move with us
	var/list/atom/movable/tank_desants
	///The "parent" that this hitbox is attached to and to whom it will relay damage
	var/obj/vehicle/root = null

/obj/hitbox/Initialize(mapload, obj/vehicle/new_root)
	. = ..()
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
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/hitbox/Destroy(force)
	if(!force) // only when the parent is deleted
		return QDEL_HINT_LETMELIVE
	root?.hitbox = null
	root = null
	return ..()

///signal handler for handling PASS_WALKOVER
/obj/hitbox/proc/can_cross_hitbox(datum/source, atom/mover)
	SIGNAL_HANDLER
	if(locate(src) in mover.loc)
		return TRUE

///Signal handler to spin the desants as well when the tank turns
/obj/hitbox/proc/owner_turned(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!new_dir || new_dir == old_dir)
		return
	for(var/mob/living/desant AS in tank_desants)
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
		desant.forceMove(new_pos)

///signal handler when someone jumping lands on us
/obj/hitbox/proc/on_jump_landed(datum/source, atom/lander)
	SIGNAL_HANDLER
	if(HAS_TRAIT(lander, TRAIT_TANK_DESANT))
		return
	ADD_TRAIT(lander, TRAIT_TANK_DESANT, VEHICLE_TRAIT)
	LAZYSET(tank_desants, lander, lander.layer)
	RegisterSignal(lander, COMSIG_QDELETING, PROC_REF(on_desant_del))
	lander.layer = ABOVE_MOB_PLATFORM_LAYER

///signal handler when we leave a turf under the hitbox
/obj/hitbox/proc/on_exited(atom/source, atom/movable/AM, direction)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(AM, TRAIT_TANK_DESANT))
		return
	if(locate(src) in AM.loc) //Î'd cut the locate but for some reason it wdoesnt work lol
		return
	REMOVE_TRAIT(AM, TRAIT_TANK_DESANT, VEHICLE_TRAIT)
	AM.layer = LAZYACCESS(tank_desants, AM)
	LAZYREMOVE(tank_desants, AM)
	UnregisterSignal(AM, COMSIG_QDELETING)

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
	for(var/mob/living/tank_desant AS in tank_desants)
		tank_desant.forceMove(get_step(tank_desant, direction))
		if(isxeno(tank_desant) || move_dist > 1)
			continue
		if(move_dist > 1)
			continue
		if(!tank_desant.l_hand || !tank_desant.r_hand)
			continue
		balloon_alert(tank_desant, "poor grip!")
		var/away_dir = get_dir(tank_desant, root)
		if(!away_dir)
			away_dir = pick(GLOB.alldirs)
		away_dir = REVERSE_DIR(away_dir)
		var/turf/target = get_step(get_step(root, away_dir), away_dir)
		tank_desant.throw_at(target, 3, 3, root)

///called when the tank is off movement cooldown and someone tries to move it
/obj/hitbox/proc/on_attempt_drive(atom/movable/movable_parent, mob/living/user, direction)
	SIGNAL_HANDLER
	if(ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
	if((root.dir != direction) && (root.dir != REVERSE_DIR(direction)))
		root.setDir(direction)
		if(isarmoredvehicle(root))
			var/obj/vehicle/sealed/armored/armor = root
			playsound(armor, armor.engine_sound, 100, TRUE, 20)
		return COMPONENT_DRIVER_BLOCK_MOVE
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

		for(var/atom/movable/O AS in T.contents) // this is checked in turf/enter but it doesnt return false so lmao
			if(O.CanPass(root))	// Then check for obstacles to crush
				continue
			root.Bump(O) //manually call bump on everything
			canstep = FALSE

	if(canstep)
		return NONE
	return COMPONENT_DRIVER_BLOCK_MOVE

/obj/hitbox/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if((allow_pass_flags & PASS_TANK) && (mover.pass_flags & PASS_TANK))
		return TRUE

/obj/hitbox/projectile_hit(obj/projectile/proj)
	if(proj.shot_from == root)
		return FALSE
	return root.projectile_hit(arglist(args))

/obj/hitbox/bullet_act(obj/projectile/proj)
	SHOULD_CALL_PARENT(FALSE) // this is an abstract object: we have to avoid everything on parent
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, proj)
	return root.bullet_act(proj)

/obj/hitbox/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	return root.take_damage(arglist(args))

/obj/hitbox/ex_act(severity)
	return

///2x2 hitbox version
/obj/hitbox/medium
	bound_width = 64
	bound_height = 64
	bound_x = 0
	bound_y = -32

/obj/hitbox/medium/on_attempt_drive(atom/movable/movable_parent, mob/living/user, direction)
	if(ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
	if((root.dir != direction) && (root.dir != REVERSE_DIR(direction)))
		root.setDir(direction)
		if(isarmoredvehicle(root))
			var/obj/vehicle/sealed/armored/armor = root
			playsound(armor, armor.engine_sound, 100, TRUE, 20)
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

	if(canstep)
		return NONE
	return COMPONENT_DRIVER_BLOCK_MOVE
