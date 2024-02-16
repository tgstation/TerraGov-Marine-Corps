


/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/machines/fire_alarm.dmi'
	icon_state = "fire0"
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	var/detecting = 1
	var/working = 1
	var/time = 10
	var/timing = 0
	var/lockdownbyai = 0
	var/obj/item/circuitboard/firealarm/electronics = null
	anchored = TRUE
	use_power = IDLE_POWER_USE
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

/obj/machinery/firealarm/update_icon()
	. = ..()
	set_light(0)
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return

	var/area/A = get_area(src)
	if(A.flags_alarm_state & ALARM_WARNING_FIRE)
		set_light_color(LIGHT_COLOR_EMISSIVE_ORANGE)
	else
		switch(GLOB.marine_main_ship.get_security_level())
			if("delta")
				set_light_color(LIGHT_COLOR_PINK)
			if("red")
				set_light_color(LIGHT_COLOR_EMISSIVE_RED)
			if("blue")
				set_light_color(LIGHT_COLOR_BLUE)
			else
				set_light_color(LIGHT_COLOR_EMISSIVE_GREEN)

	set_light(initial(light_range))

/obj/machinery/firealarm/update_icon_state()
	. = ..()
	var/area/A = get_area(src)
	icon_state = "fire[!CHECK_BITFIELD(A.flags_alarm_state, ALARM_WARNING_FIRE)]"

/obj/machinery/firealarm/update_overlays()
	. = ..()
	if(wiresexposed || (machine_stat & BROKEN))
		. += image(icon, "fire_ob[buildstage]")
		return
	if(CHECK_BITFIELD(machine_stat, NOPOWER))
		return
	. += emissive_appearance(icon, "fire_o[(is_mainship_level(z)) ? GLOB.marine_main_ship.get_security_level() : "green"]")
	. += mutable_appearance(icon, "fire_o[(is_mainship_level(z)) ? GLOB.marine_main_ship.get_security_level() : "green"]")
	var/area/A = get_area(src)
	if(A.flags_alarm_state & ALARM_WARNING_FIRE)
		. += mutable_appearance(icon, "fire_o1")

/obj/machinery/firealarm/fire_act(temperature, volume)
	if(detecting && (temperature > T0C+200))
		alarm()			// added check of detector status here

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm()
	return ..()

/obj/machinery/firealarm/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(!wiresexposed)
		return

	switch(buildstage)
		if(2)
			if(ismultitool(I))
				detecting = !detecting
				if(detecting)
					user.visible_message(span_warning(" [user] has reconnected [src]'s detecting unit!"), "You have reconnected [src]'s detecting unit.")
				else
					user.visible_message(span_warning(" [user] has disconnected [src]'s detecting unit!"), "You have disconnected [src]'s detecting unit.")
			else if(iswirecutter(I))
				user.visible_message(span_warning(" [user] has cut the wires inside \the [src]!"), "You have cut the wires inside \the [src].")
				playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
				buildstage = 1
				update_icon()
		if(1)
			if(iscablecoil(I))
				var/obj/item/stack/cable_coil/C = I
				if(C.use(5))
					to_chat(user, span_notice("You wire \the [src]."))
					buildstage = 2
					return
				else
					to_chat(user, span_warning("You need 5 pieces of cable to do wire \the [src]."))
					return
			else if(iscrowbar(I))
				to_chat(user, "You pry out the circuit!")
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				spawn(20)
					new /obj/item/circuitboard/firealarm(loc)
					electronics = null
					buildstage = 0
					update_icon()
		if(0)
			if(istype(I, /obj/item/circuitboard/firealarm))
				to_chat(user, "You insert the circuit!")
				electronics = I
				qdel(I)
				buildstage = 1
				update_icon()

			else if(iswrench(I))
				to_chat(user, "You remove the fire alarm assembly from the wall!")
				var/obj/item/frame/fire_alarm/frame = new /obj/item/frame/fire_alarm
				frame.forceMove(user.loc)
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				qdel(src)


/obj/machinery/firealarm/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(buildstage != 2)
		return FALSE

	return TRUE


/obj/machinery/firealarm/interact(mob/user)
	. = ..()
	if(.)
		return

	var/area/A = get_area(src)
	var/d1
	var/d2

	if (A.flags_alarm_state & ALARM_WARNING_FIRE)
		d1 = "<A href='?src=[text_ref(src)];reset=1'>Reset - Lockdown</A>"
	else
		d1 = "<A href='?src=[text_ref(src)];alarm=1'>Alarm - Lockdown</A>"
	if(timing)
		d2 = "<A href='?src=[text_ref(src)];time=0'>Stop Time Lock</A>"
	else
		d2 = "<A href='?src=[text_ref(src)];time=1'>Initiate Time Lock</A>"
	var/second = round(time) % 60
	var/minute = (round(time) - second) / 60
	var/dat = "<B>Fire alarm</B> [d1]\n<HR>The current alert level is: [GLOB.marine_main_ship.get_security_level()]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=[text_ref(src)];tp=-30'>-</A> <A href='?src=[text_ref(src)];tp=-1'>-</A> <A href='?src=[text_ref(src)];tp=1'>+</A> <A href='?src=[text_ref(src)];tp=30'>+</A>"

	var/datum/browser/popup = new(user, "firealarm", "<div align='center'>Fire alarm</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/firealarm/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["reset"])
		reset()

	else if(href_list["alarm"])
		alarm()

	else if(href_list["time"])
		timing = text2num(href_list["time"])
		last_process = world.time

	else if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = clamp(time, 0, 120)

	updateUsrDialog()


/obj/machinery/firealarm/proc/reset()
	if (!working)
		return
	var/area/A = get_area(src)
	A?.firereset()
	update_icon()

/obj/machinery/firealarm/proc/alarm()
	if (!working)
		return
	var/area/A = get_area(src)
	A?.firealert()
	update_icon()
	//playsound(src.loc, 'sound/ambience/signal.ogg', 50, 0)

