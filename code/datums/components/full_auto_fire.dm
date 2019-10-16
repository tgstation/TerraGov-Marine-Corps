#define AUTOFIRE_MOUSEUP 0
#define AUTOFIRE_MOUSEDOWN 1

/datum/component/automatic_fire
	var/client/clicker
	var/mob/living/shooter
	var/atom/target
	var/turf/target_loc //For dealing with locking on targets due to BYOND engine limitations (the mouse input only happening when mouse moves).
	var/autofire_stat = AUTOFIRE_STAT_SLEEPING
	var/mouse_parameters
	var/shots_fired = 0
	var/autofire_shot_delay = 0.3 SECONDS //Time between individual shots.
	var/auto_delay_timer
	var/bursts_fired = 0
	var/burstfire_shot_delay = 0.2 SECONDS
	var/shots_to_fire = 0
	var/component_fire_mode
	var/mouse_status = AUTOFIRE_MOUSEUP //This seems hacky but there can be two MouseDown() without a MouseUp() in between if the user holds click and uses alt+tab, printscreen or similar.


/datum/component/automatic_fire/Initialize(autofire_shot_delay, burstfire_shot_delay, shots_to_fire, firemode, parent_loc)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_GUN_FIREMODE_TOGGLE, .proc/wake_up)
	RegisterSignal(parent, COMSIG_GUN_FIREDELAY_MODIFIED, .proc/modify_firedelay)
	RegisterSignal(parent, COMSIG_GUN_BURSTDELAY_MODIFIED, .proc/modify_burst_delay)
	RegisterSignal(parent, COMSIG_GUN_BURSTAMOUNT_MODIFIED, .proc/modify_burst_amount)

	src.autofire_shot_delay = autofire_shot_delay
	src.burstfire_shot_delay = burstfire_shot_delay
	src.shots_to_fire = shots_to_fire

	switch(firemode)
		if(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
			var/usercli
			if(ismob(parent_loc))
				var/mob/user = parent_loc
				usercli = user.client
			wake_up(src, firemode, usercli)


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()


/datum/component/automatic_fire/proc/wake_up(datum/source, fire_mode, client/usercli)
	switch(fire_mode)
		if(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
			component_fire_mode = fire_mode
		else
			if(autofire_stat & (AUTOFIRE_STAT_IDLE|AUTOFIRE_STAT_ALERT|AUTOFIRE_STAT_FIRING))
				sleep_up()
			return //No need for autofire on other modes.
	
	if(autofire_stat & (AUTOFIRE_STAT_IDLE|AUTOFIRE_STAT_ALERT))
		return //We've updated the firemode. No need for more.
	if(autofire_stat & AUTOFIRE_STAT_FIRING)
		stop_autofiring() //Let's stop shooting to avoid issues.
		return
	
	autofire_stat = AUTOFIRE_STAT_IDLE

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETED), .proc/sleep_up)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/itemgun_equipped)

	if(usercli)
		var/obj/item/weapon/gun/shoota = parent
		if(shoota.loc == usercli.mob)
			var/mob/shooter = usercli.mob
			if(shooter.l_hand == parent || shooter.r_hand == parent)
				autofire_on(usercli)


/datum/component/automatic_fire/proc/sleep_up()
	if(autofire_stat & AUTOFIRE_STAT_SLEEPING)
		return //Already asleep

	autofire_off()

	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETED, COMSIG_ITEM_EQUIPPED))
	
	autofire_stat = AUTOFIRE_STAT_SLEEPING


// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/automatic_fire/proc/autofire_on(client/usercli)
	if(autofire_stat & (AUTOFIRE_STAT_ALERT|AUTOFIRE_STAT_FIRING))
		return
	autofire_stat = AUTOFIRE_STAT_ALERT
	clicker = usercli
	shooter = clicker.mob
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/autofire_off)
	RegisterSignal(shooter, COMSIG_MOB_LOGOUT, .proc/autofire_off)
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, /obj/item/weapon/gun/.proc/autofire_bypass_check)
	parent.RegisterSignal(parent, COMSIG_AUTOFIRE_SHOT, /obj/item/weapon/gun/.proc/do_autofire)


/datum/component/automatic_fire/proc/autofire_off(datum/source)
	if(autofire_stat & (AUTOFIRE_STAT_SLEEPING|AUTOFIRE_STAT_IDLE))
		return
	if(autofire_stat & AUTOFIRE_STAT_FIRING)
		stop_autofiring()

	autofire_stat = AUTOFIRE_STAT_IDLE

	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	mouse_status = AUTOFIRE_MOUSEUP //In regards to the component there's no click anymore to care about.
	clicker = null
	if(!QDELETED(shooter))
		UnregisterSignal(shooter, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	shooter = null
	parent.UnregisterSignal(parent, COMSIG_AUTOFIRE_SHOT)
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
	if(!isturf(source.mob.loc)) //No firing inside lockers and stuff.
		return
	if(get_dist(source.mob, target) < 2) //Adjacent clicking.
		return

	if(isnull(location)) //Clicking on a screen object.
		if(target.plane != CLICKCATCHER_PLANE) //The clickcatcher is a special case. We want the click to trigger then, under it.
			return //If we click and drag on our worn backpack, for example, we want it to open instead.
		target = params2turf(modifiers["screen-loc"], get_turf(source.eye), source)
		if(!target)
			CRASH("Failed to get the turf under clickcatcher")
		//icon-x/y is relative to the object clicked. click_catcher may occupy several tiles. Here we convert them to the proper offsets relative to the tile.
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
		params = list2params(modifiers)
	
	if(SEND_SIGNAL(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, source, target, location, control, params) & COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS)
		return

	source.click_intercepted = world.time //From this point onwards Click() will no longer be triggered.

	if(autofire_stat & (AUTOFIRE_STAT_SLEEPING|AUTOFIRE_STAT_IDLE))
		CRASH("on_mouse_down() called with [autofire_stat] autofire_stat")
	if(autofire_stat & AUTOFIRE_STAT_FIRING)
		stop_autofiring() //This can happen if we click and hold and then alt+tab, printscreen or other such action. MouseUp won't be called then and it will keep autofiring.

	src.target = target
	target_loc = get_turf(target)
	mouse_parameters = params
	start_autofiring()


//Dakka-dakka
/datum/component/automatic_fire/proc/start_autofiring()
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		return //Already pew-pewing.
	autofire_stat = AUTOFIRE_STAT_FIRING

	if(auto_delay_timer) //This shouldn't be happening, so let's stack_trace it and remove it if nothing is caught.
		stack_trace("start_autofiring called with a non-null auto_delay_timer")
		if(!deltimer(auto_delay_timer))
			INVOKE_NEXT_TICK(src, .proc/keep_trying_to_delete_timer, auto_delay_timer)
		auto_delay_timer = null

	clicker.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

	if(mouse_status == AUTOFIRE_MOUSEUP) //See mouse_status definition for the reason for this.
		RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, .proc/on_mouse_up)
		mouse_status = AUTOFIRE_MOUSEDOWN

	RegisterSignal(shooter, COMSIG_CARBON_SWAPPED_HANDS, .proc/stop_autofiring)

	if(isgun(parent))
		var/obj/item/weapon/gun/shoota = parent
		if(!shoota.on_autofire_start(shooter)) //This is needed because the minigun has a do_after before firing and signals are async.
			stop_autofiring()
			return
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return //Things may have changed while on_autofire_start() was being processed, due to do_after's sleep.

	switch(component_fire_mode)
		if(GUN_FIREMODE_AUTOMATIC)
			if(!process_shot()) //First shot is processed instantly.
				return //If it fails, such as when the gun is empty, then there's no need to schedule a second shot.
			auto_delay_timer = addtimer(CALLBACK(src, .proc/process_shot), autofire_shot_delay, TIMER_STOPPABLE|TIMER_LOOP)
		if(GUN_FIREMODE_AUTOBURST)
			process_burst()
			if(autofire_stat != AUTOFIRE_STAT_FIRING)
				return //If process_burst() fails, it will stop autofiring. We don't want a timer added then.
			var/burstfire_burst_delay = (burstfire_shot_delay * shots_to_fire) + (autofire_shot_delay * 3) //Delay between bursts, values taken from the maximum possible in non-auto burst mode.
			auto_delay_timer = addtimer(CALLBACK(src, .proc/process_burst), burstfire_burst_delay, TIMER_STOPPABLE|TIMER_LOOP)
		else
			CRASH("start_autofiring() called with no valid component_fire_mode")

	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)


/datum/component/automatic_fire/proc/on_mouse_up(datum/source, atom/object, turf/location, control, params)
	UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEUP)
	mouse_status = AUTOFIRE_MOUSEUP
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		stop_autofiring()
	return COMPONENT_CLIENT_MOUSEUP_INTERCEPT


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	switch(autofire_stat)
		if(AUTOFIRE_STAT_SLEEPING, AUTOFIRE_STAT_IDLE, AUTOFIRE_STAT_ALERT)
			return
	autofire_stat = AUTOFIRE_STAT_ALERT
	if(auto_delay_timer) //Keep this at the top of the proc. If anything else runtimes or fails it would cause a potentially-infinite loop.
		if(!deltimer(auto_delay_timer))
			INVOKE_NEXT_TICK(src, .proc/keep_trying_to_delete_timer, auto_delay_timer)
		auto_delay_timer = null
	if(clicker)
		clicker.mouse_pointer_icon = initial(clicker.mouse_pointer_icon)
		UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG)
	if(!QDELETED(shooter))
		UnregisterSignal(shooter, COMSIG_CARBON_SWAPPED_HANDS)
	var/obj/item/weapon/gun/shoota = parent
	shoota.on_autofire_stop(shots_fired)
	shots_fired = 0
	target = null
	target_loc = null
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
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
		params = list2params(modifiers)
		mouse_parameters = params
		if(!new_target)
			if(QDELETED(target)) //No new target acquired, and old one was deleted, get us out of here.
				stop_autofiring()
				CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]. Old target was incidentally QDELETED.")
			target = get_turf(target) //If previous target wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
			target_loc = target
			CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]")
		target = new_target
		target_loc = new_target
		return
	target = over_object
	target_loc = get_turf(over_object)
	mouse_parameters = params


/datum/component/automatic_fire/proc/process_shot()
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return
	if(get_turf(target) != target_loc) //Target moved since we last aimed.
		target = target_loc //So we keep firing on the emptied tile until we move our mouse and find a new target.
	switch(get_dist(shooter, target))
		if(-1 to 0)
			target = get_step(shooter, shooter.dir) //Shoot in the direction faced if the mouse is on the same tile as we are.
			target_loc = target
		if(8 to INFINITY) //Can technically only go as far as 127 right now.
			stop_autofiring() //Elvis has left the building.
			return FALSE
	shooter.face_atom(target)
	if(SEND_SIGNAL(parent, COMSIG_AUTOFIRE_SHOT, target, shooter, mouse_parameters, ++shots_fired) & COMPONENT_AUTOFIRE_SHOT_SUCCESS)
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
	

/datum/component/automatic_fire/proc/itemgun_equipped(datum/source, mob/shooter, slot)
	switch(slot)
		if(SLOT_L_HAND, SLOT_R_HAND)
			autofire_on(shooter.client)
		else
			switch(autofire_stat)
				if(AUTOFIRE_STAT_ALERT, AUTOFIRE_STAT_FIRING)
					autofire_off()


/datum/component/automatic_fire/proc/modify_firedelay(datum/source, new_delay)
	autofire_shot_delay = new_delay

/datum/component/automatic_fire/proc/modify_burst_delay(datum/source, new_delay)
	burstfire_shot_delay = new_delay

/datum/component/automatic_fire/proc/modify_burst_amount(datum/source, new_amount)
	shots_to_fire = new_amount

// Gun procs.

/obj/item/weapon/gun/proc/on_autofire_start(mob/living/shooter)
	if(!able_to_fire(shooter) || gun_on_cooldown(shooter))
		return FALSE
	return TRUE


/obj/item/weapon/gun/proc/on_autofire_stop(shots_fired)
	if(shots_fired > 1) //If it was a burst, apply the burst cooldown.
		extra_delay += fire_delay * 1.5


/obj/item/weapon/gun/proc/autofire_bypass_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	if(clicker.mob.get_active_held_item() != src)
		return COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS


/obj/item/weapon/gun/proc/do_autofire(datum/source, atom/target, mob/living/shooter, params, shots_fired)
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIRE, target, shooter)
	var/obj/item/projectile/projectile_to_fire = load_into_chamber(shooter)
	if(!projectile_to_fire)
		click_empty(shooter)
		return NONE
	var/dual_wield = FALSE
	var/obj/item/weapon/gun/akimbo_gun = shooter.get_inactive_held_item()
	if(istype(akimbo_gun))
		dual_wield = TRUE
		akimbo_gun.Fire(target, shooter, params, FALSE, dual_wield)
	apply_gun_modifiers(projectile_to_fire, target)
	setup_bullet_accuracy(projectile_to_fire, shooter, shots_fired, dual_wield)
	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		projectile_to_fire.p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		projectile_to_fire.p_y = text2num(mouse_control["icon-y"])
	simulate_recoil(0 , shooter)
	play_fire_sound(shooter)
	var/firing_angle = get_angle_with_scatter(shooter, target, get_scatter(projectile_to_fire.scatter, shooter), projectile_to_fire.p_x, projectile_to_fire.p_y)
	muzzle_flash(firing_angle, shooter)
	projectile_to_fire.fire_at(target, shooter, src, projectile_to_fire.ammo.max_range, projectile_to_fire.ammo.shell_speed, firing_angle)
	last_fired = world.time
	if(!reload_into_chamber(shooter))
		click_empty(shooter)
		return NONE
	SEND_SIGNAL(shooter, COMSIG_HUMAN_GUN_AUTOFIRED, target, src, shooter)
	var/obj/screen/ammo/A = shooter.hud_used.ammo
	A.update_hud(shooter) //Ammo HUD.
	return COMPONENT_AUTOFIRE_SHOT_SUCCESS //All is well, we can continue shooting.


/obj/item/weapon/gun/minigun/on_autofire_start(mob/living/shooter)
	. = ..()
	if(!.)
		return
	if(shooter.action_busy)
		return FALSE
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
	if(!do_after(shooter, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER))
		return FALSE

#undef AUTOFIRE_MOUSEUP
#undef AUTOFIRE_MOUSEDOWN
