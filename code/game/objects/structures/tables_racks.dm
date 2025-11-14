#define TABLE_STATUS_WEAKENED 1
#define TABLE_STATUS_FIRM 2

/obj/structure/table
	name = "table"
	desc = "A square metal surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/table_regular.dmi'
	icon_state = "table_regular-0"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	hit_sound = 'sound/effects/metalhit.ogg'
	coverage = 10
	smoothing_flags = SMOOTH_BITMASK
	base_icon_state = "table_regular"
	//determines if we drop metal on deconstruction
	var/dropmetal = TRUE
	var/parts = /obj/item/frame/table
	var/table_status = TABLE_STATUS_FIRM
	var/sheet_type = /obj/item/stack/sheet/metal
	var/table_prefix = "" //used in update_icon()
	var/reinforced = FALSE
	var/flipped = FALSE
	var/flip_cooldown = 0 //If flip cooldown exists, don't allow flipping or putting back. This carries a WORLD.TIME value
	max_integrity = 40
	smoothing_groups = list(SMOOTH_GROUP_TABLES_GENERAL)
	canSmoothWith = list(SMOOTH_GROUP_TABLES_GENERAL)

/obj/structure/table/Initialize(mapload)
	. = ..()
	for(var/obj/structure/table/evil_table in loc)
		if(evil_table != src)
			stack_trace("Duplicate table found in ([x], [y], [z])")
			qdel(evil_table)
	if(!flipped)
		update_icon()
		update_adjacent()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit),
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/table/Destroy()
	update_adjacent(loc) //so neighbouring tables get updated correctly
	return ..()

/obj/structure/table/deconstruct(disassembled)
	if(disassembled)
		new parts(loc)
		return ..()

	if(reinforced)
		if(prob(50))
			new /obj/item/stack/rods(loc)
	if(dropmetal)
		new sheet_type(src)
	return ..()

/obj/structure/table/update_icon_state()
	. = ..()
	if(flipped)
		var/ttype = 0
		var/tabledirs = 0
		for(var/direction in list(turn(dir, 90), turn(dir, -90)) )
			var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
			if (T?.flipped && T.dir == dir)
				ttype++
				tabledirs |= direction

		icon_state = "[table_prefix]flip[ttype]"
		if(ttype == 1)
			if(tabledirs & turn(dir,90))
				icon_state = icon_state+"-"
			if(tabledirs & turn(dir,-90))
				icon_state = icon_state+"+"
		return TRUE

//Flipping tables, nothing more, nothing less
/obj/structure/table/MouseDrop(over_object, src_location, over_location)

	..()

	if(flipped)
		do_put()
	else
		do_flip()

/obj/structure/table/MouseDrop_T(obj/item/I, mob/user)

	if (!istype(I) || user.get_active_held_item() != I)
		return ..()
	user.drop_held_item()
	if(I.loc != loc)
		step(I, get_dir(I, src))

/obj/structure/table/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(reinforced && table_status != TABLE_STATUS_WEAKENED)
		return FALSE

	user.visible_message(span_notice("[user] starts disassembling [src]."),
		span_notice("You start disassembling [src]."))

	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return TRUE

	user.visible_message(span_notice("[user] disassembles [src]."),
		span_notice("You disassemble [src]."))
	deconstruct(TRUE)
	return TRUE


/obj/structure/table/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(user.a_intent != INTENT_HARM)
		if(user.transferItemToLoc(I, loc))
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			return TRUE

/obj/structure/table/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	. = ..()
	if(.)
		playsound(loc, 'sound/weapons/tablehit1.ogg', 25, 1)
		return
	if(user.a_intent == INTENT_HARM)
		return
	if(user.grab_state < GRAB_AGGRESSIVE)
		return
	if(!isliving(grab.grabbed_thing))
		return

	var/mob/living/grabbed_mob = grab.grabbed_thing
	grabbed_mob.forceMove(loc)
	grabbed_mob.Paralyze(2 SECONDS)
	user.visible_message(span_danger("[user] throws [grabbed_mob] on [src]."),
	span_danger("You throw [grabbed_mob] on [src]."))
	return TRUE

///Updates connected tables when required
/obj/structure/table/proc/update_adjacent(location = loc)
	for(var/direction in CARDINAL_ALL_DIRS)
		var/obj/structure/table/table = locate(/obj/structure/table, get_step(location,direction))
		if(!table)
			continue
		INVOKE_NEXT_TICK(table, TYPE_PROC_REF(/atom, update_icon))

///Snowflake check to let ravagers kill tables
/obj/structure/table/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!istype(O,/mob/living/carbon/xenomorph/ravager))
		return
	var/mob/living/carbon/xenomorph/M = O
	if(!M.stat) //No dead xenos jumpin on the bed~
		visible_message(span_danger("[O] plows straight through [src]!"))
		deconstruct(FALSE)

/obj/structure/table/proc/straight_table_check(direction)
	var/obj/structure/table/T
	for(var/angle in list(-90, 90))
		T = locate() in get_step(loc, turn(direction, angle))
		if(T && !T.flipped)
			return FALSE
	T = locate() in get_step(loc, direction)
	if(!T || T.flipped)
		return TRUE
	if(istype(T, /obj/structure/table/reinforced))
		var/obj/structure/table/reinforced/R = T
		if(R.table_status == TABLE_STATUS_FIRM)
			return FALSE
	return T.straight_table_check(direction)


/obj/structure/table/verb/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table"
	set category = "IC.Object"
	set src in oview(1)

	if(!can_interact(usr))
		return

	if(!flip(get_cardinal_dir(usr, src)))
		to_chat(usr, span_warning("[src] won't budge."))
		return

	usr.visible_message(span_warning("[usr] flips [src]!"),
	span_warning("You flip [src]!"))

	if(climbable)
		structure_shaken()

	flip_cooldown = world.time + 50

/obj/structure/table/proc/unflipping_check(direction)

	if(world.time < flip_cooldown)
		return FALSE

	for(var/mob/living/blocker in loc)
		return FALSE

	var/list/L = list()
	if(direction)
		L.Add(direction)
	else
		L.Add(turn(src.dir,-90))
		L.Add(turn(src.dir,90))
	for(var/new_dir in L)
		var/obj/structure/table/T = locate() in get_step(loc, new_dir)
		if(T)
			if(T.flipped && T.dir == src.dir && !T.unflipping_check(new_dir))
				return FALSE
	for(var/obj/structure/S in loc)
		if((S.atom_flags & ON_BORDER) && S.density && S != src) //We would put back on a structure that wouldn't allow it
			return FALSE
	return TRUE

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back"
	set category = "IC.Object"
	set src in oview(1)

	if(!can_interact(usr))
		return

	if(!unflipping_check())
		to_chat(usr, span_warning("[src] won't budge."))
		return

	unflip(TRUE)

	flip_cooldown = world.time + 50


/obj/structure/table/proc/flip(direction, forced)
	if(!forced && world.time < flip_cooldown)
		return FALSE

	if(!straight_table_check(turn(direction, 90)) || !straight_table_check(turn(direction, -90)))
		return FALSE

	verbs -= /obj/structure/table/verb/do_flip
	verbs += /obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src, dir), get_step(src, turn(dir, 45)),get_step(src, turn(dir, -45)))
	for(var/i in get_turf(src))
		if(isobserver(i))
			continue
		var/atom/movable/thing_to_throw = i
		if(thing_to_throw.anchored || thing_to_throw.move_resist == INFINITY)
			continue
		thing_to_throw.throw_at(pick(targets), 1, 1)

	setDir(direction)
	if(dir != NORTH)
		layer = FLY_LAYER
	flipped = TRUE
	obj_flags ^= BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	coverage = 60
	atom_flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src,D)
		if(T && !T.flipped)
			T.flip(direction)
	update_icon()
	update_adjacent()

	return TRUE


/obj/structure/table/proc/unflip()

	verbs -=/obj/structure/table/proc/do_put
	verbs +=/obj/structure/table/verb/do_flip

	layer = initial(layer)
	flipped = FALSE
	coverage = 10
	climbable = initial(climbable)
	atom_flags &= ~ON_BORDER
	obj_flags ^= BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(src.loc,D)
		if(T?.flipped && T.dir == src.dir)
			T.unflip()
	update_icon()
	update_adjacent()
	QUEUE_SMOOTH(src)

	return TRUE


/obj/structure/table/flipped
	flipped = TRUE //Just not to get the icon updated on Initialize()
	coverage = 60


/obj/structure/table/flipped/Initialize(mapload)
	. = ..()
	flipped = FALSE //We'll properly flip it in LateInitialize()
	return INITIALIZE_HINT_LATELOAD


/obj/structure/table/flipped/LateInitialize()
	. = ..()
	if(!flipped)
		flip(dir, TRUE)


/*
* Wooden tables
*/
/obj/structure/table/wood
	name = "wooden table"
	desc = "A square wood surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/wood_table_reinforced.dmi'
	icon_state = "wood_table_reinforced-0"
	sheet_type = /obj/item/stack/sheet/wood
	parts = /obj/item/frame/table/wood
	base_icon_state = "wood_table_reinforced"
	table_prefix = "wood"
	hit_sound = 'sound/effects/natural/woodhit.ogg'
	max_integrity = 20

/obj/structure/table/wood/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/table/wood/footstep_override(atom/movable/source, list/footstep_overrides)
	footstep_overrides[FOOTSTEP_WOOD] = layer

/obj/structure/table/wood/fancy
	name = "fancy wooden table"
	desc = "An expensive fancy wood surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/fancy_table.dmi'
	icon_state = "fancy_table-0"
	base_icon_state = "fancy_table"
	table_prefix = "fwood"
	parts = /obj/item/frame/table/fancywood

/obj/structure/table/wood/rustic
	name = "rustic wooden table"
	desc = "A rustic wooden surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/rustic_table.dmi'
	icon_state = "rustic_table-0"
	base_icon_state = "rustic_table"
	table_prefix = "pwood"
	parts = /obj/item/frame/table/rusticwood

/obj/structure/table/wood/gambling
	name = "gambling table"
	desc = "A curved wood and carpet surface resting on four legs. Used for gambling games. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/pool_table.dmi'
	icon_state = "pool_table-0"
	base_icon_state = "pool_table"
	sheet_type = /obj/item/stack/sheet/wood
	parts = /obj/item/frame/table/gambling
	table_prefix = "gamble"
	hit_sound = 'sound/effects/natural/woodhit.ogg'
	max_integrity = 20

/obj/structure/table/wood/gambling/urban
	icon = 'icons/obj/smooth_objects/urban_table_gambling.dmi'
	icon_state = "urban_table_gambling-0"
	base_icon_state = "urban_table_gambling"
	parts = /obj/item/frame/table/gambling

/obj/structure/table/wood/gambling/urban/black
	icon = 'icons/obj/smooth_objects/urban_table_gambling_black.dmi'
	icon_state = "urban_table_gambling_black-0"
	base_icon_state = "urban_table_gambling_black"
	parts = /obj/item/frame/table/gambling

/obj/structure/table/black
	name = "black metal table"
	desc = "A sleek black metallic surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/black_table.dmi'
	icon_state = "black_table-0"
	base_icon_state = "black_table"
	table_prefix = "black"
	parts = /obj/item/frame/table

/obj/structure/table/urban/shiny_black
	name = "shiny black metal table"
	desc = "A shiny black metallic surface resting on four legs, looks like it belongs in a boardroom. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/urban_table_black.dmi'
	icon_state = "urban_table_black-0"
	base_icon_state = "urban_table_black"
	table_prefix = "urban_table_black"
	parts = /obj/item/frame/table

/obj/structure/table/urban/shiny_brown
	name = "shiny brown metal table"
	desc = "A shiny brown metallic surface resting on four legs, looks like it belongs in a boardroom. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/smooth_objects/urban_table_brown.dmi'
	icon_state = "urban_table_brown-0"
	base_icon_state = "urban_table_brown"
	table_prefix = "urban_table_brown"
	parts = /obj/item/frame/table

/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon = 'icons/obj/smooth_objects/table_reinforced.dmi'
	icon_state = "table_reinforced-0"
	base_icon_state = "table_reinforced"
	max_integrity = 100
	reinforced = TRUE
	table_prefix = "reinf"
	parts = /obj/item/frame/table/reinforced


/obj/structure/table/reinforced/flipped
	flipped = TRUE
	table_status = TABLE_STATUS_WEAKENED


/obj/structure/table/reinforced/flipped/Initialize(mapload)
	. = ..()
	flipped = FALSE
	return INITIALIZE_HINT_LATELOAD


/obj/structure/table/reinforced/flipped/LateInitialize()
	. = ..()
	if(!flipped)
		flip(dir, TRUE)


/obj/structure/table/reinforced/flip(direction, forced)
	if(!forced && table_status == TABLE_STATUS_FIRM)
		return FALSE
	return ..()


/obj/structure/table/reinforced/welder_act(mob/living/user, obj/item/I)
	. = ..()
	var/obj/item/tool/weldingtool/WT = I
	if(!WT.isOn())
		return FALSE

	if(table_status == TABLE_STATUS_FIRM)
		user.visible_message(span_notice("[user] starts weakening [src]."),
		span_notice("You start weakening [src]"))
		if(!I.use_tool(src, user, 5 SECONDS, 1, 25, null, BUSY_ICON_BUILD))
			return

		user.visible_message(span_notice("[user] weakens [src]."),
			span_notice("You weaken [src]"))
		table_status = TABLE_STATUS_WEAKENED
		return TRUE

	user.visible_message(span_notice("[user] starts welding [src] back together."),
		span_notice("You start welding [src] back together."))
	if(!I.use_tool(src, user, 5 SECONDS, 1, 25, null, BUSY_ICON_BUILD))
		return

	user.visible_message(span_notice("[user] welds [src] back together."),
		span_notice("You weld [src] back together."))
	table_status = TABLE_STATUS_FIRM
	return TRUE

/obj/structure/table/reinforced/weak //used for the icon, functionally similar to a table.
	name = "rickety reinforced table"
	desc = "A square metal surface resting on four legs. It has seen better days to whence it was strong."
	max_integrity = 40

/obj/structure/table/reinforced/prison
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon = 'icons/obj/smooth_objects/prison_table.dmi'
	icon_state = "prison_table-0"
	base_icon_state = "prison_table"
	table_prefix = "prison"

/obj/structure/table/reinforced/fabric
	name = "cloth table"
	desc = "A fancy cloth-topped wooden table, bolted to the floor. Fit for formal occasions."
	icon = 'icons/obj/smooth_objects/table_fabric.dmi'
	icon_state = "table_fabric-0"
	base_icon_state = "table_fabric"
	table_prefix = "fabric"
	parts = /obj/item/frame/table
	reinforced = TRUE

/obj/structure/table/mainship
	icon = 'icons/obj/smooth_objects/mainship_table.dmi'
	icon_state = "mainship_table-0"
	base_icon_state = "mainship_table"
	table_prefix = "ship"
	parts = /obj/item/frame/table/mainship

/obj/structure/table/mainship/nometal
	parts = /obj/item/frame/table/mainship/nometal
	dropmetal = FALSE

/*
* Racks
*/
/obj/structure/rack
	name = "rack"
	desc = "A bunch of metal shelves stacked on top of eachother. Excellent for storage purposes, less so as cover."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = TRUE
	layer = TABLE_LAYER
	anchored = TRUE
	coverage = 20
	climbable = TRUE
	var/dropmetal = TRUE   //if true drop metal when destroyed; mostly used when we need large amounts of racks without marines hoarding the metal
	max_integrity = 40
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE
	var/parts = /obj/item/frame/rack

/obj/structure/rack/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/rack/MouseDrop_T(obj/item/I, mob/user)
	if (!istype(I) || user.get_active_held_item() != I)
		return ..()
	user.drop_held_item()
	if(I.loc != loc)
		step(I, get_dir(I, src))

/obj/structure/rack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswrench(I))
		deconstruct(TRUE)
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		return

	if(user.a_intent != INTENT_HARM)
		return user.transferItemToLoc(I, loc)


/obj/structure/rack/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!istype(O,/mob/living/carbon/xenomorph/ravager))
		return
	var/mob/living/carbon/xenomorph/M = O
	if(!M.stat) //No dead xenos jumpin on the bed~
		visible_message(span_danger("[O] plows straight through [src]!"))
		deconstruct(FALSE)

/obj/structure/rack/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(disassembled && parts && dropmetal)
		new parts(loc)
	else if(dropmetal)
		new /obj/item/stack/sheet/metal(loc)
	density = FALSE
	return ..()

/obj/structure/rack/nometal
	dropmetal = FALSE

/obj/structure/rack/lectern
	icon = 'icons/obj/metnal_objects.dmi'
	icon_state = "lectern"
	dropmetal = FALSE
	hit_sound = 'sound/effects/natural/woodhit.ogg'

/obj/structure/rack/wood
	color = "#8B7B5B"
	dropmetal = FALSE

#undef TABLE_STATUS_WEAKENED
#undef TABLE_STATUS_FIRM
