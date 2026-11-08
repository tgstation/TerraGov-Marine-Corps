
/obj/structure/barricade
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	atom_flags = ON_BORDER
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY | BLOCKS_CONSTRUCTION_DIR
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_DEFENSIVE_STRUCTURE|PASSABLE|PASS_WALKOVER
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	max_integrity = 100
	barrier_flags = HANDLE_BARRIER_CHANCE
	base_icon_state = "barricade"
	///The type of stack the barricade dropped when disassembled if any.
	var/obj/item/stack/stack_type //typecast so we can query initial vars
	///The amount of stack dropped when disassembled at full health
	var/stack_amount = 5
	///to specify a non-zero amount of stack to drop when destroyed
	var/destroyed_stack_amount = 0
	///Barricade behavior flags
	var/barricade_flags = BARRICADE_DAMAGE_STATES
	///Build state of the barricade
	var/build_state = BARRICADE_FIRM
	///The skill level for maintaining this barricade
	var/skill_level = SKILL_ENGINEER_METAL

/obj/structure/barricade/Initialize(mapload, mob/user)
	. = ..()
	update_appearance(UPDATE_ICON)
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit),
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)
	if(user)
		faction = user.faction

	AddComponent(/datum/component/climbable, 2 SECONDS)

/obj/structure/barricade/handle_barrier_chance(mob/living/M)
	return prob(max(30,(100.0*obj_integrity)/max_integrity))

/obj/structure/barricade/examine(mob/user)
	. = ..()
	if(barricade_flags & BARRICADE_IS_WIRED)
		. += span_info("There is a length of wire strewn across the top of this barricade.")
	switch((obj_integrity / max_integrity) * 100)
		if(75 to INFINITY)
			. += span_info("It appears to be in good shape.")
		if(50 to 75)
			. += span_warning("It's slightly damaged, but still very functional.")
		if(25 to 50)
			. += span_warning("It's quite beat up, but it's holding together.")
		if(-INFINITY to 25)
			. += span_warning("It's crumbling apart, just a few more blows will tear it apart.")
	if(!(barricade_flags & BARRICADE_CAN_MOVE))
		return
	switch(build_state)
		if(BARRICADE_FIRM)
			. += span_info("The protection panel is still tighly screwed in place.")
		if(BARRICADE_ANCHORED)
			. += span_info("The protection panel has been removed, you can see the anchor bolts.")
		if(BARRICADE_LOOSE)
			. += span_info("The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.")

/obj/structure/barricade/on_try_exit(datum/source, atom/movable/mover, direction, list/knownblockers)
	. = ..()

	if(mover?.throwing && !CHECK_MULTIPLE_BITFIELDS(mover?.pass_flags, HOVERING) && density && (barricade_flags & BARRICADE_IS_WIRED) && iscarbon(mover) && (direction & dir))
		knownblockers += src
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, turf/target)
	if(get_dir(loc, target) & dir)
		if(!CHECK_MULTIPLE_BITFIELDS(mover?.pass_flags, HOVERING) && (barricade_flags & BARRICADE_IS_WIRED) && density && ismob(mover))
			return FALSE
		if(istype(mover, /obj/effect/xenomorph)) //cades stop xeno effects like acid spray
			return FALSE

	return ..()

/obj/structure/barricade/setDir(newdir)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/structure/barricade/update_icon_state()
	var/damage_state
	var/percentage = (obj_integrity / max_integrity) * 100
	switch(percentage)
		if(-INFINITY to 25)
			damage_state = 3
		if(25 to 50)
			damage_state = 2
		if(50 to 75)
			damage_state = 1
		if(75 to INFINITY)
			damage_state = 0

	if(barricade_flags & BARRICADE_OPEN)
		icon_state = (barricade_flags & BARRICADE_DAMAGE_STATES) ? "[base_icon_state]_open_[damage_state]" : "[base_icon_state]_open"
		layer = OBJ_LAYER
		return

	icon_state = (barricade_flags & BARRICADE_DAMAGE_STATES) ? "[base_icon_state]_[damage_state]" : "[base_icon_state]"
	if(!anchored)
		layer = initial(layer)
		return
	switch(dir)
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
		if(NORTH)
			layer = initial(layer) - 0.01
		else
			layer = initial(layer)

/obj/structure/barricade/update_overlays()
	. = ..()
	if(!(barricade_flags & BARRICADE_IS_WIRED))
		return
	if(barricade_flags & BARRICADE_OPEN)
		. += image(icon, icon_state = "[base_icon_state]_open_wire")
	else
		. += image(icon, icon_state = "[base_icon_state]_wire", layer = dir == NORTH ? layer : ABOVE_MOB_LAYER) //it will layer under certain upgrades in some cases otherwise

/obj/structure/barricade/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	. = return_stack(disassembled)
	..()

///Refunds stacks on destruction or disassembly
/obj/structure/barricade/proc/return_stack(disassembled = TRUE)
	. = list()
	if(disassembled && (barricade_flags & BARRICADE_IS_WIRED))
		. += new /obj/item/stack/barbed_wire(loc)
	var/stack_amt = destroyed_stack_amount
	if(disassembled)
		stack_amt = round(stack_amount * (obj_integrity/max_integrity)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0
	if(stack_amt)
		. += new stack_type (loc, stack_amt)

///How much this cade should be repaired by any ordinary effect
/obj/structure/barricade/proc/get_repair_amount()
	return ROUND_UP(max_integrity / stack_amount)

///Adds barbed wire
/obj/structure/barricade/proc/wire()
	DISABLE_BITFIELD(barricade_flags, BARRICADE_CAN_WIRE)
	barricade_flags |= BARRICADE_IS_WIRED
	remove_component(/datum/component/climbable)
	modify_max_integrity(max_integrity + 50)
	update_appearance(UPDATE_ICON)

/obj/structure/barricade/verb/rotate()
	set name = "Rotate Barricade Counter-Clockwise"
	set category = "IC.Object"
	set src in oview(1)

	if(anchored)
		balloon_alert(usr, "fastened to the floor")
		return FALSE

	setDir(turn(dir, 90))

/obj/structure/barricade/verb/revrotate()
	set name = "Rotate Barricade Clockwise"
	set category = "IC.Object"
	set src in oview(1)

	if(anchored)
		balloon_alert(usr, "fastened to the floor")
		return FALSE

	setDir(turn(dir, 270))
