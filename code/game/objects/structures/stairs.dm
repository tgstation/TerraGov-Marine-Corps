#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

// dir determines the direction of travel to go upwards (due to lack of sprites, currently only 1 and 2 make sense)
// stairs require /turf/open/transparent/openspace as the tile above them to work
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE
	layer = 2
	obj_flags = CAN_BE_HIT
	nomouseover = TRUE

/obj/structure/stairs/stone
	name = "stone stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stonestairs"

//	climb_offset = 10
	//RTD animate climbing offset so this can be here

/obj/structure/stairs/fancy
	icon_state = "fancy_stairs"

/obj/structure/stairs/fancy/c
	icon_state = "fancy_stairs_c"

/obj/structure/stairs/fancy/r
	icon_state = "fancy_stairs_r"

/obj/structure/stairs/fancy/l
	icon_state = "fancy_stairs_l"

/obj/structure/stairs/fancy/Initialize()
	..()
	if(GLOB.lordprimary)
		lordcolor(GLOB.lordprimary,GLOB.lordsecondary)
	else
		GLOB.lordcolor += src

/obj/structure/stairs/fancy/Destroy()
	GLOB.lordcolor -= src
	return ..()

/obj/structure/stairs/fancy/lordcolor(primary,secondary)
	if(!primary || !secondary)
		return
	var/mutable_appearance/M = mutable_appearance(icon, "[icon_state]_primary", -(layer+0.1))
	M.color = primary
	add_overlay(M)
	GLOB.lordcolor -= src


/obj/structure/stairs/OnCrafted(dirin)
	dir = dirin
	var/turf/partner = get_step_multiz(get_turf(src), UP)
	partner = get_step(partner, dirin)
	if(isopenturf(partner))
		var/obj/stairs = new /obj/structure/stairs(partner)
		stairs.dir = dirin

/obj/structure/stairs/d/OnCrafted(dirin)
	dir = turn(dirin, 180)
	var/turf/partner = get_step_multiz(get_turf(src), DOWN)
	partner = get_step(partner, dirin)
	if(isopenturf(partner))
		var/obj/stairs = new /obj/structure/stairs(partner)
		stairs.dir = turn(dirin, 180)

/obj/structure/stairs/Initialize(mapload)
	return ..()

/obj/structure/stairs/Destroy()
	return ..()

/obj/structure/stairs/Uncross(atom/movable/AM, turf/newloc)
	if(!newloc || !AM)
		return ..()
	var/moved = get_dir(src, newloc)
	if(moved == dir)
		if(stair_ascend(AM,moved))
			return FALSE
	if(moved == turn(dir, 180))
		if(stair_descend(AM,moved))
			return FALSE
	return ..()

/obj/structure/stairs/proc/stair_ascend(atom/movable/AM, dirmove)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
//	if(!checking.zPassIn(AM, UP, get_turf(src)))
//		return
	var/turf/target = get_step_multiz(get_turf(src), UP)
	if(istype(target))
		var/based = FALSE
		var/turf/newtarg = get_step(target, dirmove)
		for(var/obj/structure/stairs/S in newtarg.contents)
			if(S.dir == dir)
				based = TRUE
		if(based)
			if(isliving(AM))
				var/mob/living/L = AM
				var/pulling = L.pulling
				if(pulling)
					L.pulling.forceMove(newtarg)
				L.forceMove(newtarg)
				L.start_pulling(pulling, supress_message = TRUE)
			else
				AM.forceMove(newtarg)
			return TRUE

/obj/structure/stairs/proc/stair_descend(atom/movable/AM, dirmove)
	var/turf/checking = get_step_multiz(get_turf(src), DOWN)
	if(!istype(checking))
		return
//	if(!checking.zPassIn(AM, DOWN, get_turf(src)))
//		return
	var/turf/target = get_step_multiz(get_turf(src), DOWN)
	if(istype(target))
		var/based = FALSE
		var/turf/newtarg = get_step(target, dirmove)
		for(var/obj/structure/stairs/S in newtarg.contents)
			if(S.dir == dir)
				based = TRUE
		if(based)
			if(isliving(AM))
				var/mob/living/L = AM
//				var/pulling = L.pulling
//				if(pulling)
//					L.pulling.forceMove(newtarg)
				L.forceMove(newtarg)
//				L.start_pulling(pulling)
			else
				AM.forceMove(newtarg)
			return TRUE

/obj/structure/stairs/intercept_zImpact(atom/movable/AM, levels = 1)
	. = ..()
