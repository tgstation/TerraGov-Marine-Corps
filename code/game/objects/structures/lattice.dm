/obj/structure/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "latticefull"
	density = FALSE
	anchored = TRUE
	layer = LATTICE_LAYER
	plane = FLOOR_PLANE
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP

/obj/structure/lattice/Initialize(mapload)
	. = ..()
	for(var/obj/structure/lattice/LAT in src.loc)
		if(LAT != src)
			qdel(LAT)
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in GLOB.cardinals)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Destroy()
	for (var/dir in GLOB.cardinals)
		var/obj/structure/lattice/L
		if(locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(src.loc)
	return ..()

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE, EXPLODE_HEAVY)
			qdel(src)


/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if (iswelder(C))
		var/obj/item/tool/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			to_chat(user, span_notice("Slicing lattice joints ..."))
		new /obj/item/stack/rods(src.loc)
		qdel(src)

/obj/structure/lattice/proc/updateOverlays()
	//if(!isspaceturf(loc))
	//	qdel(src)
	spawn(1)
		overlays = list()

		var/dir_sum = 0

		for (var/direction in GLOB.cardinals)
			if(locate(/obj/structure/lattice, get_step(src, direction)))
				dir_sum += direction
			else
				if(!isspaceturf(get_step(src, direction)))
					dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return

/obj/structure/lattice/autosmooth
	icon = 'icons/obj/smooth_objects/lattice.dmi'
	icon_state = "lattice-0"
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE
	base_icon_state = "lattice"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_LATTICE_ABOVE)
	canSmoothWith = list(SMOOTH_GROUP_LATTICE_ABOVE)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/catwalk
	desc = "You can walk on this, even if you're not a cat."
	icon = 'icons/obj/smooth_objects/catwalk.dmi'
	icon_state = "catwalk-icon"
	base_icon_state = "catwalk"
	plane = FLOOR_PLANE
	layer = CATWALK_LAYER
	obj_flags = parent_type::obj_flags|BLOCK_Z_OUT_DOWN|BLOCK_Z_IN_UP
	resistance_flags = XENO_DAMAGEABLE|DROPSHIP_IMMUNE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_LATTICE)
	canSmoothWith = list(SMOOTH_GROUP_LATTICE)

/obj/structure/catwalk/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/catwalk/footstep_override(atom/movable/source, list/footstep_overrides)
	footstep_overrides[FOOTSTEP_CATWALK] = layer

/obj/structure/catwalk/lava_act()
	return FALSE

/obj/structure/catwalk/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return
	if(xeno_attacker.a_intent != INTENT_DISARM)
		return
	xeno_attacker.balloon_alert(xeno_attacker, "destroying...")
	if(!do_after(xeno_attacker, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return
	playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	qdel(src)

/obj/structure/catwalk/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(10))
				qdel(src)

/obj/structure/catwalk/no_smooth
	name = "catwalk"
	icon_state = "catwalk-0"
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
