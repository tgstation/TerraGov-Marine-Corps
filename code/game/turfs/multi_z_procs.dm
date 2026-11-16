//todo: our turfs have absolutely no rhyme or reason to them, and desperately need to be organised in a sane way, as all these overrides show

///Returns the amount of damage mobs suffering from falling on this atom
/atom/proc/get_z_fall_damage(mob/living/faller, levels) //not a turf proc, but this mostly relates to turfs
	return (levels * 10) ** 1.5

/mob/living/get_z_fall_damage(mob/living/faller, levels)
	if(mob_size >= faller.mob_size) //a small mob won't cushion your fall
		levels *= 0.5
	return ..(faller, levels)

/turf/open/liquid/get_z_fall_damage(mob/living/faller, levels)
	return (levels * 2) ** 2

/turf/open/floor/plating/ground/snow/get_z_fall_damage(mob/living/faller, levels)
	switch(slayer)
		if(3 to INFINITY)
			return 0 //lucky you
		if(2)
			levels *= 0.5
		if(1)
			levels *= 0.9
	return ..()

/turf/open/floor/wood/get_z_fall_damage(mob/living/faller, levels)
	return (levels * 8) ** 1.5

/turf/open/ground/get_z_fall_damage(mob/living/faller, levels)
	return (levels * 6) ** 1.5

/turf/open/floor/plating/ground/get_z_fall_damage(mob/living/faller, levels)
	return (levels * 6) ** 1.5

/turf/open/floor/plating/ground/ice/get_z_fall_damage(mob/living/faller, levels)
	return (levels * 10) ** 1.5

/turf/open/floor/plating/ground/concrete/get_z_fall_damage(mob/living/faller, levels)
	return (levels * 12) ** 1.5

///Returns the thing that breaks the fall of a mob landing on us
/turf/proc/get_z_fall_catcher(mob/living/faller)
	var/mob/living/lying_mob_candidate
	for(var/mob/mob in src)
		if(!isliving(mob))
			continue
		if(mob == faller)
			continue
		var/mob/living/living_mob = mob
		if(living_mob.lying_angle)
			lying_mob_candidate = mob
			continue
		if(!living_mob.density)
			return
		return mob

	for(var/obj/obj in src)
		if(!obj.density)
			continue
		if(obj.atom_flags & ON_BORDER)
			continue
		return obj

	if(lying_mob_candidate)
		return lying_mob_candidate
	return src
