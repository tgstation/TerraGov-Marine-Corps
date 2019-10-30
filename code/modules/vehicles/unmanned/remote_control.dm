#define COMSIG_REMOTE_CONTROL_TOGGLE "toggle remote control"
#define COMSIG_REMOTE_CONTROL_CLICKON "clickedon"

/datum/component/remote_control
	var/mob/user
	var/atom/target
	var/is_controlling = FALSE


/datum/component/remote_control/Initialize(atom/target)
	. = ..()
	src.target = target

	RegisterSignal(parent, COMSIG_REMOTE_CONTROL_TOGGLE, .proc/toggle_remote_control)

/datum/component/remote_control/Destroy()
	return ..()

/datum/component/remote_control/proc/on_user_clickon(datum/source, atom/A, params)
	if(A==parent)
		return ..()
	if(istype(target, /obj/vehicle/unmanned))
		var/obj/vehicle/unmanned/T = target
		T.handle_remotecontrol_onuserclickon(A, params)

	return COMSIG_MOB_CANCEL_CLICKON //So that the click returns there and doesn't go on.


/datum/component/remote_control/proc/toggle_remote_control(datum/source, mob/user)
	if(!is_controlling)
		src.user = user
		remote_control_on()
	else
		remote_control_off()

/datum/component/remote_control/proc/remote_control_on()
	is_controlling = TRUE
	user.remote_control = target
	user.reset_perspective(target)
	RegisterSignal(user, COMSIG_MOB_CLICKON, .proc/on_user_clickon)
	RegisterSignal(user, COMSIG_MOB_LOGOUT, .proc/remote_control_off)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/remote_control_off)

/datum/component/remote_control/proc/remote_control_off()
	is_controlling = FALSE
	user.remote_control = null
	user.reset_perspective(user)
	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	user = null