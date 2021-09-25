/datum/component/remote_control
	///User of the component
	var/mob/living/user
	///Movable atom being controlled by the component
	var/atom/movable/controlled
	///whether the component is currently active or not
	var/is_controlling = FALSE
	///Callback to be run when user left clicks somewhere while remote controlling
	var/datum/callback/left_click_proc
	///Callback to be run when user right clicks somewhere while remote controlling
	var/datum/callback/right_click_proc


/datum/component/remote_control/Initialize(atom/movable/controlled, type)
	. = ..()
	if(!ismovableatom(controlled))
		return COMPONENT_INCOMPATIBLE
	src.controlled = controlled
	update_left_clickproc(null, type)
	RegisterSignal(controlled, COMSIG_UNMANNED_TURRET_UPDATED, .proc/update_left_clickproc)
	RegisterSignal(controlled, COMSIG_UNMANNED_ABILITY_UPDATED, .proc/update_right_clickproc)
	RegisterSignal(parent, COMSIG_REMOTECONTROL_TOGGLE, .proc/toggle_remote_control)
	RegisterSignal(controlled, COMSIG_PARENT_QDELETING, .proc/on_control_terminate)
	RegisterSignal(controlled, COMSIG_MOVABLE_HEAR, .proc/on_hear)
	RegisterSignal(parent, list(COMSIG_REMOTECONTROL_UNLINK, COMSIG_PARENT_QDELETING), .proc/on_control_terminate)


/datum/component/remote_control/Destroy(force=FALSE, silent=FALSE)
	if(is_controlling)
		remote_control_off()
	controlled = null
	left_click_proc = null
	right_click_proc = null
	return ..()

///Called when Controlling should not be resumed and deleted the component
/datum/component/remote_control/proc/on_control_terminate(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Called when the controlled atom hear a sound
/datum/component/remote_control/proc/on_hear(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	user?.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mode)

/// Called when the remote controller wants to speak through the controlled atom
/datum/component/remote_control/proc/on_relayed_speech(datum/source, message, language)
	SIGNAL_HANDLER
	message = trim(message)
	if(!message)
		return
	controlled.say(message, language = language)
	return COMSIG_RELAYED_SPEECH_DEALT


///Updates the clickproc to a passed type of turret
/datum/component/remote_control/proc/update_left_clickproc(datum/source, type)
	SIGNAL_HANDLER
	switch(type)
		if(TURRET_TYPE_DROIDLASER, TURRET_TYPE_HEAVY, TURRET_TYPE_LIGHT)
			left_click_proc = CALLBACK(src, .proc/uv_handle_click)
		if(TURRET_TYPE_EXPLOSIVE)
			left_click_proc = CALLBACK(src, .proc/uv_handle_click_explosive)
		else
			left_click_proc = null


///Updates the clickproc to a passed type of ability
/datum/component/remote_control/proc/update_right_clickproc(datum/source, type)
	SIGNAL_HANDLER
	if(type == CLOAK_ABILITY)
		right_click_proc = CALLBACK(controlled, /obj/vehicle/unmanned/droid/scout/proc/cloak_drone)
		return
	right_click_proc = null

///called when a shooty turret attempts to shoot by click
/datum/component/remote_control/proc/uv_handle_click(mob/user, atom/target, params)
	var/obj/vehicle/unmanned/T = controlled
	log_attack("[key_name(user)] fired a shot while remote controlling [controlled] at [AREACOORD(controlled)]")
	T.fire_shot(target, user)
	return TRUE

///Called when a explosive vehicle clicks and tries to explde itself
/datum/component/remote_control/proc/uv_handle_click_explosive(mob/user, atom/target, params)
	explosion(get_turf(controlled), 1, 2, 3, 4)
	remote_control_off()
	return TRUE

///Self explanatory, toggles remote control
/datum/component/remote_control/proc/toggle_remote_control(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!is_controlling)
		remote_control_on(user)
	else
		remote_control_off()

///Turns the remote control on
/datum/component/remote_control/proc/remote_control_on(mob/living/newuser)
	if(QDELETED(controlled))
		newuser.balloon_alert(newuser, "The linked device is destroyed!")
		controlled = null
		return
	SEND_SIGNAL(controlled, COMSIG_REMOTECONTROL_CHANGED, TRUE, newuser)
	RegisterSignal(newuser, COMSIG_MOB_CLICKON, .proc/invoke)
	RegisterSignal(newuser, COMSIG_MOB_LOGOUT, .proc/remote_control_off)
	RegisterSignal(newuser, COMSIG_RELAYED_SPEECH, .proc/on_relayed_speech)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/remote_control_off)
	is_controlling = TRUE
	newuser.set_remote_control(controlled)	//Movement inputs are handled by the controlled thing in relaymove()
	user = newuser

///Invokes the callback for when the controller clicks
/datum/component/remote_control/proc/invoke(datum/source, atom/target, params)
	SIGNAL_HANDLER
	if(target == parent)
		return NONE
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])
		return NONE
	if(modifiers["left"])
		return left_click_proc?.Invoke(source, target, params) ? COMSIG_MOB_CLICK_CANCELED : NONE
	return right_click_proc?.Invoke(source, target, params) ? COMSIG_MOB_CLICK_CANCELED : NONE

///turns remote control off
/datum/component/remote_control/proc/remote_control_off()
	SIGNAL_HANDLER
	SEND_SIGNAL(controlled, COMSIG_REMOTECONTROL_CHANGED, FALSE, user)
	is_controlling = FALSE
	user.set_remote_control(null)
	UnregisterSignal(user, list(COMSIG_MOB_CLICKON, COMSIG_MOB_LOGOUT, COMSIG_RELAYED_SPEECH))
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	user = null
