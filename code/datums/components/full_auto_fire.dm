/datum/component/full_auto_fire
	var/atom/movable/gun
	var/atom/target
	var/datum/callback/extra_checks
	var/delay = 0.2 SECONDS //How long between each fire signal.
	var/next_fire = 0


/datum/component/full_auto_fire/proc/fullauto_on(new_gun, new_delay, datum/callback/extra_checks)
	gun = new_gun
	if(!isnull(new_delay))
		delay = new_delay
	src.extra_checks = extra_checks
	RegisterSignal(gun, COMSIG_PARENT_QDELETED, .proc/fullauto_off)
	RegisterSignal(gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/fullauto_off)
	RegisterSignal(parent, COMSIG_CLIENT_DISCONNECTED, .proc/fullauto_off)
	RegisterSignal(parent, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	gun.RegisterSignal(gun, COMSIG_FULL_AUTO_FIRE, .proc/do_auto_fire)


/datum/component/full_auto_fire/proc/fullauto_off()
	if(!isnull(target))
		stop_autofiring()
	UnregisterSignal(parent, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG, COMSIG_CLIENT_DISCONNECTED))
	if(!QDELETED(gun))
		UnregisterSignal(gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETED))
		gun.UnregisterSignal(gun, COMSIG_FULL_AUTO_FIRE)
	gun = null
	delay = initial(delay)
	extra_checks = null


/datum/component/full_auto_fire/Destroy()
	fullauto_off()
	return ..()


/datum/component/full_auto_fire/proc/on_mouse_down(client/source, atom/target, turf/location, params)
	var/list/modifiers = params2list(params) //If they're shift+clicking, for example, let's not have them accidentally shoot.
	if(modifiers["shift"])
		return NONE
	if(modifiers["ctrl"])
		return NONE
	if(modifiers["middle"])
		return NONE
	if(modifiers["alt"])
		return NONE
	if(isnull(location))
		return NONE //If we click and drag on our worn backpack, for example, we want it to open instead.
	. = extra_checks?.Invoke(target) //If there are no extra checks, it will be null and go on as normal.
	switch(.) //Here we give the chance for custom behavior.
		if(NONE, COMSIG_CLIENT_MOUSEDOWN_INTERCEPT)
			return //Null lets things progress. NONE lets the click pass .COMSIG_CLIENT_MOUSEDOWN_INTERCEPT doesn't.
	src.target = target
	start_autofiring()
	return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT


/datum/component/full_auto_fire/proc/start_autofiring()
	var/client/holder = parent
	holder.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'
	RegisterSignal(parent, COMSIG_CLIENT_MOUSEUP, .proc/stop_autofiring)
	RegisterSignal(parent, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)
	START_PROCESSING(SSfastprocess, src)


/datum/component/full_auto_fire/proc/stop_autofiring()
	var/client/holder = parent
	holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	UnregisterSignal(parent, list(COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	target = null
	STOP_PROCESSING(SSfastprocess, src)


/datum/component/full_auto_fire/proc/on_mouse_drag(client/source, atom/target, turf/target_loc)
	if(isnull(target_loc))
		return //This happens when the mouse is over an inventory or screen object, for example.
	src.target = target


/datum/component/full_auto_fire/process()
	if(world.time < next_fire)
		return
	next_fire = world.time + delay
	. = extra_checks?.Invoke(target)
	switch(.) //Here we give the chance for custom behavior.
		if(NONE, COMSIG_CLIENT_MOUSEDOWN_INTERCEPT)
			return //Null lets things progress. NONE and COMSIG_CLIENT_MOUSEDOWN_INTERCEPT don't.
	var/client/holder = parent
	SEND_SIGNAL(gun, COMSIG_FULL_AUTO_FIRE, target, holder.mob)


//Full auto action.
/datum/action/toggle_full_auto
	name = "Toggle Full Auto"
	var/image/selected_frame
	var/active = FALSE


/datum/action/toggle_full_auto/New(target)
	. = ..()
	selected_frame = image('icons/mob/actions.dmi', null, "selected_frame")
	selected_frame.appearance_flags = RESET_COLOR


/datum/action/toggle_full_auto/action_activate()
	if(!owner.client)
		return
	if(active)
		var/datum/component/full_auto_fire/fullauto = owner.client.LoadComponent(/datum/component/full_auto_fire)
		fullauto.fullauto_off()
		button.overlays -= selected_frame
		active = FALSE
		return
	var/datum/component/full_auto_fire/fullauto = owner.client.LoadComponent(/datum/component/full_auto_fire)
	fullauto.fullauto_on(target)
	button.overlays += selected_frame
	active = TRUE


/datum/action/toggle_full_auto/remove_action()
	if(active)
		action_activate()
	return ..()


//Full auto proc.
/datum/proc/do_auto_fire()
	CRASH("[usr] calling for undefined do_auto_fire() on [src]")