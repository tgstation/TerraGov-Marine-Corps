#define DRIP_ON_WALK 1
#define DRIP_ON_TIME 2

/datum/component/dripping
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/drip_counter
	var/drip_limit
	var/drip_ratio
	var/dripped_type = /obj/effect/decal/cleanable/blood/drip/tracking_fluid


/datum/component/dripping/Initialize(drip_mode = DRIP_ON_WALK, drip_limit, drip_ratio, dripped_type)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(!drip_limit || !drip_ratio)
		return COMPONENT_INCOMPATIBLE
	if(!isnull(dripped_type))
		src.dripped_type = dripped_type
	src.drip_ratio = drip_ratio
	switch(drip_mode)
		if(DRIP_ON_WALK)
			drip_counter = 1
			src.drip_limit = drip_limit
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/drip_on_walk)
		if(DRIP_ON_TIME)
			drip_counter = world.time
			src.drip_limit = world.time + drip_limit
			START_PROCESSING(SSprocessing, src)
		else
			return COMPONENT_INCOMPATIBLE


/datum/component/dripping/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/datum/component/dripping/proc/drip_on_walk(datum/source, atom/oldloc, direction, Forced = FALSE)
	SIGNAL_HANDLER
	var/mob/living/dripper = parent
	if(!isturf(dripper.loc))
		return
	if(!(drip_counter % drip_ratio))
		return
	new /obj/effect/decal/cleanable/blood/drip/tracking_fluid(dripper.loc)
	if(++drip_counter > drip_limit)
		qdel(src)


/datum/component/dripping/process()
	var/mob/living/dripper = parent
	if(world.time > drip_limit)
		qdel(src)
		return
	if(world.time < drip_counter)
		return
	drip_counter += drip_ratio
	if(!isturf(dripper.loc))
		return
	new /obj/effect/decal/cleanable/blood/drip/tracking_fluid(dripper.loc)
	if(world.time + drip_ratio > drip_limit)
		qdel(src)
