/datum/action/innate/camera_off/cas
	name = "Exit CAS mode"

/datum/action/innate/camera_off/cas/Activate()
	if(!isliving(target))
		return
	var/mob/living/living = target
	var/mob/camera/aiEye/remote/remote_eye = living.remote_control
	var/obj/docking_port/mobile/marine_dropship/casplane/plane = remote_eye.origin
	plane.end_cas_mission(living)

/datum/action/innate/jump_to_lase
	name = "Jump to Lase"
	action_icon_state = "aim_mode"
	var/obj/docking_port/mobile/marine_dropship/casplane/plane

/datum/action/innate/jump_to_lase/New(Target, plane)
	. = ..()
	src.plane = plane

/datum/action/innate/jump_to_lase/Activate()
	if(!plane?.eyeobj)
		return
	var/obj/effect/overlay/temp/laser_target/caspoint = tgui_input_list(usr, "Select a CAS target", "CAS Targeting", GLOB.active_cas_targets)
	if(QDELETED(caspoint))
		to_chat(usr, span_warning("That marker has expired."))
		return

	to_chat(usr, span_notice("Jumped to [caspoint]."))
	plane.eyeobj.setLoc(get_turf(caspoint))
