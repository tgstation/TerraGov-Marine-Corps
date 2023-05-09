/datum/component/timed_tracking

/datum/component/timed_tracking/Initialize(track_time = 20 SECONDS, image_override, flag_override)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(!track_time)
		return COMPONENT_INCOMPATIBLE
	
	var/flags = flag_override ? flag_override : MINIMAP_FLAG_MARINE
	QDEL_IN(src, track_time)
	if(image_override)
		SSminimaps.add_marker(parent, flags, image_override)
		return
	if(isxeno(parent))
		var/mob/living/carbon/xenomorph/xeno = parent
		SSminimaps.add_marker(xeno, flags, image('icons/UI_icons/map_blips.dmi', null, xeno.xeno_caste.minimap_icon))
	else
		SSminimaps.add_marker(parent, flags, image('icons/UI_icons/map_blips.dmi', null, "tracker"))

/datum/component/timed_tracking/Destroy(force, silent)
	SSminimaps.remove_marker(parent)
	return ..()
