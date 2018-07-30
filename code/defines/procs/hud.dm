

mob/proc/in_view(var/turf/T)
	return view(T)

/mob/aiEye/in_view(var/turf/T)
	var/list/viewed = new
	for(var/mob/living/carbon/human/H in mob_list)
		if(get_dist(H, T) <= 7)
			viewed += H
	return viewed
