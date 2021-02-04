/datum/component/remote_control
	var/mob/user
	var/atom/movable/controlled
	var/is_controlling = FALSE
	var/datum/callback/click_proc


/datum/component/remote_control/Initialize(atom/movable/controlled, type)
	. = ..()
	if(!ismovableatom(controlled))
		return COMPONENT_INCOMPATIBLE
	src.controlled = controlled
	update_clickproc(null, type)
	to_chat(world, "clickproc [click_proc]")
	RegisterSignal(parent, COMSIG_UNMANNED_TURRET_UPDATED, .proc/update_clickproc)
	RegisterSignal(parent, COMSIG_REMOTECONTROL_TOGGLE, .proc/toggle_remote_control)

/datum/component/remote_control/Destroy(force=FALSE, silent=FALSE)
	user = null
	controlled = null
	click_proc = null
	return ..()

/datum/component/remote_control/proc/update_clickproc(datum/source, type)
	SIGNAL_HANDLER
	switch(type)
		if(TURRET_TYPE_HEAVY, TURRET_TYPE_LIGHT)
			click_proc = CALLBACK(src, .proc/uv_handle_click)
		if(TURRET_TYPE_EXPLOSIVE)
			click_proc = CALLBACK(src, .proc/uv_handle_click_explosive)
		else
			click_proc = null

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
	SIGNAL_HANDLER
	if(!is_controlling)
		remote_control_on(user)
	else
		remote_control_off()

/datum/component/remote_control/proc/remote_control_on(mob/newuser)
	user = newuser
	if(QDELETED(controlled))
		to_chat(newuser, "<span class = 'warning'>The llinked device is destroyed!</span>")
		return
	is_controlling = TRUE
	newuser.remote_control = controlled	//Movement inputs are handled by the controlled thing in relaymove()
	newuser.reset_perspective(controlled)
	if(click_proc)
		RegisterSignal(newuser, COMSIG_MOB_MOUSEDOWN, .proc/invoke)
	RegisterSignal(newuser, COMSIG_MOB_LOGOUT, .proc/remote_control_off)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/remote_control_off)

/datum/component/remote_control/proc/invoke(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	if(QDELETED(controlled))
		return
	if(!istype(target, /obj/item/unmanned_vehicle_remote))
		click_proc?.Invoke(source, target, user)

/datum/component/remote_control/proc/remote_control_off()
	SIGNAL_HANDLER
	is_controlling = FALSE
	user.remote_control = null
	user.reset_perspective(user)
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	user = null
