//Various macros
#define NODE_GET_VALUE_OF_WEIGHT(IDENTIFIER, NODE, WEIGHT_NAME) NODE.weights[IDENTIFIER][WEIGHT_NAME]

///Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/movable/source, distance)
	. = list()
	for(var/human in GLOB.humans_by_zlevel["[source.z]"])
		var/mob/living/carbon/human/nearby_human = human
		if(get_dist(source, nearby_human) > distance)
			continue
		. += nearby_human

//Returns a list of xenos via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_xenos_near(atom/movable/source, distance)
	. = list()
	for(var/xeno in GLOB.alive_xeno_list)
		var/mob/living/carbon/xenomorph/nearby_xeno = xeno
		if(source.z != nearby_xeno.z)
			continue
		if(get_dist(source, nearby_xeno) > distance)
			continue
		. += nearby_xeno
