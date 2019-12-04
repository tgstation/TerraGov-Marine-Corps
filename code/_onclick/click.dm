//Delays the mob's next click/action by num deciseconds
// eg: 10 - 3 = 7 deciseconds of delay
// eg: 10 * 0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num + next_move_adjust) * next_move_modifier)


/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/
/atom/Click(location, control, params)
	if(flags_atom & INITIALIZED)
		SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)
		usr.ClickOn(src, params)


/atom/DblClick(location, control, params)
	if(flags_atom & INITIALIZED)
		usr.DblClickOn(src, params)


/atom/MouseWheel(delta_x, delta_y, location, control, params)
	if(flags_atom & INITIALIZED)
		usr.MouseWheelOn(src, delta_x, delta_y, params)


/*
	Standard mob ClickOn()
	Handles exceptions: Buildmode, middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is receiving it.
	The most common are:
	* mob/UnarmedAttack(atom, adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item, user, params) - used only when adjacent
	* item/afterattack(atom, user, adjacent, params) - used both ranged and adjacent when not handled by attackby
	* mob/RangedAttack(atom, params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params, A))
		return

	if(notransform)
		return

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, params) & COMSIG_MOB_CLICK_CANCELED)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["middle"])
		ShiftMiddleClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["ctrl"] && modifiers["middle"])
		CtrlMiddleClickOn(A)
		return
	if(modifiers["middle"] && MiddleClickOn(A))		
		return
	if(modifiers["shift"] && ShiftClickOn(A))
		return
	if(modifiers["alt"] && AltClickOn(A))
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(incapacitated(TRUE))
		return

	face_atom(A)

	if(next_move > world.time)
		return

	if(!modifiers["catcher"] && A.IsObscured())
		return

	if(istype(loc, /obj/vehicle/multitile/root/cm_armored))
		var/obj/vehicle/multitile/root/cm_armored/N = loc
		N.click_action(A, src, params)
		return

	if(restrained())
		changeNext_move(CLICK_CD_HANDCUFFED)
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	var/obj/item/W = get_active_held_item()

	if(W == A)
		W.attack_self(src)
		update_inv_l_hand()
		update_inv_r_hand()
		return

	//These are always reachable.
	//User itself, current loc, and user inventory
	if(A in DirectAccess())
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			UnarmedAttack(A)
		return

	//Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	//Standard reach turf to turf or reaching inside storage
	if(CanReach(A, W))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			UnarmedAttack(A, 1)
	else
		if(W)
			var/attack
			var/proximity = A.Adjacent(src)
			if(proximity && A.attackby(W, src, params))
				attack = TRUE
			if(!attack)
				W.afterattack(A, src, proximity, params)
		else
			if(A.Adjacent(src))
				A.attack_hand(src)
			RangedAttack(A, params)


/atom/movable/proc/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	// A backwards depth-limited breadth-first-search to see if the target is
	// logically "in" anything adjacent to us.
	var/list/direct_access = DirectAccess()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)
	while(checking.len && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)  // will filter out nulls
			if(closed[target] || isarea(target))  // avoid infinity situations
				continue
			closed[target] = TRUE
			if(isturf(target) || isturf(target.loc) || (target in direct_access)) //Directly accessible atoms
				if(Adjacent(target) || target.Adjacent(src) || (tool && CheckToolReach(src, target, tool.reach))) //Adjacent or reaching attacks
					return TRUE

			if(!target.loc)
				continue

			if(!(SEND_SIGNAL(target.loc, COMSIG_ATOM_CANREACH, next) & COMPONENT_BLOCK_REACH))
				next += target.loc

		checking = next
	return FALSE


/atom/movable/proc/DirectAccess()
	return list(src, loc)


/mob/DirectAccess(atom/target)
	return ..() + contents


/mob/living/DirectAccess(atom/target)
	return ..() + GetAllContents()


/atom/proc/IsObscured()
	if(!isturf(loc)) //This only makes sense for things directly on turfs for now
		return FALSE
	var/turf/T = get_turf_pixel(src)
	if(!T)
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM.flags_atom & PREVENT_CLICK_UNDER && AM.density && AM.layer > layer)
			return TRUE
	return FALSE


/turf/IsObscured()
	for(var/atom/movable/AM in src)
		if(AM.flags_atom & PREVENT_CLICK_UNDER && AM.density)
			return TRUE
	return FALSE


/atom/proc/AllowClick()
	return FALSE


/turf/AllowClick()
	return TRUE


/proc/CheckToolReach(atom/movable/here, atom/movable/there, reach)
	if(!here || !there)
		return
	switch(reach)
		if(0)
			return FALSE
		if(1)
			return FALSE //here.Adjacent(there)
		if(2 to INFINITY)
			var/obj/dummy = new(get_turf(here))
			dummy.flags_pass |= PASSTABLE
			dummy.invisibility = INVISIBILITY_ABSTRACT
			for(var/i in 1 to reach) //Limit it to that many tries
				var/turf/T = get_step(dummy, get_dir(dummy, there))
				if(dummy.CanReach(there))
					qdel(dummy)
					return TRUE
				if(!dummy.Move(T)) //we're blocked!
					qdel(dummy)
					return
			qdel(dummy)


/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	if(ismob(A))
		changeNext_move(CLICK_CD_MELEE)


/*
	Ranged unarmed attack:

	This currently is just a default for all mobs, involving
	laser eyes and telekinesis.  You could easily add exceptions
	for things like ranged glove touches, spitting alien acid/neurotoxin,
	animals lunging, etc.
*/
/mob/proc/RangedAttack(atom/A, params)
	SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED, A, params)


/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(atom/A)
	return


/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(atom/A)
	return TRUE


/mob/living/carbon/human/MiddleClickOn(atom/A)
	. = ..()
	if(!middle_mouse_toggle)
		return
	var/obj/item/held_thing = get_active_held_item()
	if(held_thing && SEND_SIGNAL(held_thing, COMSIG_ITEM_MIDDLECLICKON, A, src) & COMPONENT_ITEM_CLICKON_BYPASS)
		return FALSE


/mob/living/carbon/xenomorph/MiddleClickOn(atom/A)
	. = ..()
	if(!middle_mouse_toggle || !selected_ability)
		return
	if(selected_ability.can_use_ability(A))
		selected_ability.use_ability(A)

/*
	Shift click
	For most mobs, examine.
	This is overridden in ai.dm
*/
/mob/proc/ShiftClickOn(atom/A)
	switch(SEND_SIGNAL(src, COMSIG_MOB_CLICK_SHIFT, A))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return A.ShiftClick(src)


/mob/living/carbon/human/ShiftClickOn(atom/A)
	if(middle_mouse_toggle)
		return ..()
	var/obj/item/held_thing = get_active_held_item()

	if(held_thing && SEND_SIGNAL(held_thing, COMSIG_ITEM_SHIFTCLICKON, A, src) & COMPONENT_ITEM_CLICKON_BYPASS)
		return FALSE
	return ..()


/mob/living/carbon/xenomorph/ShiftClickOn(atom/A)
	if(!selected_ability || middle_mouse_toggle)
		return ..()
	if(selected_ability.can_use_ability(A))
		selected_ability.use_ability(A)
	return TRUE


/atom/proc/ShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_SHIFT, user)
	return TRUE

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)


/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)


/atom/movable/CtrlClick(mob/user)
	. = ..()
	var/mob/living/L = user
	if(istype(L))
		L.start_pulling(src)


/mob/living/carbon/human/CtrlClick(mob/user)
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated())
		return ..()

	if(world.time < user.next_move)
		return FALSE
	var/mob/living/carbon/human/H = user
	H.start_pulling(src)


/*
	Alt click
*/
/mob/proc/AltClickOn(atom/A)
	switch(SEND_SIGNAL(src, COMSIG_MOB_CLICK_ALT, A))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	A.AltClick(src)
	return TRUE


/atom/proc/AltClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_ALT, user)
	var/turf/examined_turf = get_turf(src)
	if(examined_turf && user.TurfAdjacent(examined_turf))
		user.listed_turf = examined_turf
		user.client.statpanel = examined_turf.name
	return TRUE


/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)


/*
	Control+Shift click
	Unused except for AI
*/
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return


/mob/proc/ShiftMiddleClickOn(atom/A)
	return


/mob/living/ShiftMiddleClickOn(atom/A)
	point_to(A)


/atom/proc/CtrlShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL_SHIFT)
	return


/*
	Ctrl+Middle click
*/
/atom/proc/CtrlMiddleClickOn(atom/A)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL_MIDDLE, A)


// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/A)
	if(buckled || stat != CONSCIOUS || !A || !x || !y || !A.x || !A.y)
		return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) // Wall items are graphically shifted but on the floor
		if(A.pixel_y > 16)
			setDir(NORTH)
		else if(A.pixel_y < -16)
			setDir(SOUTH)
		else if(A.pixel_x > 16)
			setDir(EAST)
		else if(A.pixel_x < -16)
			setDir(WEST)
		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			setDir(NORTH)
		else
			setDir(SOUTH)
	else
		if(dx > 0)
			setDir(EAST)
		else
			setDir(WEST)


/obj/screen/proc/scale_to(x1,y1)
	if(!y1)
		y1 = x1
	var/matrix/M = new
	M.Scale(x1,y1)
	transform = M


/obj/screen/click_catcher
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"


#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / world.icon_size)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32)			//Not using world.icon_size on purpose.


/obj/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
	var/icon/newicon = icon('icons/mob/screen/generic.dmi', "catcher")
	var/ox = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_x)
	var/oy = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_y)
	var/px = view_size_x * world.icon_size
	var/py = view_size_y * world.icon_size
	var/sx = min(MAX_SAFE_BYOND_ICON_SCALE_PX, px)
	var/sy = min(MAX_SAFE_BYOND_ICON_SCALE_PX, py)
	newicon.Scale(sx, sy)
	icon = newicon
	screen_loc = "CENTER-[(ox-1)*0.5],CENTER-[(oy-1)*0.5]"
	var/matrix/M = new
	M.Scale(px/sx, py/sy)
	transform = M


/obj/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.swap_hand()
	else
		var/turf/T = params2turf(modifiers["screen-loc"], get_turf(usr.client ? usr.client.eye : usr), usr.client)
		params += "&catcher=1"
		if(T)
			//icon-x/y is relative to the object clicked. click_catcher may occupy several tiles. Here we convert them to the proper offsets relative to the tile.
			modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
			modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
			T.Click(location, control, list2params(modifiers))
	. = TRUE


/* MouseWheelOn */
/mob/proc/MouseWheelOn(atom/A, delta_x, delta_y, params)
	return


/mob/proc/check_click_intercept(params,A)
	//Client level intercept
	if(client?.click_intercept)
		if(call(client.click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	//Mob level intercept
	if(click_intercept)
		if(call(click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	return FALSE


/datum/proc/InterceptClickOn(mob/user, params, atom/object)
	return FALSE
