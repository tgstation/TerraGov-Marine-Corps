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
		RegisterSignal(parent, COMSIG_GUN_FULLAUTOMODE_TOGGLEON, .proc/autofire_turning_on)
		RegisterSignal(parent, COMSIG_GUN_FULLAUTOMODE_TOGGLEOFF, .proc/autofire_turning_off)
		return
	return COMPONENT_INCOMPATIBLE


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()


// There is a gun. Let's configure it so that it turns on whenver the user wields it.
/datum/component/automatic_fire/proc/autofire_turning_on(datum/source, client/usercli)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/itemgun_equipped)
	var/mob/shooter = usercli.mob
	if(shooter.l_hand == parent || shooter.r_hand == parent)
		autofire_on(usercli)


/datum/component/automatic_fire/proc/autofire_turning_off(datum/source, client/usercli)
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	autofire_off()


// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/automatic_fire/proc/autofire_on(client/usercli)
	clicker = usercli
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, .proc/on_mouse_down)
	RegisterSignal(clicker.mob, COMSIG_MOB_LOGOUT, .proc/autofire_off)
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETED, COMSIG_ITEM_DROPPED), .proc/autofire_off)
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_STOPPED, /obj/item/weapon/gun/.proc/on_autofire_stop)
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, /obj/item/weapon/gun/.proc/autofire_fail_check)
	parent.RegisterSignal(parent, COMSIG_FULL_AUTO_FIRE, /obj/item/weapon/gun/.proc/do_autofire)


/datum/component/automatic_fire/proc/autofire_off(datum/source)
	if(!isnull(target))
		stop_autofiring()
	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
		if(!QDELETED(clicker.mob))
			UnregisterSignal(clicker.mob, COMSIG_MOB_LOGOUT)
	clicker = null
	parent.UnregisterSignal(parent, COMSIG_FULL_AUTO_FIRE)
	parent.UnregisterSignal(src, list(COMSIG_AUTOFIRE_ONMOUSEDOWN, COMSIG_AUTOFIRE_STOPPED))
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
	if(SEND_SIGNAL(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, source, target, location, control, params) & COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL) //Here's the chance to add a check before starting to fire.
		return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT
	src.target = target
	mouse_parameters = params
	start_autofiring()
	return COMSIG_CLIENT_MOUSEDOWN_INTERCEPT


//Dakka-dakka
/datum/component/automatic_fire/proc/start_autofiring()
	clicker.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, .proc/stop_autofiring)
	RegisterSignal(parent, COMSIG_GUN_CLICKEMPTY, .proc/stop_autofiring)
	if(autofire_flags & AUTOFIRE_TRACKTARGET)
		RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, .proc/on_mouse_drag)
	if(isgun(parent))
		var/obj/item/weapon/gun/shoota = parent
		delay = shoota.autofire_delay
	delay_timer = addtimer(CALLBACK(src, .proc/process), delay, TIMER_STOPPABLE|TIMER_LOOP)


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	SEND_SIGNAL(src, COMSIG_AUTOFIRE_STOPPED, clicker, object, location, control, params, shots_fired)
	shots_fired = 0
	clicker.mouse_pointer_icon = initial(clicker.mouse_pointer_icon)
	UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	UnregisterSignal(parent, COMSIG_GUN_CLICKEMPTY)
	target = null
	mouse_parameters = null
	if(delay_timer)
		deltimer(delay_timer)


/datum/component/automatic_fire/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	if(isnull(over_location)) //This happens when the mouse is over an inventory or screen object, or on entering deep darkness, for example.
		if(!isturf(target)) //If this happens, the target will be locked while we are able to move around, until the mouse enters another valid loc.
			target = get_turf(target) //So if it wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
		return
	target = over_object
	mouse_parameters = params


/datum/component/automatic_fire/process()
	switch(get_dist(clicker.mob, target))
		if(-1 to 0)
			target = get_step(clicker.mob, clicker.mob.dir) //Shoot in the direction faced if the mouse is on the same tile as we are.
		if(8 to INFINITY) //Can technically only go as far as 127 right now.
			return stop_autofiring() //Elvis has left the building.
	clicker.mob.face_atom(target)
	SEND_SIGNAL(parent, COMSIG_FULL_AUTO_FIRE, target, clicker.mob, mouse_parameters, ++shots_fired)


// obj/item/gun
/datum/component/automatic_fire/proc/itemgun_equipped(datum/source, mob/shooter, slot)
	switch(slot)
		if(SLOT_L_HAND, SLOT_R_HAND)
			autofire_on(shooter.client)
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


/obj/item/weapon/gun/proc/on_autofire_stop(datum/source, client/clicker, atom/object, turf/location, control, params, shots_fired)
	if(shots_fired > 1) //If it was a burst, apply the burst cooldown.
		extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3)


/obj/item/weapon/gun/proc/autofire_fail_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	if(!able_to_fire(clicker.mob) || gun_on_cooldown(clicker.mob))
		return COMSIG_AUTOFIRE_ONMOUSEDOWN_FAIL
	return NONE //No flags means success.


/obj/item/weapon/gun/proc/do_autofire(datum/source, atom/target, mob/shooter, params, shots_fired)
	set waitfor = FALSE
	//COMSIG_GUN_FIRE would go here.
	var/obj/item/projectile/projectile_to_fire = load_into_chamber(shooter)
	if(!projectile_to_fire)
		click_empty(shooter) //Will stop_autofiring() through COMSIG_GUN_CLICKEMPTY
		return
	apply_bullet_effects(projectile_to_fire, shooter, shots_fired)
	target = simulate_scatter(projectile_to_fire, target, get_turf(target), shooter)
	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		projectile_to_fire.p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		projectile_to_fire.p_y = text2num(mouse_control["icon-y"])
	simulate_recoil(0, shooter)
	projectile_to_fire.fire_at(target, shooter, src, projectile_to_fire.ammo.max_range, projectile_to_fire.ammo.shell_speed)
	last_fired = world.time
	muzzle_flash(Get_Angle(shooter, target), shooter)
	if(!reload_into_chamber(shooter))
		click_empty(shooter) //Will stop_autofiring() through COMSIG_GUN_CLICKEMPTY
		return
	//COMSIG_HUMAN_GUN_FIRED would go here.
	var/obj/screen/ammo/A = shooter.hud_used.ammo
	A.update_hud(shooter) //Ammo HUD.


/obj/item/weapon/gun/minigun/do_autofire(datum/source, atom/target, mob/shooter, params, shots_fired)
	if(shooter.action_busy)
		return
	if(shots_fired == 1) //First shot.
		playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
		if(!do_after(shooter, 0.5 SECONDS, TRUE, src, BUSY_ICON_DANGER))
			return
	return ..()