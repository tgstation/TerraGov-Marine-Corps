#define CONTROL_POD_DOORS 0
#define CONTROL_NORMAL_DOORS 1

/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	var/id = null
	var/range = 10
	var/normaldoorcontrol = CONTROL_POD_DOORS
	var/desiredstate = 0 // Zero is closed, 1 is open.
	var/specialfunctions = 1
	var/directional = TRUE //if true we apply directional offsets, if not the door control is free floating
	anchored = TRUE
	var/pressed = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/door_control/unmeltable
	resistance_flags = RESIST_ALL

/obj/machinery/door_control/ai
	name = "AI Lockdown"

/obj/machinery/door_control/ai/exterior
	name = "AI Exterior Lockdown"
	id = "ailockdownexterior"

/obj/machinery/door_control/ai/interior
	name = "AI Interior Lockdown"
	id = "ailockdowninterior"

/obj/machinery/door_control/Initialize(mapload, ndir = 0)
	. = ..()
	if(directional)
		setDir(ndir)
		pixel_x = ( (dir & 3) ? 0 : (dir == 4 ? -22 : 22) )
		pixel_y = ( (dir & 3) ? (dir == 1 ? -16 : 28) : 0 )
		update_icon()

/obj/machinery/door_control/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/detective_scanner))
		return
	else
		return attack_hand(user)

/obj/machinery/door_control/proc/handle_door()
	for(var/obj/machinery/door/airlock/D in range(range))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				if (D.density)
					D.open()
				else
					D.close()
			if(desiredstate == 1)
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = 1
				if(specialfunctions & BOLTS)
					D.lock()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = -1
				if(specialfunctions & SAFE)
					D.safe = 0
			else
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = 0
				if(specialfunctions & BOLTS)
					if(!D.wires.is_cut(WIRE_BOLTS) && D.hasPower())
						D.unlock()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = 0
				if(specialfunctions & SAFE)
					D.safe = 1

/obj/machinery/door_control/proc/handle_pod()
	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == id)
			if(M.density)
				M.open()
			else
				M.close()

/obj/machinery/door_control/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(user,/mob/living/carbon/xenomorph))
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("[src] doesn't seem to be working."))
		return

	if(!allowed(user))
		to_chat(user, span_warning("Access Denied"))
		if(directional)
			flick("doorctrl-denied",src)
		if(!directional) //nondirectional door controls use the old door denied sprites
			flick("olddoorctrl-denied",src)
		return

	use_power(active_power_usage)
	pressed = TRUE
	update_icon()

	switch(normaldoorcontrol)
		if(CONTROL_NORMAL_DOORS)
			handle_door()
		if(CONTROL_POD_DOORS)
			handle_pod()

	desiredstate = !desiredstate
	addtimer(CALLBACK(src, .proc/unpress), 15, TIMER_OVERRIDE|TIMER_UNIQUE)


/obj/machinery/door_control/attack_ai(mob/living/silicon/ai/AI)
	return attack_hand(AI)


/obj/machinery/door_control/proc/unpress()
	pressed = FALSE
	update_icon()

/obj/machinery/door_control/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "doorctrl-p"
	else if(pressed)
		icon_state = "doorctrl1"
	else
		icon_state = "doorctrl0"

/obj/machinery/driver_button/attack_ai(mob/living/silicon/ai/AI)
	return attack_hand(AI)


/obj/machinery/driver_button/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/detective_scanner))
		return
	else
		return attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(active_power_usage)

	active = TRUE
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == id)
			M.open()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id == id)
			M.close()

	icon_state = "launcherbtt"
	active = 0

//mainship door controls
/obj/machinery/door_control/mainship/ammo
	name = "Ammunition Storage"
	id = "ammo2"
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LEADER, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP)

/obj/machinery/door_control/mainship/droppod
	name = "Droppod bay"
	id = "droppod"
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LEADER, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP)

/obj/machinery/door_control/mainship/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)

/obj/machinery/door_control/mainship/medbay
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/machinery/door_control/mainship/fuel
	name = "Solid Fuel Storage"
	id = "solid_fuel"

/obj/machinery/door_control/mainship/hangar
	name = "Hangar Shutters"
	id = "hangar_shutters"

/obj/machinery/door_control/mainship/research
	name = "Medical Research Wing"
	id = "researchdoorext"
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/door_control/mainship/research/lockdown
	name = "Research Lockdown"
	id = "researchlockdownext"

/obj/machinery/door_control/mainship/brigarmory
	name = "Brig Armory"
	id = "brig_armory"
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door_control/mainship/checkpoint
	name = "Checkpoint Shutters"
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIG, ACCESS_MARINE_LEADER, ACCESS_MARINE_BRIDGE)

/obj/machinery/door_control/mainship/checkpoint/north
	id = "northcheckpoint"

/obj/machinery/door_control/mainship/checkpoint/south
	id = "southcheckpoint"

/obj/machinery/door_control/mainship/cic
	name = "CIC Lockdown"
	id = "cic_lockdown"
	req_one_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door_control/mainship/cic/rebel
	id = "cic_lockdown_rebel"
	req_one_access = list(ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/door_control/mainship/cic/armory
	name = "Armory Lockdown"
	id = "cic_armory"

/obj/machinery/door_control/mainship/cic/armory/rebel
	id = "cic_armory_armory"
	req_one_access = list(ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/door_control/mainship/cic/hangar
	name = "Hangar Lockdown"
	id = "hangar_lockdown"

/obj/machinery/door_control/mainship/mech
	name = "Mech Shutter"
	id = "mech_shutters"
  req_one_access = list(ACCESS_MARINE_MECH)

/obj/machinery/door_control/mainship/tcomms
	name = "Telecommunications Entrance"
	id = "tcomms"
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE)

/obj/machinery/door_control/mainship/tcomms/rebel
	id = "tcomms_rebel"
	req_one_access = list(ACCESS_MARINE_ENGINEERING_REBEL, ACCESS_MARINE_LOGISTICS_REBEL, ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/door_control/mainship/engineering/armory
	name = "Engineering Armory Lockdown"
	id = "engi_armory"
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE)


/obj/machinery/door_control/mainship/corporate
	name = "Privacy Shutters"
	id = "cl_shutters"
	req_access = list(ACCESS_NT_CORPORATE)

/obj/machinery/door_control/mainship/req
	name = "RO Line Shutters"
	id = "ROlobby"
	req_one_access = list(ACCESS_MARINE_CARGO, ACCESS_MARINE_LOGISTICS)

/obj/machinery/door_control/mainship/req/rebel
	id = "ROlobby_rebel"
	req_one_access = list(ACCESS_MARINE_CARGO_REBEL, ACCESS_MARINE_LOGISTICS_REBEL)

/obj/machinery/door_control/mainship/req/ro1
	name = "RO Line 1 Shutters"
	id = "ROlobby1"

/obj/machinery/door_control/mainship/req/ro2
	name = "RO Line 2 Shutters"
	id = "ROlobby2"

/obj/machinery/door_control/directional
	name = "autodirection door control"

/obj/machinery/door_control/directional/unmeltable
	resistance_flags = RESIST_ALL

/obj/machinery/door_control/old //sometimes we need a button that has the appearance of the old button and isn't initialized to an x or y value
	icon_state = "olddoorctrl0"
	directional = FALSE

/obj/machinery/door_control/old/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "olddoorctrl-p"
	else if(pressed)
		icon_state = "olddoorctrl1"
	else
		icon_state = "olddoorctrl0"

/obj/machinery/door_control/old/req
	name = "RO Line Shutters"
	id = "ROlobby"
	req_one_access = list(ACCESS_MARINE_CARGO, ACCESS_MARINE_LOGISTICS)

/obj/machinery/door_control/old/valhalla
	name = "RO Line Shutters"
	id = "valhalla"

/obj/machinery/door_control/old/rebel
	name = "RO Line Shutters"
	id = "ROlobby_rebel"
	req_one_access = list(ACCESS_MARINE_CARGO_REBEL, ACCESS_MARINE_LOGISTICS_REBEL)

/obj/machinery/door_control/old/cic
	name = "CIC Lockdown"
	id = "cic_lockdown"
	req_one_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door_control/old/cic/rebel
	name = "CIC Lockdown"
	id = "cic_lockdown"
	req_one_access = list(ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/door_control/old/cic/hangar
	name = "Hangar Lockdown"
	id = "hangar_lockdown"

/obj/machinery/door_control/old/cic/hangar_shutters
	id = "hangar_shutters"
	name = "Hangar Shutters"

/obj/machinery/door_control/old/cic/armory
	name = "Armory Lockdown"
	id = "cic_armory"

/obj/machinery/door_control/old/cic/armory/rebel
	id = "cic_armory_armory"
	req_one_access = list(ACCESS_MARINE_BRIDGE_REBEL)

/obj/machinery/door_control/old/medbay
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/machinery/door_control/old/checkpoint
	name = "Checkpoint Shutters"
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIG, ACCESS_MARINE_LEADER, ACCESS_MARINE_BRIDGE)

/obj/machinery/door_control/old/checkpoint/north
	id = "northcheckpoint"

/obj/machinery/door_control/old/checkpoint/south
	id = "southcheckpoint"

/obj/machinery/door_control/old/ai
	id = "AiCoreShutter"

/obj/machinery/door_control/old/unmeltable
	resistance_flags = RESIST_ALL
