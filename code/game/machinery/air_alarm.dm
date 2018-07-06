////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

/proc/RandomAAlarmWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/AAlarmwires = list(0, 0, 0, 0, 0)
	AAlarmIndexToFlag = list(0, 0, 0, 0, 0)
	AAlarmIndexToWireColor = list(0, 0, 0, 0, 0)
	AAlarmWireColorToIndex = list(0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<32, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 5)
			if (AAlarmwires[colorIndex]==0)
				valid = 1
				AAlarmwires[colorIndex] = flag
				AAlarmIndexToFlag[flagIndex] = flag
				AAlarmIndexToWireColor[flagIndex] = colorIndex
				AAlarmWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return AAlarmwires

#define AALARM_WIRE_IDSCAN		1	//Added wires
#define AALARM_WIRE_POWER		2
#define AALARM_WIRE_SYPHON		3
#define AALARM_WIRE_AI_CONTROL	4
#define AALARM_WIRE_AALARM		5

#define AALARM_MODE_SCRUBBING	1
#define AALARM_MODE_REPLACEMENT	2 //like scrubbing, but faster.
#define AALARM_MODE_PANIC		3 //constantly sucks all air
#define AALARM_MODE_CYCLE		4 //sucks off all air, then refill and switches to scrubbing
#define AALARM_MODE_FILL		5 //emergency fill
#define AALARM_MODE_OFF			6 //Shuts it all down.

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

#define MAX_TEMPERATURE 90
#define MIN_TEMPERATURE -40

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm
	name = "alarm"
	icon = 'icons/obj/machines/monitors.dmi' // I made these really quickly because idk where they have their new air alarm ~Art
	icon_state = "alarm0"
	anchored = 1
	use_power = 1
	idle_power_usage = 80
	active_power_usage = 1000 //For heating/cooling rooms. 1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
	power_channel = ENVIRON
	req_one_access = list(ACCESS_CIVILIAN_ENGINEERING)
	var/alarm_id = null
	var/breach_detection = 1 // Whether to use automatic breach detection or not
	var/frequency = 1439
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = 0
	var/rcon_setting = 2
	var/rcon_time = 0
	var/locked = 1
	var/wiresexposed = 0 // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	var/mode = AALARM_MODE_SCRUBBING
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.

	var/target_temperature = T0C+20
	var/regulating_temperature = 0

	var/datum/radio_frequency/radio_connection

	var/list/TLV = list()

	var/danger_level = 0
	var/pressure_dangerlevel = 0
	var/oxygen_dangerlevel = 0
	var/co2_dangerlevel = 0
	var/phoron_dangerlevel = 0
	var/temperature_dangerlevel = 0
	var/other_dangerlevel = 0

	var/apply_danger_level = 1
	var/post_alert = 1



/obj/machinery/alarm/New(var/loc, var/direction, var/building = 0)
	..()

	if(building)
		if(loc)
			src.loc = loc

		if(direction)
			src.dir = direction

		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		update_icon()
		if(ticker && ticker.current_state == 3)//if the game is running
			src.initialize()
		return

	switch(dir)
		if(NORTH) pixel_y = 25
		if(SOUTH) pixel_y = -25
		if(EAST) pixel_x = 25
		if(WEST) pixel_x = -25

	first_run()
	start_processing()


/obj/machinery/alarm/proc/first_run()
	alarm_area = get_area(src)
	if (alarm_area.master)
		alarm_area = alarm_area.master
	area_uid = alarm_area.uid
	if (name == "alarm")
		name = "[alarm_area.name] Air Alarm"

	// breathable air according to human/Life()
	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["carbon dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["phoron"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(T0C-26, T0C, T0C+40, T0C+66) // K


/obj/machinery/alarm/initialize()
	set_frequency(frequency)
	if (!master_is_operating())
		elect_master()

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != 2)
		return

	var/turf/location = loc
	if(!istype(location))	return//returns if loc is not simulated

	var/old_level = danger_level
	var/old_pressurelevel = pressure_dangerlevel
	danger_level = overall_danger_level(location)

	if (old_level != danger_level)
		apply_danger_level(danger_level)

	if (old_pressurelevel != pressure_dangerlevel)
		if (breach_detected())
		//	mode = AALARM_MODE_OFF
			apply_mode()

	if (mode==AALARM_MODE_CYCLE && location.return_pressure()<ONE_ATMOSPHERE*0.05)
		mode=AALARM_MODE_FILL
		apply_mode()

	//atmos computer remote controll stuff
	switch(rcon_setting)
		if(RCON_NO)
			remote_control = 0
		if(RCON_AUTO)
			if(danger_level == 2)
				remote_control = 1
			else
				remote_control = 0
		if(RCON_YES)
			remote_control = 1

	updateDialog()
	return

/obj/machinery/alarm/proc/handle_heating_cooling()
	return

/obj/machinery/alarm/proc/overall_danger_level(turf/T)
	pressure_dangerlevel = get_danger_level(T.return_pressure(), TLV["pressure"])
	temperature_dangerlevel = get_danger_level(T.return_temperature(), TLV["temperature"])

	return max(
		pressure_dangerlevel,
		temperature_dangerlevel
		)

// Returns whether this air alarm thinks there is a breach, given the sensors that are available to it.
/obj/machinery/alarm/proc/breach_detected()
	var/turf/location = loc

	if(!istype(location))
		return 0

	if(breach_detection	== 0)
		return 0

	var/pressure_levels = TLV["pressure"]

	if (location.return_pressure() <= pressure_levels[1])		//low pressures
		if (!(mode == AALARM_MODE_PANIC || mode == AALARM_MODE_CYCLE))
			return 1

	return 0


/obj/machinery/alarm/proc/master_is_operating()
	return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))


/obj/machinery/alarm/proc/elect_master()
	for (var/area/A in alarm_area.related)
		for (var/obj/machinery/alarm/AA in A)
			if (!(AA.stat & (NOPOWER|BROKEN)))
				alarm_area.master_air_alarm = AA
				return 1
	return 0

/obj/machinery/alarm/proc/get_danger_level(var/current_value, var/list/danger_levels)
	if((current_value >= danger_levels[4] && danger_levels[4] > 0) || current_value <= danger_levels[1])
		return 2
	if((current_value >= danger_levels[3] && danger_levels[3] > 0) || current_value <= danger_levels[2])
		return 1
	return 0

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state = "alarmx"
		return
	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	var/icon_level = danger_level
	if (alarm_area.atmosalm)
		icon_level = max(icon_level, 1)	//if there's an atmos alarm but everything is okay locally, no need to go past yellow

	switch(icon_level)
		if (0)
			icon_state = "alarm0"
		if (1)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if (2)
			icon_state = "alarm1"

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if (alarm_area.master_air_alarm != src)
		if (master_is_operating())
			return
		elect_master()
		if (alarm_area.master_air_alarm != src)
			return
	if(!signal || signal.encryption)
		return
	var/id_tag = signal.data["tag"]
	if (!id_tag)
		return
	if (signal.data["area"] != area_uid)
		return
	if (signal.data["sigtype"] != "status")
		return

	var/dev_type = signal.data["device"]
	if(!(id_tag in alarm_area.air_scrub_names) && !(id_tag in alarm_area.air_vent_names))
		register_env_machine(id_tag, dev_type)
	if(dev_type == "AScr")
		alarm_area.air_scrub_info[id_tag] = signal.data
	else if(dev_type == "AVP")
		alarm_area.air_vent_info[id_tag] = signal.data

/obj/machinery/alarm/proc/register_env_machine(var/m_id, var/device_type)
	var/new_name
	if (device_type=="AVP")
		new_name = "[alarm_area.name] Vent Pump #[alarm_area.air_vent_names.len+1]"
		alarm_area.air_vent_names[m_id] = new_name
	else if (device_type=="AScr")
		new_name = "[alarm_area.name] Air Scrubber #[alarm_area.air_scrub_names.len+1]"
		alarm_area.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in alarm_area.air_vent_names)
		var/list/I = alarm_area.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in alarm_area.air_scrub_names)
		var/list/I = alarm_area.air_scrub_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(var/target, var/list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			world << text("Signal [] Broadcasted to []", command, target)

	return 1

/obj/machinery/alarm/proc/apply_mode()
	//propagate mode to other air alarms in the area
	//TODO: make it so that players can choose between applying the new mode to the room they are in (related area) vs the entire alarm area
	for (var/area/RA in alarm_area.related)
		for (var/obj/machinery/alarm/AA in RA)
			AA.mode = mode

	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "co2_scrub"= 1, "scrubbing"= 1, "panic_siphon"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

		if(AALARM_MODE_REPLACEMENT)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_FILL)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_OFF)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

/obj/machinery/alarm/proc/apply_danger_level(var/new_danger_level)
	if (apply_danger_level && alarm_area.atmosalert(new_danger_level))
		post_alert(new_danger_level)

	update_icon()

/obj/machinery/alarm/proc/post_alert(alert_level)
	if(!post_alert)
		return

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)
	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)


///////////
//HACKING//
///////////
/obj/machinery/alarm/proc/isWireColorCut(var/wireColor)
	var/wireFlag = AAlarmWireColorToFlag[wireColor]
	return ((AAlarmwires & wireFlag) == 0)

/obj/machinery/alarm/proc/isWireCut(var/wireIndex)
	var/wireFlag = AAlarmIndexToFlag[wireIndex]
	return ((AAlarmwires & wireFlag) == 0)

/obj/machinery/alarm/proc/allWiresCut()
	var/i = 1
	while(i<=5)
		if(AAlarmwires & AAlarmIndexToFlag[i])
			return 0
		i++
	return 1

/obj/machinery/alarm/proc/cut(var/wireColor)
	var/wireFlag = AAlarmWireColorToFlag[wireColor]
	var/wireIndex = AAlarmWireColorToIndex[wireColor]
	AAlarmwires &= ~wireFlag
	switch(wireIndex)
		if(AALARM_WIRE_IDSCAN)
			locked = 1

		if(AALARM_WIRE_POWER)
			shock(usr, 50)
			shorted = 1
			update_icon()

		if (AALARM_WIRE_AI_CONTROL)
			if (aidisabled == 0)
				aidisabled = 1

		if(AALARM_WIRE_SYPHON)
			mode = AALARM_MODE_PANIC
			apply_mode()

		if(AALARM_WIRE_AALARM)

			if (alarm_area.atmosalert(2))
				apply_danger_level(2)
			spawn(1)
				updateUsrDialog()
			update_icon()

	updateDialog()

	return

/obj/machinery/alarm/proc/mend(var/wireColor)
	var/wireFlag = AAlarmWireColorToFlag[wireColor]
	var/wireIndex = AAlarmWireColorToIndex[wireColor] //not used in this function
	AAlarmwires |= wireFlag
	switch(wireIndex)
		if(AALARM_WIRE_IDSCAN)

		if(AALARM_WIRE_POWER)
			shorted = 0
			shock(usr, 50)
			update_icon()

		if(AALARM_WIRE_AI_CONTROL)
			if (aidisabled == 1)
				aidisabled = 0

	updateDialog()
	return

/obj/machinery/alarm/proc/pulse(var/wireColor)
	//var/wireFlag = AAlarmWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = AAlarmWireColorToIndex[wireColor]
	switch(wireIndex)
		if(AALARM_WIRE_IDSCAN)			//unlocks for 30 seconds, if you have a better way to hack I'm all ears
			locked = 0
			spawn(300)
				locked = 1

		if (AALARM_WIRE_POWER)
			if(shorted == 0)
				shorted = 1
				update_icon()

			spawn(1200)
				if(shorted == 1)
					shorted = 0
					update_icon()


		if (AALARM_WIRE_AI_CONTROL)
			if (aidisabled == 0)
				aidisabled = 1
			updateDialog()
			spawn(10)
				if (aidisabled == 1)
					aidisabled = 0
				updateDialog()

		if(AALARM_WIRE_SYPHON)
			mode = AALARM_MODE_REPLACEMENT
			apply_mode()

		if(AALARM_WIRE_AALARM)
			if (alarm_area.atmosalert(0))
				apply_danger_level(0)
			spawn(1)
				updateUsrDialog()
			update_icon()

	updateDialog()
	return

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_ai(mob/user)
	return interact(user)

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()
	if (.)
		return
	return interact(user)

/obj/machinery/alarm/interact(mob/user)
	user.set_interaction(src)

	if(buildstage!=2)
		return

	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user.unset_interaction()
			user << browse(null, "window=air_alarm")
			user << browse(null, "window=AAlarmwires")
			return


		else if (istype(user, /mob/living/silicon) && aidisabled)
			user << "AI control for this Air Alarm interface has been disabled."
			user << browse(null, "window=air_alarm")
			return

	if(wiresexposed && (!istype(user, /mob/living/silicon)))
		var/t1 = text("<html><head><title>[alarm_area.name] Air Alarm Wires</title></head><body><B>Access Panel</B><br>\n")
		var/list/wirecolors = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Black" = 5,
		)
		for(var/wiredesc in wirecolors)
			var/is_uncut = AAlarmwires & AAlarmWireColorToFlag[wirecolors[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];AAlarmwires=[wirecolors[wiredesc]]'>Mend</a>"

			else
				t1 += "<a href='?src=\ref[src];AAlarmwires=[wirecolors[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[wirecolors[wiredesc]]'>Pulse</a> "

			t1 += "<br>"
		t1 += text("<br>\n[(locked ? "The Air Alarm is locked." : "The Air Alarm is unlocked.")]<br>\n[((shorted || (stat & (NOPOWER|BROKEN))) ? "The Air Alarm is offline." : "The Air Alarm is working properly!")]<br>\n[(aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p></body></html>")
		user << browse(t1, "window=AAlarmwires")
		onclose(user, "AAlarmwires")

	if(!shorted)
		user << browse(return_text(user),"window=air_alarm")
		onclose(user, "air_alarm")

	return

/obj/machinery/alarm/proc/return_text(mob/user)
	if(!(istype(user, /mob/living/silicon)) && locked)
		return "<html><head><title>\The [src]</title></head><body>[return_status()]<hr>[rcon_text()]<hr><i>(Swipe ID card to unlock interface)</i></body></html>"
	else
		return "<html><head><title>\The [src]</title></head><body>[return_status()]<hr>[rcon_text()]<hr>[return_controls()]</body></html>"

/obj/machinery/alarm/proc/return_status()
	var/turf/location = get_turf(src)

	var/output = "<b>Air Status:</b><br>"


	output += {"
<style>
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
"}


	var/list/current_settings = TLV["pressure"]
	var/environment_pressure = location.return_pressure()
	var/pressure_dangerlevel = get_danger_level(environment_pressure, current_settings)

	current_settings = TLV["temperature"]
	var/enviroment_temperature = location.return_temperature()
	var/temperature_dangerlevel = get_danger_level(enviroment_temperature, current_settings)

	output += {"
Pressure: <span class='dl[pressure_dangerlevel]'>[environment_pressure]</span>kPa<br>
"}

	output += "Temperature: <span class='dl[temperature_dangerlevel]'>[enviroment_temperature]</span>K ([round(enviroment_temperature - T0C, 0.1)]C)<br>"

	//'Local Status' should report the LOCAL status, damnit.
	output += "Local Status: "
	switch(max(pressure_dangerlevel,oxygen_dangerlevel,co2_dangerlevel,phoron_dangerlevel,other_dangerlevel,temperature_dangerlevel))
		if(2)
			output += "<span class='dl2'>DANGER: Internals Required</span><br>"
		if(1)
			output += "<span class='dl1'>Caution</span><br>"
		if(0)
			output += "<span class='dl0'>Optimal</span><br>"

	output += "Area Status: "
	if(alarm_area.atmosalm)
		output += "<span class='dl1'>Atmos alert in area</span>"
	else if (alarm_area.flags_alarm_state & ALARM_WARNING_FIRE)
		output += "<span class='dl1'>Fire alarm in area</span>"
	else
		output += "No alerts"

	return output

/obj/machinery/alarm/proc/rcon_text()
	var/dat = "<table width=\"100%\"><td align=\"center\"><b>Remote Control:</b><br>"
	if(rcon_setting == RCON_NO)
		dat += "<b>Off</b>"
	else
		dat += "<a href='?src=\ref[src];rcon=[RCON_NO]'>Off</a>"
	dat += "|"
	if(rcon_setting == RCON_AUTO)
		dat += "<b>Auto</b>"
	else
		dat += "<a href='?src=\ref[src];rcon=[RCON_AUTO]'>Auto</a>"
	dat += "|"
	if(rcon_setting == RCON_YES)
		dat += "<b>On</b>"
	else
		dat += "<a href='?src=\ref[src];rcon=[RCON_YES]'>On</a></td>"

	//Hackish, I know.  I didn't feel like bothering to rework all of this.
	dat += "<td align=\"center\"><b>Thermostat:</b><br><a href='?src=\ref[src];temperature=1'>[target_temperature - T0C]C</a></td></table>"

	return dat

/obj/machinery/alarm/proc/return_controls()
	var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"

	switch(screen)
		if (AALARM_SCREEN_MAIN)
			if(alarm_area.atmosalm)
				output += "<a href='?src=\ref[src];atmos_reset=1'>Reset - Area Atmospheric Alarm</a><hr>"
			else
				output += "<a href='?src=\ref[src];atmos_alarm=1'>Activate - Area Atmospheric Alarm</a><hr>"

			output += {"
<a href='?src=\ref[src];screen=[AALARM_SCREEN_SCRUB]'>Scrubbers Control</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_VENT]'>Vents Control</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_MODE]'>Set environmentals mode</a><br>
<a href='?src=\ref[src];screen=[AALARM_SCREEN_SENSORS]'>Sensor Settings</a><br>
<HR>
"}
			if (mode==AALARM_MODE_PANIC)
				output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];mode=[AALARM_MODE_SCRUBBING]'>Turn syphoning off</A>"
			else
				output += "<A href='?src=\ref[src];mode=[AALARM_MODE_PANIC]'><font color='red'>ACTIVATE PANIC SYPHON IN AREA</font></A>"


		if (AALARM_SCREEN_VENT)
			var/sensor_data = ""
			if(alarm_area.air_vent_names.len)
				for(var/id_tag in alarm_area.air_vent_names)
					var/long_name = alarm_area.air_vent_names[id_tag]
					var/list/data = alarm_area.air_vent_info[id_tag]
					if(!data)
						continue;
					var/state = ""

					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A>
<BR>
<B>Pressure checks:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=checks;val=[data["checks"]^1]' [(data["checks"]&1)?"style='font-weight:bold;'":""]>external</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=checks;val=[data["checks"]^2]' [(data["checks"]&2)?"style='font-weight:bold;'":""]>internal</A>
<BR>
<B>External pressure bound:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-1000'>-</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-100'>-</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-10'>-</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=-1'>-</A>
[data["external"]]
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+1'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+10'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+100'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=adjust_external_pressure;val=+1000'>+</A>
<A href='?src=\ref[src];id_tag=[id_tag];command=set_external_pressure;val=[ONE_ATMOSPHERE]'> (reset) </A>
<BR>
"}
					if (data["direction"] == "siphon")
						sensor_data += {"
<B>Direction:</B>
siphoning
<BR>
"}
					sensor_data += {"<HR>"}
			else
				sensor_data = "No vents connected.<BR>"
			output = {"<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}
		if (AALARM_SCREEN_SCRUB)
			var/sensor_data = ""
			if(alarm_area.air_scrub_names.len)
				for(var/id_tag in alarm_area.air_scrub_names)
					var/long_name = alarm_area.air_scrub_names[id_tag]
					var/list/data = alarm_area.air_scrub_info[id_tag]
					if(!data)
						continue;
					var/state = ""

					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A><BR>
<B>Type:</B>
<A href='?src=\ref[src];id_tag=[id_tag];command=scrubbing;val=[!data["scrubbing"]]'>[data["scrubbing"]?"scrubbing":"syphoning"]</A><BR>
"}

					if(data["scrubbing"])
						sensor_data += {"
<B>Filtering:</B>
Carbon Dioxide
<A href='?src=\ref[src];id_tag=[id_tag];command=co2_scrub;val=[!data["filter_co2"]]'>[data["filter_co2"]?"on":"off"]</A>;
Toxins
<A href='?src=\ref[src];id_tag=[id_tag];command=tox_scrub;val=[!data["filter_phoron"]]'>[data["filter_phoron"]?"on":"off"]</A>;
Nitrous Oxide
<A href='?src=\ref[src];id_tag=[id_tag];command=n2o_scrub;val=[!data["filter_n2o"]]'>[data["filter_n2o"]?"on":"off"]</A>
<BR>
"}
					sensor_data += {"
<B>Panic syphon:</B> [data["panic"]?"<font color='red'><B>PANIC SYPHON ACTIVATED</B></font>":""]
<A href='?src=\ref[src];id_tag=[id_tag];command=panic_siphon;val=[!data["panic"]]'><font color='[(data["panic"]?"blue'>Dea":"red'>A")]ctivate</font></A><BR>
<HR>
"}
			else
				sensor_data = "No scrubbers connected.<BR>"
			output = {"<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}

		if (AALARM_SCREEN_MODE)
			output += "<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br><b>Air machinery mode for the area:</b><ul>"
			var/list/modes = list(AALARM_MODE_SCRUBBING   = "Filtering - Scrubs out contaminants",\
				AALARM_MODE_REPLACEMENT = "<font color='blue'>Replace Air - Siphons out air while replacing</font>",\
				AALARM_MODE_PANIC       = "<font color='red'>Panic - Siphons air out of the room</font>",\
				AALARM_MODE_CYCLE       = "<font color='red'>Cycle - Siphons air before replacing</font>",\
				AALARM_MODE_FILL        = "<font color='green'>Fill - Shuts off scrubbers and opens vents</font>",\
				AALARM_MODE_OFF         = "<font color='blue'>Off - Shuts off vents and scrubbers</font>",)
			for (var/m=1,m<=modes.len,m++)
				if (mode==m)
					output += "<li><A href='?src=\ref[src];mode=[m]'><b>[modes[m]]</b></A> (selected)</li>"
				else
					output += "<li><A href='?src=\ref[src];mode=[m]'>[modes[m]]</A></li>"
			output += "</ul>"

		if (AALARM_SCREEN_SENSORS)
			output += {"
<a href='?src=\ref[src];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
<b>Alarm thresholds:</b><br>
Partial pressure for gases
<style>/* some CSS woodoo here. Does not work perfect in ie6 but who cares? */
table td { border-left: 1px solid black; border-top: 1px solid black;}
table tr:first-child th { border-left: 1px solid black;}
table th:first-child { border-top: 1px solid black; font-weight: normal;}
table tr:first-child th:first-child { border: none;}
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
<table cellspacing=0>
<TR><th></th><th class=dl2>min2</th><th class=dl1>min1</th><th class=dl1>max1</th><th class=dl2>max2</th></TR>
"}
			var/list/gases = list(
				"oxygen"         = "O<sub>2</sub>",
				"carbon dioxide" = "CO<sub>2</sub>",
				"phoron"         = "Toxin",
				"other"          = "Other",)

			var/list/selected
			for (var/g in gases)
				output += "<TR><th>[gases[g]]</th>"
				selected = TLV[g]
				for(var/i = 1, i <= 4, i++)
					output += "<td><A href='?src=\ref[src];command=set_threshold;env=[g];var=[i]'>[selected[i] >= 0 ? selected[i] :"OFF"]</A></td>"
				output += "</TR>"

			selected = TLV["pressure"]
			output += "	<TR><th>Pressure</th>"
			for(var/i = 1, i <= 4, i++)
				output += "<td><A href='?src=\ref[src];command=set_threshold;env=pressure;var=[i]'>[selected[i] >= 0 ? selected[i] :"OFF"]</A></td>"
			output += "</TR>"

			selected = TLV["temperature"]
			output += "<TR><th>Temperature</th>"
			for(var/i = 1, i <= 4, i++)
				output += "<td><A href='?src=\ref[src];command=set_threshold;env=temperature;var=[i]'>[selected[i] >= 0 ? selected[i] :"OFF"]</A></td>"
			output += "</TR></table>"

	return output

/obj/machinery/alarm/Topic(href, href_list)
	if(..() || !( Adjacent(usr) || istype(usr, /mob/living/silicon)) ) // dont forget calling super in machine Topics -walter0o
		usr.unset_interaction()
		usr << browse(null, "window=air_alarm")
		usr << browse(null, "window=AAlarmwires")
		return

	add_fingerprint(usr)
	usr.set_interaction(src)

	// hrefs that can always be called -walter0o
	if(href_list["rcon"])
		var/attempted_rcon_setting = text2num(href_list["rcon"])

		switch(attempted_rcon_setting)
			if(RCON_NO)
				rcon_setting = RCON_NO
			if(RCON_AUTO)
				rcon_setting = RCON_AUTO
			if(RCON_YES)
				rcon_setting = RCON_YES
			else
				return

	if(href_list["temperature"])
		var/list/selected = TLV["temperature"]
		var/max_temperature = min(selected[3] - T0C, MAX_TEMPERATURE)
		var/min_temperature = max(selected[2] - T0C, MIN_TEMPERATURE)
		var/input_temperature = input("What temperature would you like the system to mantain? (Capped between [min_temperature]C and [max_temperature]C)", "Thermostat Controls") as num|null
		if(!input_temperature || input_temperature > max_temperature || input_temperature < min_temperature)
			usr << "Temperature must be between [min_temperature]C and [max_temperature]C"
		else
			target_temperature = input_temperature + T0C

	// hrefs that need the AA unlocked -walter0o
	if(!locked || istype(usr, /mob/living/silicon))

		if(href_list["command"])
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])
				if( "power",
					"adjust_external_pressure",
					"set_external_pressure",
					"checks",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"panic_siphon",
					"scrubbing")

					send_signal(device_id, list(href_list["command"] = text2num(href_list["val"]) ) )

				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as null|num
					if (isnull(newval) || ..() || (locked && !issilicon(usr)))
						return
					if (newval<0)
						selected[threshold] = -1.0
					else if (env=="temperature" && newval>5000)
						selected[threshold] = 5000
					else if (env=="pressure" && newval>50*ONE_ATMOSPHERE)
						selected[threshold] = 50*ONE_ATMOSPHERE
					else if (env!="temperature" && env!="pressure" && newval>200)
						selected[threshold] = 200
					else
						newval = round(newval,0.01)
						selected[threshold] = newval
					if(threshold == 1)
						if(selected[1] > selected[2])
							selected[2] = selected[1]
						if(selected[1] > selected[3])
							selected[3] = selected[1]
						if(selected[1] > selected[4])
							selected[4] = selected[1]
					if(threshold == 2)
						if(selected[1] > selected[2])
							selected[1] = selected[2]
						if(selected[2] > selected[3])
							selected[3] = selected[2]
						if(selected[2] > selected[4])
							selected[4] = selected[2]
					if(threshold == 3)
						if(selected[1] > selected[3])
							selected[1] = selected[3]
						if(selected[2] > selected[3])
							selected[2] = selected[3]
						if(selected[3] > selected[4])
							selected[4] = selected[3]
					if(threshold == 4)
						if(selected[1] > selected[4])
							selected[1] = selected[4]
						if(selected[2] > selected[4])
							selected[2] = selected[4]
						if(selected[3] > selected[4])
							selected[3] = selected[4]

					apply_mode()

		if(href_list["screen"])
			screen = text2num(href_list["screen"])

		if(href_list["atmos_unlock"])
			switch(href_list["atmos_unlock"])
				if("0")
					alarm_area.air_doors_close()
				if("1")
					alarm_area.air_doors_open()

		if(href_list["atmos_alarm"])
			if (alarm_area.atmosalert(2))
				apply_danger_level(2)
			update_icon()

		if(href_list["atmos_reset"])
			if (alarm_area.atmosalert(0))
				apply_danger_level(0)
			update_icon()

		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			apply_mode()

	// hrefs that need the AA wires exposed, note that borgs should be in range here too -walter0o
	if(wiresexposed && Adjacent(usr))

		if (href_list["AAlarmwires"])
			var/t1 = text2num(href_list["AAlarmwires"])
			if (!( istype(usr.get_held_item(), /obj/item/tool/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (isWireColorCut(t1))
				mend(t1)
			else
				cut(t1)
				if (AAlarmwires == 0)
					usr << "<span class='notice'>You cut last of wires inside [src]</span>"
					update_icon()
					buildstage = 1
				return

		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if (!istype(usr.get_held_item(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				pulse(t1)

	updateUsrDialog()


/obj/machinery/alarm/attackby(obj/item/W as obj, mob/user as mob)
/*	if (istype(W, /obj/item/tool/wirecutters))
		stat ^= BROKEN
		add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has []activated []!", user, (stat&BROKEN) ? "de" : "re", src), 1)
		update_icon()
		return
*/
	src.add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(isscrewdriver(W))  // Opening that Air Alarm up.
				//user << "You pop the Air Alarm's maintence panel open."
				wiresexposed = !wiresexposed
				user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
				update_icon()
				return

			if(wiresexposed && ((istype(W, /obj/item/device/multitool) || istype(W, /obj/item/tool/wirecutters))))
				return attack_hand(user)

			if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					user << "It does nothing"
					return
				else
					if(allowed(usr) && !isWireCut(AALARM_WIRE_IDSCAN))
						locked = !locked
						user << "\blue You [ locked ? "lock" : "unlock"] the Air Alarm interface."
						updateUsrDialog()
					else
						user << "\red Access denied."
			return

		if(1)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(5))
					user << "<span class='notice'>You wire \the [src].</span>"
					buildstage = 2
					update_icon()
					first_run()
					return
				else
					user << "<span class='warning'>You need 5 pieces of cable to do wire \the [src].</span>"
					return

			else if(iscrowbar(W))
				user.visible_message("<span class='notice'>[user] starts prying out [src]'s circuits.</span>",
				"<span class='notice'>You start prying out [src]'s circuits.</span>")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
				if(do_after(user,20, TRUE, 5, BUSY_ICON_BUILD))
					user.visible_message("<span class='notice'>[user] pries out [src]'s circuits.</span>",
					"<span class='notice'>You pry out [src]'s circuits.</span>")
					var/obj/item/circuitboard/airalarm/circuit = new()
					circuit.loc = user.loc
					buildstage = 0
					update_icon()
				return
		if(0)
			if(istype(W, /obj/item/circuitboard/airalarm))
				user << "You insert the circuit!"
				cdel(W)
				buildstage = 1
				update_icon()
				return

			else if(iswrench(W))
				user << "You remove the fire alarm assembly from the wall!"
				var/obj/item/frame/air_alarm/frame = new /obj/item/frame/air_alarm()
				frame.loc = user.loc
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				cdel(src)

	return ..()

/obj/machinery/alarm/power_change()
	..()
	spawn(rand(0,15))
		update_icon()

/obj/machinery/alarm/examine(mob/user)
	..()
	if (buildstage < 2)
		user << "It is not wired."
	if (buildstage < 1)
		user << "The circuit is missing."




/obj/machinery/alarm/monitor
	apply_danger_level = 0
	breach_detection = 0
	post_alert = 0

/obj/machinery/alarm/server/New()
	..()
	req_one_access = list(ACCESS_CIVILIAN_ENGINEERING)
	TLV["oxygen"] =			list(-1.0, -1.0,-1.0,-1.0) // Partial pressure, kpa
	TLV["carbon dioxide"] = list(-1.0, -1.0,   5,  10) // Partial pressure, kpa
	TLV["phoron"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(0,ONE_ATMOSPHERE*0.10,ONE_ATMOSPHERE*1.40,ONE_ATMOSPHERE*1.60) /* kpa */
	TLV["temperature"] =	list(20, 40, 140, 160) // K
	target_temperature = 90


//Almayer version
/obj/machinery/alarm/almayer


