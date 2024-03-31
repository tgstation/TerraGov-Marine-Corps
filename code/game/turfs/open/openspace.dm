GLOBAL_DATUM_INIT(openspace_backdrop_one_for_all, /atom/movable/openspace_backdrop, new)

/atom/movable/openspace_backdrop
	name			= "openspace_backdrop"

	anchored		= TRUE

	icon            = 'icons/turf/floors.dmi'
	icon_state      = "grey"
	plane           = OPENSPACE_BACKDROP_PLANE
	mouse_opacity 	= MOUSE_OPACITY_TRANSPARENT
	layer           = SPLASHSCREEN_LAYER
	//I don't know why the others are aligned but I shall do the same.
	vis_flags		= VIS_INHERIT_ID

/atom/movable/openspace_backdrop/Initialize()
	. = ..()
//	filters += filter(type = "blur", size = 3)

/turf/open/transparent/openspace
	name = "open space"
	desc = ""
	icon_state = "openspace"
	baseturfs = /turf/open/transparent/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
//	appearance_flags = KEEP_TOGETHER
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/can_cover_up = TRUE
	var/can_build_on = TRUE
	dynamic_lighting = 1
	canSmoothWith = list(/turf/closed/mineral,/turf/closed/wall/mineral/rogue, /turf/open/floor/rogue)
	smooth = SMOOTH_MORE
	neighborlay_override = "staticedge"

/turf/open/transparent/openspace/cardinal_smooth(adjacencies)
	roguesmooth(adjacencies)

/turf/open/transparent/openspace/roguesmooth(adjacencies)
	var/list/Yeah = ..()
	for(var/O in Yeah)
		var/mutable_appearance/M = mutable_appearance(icon, O)
		M.layer = SPLASHSCREEN_LAYER + 0.01
		M.plane = OPENSPACE_BACKDROP_PLANE + 0.01
		add_overlay(M)

/turf/open/transparent/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/transparent/openspace/debug/update_multiz()
	..()
	return TRUE

///No bottom level for openspace.
/turf/open/transparent/openspace/show_bottom_level()
	return FALSE

/turf/open/transparent/openspace/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	dynamic_lighting = 1
	vis_contents += GLOB.openspace_backdrop_one_for_all //Special grey square for projecting backdrop darkness filter on it.

/turf/open/transparent/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/open/transparent/openspace/zAirIn()
	return TRUE

/turf/open/transparent/openspace/zAirOut()
	return TRUE

/turf/open/transparent/openspace/zPassIn(atom/movable/A, direction, turf/source)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/transparent/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	if(A.anchored)
		return FALSE
	if(direction == DOWN)
		testing("dir=down")
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_DOWN)
				testing("noout")
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE


/turf/open/transparent/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/transparent/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/transparent/openspace/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/transparent/openspace/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.stat != CONSCIOUS)
			return
		var/turf/target = get_step_multiz(src, DOWN)
		if(!target)
			to_chat(user, "<span class='warning'>I can't climb there.</span>")
			return
		if(!user.can_zTravel(target, DOWN, src))
			to_chat(user, "<span class='warning'>I can't climb here.</span>")
			return
		if(user.m_intent != MOVE_INTENT_SNEAK)
			playsound(user, 'sound/foley/climb.ogg', 100, TRUE)
		user.visible_message("<span class='warning'>[user] starts to climb down.</span>", "<span class='warning'>I start to climb down.</span>")
		if(do_after(L, 30, target = src))
			if(user.m_intent != MOVE_INTENT_SNEAK)
				playsound(user, 'sound/foley/climb.ogg', 100, TRUE)
			var/pulling = user.pulling
			if(ismob(pulling))
				user.pulling.forceMove(target)
			user.forceMove(target)
			user.start_pulling(pulling,supress_message = TRUE)

/turf/open/transparent/openspace/attack_ghost(mob/dead/observer/user)
	var/turf/target = get_step_multiz(src, DOWN)
	if(!user.Adjacent(src))
		return
	if(!target)
		to_chat(user, "<span class='warning'>I can't go there.</span>")
		return
	user.forceMove(target)
	to_chat(user, "<span class='warning'>I glide down.</span>")
	. = ..()

/turf/open/transparent/openspace/attackby(obj/item/C, mob/user, params)
	..()
	if(!CanBuildHere())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, "<span class='warning'>There is already a catwalk here!</span>")
			return
		if(L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>I construct a catwalk.</span>")
				playsound(src, 'sound/blank.ogg', 50, TRUE)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, "<span class='warning'>I need two rods to build a catwalk!</span>")
			return
		if(R.use(1))
			to_chat(user, "<span class='notice'>I construct a lattice.</span>")
			playsound(src, 'sound/blank.ogg', 50, TRUE)
			ReplaceWithLattice()
		else
			to_chat(user, "<span class='warning'>I need one rod to build a lattice.</span>")
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		if(!CanCoverUp())
			return
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/blank.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>I build a floor.</span>")
				PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else
				to_chat(user, "<span class='warning'>I need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/open/transparent/openspace/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!CanBuildHere())
		return FALSE

	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/transparent/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>I build a floor.</span>")
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/transparent/openspace/bullet_act(obj/projectile/P)
	if(!P.arcshot)
		return ..()
	var/turf/target = get_step_multiz(src, DOWN)
	if(target)
		testing("canztrav")
//		if(can_zFall(P, 2, target))
//			testing("canztrue")
//			P.zfalling = TRUE
		P.forceMove(target)
//			P.zfalling = FALSE
		P.original = target
		P.process_hit(target, P.select_target(target))
		//bump
		return BULLET_ACT_TURF
