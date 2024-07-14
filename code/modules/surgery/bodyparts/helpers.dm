
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	RETURN_TYPE(/obj/item/bodypart)

	if(!zone)
		zone = BODY_ZONE_CHEST
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(bodypart.body_zone == zone)
			return bodypart
