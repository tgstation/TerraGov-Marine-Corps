/**
 * tgui state: dropship_state
 *
 * Checks that the user is next to the src object
 */
GLOBAL_DATUM_INIT(dropship_state, /datum/ui_state/dropship_state, new)

/datum/ui_state/dropship_state/can_use_topic(src_object, mob/user)
	var/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/shuttle_computer = src_object
	if(shuttle_computer.machine_stat & BROKEN)
		return UI_CLOSE
	return user.dropship_can_use_topic(src_object)

/mob/living/dropship_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc) //must not be in nullspace.
		var/dist = get_dist(src_object, src)
		if(dist > 1)
			return UI_CLOSE

/mob/proc/dropship_can_use_topic(src_object)
	return UI_CLOSE
