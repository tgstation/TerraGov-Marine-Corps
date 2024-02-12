/**
 * HITBOX
 * The core of multitile. Acts as a relay for damage and stops people from walking onto the multitle sprite
 * has changed bounds and as thus must always be forcemoved so it doesnt break everything
 * I would use pixel movement but the maptick caused by it is way too high and a fake tile based movement is ?????
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
	///The "parent" that this hitbox is attached to and to whom it will relay damage
	var/obj/vehicle/root = null

/obj/hitbox/Initialize(mapload, obj/vehicle/new_root)
	. = ..()
	root = new_root
	allow_pass_flags = root.allow_pass_flags
	resistance_flags = root.resistance_flags
	RegisterSignal(new_root, COMSIG_MOVABLE_MOVED, PROC_REF(root_move))
	RegisterSignal(new_root, COMSIG_QDELETING, PROC_REF(root_delete))
	RegisterSignals(new_root, list(COMSIG_RIDDEN_DRIVER_MOVE, COMSIG_VEHICLE_MOVE), PROC_REF(on_attempt_drive))

/obj/hitbox/Destroy(force)
	if(!force) // only when the parent is deleted
		return QDEL_HINT_LETMELIVE
	root?.hitbox = null
	root = null
	return ..()

/obj/hitbox/proc/root_delete()
	SIGNAL_HANDLER
	qdel(src, TRUE)

/obj/hitbox/proc/root_move(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	forceMove(mover.loc)

/obj/hitbox/CanAllowThrough(atom/movable/mover, turf/target)
	if(mover == root)//Bypass your own hitbox
		return TRUE
	return ..()

/obj/hitbox/proc/on_attempt_drive(atom/movable/movable_parent, mob/living/user, direction)
	SIGNAL_HANDLER
	if(ISDIAGONALDIR(direction))
		return COMPONENT_DRIVER_BLOCK_MOVE
	movable_parent.setDir(direction)//we can move, so lets start by pointing in that direction
	//Due to this being a hot proc this part here is inlined and set on a by-hitbox-size basis
	/////////////////////////////
	var/turf/centerturf = get_step(get_step(root, direction), direction)
	var/list/enteringturfs = list(centerturf)
	enteringturfs += get_step(centerturf, turn(direction, 90))
	enteringturfs += get_step(centerturf, turn(direction, -90))
	/////////////////////////////
	var/canstep = TRUE
	for(var/turf/T AS in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(T.Enter(root) == FALSE)	//Check if we can cross the turf first/bump the turf
			canstep = FALSE		//why "var == false" you ask? well its because its tiny bit faster, thanks byond

		for(var/atom/movable/O AS in T.contents) // this is checked in turf/enter but it doesnt return it so lmao
			if(O.CanPass(root) == TRUE)	// Then check for obstacles to crush
				continue
			root.Bump(O) //manually call bump on everything
			canstep = FALSE

	if(canstep == TRUE)
		return NONE
	return COMPONENT_DRIVER_BLOCK_MOVE


/obj/hitbox/projectile_hit(obj/projectile/proj)
	if(proj.firer == root)
		return FALSE
	return ..()

/obj/hitbox/bullet_act(obj/projectile/proj)
	SHOULD_CALL_PARENT(FALSE) // this is an abstract object that should not affect the bullet in any way
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, proj)
	return root.bullet_act(proj)

/obj/hitbox/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", effects = TRUE, attack_dir, armour_penetration = 0)
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
	setDir(direction)//we can move, so lets start by pointing in that direction
	///////////////////////////
	var/turf/centerturf = get_step(root, direction)
	var/list/enteringturfs = list(centerturf)
	switch(direction)
		if(NORTH)
			enteringturfs += get_step(centerturf, turn(direction, -90))
		if(SOUTH)
			centerturf = get_step(get_step(root, direction), direction)
			enteringturfs += get_step(centerturf, turn(direction, 90))
		if(EAST)
			centerturf = get_step(get_step(root, direction), direction)
			enteringturfs += get_step(centerturf, turn(direction, -90))
		if(WEST)
			enteringturfs += get_step(centerturf, turn(direction, 90))
	////////////////////////////////////
	var/canstep = TRUE
	for(var/turf/T AS in enteringturfs)	//No break because we want to crush all the turfs before we start trying to move
		if(T.Enter(root) == FALSE)	//Check if we can cross the turf first/bump the turf
			canstep = FALSE		//why "var == false" you ask? well its because its tiny bit faster, thanks byond

		for(var/atom/movable/O AS in T.contents) // this is checked in turf/enter but it doesnt return it so lmao
			if(O.CanPass(root) == TRUE)	// Then check for obstacles to crush
				continue
			root.Bump(O) //manually call bump on everything
			canstep = FALSE

	if(canstep == TRUE)
		return NONE //step(root, direction)
	return COMPONENT_DRIVER_BLOCK_MOVE
