/obj/effect/decal/cleanable
	var/list/random_icon_states = list()
	var/targeted_by = null			// Used so cleanbots can't claim a mess.

/obj/effect/decal/cleanable/Initialize()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	return ..()

/obj/effect/decal/cleanable/attackby(obj/item/W, mob/user)
	var/obj/effect/alien/weeds/A = locate() in loc
	if(A)
		return A.attackby(W,user)
	else
		return ..()


/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

	
/obj/effect/decal/cleanable/blood/splatter/animated/Initialize()
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

	var/obj/effect/decal/cleanable/blood/drip/D = new (get_turf(src))
	if(!prob(50))
		return

	D = new(get_turf(src))
	D.blood_DNA = blood_DNA