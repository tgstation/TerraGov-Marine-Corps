#define AUTOFIRE_ON (1<<0)
#define AUTOFIRING (1<<1)


datum/component/automatic_fire
	var/client/clicker
	var/atom/target
	var/mouse_parameters
	var/shots_fired = 0
	var/autofire_shot_delay = 0.3 SECONDS //Time between individual shots.
	var/auto_delay_timer
	var/bursts_fired = 0
	var/burstfire_shot_delay = 0.2 SECONDS
	var/shots_to_fire = 0
	var/fire_mode
	var/autofire_flags = NONE


/datum/component/automatic_fire/Initialize()
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_GUN_FIREMODE_TOGGLE_ON, .proc/autofire_turning_on)
	RegisterSignal(parent, COMSIG_GUN_FIREMODE_TOGGLE_OFF, .proc/autofire_turning_off)
	/* This will require to refactor how gun configs are set and change many values.
	var/obj/item/weapon/gun/shoota = parent
	RegisterSignal(parent, COMSIG_GUN_SET_AUTOFIREDELAY, .proc/update_autofiredelay)
	autofire_delay = shoota.autofire_delay
	burstfire_shot_delay = shoota.burst_delay
	*/


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()


// There is a gun. Let's configure it so that it turns on whenver the user wields it.
/datum/component/automatic_fire/proc/autofire_turning_on(datum/source, client/usercli, fire_mode)
	if(!usercli) //This can happen if a mob without a client gets an active automatic gun put in their hands, for example.
		var/obj/item/weapon/gun/shoota = parent //We'll assume this is a gun for now.
		shoota.do_toggle_firemode(GUN_FIREMODE_SINGLEFIRE) //Let's try to reset it to single fire to avoid some quirkiness.
		return

	var/mob/shooter = usercli.mob

	switch(fire_mode)
		if(GUN_FIREMODE_SINGLEFIRE) //No need for autofire for this mode.
			autofire_off()
			return
		if(null)
			//No need to update the fire mode, just carry on.
		else
			src.fire_mode = fire_mode

	if(autofire_flags & AUTOFIRE_ON)
		return

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/itemgun_equipped)
	if(shooter.l_hand == parent || shooter.r_hand == parent)
		autofire_on(usercli)


/datum/component/automatic_fire/proc/autofire_turning_off(datum/source, client/usercli)
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	autofire_off()


// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/automatic_fire/proc/autofire_on(client/usercli)
	autofire_flags |= AUTOFIRE_ON
	clicker = usercli
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	RegisterSignal(clicker.mob, COMSIG_MOB_LOGOUT, .proc/autofire_off)
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETED, COMSIG_ITEM_DROPPED), .proc/autofire_off)
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, /obj/item/weapon/gun/.proc/autofire_fail_check)
	parent.RegisterSignal(parent, COMSIG_GUN_SHOT_AUTOFIRE, /obj/item/weapon/gun/.proc/do_autofire)


/datum/component/automatic_fire/proc/autofire_off(datum/source)
	if(!(autofire_flags & AUTOFIRE_ON))
		return
	autofire_flags &= ~AUTOFIRE_ON
	to_chat(world, "autofire_off || [src] || [target] || [clicker] || [shots_fired] || [fire_mode]")
	if(auto_delay_timer)
		stop_autofiring()
	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
		if(!QDELETED(clicker.mob))
			UnregisterSignal(clicker.mob, COMSIG_MOB_LOGOUT)
	clicker = null
	parent.UnregisterSignal(parent, COMSIG_GUN_SHOT_AUTOFIRE)
	parent.UnregisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN)
	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETED))


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
	if(auto_delay_timer)
		return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT //Some bastard is using sleep() on the procs. Gotta wait.
	if(SEND_SIGNAL(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, source, target, location, control, params) & COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL) //Here's the chance to add a check before starting to fire.
		return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT
	src.target = target
	mouse_parameters = params
	start_autofiring()
	return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT


//Dakka-dakka
/datum/component/automatic_fire/proc/start_autofiring()
	autofire_flags |= AUTOFIRING
	clicker.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, .proc/stop_autofiring)
	RegisterSignal(parent, COMSIG_GUN_CLICKEMPTY, .proc/stop_autofiring)
	var/obj/item/weapon/gun/shoota = parent //We'll assume this is a gun for now.
	if(auto_delay_timer)
		if(!deltimer(auto_delay_timer))
			to_chat(world, "start_autofiring || failed to delete [auto_delay_timer] timer")
			CRASH("start_autofiring || failed to delete [auto_delay_timer] timer")
		auto_delay_timer = null
		stack_trace("start_autofiring() called with an existent auto_delay_timer")
	autofire_shot_delay = shoota.fire_delay //For testing. In the long run this will be set via signals.
	switch(fire_mode)
		if(GUN_FIREMODE_AUTOFIRE)
			process_shot()
			auto_delay_timer = addtimer(CALLBACK(src, .proc/process_shot), autofire_shot_delay, TIMER_STOPPABLE|TIMER_LOOP)
		if(GUN_FIREMODE_BURSTFIRE)
			shots_to_fire = shoota.burst_amount //For testing. In the long run this will be set via signals.
			burstfire_shot_delay = shoota.burst_delay //For testing. In the long run this will be set via signals.
			process_burst()
			var/burstfire_burst_delay = (burstfire_shot_delay * shots_to_fire) + (autofire_shot_delay * 3) //For testing. In the long run this will be set via signals.
			auto_delay_timer = addtimer(CALLBACK(src, .proc/process_burst), burstfire_burst_delay, TIMER_STOPPABLE|TIMER_LOOP)
		else
			CRASH("start_autofiring() called with no fire_mode")
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	do_stop_autofiring()


/datum/component/automatic_fire/proc/do_stop_autofiring()
	to_chat(world, "do_stop_autofiring || [src] || [auto_delay_timer] || [parent] || [shots_fired] || [clicker] || [target] || [fire_mode]")
	if(auto_delay_timer) //Keep this at the top of the proc. If anything else runtimes or fails it would cause a potentially-infinite loop.
		if(!deltimer(auto_delay_timer))
			to_chat(world, "stop_autofiring || failed to delete [auto_delay_timer] timer")
			CRASH("stop_autofiring || failed to delete [auto_delay_timer] timer")
		auto_delay_timer = null
	if(!(autofire_flags & AUTOFIRING))
		return
	var/obj/item/weapon/gun/shoota = parent
	shoota.on_autofire_stop(shots_fired)
	autofire_flags &= ~AUTOFIRING
	shots_fired = 0
	if(clicker)
		clicker.mouse_pointer_icon = initial(clicker.mouse_pointer_icon)
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	UnregisterSignal(parent, COMSIG_GUN_CLICKEMPTY)
	target = null
	mouse_parameters = null


/datum/component/automatic_fire/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	if(isnull(over_location)) //This happens when the mouse is over an inventory or screen object, or on entering deep darkness, for example.
		if(!isturf(target)) //If this happens, the target will be locked while we are able to move around, until the mouse enters another valid loc.
			target = get_turf(target) //So if it wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
		return
	target = over_object
	mouse_parameters = params


/datum/component/automatic_fire/proc/process_shot()
	to_chat(world, "process_shot || [shots_fired] || [shots_to_fire]")
	switch(get_dist(clicker.mob, target))
		if(-1 to 0)
			target = get_step(clicker.mob, clicker.mob.dir) //Shoot in the direction faced if the mouse is on the same tile as we are.
		if(8 to INFINITY) //Can technically only go as far as 127 right now.
			do_stop_autofiring() //Elvis has left the building.
			return FALSE
	clicker.mob.face_atom(target)
	if(SEND_SIGNAL(parent, COMSIG_GUN_SHOT_AUTOFIRE, target, clicker.mob, mouse_parameters, ++shots_fired) & COMSIG_GUN_SHOT_AUTOFIRE_SUCCESS)
		return TRUE
	do_stop_autofiring()
	return FALSE


/datum/component/automatic_fire/proc/process_burst()
	set waitfor = FALSE
	var/current_burst = ++bursts_fired
	for(var/i in 1 to shots_to_fire)
		if(current_burst != bursts_fired)
			return
		if(!process_shot())
			return
		to_chat(world, "process_burst || [shots_fired] / [shots_to_fire] || [bursts_fired]")
		stoplag(burstfire_shot_delay)
	

// obj/item/gun
/datum/component/automatic_fire/proc/itemgun_equipped(datum/source, mob/shooter, slot)
	switch(slot)
		if(SLOT_L_HAND, SLOT_R_HAND)
			autofire_turning_on(src, shooter.client)
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

/obj/item/weapon/gun/proc/on_autofire_stop(shots_fired)
	if(shots_fired > 1) //If it was a burst, apply the burst cooldown.
		extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3)


/obj/item/weapon/gun/proc/autofire_fail_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	if(!able_to_fire(clicker.mob) || gun_on_cooldown(clicker.mob))
		return COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL
	return NONE //No flags means success.


/obj/item/weapon/gun/proc/do_autofire(datum/source, atom/target, mob/shooter, params, shots_fired)
	to_chat(world, "do_autofire || [src] || [target] || [shooter] || [shots_fired]")
	//COMSIG_GUN_FIRE would go here.
	var/obj/item/projectile/projectile_to_fire = load_into_chamber(shooter)
	if(!projectile_to_fire)
		click_empty(shooter)
		return NONE
	apply_bullet_effects(projectile_to_fire, shooter, shots_fired)
	target = simulate_scatter(projectile_to_fire, target, get_turf(target), shooter)
	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		projectile_to_fire.p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		projectile_to_fire.p_y = text2num(mouse_control["icon-y"])
	simulate_recoil(0 , shooter)
	projectile_to_fire.fire_at(target, shooter, src, projectile_to_fire.ammo.max_range, projectile_to_fire.ammo.shell_speed)
	last_fired = world.time
	muzzle_flash(Get_Angle(shooter, target), shooter)
	if(!reload_into_chamber(shooter))
		click_empty(shooter)
		return NONE
	//COMSIG_HUMAN_GUN_FIRED would go here.
	var/obj/screen/ammo/A = shooter.hud_used.ammo
	A.update_hud(shooter) //Ammo HUD.
	return COMSIG_GUN_SHOT_AUTOFIRE_SUCCESS //All is well, we can continue shooting.


/obj/item/weapon/gun/minigun/autofire_fail_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	. = ..()
	if(. == COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL)
		return //Will return COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL. Else . == NONE and will return that at the end of the proc should it not early return.
	var/mob/living/shooter = clicker.mob
	if(shooter.action_busy)
		return COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
	if(!do_after(shooter, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER))
		return COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL
