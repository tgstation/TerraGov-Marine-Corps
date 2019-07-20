GLOBAL_LIST_EMPTY(nukes_set_list)

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	resistance_flags = UNACIDABLE
	var/deployable = FALSE
	var/extended = FALSE
	var/lighthack = FALSE
	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = FALSE
	var/safety = TRUE
	var/obj/item/disk/nuclear/auth = null
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open,
							// 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	use_power = 0



/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.

/obj/machinery/nuclearbomb/process()
	if (timing)
		GLOB.nukes_set_list |= src
		timeleft--
		if (timeleft <= 0)
			explode()
			return
		updateUsrDialog()
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

/obj/machinery/nuclearbomb/attack_hand(mob/living/user)
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
			if (yes_code)
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
		Auth. Disk: <a href='?src=[REF(src)];auth=1'>[auth ? "++++++++++" : "----------"]</a>
		<hr />
		<b>Status</b>: [status]<br />
		<b>Timer</b>: [timeleft]<br />
		<br />
		Timer: [timing ? "On" : "Off"] [yes_code ? "<a href='?src=[REF(src)];timer=1'>Toggle</a>" : "Toggle"] <br />
		Time: [yes_code ? "<a href='?src=[REF(src)];time=-10'>--</a> <a href='?src=[REF(src)];time=-1'>-</a> [timeleft] <a href='?src=[REF(src)];time=1'>+</a> <a href='?src=[REF(src)];time=10'>++</a>" : "- - [timeleft] + +"] <br />
		<br />
		Safety: [safety ? "On" : "Off"] [yes_code ? "<a href='?src=[REF(src)];safety=1'>Toggle</a>" : "Toggle"] <br />
		Anchor: [anchored ? "Engaged" : "Off"] [yes_code ? "<a href='?src=[REF(src)];anchor=1'>Toggle</a>" : "Toggle"] <br />
		<hr />
		> [yes_code ? "*****" : code]<br />
		<a href='?src=[REF(src)];type=1'>1</a> - <a href='?src=[REF(src)];type=2'>2</a> - <a href='?src=[REF(src)];type=3'>3</a> <br />
		<a href='?src=[REF(src)];type=4'>4</a> - <a href='?src=[REF(src)];type=5'>5</a> - <a href='?src=[REF(src)];type=6'>6</a> <br />
		<a href='?src=[REF(src)];type=7'>7</a> - <a href='?src=[REF(src)];type=8'>8</a> - <a href='?src=[REF(src)];type=9'>9</a> <br />
		<a href='?src=[REF(src)];type=R'>R</a> - <a href='?src=[REF(src)];type=0'>0</a> - <a href='?src=[REF(src)];type=E'>E</a> <br />
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
			visible_message("<span class='warning'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		else
			visible_message("<span class='warning'> \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.</span>")
		if(!lighthack)
			flick("nuclearbombc", src)
			icon_state = "nuclearbomb1"
		extended = TRUE
	return

obj/machinery/nuclearbomb/proc/nukehack_win(mob/user as mob)
	var/dat = {"
	<b>Nuclear Fission Explosive</b><br>
	Nuclear Device Wires:<hr>
	<hr>The device is [timing ? "shaking!" : "still"]<br>
	The device is [safety ? "quiet" : "whirring"].<br>
	The lights are [lighthack ? "static" : "functional"].<br>
	"}
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
		return

	if (deployable)
		to_chat(usr, "<span class='warning'>You close several panels to make [src] undeployable.</span>")
		deployable = FALSE
	else
		to_chat(usr, "<span class='warning'>You adjust some panels to make [src] deployable.</span>")
		deployable = TRUE
	return


/obj/machinery/nuclearbomb/Topic(href, href_list)
	. = ..()
	if(.)
		return

	usr.set_interaction(src)

	if (href_list["auth"])
		if (auth)
			auth.loc = loc
			yes_code = FALSE
			auth = null
		else
			var/obj/item/I = usr.get_active_held_item()
			if (istype(I, /obj/item/disk/nuclear))
				if(usr.drop_held_item())
					I.forceMove(src)
					auth = I
	if (auth)
		if (href_list["type"])
			if (href_list["type"] == "E")
				if (code == r_code)
					yes_code = TRUE
					code = null
				else
					code = "ERROR"
			else
				if (href_list["type"] == "R")
					yes_code = FALSE
					code = null
				else
					code += "[href_list["type"]]"
					if (length(code) > 5)
						code = "ERROR"
		if (yes_code)
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

	updateUsrDialog()
		

/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = 0
		GLOB.nukes_set_list -= src
		stop_processing()
		return
	timing = -1.0
	yes_code = FALSE
	safety = TRUE
	if(!lighthack) 
		icon_state = "nuclearbomb3"

	SSevacuation.initiate_self_destruct(TRUE) //The round ends as soon as this happens, or it should.
