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
	var/deployable = TRUE
	var/extended = FALSE
	var/lighthack = FALSE
	var/timeleft = 180 /// 3 minutes
	var/timer_enabled = FALSE
	var/safety = TRUE
	var/exploded = FALSE
	var/removal_stage = NUKE_STAGE_NONE
	use_power = NO_POWER_USE
	var/obj/effect/countdown/nuclearbomb/countdown

	var/has_auth
	var/obj/item/disk/nuclear/red/r_auth
	var/obj/item/disk/nuclear/green/g_auth
	var/obj/item/disk/nuclear/blue/b_auth


/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	GLOB.nuke_list += src
	countdown = new(src)
	name = "[initial(name)] ([UNIQUEID])"
	update_minimap_icon()
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/disable_on_hijack)


/obj/machinery/nuclearbomb/Destroy()
	GLOB.nuke_list -= src
	QDEL_NULL(countdown)
	return ..()


/obj/machinery/nuclearbomb/process()
	if(!timer_enabled)
		stop_processing()
		return
	timeleft--
	if(timeleft <= 0)
		explode()
		return
	updateUsrDialog()


/obj/machinery/nuclearbomb/start_processing()
	. = ..()
	GLOB.active_nuke_list += src
	countdown.start()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_START, src)
	update_minimap_icon()
	notify_ghosts("[usr] enabled the [src], it has [timeleft] seconds on the timer.", source = src, action = NOTIFY_ORBIT, extra_large = TRUE)



/obj/machinery/nuclearbomb/stop_processing()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_STOP, src)
	countdown.stop()
	GLOB.active_nuke_list -= src
	timeleft = initial(timeleft)
	update_minimap_icon()
	return ..()


/obj/machinery/nuclearbomb/proc/explode()
	stop_processing()

	if(safety)
		timer_enabled = FALSE
		update_minimap_icon()
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
		timer_enabled = FALSE
		stop_processing()

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

	updateUsrDialog()


/obj/machinery/nuclearbomb/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(!timer_enabled)
		to_chat(X, span_warning("\The [src] is soundly asleep. We better not disturb it."))
		return

	X.visible_message("[X] begins to slash delicately at the nuke",
	"You start slashing delicately at the nuke.")
	if(!do_after(X, 5 SECONDS, TRUE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return
	X.visible_message("[X] disabled the nuke",
	"You disabled the nuke.")

	timer_enabled = FALSE
	stop_processing()
	update_icon()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DIFFUSED, src, X)


/obj/machinery/nuclearbomb/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!extended)
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

	if(!do_after(user, 3 SECONDS, TRUE, src, BUSY_ICON_BUILD))
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


/obj/machinery/nuclearbomb/interact(mob/user)
	. = ..()
	if(.)
		return

	var/safe_text = (safety) ? "Safe" : "Engaged"
	var/status
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

	var/html = {"
	<b>Nuclear Fission Explosive</b><br />
	<hr />
	<b>Status</b>: [status]<br />
	<b>Timer</b>: [timeleft]<br />
	<br />
	Timer: [timer_enabled ? "On" : "Off"] [has_auth ? "<a href='?src=[REF(src)];timer=1'>Toggle</a>" : "Toggle"] <br />
	Time: [has_auth ? "<a href='?src=[REF(src)];time=-10'>--</a> <a href='?src=[REF(src)];time=-1'>-</a> [timeleft] <a href='?src=[REF(src)];time=1'>+</a> <a href='?src=[REF(src)];time=10'>++</a>" : "- - [timeleft] + +"] <br />
	<br />
	Safety: [safety ? "On" : "Off"] [has_auth ? "<a href='?src=[REF(src)];safety=1'>Toggle</a>" : "Toggle"] <br />
	Anchor: [anchored ? "Engaged" : "Off"] [has_auth ? "<a href='?src=[REF(src)];anchor=1'>Toggle</a>" : "Toggle"] <br />
	<hr />
	Red Auth. Disk: <a href='?src=[REF(src)];disk=red'>[r_auth ? "++++++++++" : "----------"]</a><br />
	Green Auth. Disk: <a href='?src=[REF(src)];disk=green'>[g_auth ? "++++++++++" : "----------"]</a><br />
	Blue Auth. Disk: <a href='?src=[REF(src)];disk=blue'>[b_auth ? "++++++++++" : "----------"]</a><br />
	"}

	var/datum/browser/popup = new(user, "nuclearbomb", "<div align='center'>Nuclear Bomb</div>", 300, 400)
	popup.set_content(html)
	popup.open()



/obj/machinery/nuclearbomb/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["disk"])
		var/disk_colour = href_list["disk"]
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
					r_auth.forceMove(loc)
					r_auth = null
				if("green")
					g_auth.forceMove(loc)
					g_auth = null
				if("blue")
					b_auth.forceMove(loc)
					b_auth = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if(!istype(I, disk_type))
				return
			if(!usr.drop_held_item())
				return
			I.forceMove(src)
			switch(disk_colour)
				if("red")
					r_auth = I
				if("green")
					g_auth = I
				if("blue")
					b_auth = I
			if(r_auth && g_auth && b_auth)
				has_auth = TRUE

	if(has_auth)
		if(href_list["time"])
			var/time = text2num(href_list["time"])
			timeleft += time
			timeleft = clamp(timeleft, initial(timeleft), 600)
		if(href_list["timer"])
			if(exploded)
				return
			if(safety)
				to_chat(usr, span_warning("The safety is still on."))
				return
			if(!anchored)
				to_chat(usr, span_warning("The anchors are not set."))
				return
			timer_enabled = !timer_enabled
			if(timer_enabled)
				start_processing()

			if(!lighthack)
				icon_state = (timer_enabled) ? "nuclearbomb2" : "nuclearbomb1"
		if(href_list["safety"])
			safety = !safety
			if(safety)
				timer_enabled = FALSE
				stop_processing()
			else
				start_processing()
		if(href_list["anchor"])
			if(removal_stage == NUKE_STAGE_BOLTS_REMOVED)
				anchored = FALSE
				visible_message(span_warning("\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut."))
				return
			if(istype(get_area(loc), /area/shuttle))
				to_chat(usr, span_warning("This doesn't look like a good spot to anchor the nuke."))
				return

			anchored = !anchored
			if(anchored)
				visible_message(span_warning("With a steely snap, bolts slide out of [src] and anchor it to the flooring."))
			else
				visible_message(span_warning("The anchoring bolts slide back into the depths of [src]."))
				timer_enabled = FALSE
				stop_processing()

	updateUsrDialog()


/obj/machinery/nuclearbomb/proc/get_time_left()
	return timeleft

///Change minimap icon if its on or off
/obj/machinery/nuclearbomb/proc/update_minimap_icon()
	SSminimaps.add_marker(src, z, MINIMAP_FLAG_ALL, "nuke[timer_enabled ? "_on" : "_off"]", 'icons/UI_icons/map_blips_large.dmi')

#undef NUKE_STAGE_NONE
#undef NUKE_STAGE_COVER_REMOVED
#undef NUKE_STAGE_COVER_OPENED
#undef NUKE_STAGE_SEALANT_OPEN
#undef NUKE_STAGE_UNWRENCHED
#undef NUKE_STAGE_BOLTS_REMOVED
