var/bomb_set

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1
	unacidable = 1
	var/deployable = 0.0
	var/extended = 0.0
	var/lighthack = 0
	var/opened = 0.0
	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/disk/nuclear/auth = null
	var/list/wires = list()
	var/light_wire
	var/safety_wire
	var/timing_wire
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open,
	                      // 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	use_power = 0
	flags_atom = FPRINT



/obj/machinery/nuclearbomb/New()
	..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.

	src.wires["Red"] = 0
	src.wires["Blue"] = 0
	src.wires["Green"] = 0
	src.wires["Marigold"] = 0
	src.wires["Fuschia"] = 0
	src.wires["Black"] = 0
	src.wires["Pearl"] = 0
	var/list/w = list("Red","Blue","Green","Marigold","Black","Fuschia","Pearl")
	src.light_wire = pick(w)
	w -= src.light_wire
	src.timing_wire = pick(w)
	w -= src.timing_wire
	src.safety_wire = pick(w)
	w -= src.safety_wire

/obj/machinery/nuclearbomb/process()
	if (src.timing)
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		src.timeleft--
		if (src.timeleft <= 0)
			explode()
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.interactee == src))
				src.attack_hand(M)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/O as obj, mob/user as mob)

	if (istype(O, /obj/item/tool/screwdriver))
		src.add_fingerprint(user)
		if (src.auth)
			if (src.opened == 0)
				src.opened = 1
				overlays += image(icon, "npanel_open")
				user << "You unscrew the control panel of [src]."

			else
				src.opened = 0
				overlays -= image(icon, "npanel_open")
				user << "You screw the control panel of [src] back on."
		else
			if (src.opened == 0)
				user << "The [src] emits a buzzing noise, the panel staying locked in."
			if (src.opened == 1)
				src.opened = 0
				overlays -= image(icon, "npanel_open")
				user << "You screw the control panel of [src] back on."
			flick("nuclearbombc", src)

		return
	if (istype(O, /obj/item/tool/wirecutters) || istype(O, /obj/item/device/multitool))
		if (src.opened == 1)
			nukehack_win(user)
		return

	if (extended)
		if (istype(O, /obj/item/disk/nuclear))
			if(user.drop_inv_item_to_loc(O, src))
				auth = O
				add_fingerprint(user)
			return

	if(anchored)
		switch(removal_stage)
			if(0)
				if(iswelder(O))
					var/obj/item/tool/weldingtool/WT = O
					if(!WT.isOn()) return
					if(WT.get_fuel() < 5) // uses up 5 fuel.
						user << "<span class='warning'>You need more fuel to complete this task.</span>"
						return
					user.visible_message("<span class='notice'>[user] starts cutting loose the anchoring bolt covers on [src].</span>",
					"<span class='notice'>You start cutting loose the anchoring bolt covers with [O].</span>")
					if(do_after(user,40, TRUE, 5, BUSY_ICON_GENERIC))
						if(!src || !user || !WT.remove_fuel(5, user)) return
						user.visible_message("<span class='notice'>[user] cuts through the bolt covers on [src].</span>",
						"<span class='notice'>You cut through the bolt cover.</span>")
						removal_stage = 1
				return

			if(1)
				if(iscrowbar(O))
					user.visible_message("<span class='notice'>[user] starts forcing open the bolt covers on [src].</span>",
					"<span class='notice'>You start forcing open the anchoring bolt covers with [O].</span>")
					if(do_after(user, 15, TRUE, 5, BUSY_ICON_GENERIC))
						if(!src || !user) return
						user.visible_message("<span class='notice'>[user] forces open the bolt covers on [src].</span>",
						"<span class='notice'>You force open the bolt covers.</span>")
						removal_stage = 2
				return

			if(2)
				if(iswelder(O))
					var/obj/item/tool/weldingtool/WT = O
					if(!WT.isOn()) return
					if(WT.get_fuel() < 5) //Uses up 5 fuel.
						user << "<span class='warning'>You need more fuel to complete this task.</span>"
						return
					user.visible_message("<span class='notice'>[user] starts cutting apart the anchoring system sealant on [src].</span>",
					"<span class='notice'>You start cutting apart the anchoring system's sealant with [O].</span>")
					if(do_after(user, 40, TRUE, 5, BUSY_ICON_GENERIC))
						if(!src || !user || !WT.remove_fuel(5, user)) return
						user.visible_message("<span class='notice'>[user] cuts apart the anchoring system sealant on [src].</span>",
						"<span class='notice'>You cut apart the anchoring system's sealant.</span>")
						removal_stage = 3
				return

			if(3)
				if(iswrench(O))
					user.visible_message("<span class='notice'>[user] begins unwrenching the anchoring bolts on [src].</span>",
					"<span class='notice'>You begin unwrenching the anchoring bolts.</span>")
					if(do_after(user, 50, TRUE, 5, BUSY_ICON_GENERIC))
						if(!src || !user) return
						user.visible_message("<span class='notice'>[user] unwrenches the anchoring bolts on [src].</span>",
						"<span class='notice'>You unwrench the anchoring bolts.</span>")
						removal_stage = 4
				return

			if(4)
				if(iscrowbar(O))
					user.visible_message("<span class='notice'>[user] begins lifting [src] off of the anchors.",
					"<span class='notice'>You begin lifting the device off the anchors...")
					if(do_after(user, 80, TRUE, 5, BUSY_ICON_GENERIC))
						if(!src || !user) return
						user.visible_message("<span class='notice'>[user] crowbars [src] off of the anchors. It can now be moved.",
						"<span class='notice'>You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!")
						anchored = 0
						removal_stage = 5
				return
	..()

/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if (src.extended)
		if (!ishuman(user))
			usr << "\red You don't have the dexterity to do this!"
			return 1

		if (!ishuman(user))
			usr << "\red You don't have the dexterity to do this!"
			return 1
		user.set_interaction(src)
		var/dat = text("<TT><B>Nuclear Fission Explosive</B><BR>\nAuth. Disk: <A href='?src=\ref[];auth=1'>[]</A><HR>", src, (src.auth ? "++++++++++" : "----------"))
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
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
		user << browse(dat, "window=nuclearbomb;size=300x400")
		onclose(user, "nuclearbomb")
	else if (src.deployable)
		if(removal_stage < 5)
			src.anchored = 1
			visible_message("\red With a steely snap, bolts slide out of [src] and anchor it to the flooring!")
		else
			visible_message("\red \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.")
		if(!src.lighthack)
			flick("nuclearbombc", src)
			src.icon_state = "nuclearbomb1"
		src.extended = 1
	return

obj/machinery/nuclearbomb/proc/nukehack_win(mob/user as mob)
	var/dat as text
	dat += "<TT><B>Nuclear Fission Explosive</B><BR>\nNuclear Device Wires:</A><HR>"
	for(var/wire in src.wires)
		dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")
	dat += text("<HR>The device is [src.timing ? "shaking!" : "still"]<BR>")
	dat += text("The device is [src.safety ? "quiet" : "whirring"].<BR>")
	dat += text("The lights are [src.lighthack ? "static" : "functional"].<BR>")
	user << browse("<HTML><HEAD><TITLE>Bomb Defusion</TITLE></HEAD><BODY>[dat]</BODY></HTML>","window=nukebomb_hack")
	onclose(user, "nukebomb_hack")

/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	if (!usr.canmove || usr.stat || usr.is_mob_restrained())
		return
	if (!ishuman(usr))
		usr << "\red You don't have the dexterity to do this!"
		return 1

	if (src.deployable)
		usr << "\red You close several panels to make [src] undeployable."
		src.deployable = 0
	else
		usr << "\red You adjust some panels to make [src] deployable."
		src.deployable = 1
	return


/obj/machinery/nuclearbomb/Topic(href, href_list)
	..()
	if (!usr.canmove || usr.stat || usr.is_mob_restrained())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_interaction(src)
		if(href_list["act"])
			var/temp_wire = href_list["wire"]
			if(href_list["act"] == "pulse")
				if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
					usr << "You need a multitool!"
				else
					if(src.wires[temp_wire])
						usr << "You can't pulse a cut wire."
					else
						if(src.light_wire == temp_wire)
							src.lighthack = !src.lighthack
							spawn(100) src.lighthack = !src.lighthack
						if(src.timing_wire == temp_wire)
							if(src.timing)
								explode()
						if(src.safety_wire == temp_wire)
							src.safety = !src.safety
							spawn(100) src.safety = !src.safety
							if(src.safety == 1)
								visible_message("\blue The [src] quiets down.")
								if(!src.lighthack)
									if (src.icon_state == "nuclearbomb2")
										src.icon_state = "nuclearbomb1"
							else
								visible_message("\blue The [src] emits a quiet whirling noise!")
			if(href_list["act"] == "wire")
				if (!istype(usr.get_active_hand(), /obj/item/tool/wirecutters))
					usr << "You need wirecutters!"
				else
					wires[temp_wire] = !wires[temp_wire]
					if(src.safety_wire == temp_wire)
						if(src.timing)
							explode()
					if(src.timing_wire == temp_wire)
						if(!src.lighthack)
							if (src.icon_state == "nuclearbomb2")
								src.icon_state = "nuclearbomb1"
						src.timing = 0
						stop_processing()
						bomb_set = 0
					if(src.light_wire == temp_wire)
						src.lighthack = !src.lighthack

		if (href_list["auth"])
			if (src.auth)
				src.auth.loc = src.loc
				src.yes_code = 0
				src.auth = null
			else
				var/obj/item/I = usr.get_active_hand()
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
						usr << "\red The safety is still on."
						return
					src.timing = !( src.timing )
					if (src.timing)
						if(!src.lighthack)
							src.icon_state = "nuclearbomb2"
						if(!src.safety)
							bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
						else
							bomb_set = 0
					else
						bomb_set = 0
						if(!src.lighthack)
							src.icon_state = "nuclearbomb1"
				if (href_list["safety"])
					src.safety = !( src.safety )
					if(safety)
						src.timing = 0
						stop_processing()
						bomb_set = 0
				if (href_list["anchor"])

					if(removal_stage == 5)
						src.anchored = 0
						visible_message("\red \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.")
						return

					src.anchored = !( src.anchored )
					if(src.anchored)
						visible_message("\red With a steely snap, bolts slide out of [src] and anchor it to the flooring.")
					else
						visible_message("\red The anchoring bolts slide back into the depths of [src].")

		src.add_fingerprint(usr)
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
		r_FAL
	timing = -1.0
	yes_code = 0
	safety = 1
	if(!lighthack) icon_state = "nuclearbomb3"

	EvacuationAuthority.trigger_self_destruct(list(z), src) //The round ends as soon as this happens, or it should.
	r_TRU

/obj/item/disk/nuclear/Dispose()
	if(blobstart.len > 0)
		var/obj/D = new /obj/item/disk/nuclear(pick(blobstart))
		message_admins("[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).")
		log_game("[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).")
	. = ..()
