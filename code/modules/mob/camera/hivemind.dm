/mob/camera/xeno/hivemind
	name = "hivemind"
	real_name = "hivemind"
	desc = "A glorious singular entity."

	mouse_opacity = MOUSE_OPACITY_OPAQUE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_MOBS|SEE_TURFS|SEE_OBJS
	see_in_dark = 8
	move_on_shuttle = TRUE

	var/datum/hive_status/hive


/mob/camera/xeno/hivemind/Initialize(mapload, ...)
	. = ..()
	new /obj/effect/alien/weeds/node/strong(loc)


/mob/camera/xeno/hivemind/Move(NewLoc, Dir = 0)
	var/obj/effect/alien/weeds/W = locate() in range("3x3", NewLoc)
	if(!W)
		return FALSE
	forceMove(NewLoc)

