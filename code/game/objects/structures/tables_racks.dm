/* Tables and Racks
* Contains:
*		Tables
*		Wooden tables
*		Reinforced tables
*		Racks
*/


/*
* Tables
*/
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
	parts = /obj/item/frame/table

	var/sheet_type = /obj/item/stack/sheet/metal
	var/table_prefix = "" //used in update_icon()
	var/reinforced = FALSE
	var/flipped = FALSE
	var/flip_cooldown = 0 //If flip cooldown exists, don't allow flipping or putting back. This carries a WORLD.TIME value
	max_integrity = 100

/obj/structure/table/destroy_structure(deconstruct)
	if(deconstruct)
		if(parts)
			new parts(loc)
	else
		if(reinforced)
			if(prob(50))
				new /obj/item/stack/rods(loc)
		new sheet_type(src)
	qdel(src)

/obj/structure/table/proc/update_adjacent(location)
	if(!location) location = src //location arg is used to correctly update neighbour tables when deleting a table.
	for(var/direction in CARDINAL_ALL_DIRS)
		var/obj/structure/table/T = locate(/obj/structure/table, get_step(location,direction))
		if(T)
			T.update_icon()

/obj/structure/table/Initialize()
	. = ..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			qdel(T)
	update_icon()
	update_adjacent()

/obj/structure/table/Crossed(atom/movable/O)
	..()
	if(istype(O,/mob/living/carbon/xenomorph/ravager) || istype(O,/mob/living/carbon/xenomorph/crusher))
		var/mob/living/carbon/xenomorph/M = O
		if(!M.stat) //No dead xenos jumpin on the bed~
			visible_message("<span class='danger'>[O] plows straight through [src]!</span>")
			destroy_structure()

/obj/structure/table/Destroy()
	var/tableloc = loc
	. = ..()
	update_adjacent(tableloc) //so neighbouring tables get updated correctly

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
	if(dir_sum%16 in GLOB.cardinals)
		table_type = 1 //endtable
		dir_sum %= 16
	if(dir_sum%16 in list(3, 12))
		table_type = 2 //1 tile thick, streight table
		if(dir_sum%16 == 3) //3 doesn't exist as a dir
			dir_sum = 2
		if(dir_sum%16 == 12) //12 doesn't exist as a dir.
			dir_sum = 4
	if(dir_sum%16 in list(5, 6, 9, 10))
		if(locate(/obj/structure/table, get_step(src.loc, dir_sum%16)))
			table_type = 3 //full table (not the 1 tile thick one, but one of the 'tabledir' tables)
		else
			table_type = 2 //1 tile thick, corner table (treated the same as streight tables in code later on)
		dir_sum %= 16
	if(dir_sum%16 in list(13, 14, 7, 11)) //Three-way intersection
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

/obj/structure/table/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border objects allow you to universally climb over others
		return TRUE
	if(flipped)
		if(get_dir(loc, target) & dir)
			return !density
		else
			return TRUE
	return FALSE

/obj/structure/table/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && CHECK_BITFIELD(O.flags_pass, PASSTABLE))
		return TRUE
	if(flipped)
		if(get_dir(loc, target) & dir)
			return !density
		else
			return TRUE
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

/obj/structure/table/attack_alien(mob/living/carbon/xenomorph/M)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	M.do_attack_animation(src)
	if(sheet_type == /obj/item/stack/sheet/wood)
		playsound(src, 'sound/effects/woodhit.ogg', 25, 1)
	else
		playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
	obj_integrity -= rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper)
	if(obj_integrity <= 0)
		M.visible_message("<span class='danger'>\The [M] slices [src] apart!</span>", \
		"<span class='danger'>We slice [src] apart!</span>", null, 5)
		destroy_structure()
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>We slash [src]!</span>", null, 5)
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_TABLE)

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
			if(user.grab_level <= GRAB_AGGRESSIVE)
				to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
				return

			if(prob(15))	
				M.knock_down(5)
			M.apply_damage(8, def_zone = "head")
			user.visible_message("<span class='danger'>[user] slams [M]'s face against [src]!</span>",
			"<span class='danger'>You slam [M]'s face against [src]!</span>")
			log_combat(user, M, "slammed", "", "against \the [src]")
			msg_admin_attack("[key_name(user)] slammed [key_name(M)]'s face' against \the [src].")
			playsound(loc, 'sound/weapons/tablehit1.ogg', 25, 1)

		else if(user.grab_level >= GRAB_AGGRESSIVE)
			M.forceMove(loc)
			M.knock_down(5)
			user.visible_message("<span class='danger'>[user] throws [M] on [src].</span>",
			"<span class='danger'>You throw [M] on [src].</span>")

	else if(iswrench(I) && !reinforced)
		user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
		"<span class='notice'>You start disassembling [src].</span>")

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
		"<span class='notice'>You disassemble [src].</span>")
		destroy_structure(1)

	else if((I.flags_item & ITEM_ABSTRACT))
		return

	else
		user.transferItemToLoc(I, loc)


/obj/structure/table/proc/straight_table_check(direction)
	var/obj/structure/table/T
	for(var/angle in list(-90, 90))
		T = locate() in get_step(loc, turn(direction, angle))
		if(T && !T.flipped)
			return FALSE
	T = locate() in get_step(src.loc,direction)
	if(!T || T.flipped)
		return TRUE
	if(istype(T, /obj/structure/table/reinforced/))
		var/obj/structure/table/reinforced/R = T
		if(R.status == 2)
			return FALSE
	return T.straight_table_check(direction)

/obj/structure/table/verb/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table"
	set category = "Object"
	set src in oview(1)

	if(!can_touch(usr) || ismouse(usr))
		return

	if(!flip(get_cardinal_dir(usr, src)))
		to_chat(usr, "<span class='warning'>[src] won't budge.</span>")
		return

	usr.visible_message("<span class='warning'>[usr] flips [src]!</span>",
	"<span class='warning'>You flip [src]!</span>")

	if(climbable)
		structure_shaken()

	flip_cooldown = world.time + 50

/obj/structure/table/proc/unflipping_check(direction)

	if(world.time < flip_cooldown)
		return FALSE

	for(var/mob/M in oview(src, 0))
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

	if(!can_touch(usr))
		return

	if(!unflipping_check())
		to_chat(usr, "<span class='warning'>[src] won't budge.</span>")
		return

	unflip()

	flip_cooldown = world.time + 50

/obj/structure/table/proc/flip(direction)

	if(world.time < flip_cooldown)
		return FALSE

	if(!straight_table_check(turn(direction, 90)) || !straight_table_check(turn(direction, -90)))
		return FALSE

	verbs -=/obj/structure/table/verb/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src,dir),get_step(src, turn(dir, 45)),get_step(src, turn(dir, -45)))
	for(var/atom/movable/A in get_turf(src))
		if(!A.anchored)
			spawn(0)
				A.throw_at(pick(targets), 1, 1)

	setDir(direction)
	if(dir != NORTH)
		layer = FLY_LAYER
	flipped = TRUE
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
	flipped = TRUE

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
	max_integrity = 50
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
	max_integrity = 50
/*
* Reinforced tables
*/
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon_state = "reinftable"
	max_integrity = 200
	var/status = 2
	reinforced = TRUE
	table_prefix = "reinf"
	parts = /obj/item/frame/table/reinforced

/obj/structure/table/reinforced/flipped
	flipped = TRUE

/obj/structure/table/reinforced/flip(direction)
	return FALSE //No, just no. It's a full desk, you can't flip that


/obj/structure/table/reinforced/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0, user))
			return

		if(status == 2)
			user.visible_message("<span class='notice'>[user] starts weakening [src].</span>",
			"<span class='notice'>You start weakening [src]</span>")
			playsound(loc, 'sound/items/welder.ogg', 25, 1)
			if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
				return

			if(!WT.isOn())
				return

			user.visible_message("<span class='notice'>[user] weakens [src].</span>",
			"<span class='notice'>You weaken [src]</span>")
			status = 1
		else
			user.visible_message("<span class='notice'>[user] starts welding [src] back together.</span>",
			"<span class='notice'>You start welding [src] back together.</span>")
			playsound(loc, 'sound/items/welder.ogg', 25, 1)
			if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
				return

			if(!WT.isOn())
				return

			user.visible_message("<span class='notice'>[user] welds [src] back together.</span>",
			"<span class='notice'>You weld [src] back together.</span>")
			status = 2


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
	throwpass = TRUE	//You can throw objects over this, despite it's density.
	climbable = TRUE
	parts = /obj/item/frame/rack

/obj/structure/rack/CanPass(atom/movable/mover, turf/target)
	if(!density) //Because broken racks
		return TRUE
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border  objects allow you to universally climb over others
		return TRUE
	else
		return FALSE

/obj/structure/rack/MouseDrop_T(obj/item/I, mob/user)
	if (!istype(I) || user.get_active_held_item() != I)
		return
	user.drop_held_item()
	if(I.loc != loc)
		step(I, get_dir(I, src))

/obj/structure/rack/attack_alien(mob/living/carbon/xenomorph/M)
	M.do_attack_animation(src)
	playsound(src, 'sound/effects/metalhit.ogg', 25, 1)
	M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
	"<span class='danger'>We slice [src] apart!</span>", null, 5)
	destroy_structure()
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_RACK)

/obj/structure/rack/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		destroy_structure(1)
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

	else if((I.flags_item & ITEM_ABSTRACT))
		return

	else if(!QDELETED(src)) //The parent call may have destroyed us
		user.transferItemToLoc(I, loc)


/obj/structure/rack/Crossed(atom/movable/O)
	..()
	if(istype(O,/mob/living/carbon/xenomorph/ravager) || istype(O,/mob/living/carbon/xenomorph/crusher))
		var/mob/living/carbon/xenomorph/M = O
		if(!M.stat) //No dead xenos jumpin on the bed~
			visible_message("<span class='danger'>[O] plows straight through [src]!</span>")
			destroy_structure()

/obj/structure/rack/destroy_structure(deconstruct)
	if(deconstruct)
		if(parts)
			new parts(loc)
	else
		new /obj/item/stack/sheet/metal(loc)
	density = FALSE
	qdel(src)
