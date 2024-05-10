
/obj/machinery/computer/station_alert
	name = "Station Alert Computer"
	desc = "Used to access the station's automated alert system."
	icon_state = "computer_small"
	screen_overlay = "atmos"
	circuit = /obj/item/circuitboard/computer/stationalert
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())


/obj/machinery/computer/station_alert/Initialize(mapload)
	. = ..()
	GLOB.alert_consoles += src


/obj/machinery/computer/station_alert/Destroy()
	GLOB.alert_consoles -= src
	return ..()



/obj/machinery/computer/station_alert/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	for (var/cat in src.alarms)
		dat += "<B>[cat]</B><BR>\n"
		var/list/L = src.alarms[cat]
		if (length(L))
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "&bull; "
				dat += "[A.name]"
				if (length(sources) > 1)
					dat += " - [length(sources)] sources"
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/popup = new(user, "alerts", "<div align='center'>Current Station Alerts</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/A, O, alarmsource)
	if(machine_stat & (BROKEN|DISABLED))
		return
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (length(CL) == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	return 1


/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A as area, obj/origin)
	if(machine_stat & (BROKEN|DISABLED))
		return
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (length(srcs) == 0)
				cleared = 1
				L -= I
	return !cleared


/obj/machinery/computer/station_alert/process()
	if (machine_stat &(NOPOWER))
		icon_state = "computer_small"
		return
	if(machine_stat & (BROKEN|DISABLED))
		icon_state = "computer_small_broken"
		return
	var/active_alarms = 0
	for (var/cat in src.alarms)
		var/list/L = src.alarms[cat]
		if(length(L)) active_alarms = 1
	if(active_alarms)
		screen_overlay = "atmos2"
	else
		screen_overlay = "atmos"
	return ..()
