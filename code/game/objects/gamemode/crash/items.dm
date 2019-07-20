/obj/machinery/nuclearbomb/crash
	deployable = TRUE
	var/has_auth
	var/obj/item/disk/nuclear/crash/red/r_auth
	var/obj/item/disk/nuclear/crash/green/g_auth
	var/obj/item/disk/nuclear/crash/blue/b_auth

/obj/machinery/nuclearbomb/crash/proc/set_victory_condition()
	if (iscrashgamemode(SSticker.mode))
		var/datum/game_mode/crash/C = SSticker.mode
		C.planet_nuked = TRUE

/obj/machinery/nuclearbomb/crash/explode()
	. = ..()
	addtimer(CALLBACK(src, .proc/set_victory_condition), 45 SECONDS) // TODO: Refine the time here.
	

/obj/machinery/nuclearbomb/crash/make_deployable()
	set hidden = TRUE


/obj/machinery/nuclearbomb/crash/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!extended)
		return
	if(istype(I, /obj/item/disk/nuclear/crash))
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


/obj/machinery/nuclearbomb/crash/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if (extended)
		if (!ishuman(user))
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 1

		if (!ishuman(user))
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 1
		user.set_interaction(src)


		var/safe_text = (safety) ? "Safe" : "Engaged"
		var/status
		if (auth)
			if (has_auth)
				status = "[timing ? "Func/Set" : "Functional"]-[safe_text]"
			else
				status = "Auth. S2-[safe_text]"
		else
			if (timing)
				status = "Set-[safe_text]"
			else
				status = "Auth. S1-[safe_text]"
		
		var/html = {"
		<b>Nuclear Fission Explosive</b><br />
		<hr />
		<b>Status</b>: [status]<br />
		<b>Timer</b>: [timeleft]<br />
		<br />
		Timer: [timing ? "On" : "Off"] [has_auth ? "<a href='?src=[REF(src)];timer=1'>Toggle</a>" : "Toggle"] <br />
		Time: [has_auth ? "<a href='?src=[REF(src)];time=-10'>--</a> <a href='?src=[REF(src)];time=-1'>-</a> [timeleft] <a href='?src=[REF(src)];time=1'>+</a> <a href='?src=[REF(src)];time=10'>++</a>" : "- - [timeleft] + +"] <br />
		<br />
		Safety: [safety ? "On" : "Off"] [has_auth ? "<a href='?src=[REF(src)];safety=1'>Toggle</a>" : "Toggle"] <br />
		Anchor: [anchored ? "Engaged" : "Off"] [has_auth ? "<a href='?src=[REF(src)];anchor=1'>Toggle</a>" : "Toggle"] <br />
		<hr />
		Red Auth. Disk: <a href='?src=[REF(src)];r_auth=1'>[r_auth ? "++++++++++" : "----------"]</a><br />
		Green Auth. Disk: <a href='?src=[REF(src)];g_auth=1'>[g_auth ? "++++++++++" : "----------"]</a><br />
		Blue Auth. Disk: <a href='?src=[REF(src)];b_auth=1'>[b_auth ? "++++++++++" : "----------"]</a><br />
		"}

		var/datum/browser/popup = new(user, "nuclearbomb", "<div align='center'>Nuclear Bomb</div>", 300, 400)
		popup.set_content(html)
		popup.open(FALSE)
		onclose(user, "nuclearbomb")
	else if (deployable)
		if (!do_after(user, 3 SECONDS, TRUE, src, BUSY_ICON_BUILD))
			return
		if(removal_stage < 5)
			anchored = TRUE
			visible_message("<span class='warning'> With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class='warning'> \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		if(!lighthack)
			flick("nuclearbombc", src)
			icon_state = "nuclearbomb1"
		extended = TRUE
	return



/obj/machinery/nuclearbomb/crash/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!usr.canmove || usr.stat || usr.restrained())
		return
	if (!(usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))))
		usr << browse(null, "window=nuclearbomb")
		return

	usr.set_interaction(src)
	
	if(href_list["r_auth"])
		if (r_auth)
			r_auth.loc = loc
			has_auth = FALSE
			r_auth = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if (istype(I, /obj/item/disk/nuclear/crash/red))
				if(usr.drop_held_item())
					I.forceMove(src)
					r_auth = I
	if(href_list["g_auth"])
		if (g_auth)
			g_auth.loc = loc
			has_auth = FALSE
			g_auth = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if (istype(I, /obj/item/disk/nuclear/crash/green))
				if(usr.drop_held_item())
					I.forceMove(src)
					g_auth = I
	if(href_list["b_auth"])
		if (b_auth)
			b_auth.loc = loc
			has_auth = FALSE
			b_auth = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if (istype(I, /obj/item/disk/nuclear/crash/blue))
				if(usr.drop_held_item())
					I.forceMove(src)
					b_auth = I

	if (has_auth)
		if (href_list["time"])
			var/time = text2num(href_list["time"])
			timeleft += time
			timeleft = min(max(round(timeleft), 60), 600)
		if (href_list["timer"])
			if (timing == -1.0)
				return
			if (safety)
				to_chat(usr, "<span class='warning'>The safety is still on.</span>")
				return
			timing = !timing
			if(timing)
				GLOB.nukes_set_list |= src
				start_processing()
			if(!lighthack)
				icon_state = (timing) ? "nuclearbomb2" : "nuclearbomb1"
		if (href_list["safety"])
			safety = !safety
			if(safety)
				timing = FALSE
				GLOB.nukes_set_list -= src
				stop_processing()
			else
				GLOB.nukes_set_list |= src
				start_processing()
		if (href_list["anchor"])
			if(removal_stage == 5)
				anchored = FALSE
				visible_message("<span class='warning'> \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
				return

			anchored = !anchored
			if(anchored)
				visible_message("<span class='warning'> With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
			else
				visible_message("<span class='warning'> The anchoring bolts slide back into the depths of [src].</span>")

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.interactee == src))
			attack_hand(M)


/obj/item/disk/nuclear/crash
	name = "generic crash nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "datadisk0"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = UNACIDABLE | INDESTRUCTIBLE

/obj/item/disk/nuclear/crash/Initialize()
	. = ..()
	GLOB.gamemode_key_items += src


/obj/item/disk/nuclear/crash/Destroy()
	. = ..()
	GLOB.gamemode_key_items -= src

/obj/item/disk/nuclear/crash/red
	name = "red nuclear authentication disk"
	icon_state = "datadisk0"

/obj/item/disk/nuclear/crash/green
	name = "green nuclear authentication disk"
	icon_state = "datadisk3"

/obj/item/disk/nuclear/crash/blue
	name = "blue nuclear authentication disk"
	icon_state = "datadisk1"
