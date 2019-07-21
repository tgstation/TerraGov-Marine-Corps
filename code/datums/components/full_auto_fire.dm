#define AUTOFIRE_ON (1<<0)
#define AUTOFIRING (1<<1)

#define AUTOFIRE_STAT_SLEEPING 0 //Component is in the gun, but the gun is in a different firemode. Sleep until a compatible firemode is activated.
#define AUTOFIRE_STAT_IDLE 1 //Compatible firemode is in the gun. Wait until it's held in the user hands.
#define AUTOFIRE_STAT_ALERT	2 //Gun is active and in the user hands. Wait until user does a valid click.
#define AUTOFIRE_STAT_FIRING 3 //Dakka-dakka-dakka.

datum/component/automatic_fire
	var/client/clicker
	var/atom/target
	var/autofire_stat = AUTOFIRE_STAT_SLEEPING
	var/mouse_parameters
	var/shots_fired = 0
	var/autofire_shot_delay = 0.3 SECONDS //Time between individual shots.
	var/auto_delay_timer
	var/bursts_fired = 0
	var/burstfire_shot_delay = 0.2 SECONDS
	var/shots_to_fire = 0
	var/component_fire_mode


/datum/component/automatic_fire/Initialize()
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_GUN_FIREMODE_TOGGLE, .proc/wake_up)
	var/obj/item/weapon/gun/shoota = parent
	switch(shoota.gun_firemode)
		if(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
			var/usercli
			if(ismob(shoota.loc))
				var/mob/user = shoota.loc
				usercli = user.client
			wake_up(src, component_fire_mode, usercli)


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()


/datum/component/automatic_fire/proc/wake_up(datum/source, fire_mode, client/usercli)
	switch(fire_mode)
		if(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)
			switch(autofire_stat)
				if(AUTOFIRE_STAT_IDLE, AUTOFIRE_STAT_ALERT, AUTOFIRE_STAT_FIRING)
					sleep_up()
			return //No need for autofire on this mode.
	
	component_fire_mode = fire_mode
	
	switch(autofire_stat)
		if(AUTOFIRE_STAT_IDLE, AUTOFIRE_STAT_ALERT, AUTOFIRE_STAT_FIRING)
			return //We've updated the firemode. No need for more.
	
	autofire_stat = AUTOFIRE_STAT_IDLE

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETED, COMSIG_ITEM_DROPPED), .proc/autofire_off)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/itemgun_equipped)

	if(usercli)
		var/obj/item/weapon/gun/shoota = parent
		if(shoota.loc == usercli.mob)
			var/mob/shooter = usercli.mob
			if(shooter.l_hand == parent || shooter.r_hand == parent)
				autofire_on(usercli)


/datum/component/automatic_fire/proc/sleep_up()
	switch(autofire_stat)
		if(AUTOFIRE_STAT_SLEEPING)
			return //Already asleep
		if(AUTOFIRE_STAT_IDLE, AUTOFIRE_STAT_ALERT, AUTOFIRE_STAT_FIRING)
			autofire_off()

	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETED, COMSIG_ITEM_EQUIPPED))
	
	autofire_stat = AUTOFIRE_STAT_SLEEPING


// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/automatic_fire/proc/autofire_on(client/usercli)
	switch(autofire_stat)
		if(AUTOFIRE_STAT_ALERT, AUTOFIRE_STAT_FIRING)
			return
	autofire_stat = AUTOFIRE_STAT_ALERT
	clicker = usercli
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	RegisterSignal(clicker.mob, COMSIG_MOB_LOGOUT, .proc/autofire_off)
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, /obj/item/weapon/gun/.proc/autofire_bypass_check)
	parent.RegisterSignal(parent, COMSIG_GUN_SHOT_AUTOFIRE, /obj/item/weapon/gun/.proc/do_autofire)


/datum/component/automatic_fire/proc/autofire_off(datum/source)
	switch(autofire_stat)
		if(AUTOFIRE_STAT_SLEEPING, AUTOFIRE_STAT_IDLE)
			return
		if(AUTOFIRE_STAT_FIRING)
			stop_autofiring()
	autofire_stat = AUTOFIRE_STAT_IDLE
	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
		if(!QDELETED(clicker.mob))
			UnregisterSignal(clicker.mob, COMSIG_MOB_LOGOUT)
	clicker = null
	parent.UnregisterSignal(parent, COMSIG_GUN_SHOT_AUTOFIRE)
	parent.UnregisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN)


/datum/component/automatic_fire/proc/on_mouse_down(client/source, atom/target, turf/location, control, params)
	var/list/modifiers = params2list(params) //If they're shift+clicking, for example, let's not have them accidentally shoot.
	if(modifiers["shift"])
		return
	if(modifiers["ctrl"])
		return
	if(modifiers["middle"])
		return
	if(modifiers["alt"])
		return

	if(source.mob.in_throw_mode)
		return

	if(get_dist(source.mob, target) < 2) //Adjacent clicking.
		return

	if(isnull(location)) //Clicking on a screen object.
		if(target.plane != CLICKCATCHER_PLANE) //The clickcatcher is a special case. We want the click to trigger then, under it.
			return //If we click and drag on our worn backpack, for example, we want it to open instead.
		target = params2turf(modifiers["screen-loc"], get_turf(source.eye), source)
		if(!target)
			CRASH("Failed to get the turf under clickcatcher")
	
	if(SEND_SIGNAL(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, source, target, location, control, params) & COMSIG_AUTOFIRE_ONMOUSEDOWN_BYPASS)
		return

	source.click_intercepted = world.time //From this point onwards Click() will no longer be triggered.

	if(auto_delay_timer)
		CRASH("on_mouse_down() called with an active auto_delay_timer")

	src.target = target
	mouse_parameters = params
	start_autofiring()


//Dakka-dakka
/datum/component/automatic_fire/proc/start_autofiring()
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		return
	var/obj/item/weapon/gun/shoota = parent //We'll assume this is a gun for now.
	autofire_stat = AUTOFIRE_STAT_FIRING
	clicker.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, .proc/on_mouse_up)
	if(!shoota.on_autofire_start(clicker))
		stop_autofiring()
		return
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return //Might have been interrupted while on_autofire_start() was being processed.
	RegisterSignal(parent, COMSIG_GUN_CLICKEMPTY, .proc/stop_autofiring)
	if(auto_delay_timer)
		if(!deltimer(auto_delay_timer))
			addtimer(CALLBACK(src, .proc/keep_trying_to_delete_timer, auto_delay_timer), 0.1 SECONDS) //Next tick hopefully.
		auto_delay_timer = null
	autofire_shot_delay = shoota.fire_delay //For testing. In the long run this will be set via signals.
	switch(component_fire_mode)
		if(GUN_FIREMODE_AUTOMATIC)
			process_shot()
			auto_delay_timer = addtimer(CALLBACK(src, .proc/process_shot), autofire_shot_delay, TIMER_STOPPABLE|TIMER_LOOP)
		if(GUN_FIREMODE_AUTOBURST)
			shots_to_fire = shoota.burst_amount //For testing. In the long run this will be set via signals.
			burstfire_shot_delay = shoota.burst_delay //For testing. In the long run this will be set via signals.
			process_burst()
			var/burstfire_burst_delay = (burstfire_shot_delay * shots_to_fire) + (autofire_shot_delay * 3) //For testing. In the long run this will be set via signals.
			auto_delay_timer = addtimer(CALLBACK(src, .proc/process_burst), burstfire_burst_delay, TIMER_STOPPABLE|TIMER_LOOP)
		else
			CRASH("start_autofiring() called with no valid component_fire_mode")
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)


/datum/component/automatic_fire/proc/on_mouse_up(datum/source, atom/object, turf/location, control, params)
	if(clicker)
		UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEUP)
	stop_autofiring()
	return COMSIG_CLIENT_MOUSEUP_INTERCEPT


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	switch(autofire_stat)
		if(AUTOFIRE_STAT_SLEEPING, AUTOFIRE_STAT_IDLE, AUTOFIRE_STAT_ALERT)
			return
	autofire_stat = AUTOFIRE_STAT_ALERT
	if(auto_delay_timer) //Keep this at the top of the proc. If anything else runtimes or fails it would cause a potentially-infinite loop.
		if(!deltimer(auto_delay_timer))
			addtimer(CALLBACK(src, .proc/keep_trying_to_delete_timer, auto_delay_timer), 0.1 SECONDS) //Next tick hopefully.
		auto_delay_timer = null
	if(clicker)
		clicker.mouse_pointer_icon = initial(clicker.mouse_pointer_icon)
		UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG)
	UnregisterSignal(parent, COMSIG_GUN_CLICKEMPTY)
	var/obj/item/weapon/gun/shoota = parent
	shoota.on_autofire_stop(shots_fired)
	shots_fired = 0
	target = null
	mouse_parameters = null


/datum/component/automatic_fire/proc/keep_trying_to_delete_timer(timer_id) //This is an ugly hack until a fix for timers being unable to be deleted from inside the call stack is done.
	set waitfor = FALSE
	while(!(deltimer(timer_id)))
		var/datum/timedevent/timer = SStimer.timer_id_dict[timer_id] //This is not a kosher thing to do outside of the SS. But this is a temporary hack.
		if(!timer)
			return //Has already been deleted.
		stoplag(1) //Let's try again next tick.
	

/datum/component/automatic_fire/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	if(isnull(over_location)) //This happens when the mouse is over an inventory or screen object, or on entering deep darkness, for example.
		var/list/modifiers = params2list(params)
		var/new_target = params2turf(modifiers["screen-loc"], get_turf(source.eye), source)
		if(!new_target)
			target = get_turf(target) //If previous target wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
			CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]")
		target = new_target
		return
	target = over_object
	mouse_parameters = params


/datum/component/automatic_fire/proc/process_shot()
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return
	switch(get_dist(clicker.mob, target))
		if(-1 to 0)
			target = get_step(clicker.mob, clicker.mob.dir) //Shoot in the direction faced if the mouse is on the same tile as we are.
		if(8 to INFINITY) //Can technically only go as far as 127 right now.
			stop_autofiring() //Elvis has left the building.
			return FALSE
	clicker.mob.face_atom(target)
	if(SEND_SIGNAL(parent, COMSIG_GUN_SHOT_AUTOFIRE, target, clicker.mob, mouse_parameters, ++shots_fired) & COMSIG_GUN_SHOT_AUTOFIRE_SUCCESS)
		return TRUE
	stop_autofiring()
	return FALSE


/datum/component/automatic_fire/proc/process_burst()
	set waitfor = FALSE
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return
	var/current_burst = ++bursts_fired
	for(var/i in 1 to shots_to_fire)
		if(current_burst != bursts_fired)
			return
		if(!process_shot())
			return
		stoplag(burstfire_shot_delay)
	

// obj/item/gun
/datum/component/automatic_fire/proc/itemgun_equipped(datum/source, mob/shooter, slot)
	switch(slot)
		if(SLOT_L_HAND, SLOT_R_HAND)
			autofire_on(shooter.client)
		else
			switch(autofire_stat)
				if(AUTOFIRE_STAT_ALERT, AUTOFIRE_STAT_FIRING)
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
/obj/item/weapon/gun/proc/on_autofire_start(client/clicker)
	if(!able_to_fire(clicker.mob) || gun_on_cooldown(clicker.mob))
		return FALSE
	return TRUE


/obj/item/weapon/gun/proc/on_autofire_stop(shots_fired)
	if(shots_fired > 1) //If it was a burst, apply the burst cooldown.
		extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3)


/obj/item/weapon/gun/proc/autofire_bypass_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	if(clicker.mob.get_active_held_item() != src)
		return COMSIG_AUTOFIRE_ONMOUSEDOWN_BYPASS
	return NONE //No flags means success.


/obj/item/weapon/gun/proc/do_autofire(datum/source, atom/target, mob/shooter, params, shots_fired)
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


/obj/item/weapon/gun/minigun/on_autofire_start(client/clicker)
	. = ..()
	if(!.)
		return
	if(clicker.mob.action_busy)
		return FALSE
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
	if(!do_after(clicker.mob, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER))
		return FALSE
