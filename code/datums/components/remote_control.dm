/datum/component/remote_control
	///User of the component
	var/mob/user
	///Movable atom being controlled by the component
	var/atom/movable/controlled
	///whether the component is currently active or not
	var/is_controlling = FALSE
	///Callback to be run when user clicks somewhere while remote controlling
	var/datum/callback/click_proc


/datum/component/remote_control/Initialize(atom/movable/controlled, type)
	. = ..()
	if(!ismovableatom(controlled))
		return COMPONENT_INCOMPATIBLE
	src.controlled = controlled
	update_clickproc(null, type)
	RegisterSignal(controlled, COMSIG_UNMANNED_TURRET_UPDATED, .proc/update_clickproc)
	RegisterSignal(parent, COMSIG_REMOTECONTROL_TOGGLE, .proc/toggle_remote_control)
	RegisterSignal(controlled, list(COMSIG_PARENT_QDELETING, COMSIG_REMOTECONTROL_UNLINK), .proc/on_control_terminate)

/datum/component/remote_control/Destroy(force=FALSE, silent=FALSE)
	if(is_controlling)
		remote_control_off()
	controlled = null
	click_proc = null
	return ..()

///Called when Controlling should not be resumed and deleted the component
/datum/component/remote_control/proc/on_control_terminate(datum/source)
	SIGNAL_HANDLER
	qdel(src)


///Updates the clickproc to a passed type of turret
/datum/component/remote_control/proc/update_clickproc(datum/source, type)
	SIGNAL_HANDLER
	switch(type)
		if(TURRET_TYPE_HEAVY, TURRET_TYPE_LIGHT, TURRET_TYPE_DROIDLASER)
			click_proc = CALLBACK(src, .proc/uv_handle_click)
		if(TURRET_TYPE_EXPLOSIVE)
			click_proc = CALLBACK(src, .proc/uv_handle_click_explosive)
		else
			click_proc = null

///called when a shooty turret attempts to shoot by click
/datum/component/remote_control/proc/uv_handle_click(mob/user, atom/target, params)
	var/obj/vehicle/unmanned/T = controlled
	T.fire_shot(target, user)

///Called when a explosive vehicle clicks and tries to explde itself
/datum/component/remote_control/proc/uv_handle_click_explosive(mob/user, atom/target, params)
	explosion(get_turf(controlled), 1, 2, 3, 4)
	remote_control_off()

///Self explanatory, toggles remote control
/datum/component/remote_control/proc/toggle_remote_control(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!is_controlling)
		remote_control_on(user)
	else
		remote_control_off()

///Turns the remote control on
/datum/component/remote_control/proc/remote_control_on(mob/newuser)
	if(QDELETED(controlled))
		to_chat(newuser, span_warning("The linked device is destroyed!"))
		controlled = null
		return
	is_controlling = TRUE
	newuser.remote_control = controlled	//Movement inputs are handled by the controlled thing in relaymove()
	newuser.reset_perspective(controlled)
	user = newuser
	SEND_SIGNAL(controlled, COMSIG_REMOTECONTROL_CHANGED, TRUE, user)
	RegisterSignal(newuser, COMSIG_MOB_CLICKON, .proc/invoke)
	RegisterSignal(newuser, COMSIG_MOB_LOGOUT, .proc/remote_control_off)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/remote_control_off)

///Invokes the callback for when the controller clicks
/datum/component/remote_control/proc/invoke(datum/source, atom/target, params)
	SIGNAL_HANDLER
	if(target != parent)
		click_proc?.Invoke(source, target, params)
		return COMSIG_MOB_CLICK_CANCELED
	return NONE

///turns remote control off
/datum/component/remote_control/proc/remote_control_off()
	SIGNAL_HANDLER
	SEND_SIGNAL(controlled, COMSIG_REMOTECONTROL_CHANGED, FALSE, user)
	is_controlling = FALSE
	user.remote_control = null
	user.reset_perspective(user)
	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	UnregisterSignal(user, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	user = null
