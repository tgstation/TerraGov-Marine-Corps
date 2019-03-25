


/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	var/obj/item/circuitboard/firealarm/electronics = null
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/Initialize(mapload, direction, building)
	. = ..()

	if(direction)
		setDir(direction)

	if(building)
		buildstage = 0
		wiresexposed = TRUE

	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

	update_icon()
	start_processing()

/obj/machinery/firealarm/update_icon()
	overlays.Cut()
	icon_state = "fire1"

	if(wiresexposed || (machine_stat & BROKEN))
		overlays += image(icon, "fire_ob[buildstage]")
		return

	if(!(machine_stat & NOPOWER))
		var/alert = (is_mainship_level(z)) ? get_security_level() : "green"
		overlays += image(icon, "fire_o[alert]")
		var/area/A = get_area(src)
		if(A?.flags_alarm_state & ALARM_WARNING_FIRE)
			icon_state = "fire0"
			overlays += image(icon, "fire_o1")

/obj/machinery/firealarm/fire_act(temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity)) alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob)
	src.add_fingerprint(user)

	if (isscrewdriver(W) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if (ismultitool(W))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("<span class='warning'> [user] has reconnected [src]'s detecting unit!</span>", "You have reconnected [src]'s detecting unit.")
					else
						user.visible_message("<span class='warning'> [user] has disconnected [src]'s detecting unit!</span>", "You have disconnected [src]'s detecting unit.")
				else if (iswirecutter(W))
					user.visible_message("<span class='warning'> [user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
					buildstage = 1
					update_icon()
			if(1)
				if(iscablecoil(W))
					var/obj/item/stack/cable_coil/C = W
					if (C.use(5))
						to_chat(user, "<span class='notice'>You wire \the [src].</span>")
						buildstage = 2
						return
					else
						to_chat(user, "<span class='warning'>You need 5 pieces of cable to do wire \the [src].</span>")
						return
				else if(iscrowbar(W))
					to_chat(user, "You pry out the circuit!")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					spawn(20)
						var/obj/item/circuitboard/firealarm/circuit
						if(!electronics)
							circuit = new/obj/item/circuitboard/firealarm( src.loc )
						else
							circuit = new electronics( src.loc )
							if(electronics.is_general_board)
								circuit.set_general()
						electronics = null
						buildstage = 0
						update_icon()
			if(0)
				if(istype(W, /obj/item/circuitboard/firealarm))
					to_chat(user, "You insert the circuit!")
					electronics = W
					qdel(W)
					buildstage = 1
					update_icon()

				else if(iswrench(W))
					to_chat(user, "You remove the fire alarm assembly from the wall!")
					var/obj/item/frame/fire_alarm/frame = new /obj/item/frame/fire_alarm()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					qdel(src)
		return

	//src.alarm() // why was this even a thing?
	..()
	return

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(src.timing)
		if(src.time > 0)
			src.time = src.time - ((world.timeofday - last_process)/10)
		else
			src.alarm()
			src.time = 0
			src.timing = 0
			//STOP_PROCESSING(SSobj, src) // uh what
		src.updateDialog()
	last_process = world.timeofday
/*
	if(locate(/obj/fire) in loc)
		alarm()
*/
	return

/obj/machinery/firealarm/power_change()
	..()
	spawn(rand(0,15))
		update_icon()

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if(user.stat || machine_stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_interaction(src)
	var/area/A = src.loc
	var/d1
	var/d2
	if (ishuman(user) || issilicon(user))
		A = A.loc

		if (A.flags_alarm_state & ALARM_WARNING_FIRE)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		var/dat = "<B>Fire alarm</B> [d1]\n<HR>The current alert level is: [get_security_level()]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"

		var/datum/browser/popup = new(user, "firealarm", "<div align='center'>Fire alarm</div>")
		popup.set_content(dat)
		popup.open(FALSE)
		onclose(user, "firealarm")
	else
		A = A.loc
		if (A.flags_alarm_state & ALARM_WARNING_FIRE)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		var/dat = "[d1]\n<HR><b>The current alert level is: [stars(get_security_level())]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"

		var/datum/browser/popup = new(user, "firealarm", "<div align='center'>Fire alarm</div>")
		popup.set_content(dat)
		popup.open(FALSE)
		onclose(user, "firealarm")


/obj/machinery/firealarm/Topic(href, href_list)
	..()
	if (usr.stat || machine_stat & (BROKEN|NOPOWER))
		return

	if (buildstage != 2)
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || issilicon(usr))
		usr.set_interaction(src)
		if (href_list["reset"])
			src.reset()
		else if (href_list["alarm"])
			src.alarm()
		else if (href_list["time"])
			src.timing = text2num(href_list["time"])
			last_process = world.timeofday
			//START_PROCESSING(SSobj, src)
		else if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 0), 120)

		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
	return

/obj/machinery/firealarm/proc/reset()
	if (!working)
		return
	var/area/A = get_area(src)
	A?.firereset()
	update_icon()
	return

/obj/machinery/firealarm/proc/alarm()
	if (!working)
		return
	var/area/A = get_area(src)
	A?.firealert()
	update_icon()
	//playsound(src.loc, 'sound/ambience/signal.ogg', 50, 0)
	return
