/datum/mapGeneratorModule/ambushing
	spawnableAtoms = list(/obj/effect/landmark/ambush=80)
	spawnableTurfs = list()
	clusterMax = 3
	clusterMin = 3
	checkdensity = FALSE
	allowed_areas = list(/area/rogue/outdoors)
	allowed_turfs = list(/turf/open/floor/rogue/dirt/ambush)
	excluded_turfs = list(/turf/open/floor/rogue/dirt/road)

/obj/effect/landmark/ambush/Initialize()
	. = ..()
#ifdef TESTSERVER
	invisibility = 0
#endif
/obj/effect/landmark/ambush/Crossed(AM as mob|obj)
	. = ..()
	if(isturf(loc))
		if(isliving(AM))
			var/mob/living/MM = AM
			if(MM.m_intent != MOVE_INTENT_SNEAK)
				MM.consider_ambush()