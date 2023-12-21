#define NUKE_STAGE_NONE 0
#define NUKE_STAGE_COVER_REMOVED 1
#define NUKE_STAGE_COVER_OPENED 2
#define NUKE_STAGE_SEALANT_OPEN 3
#define NUKE_STAGE_UNWRENCHED 4
#define NUKE_STAGE_BOLTS_REMOVED 5

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	anchored = TRUE
	coverage = 20
	flags_atom = CRITICAL_ATOM
	resistance_flags = RESIST_ALL
	layer = BELOW_MOB_LAYER
	interaction_flags = INTERACT_OBJ_UI
	var/deployable = TRUE
	var/extended = FALSE
	var/lighthack = FALSE
	///Time to start the timer on
	var/time = 360 SECONDS
	///Min time for the nuke timer
	var/timemin = 360 SECONDS
	///Max time for the nuke timer
	var/timemax = 1200 SECONDS
	var/timer_enabled = FALSE
	///ID of timer
	var/timer
	var/safety = TRUE
	var/exploded = FALSE
	var/removal_stage = NUKE_STAGE_NONE
	use_power = NO_POWER_USE
	var/obj/effect/countdown/nuclearbomb/countdown

	var/has_auth
	var/obj/item/disk/nuclear/red/r_auth
	var/obj/item/disk/nuclear/green/g_auth
	var/obj/item/disk/nuclear/blue/b_auth

/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	GLOB.nuke_list += src
	countdown = new(src)
	name = "[initial(name)] ([UNIQUEID])"
	update_minimap_icon()
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(disable_on_hijack))

/obj/machinery/nuclearbomb/Destroy()
	if(timer_enabled)
		disable()
	GLOB.nuke_list -= src
	QDEL_NULL(countdown)
	return ..()

///Enables nuke timer
/obj/machinery/nuclearbomb/proc/enable()
	GLOB.active_nuke_list += src
	countdown.start()
	notify_ghosts("[usr] enabled the [src], it has [round(time MILLISECONDS)] seconds on the timer.", source = src, action = NOTIFY_ORBIT, extra_large = TRUE)
	timer_enabled = TRUE
	timer = addtimer(CALLBACK(src, PROC_REF(explode)), time, TIMER_STOPPABLE)
	update_minimap_icon()
	// The timer is needed for when the signal is sent
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_START, src)

///Disables nuke timer
/obj/machinery/nuclearbomb/proc/disable()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_STOP, src)
	countdown.stop()
	GLOB.active_nuke_list -= src
	timer_enabled = FALSE
	if(timer)
		deltimer(timer)
		timer = null
	update_minimap_icon()

///Handles the boom
/obj/machinery/nuclearbomb/proc/explode()
	disable()

	if(safety)
		return
	if(exploded)
		return
	exploded = TRUE
	safety = TRUE
	if(!lighthack)
		icon_state = "nuclearbomb3"

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_EXPLODED, z)
	return TRUE

/// Permanently disables this nuke, for use on hijack
/obj/machinery/nuclearbomb/proc/disable_on_hijack()
	desc += " A strong interference renders this inoperable."
	machine_stat |= BROKEN
	anchored = FALSE
	if(timer_enabled)
		disable()

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!extended)
		return
	if(!istype(I, /obj/item/disk/nuclear))
		return
	if(!user.transferItemToLoc(I, src))
		return
	switch(I.type)
		if(/obj/item/disk/nuclear/red)
			r_auth = I
		if(/obj/item/disk/nuclear/green)
			g_auth = I
		if(/obj/item/disk/nuclear/blue)
			b_auth = I
	if(r_auth && g_auth && b_auth)
		has_auth = TRUE

/obj/machinery/nuclearbomb/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(!timer_enabled)
		to_chat(X, span_warning("\The [src] is soundly asleep. We better not disturb it."))
		return

	X.visible_message("[X] begins to slash delicately at the nuke",
	"You start slashing delicately at the nuke.")
	if(!do_after(X, 5 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return
	X.visible_message("[X] disabled the nuke",
	"You disabled the nuke.")

	disable()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DIFFUSED, src, X)

/obj/machinery/nuclearbomb/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!extended)
		return FALSE

	if(machine_stat & BROKEN)
		return FALSE

	return TRUE

/obj/machinery/nuclearbomb/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(extended)
		return

	if(!deployable)
		return

	if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return

	if(removal_stage < NUKE_STAGE_BOLTS_REMOVED)
		if(anchored)
			visible_message(span_warning("With a loud beep, lights flicker on the [src]'s display panel. It's working!"))
		else
			anchored = TRUE
			visible_message(span_warning("With a steely snap, bolts slide out of [src] and anchor it to the flooring!"))
	else
		visible_message(span_warning("\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut."))
	if(!lighthack)
		flick("nuclearbombc", src)
		icon_state = "nuclearbomb1"

	extended = TRUE

/obj/machinery/nuclearbomb/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb", name)
		ui.open()

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()

	data["time"] = round(time MILLISECONDS)
	data["time_left"] = get_time_left()
	data["timer_enabled"] = timer_enabled
	data["has_auth"] = has_auth
	data["safety"] = safety
	data["anchor"] = anchored
	data["red"] = r_auth
	data["green"] = g_auth
	data["blue"] = b_auth

	var/safe_text = (safety) ? "Safe" : "Engaged"
	var/status = "Unknown"

	if(has_auth)
		if(timer_enabled)
			status = "Func/Set-[safe_text]"
		else
			status = "Functional-[safe_text]"
	else
		if(timer_enabled)
			status = "Set-[safe_text]"
		else
			status = "Auth. S1-[safe_text]"

	if(timer && timeleft(timer) <= 5 SECONDS)
		status = "Initializing nuclear explosion. Have a nice day :)"

	data["status"] = status

	return data

/obj/machinery/nuclearbomb/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("toggle_timer")
			if(!has_auth)
				return
			toggle_timer(user)
		if("change_time")
			if(!has_auth)
				return
			if(!isnum(params["seconds"]))
				CRASH("non-number passed")
			change_time(params["seconds"] SECONDS)
		if("toggle_safety")
			if(!has_auth)
				return
			toggle_safety(user)
		if("toggle_anchor")
			if(!has_auth)
				return
			toggle_anchor(user)
		if("toggle_disk")
			toggle_disk(user, params["disktype"])

///Toggles the timer on or off
/obj/machinery/nuclearbomb/proc/toggle_timer(mob/user)
	if(exploded)
		return
	if(safety)
		balloon_alert(user, "safety is still on")
		return
	if(!anchored)
		balloon_alert(user, "anchors not set")
		return

	if(!timer_enabled)
		enable()
		balloon_alert(user, "timer started")
	else
		disable()
		balloon_alert(user, "timer stopped")

	if(!lighthack)
		icon_state = (timer_enabled) ? "nuclearbomb2" : "nuclearbomb1"

///Modifies the nuke timer
/obj/machinery/nuclearbomb/proc/change_time(change)
	if(!timer_enabled)
		time = clamp(time + change, timemin, timemax)

///Toggles the safety on or off
/obj/machinery/nuclearbomb/proc/toggle_safety(mob/user)
	safety = !safety
	if(safety)
		balloon_alert(user, "safety enabled")
		disable()
	else
		balloon_alert(user, "safety disabled")

///Toggles the anchor bolts on or off
/obj/machinery/nuclearbomb/proc/toggle_anchor(mob/user)
	if(removal_stage == NUKE_STAGE_BOLTS_REMOVED)
		anchored = FALSE
		visible_message(span_warning("\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut."))
		return
	if(istype(get_area(loc), /area/shuttle))
		balloon_alert(user, "unsuitable location")
		return

	anchored = !anchored
	if(anchored)
		balloon_alert(user, "anchored")
		visible_message(span_warning("With a steely snap, bolts slide out of [src] and anchor it to the flooring."))
	else
		balloon_alert(user, "unanchored")
		visible_message(span_warning("The anchoring bolts slide back into the depths of [src]."))
		disable()

///Handles disk insertion and removal
/obj/machinery/nuclearbomb/proc/toggle_disk(mob/user, disk_colour)
	var/disk_type
	var/obj/item/disk/nuclear/disk_slot
	switch(disk_colour)
		if("red")
			disk_slot = r_auth
			disk_type = /obj/item/disk/nuclear/red
		if("green")
			disk_slot = g_auth
			disk_type = /obj/item/disk/nuclear/green
		if("blue")
			disk_slot = b_auth
			disk_type = /obj/item/disk/nuclear/blue

	if(disk_slot)
		has_auth = FALSE
		switch(disk_colour)
			if("red")
				user.put_in_hands(r_auth)
				r_auth = null
			if("green")
				user.put_in_hands(g_auth)
				g_auth = null
			if("blue")
				user.put_in_hands(b_auth)
				b_auth = null
	else
		var/obj/item/I = user.get_active_held_item()
		if(!istype(I, disk_type))
			return
		if(!user.drop_held_item())
			return
		I.forceMove(user)
		switch(disk_colour)
			if("red")
				r_auth = I
			if("green")
				g_auth = I
			if("blue")
				b_auth = I
		if(r_auth && g_auth && b_auth)
			has_auth = TRUE

///Returns time left on the nuke in seconds
/obj/machinery/nuclearbomb/proc/get_time_left()
	return timer ? round(timeleft(timer) MILLISECONDS) : round(time MILLISECONDS)

///Change minimap icon if its on or off
/obj/machinery/nuclearbomb/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "nuke[timer_enabled ? "_on" : "_off"]"))

#undef NUKE_STAGE_NONE
#undef NUKE_STAGE_COVER_REMOVED
#undef NUKE_STAGE_COVER_OPENED
#undef NUKE_STAGE_SEALANT_OPEN
#undef NUKE_STAGE_UNWRENCHED
#undef NUKE_STAGE_BOLTS_REMOVED
