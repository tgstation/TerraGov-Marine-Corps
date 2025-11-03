//Various macros
#define NODE_GET_VALUE_OF_WEIGHT(IDENTIFIER, NODE, WEIGHT_NAME) NODE.weights[IDENTIFIER][WEIGHT_NAME]

///Returns a list of mobs/living via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_living_near(atom/source, distance)
	. = list()
	for(var/mob/living/nearby_living AS in GLOB.mob_living_list)
		if(source.z != nearby_living.z)
			continue
		if(get_dist(source, nearby_living) > distance)
			continue
		. += nearby_living

///Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/mob/living/carbon/human/nearby_human AS in GLOB.humans_by_zlevel["[source_turf.z]"])
		if(isnull(nearby_human))
			continue
		if(nearby_human.z != source_turf.z)
			continue
		if(get_dist(source_turf, nearby_human) > distance)
			continue
		. += nearby_human

///Returns a list of xenos via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_xenos_near(atom/source, distance)
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
/proc/cheap_get_mechs_near(atom/source, distance)
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

///Returns a list of vehicles via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_tanks_near(atom/source, distance)
	. = list()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	for(var/obj/vehicle/sealed/armored/nearby_tank AS in GLOB.tank_list)
		if(isnull(nearby_tank))
			continue
		if(source_turf.z != nearby_tank.z)
			continue
		if(nearby_tank.armored_flags & ARMORED_IS_WRECK) //wrecks are decorative currently, probably remove this if they ever become repairable
			continue
		var/bound_max = 1
		if(nearby_tank.hitbox)
			bound_max = max(nearby_tank.hitbox.bound_height, nearby_tank.hitbox.bound_width) / 32
		if(get_dist(source_turf, nearby_tank) > distance + bound_max - 1)
			continue
		. += nearby_tank

///Returns the nearest target that has the right target flag
/proc/get_nearest_target(atom/source, distance, target_flags, attacker_faction, attacker_hive, need_los = FALSE)
	if(!source)
		return
	var/atom/nearest_target
	var/shorter_distance = distance + 1
	// Cache it in case we need it twice
	var/list/nearby_xeno_list
	if(target_flags & TARGET_HUMAN)
		for(var/mob/living/nearby_human AS in cheap_get_humans_near(source, distance))
			if(nearby_human.stat == DEAD || nearby_human.faction == attacker_faction || nearby_human.alpha <= SCOUT_CLOAK_RUN_ALPHA)
				continue
			if(get_dist(source, nearby_human) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_human))
				continue
			nearest_target = nearby_human
			shorter_distance = get_dist(source, nearby_human) //better to recalculate than to save the var
	if(target_flags & TARGET_XENO)
		for(var/obj/item/clothing/mask/facehugger/hugger AS in GLOB.alive_hugger_list)
			if(hugger.z != source.z)
				continue
			if(!isturf(hugger.loc))
				continue
			if(attacker_hive == hugger.get_xeno_hivenumber())
				continue
			if(get_dist(source, hugger) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, hugger))
				continue
			nearest_target = hugger
			shorter_distance = get_dist(source, hugger)

		nearby_xeno_list = cheap_get_xenos_near(source, shorter_distance - 1)
		for(var/mob/nearby_xeno AS in nearby_xeno_list)
			if(attacker_hive == nearby_xeno.get_xeno_hivenumber())
				continue
			if(nearby_xeno.stat == DEAD || nearby_xeno.alpha <= HUNTER_STEALTH_RUN_ALPHA)
				continue
			if((nearby_xeno.status_flags & GODMODE) || (nearby_xeno.status_flags & INCORPOREAL)) //No attacking invulnerable/ai's eye!
				continue
			if(get_dist(source, nearby_xeno) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_xeno))
				continue
			nearest_target = nearby_xeno
			shorter_distance = get_dist(source, nearby_xeno)

		for(var/hive in GLOB.xeno_resin_turrets_by_hive) //we could check all xeno structures, but most of them are not shootable
			for(var/obj/structure/xeno/xeno_turret/xeno_structure AS in GLOB.xeno_resin_turrets_by_hive[hive])
				if(xeno_structure.z != source.z)
					continue
				if(attacker_hive == xeno_structure.get_xeno_hivenumber())
					continue
				if(get_dist(source, xeno_structure) >= shorter_distance)
					continue
				if(need_los && !line_of_sight(source, xeno_structure))
					continue
				nearest_target = xeno_structure
				shorter_distance = get_dist(source, xeno_structure)

	if(target_flags & TARGET_HUMAN_TURRETS)
		for(var/obj/machinery/deployable/mounted/sentry/nearby_turret AS in GLOB.marine_turrets)
			if(source.z != nearby_turret.z)
				continue
			if((GLOB.faction_to_iff[attacker_faction] == nearby_turret.iff_signal))
				continue
			if(nearby_turret.faction == attacker_faction)
				continue
			if(get_dist(source, nearby_turret) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_turret))
				continue
			nearest_target = nearby_turret
			shorter_distance = get_dist(source, nearby_turret)
	if(target_flags & TARGET_VEHICLE)
		for(var/obj/vehicle/sealed/nearby_vehicle AS in (cheap_get_tanks_near(source, distance) + cheap_get_mechs_near(source, distance)))
			if(nearby_vehicle.faction == attacker_faction)
				continue
			if(get_dist(source, nearby_vehicle) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_vehicle))
				continue
			nearest_target = nearby_vehicle
			shorter_distance = get_dist(source, nearby_vehicle)
	if(target_flags & TARGET_UNMANNED_VEHICLE)
		for(var/obj/vehicle/unmanned/nearby_unmanned AS in GLOB.unmanned_vehicles)
			if(source.z != nearby_unmanned.z)
				continue
			if(nearby_unmanned.faction == attacker_faction)
				continue
			if(get_dist(source, nearby_unmanned) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_unmanned))
				continue
			nearest_target = nearby_unmanned
			shorter_distance = get_dist(source, nearby_unmanned)
	if(target_flags & TARGET_FRIENDLY_XENO)
		if(!nearby_xeno_list)
			nearby_xeno_list = cheap_get_xenos_near(source, shorter_distance - 1)
		for(var/mob/nearby_xeno AS in nearby_xeno_list)
			if(source == nearby_xeno)
				continue
			if(!nearby_xeno.client)
				continue
			if(!source.issamexenohive(nearby_xeno))
				continue
			if(nearby_xeno.stat == DEAD)
				continue
			if(get_dist(source, nearby_xeno) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_xeno))
				continue
			nearest_target = nearby_xeno
			shorter_distance = get_dist(source, nearby_xeno)
	if(target_flags & TARGET_FRIENDLY_MOB)
		for(var/mob/living/nearby_mob AS in cheap_get_living_near(source, distance))
			if(nearby_mob.stat == DEAD)
				continue
			if(nearby_mob.faction != attacker_faction)
				continue
			if(!nearby_mob.client) //todo: this might not actually be desirable. Useful for escort atm, but bad for npc on npc teamwork/healing etc
				continue
			if(nearby_mob.alpha <= SCOUT_CLOAK_RUN_ALPHA)
				continue
			if(get_dist(source, nearby_mob) >= shorter_distance)
				continue
			if(need_los && !line_of_sight(source, nearby_mob))
				continue
			nearest_target = nearby_mob
			shorter_distance = get_dist(source, nearby_mob) //better to recalculate than to save the var
	return nearest_target

/**
 * This proc attempts to get an instance of an atom type within distance, with center as the center.
 * Arguments
 * * center - The center of the search
 * * type - The type of atom we're looking for
 * * distance - The distance we should search
 * * list_to_search - The list to look through for the type
 */
/proc/cheap_get_atom(atom/center, type, distance, list/list_to_search)
	var/turf/turf_center = get_turf(center)
	if(!turf_center)
		return
	for(var/atom/near AS in list_to_search)
		if(!istype(near, type))
			continue
		if(get_dist(turf_center, near) > distance)
			continue
		return near
