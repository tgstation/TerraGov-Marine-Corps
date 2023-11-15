//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.
#define MAX_CONVEYOR_ITEMS_MOVE 30
GLOBAL_LIST_EMPTY(conveyors_by_id)

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_map"
	name = "conveyor belt"
	desc = "A conveyor belt. It can be rotated with a <b>wrench</b>. It can be reversed with a <b>screwdriver</b>. The belt can be flipped with a <b>wirecutter</b>."
	layer = FIREDOOR_OPEN_LAYER
	max_integrity = 50
	resistance_flags = XENO_DAMAGEABLE
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id = ""			// the control ID	- must match controller ID
	/// Inverts the direction the conveyor belt moves when false.
	var/verted = FALSE
	/// Is the conveyor's belt flipped? Useful mostly for conveyor belt corners. It makes the belt point in the other direction, rather than just going in reverse.
	var/flipped = FALSE
	/// Are we currently conveying items?
	var/conveying = FALSE

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"

/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner pieces.
	icon_state = "conveyor_map_inverted"
	verted = -1
	flipped = TRUE

/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !(ISDIAGONALDIR(dir)))
		stack_trace("[src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")


/obj/machinery/conveyor/auto/update()
	. = ..()
	if(.)
		operating = TRUE
	update_icon()

// create a conveyor
/obj/machinery/conveyor/Initialize(mapload, newdir, newid)
	. = ..()
	if(newdir)
		setDir(newdir)
	if(newid)
		id = newid
	LAZYADD(GLOB.conveyors_by_id[id], src)
	update_move_direction()
	update_icon()

/obj/machinery/conveyor/auto/Initialize(mapload, newdir)
	operating = TRUE
	return ..()

/obj/machinery/conveyor/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()

/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH
	if(verted)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(flipped)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "conveyor-broken"
	else
		icon_state = "conveyor[verted ? -operating : operating ][flipped ? "-flipped" : ""]"

/obj/machinery/conveyor/proc/update()
	if(machine_stat & BROKEN || !operable || machine_stat & NOPOWER)
		operating = FALSE
		update_icon()
		return FALSE
	return TRUE

// machine process
// move items to the target location
/obj/machinery/conveyor/process()
	if(machine_stat & (BROKEN | NOPOWER))
		return

	//If the conveyor is broken or already moving items
	if(!operating || conveying)
		return

	//get the first 30 items in contents
	var/turf/locturf = loc
	var/list/items = locturf.contents - src
	if(!LAZYLEN(items))//Dont do anything at all if theres nothing there but the conveyor
		return
	var/list/affecting
	if(length(items) > MAX_CONVEYOR_ITEMS_MOVE)
		affecting = items.Copy(1, MAX_CONVEYOR_ITEMS_MOVE + 1)//Lists start at 1 lol
	else
		affecting = items
	conveying = TRUE

	INVOKE_NEXT_TICK(src, PROC_REF(convey), affecting)//Movement effect

/obj/machinery/conveyor/proc/convey(list/affecting)
	for(var/am in affecting)
		if(!ismovable(am))	//This is like a third faster than for(var/atom/movable in affecting)
			continue
		var/atom/movable/movable_thing = am
		//Give this a chance to yield if the server is busy
		stoplag()
		if(QDELETED(movable_thing) || (movable_thing.loc != loc))
			continue
		if(iseffect(movable_thing) || isdead(movable_thing))
			continue
		if(!movable_thing.anchored)
			step(movable_thing, movedir)
	conveying = FALSE

/obj/machinery/conveyor/crowbar_act(mob/living/user, obj/item/I)
	user.visible_message(span_notice("[user] struggles to pry up \the [src] with \the [I]."), \
	span_notice("You struggle to pry up \the [src] with \the [I]."))
	if(I.use_tool(src, user, 40, volume=40))
		if(!(machine_stat & BROKEN))
			new /obj/item/stack/conveyor(loc, 1, TRUE, id)
		to_chat(user, span_notice("You remove [src]."))
		qdel(src)
	return TRUE

/obj/machinery/conveyor/wrench_act(mob/living/user, obj/item/I)
	if(machine_stat & BROKEN)
		return TRUE
	I.play_tool_sound(src)
	setDir(turn(dir,-45))
	update_move_direction()
	to_chat(user, span_notice("You rotate [src]."))
	return TRUE

/obj/machinery/conveyor/screwdriver_act(mob/living/user, obj/item/I)
	if(machine_stat & BROKEN)
		return TRUE
	verted = !verted
	update_move_direction()
	to_chat(user, span_notice("You set [src]'s direction [verted ? "backwards" : "back to default"]."))

/obj/machinery/conveyor/wirecutter_act(mob/living/user, obj/item/I)
	if(machine_stat & BROKEN)
		return TRUE
	flipped = !flipped
	update_move_direction()
	to_chat(user, span_notice("You flip [src]'s belt [flipped ? "around" : "back to normal"]."))

/obj/machinery/conveyor/attackby(obj/item/I, mob/living/user, def_zone)
	. = ..()
	if(!. && user.a_intent != INTENT_HELP) //if we aren't in help mode drop item on conveyor
		user.transferItemToLoc(I, drop_location())

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	obj_break()
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, REVERSE_DIR(dir))
	if(C)
		C.set_operable(REVERSE_DIR(dir), id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/obj/machinery/conveyor/power_change()
	. = ..()
	update()

///////// the conveyor control switch

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"

	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/oneway = FALSE			// if the switch only operates the conveyor belts in a single direction.
	var/invert_icon = FALSE		// If the level points the opposite direction when it's turned on.

	var/id = "" 				// must match conveyor IDs to control them

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid
	update_icon()
	LAZYADD(GLOB.conveyors_by_id[id], src)

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()

/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

// update the icon depending on the position

/obj/machinery/conveyor_switch/update_icon_state()
	if(position<0)
		if(invert_icon)
			icon_state = "switch-fwd"
		else
			icon_state = "switch-rev"
	else if(position>0)
		if(invert_icon)
			icon_state = "switch-rev"
		else
			icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

/// Updates all conveyor belts that are linked to this switch, and tells them to start processing.
/obj/machinery/conveyor_switch/proc/update_linked_conveyors()
	for(var/obj/machinery/conveyor/C in GLOB.conveyors_by_id[id])
		C.operating = position
		C.update_move_direction()
		C.update_icon()
		if(C.operating)
			C.start_processing()
		else
			C.stop_processing()
		CHECK_TICK

/// Finds any switches with same `id` as this one, and set their position and icon to match us.
/obj/machinery/conveyor_switch/proc/update_linked_switches()
	for(var/obj/machinery/conveyor_switch/S in GLOB.conveyors_by_id[id])
		S.invert_icon = invert_icon
		S.position = position
		S.update_icon()
		CHECK_TICK

/// Updates the switch's `position` and `last_pos` variable. Useful so that the switch can properly cycle between the forwards, backwards and neutral positions.
/obj/machinery/conveyor_switch/proc/update_position()
	if(position == 0)
		if(oneway)   //is it a oneway switch
			position = oneway
		else
			if(last_pos < 0)
				position = 1
				last_pos = 0
			else
				position = -1
				last_pos = 0
	else
		last_pos = position
		position = 0

/// Called when a user clicks on this switch with an open hand.
/obj/machinery/conveyor_switch/interact(mob/user)
	if(!isliving(user))
		return
	add_fingerprint(user, "interact")
	update_position()
	update_icon()
	update_linked_conveyors()
	update_linked_switches()


/obj/machinery/conveyor_switch/crowbar_act(mob/living/user, obj/item/I)
	var/obj/item/conveyor_switch_construct/C = new/obj/item/conveyor_switch_construct(src.loc)
	C.id = id
	to_chat(user, span_notice("You detach the conveyor switch."))
	qdel(src)


/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	oneway = TRUE

/obj/machinery/conveyor_switch/oneway/Initialize(mapload)
	. = ..()
	if((dir == NORTH) || (dir == WEST))
		invert_icon = TRUE

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	var/id = "" //inherited by the switch

/obj/item/conveyor_switch_construct/Initialize(mapload)
	. = ..()
	id = "[rand()]" //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/attack_self(mob/user)
	for(var/obj/item/stack/conveyor/C in view())
		C.id = id
	to_chat(user, span_notice("You have linked all nearby conveyor belt assemblies to this switch."))

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id == src.id)
			found = 1
			break
	if(!found)
		to_chat(user, "[icon2html(src, user)]<span class=notice>The conveyor switch did not detect any linked conveyor belts in range.</span>")
		return
	new/obj/machinery/conveyor_switch(A, id)
	qdel(src)

/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	///id for linking
	var/id = ""

/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/cdir = get_dir(A, user)
	if(A == user.loc)
		to_chat(user, span_warning("You cannot place a conveyor belt under yourself!"))
		return
	new/obj/machinery/conveyor(A, cdir, id)
	use(1)

/obj/item/stack/conveyor/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/conveyor_switch_construct))
		to_chat(user, span_notice("You link the switch to the conveyor belt assembly."))
		var/obj/item/conveyor_switch_construct/C = I
		id = C.id

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/thirty
	amount = 30

#undef MAX_CONVEYOR_ITEMS_MOVE
