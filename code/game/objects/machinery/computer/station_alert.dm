
/obj/machinery/computer/station_alert
	name = "Station Alert Computer"
	desc = "Used to access the station's automated alert system."
	icon_state = "atmos"
	circuit = /obj/item/circuitboard/computer/stationalert
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())


/obj/machinery/computer/station_alert/Initialize()
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
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "&bull; "
				dat += "[A.name]"
				if (sources.len > 1)
					dat += text(" - [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/popup = new(user, "alerts", "<div align='center'>Current Station Alerts</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/A, O, alarmsource)
	if(machine_stat & (BROKEN))
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
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	return 1


/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A as area, obj/origin)
	if(machine_stat & (BROKEN))
		return
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	return !cleared


/obj/machinery/computer/station_alert/process()
	if (machine_stat &(NOPOWER))
		icon_state = "atmos0"
		return
	if(machine_stat & (BROKEN))
		icon_state = "atmosb"
		return
	var/active_alarms = 0
	for (var/cat in src.alarms)
		var/list/L = src.alarms[cat]
		if(L.len) active_alarms = 1
	if(active_alarms)
		icon_state = "atmos2"
	else
		icon_state = "atmos"
	..()
	return
