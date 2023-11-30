//Various macros
#define NODE_GET_VALUE_OF_WEIGHT(IDENTIFIER, NODE, WEIGHT_NAME) NODE.weights[IDENTIFIER][WEIGHT_NAME]

///Returns a list of mobs/living via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_living_near(atom/movable/source, distance)
	. = list()
	for(var/mob/living/nearby_living AS in GLOB.mob_living_list)
		if(source.z != nearby_living.z)
			continue
		if(get_dist(source, nearby_living) > distance)
			continue
		. += nearby_living

///Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/movable/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/mob/living/carbon/human/nearby_human AS in GLOB.humans_by_zlevel["[source_turf.z]"])
		if(isnull(nearby_human))
			continue
		if(get_dist(source_turf, nearby_human) > distance)
			continue
		. += nearby_human

///Returns a list of xenos via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_xenos_near(atom/movable/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/mob/living/carbon/xenomorph/nearby_xeno AS in GLOB.alive_xeno_list)
		if(isnull(nearby_xeno))
			continue
		if(source_turf.z != nearby_xeno.z)
			continue
		if(get_dist(source_turf, nearby_xeno) > distance)
			continue
		. += nearby_xeno

///Returns a list of mechs via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_mechs_near(atom/movable/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/obj/vehicle/sealed/mecha/nearby_mech AS in GLOB.mechas_list)
		if(isnull(nearby_mech))
			continue
		if(source_turf.z != nearby_mech.z)
			continue
		if(get_dist(source_turf, nearby_mech) > distance)
			continue
		. += nearby_mech

///Returns the nearest target that has the right target flag
/proc/get_nearest_target(atom/source, distance, target_flags, attacker_faction, attacker_hive)
	if(!source)
		return
	var/atom/nearest_target
	var/shorter_distance = distance + 1
	if(target_flags & TARGET_HUMAN)
		for(var/mob/living/nearby_human AS in cheap_get_humans_near(source, distance))
			if(nearby_human.stat == DEAD || nearby_human.faction == attacker_faction || nearby_human.alpha <= SCOUT_CLOAK_RUN_ALPHA)
				continue
			if(get_dist(source, nearby_human) < shorter_distance)
				nearest_target = nearby_human
				shorter_distance = get_dist(source, nearby_human) //better to recalculate than to save the var
	if(target_flags & TARGET_XENO)
		for(var/mob/nearby_xeno AS in cheap_get_xenos_near(source, shorter_distance - 1))
			if(source.issamexenohive(nearby_xeno))
				continue
			if(nearby_xeno.stat == DEAD || nearby_xeno.alpha <= HUNTER_STEALTH_RUN_ALPHA)
				continue
			if((nearby_xeno.status_flags & GODMODE) || (nearby_xeno.status_flags & INCORPOREAL)) //No attacking invulnerable/ai's eye!
				continue
			if(get_dist(source, nearby_xeno) < shorter_distance)
				nearest_target = nearby_xeno
				shorter_distance = get_dist(source, nearby_xeno)
	if(target_flags & TARGET_HUMAN_TURRETS)
		for(var/atom/nearby_turret AS in GLOB.marine_turrets)
			if(source.z != nearby_turret.z)
				continue
			if(!(get_dist(source, nearby_turret) < shorter_distance))
				continue
			nearest_target = nearby_turret
	if(target_flags & TARGET_UNMANNED_VEHICLE)
		for(var/atom/nearby_vehicle AS in GLOB.unmanned_vehicles)
			if(source.z != nearby_vehicle.z)
				continue
			if(!(get_dist(source, nearby_vehicle) < shorter_distance))
				continue
			nearest_target = nearby_vehicle
	return nearest_target
