

/obj/item/circuitboard/computer


/obj/item/circuitboard/computer/message_monitor
	name = "Circuit board (Message Monitor)"
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = "programming=3"

//TODO: Move these into computer/camera.dm
/obj/item/circuitboard/computer/security
	name = "Circuit board (Security Camera Monitor)"
	build_path = /obj/machinery/computer/security
	var/network = list("military")
	req_access = list(ACCESS_MARINE_BRIG)
	var/locked = 1
	var/emagged = 0

/obj/item/circuitboard/computer/security/construct(var/obj/machinery/computer/security/C)
	if (..(C))
		C.network = network

/obj/item/circuitboard/computer/security/deconstruct(var/obj/machinery/computer/security/C)
	if (..(C))
		network = C.network

/obj/item/circuitboard/computer/security/engineering
	name = "Circuit board (Engineering Camera Monitor)"
	build_path = /obj/machinery/computer/security/engineering
	network = list("Engineering","Power Alarms","Atmosphere Alarms","Fire Alarms")
	req_access = list()
/obj/item/circuitboard/computer/security/mining
	name = "Circuit board (Mining Camera Monitor)"
	build_path = /obj/machinery/computer/security/mining
	network = list("MINE")
	req_access = list()

/obj/item/circuitboard/computer/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"
	origin_tech = "programming=3"

/obj/item/circuitboard/computer/aiupload
	name = "Circuit board (AI Upload)"
	build_path = /obj/machinery/computer/aiupload
	origin_tech = "programming=4"

/obj/item/circuitboard/computer/borgupload
	name = "Circuit board (Cyborg Upload)"
	build_path = /obj/machinery/computer/borgupload
	origin_tech = "programming=4"

/obj/item/circuitboard/computer/med_data
	name = "Circuit board (Medical Records)"
	build_path = /obj/machinery/computer/med_data

/obj/item/circuitboard/computer/pandemic
	name = "Circuit board (PanD.E.M.I.C. 2200)"
	build_path = /obj/machinery/computer/pandemic
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = "programming=2;biotech=2"

/obj/item/circuitboard/computer/communications
	name = "Circuit board (Communications)"
	build_path = /obj/machinery/computer/communications
	origin_tech = "programming=2;magnets=2"

/obj/item/circuitboard/computer/card
	name = "Circuit board (ID Computer)"
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "Circuit board (CentCom ID Computer)"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/teleporter
	name = "Circuit board (Teleporter)"
	build_path = /obj/machinery/computer/teleporter
	origin_tech = "programming=2;bluespace=2"

/obj/item/circuitboard/computer/secure_data
	name = "Circuit board (Security Records)"
	build_path = /obj/machinery/computer/secure_data

/obj/item/circuitboard/computer/skills
	name = "Circuit board (Employment Records)"
	build_path = /obj/machinery/computer/skills

/obj/item/circuitboard/computer/stationalert
	name = "Circuit board (Station Alerts)"
	build_path = /obj/machinery/computer/station_alert



/obj/item/circuitboard/computer/air_management
	name = "Circuit board (Atmospheric Monitor)"
	build_path = /obj/machinery/computer/general_air_control
	var/frequency = 1439

/obj/item/circuitboard/computer/air_management/tank_control
	name = "Circuit board (Tank Control)"
	build_path = /obj/machinery/computer/general_air_control/large_tank_control
	frequency = 1441

/obj/item/circuitboard/computer/air_management/supermatter_core
	name = "Circuit board (Core Control)"
	build_path = /obj/machinery/computer/general_air_control/supermatter_core
	frequency = 1438

/obj/item/circuitboard/computer/air_management/injector_control
	name = "Circuit board (Injector Control)"
	build_path = /obj/machinery/computer/general_air_control/fuel_injection

/obj/item/circuitboard/computer/air_management/construct(var/obj/machinery/computer/general_air_control/C)
	if (..(C))
		C.frequency = frequency

/obj/item/circuitboard/computer/air_management/deconstruct(var/obj/machinery/computer/general_air_control/C)
	if (..(C))
		frequency = C.frequency



/obj/item/circuitboard/computer/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/circuitboard/computer/pod
	name = "Circuit board (Massdriver control)"
	build_path = /obj/machinery/computer/pod
/obj/item/circuitboard/computer/robotics
	name = "Circuit board (Robotics Control)"
	build_path = /obj/machinery/computer/robotics
	origin_tech = "programming=3"
/obj/item/circuitboard/computer/drone_control
	name = "Circuit board (Drone Control)"
	build_path = /obj/machinery/computer/drone_control
	origin_tech = "programming=3"
/obj/item/circuitboard/computer/arcade
	name = "Circuit board (Arcade)"
	build_path = /obj/machinery/computer/arcade
	origin_tech = "programming=1"
/obj/item/circuitboard/computer/turbine_control
	name = "Circuit board (Turbine control)"
	build_path = /obj/machinery/computer/turbine_computer
/obj/item/circuitboard/computer/solar_control
	name = "Circuit board (Solar Control)"
	build_path = /obj/machinery/power/solar_control
	origin_tech = "programming=2;powerstorage=2"
/obj/item/circuitboard/computer/powermonitor
	name = "Circuit board (Power Monitor)"
	build_path = /obj/machinery/power/monitor
/obj/item/circuitboard/computer/olddoor
	name = "Circuit board (DoorMex)"
	build_path = /obj/machinery/computer/pod/old
/obj/item/circuitboard/computer/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/circuitboard/computer/swfdoor
	name = "Circuit board (Magix)"
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/circuitboard/computer/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = /obj/machinery/computer/prisoner
/obj/item/circuitboard/computer/rdconsole
	name = "Circuit Board (RD Console)"
	build_path = /obj/machinery/computer/rdconsole/core
/obj/item/circuitboard/computer/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = /obj/machinery/computer/mecha
/obj/item/circuitboard/computer/rdservercontrol
	name = "Circuit Board (R&D Server Control)"
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/circuitboard/computer/crew
	name = "Circuit board (Crew monitoring computer)"
	build_path = /obj/machinery/computer/crew
	origin_tech = "programming=3;biotech=2;magnets=2"
/obj/item/circuitboard/computer/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = "programming=2;powerstorage=3"
/obj/item/circuitboard/computer/ordercomp
	name = "Circuit board (Supply ordering console)"
	build_path = /obj/machinery/computer/ordercomp
	origin_tech = "programming=2"

/obj/item/circuitboard/computer/supplycomp
	name = "Circuit board (Supply shuttle console)"
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = "programming=3"
	var/contraband_enabled = 0

/obj/item/circuitboard/computer/supplycomp/construct(var/obj/machinery/computer/supplycomp/SC)
	if (..(SC))
		SC.can_order_contraband = contraband_enabled

/obj/item/circuitboard/computer/supplycomp/deconstruct(var/obj/machinery/computer/supplycomp/SC)
	if (..(SC))
		contraband_enabled = SC.can_order_contraband

/obj/item/circuitboard/computer/operating
	name = "Circuit board (Operating Computer)"
	build_path = /obj/machinery/computer/operating
	origin_tech = "programming=2;biotech=2"
/obj/item/circuitboard/computer/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = "programming=3"
/obj/item/circuitboard/computer/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = "programming=3"
/obj/item/circuitboard/computer/comm_traffic
	name = "Circuitboard (Telecommunications Traffic Control)"
	build_path = /obj/machinery/computer/telecomms/traffic
	origin_tech = "programming=3"

/obj/item/circuitboard/computer/mining_shuttle
	name = "Circuit board (Mining Shuttle)"
	build_path = /obj/machinery/computer/shuttle_control/mining
	origin_tech = "programming=2"
/obj/item/circuitboard/computer/engineering_shuttle
	name = "Circuit board (Engineering Shuttle)"
	build_path = /obj/machinery/computer/shuttle_control/engineering
	origin_tech = "programming=2"
/obj/item/circuitboard/computer/research_shuttle
	name = "Circuit board (Research Shuttle)"
	build_path = /obj/machinery/computer/shuttle_control/research
	origin_tech = "programming=2"
/obj/item/circuitboard/computer/HolodeckControl // Not going to let people get this, but it's just here for future
	name = "Circuit board (Holodeck Control)"
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = "programming=4"
/obj/item/circuitboard/computer/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	build_path = /obj/machinery/computer/aifixer
	origin_tech = "programming=3;biotech=2"
/obj/item/circuitboard/computer/area_atmos
	name = "Circuit board (Area Air Control)"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = "programming=2"
/obj/item/circuitboard/computer/prison_shuttle
	name = "Circuit board (Prison Shuttle)"
	build_path = /obj/machinery/computer/prison_shuttle
	origin_tech = "programming=2"


/obj/item/circuitboard/computer/supplycomp/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/device/multitool))
		var/catastasis = src.contraband_enabled
		var/opposite_catastasis
		if(catastasis)
			opposite_catastasis = "STANDARD"
			catastasis = "BROAD"
		else
			opposite_catastasis = "BROAD"
			catastasis = "STANDARD"

		switch( alert("Current receiver spectrum is set to: [catastasis]","Multitool-Circuitboard interface","Switch to [opposite_catastasis]","Cancel") )
		//switch( alert("Current receiver spectrum is set to: " {(src.contraband_enabled) ? ("BROAD") : ("STANDARD")} , "Multitool-Circuitboard interface" , "Switch to " {(src.contraband_enabled) ? ("STANDARD") : ("BROAD")}, "Cancel") )
			if("Switch to STANDARD","Switch to BROAD")
				src.contraband_enabled = !src.contraband_enabled

			if("Cancel")
				return
			else
				user << "DERP! BUG! Report this (And what you were doing to cause it) to Agouri"
	return

/obj/item/circuitboard/computer/security/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/card/emag))
		if(emagged)
			user << "Circuit lock is already removed."
			return
		user << "\blue You override the circuit lock and open controls."
		emagged = 1
		locked = 0
	else if(istype(I,/obj/item/card/id))
		if(emagged)
			user << "\red Circuit lock does not respond."
			return
		if(check_access(I))
			locked = !locked
			user << "\blue You [locked ? "" : "un"]lock the circuit controls."
		else
			user << "\red Access denied."
	else if(istype(I,/obj/item/device/multitool))
		if(locked)
			user << "\red Circuit controls are locked."
			return
		var/existing_networks = list2text(network,",")
		var/input = strip_html(input(usr, "Which networks would you like to connect this camera console circuit to? Seperate networks with a comma. No Spaces!\nFor example: military,Security,Secret ", "Multitool-Circuitboard interface", existing_networks))
		if(!input)
			usr << "No input found please hang up and try your call again."
			return
		var/list/tempnetwork = text2list(input, ",")
		tempnetwork = difflist(tempnetwork,RESTRICTED_CAMERA_NETWORKS,1)
		if(tempnetwork.len < 1)
			usr << "No network found please hang up and try your call again."
			return
		network = tempnetwork
	return

/obj/item/circuitboard/computer/rdconsole/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/tool/screwdriver))
		user.visible_message("\blue \the [user] adjusts the jumper on the [src]'s access protocol pins.", "\blue You adjust the jumper on the access protocol pins.")
		if(src.build_path == /obj/machinery/computer/rdconsole/core)
			src.name = "Circuit Board (RD Console - Robotics)"
			src.build_path = /obj/machinery/computer/rdconsole/robotics
			user << "\blue Access protocols set to robotics."
		else
			src.name = "Circuit Board (RD Console)"
			src.build_path = /obj/machinery/computer/rdconsole/core
			user << "\blue Access protocols set to default."


