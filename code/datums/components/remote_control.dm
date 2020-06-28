/datum/component/remote_control
	var/mob/user
	var/atom/movable/controlled
	var/is_controlling = FALSE
	var/datum/callback/click_proc


/datum/component/remote_control/Initialize(atom/movable/controlled)
	. = ..()
	if(!ismovableatom(controlled))
		return COMPONENT_INCOMPATIBLE
	src.controlled = controlled
	if(istype(controlled, /obj/vehicle/unmanned))
		click_proc = CALLBACK(src, .proc/uv_handle_click)
	if(istype(controlled, /obj/vehicle/unmanned/explosive))
		click_proc = CALLBACK(src, .proc/uv_handle_click_explosive)
	to_chat(world, "clickproc [click_proc]")
	RegisterSignal(parent, COMSIG_REMOTECONTROL_TOGGLE, .proc/toggle_remote_control)

/datum/component/remote_control/Destroy(force=FALSE, silent=FALSE)
	user = null
	controlled = null
	click_proc = null
	return ..()

/datum/component/remote_control/proc/uv_handle_click(datum/source, atom/target, mob/user)
	to_chat(world, "1")
	to_chat(world, "[target], [user]")
	var/obj/vehicle/unmanned/T = controlled
	T.fire_shot(target, user)

/datum/component/remote_control/proc/uv_handle_click_explosive(datum/source, atom/target, mob/user)
	to_chat(world, "2")
	var/obj/vehicle/unmanned/T = controlled
	explosion(get_turf(T), 1, 2, 3, 4)
	remote_control_off()

/datum/component/remote_control/proc/toggle_remote_control(datum/source, mob/user)
	if(!is_controlling)
		remote_control_on(user)
	else
		remote_control_off()

/datum/component/remote_control/proc/remote_control_on(mob/user)
	src.user = user
	if(QDELETED(controlled))
		to_chat(user, "<span class = 'warning'>The llinked device is destroyed!</span>")
		return
	is_controlling = TRUE
	user.remote_control = controlled	//Movement inputs are handled by the controlled thing in relaymove()
	user.reset_perspective(controlled)
	if(click_proc)
		to_chat(world, "3")
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, .proc/invoke)
	RegisterSignal(user, COMSIG_MOB_LOGOUT, .proc/remote_control_off)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/remote_control_off)

/datum/component/remote_control/proc/invoke(datum/source, atom/target, mob/user)
	if(QDELETED(controlled))
		return
	if(!istype(target, /obj/item/unmanned_vehicle_remote))
		click_proc.Invoke(source, target, user)

/datum/component/remote_control/proc/remote_control_off()
	is_controlling = FALSE
	user.remote_control = null
	user.reset_perspective(user)
	UnregisterSignal(parent, COMSIG_MOB_MOUSEDOWN)
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	user = null
