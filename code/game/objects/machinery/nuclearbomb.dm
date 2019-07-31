#define NUKE_STAGE_NONE 0
#define NUKE_STAGE_COVER_REMOVED 1
#define NUKE_STAGE_COVER_OPENED 2
#define NUKE_STAGE_SEALANT_OPEN 3
#define NUKE_STAGE_UNWRENCHED 4
#define NUKE_STAGE_BOLTS_REMOVED 5
GLOBAL_LIST_EMPTY(nukes_set_list)

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	var/deployable = TRUE
	var/extended = FALSE
	var/lighthack = FALSE
	var/timeleft = 60
	var/timer_enabled = FALSE
	var/safety = TRUE
	var/exploded = FALSE
	var/removal_stage = NUKE_STAGE_NONE // 0 is no removal, 1 is covers removed, 2 is covers open,
							// 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	use_power = 0

	var/has_auth
	var/obj/item/disk/nuclear/crash/red/r_auth
	var/obj/item/disk/nuclear/crash/green/g_auth
	var/obj/item/disk/nuclear/crash/blue/b_auth


/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	GLOB.nuke_list += src


/obj/machinery/nuclearbomb/Destroy()
	GLOB.nuke_list -= src
	return ..()


/obj/machinery/nuclearbomb/process()
	if(timer_enabled)
		GLOB.nukes_set_list |= src
		timeleft--
		if(timeleft <= 0)
			explode()
			return
		updateUsrDialog()

/obj/machinery/nuclearbomb/proc/set_victory_condition()
	if(!iscrashgamemode(SSticker.mode))
		return
	var/datum/game_mode/crash/C = SSticker.mode
	C.planet_nuked = TRUE


/obj/machinery/nuclearbomb/proc/explode()
	stop_processing()

	if(safety)
		timer_enabled = FALSE
		GLOB.nukes_set_list -= src
		return

	if(exploded)
		return
	exploded = TRUE
	safety = TRUE
	if(!lighthack)
		icon_state = "nuclearbomb3"

	play_cinematic() //The round ends as soon as this happens, or it should.
	addtimer(CALLBACK(src, .proc/set_victory_condition), 7 SECONDS)
	return TRUE


/obj/machinery/nuclearbomb/proc/play_cinematic()
	GLOB.enter_allowed = FALSE
	priority_announce("DANGER. DANGER. Planetary Nuke Activated. DANGER. DANGER. Self destruct in progress. DANGER. DANGER.", "Priority Alert")
	SEND_SOUND(world, pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg'))

	for(var/x in GLOB.player_list)
		var/mob/M = x
		if(isobserver(M))
			continue
		shake_camera(M, 110, 4)

	Cinematic(CINEMATIC_SELFDESTRUCT, world)


/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!extended)
		return
	if(!istype(I, /obj/item/disk/nuclear/crash))
		return
	if(!user.transferItemToLoc(I, src))
		return
	if(istype(I, /obj/item/disk/nuclear/crash/red))
		r_auth = I
	else if(istype(I, /obj/item/disk/nuclear/crash/green))
		g_auth = I
	else if(istype(I, /obj/item/disk/nuclear/crash/blue))
		b_auth = I
	if(r_auth && g_auth && b_auth)
		has_auth = TRUE

	updateUsrDialog()


/obj/machinery/nuclearbomb/attack_paw(mob/living/carbon/monkey/user)
	return attack_hand(user)


/obj/machinery/nuclearbomb/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(extended)
		if(!ishuman(user))
			to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return TRUE
		user.set_interaction(src)

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
		popup.open(FALSE)
		onclose(user, "nuclearbomb")
	else if(deployable)
		if(!do_after(user, 3 SECONDS, TRUE, src, BUSY_ICON_BUILD))
			return
		if(removal_stage < NUKE_STAGE_BOLTS_REMOVED)
			anchored = TRUE
			visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class='warning'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		if(!lighthack)
			flick("nuclearbombc", src)
			icon_state = "nuclearbomb1"
		extended = TRUE


/obj/machinery/nuclearbomb/Topic(href, href_list)
	. = ..()
	if(.)
		return

	usr.set_interaction(src)
	
	if(href_list["disk"])
		var/disk_colour = href_list["disk"]
		var/disk_type
		var/obj/item/disk/nuclear/crash/disk_slot
		switch(disk_colour)
			if("red")
				disk_slot = r_auth
				disk_type = /obj/item/disk/nuclear/crash/red
			if("green")
				disk_slot = g_auth
				disk_type = /obj/item/disk/nuclear/crash/green
			if("blue")
				disk_slot = b_auth
				disk_type = /obj/item/disk/nuclear/crash/blue

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

	if(has_auth)
		if(href_list["time"])
			var/time = text2num(href_list["time"])
			timeleft += time
			timeleft = CLAMP(timeleft, 60, 600)
		if(href_list["timer"])
			if(exploded)
				return
			if(safety)
				to_chat(usr, "<span class='warning'>The safety is still on.</span>")
				return
			timer_enabled = !timer_enabled
			if(timer_enabled)
				GLOB.nukes_set_list |= src
				start_processing()
			if(!lighthack)
				icon_state = (timer_enabled) ? "nuclearbomb2" : "nuclearbomb1"
		if(href_list["safety"])
			safety = !safety
			if(safety)
				timer_enabled = FALSE
				GLOB.nukes_set_list -= src
				stop_processing()
			else
				GLOB.nukes_set_list |= src
				start_processing()
		if(href_list["anchor"])
			if(removal_stage == NUKE_STAGE_BOLTS_REMOVED)
				anchored = FALSE
				visible_message("<span class='warning'>\The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
				return

			anchored = !anchored
			if(anchored)
				visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
			else
				visible_message("<span class='warning'>The anchoring bolts slide back into the depths of [src].</span>")

	updateUsrDialog()


#undef NUKE_STAGE_NONE
#undef NUKE_STAGE_COVER_REMOVED
#undef NUKE_STAGE_COVER_OPENED
#undef NUKE_STAGE_SEALANT_OPEN
#undef NUKE_STAGE_UNWRENCHED
#undef NUKE_STAGE_BOLTS_REMOVED