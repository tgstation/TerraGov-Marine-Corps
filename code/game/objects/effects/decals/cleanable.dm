/obj/effect/decal/cleanable
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	///List of icon states that our cleanable can have. Used to add variety
	var/list/random_icon_states = list()
	/// Used so cleanbots can't claim a mess.
	var/targeted_by = null

/obj/effect/decal/cleanable/Initialize(mapload)
	if(random_icon_states && length(random_icon_states) > 0)
		icon_state = pick(random_icon_states)
	return ..()

/obj/effect/decal/cleanable/attackby(obj/item/I, mob/user, params)
	var/obj/alien/weeds/A = locate() in loc
	if(A)
		return A.attackby(I, user, params)
	else
		return ..()

/obj/effect/decal/cleanable/wash()
	. = ..()
	qdel(src)
	return TRUE

/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

/obj/effect/decal/cleanable/blood/splatter/animated/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	loc_last_process = loc

/obj/effect/decal/cleanable/blood/splatter/animated/Destroy()
	animation_destruction_fade(src)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/blood/splatter/animated/process()
	if(!target_turf || loc == target_turf)
		return ..()

	step_towards(src, target_turf)
	if(loc == loc_last_process) target_turf = null
	loc_last_process = loc

	//Leaves drips.
	if(!prob(50))
		return

	new /obj/effect/decal/cleanable/blood/drip(get_turf(src))
	if(!prob(50))
		return

	new /obj/effect/decal/cleanable/blood/drip(get_turf(src))
