GLOBAL_LIST_EMPTY(nukes_set_list)

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	resistance_flags = UNACIDABLE
	var/deployable = 0.0
	var/extended = 0.0
	var/lighthack = 0
	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/disk/nuclear/auth = null
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open,
							// 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	use_power = 0



/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.

/obj/machinery/nuclearbomb/process()
	if (src.timing)
		GLOB.nukes_set_list |= src
		src.timeleft--
		if (src.timeleft <= 0)
			explode()
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.interactee == src))
				src.attack_hand(M)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(auth)
			TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
			if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
				overlays += image(icon, "npanel_open")
				to_chat(user, "You unscrew the control panel of [src].")
			else
				overlays -= image(icon, "npanel_open")
				to_chat(user, "You screw the control panel of [src] back on.")
		else
			if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
				to_chat(user, "The [src] emits a buzzing noise, the panel staying locked in.")
			else
				DISABLE_BITFIELD(machine_stat, PANEL_OPEN)
				overlays -= image(icon, "npanel_open")
				to_chat(user, "You screw the control panel of [src] back on.")
			flick("nuclearbombc", src)

	else if(iswirecutter(I) || ismultitool(I))
		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			return

		nukehack_win(user)

	else if(extended && istype(I, /obj/item/disk/nuclear))
		if(!user.transferItemToLoc(I, src))
			return

		auth = I

	if(!anchored)
		return

	switch(removal_stage)
		if(0)
			if(!iswelder(I))
				return

			var/obj/item/tool/weldingtool/WT = I
			if(!WT.isOn()) 
				return

			if(WT.get_fuel() < 5) // uses up 5 fuel.
				to_chat(user, "<span class='warning'>You need more fuel to complete this task.</span>")
				return

			user.visible_message("<span class='notice'>[user] starts cutting loose the anchoring bolt covers on [src].</span>",
			"<span class='notice'>You start cutting loose the anchoring bolt covers with [I].</span>")
			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || !WT.remove_fuel(5, user))
				return

			user.visible_message("<span class='notice'>[user] cuts through the bolt covers on [src].</span>",
			"<span class='notice'>You cut through the bolt cover.</span>")
			removal_stage = 1

		if(1)
			if(!iscrowbar(I))
				return

			user.visible_message("<span class='notice'>[user] starts forcing open the bolt covers on [src].</span>",
			"<span class='notice'>You start forcing open the anchoring bolt covers with [I].</span>")
			
			if(!do_after(user, 15, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] forces open the bolt covers on [src].</span>",
			"<span class='notice'>You force open the bolt covers.</span>")
			removal_stage = 2

		if(2)
			if(!iswelder(I))
				return

			var/obj/item/tool/weldingtool/WT = I

			user.visible_message("<span class='notice'>[user] starts cutting apart the anchoring system sealant on [src].</span>",
			"<span class='notice'>You start cutting apart the anchoring system's sealant with [I].</span>")

			if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)) || !WT.remove_fuel(5, user))
				return

			user.visible_message("<span class='notice'>[user] cuts apart the anchoring system sealant on [src].</span>",
			"<span class='notice'>You cut apart the anchoring system's sealant.</span>")
			removal_stage = 3

		if(3)
			if(!iswrench(I))
				return
			user.visible_message("<span class='notice'>[user] begins unwrenching the anchoring bolts on [src].</span>",
			"<span class='notice'>You begin unwrenching the anchoring bolts.</span>")

			if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] unwrenches the anchoring bolts on [src].</span>",
			"<span class='notice'>You unwrench the anchoring bolts.</span>")
			removal_stage = 4

		if(4)
			if(!iscrowbar(I))
				return

			user.visible_message("<span class='notice'>[user] begins lifting [src] off of the anchors.",
			"<span class='notice'>You begin lifting the device off the anchors...")
			
			if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("<span class='notice'>[user] crowbars [src] off of the anchors. It can now be moved.",
			"<span class='notice'>You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!")
			anchored = FALSE
			removal_stage = 5


/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if (src.extended)
		if (!ishuman(user))
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 1

		if (!ishuman(user))
			to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
			return 1
		user.set_interaction(src)
		var/dat = text("<B>Nuclear Fission Explosive</B><BR>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (src.auth ? "++++++++++" : "----------"))
		if (src.auth)
			if (src.yes_code)
				dat += text("\n<B>Status</B>: []-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] <A href='?src=\ref[];timer=1'>Toggle</A><BR>\nTime: <A href='?src=\ref[];time=-10'>-</A> <A href='?src=\ref[];time=-1'>-</A> [] <A href='?src=\ref[];time=1'>+</A> <A href='?src=\ref[];time=10'>+</A><BR>\n<BR>\nSafety: [] <A href='?src=\ref[];safety=1'>Toggle</A><BR>\nAnchor: [] <A href='?src=\ref[];anchor=1'>Toggle</A><BR>\n", (src.timing ? "Func/Set" : "Functional"), (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src, src, src, src.timeleft, src, src, (src.safety ? "On" : "Off"), src, (src.anchored ? "Engaged" : "Off"), src)
			else
				dat += text("\n<B>Status</B>: Auth. S2-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\n[] Safety: Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		else
			if (src.timing)
				dat += text("\n<B>Status</B>: Set-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
			else
				dat += text("\n<B>Status</B>: Auth. S1-[]<BR>\n<B>Timer</B>: []<BR>\n<BR>\nTimer: [] Toggle<BR>\nTime: - - [] + +<BR>\n<BR>\nSafety: [] Toggle<BR>\nAnchor: [] Toggle<BR>\n", (src.safety ? "Safe" : "Engaged"), src.timeleft, (src.timing ? "On" : "Off"), src.timeleft, (src.safety ? "On" : "Off"), (src.anchored ? "Engaged" : "Off"))
		var/message = "AUTH"
		if (src.auth)
			message = text("[]", src.code)
			if (src.yes_code)
				message = "*****"
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n", message, src, src, src, src, src, src, src, src, src, src, src, src)
		var/datum/browser/popup = new(user, "nuclearbomb", "<div align='center'>Nuclear Bomb</div>", 300, 400)
		popup.set_content(dat)
		popup.open(FALSE)
		onclose(user, "nuclearbomb")
	else if (src.deployable)
		if(removal_stage < 5)
			src.anchored = TRUE
			visible_message("<span class='warning'> With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class='warning'> \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		if(!src.lighthack)
			flick("nuclearbombc", src)
			src.icon_state = "nuclearbomb1"
		src.extended = 1
	return

obj/machinery/nuclearbomb/proc/nukehack_win(mob/user as mob)
	var/dat
	dat += "<B>Nuclear Fission Explosive</B><BR>\nNuclear Device Wires:</A><HR>"
	dat += text("<HR>The device is [src.timing ? "shaking!" : "still"]<BR>")
	dat += text("The device is [src.safety ? "quiet" : "whirring"].<BR>")
	dat += text("The lights are [src.lighthack ? "static" : "functional"].<BR>")
	var/datum/browser/popup = new(user, "nukebomb_hack", "<div align='center'>Bomb Defusion</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "nukebomb_hack")


/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	if (!usr.canmove || usr.stat || usr.restrained())
		return
	if (!ishuman(usr))
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	if (src.deployable)
		to_chat(usr, "<span class='warning'>You close several panels to make [src] undeployable.</span>")
		src.deployable = 0
	else
		to_chat(usr, "<span class='warning'>You adjust some panels to make [src] deployable.</span>")
		src.deployable = 1
	return


/obj/machinery/nuclearbomb/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!usr.canmove || usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_interaction(src)
		if (href_list["auth"])
			if (src.auth)
				src.auth.loc = src.loc
				src.yes_code = 0
				src.auth = null
			else
				var/obj/item/I = usr.get_active_held_item()
				if (istype(I, /obj/item/disk/nuclear))
					if(usr.drop_held_item())
						I.forceMove(src)
						auth = I
		if (src.auth)
			if (href_list["type"])
				if (href_list["type"] == "E")
					if (src.code == src.r_code)
						src.yes_code = 1
						src.code = null
					else
						src.code = "ERROR"
				else
					if (href_list["type"] == "R")
						src.yes_code = 0
						src.code = null
					else
						src.code += text("[]", href_list["type"])
						if (length(src.code) > 5)
							src.code = "ERROR"
			if (src.yes_code)
				if (href_list["time"])
					var/time = text2num(href_list["time"])
					src.timeleft += time
					src.timeleft = min(max(round(src.timeleft), 60), 600)
				if (href_list["timer"])
					if (src.timing == -1.0)
						return
					if (src.safety)
						to_chat(usr, "<span class='warning'>The safety is still on.</span>")
						return
					src.timing = !( src.timing )
					if (src.timing)
						if(!src.lighthack)
							src.icon_state = "nuclearbomb2"
						if(!src.safety)
							GLOB.nukes_set_list |= src
						else
							GLOB.nukes_set_list -= src
					else
						GLOB.nukes_set_list -= src
						if(!src.lighthack)
							src.icon_state = "nuclearbomb1"
				if (href_list["safety"])
					src.safety = !( src.safety )
					if(safety)
						src.timing = 0
						stop_processing()
						GLOB.nukes_set_list -= src
				if (href_list["anchor"])

					if(removal_stage == 5)
						src.anchored = 0
						visible_message("<span class='warning'> \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
						return

					src.anchored = !( src.anchored )
					if(src.anchored)
						visible_message("<span class='warning'> With a steely snap, bolts slide out of [src] and anchor it to the flooring.</span>")
					else
						visible_message("<span class='warning'> The anchoring bolts slide back into the depths of [src].</span>")

		for(var/mob/M in viewers(1, src))
			if ((M.client && M.interactee == src))
				src.attack_hand(M)
	else
		usr << browse(null, "window=nuclearbomb")
		return
	return


/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = 0
		stop_processing()
		return FALSE
	timing = -1.0
	yes_code = 0
	safety = 1
	if(!lighthack) icon_state = "nuclearbomb3"

	SSevacuation.initiate_self_destruct(TRUE) //The round ends as soon as this happens, or it should.
	return TRUE