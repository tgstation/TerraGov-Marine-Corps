
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
	if (control)	// No .click macros allowed
		return usr.do_click(A, location, params)


/mob/proc/do_click(atom/A, location, params)
	// No clicking on atoms with the NOINTERACT flag
	if ((A.flags_atom & NOINTERACT))
		if(istype(A, /obj/screen/click_catcher))
			var/list/mods = params2list(params)
			var/turf/TU = params2turf(mods["screen-loc"], get_turf(usr.client ? usr.client.eye : usr), usr.client)
			if(TU)
				do_click(TU, location, params)
		return

	if (world.time <= next_click)
		//DEBUG: world << "FAIL! TIME:[world.time]   NEXT_CLICK:[next_click]    NEXT_MOVE: [next_move]"
		return

	next_click = world.time + 1
	//DEBUG: world << "SUCCESS! TIME:[world.time]   NEXT_CLICK:[next_click]     NEXT_MOVE: [next_move]"

	var/list/mods = params2list(params)

	// Don't allow any other clicks while dragging something
	if (mods["drag"])
		return

	if(client.buildmode)
		if (istype(A, /obj/effect/bmode))
			A.clicked(src, mods)
			return

		build_click(src, client.buildmode, mods, A)
		return

	var/click_handled = 0
	// Click handled elsewhere. (These clicks are not affected by the next_move cooldown)
	click_handled = click(A, mods)
	click_handled |= A.clicked(src, mods, location, params)

	if (click_handled)
		return

	// Default click functions from here on.

	if (is_mob_incapacitated(TRUE))
		return

	face_atom(A)

	// Special type of click.
	if (is_mob_restrained())
		RestrainedClickOn(A)
		return

	// Throwing stuff.
	if (in_throw_mode)
		throw_item(A)
		return

	// Last thing clicked is tracked for something somewhere.
	if(!istype(A,/obj/item/weapon/gun) && !isturf(A) && !istype(A,/obj/screen))
		last_target_click = world.time

	var/obj/item/W = get_active_hand()

	// Special gun mode stuff.
	if(W == A)
		mode()
		return

	// Don't allow doing anything else if inside a container of some sort, like a locker.
	if (!isturf(loc))
		return

	if (world.time <= next_move)	// Attack click cooldown check
		//DEBUG: world << "FAIL! TIME:[world.time]   NEXT_CLICK:[next_click]    NEXT_MOVE: [next_move]"
		return

	next_move = world.time
	// If standing next to the atom clicked.
	if (A.Adjacent(src))
		if (W)
			if (W.attack_speed)
				next_move += W.attack_speed
			if (!A.attackby(W, src) && A && !A.disposed)
				W.afterattack(A, src, 1, mods)
		else
			next_move += 4
			UnarmedAttack(A, 1)

		return

	// If not standing next to the atom clicked.
	if (W)
		W.afterattack(A, src, 0, mods)
		return

	RangedAttack(A, mods)
	return


/*	OLD DESCRIPTION
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

	if (mods["shift"] && !mods["middle"])
		if(user.client && user.client.eye == user)
			examine(user)
			user.face_atom(src)
		return 1

	if (mods["alt"])
		var/turf/T = get_turf(src)
		if(T && user.TurfAdjacent(T) && T.contents.len)
			user.tile_contents = T.contents.Copy()

			var/atom/A
			for (A in user.tile_contents)
				if (A.invisibility > user.see_invisible)
					user.tile_contents -= A

			if (user.tile_contents.len)
				user.tile_contents_change = 1
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





// click catcher stuff


/obj/screen/click_catcher
	icon = 'icons/mob/screen1.dmi'
	icon_state = "catcher"
	layer = 0
	plane = -99
	mouse_opacity = 2
	screen_loc = "CENTER-7,CENTER-7"
	flags_atom = NOINTERACT


/obj/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
	var/icon/newicon = icon('icons/mob/screen1.dmi', "catcher")
	var/ox = min((33 * 32)/ world.icon_size, view_size_x)
	var/oy = min((33 * 32)/ world.icon_size, view_size_y)
	var/px = view_size_x * world.icon_size
	var/py = view_size_y * world.icon_size
	var/sx = min(33 * 32, px)
	var/sy = min(33 * 32, py)
	newicon.Scale(sx, sy)
	icon = newicon
	screen_loc = "CENTER-[(ox-1)*0.5],CENTER-[(oy-1)*0.5]"
	var/matrix/M = new
	M.Scale(px/sx, py/sy)
	transform = M



/client/proc/change_view(new_size)
	view = new_size
	apply_clickcatcher()
	mob.reload_fullscreens()

/client/proc/create_clickcatcher()
	if(!void)
		void = new()
	screen += void

/client/proc/apply_clickcatcher()
	create_clickcatcher()
	var/list/actual_view = getviewsize(view)
	void.UpdateGreed(actual_view[1],actual_view[2])

/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc || !origin)
		return
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = Clamp(origin.x + text2num(tX) - round(actual_view[1] / 2) - 1, 1, world.maxx)
	tY = Clamp(origin.y + text2num(tY) - round(actual_view[2] / 2) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)


/proc/getviewsize(view)
	var/viewX
	var/viewY
	if(isnum(view))
		var/totalviewrange = 1 + 2 * view
		viewX = totalviewrange
		viewY = totalviewrange
	else
		var/list/viewrangelist = splittext(view,"x")
		viewX = text2num(viewrangelist[1])
		viewY = text2num(viewrangelist[2])
	return list(viewX, viewY)