#define COMSIG_REMOTE_CONTROL_TOGGLE "toggle remote control"
#define COMSIG_REMOTE_CONTROL_CLICKON "clickedon"

/datum/component/remote_control
	var/mob/user
	var/atom/target
	var/is_controlling


/datum/component/remote_control/Initialize(atom/target)
	. = ..()
	is_controlling = FALSE
	src.target = target

	RegisterSignal(parent, COMSIG_REMOTE_CONTROL_TOGGLE, .proc/toggle_remote_control)


/datum/component/remote_control/Destroy()
	return ..()

/datum/component/remote_control/InterceptClickOn(mob/user, params, atom/object)	
	if(istype(target, /obj/unmanned_vehicle))
		var/obj/unmanned_vehicle/vehicle = target
		vehicle.handle_click(user, params, object)

	return COMSIG_MOB_CANCEL_CLICKON //So that the click returns there and doesn't go on.

/datum/component/remote_control/proc/toggle_remote_control(datum/source, mob/user)
	if(!is_controlling)
		is_controlling = TRUE
		user.set_interaction(parent)
		user.remote_control = target
		user.reset_perspective(target)
		if(istype(target, /obj/unmanned_vehicle))
			var/obj/unmanned_vehicle/vehicle = target
			user.client.click_intercept = src
	else
		is_controlling = FALSE
		user.unset_interaction()
		user.remote_control = null
		user.reset_perspective(user)