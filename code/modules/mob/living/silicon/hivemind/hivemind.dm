/mob/camera/xeno/hivemind
	name = "hivemind"
	verb_say = "states"
	verb_ask = "ponders"
	verb_exclaim = "declares"
	verb_yell = "exclaims"

	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

	var/datum/hive_status/hive


/mob/camera/xeno/hivemind/Initialize(mapload, ...)
	. = ..()

	new /obj/effect/alien/weeds/node/strong(loc)

/mob/camera/xeno/hivemind/Move(NewLoc, Dir = 0)
	var/obj/effect/alien/weeds/W = locate() in range("3x3", NewLoc)
	if(!W)
		return FALSE
	forceMove(NewLoc)