/obj/machinery/computer/general_air_control
	icon_state = "computer"
	screen_overlay = "tank"
	broken_icon = "computer_blue_broken"
	var/frequency = 1439
	var/list/sensors = list()

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection
	circuit = /obj/item/circuitboard/computer/air_management


/obj/machinery/computer/general_air_control/Initialize(mapload)
	. = ..()
	set_frequency(frequency)


/obj/machinery/computer/general_air_control/Destroy()
	if(radio_connection)
		SSradio.remove_object(src, frequency)
		radio_connection = null
	return ..()


/obj/machinery/computer/general_air_control/interact(mob/user)
	. = ..()
	if(.)
		return

	var/datum/browser/popup = new(user, "computer")
	popup.set_content(return_text())
	popup.open()


/obj/machinery/computer/general_air_control/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["tag"]
	if(!id_tag || !sensors.Find(id_tag)) return

	sensor_information[id_tag] = signal.data

/obj/machinery/computer/general_air_control/proc/return_text()
	var/sensor_data
	if(length(sensors))
		for(var/id_tag in sensors)
			var/long_name = sensors[id_tag]
			var/list/data = sensor_information[id_tag]
			var/sensor_part = "<B>[long_name]</B>:<BR>"

			if(data)
				if(data["pressure"])
					sensor_part += "   <B>Pressure:</B> [data["pressure"]] kPa<BR>"
				if(data["temperature"])
					sensor_part += "   <B>Temperature:</B> [data["temperature"]] K<BR>"
				if(data["oxygen"]||data["phoron"]||data["nitrogen"]||data["carbon_dioxide"])
					sensor_part += "   <B>Gas Composition :</B>"
					if(data["oxygen"])
						sensor_part += "[data["oxygen"]]% O2; "
					if(data["nitrogen"])
						sensor_part += "[data["nitrogen"]]% N; "
					if(data["carbon_dioxide"])
						sensor_part += "[data["carbon_dioxide"]]% CO2; "
					if(data["phoron"])
						sensor_part += "[data["phoron"]]% TX; "
				sensor_part += "<HR>"

			else
				sensor_part = "<FONT color='red'>[long_name] can not be found!</FONT><BR>"

			sensor_data += sensor_part

	else
		sensor_data = "No sensors connected."

	var/output = {"<B>[name]</B><HR>
<B>Sensor Data:</B><HR><HR>[sensor_data]"}

	return output

/obj/machinery/computer/general_air_control/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)


/obj/machinery/computer/general_air_control/large_tank_control
	frequency = 1441
	var/input_tag
	var/output_tag

	var/list/input_info
	var/list/output_info

	var/input_flow_setting = 200
	var/pressure_setting = ONE_ATMOSPHERE * 45
	circuit = /obj/item/circuitboard/computer/air_management/tank_control


/obj/machinery/computer/general_air_control/large_tank_control/return_text()
	var/output = ..()
	//if(signal.data)
	//	input_info = signal.data // Attempting to fix intake control -- TLE

	output += "<B>Tank Control System</B><BR><BR>"
	if(input_info)
		var/power = (input_info["power"])
		var/volume_rate = round(input_info["volume_rate"], 0.1)
		output += "<B>Input</B>: [power?("Injecting"):("On Hold")] <A href='?src=[text_ref(src)];in_refresh_status=1'>Refresh</A><BR>Flow Rate Limit: [volume_rate] L/s<BR>"
		output += "Command: <A href='?src=[text_ref(src)];in_toggle_injector=1'>Toggle Power</A> <A href='?src=[text_ref(src)];in_set_flowrate=1'>Set Flow Rate</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find input port</FONT> <A href='?src=[text_ref(src)];in_refresh_status=1'>Search</A><BR>"

	output += "Flow Rate Limit: <A href='?src=[text_ref(src)];adj_input_flow_rate=-100'>-</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=-10'>-</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=-1'>-</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=-0.1'>-</A> [round(input_flow_setting, 0.1)] L/s <A href='?src=[text_ref(src)];adj_input_flow_rate=0.1'>+</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=1'>+</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=10'>+</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=100'>+</A><BR>"

	output += "<BR>"

	if(output_info)
		var/power = (output_info["power"])
		var/output_pressure = output_info["internal"]
		output += {"<B>Output</B>: [power?("Open"):("On Hold")] <A href='?src=[text_ref(src)];out_refresh_status=1'>Refresh</A><BR>
Max Output Pressure: [output_pressure] kPa<BR>"}
		output += "Command: <A href='?src=[text_ref(src)];out_toggle_power=1'>Toggle Power</A> <A href='?src=[text_ref(src)];out_set_pressure=1'>Set Pressure</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find output port</FONT> <A href='?src=[text_ref(src)];out_refresh_status=1'>Search</A><BR>"

	output += "Max Output Pressure Set: <A href='?src=[text_ref(src)];adj_pressure=-1000'>-</A> <A href='?src=[text_ref(src)];adj_pressure=-100'>-</A> <A href='?src=[text_ref(src)];adj_pressure=-10'>-</A> <A href='?src=[text_ref(src)];adj_pressure=-1'>-</A> [pressure_setting] kPa <A href='?src=[text_ref(src)];adj_pressure=1'>+</A> <A href='?src=[text_ref(src)];adj_pressure=10'>+</A> <A href='?src=[text_ref(src)];adj_pressure=100'>+</A> <A href='?src=[text_ref(src)];adj_pressure=1000'>+</A><BR>"

	return output

/obj/machinery/computer/general_air_control/large_tank_control/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)

/obj/machinery/computer/general_air_control/large_tank_control/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["adj_pressure"])
		var/change = text2num(href_list["adj_pressure"])
		pressure_setting = between(0, pressure_setting + change, 50*ONE_ATMOSPHERE)
		INVOKE_NEXT_TICK(src, PROC_REF(updateUsrDialog))
		return

	if(href_list["adj_input_flow_rate"])
		var/change = text2num(href_list["adj_input_flow_rate"])
		input_flow_setting = between(0, input_flow_setting + change, ATMOS_DEFAULT_VOLUME_PUMP + 500) //default flow rate limit for air injectors
		INVOKE_NEXT_TICK(src, PROC_REF(updateUsrDialog))
		return

	if(!radio_connection)
		return 0
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	if(href_list["in_refresh_status"])
		input_info = null
		signal.data = list ("tag" = input_tag, "status" = 1)

	if(href_list["in_toggle_injector"])
		input_info = null
		signal.data = list ("tag" = input_tag, "power_toggle" = 1)

	if(href_list["in_set_flowrate"])
		input_info = null
		signal.data = list ("tag" = input_tag, "set_volume_rate" = "[input_flow_setting]")

	if(href_list["out_refresh_status"])
		output_info = null
		signal.data = list ("tag" = output_tag, "status" = 1)

	if(href_list["out_toggle_power"])
		output_info = null
		signal.data = list ("tag" = output_tag, "power_toggle" = 1)

	if(href_list["out_set_pressure"])
		output_info = null
		signal.data = list ("tag" = output_tag, "set_internal_pressure" = "[pressure_setting]")

	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	addtimer(CALLBACK(src, PROC_REF(updateUsrDialog)), 5)

/obj/machinery/computer/general_air_control/supermatter_core
	frequency = 1438
	var/input_tag
	var/output_tag

	var/list/input_info
	var/list/output_info

	var/input_flow_setting = 700
	var/pressure_setting = 100
	circuit = /obj/item/circuitboard/computer/air_management/supermatter_core


/obj/machinery/computer/general_air_control/supermatter_core/return_text()
	var/output = ..()
	//if(signal.data)
	//	input_info = signal.data // Attempting to fix intake control -- TLE

	output += "<B>Core Cooling Control System</B><BR><BR>"
	if(input_info)
		var/power = (input_info["power"])
		var/volume_rate = round(input_info["volume_rate"], 0.1)
		output += "<B>Coolant Input</B>: [power?("Injecting"):("On Hold")] <A href='?src=[text_ref(src)];in_refresh_status=1'>Refresh</A><BR>Flow Rate Limit: [volume_rate] L/s<BR>"
		output += "Command: <A href='?src=[text_ref(src)];in_toggle_injector=1'>Toggle Power</A> <A href='?src=[text_ref(src)];in_set_flowrate=1'>Set Flow Rate</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find input port</FONT> <A href='?src=[text_ref(src)];in_refresh_status=1'>Search</A><BR>"

	output += "Flow Rate Limit: <A href='?src=[text_ref(src)];adj_input_flow_rate=-100'>-</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=-10'>-</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=-1'>-</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=-0.1'>-</A> [round(input_flow_setting, 0.1)] L/s <A href='?src=[text_ref(src)];adj_input_flow_rate=0.1'>+</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=1'>+</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=10'>+</A> <A href='?src=[text_ref(src)];adj_input_flow_rate=100'>+</A><BR>"

	output += "<BR>"

	if(output_info)
		var/power = (output_info["power"])
		var/pressure_limit = output_info["external"]
		output += {"<B>Core Outpump</B>: [power?("Open"):("On Hold")] <A href='?src=[text_ref(src)];out_refresh_status=1'>Refresh</A><BR>
Min Core Pressure: [pressure_limit] kPa<BR>"}
		output += "Command: <A href='?src=[text_ref(src)];out_toggle_power=1'>Toggle Power</A> <A href='?src=[text_ref(src)];out_set_pressure=1'>Set Pressure</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find output port</FONT> <A href='?src=[text_ref(src)];out_refresh_status=1'>Search</A><BR>"

	output += "Min Core Pressure Set: <A href='?src=[text_ref(src)];adj_pressure=-100'>-</A> <A href='?src=[text_ref(src)];adj_pressure=-50'>-</A> <A href='?src=[text_ref(src)];adj_pressure=-10'>-</A> <A href='?src=[text_ref(src)];adj_pressure=-1'>-</A> [pressure_setting] kPa <A href='?src=[text_ref(src)];adj_pressure=1'>+</A> <A href='?src=[text_ref(src)];adj_pressure=10'>+</A> <A href='?src=[text_ref(src)];adj_pressure=50'>+</A> <A href='?src=[text_ref(src)];adj_pressure=100'>+</A><BR>"

	return output

/obj/machinery/computer/general_air_control/supermatter_core/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["tag"]

	if(input_tag == id_tag)
		input_info = signal.data
	else if(output_tag == id_tag)
		output_info = signal.data
	else
		..(signal)

/obj/machinery/computer/general_air_control/supermatter_core/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["adj_pressure"])
		var/change = text2num(href_list["adj_pressure"])
		pressure_setting = between(0, pressure_setting + change, 10*ONE_ATMOSPHERE)
		INVOKE_NEXT_TICK(src, PROC_REF(updateUsrDialog))
		return

	if(href_list["adj_input_flow_rate"])
		var/change = text2num(href_list["adj_input_flow_rate"])
		input_flow_setting = between(0, input_flow_setting + change, ATMOS_DEFAULT_VOLUME_PUMP + 500) //default flow rate limit for air injectors
		INVOKE_NEXT_TICK(src, PROC_REF(updateUsrDialog))
		return

	if(!radio_connection)
		return 0
	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	if(href_list["in_refresh_status"])
		input_info = null
		signal.data = list ("tag" = input_tag, "status" = 1)

	if(href_list["in_toggle_injector"])
		input_info = null
		signal.data = list ("tag" = input_tag, "power_toggle" = 1)

	if(href_list["in_set_flowrate"])
		input_info = null
		signal.data = list ("tag" = input_tag, "set_volume_rate" = "[input_flow_setting]")

	if(href_list["out_refresh_status"])
		output_info = null
		signal.data = list ("tag" = output_tag, "status" = 1)

	if(href_list["out_toggle_power"])
		output_info = null
		signal.data = list ("tag" = output_tag, "power_toggle" = 1)

	if(href_list["out_set_pressure"])
		output_info = null
		signal.data = list ("tag" = output_tag, "set_external_pressure" = "[pressure_setting]", "checks" = 1)

	signal.data["sigtype"]="command"
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	addtimer(CALLBACK(src, PROC_REF(updateUsrDialog)), 5)

/obj/machinery/computer/general_air_control/fuel_injection
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer_small"
	screen_overlay = "atmos"

	var/device_tag
	var/list/device_info

	var/automation = 0

	var/cutoff_temperature = 2000
	var/on_temperature = 1200
	circuit = /obj/item/circuitboard/computer/air_management/injector_control

/obj/machinery/computer/general_air_control/fuel_injection/process()
	if(automation)
		if(!radio_connection)
			return 0

		var/injecting = 0
		for(var/id_tag in sensor_information)
			var/list/data = sensor_information[id_tag]
			if(data["temperature"])
				if(data["temperature"] >= cutoff_temperature)
					injecting = 0
					break
				if(data["temperature"] <= on_temperature)
					injecting = 1

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src

		signal.data = list(
			"tag" = device_tag,
			"power" = injecting,
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	..()

/obj/machinery/computer/general_air_control/fuel_injection/return_text()
	var/output = ..()

	output += "<B>Fuel Injection System</B><BR>"
	if(device_info)
		var/power = device_info["power"]
		var/volume_rate = device_info["volume_rate"]
		output += {"Status: [power?("Injecting"):("On Hold")] <A href='?src=[text_ref(src)];refresh_status=1'>Refresh</A><BR>
Rate: [volume_rate] L/sec<BR>"}

		if(automation)
			output += "Automated Fuel Injection: <A href='?src=[text_ref(src)];toggle_automation=1'>Engaged</A><BR>"
			output += "Injector Controls Locked Out<BR>"
		else
			output += "Automated Fuel Injection: <A href='?src=[text_ref(src)];toggle_automation=1'>Disengaged</A><BR>"
			output += "Injector: <A href='?src=[text_ref(src)];toggle_injector=1'>Toggle Power</A> <A href='?src=[text_ref(src)];injection=1'>Inject (1 Cycle)</A><BR>"

	else
		output += "<FONT color='red'>ERROR: Can not find device</FONT> <A href='?src=[text_ref(src)];refresh_status=1'>Search</A><BR>"

	return output

/obj/machinery/computer/general_air_control/fuel_injection/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/id_tag = signal.data["tag"]

	if(device_tag == id_tag)
		device_info = signal.data
	else
		..(signal)

/obj/machinery/computer/general_air_control/fuel_injection/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["refresh_status"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"status" = 1,
			"sigtype"="command"
		)
		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	if(href_list["toggle_automation"])
		automation = !automation

	if(href_list["toggle_injector"])
		device_info = null
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"power_toggle" = 1,
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	if(href_list["injection"])
		if(!radio_connection)
			return 0

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.source = src
		signal.data = list(
			"tag" = device_tag,
			"inject" = 1,
			"sigtype"="command"
		)

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)




