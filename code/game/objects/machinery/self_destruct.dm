/obj/machinery/self_destruct
	icon = 'icons/obj/machines/self_destruct.dmi'
	use_power = FALSE
	density = FALSE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	interaction_flags = INTERACT_MACHINE_TGUI
	var/active_state = SELF_DESTRUCT_MACHINE_INACTIVE
	///Whether only marines can activate this. left here in case of admins feeling nice or events
	var/marine_only_activate = TRUE
	///When the self destruct sequence was initiated
	var/started_at = 0
	/// Timer mainly used for hud timers
	var/timer


/obj/machinery/self_destruct/Initialize(mapload)
	. = ..()
	icon_state += "_1"


/obj/machinery/self_destruct/Destroy()
	GLOB.machines -= src
	return ..()


/obj/machinery/self_destruct/proc/toggle(lock)
	icon_state = initial(icon_state) + (lock ? "_1" : "_3")
	active_state = active_state > SELF_DESTRUCT_MACHINE_INACTIVE ? SELF_DESTRUCT_MACHINE_INACTIVE : SELF_DESTRUCT_MACHINE_ACTIVE


/obj/machinery/self_destruct/console
	name = "self destruct control panel"
	icon_state = "console"


/obj/machinery/self_destruct/console/Destroy()
	SSevacuation.dest_master = null
	SSevacuation.dest_rods = null
	return ..()


/obj/machinery/self_destruct/console/can_interact(mob/living/carbon/user)
	. = ..()
	if(!.)
		return
	if(marine_only_activate && !isterragovjob(user?.job))
		to_chat(user, span_warning("The [src] beeps, \"Marine retinal scan failed!\"."))
		return FALSE
	return TRUE

/obj/machinery/self_destruct/console/toggle(lock)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 25, 1)
	return ..()


/obj/machinery/self_destruct/console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SelfDestruct", name)
		ui.open()

/obj/machinery/self_destruct/console/ui_data(mob/user)
	var/list/data = list()
	data["dest_status"] = active_state
	if(active_state == SELF_DESTRUCT_MACHINE_ARMED)
		data["detonation_pcent"] = min(round(((world.time - started_at)  / (SELF_DESTRUCT_ROD_STARTUP_TIME)), 0.01), 1)  // percentage of time left to detonation
		data["detonation_time"] = DisplayTimeText(timeleft(timer), 1) //amount of time left to detonation
	else
		data["detonation_pcent"] = 0
		data["detonation_time"] = "Inactive"
	return data


/obj/machinery/self_destruct/console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("dest_start")
			to_chat(usr, span_notice("You press a few keys on the panel."))
			to_chat(usr, span_notice("The system must be booting up the self-destruct sequence now."))
			priority_announce("Danger. The emergency destruct system is now activated. The ship will detonate in T-minus 20 minutes. Automatic detonation is unavailable. Manual detonation is required.", "Priority Alert", sound = 'sound/AI/selfdestruct.ogg')
			active_state = SELF_DESTRUCT_MACHINE_ARMED
			var/obj/machinery/self_destruct/rod/I = SSevacuation.dest_rods[SSevacuation.dest_index]
			I.activate_time = world.time
			started_at = world.time
			SSevacuation.initiate_self_destruct()
			timer = addtimer(VARSET_CALLBACK(src, timer, null), SELF_DESTRUCT_ROD_STARTUP_TIME, TIMER_DELETE_ME|TIMER_STOPPABLE)

			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SHIP_SELF_DESTRUCT_ACTIVATED, src)
			. = TRUE

		if("dest_trigger")
			if(SSevacuation.initiate_self_destruct())
				SStgui.close_user_uis(usr, src, "main")

		if("dest_cancel")
			if(!isliving(usr))
				return
			var/mob/living/user = usr
			if(!ismarinecommandjob(user.job))
				to_chat(usr, span_notice("You don't have the necessary clearance to cancel the emergency destruct system."))
				return
			if(SSevacuation.cancel_self_destruct())
				SStgui.close_user_uis(usr, src, "main")


/obj/machinery/self_destruct/rod
	name = "self destruct control rod"
	desc = "It is part of a complicated self-destruct sequence, but relatively simple to operate. Twist to arm or disarm."
	icon_state = "rod"
	layer = BELOW_OBJ_LAYER
	var/activate_time


/obj/machinery/self_destruct/rod/Destroy()
	if(SSevacuation?.dest_rods)
		SSevacuation.dest_rods -= src
	return ..()


/obj/machinery/self_destruct/rod/toggle(lock)
	. = ..()
	playsound(src, 'sound/machines/hydraulics_2.ogg', 25, 1)
	if(lock)
		activate_time = null
		density = FALSE
		layer = initial(layer)
	else
		density = TRUE
		layer = ABOVE_OBJ_LAYER


/obj/machinery/self_destruct/rod/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	switch(active_state)
		if(SELF_DESTRUCT_MACHINE_ACTIVE)
			to_chat(user, span_notice("You twist and release the control rod, arming it."))
			playsound(src, 'sound/machines/switch.ogg', 25, 1)
			icon_state = "rod_4"
			active_state = SELF_DESTRUCT_MACHINE_ARMED
		if(SELF_DESTRUCT_MACHINE_ARMED)
			to_chat(user, span_notice("You twist and release the control rod, disarming it."))
			playsound(src, 'sound/machines/switch.ogg', 25, 1)
			icon_state = "rod_3"
			active_state = SELF_DESTRUCT_MACHINE_ACTIVE
		else
			to_chat(user, span_warning("The control rod is not ready."))
