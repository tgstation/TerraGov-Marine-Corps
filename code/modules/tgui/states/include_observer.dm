/**
 * tgui state: include_observer_state
 *
 * See /obj/machinery/computer/shuttle/shuttle_control/ui_state for usage example.
 * This ui_state allows you to mount any other ui_state on it.
 * Mounting it allows the original behaviour of the mount to take place, but also allow observers to interact with the UI.
 * Make sure to sanatize ui_act for observer interactions when using this.
 */

GLOBAL_VAR_INIT(include_observer_state, /datum/ui_state/include_observer_state)

/datum/ui_state/include_observer_state
	///The ui_state this ui_state overrides
	var/datum/ui_state/mount

/datum/ui_state/include_observer_state/New(datum/ui_state/to_mount)
	if(to_mount)
		mount = to_mount
	. = ..()

/datum/ui_state/include_observer_state/can_use_topic(src_object, mob/user)
	return user.include_observer_can_use_topic(src_object, user, mount)

/mob/proc/include_observer_can_use_topic(src_object, mob/user, datum/ui_state/mount)
	if(mount)
		return mount.can_use_topic(src_object, user, mount)
	return UI_CLOSE

/mob/dead/observer/include_observer_can_use_topic(src_object)
	return UI_INTERACTIVE
