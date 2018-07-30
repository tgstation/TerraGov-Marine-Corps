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
	density = 1
	anchored = 1.0
	layer = TABLE_LAYER
	throwpass = 1	//You can throw objects over this, despite it's density.")
	climbable = 1
	breakable = 1
	parts = /obj/item/frame/table

	var/sheet_type = /obj/item/stack/sheet/metal
	var/table_prefix = "" //used in update_icon()
	var/reinforced = FALSE
	var/flipped = 0
	var/flip_cooldown = 0 //If flip cooldown exists, don't allow flipping or putting back. This carries a WORLD.TIME value
	var/health = 100

/obj/structure/table/destroy(deconstruct)
	if(deconstruct)
		if(parts)
			new parts(loc)
	else
		if(reinforced)
			if(prob(50))
				new /obj/item/stack/rods(loc)
		new sheet_type(src)
	cdel(src)

/obj/structure/table/proc/update_adjacent(location)
	if(!location) location = src //location arg is used to correctly update neighbour tables when deleting a table.
	for(var/direction in CARDINAL_ALL_DIRS)
		var/obj/structure/table/T = locate(/obj/structure/table, get_step(location,direction))
		if(T)
			T.update_icon()

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			cdel(T)
	update_icon()
	update_adjacent()

/obj/structure/table/Crossed(atom/movable/O)
	..()
	if(istype(O,/mob/living/carbon/Xenomorph/Ravager) || istype(O,/mob/living/carbon/Xenomorph/Crusher))
		var/mob/living/carbon/Xenomorph/M = O
		if(!M.stat) //No dead xenos jumpin on the bed~
			visible_message("<span class='danger'>[O] plows straight through [src]!</span>")
			destroy()

/obj/structure/table/Dispose()
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
		return 1

	var/dir_sum = 0
	for(var/direction in CARDINAL_ALL_DIRS)
		var/skip_sum = 0
		for(var/obj/structure/window/W in src.loc)
			if(W.dir == direction) //So smooth tables don't go smooth through windows
				skip_sum = 1
				continue
		var/inv_direction = turn(dir, 180) //inverse direction
		for(var/obj/structure/window/W in get_step(src, direction))
			if(W.dir == inv_direction) //So smooth tables don't go smooth through windows when the window is on the other table's tile
				skip_sum = 1
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
	if(dir_sum%16 in cardinal)
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
		dir = dir_sum
	else
		dir = SOUTH


/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border objects allow you to universally climb over others
		return 1
	if(flipped)
		if(get_dir(loc, target) & dir)
			return !density
		else
			return 1
	return 0

/obj/structure/table/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if(flipped)
		if(get_dir(loc, target) & dir)
			return !density
		else
			return 1
	return 1

//Flipping tables, nothing more, nothing less
/obj/structure/table/MouseDrop(over_object, src_location, over_location)

	..()

	if(flipped)
		do_put()
	else
		do_flip()

/obj/structure/table/MouseDrop_T(obj/item/I, mob/user)

	if (!istype(I) || user.get_active_hand() != I)
		return ..()
	if(isrobot(user))
		return
	user.drop_held_item()
	if(I.loc != loc)
		step(I, get_dir(I, src))



/obj/structure/table/attackby(obj/item/W, mob/user)
	if(!W) return
	if(istype(W, /obj/item/grab) && get_dist(src, user) <= 1)
		if(isXeno(user)) return
		var/obj/item/grab/G = W
		if(istype(G.grabbed_thing, /mob/living))
			var/mob/living/M = G.grabbed_thing
			if(user.a_intent == "hurt")
				if(user.grab_level > GRAB_AGGRESSIVE)
					if (prob(15))	M.KnockDown(5)
					M.apply_damage(8, def_zone = "head")
					user.visible_message("<span class='danger'>[user] slams [M]'s face against [src]!</span>",
					"<span class='danger'>You slam [M]'s face against [src]!</span>")
					playsound(src.loc, 'sound/weapons/tablehit1.ogg', 25, 1)
				else
					user << "<span class='warning'>You need a better grip to do that!</span>"
					return
			else if(user.grab_level >= GRAB_AGGRESSIVE)
				M.forceMove(loc)
				M.KnockDown(5)
				user.visible_message("<span class='danger'>[user] throws [M] on [src].</span>",
				"<span class='danger'>You throw [M] on [src].</span>")
		return

	if(istype(W, /obj/item/tool/wrench))
		user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
		"<span class='notice'>You start disassembling [src].</span>")
		playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
		if(do_after(user,50, TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
			"<span class='notice'>You disassemble [src].</span>")
			destroy(1)
		return

	if((W.flags_item & ITEM_ABSTRACT) || isrobot(user))
		return

	if(istype(W, /obj/item/weapon/wristblades))
		if(rand(0, 2) == 0)
			playsound(src.loc, 'sound/weapons/wristblades_hit.ogg', 25, 1)
			user.visible_message("<span class='danger'>[user] slices [src] apart!",
			"<span class='danger'>You slice [src] apart!")
			destroy()
		else
			user << "<span class='warning'>You slice at the table, but only claw it up a little.</span>"
		return

	user.drop_inv_item_to_loc(W, loc)


/obj/structure/table/proc/straight_table_check(var/direction)
	var/obj/structure/table/T
	for(var/angle in list(-90, 90))
		T = locate() in get_step(loc, turn(direction, angle))
		if(T && !T.flipped)
			return 0
	T = locate() in get_step(src.loc,direction)
	if(!T || T.flipped)
		return 1
	if(istype(T, /obj/structure/table/reinforced/))
		var/obj/structure/table/reinforced/R = T
		if(R.status == 2)
			return 0
	return T.straight_table_check(direction)

/obj/structure/table/verb/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table"
	set category = "Object"
	set src in oview(1)

	if(!can_touch(usr) || ismouse(usr))
		return

	if(!flip(get_cardinal_dir(usr, src)))
		usr << "<span class='warning'>[src] won't budge.</span>"
		return

	usr.visible_message("<span class='warning'>[usr] flips [src]!</span>",
	"<span class='warning'>You flip [src]!</span>")

	if(climbable)
		structure_shaken()

	flip_cooldown = world.time + 50

/obj/structure/table/proc/unflipping_check(var/direction)

	if(world.time < flip_cooldown)
		return 0

	for(var/mob/M in oview(src, 0))
		return 0

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
				return 0
	for(var/obj/structure/S in loc)
		if((S.flags_atom & ON_BORDER) && S.density && S != src) //We would put back on a structure that wouldn't allow it
			return 0
	return 1

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back"
	set category = "Object"
	set src in oview(1)

	if(!can_touch(usr))
		return

	if(!unflipping_check())
		usr << "<span class='warning'>[src] won't budge.</span>"
		return

	unflip()

	flip_cooldown = world.time + 50

/obj/structure/table/proc/flip(var/direction)

	if(world.time < flip_cooldown)
		return 0

	if(!straight_table_check(turn(direction, 90)) || !straight_table_check(turn(direction, -90)))
		return 0

	verbs -=/obj/structure/table/verb/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src,dir),get_step(src, turn(dir, 45)),get_step(src, turn(dir, -45)))
	for(var/atom/movable/A in get_turf(src))
		if(!A.anchored)
			spawn(0)
				A.throw_at(pick(targets), 1, 1)

	dir = direction
	if(dir != NORTH)
		layer = FLY_LAYER
	flipped = 1
	flags_atom |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src,D)
		if(T && !T.flipped)
			T.flip(direction)
	update_icon()
	update_adjacent()

	return 1

/obj/structure/table/proc/unflip()

	verbs -=/obj/structure/table/proc/do_put
	verbs +=/obj/structure/table/verb/do_flip

	layer = initial(layer)
	flipped = 0
	climbable = initial(climbable)
	flags_atom &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(src.loc,D)
		if(T && T.flipped && T.dir == src.dir)
			T.unflip()
	update_icon()
	update_adjacent()

	return 1

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
	health = 50
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
	health = 50
/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon_state = "reinftable"
	health = 200
	var/status = 2
	reinforced = TRUE
	table_prefix = "reinf"
	parts = /obj/item/frame/table/reinforced

/obj/structure/table/reinforced/flip(var/direction)
	return 0 //No, just no. It's a full desk, you can't flip that

/obj/structure/table/reinforced/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			if(status == 2)
				user.visible_message("<span class='notice'>[user] starts weakening [src].</span>",
				"<span class='notice'>You start weakening [src]</span>")
				playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
				if (do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
					if(!src || !WT.isOn()) return
					user.visible_message("<span class='notice'>[user] weakens [src].</span>",
					"<span class='notice'>You weaken [src]</span>")
					src.status = 1
			else
				user.visible_message("<span class='notice'>[user] starts welding [src] back together.</span>",
				"<span class='notice'>You start welding [src] back together.</span>")
				playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
				if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
					if(!src || !WT.isOn()) return
					user.visible_message("<span class='notice'>[user] welds [src] back together.</span>",
					"<span class='notice'>You weld [src] back together.</span>")
					status = 2
			return
		return

	if(istype(W, /obj/item/tool/wrench))
		if(status == 2)
			return
	..()

/obj/structure/table/reinforced/prison
	desc = "A square metal surface resting on four legs. This one has side panels, making it useful as a desk, but impossible to flip."
	icon_state = "prisontable"
	table_prefix = "prison"

/obj/structure/table/almayer
	icon_state = "almtable"
	table_prefix = "alm"






/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "A bunch of metal shelves stacked on top of eachother. Excellent for storage purposes, less so as cover."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	layer = TABLE_LAYER
	anchored = 1.0
	throwpass = 1	//You can throw objects over this, despite it's density.
	breakable = 1
	climbable = 1
	parts = /obj/item/frame/rack

/obj/structure/rack/CanPass(atom/movable/mover, turf/target)
	if(!density) //Because broken racks
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border  objects allow you to universally climb over others
		return 1
	else
		return 0

/obj/structure/rack/MouseDrop_T(obj/item/I, mob/user)
	if (!istype(I) || user.get_active_hand() != I)
		return
	if(isrobot(user))
		return
	user.drop_held_item()
	if(I.loc != loc)
		step(I, get_dir(I, src))


/obj/structure/rack/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tool/wrench))
		destroy(1)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
		return
	if((W.flags_item & ITEM_ABSTRACT) || isrobot(user))
		return
	user.drop_inv_item_to_loc(W, loc)


/obj/structure/rack/Crossed(atom/movable/O)
	..()
	if(istype(O,/mob/living/carbon/Xenomorph/Ravager) || istype(O,/mob/living/carbon/Xenomorph/Crusher))
		var/mob/living/carbon/Xenomorph/M = O
		if(!M.stat) //No dead xenos jumpin on the bed~
			visible_message("<span class='danger'>[O] plows straight through [src]!</span>")
			destroy()

/obj/structure/rack/destroy(deconstruct)
	if(deconstruct)
		if(parts)
			new parts(loc)
	else
		new /obj/item/stack/sheet/metal(loc)
	density = 0
	cdel(src)
