/obj/machinery/self_destruct
	icon = 'icons/obj/machines/self_destruct.dmi'
	use_power = FALSE
	density = FALSE
	anchored = TRUE
	resistance_flags = RESIST_ALL
	interaction_flags = INTERACT_MACHINE_TGUI
	var/active_state = SELF_DESTRUCT_MACHINE_INACTIVE
	ui_x = 470
	ui_y = 290

/obj/machinery/self_destruct/Initialize()
	. = ..()
	icon_state += "_1"


/obj/machinery/self_destruct/Destroy()
	GLOB.machines -= src
	operator = null
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


/obj/machinery/self_destruct/console/toggle(lock)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 25, 1)
	return ..()


/obj/machinery/self_destruct/console/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "SelfDestruct", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/self_destruct/console/ui_data(mob/user)
	return list("dest_status" = active_state)


/obj/machinery/self_destruct/console/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("dest_start")
			to_chat(usr, "<span class='notice'>You press a few keys on the panel.</span>")
			to_chat(usr, "<span class='notice'>The system must be booting up the self-destruct sequence now.</span>")
			priority_announce("Danger. The emergency destruct system is now activated. The ship will detonate in T-minus 20 minutes. Automatic detonation is unavailable. Manual detonation is required.", "Priority Alert", sound = 'sound/AI/selfdestruct.ogg')
			active_state = SELF_DESTRUCT_MACHINE_ARMED
			var/obj/machinery/self_destruct/rod/I = SSevacuation.dest_rods[SSevacuation.dest_index]
			I.activate_time = world.time
			SSevacuation.initiate_self_destruct()
			. = TRUE

		if("dest_trigger")
			if(SSevacuation.initiate_self_destruct())
				SStgui.close_user_uis(usr, src, "main")

		if("dest_cancel")
			if(!isliving(usr))
				return
			var/mob/living/user = usr
			if(!ismarinecommandjob(user.job))
				to_chat(usr, "<span class='notice'>You don't have the necessary clearance to cancel the emergency destruct system.</span>")
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
	if(SSevacuation)
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
			to_chat(user, "<span class='notice'>You twist and release the control rod, arming it.</span>")
			playsound(src, 'sound/machines/switch.ogg', 25, 1)
			icon_state = "rod_4"
			active_state = SELF_DESTRUCT_MACHINE_ARMED
		if(SELF_DESTRUCT_MACHINE_ARMED)
			to_chat(user, "<span class='notice'>You twist and release the control rod, disarming it.</span>")
			playsound(src, 'sound/machines/switch.ogg', 25, 1)
			icon_state = "rod_3"
			active_state = SELF_DESTRUCT_MACHINE_ACTIVE
		else
			to_chat(user, "<span class='warning'>The control rod is not ready.</span>")
