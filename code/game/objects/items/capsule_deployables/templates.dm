///Map templates used for bluespace survival capsules.
/datum/map_template/capsule
	//has_ceiling = TRUE
	//ceiling_turf = /turf/open/floor/engine/hull
	//ceiling_baseturfs = list(/turf/open/floor/plating)
	///The id of the shelter template in the relative list from the mapping subsystem
	var/shelter_id
	///The description of the shelter, shown when examining survival capsule.
	var/description
	///If turf in the affected turfs is in this list, the survival capsule cannot be deployed.
	var/list/blacklisted_turfs
	///Areas where the capsule cannot be deployed.
	var/list/banned_areas
	///If any object in this list is found in the affected turfs, the capsule cannot deploy.
	var/list/banned_objects = list()

/datum/map_template/capsule/New()
	. = ..()
	blacklisted_turfs = typecacheof(/turf/closed)
	banned_areas = typecacheof(list(/area/shuttle))

/datum/map_template/capsule/proc/check_deploy(turf/deploy_location, obj/item/deploy_capsule/capsule, ignore_flags = NONE)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/turf in affected)
		var/area/area = get_area(turf)
		if(is_type_in_typecache(area, banned_areas))
			return SHELTER_DEPLOY_BAD_AREA

		if(is_type_in_typecache(turf, blacklisted_turfs))
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/object in turf)
			if(!(ignore_flags & CAPSULE_IGNORE_ANCHORED_OBJECTS) && object.density && object.anchored)
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
			if(!(ignore_flags & CAPSULE_IGNORE_BANNED_OBJECTS) && is_type_in_typecache(object, banned_objects))
				return SHELTER_DEPLOY_BANNED_OBJECTS

	// Check if the shelter sticks out of map borders
	var/shelter_origin_x = deploy_location.x - round(width/2)
	if(shelter_origin_x <= 1 || shelter_origin_x+width > world.maxx)
		return SHELTER_DEPLOY_OUTSIDE_MAP
	var/shelter_origin_y = deploy_location.y - round(height/2)
	if(shelter_origin_y <= 1 || shelter_origin_y+height > world.maxy)
		return SHELTER_DEPLOY_OUTSIDE_MAP

	return SHELTER_DEPLOY_ALLOWED

/datum/map_template/capsule/alpha
	name = "Shelter Alpha"
	shelter_id = "shelter_alpha"
	description = "A cosy self-contained pressurized shelter, with \
		built-in navigation, entertainment, medical facilities and a \
		sleeping area! Order now, and we'll throw in a TINY FAN, \
		absolutely free!"
	mappath = "_maps/templates/capsule_1.dmm"

/*
/datum/map_template/capsule/alpha
	name = "Shelter Alpha"
	shelter_id = "shelter_alpha"
	description = "A cosy self-contained pressurized shelter, with \
		built-in navigation, entertainment, medical facilities and a \
		sleeping area! Order now, and we'll throw in a TINY FAN, \
		absolutely free!"
	mappath = "_maps/templates/shelter_1.dmm"

/datum/map_template/capsule/alpha/New()
	. = ..()
	blacklisted_turfs -= typesof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)

/datum/map_template/capsule/beta
	name = "Shelter Beta"
	shelter_id = "shelter_beta"
	description = "An extremely luxurious shelter, containing all \
		the amenities of home, including carpeted floors, hot and cold \
		running water, a gourmet three course meal, cooking facilities, \
		and a deluxe companion to keep you from getting lonely during \
		an ash storm."
	mappath = "_maps/templates/shelter_2.dmm"

/datum/map_template/capsule/beta/New()
	. = ..()
	blacklisted_turfs -= typesof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)
*/
