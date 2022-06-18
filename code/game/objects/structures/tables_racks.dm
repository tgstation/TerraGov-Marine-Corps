#define TABLE_STATUS_WEAKENED 1
#define TABLE_STATUS_FIRM 2

/obj/structure/table
	name = "table"
	desc = "A square metal surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon = 'icons/obj/structures/tables.dmi'
	icon_state = "table"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	throwpass = TRUE	//You can throw objects over this, despite it's density.")
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
	hit_sound = 'sound/effects/metalhit.ogg'
	coverage = 10
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

/obj/structure/table/mainship/nometal
	dropmetal = FALSE

/obj/structure/table/deconstruct(disassembled)
	if(disassembled)
		new parts(loc)
	else
		if(reinforced)
			if(prob(50))
				new /obj/item/stack/rods(loc)
		if(dropmetal)
			new sheet_type(src)
	return ..()

/obj/structure/table/proc/update_adjacent(location = loc)
	for(var/direction in CARDINAL_ALL_DIRS)
		var/obj/structure/table/table = locate(/obj/structure/table, get_step(location,direction))
		if(!table)
			continue
		INVOKE_NEXT_TICK(table, /atom/proc.update_icon)


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
		COMSIG_ATOM_ENTERED = .proc/on_cross,
		COMSIG_ATOM_EXIT = .proc/on_try_exit,
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/table/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!istype(O,/mob/living/carbon/xenomorph/ravager))
		return
	var/mob/living/carbon/xenomorph/M = O
	if(!M.stat) //No dead xenos jumpin on the bed~
		visible_message(span_danger("[O] plows straight through [src]!"))
		deconstruct(FALSE)

/obj/structure/table/Destroy()
	var/tableloc = loc
	update_adjacent(tableloc) //so neighbouring tables get updated correctly
	return ..()

/obj/structure/table/update_icon()
	if(flipped)
		var/ttype = 0
		var/tabledirs = 0
		for(var/direction in list(turn(dir, 90), turn(dir, -90)) )
			var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
			if (T && T.flipped && T.dir == dir)
				ttype++
				tabledirs |= direction

		icon_state = "[table_prefix]flip[ttype]"
		if(ttype == 1)
			if(tabledirs & turn(dir,90))
				icon_state = icon_state+"-"
			if(tabledirs & turn(dir,-90))
				icon_state = icon_state+"+"
		return TRUE

	var/dir_sum = 0
	for(var/direction in CARDINAL_ALL_DIRS)
		var/skip_sum = FALSE
		for(var/obj/structure/window/W in src.loc)
			if(W.dir == direction) //So smooth tables don't go smooth through windows
				skip_sum = TRUE
				continue
		var/inv_direction = turn(dir, 180) //inverse direction
		for(var/obj/structure/window/W in get_step(src, direction))
			if(W.dir == inv_direction) //So smooth tables don't go smooth through windows when the window is on the other table's tile
				skip_sum = TRUE
				continue
		if(!skip_sum) //there is no window between the two tiles in this direction
			var/obj/structure/table/T = locate(/obj/structure/table, get_step(src, direction))
			if(T && !T.flipped)
				if(direction < 5)
					dir_sum += direction
				else
					if(direction == 5)	//This permits the use of all table directions. (Set up so clockwise around the central table is a higher value, from north)
						dir_sum += 16
					if(direction == 6)
						dir_sum += 32
					if(direction == 8)	//Aherp and Aderp.  Jezes I am stupid.  -- SkyMarshal
						dir_sum += 8
					if(direction == 10)
						dir_sum += 64
					if(direction == 9)
						dir_sum += 128

	var/table_type = 0 //stand_alone table
	if((dir_sum%16) in GLOB.cardinals)
		table_type = 1 //endtable
		dir_sum %= 16
	if((dir_sum%16) in list(3, 12))
		table_type = 2 //1 tile thick, streight table
		if(dir_sum%16 == 3) //3 doesn't exist as a dir
			dir_sum = 2
		if(dir_sum%16 == 12) //12 doesn't exist as a dir.
			dir_sum = 4
	if((dir_sum%16) in list(5, 6, 9, 10))
		if(locate(/obj/structure/table, get_step(src.loc, dir_sum%16)))
			table_type = 3 //full table (not the 1 tile thick one, but one of the 'tabledir' tables)
		else
			table_type = 2 //1 tile thick, corner table (treated the same as streight tables in code later on)
		dir_sum %= 16
	if((dir_sum%16) in list(13, 14, 7, 11)) //Three-way intersection
		table_type = 5 //full table as three-way intersections are not sprited, would require 64 sprites to handle all combinations.  TOO BAD -- SkyMarshal
		switch(dir_sum%16)	//Begin computation of the special type tables.  --SkyMarshal
			if(7)
				if(dir_sum == 23)
					table_type = 6
					dir_sum = 8
				else if(dir_sum == 39)
					dir_sum = 4
					table_type = 6
				else if(dir_sum == 55 || dir_sum == 119 || dir_sum == 247 || dir_sum == 183)
					dir_sum = 4
					table_type = 3
				else
					dir_sum = 4
			if(11)
				if(dir_sum == 75)
					dir_sum = 5
					table_type = 6
				else if(dir_sum == 139)
					dir_sum = 9
					table_type = 6
				else if(dir_sum == 203 || dir_sum == 219 || dir_sum == 251 || dir_sum == 235)
					dir_sum = 8
					table_type = 3
				else
					dir_sum = 8
			if(13)
				if(dir_sum == 29)
					dir_sum = 10
					table_type = 6
				else if(dir_sum == 141)
					dir_sum = 6
					table_type = 6
				else if(dir_sum == 189 || dir_sum == 221 || dir_sum == 253 || dir_sum == 157)
					dir_sum = 1
					table_type = 3
				else
					dir_sum = 1
			if(14)
				if(dir_sum == 46)
					dir_sum = 1
					table_type = 6
				else if(dir_sum == 78)
					dir_sum = 2
					table_type = 6
				else if(dir_sum == 110 || dir_sum == 254 || dir_sum == 238 || dir_sum == 126)
					dir_sum = 2
					table_type = 3
				else
					dir_sum = 2 //These translate the dir_sum to the correct dirs from the 'tabledir' icon_state.
	if(dir_sum%16 == 15)
		table_type = 4 //4-way intersection, the 'middle' table sprites will be used.

	switch(table_type)
		if(0)
			icon_state = "[table_prefix]table"
		if(1)
			icon_state = "[table_prefix]1tileendtable"
		if(2)
			icon_state = "[table_prefix]1tilethick"
		if(3)
			icon_state = "[table_prefix]tabledir"
		if(4)
			icon_state = "[table_prefix]middle"
		if(5)
			icon_state = "[table_prefix]tabledir2"
		if(6)
			icon_state = "[table_prefix]tabledir3"

	if(dir_sum in CARDINAL_ALL_DIRS)
		setDir(dir_sum)
	else
		setDir(SOUTH)


/obj/structure/table/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S?.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border objects allow you to universally climb over others
		return TRUE
	if(flipped)
		if(get_dir(loc, target) & dir)
			return FALSE
		else
			return TRUE


/obj/structure/table/proc/on_try_exit(datum/source, atom/movable/mover, direction, list/knownblockers)
	SIGNAL_HANDLER
	if(CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return NONE
	if(!density || !(flags_atom & ON_BORDER) || !(direction & dir) || (mover.status_flags & INCORPOREAL))
		return NONE
	knownblockers += src
	return COMPONENT_ATOM_BLOCK_EXIT

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

/obj/structure/table/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_TABLE)
	return ..()


/obj/structure/table/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(reinforced && table_status != TABLE_STATUS_WEAKENED)
		return FALSE

	user.visible_message(span_notice("[user] starts disassembling [src]."),
		span_notice("You start disassembling [src]."))

	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		return TRUE

	user.visible_message(span_notice("[user] disassembles [src]."),
		span_notice("You disassemble [src]."))
	deconstruct(TRUE)
	return TRUE


/obj/structure/table/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab) && get_dist(src, user) <= 1)
		if(isxeno(user))
			return

		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		if(user.a_intent == INTENT_HARM)
			if(user.grab_state <= GRAB_AGGRESSIVE)
				to_chat(user, span_warning("You need a better grip to do that!"))
				return

			if(prob(15))
				M.Paralyze(10 SECONDS)
			M.apply_damage(8, BRUTE, "head", updating_health = TRUE)
			user.visible_message(span_danger("[user] slams [M]'s face against [src]!"),
			span_danger("You slam [M]'s face against [src]!"))
			log_combat(user, M, "slammed", "", "against \the [src]")
			playsound(loc, 'sound/weapons/tablehit1.ogg', 25, 1)

		else if(user.grab_state >= GRAB_AGGRESSIVE)
			M.forceMove(loc)
			M.Paralyze(10 SECONDS)
			user.visible_message(span_danger("[user] throws [M] on [src]."),
			span_danger("You throw [M] on [src]."))
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
	set category = "Object"
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
		if((S.flags_atom & ON_BORDER) && S.density && S != src) //We would put back on a structure that wouldn't allow it
			return FALSE
	return TRUE

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back"
	set category = "Object"
	set src in oview(1)

	if(!can_interact(usr))
		return

	if(!unflipping_check())
		to_chat(usr, span_warning("[src] won't budge."))
		return

	unflip()

	flip_cooldown = world.time + 50


/obj/structure/table/proc/flip(direction, forced)
	if(!forced && world.time < flip_cooldown)
		return FALSE

	if(!straight_table_check(turn(direction, 90)) || !straight_table_check(turn(direction, -90)))
		return FALSE

	verbs -=/obj/structure/table/verb/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src, dir), get_step(src, turn(dir, 45)),get_step(src, turn(dir, -45)))
	for(var/i in get_turf(src))
		if(isobserver(i))
			continue
		var/atom/movable/thing_to_throw = i
		if(thing_to_throw.anchored)
			continue
		thing_to_throw.throw_at(pick(targets), 1, 1)

	setDir(direction)
	if(dir != NORTH)
		layer = FLY_LAYER
	flipped = TRUE
	coverage = 60
	flags_atom |= ON_BORDER
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
	flags_atom &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(src.loc,D)
		if(T && T.flipped && T.dir == src.dir)
			T.unflip()
	update_icon()
	update_adjacent()

	return TRUE


/obj/structure/table/flipped
	flipped = TRUE //Just not to get the icon updated on Initialize()
	coverage = 60


/obj/structure/table/flipped/Initialize()
	. = ..()
	flipped = FALSE //We'll properly flip it in LateInitialize()
	return INITIALIZE_HINT_LATELOAD


/obj/structure/table/flipped/LateInitialize(mapload)
	. = ..()
	if(!flipped)
		flip(dir, TRUE)


/*
* Wooden tables
*/
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "A square wood surface resting on four legs. Useful to put stuff on. Can be flipped in emergencies to act as cover."
	icon_state = "woodtable"
	sheet_type = /obj/item/stack/sheet/wood
	parts = /obj/item/frame/table/wood
	table_prefix = "wood"
	hit_sound = 'sound/effects/woodhit.ogg'
	max_integrity = 20
/*
* Gambling tables
*/
/obj/structure/table/gamblingtable
	name = "gambling table"
	desc = "A curved wood and carpet surface resting on four legs. Used for gambling games. Can be flipped in emergencies to act as cover."
	icon_state = "gambletable"
	sheet_type = /obj/item/stack/sheet/wood
	parts = /obj/item/frame/table/gambling
	table_prefix = "gamble"
	hit_sound = 'sound/effects/woodhit.ogg'
	max_integrity = 20
/*
* Reinforced tables
*/
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon_state = "reinftable"
	max_integrity = 100
	reinforced = TRUE
	table_prefix = "reinf"
	parts = /obj/item/frame/table/reinforced


/obj/structure/table/reinforced/flipped
	flipped = TRUE
	table_status = TABLE_STATUS_WEAKENED


/obj/structure/table/reinforced/flipped/Initialize()
	. = ..()
	flipped = FALSE
	return INITIALIZE_HINT_LATELOAD


/obj/structure/table/reinforced/flipped/LateInitialize(mapload)
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
		playsound(loc, 'sound/items/welder.ogg', 25, TRUE)
		if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || !WT.remove_fuel(1, user))
			return TRUE

		user.visible_message(span_notice("[user] weakens [src]."),
			span_notice("You weaken [src]"))
		table_status = TABLE_STATUS_WEAKENED
		return TRUE

	user.visible_message(span_notice("[user] starts welding [src] back together."),
		span_notice("You start welding [src] back together."))
	playsound(loc, 'sound/items/welder.ogg', 25, TRUE)
	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || !WT.remove_fuel(1, user))
		return TRUE

	user.visible_message(span_notice("[user] welds [src] back together."),
		span_notice("You weld [src] back together."))
	table_status = TABLE_STATUS_FIRM
	return TRUE


/obj/structure/table/reinforced/prison
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon_state = "prisontable"
	table_prefix = "prison"

/obj/structure/table/mainship
	icon_state = "shiptable"
	table_prefix = "ship"


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
	throwpass = TRUE	//You can shoot past it
	coverage = 20
	climbable = TRUE
	var/dropmetal = TRUE   //if true drop metal when destroyed; mostly used when we need large amounts of racks without marines hoarding the metal
	max_integrity = 40
	resistance_flags = XENO_DAMAGEABLE
	var/parts = /obj/item/frame/rack

/obj/structure/rack/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/rack/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S?.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border  objects allow you to universally climb over others
		return TRUE

/obj/structure/rack/MouseDrop_T(obj/item/I, mob/user)
	if (!istype(I) || user.get_active_held_item() != I)
		return ..()
	user.drop_held_item()
	if(I.loc != loc)
		step(I, get_dir(I, src))

/obj/structure/rack/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_RACK)
	return ..()

/obj/structure/rack/attackby(obj/item/I, mob/user, params)
	. = ..()

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

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(disassembled && parts && dropmetal)
		new parts(loc)
	else if(dropmetal)
		new /obj/item/stack/sheet/metal(loc)
	density = FALSE
	return ..()

/obj/structure/rack/nometal
	dropmetal = FALSE

#undef TABLE_STATUS_WEAKENED
#undef TABLE_STATUS_FIRM
