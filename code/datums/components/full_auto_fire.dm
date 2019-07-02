#define AUTOFIRE_TRACKTARGET (1<<0)


/datum/component/automatic_fire
	var/client/clicker
	var/atom/target
	var/mouse_parameters
	var/delay = 0.2 SECONDS //How long between each fire signal.
	var/delay_timer
	var/autofire_flags = AUTOFIRE_TRACKTARGET
	var/shots_fired = 0


/datum/component/automatic_fire/Initialize(...)
	. = ..()
	if(isgun(parent))
		RegisterSignal(parent, COMSIG_GUN_FULLAUTOMODE_TOGGLEON, .proc/autofire_on)
		RegisterSignal(parent, COMSIG_GUN_FULLAUTOMODE_TOGGLEOFF, .proc/autofire_off)
		return
	return COMPONENT_INCOMPATIBLE


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()


/datum/component/automatic_fire/proc/autofire_on(datum/source, client/usercli, new_delay, flags)
	clicker = usercli
	if(!isnull(flags))
		autofire_flags = flags
	if(!isnull(new_delay))
		delay = new_delay
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	RegisterSignal(clicker.mob, COMSIG_MOB_LOGOUT, .proc/autofire_off)
	RegisterSignal(parent, COMSIG_PARENT_QDELETED, .proc/autofire_off)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/autofire_off)
	parent.RegisterSignal(parent, COMSIG_FULL_AUTO_FIRE, /obj/item/weapon/gun/.proc/do_autofire)


/datum/component/automatic_fire/proc/autofire_off()
	if(!isnull(target))
		stop_autofiring()
	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
		if(!QDELETED(clicker.mob))
			UnregisterSignal(clicker.mob, COMSIG_MOB_LOGOUT)
	clicker = null
	parent.UnregisterSignal(parent, COMSIG_FULL_AUTO_FIRE)
	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETED))
	delay = initial(delay)


/datum/component/automatic_fire/proc/on_mouse_down(client/source, atom/target, turf/location, control, params)
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
	src.target = target
	mouse_parameters = params
	start_autofiring()
	return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT


/datum/component/automatic_fire/proc/start_autofiring()
	clicker.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, .proc/stop_autofiring)
	if(autofire_flags & AUTOFIRE_TRACKTARGET)
		RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)
	delay_timer = addtimer(CALLBACK(src, .proc/process), delay, TIMER_STOPPABLE|TIMER_LOOP)


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	shots_fired = 0
	clicker.mouse_pointer_icon = initial(clicker.mouse_pointer_icon)
	UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	autofire_flags = initial(autofire_flags)
	target = null
	mouse_parameters = null
	if(delay_timer)
		deltimer(delay_timer)


/datum/component/automatic_fire/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	if(isnull(over_location))
		return //This happens when the mouse is over an inventory or screen object, for example.
	target = over_object
	mouse_parameters = params


/datum/component/automatic_fire/process()
	SEND_SIGNAL(parent, COMSIG_FULL_AUTO_FIRE, target, clicker.mob, mouse_parameters, ++shots_fired)


// obj/item/gun
/datum/component/automatic_fire/proc/itemgun_equipped(datum/source, mob/shooter, slot)
	switch(slot)
		if(SLOT_L_HAND, SLOT_R_HAND)
			autofire_on(source, shooter.client)
		else
			autofire_off()
	

/*
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
		var/datum/component/automatic_fire/fullauto = owner.client.LoadComponent(/datum/component/automatic_fire)
		fullauto.autofire_off()
		button.overlays -= selected_frame
		active = FALSE
		return
	var/datum/component/automatic_fire/fullauto = owner.client.LoadComponent(/datum/component/automatic_fire)
	fullauto.autofire_on(target)
	button.overlays += selected_frame
	active = TRUE


/datum/action/toggle_full_auto/remove_action()
	if(active)
		action_activate()
	return ..()
*/


//Procs to be put elsewhere later on.


/obj/item/weapon/gun/proc/do_autofire(datum/source, atom/target, mob/shooter, params, shots_fired)
	if(get_dist(shooter, target) < 1)
		return //Can't autofire-shoot ourselves or on the same tile.

	Fire(target, shooter, params) //Otherwise, fire normally.


/obj/item/weapon/gun/minigun/do_autofire(datum/source, atom/target, mob/shooter, params, shots_fired)
	if(shooter.action_busy)
		return
	if(shots_fired == 1) //First shot.
		playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
		if(!do_after(shooter, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER))
			return
	return ..()