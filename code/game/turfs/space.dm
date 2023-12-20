/turf/open/space
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "0"
	can_bloody = FALSE
	light_power = 0.25
	///What type of debuff do we apply when someone walks through this tile?
	var/debuff_type = /datum/status_effect/spacefreeze

/turf/open/space/basic/New()	//Do not convert to Initialize
	//This is used to optimize the map loader
	return

// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(FALSE)

/**
 * Space Initialize
 *
 * Doesn't call parent, see [/atom/proc/Initialize].
 * When adding new stuff to /atom/Initialize, /turf/Initialize, etc
 * don't just add it here unless space actually needs it.
 *
 * There is a lot of work that is intentionally not done because it is not currently used.
 * This includes stuff like smoothing, blocking camera visibility, etc.
 * If you are facing some odd bug with specifically space, check if it's something that was
 * intentionally ommitted from this implementation.
 */
/turf/open/space/Initialize(mapload, ...)
	SHOULD_CALL_PARENT(FALSE) //prevent laggies
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	ENABLE_BITFIELD(flags_atom, INITIALIZED)
	icon_state = SPACE_ICON_STATE(x, y, z)

	return INITIALIZE_HINT_NORMAL

/area/space/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(isliving(arrived))
		var/mob/living/spaceman = arrived
		if(!spaceman.has_status_effect(debuff_type) && !(spaceman.status_flags & INCORPOREAL))
			spaceman.apply_status_effect(debuff_type)

/area/space/Exited(atom/movable/leaver, direction)
	. = ..()
	if(isliving(leaver))
		var/mob/living/spaceman = leaver
		spaceman.remove_status_effect(debuff_type)

/turf/open/space/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/rods))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice) in src
		if(L)
			return
		var/obj/item/stack/rods/R = I
		if(!R.use(1))
			return

		to_chat(user, span_notice("Constructing support lattice ..."))
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
		ReplaceWithLattice()

	else if(istype(I, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice) in src
		if(!L)
			to_chat(user, span_warning("The plating is going to need some support."))
			return

		var/obj/item/stack/tile/plasteel/S = I
		if(S.get_amount() < 1)
			return
		qdel(L)
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
		S.build(src)
		S.use(1)


/turf/open/space/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		var/mob/living/spaceman = arrived
		if(!spaceman.has_status_effect(debuff_type))
			spaceman.apply_status_effect(debuff_type)

/turf/open/space/Exited(atom/movable/leaver, direction)
	if(isliving(leaver))
		var/step = get_step(src, direction)
		if(!istype(step, /turf/open/space))
			var/mob/living/spaceman = leaver
			spaceman.remove_status_effect(debuff_type)

/turf/open/space/can_teleport_here()
	return FALSE

/turf/open/space/sea //used on prison for flavor
	icon = 'icons/misc/beach.dmi'
	name = "sea"
	icon_state = "seadeep"
	plane = FLOOR_PLANE

/turf/open/space/sea/Initialize(mapload, ...)
	. = ..()
	icon_state = "seadeep"

//Same as regular space, but it applies a debuff type that doesn't hurt as much
/turf/open/space/basic/light
	debuff_type = /datum/status_effect/spacefreeze/light
