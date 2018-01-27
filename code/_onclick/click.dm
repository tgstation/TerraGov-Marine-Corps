
// 1 decisecond click delay (above and beyond mob/next_move)
/mob/var/next_click = 0
/*
	client/Click is called every time a client clicks anywhere, it should never be overridden.

	For all mobs that should have a specific click function and/or a modified click function
	(modified means click+shift, click+ctrl, etc.) add a custom mob/click() proc.

	For anything being clicked by a mob that should have a specific or modified click function,
	add a custom atom/clicked() proc.

	For both click() and clicked(), make sure they return 1 if the click is resolved,
	if not, return 0 to perform regular click functions like picking up items off the ground.
	~ BMC777
*/

/client/Click(atom/A, location, control, params)
	if (control)
		return usr.do_click(A, location, params)


/mob/proc/do_click(atom/A, location, params)
	// No .click macros allowed, no clicking on atoms with the NOINTERACT flag.
	if ((A.flags_atom & NOINTERACT))
		return

	if (world.time <= next_click)
		//DEBUG: world << "FAIL! TIME:[world.time]   NEXT_CLICK:[next_click]"
		return

	next_click = world.time + 3
	//DEBUG: world << "SUCCESS! TIME:[world.time]   NEXT_CLICK:[next_click]"
	var/mob/user = src
	var/list/mods = params2list(params)
	var/click_handled = 0

	if (user.next_move > world.time)
		return

	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	// Click handled elsewhere.
	click_handled = user.click(A, mods)
	click_handled |= A.clicked(user, mods)

	if (click_handled)
		return 100

	// Default click functions from here on.

	if (user.is_mob_incapacitated(TRUE))
		return

	user.face_atom(A)

	if (next_move > world.time)
		return

	// Special type of click.
	if (user.is_mob_restrained())
		user.RestrainedClickOn(A)
		return 100

	// Throwing stuff.
	if (user.in_throw_mode)
		user.throw_item(A)
		return 100

	// Last thing clicked is tracked for something somewhere.
	if(!istype(A,/obj/item/weapon/gun) && !isturf(A) && !istype(A,/obj/screen))
		user.last_target_click = world.time

	var/obj/item/W = user.get_active_hand()

	// Special gun mode stuff.
	if(W == A)
		user.mode()
		return 100

	// Don't allow doing anything else if inside a container of some sort, like a locker.
	if (!isturf(user.loc))
		return

	// If standing next to the atom clicked.
	if (A.Adjacent(user))
		user.next_move += 6
		if (W)
			if (W.attack_speed)
				user.next_move += W.attack_speed

			if (!A.attackby(W, user) && A)
				W.afterattack(A, user, 1, mods)
		else
			user.UnarmedAttack(A, 1)

		return 100

	// If not standing next to the atom clicked.
	if (W)
		W.afterattack(A, user, 0, mods)
		return 100

	user.RangedAttack(A, mods)
	return 100


/*
	Standard mob ClickOn()
	Handles exceptions: Buildmode, middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/

/mob/proc/click(var/atom/A, var/list/mods)
	return 0

/atom/proc/clicked(var/mob/user, var/list/mods)

	if (mods["shift"])
		if(user.client && user.client.eye == user)
			examine(user)
			user.face_atom(src)
		return 1

	if (mods["alt"])
		var/turf/T = get_turf(src)
		if(T && user.TurfAdjacent(T))
			if(user.listed_turf == T)
				user.listed_turf = null
			else
				user.listed_turf = T
				user.client.statpanel = T.name
		return 1
	return 0

/atom/movable/clicked(var/mob/user, var/list/mods)
	if (..())
		return 1

	if (mods["ctrl"])
		if (Adjacent(user))
			user.start_pulling(src)
		return 1
	return 0

/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(var/atom/A, var/proximity_flag)
	return

/*
	Ranged unarmed attack:

	This currently is just a default for all mobs, involving
	laser eyes and telekinesis.  You could easily add exceptions
	for things like ranged glove touches, spitting alien acid/neurotoxin,
	animals lunging, etc.
*/
/mob/proc/RangedAttack(var/atom/A, var/params)
	if(!mutations.len) return
	if((LASER in mutations) && a_intent == "harm")
		LaserEyes(A) // moved into a proc below
	else if(TK in mutations)
		switch(get_dist(src,A))
			if(0)
				;
			if(1 to 5) // not adjacent may mean blocked by window
				next_move += 2
			if(5 to 7)
				next_move += 5
			if(8 to tk_maxrange)
				next_move += 10
			else
				return
		A.attack_tk(src)
/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(var/atom/A)
	return

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	next_move = world.time + 6
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/item/projectile/beam/LE = new /obj/item/projectile/beam( loc )
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 25, 1)

	LE.firer = src
	LE.def_zone = get_limbzone_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn( 1 )
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		src << "\red You're out of energy!  You need food!"

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(var/atom/A)

	if( stat || (buckled && buckled.anchored) || !A || !x || !y || !A.x || !A.y ) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)	direction = NORTH
		else		direction = SOUTH
	else
		if(dx > 0)	direction = EAST
		else		direction = WEST
	usr.dir = direction
	if(buckled)
		buckled.dir = direction
		buckled.handle_rotation()
