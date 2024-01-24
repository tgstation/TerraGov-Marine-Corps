/**
 * Delays the mob's next click/action by num deciseconds
 * eg: 10 - 3 = 7 deciseconds of delay
 * eg: 10 * 0.5 = 5 deciseconds of delay
 * DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK
 */
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
		usr.ClickOn(src, location, params)


/atom/DblClick(location, control, params)
	if(flags_atom & INITIALIZED)
		usr.DblClickOn(src, params)


/atom/MouseWheel(delta_x, delta_y, location, control, params)
	if(flags_atom & INITIALIZED)
		usr.MouseWheelOn(src, delta_x, delta_y, params)


/**
 * Standard mob ClickOn()
 * Handles exceptions: Buildmode, middle click, modified clicks, mech actions
 *
 * Does a few checks to make sure you are allowed to click, after which we look at modifiers and call the appropriate click proc
 */
/mob/proc/ClickOn(atom/target, location, params)

	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params, target))
		return

	if(notransform)
		return

	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, target, params) & COMSIG_MOB_CLICK_CANCELED)
		return

	var/list/modifiers = params2list(params)
	if(isnull(location) && target.plane == CLICKCATCHER_PLANE) //Checks if the intended target is in deep darkness and adjusts target based on params.
		target = params2turf(modifiers["screen-loc"], get_turf(client.eye), client)
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
		params = list2params(modifiers)

	if(incapacitated(TRUE))
		return

	face_atom(target)

	if(next_move > world.time)
		return

	if(!modifiers["catcher"] && target.IsObscured())
		return

	if(restrained())
		changeNext_move(CLICK_CD_HANDCUFFED)
		RestrainedClickOn(target)
		return

	//Right clicking
	if(modifiers["right"] && modifiers["ctrl"])
		CtrlRightClickOn(target, params)
		return
	if(modifiers["right"] && modifiers["shift"])
		ShiftRightClickOn(target, params)
		return
	if(modifiers["right"] && modifiers["alt"])
		AltRightClickOn(target, params)
		return
	if(modifiers["right"])
		RightClickOn(target, params)
		return

	//Middle clicking
	if(modifiers["middle"] && modifiers["ctrl"])
		CtrlMiddleClickOn(target, params)
		return
	if(modifiers["middle"] && modifiers["shift"])
		ShiftMiddleClickOn(target, params)
		return
	if(modifiers["middle"] && modifiers["alt"])
		AltMiddleClickOn(target, params)
		return
	if(modifiers["middle"])
		MiddleClickOn(target, params)
		return

	//Left clicking
	if(modifiers["ctrl"] && modifiers["shift"])
		CtrlShiftClickOn(target, params)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(target, params)
		return
	if(modifiers["shift"])
		ShiftClickOn(target, params)
		return
	if(modifiers["alt"])
		AltClickOn(target, params)
		return
	//If there's no modifiers, we simply left click
	LeftClickOn(target, params)

/**
 *
 * Just checks your state, check whether you're holding an item,
 * check whether you're adjacent to the target, then pass off the click to whoever
 * is receiving it.
 * The most common are:
 * * mob/UnarmedAttack(atom, adjacent, params) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
 * * atom/attackby(item, user, params) - used only when adjacent
 * * item/afterattack(atom, user, adjacent, params) - used both ranged and adjacent when not handled by attackby
 * * mob/RangedAttack(atom, params) - used only ranged, only used for tk and laser eyes but could be changed
 */
/mob/proc/item_click(atom/target, params)
	if(in_throw_mode)
		if(throw_item(target))
			changeNext_move(CLICK_CD_THROWING)
		return TRUE

	var/list/modifiers = params2list(params)
	var/obj/item/item_clicked_on = get_active_held_item()

	if(item_clicked_on == target)
		if(modifiers["right"])
			item_clicked_on.attack_self_alternate(src)
		else
			item_clicked_on.attack_self(src)
		update_inv_l_hand()
		update_inv_r_hand()
		return TRUE

	//These are always reachable.
	//User itself, current loc, and user inventory
	if(target in DirectAccess())
		if(item_clicked_on)
			item_clicked_on.melee_attack_chain(src, target, params, modifiers["right"])
		else
			UnarmedAttack(target, FALSE, modifiers)
		return TRUE

	//Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	//Standard reach turf to turf or reaching inside storage
	if(CanReach(target, item_clicked_on))
		if(item_clicked_on)
			item_clicked_on.melee_attack_chain(src, target, params, modifiers["right"])
		else
			UnarmedAttack(target, TRUE, modifiers)
	else
		if(item_clicked_on)
			var/proximity = target.Adjacent(src)
			if(!proximity || !target.attackby(item_clicked_on, src, params))
				item_clicked_on.afterattack(target, src, proximity, params)
		else
			if(target.Adjacent(src))
				target.attack_hand(src)
			RangedAttack(target, params)


/atom/movable/proc/CanReach(atom/ultimate_target, obj/item/tool, view_only = FALSE)
	// A backwards depth-limited breadth-first-search to see if the target is
	// logically "in" anything adjacent to us.
	var/list/direct_access = DirectAccess()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)
	while(length(checking) && depth > 0)
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
	return GetAllContents() + loc


/atom/proc/IsObscured()
	if(!isturf(loc)) //This only makes sense for things directly on turfs for now
		return FALSE
	var/turf/T = get_turf_pixel(src)
	if(!T)
		return FALSE
	for(var/atom/movable/AM AS in T)
		if(AM.flags_atom & PREVENT_CLICK_UNDER && AM.density && AM.layer > layer)
			return TRUE
	return FALSE


/turf/IsObscured()
	for(var/atom/movable/AM AS in src)
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
			dummy.allow_pass_flags |= PASS_LOW_STRUCTURE
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


/**
 *Translates into attack_hand, etc.
 *
 * has_proximity is TRUE if this afterattack was called on something adjacent, in your square, or on your person.
 *
 * has_proximity is not currently passed to attack_hand, and is instead used
 * in human click code to allow glove touches only at melee range.
 *
 * params is passed on here as the third arg
 */
/mob/proc/UnarmedAttack(atom/A, has_proximity, params)
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

/**
 * Right Clicking
 */

///Called when a owner mob Rightmouseclicks an atom
/mob/proc/RightClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_RIGHT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE

	if(item_click(target, params))
		return

	return target.RightClick(src)

///Called when a mob Rightmouseclicks this atom
/atom/proc/RightClick(mob/user)
	SEND_SIGNAL(src, COMSIG_RIGHT_CLICK, user)

/mob/living/carbon/human/RightClickOn(atom/target, params)
	var/obj/item/held_thing = get_active_held_item()

	if(held_thing && SEND_SIGNAL(held_thing, COMSIG_ITEM_RIGHTCLICKON, target, src) & COMPONENT_ITEM_CLICKON_BYPASS)
		return FALSE
	return ..()

/mob/living/carbon/xenomorph/RightClickOn(atom/target)
	if(selected_ability) //If we have a selected ability that we can use, return TRUE
		target = ability_target(target)
		if(selected_ability.can_use_ability(target))
			selected_ability.use_ability(target)
			return !CHECK_BITFIELD(selected_ability.use_state_flags, ABILITY_DO_AFTER_ATTACK)
	return ..()

///Called when a owner mob CTRL + Rightmouseclicks an atom
/mob/proc/CtrlRightClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_CTRL_RIGHT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.CtrlRightClick(src)

///Called when a mob CTRL + Rightmouseclicks this atom
/atom/proc/CtrlRightClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CTRL_RIGHT_CLICK, user)

///Called when a owner mob SHIFT + Rightmouseclicks an atom
/mob/proc/ShiftRightClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_SHIFT_RIGHT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.ShiftRightClick(src)

///Called when a mob SHIFT + Rightmouseclicks this atom
/atom/proc/ShiftRightClick(mob/user)
	SEND_SIGNAL(src, COMSIG_SHIFT_RIGHT_CLICK, user)

///Called when a owner mob ALT + Rightmouseclicks an atom
/mob/proc/AltRightClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_ALT_RIGHT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.AltRightClick(src)

///Called when a mob ALT + Rightmouseclicks this atom
/atom/proc/AltRightClick(mob/user)
	SEND_SIGNAL(src, COMSIG_ALT_RIGHT_CLICK, user)

/**
 * Middle Clicking
 */

///Called when a owner mob Middlemouseclicks an atom
/mob/proc/MiddleClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_MIDDLE_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE

	if(item_click(target, params))
		return

	return target.MiddleClick(src)

///Called when a mob Middlemouseclicks this atom
/atom/proc/MiddleClick(mob/user)
	SEND_SIGNAL(src, COMSIG_MIDDLE_CLICK, user)

/mob/living/carbon/human/MiddleClickOn(atom/target)
	. = ..()
	if(!(client.prefs.toggles_gameplay & MIDDLESHIFTCLICKING))
		return
	var/obj/item/held_thing = get_active_held_item()
	if(held_thing && SEND_SIGNAL(held_thing, COMSIG_ITEM_MIDDLECLICKON, target, src) & COMPONENT_ITEM_CLICKON_BYPASS)
		return FALSE

	if(!selected_ability)
		return FALSE
	target = ability_target(target)
	if(selected_ability.can_use_ability(target))
		selected_ability.use_ability(target)

#define TARGET_FLAGS_MACRO(flagname, typepath) \
if(selected_ability.target_flags & flagname && !istype(target, typepath)){\
	. = locate(typepath) in get_turf(target);\
	if(.){\
		return;}}

/mob/living/carbon/proc/ability_target(atom/target)
	TARGET_FLAGS_MACRO(ABILITY_MOB_TARGET, /mob/living)
	if(selected_ability.target_flags & ABILITY_TURF_TARGET)
		return get_turf(target)
	return target

/mob/living/carbon/xenomorph/MiddleClickOn(atom/target)
	if(!(client.prefs.toggles_gameplay & MIDDLESHIFTCLICKING) || !selected_ability)
		return FALSE
	target = ability_target(target)
	if(selected_ability.can_use_ability(target))
		selected_ability.use_ability(target)
	return ..()

///Called when a owner mob CTRL + Middlemouseclicks an atom
/mob/proc/CtrlMiddleClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_CTRL_MIDDLE_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.CtrlMiddleClick(src)

///Called when a mob CTRL + Middlemouseclicks this atom
/atom/proc/CtrlMiddleClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CTRL_MIDDLE_CLICK, user)

///Called when a owner mob SHIFT + Middlemouseclicks an atom
/mob/proc/ShiftMiddleClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_SHIFT_MIDDLE_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	point_to(target)
	return target.ShiftMiddleClick(src)

///Called when a mob SHIFT + Middlemouseclicks this atom
/atom/proc/ShiftMiddleClick(mob/user)
	SEND_SIGNAL(src, COMSIG_SHIFT_MIDDLE_CLICK, user)

///Called when a owner mob ALT + Middlemouseclicks an atom
/mob/proc/AltMiddleClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_ALT_MIDDLE_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.AltMiddleClick(src)

///Called when a mob ALT + Middlemouseclicks this atom
/atom/proc/AltMiddleClick(mob/user)
	SEND_SIGNAL(src, COMSIG_ALT_MIDDLE_CLICK, user)

/**
 * Left Clicking
 */

///Called when a owner mob Leftmouseclicks an atom
/mob/proc/LeftClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_LEFT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE

	if(item_click(target, params))
		return

	return target.LeftClick(src)

/atom/proc/LeftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_LEFT_CLICK, user)

///Called when a owner mob CTRL + Leftmouseclicks an atom
/mob/proc/CtrlClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_CTRL_LEFT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.CtrlClick(src)

///Called when a mob CTRL + Leftmouseclicks this atom
/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CTRL_LEFT_CLICK, user)

/atom/movable/CtrlClick(mob/user)
	. = ..()
	var/mob/living/L = user
	if(istype(L))
		return L.start_pulling(src)

/mob/living/carbon/human/CtrlClick(mob/user)
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated())
		return ..()

	if(world.time < user.next_move)
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.start_pulling(src)

///Called when a owner mob SHIFT + Leftmouseclicks an atom
/mob/proc/ShiftClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_SHIFT_LEFT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE

	if(examinate(target))
		return

	return target.ShiftClick(src)

///Called when a mob SHIFT + Leftmouseclicks this atom
/atom/proc/ShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_SHIFT_LEFT_CLICK, user)

/mob/living/carbon/human/ShiftClickOn(atom/target)
	if(client.prefs.toggles_gameplay & MIDDLESHIFTCLICKING)
		return ..()
	var/obj/item/held_thing = get_active_held_item()

	if(held_thing && SEND_SIGNAL(held_thing, COMSIG_ITEM_SHIFTCLICKON, target, src) & COMPONENT_ITEM_CLICKON_BYPASS)
		return FALSE
	return ..()

/mob/living/carbon/xenomorph/ShiftClickOn(atom/target)
	if(!selected_ability || (client.prefs.toggles_gameplay & MIDDLESHIFTCLICKING))
		return ..()
	target = ability_target(target)
	if(selected_ability.can_use_ability(target))
		selected_ability.use_ability(target)
	return TRUE

///Called when a owner mob ALT + Leftmouseclicks an atom
/mob/proc/AltClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_ALT_LEFT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.AltClick(src)

///Called when a mob ALT + Leftmouseclicks this atom
/atom/proc/AltClick(mob/user)
	SEND_SIGNAL(src, COMSIG_ALT_LEFT_CLICK, user)
	var/turf/T = get_turf(src)
	if(T && (isturf(loc) || isturf(src)) && user.TurfAdjacent(T))
		user.set_listed_turf(T)
	return TRUE

///Called when a owner mob CTRL + SHIFT + Leftmouseclicks an atom
/mob/proc/CtrlShiftClickOn(atom/target, params)
	switch(SEND_SIGNAL(src, COMSIG_MOB_CTRL_SHIFT_LEFT_CLICK, target))
		if(COMSIG_MOB_CLICK_CANCELED)
			return FALSE
		if(COMSIG_MOB_CLICK_HANDLED)
			return TRUE
	return target.CtrlShiftClick(src)

///Called when a mob CTRL + SHIFT + Leftmouseclicks this atom
/atom/proc/CtrlShiftClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CTRL_SHIFT_LEFT_CLICK, user)

/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)

/atom/movable/screen/proc/scale_to(x1,y1)
	if(!y1)
		y1 = x1
	var/matrix/M = new
	M.Scale(x1,y1)
	transform = M


/atom/movable/screen/click_catcher
	icon = 'icons/mob/screen/generic.dmi'
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"


#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / world.icon_size)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32)			//Not using world.icon_size on purpose.


/atom/movable/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
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


/atom/movable/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	var/turf/T = params2turf(modifiers["screen-loc"], get_turf(usr.client ? usr.client.eye : usr), usr.client)
	params += "&catcher=1"
	if(T)
		//icon-x/y is relative to the object clicked. click_catcher may occupy several tiles. Here we convert them to the proper offsets relative to the tile.
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
		T.Click(location, control, list2params(modifiers))
	. = TRUE

/atom/movable/screen/click_catcher/MouseMove(location, control, params)//This allow to catch mouse drag on click catcher, aka black tiles
	return


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
