//----- Marine ship machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.



//----- Marine ship props -----//
//Put any props that don't function properly, they could function in the future but for now are for looks. This system could be expanded for other maps too. ~Art

/obj/item/prop/mainship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P03' IF SEEN IN ROUND WITH LOCATION"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "hangarbox"

/obj/machinery/prop/mainship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P01' IF SEEN IN ROUND WITH LOCATION"
	coverage = 15

/obj/machinery/prop/mainship/hangar/dropship_part_fabricator

/obj/machinery/prop/mainship/computer/PC
	name = "personal desktop"
	desc = "A small computer hooked up into the ship's computer network."
	icon_state = "terminal1"

/obj/machinery/prop/mainship/computer
	name = "systems computer"
	desc = "A small computer hooked up into the ship's systems."

	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20

	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "terminal"

/obj/machinery/prop/mainship/computer/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				set_broken()
		if(EXPLODE_LIGHT)
			if (prob(25))
				set_broken()


/obj/machinery/prop/mainship/computer/proc/set_broken()
	machine_stat |= BROKEN
	update_icon()

/obj/machinery/prop/mainship/computer/update_icon_state()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	if(machine_stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"


//Nonpower using props

/obj/structure/prop/mainship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P02' IF SEEN IN ROUND WITH LOCATION"
	density = TRUE
	anchored = TRUE
	coverage = 15

/obj/structure/prop/mainship/minigun_crate
	name = "30mm ammo crate"
	desc = "A crate full of 30mm bullets used on one of the weapon pod types for the dropship. Moving this will require some sort of lifter."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "30mm_crate"


/obj/structure/prop/mainship/mission_planning_system
	name = "\improper MPS IV computer"
	desc = "The Mission Planning System IV (MPS IV), a enhancement in mission planning and charting for dropship pilots across the TGMC. Fully capable of customizing their flight paths and loadouts to suit their combat needs."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "mps"

/obj/structure/prop/mainship/mapping_computer
	name = "\improper CMPS II computer"
	desc = "The Common Mapping Production System version II allows for sensory imput from satellites and ship systems to derive planetary maps in a standardized fashion for all TGMC pilots."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "mapping_comp"

/obj/structure/prop/mainship/sensor_computer1
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sensor_comp1"

/obj/structure/prop/mainship/sensor_computer1/sd
	name = "self destruct status computer"

/obj/structure/prop/mainship/sensor_computer2
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sensor_comp2"

/obj/structure/prop/mainship/sensor_computer2/sd
	name = "self destruct regulator"

/obj/structure/prop/mainship/sensor_computer3
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sensor_comp3"

/obj/structure/prop/mainship/sensor_computer3/sd
	name = "tempature regulator"

/obj/structure/prop/mainship/missile_tube
	name = "\improper Mk 33 ASAT launcher system"
	desc = "Cold launch tubes that can fire a few varieties of missiles out of them The most common being the ASAAR-21 Rapier IV missile used against satellites and other spacecraft and the BGM-227 Sledgehammer missile which is used for ground attack."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "missiletubenorth"
	bound_width = 32
	bound_height = 96
	resistance_flags = UNACIDABLE


/obj/structure/prop/mainship/ship_memorial
	name = "slab of victory"
	desc = "A ship memorial dedicated to the triumphs of the TGMC and the fallen marines of this ship. On the left there are grand tales of victory etched into the slab. On the right there is a list of famous marines who have fallen in combat serving the TGMC."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "ship_memorial"
	bound_width = 64
	bound_height = 32
	resistance_flags = UNACIDABLE
	throwpass = FALSE
	var/list/fallen_list

/obj/structure/prop/mainship/ship_memorial/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/dogtag))
		var/obj/item/dogtag/D = I
		if(D.fallen_names)
			to_chat(user, span_notice("You add [D] to [src]."))
			if(!fallen_list)
				fallen_list = list()
			fallen_list += D.fallen_names
			qdel(D)
		return TRUE
	else
		. = ..()

/obj/structure/prop/mainship/ship_memorial/examine(mob/user)
	. = ..()
	if((isobserver(user) || ishuman(user)) && fallen_list)
		var/faltext = ""
		for(var/i = 1 to fallen_list.len)
			if(i != fallen_list.len)
				faltext += "[fallen_list[i]], "
			else
				faltext += fallen_list[i]
		. += "[span_notice("To our fallen soldiers:")] <b>[faltext]</b>."


/obj/structure/prop/mainship/particle_cannon
	name = "\improper 75cm/140 Mark 74 General Atomics railgun"
	desc = "The Mark 74 Railgun is top of the line for space based weaponry. Capable of firing a round with a diameter of 3/4ths of a meter at 24 kilometers per second. It also is capable of using a variety of round types which can be interchanged at anytime with its newly designed feed system."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "1"
	resistance_flags = UNACIDABLE


/obj/structure/prop/mainship/name_stencil
	name = "\improper The TGMC, a TGMC-Class Marine Carrier Arsenal Ship"
	desc = "The name of the ship stenciled on the hull."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "TGMC1"
	density = FALSE
	resistance_flags = UNACIDABLE
	layer = ABOVE_TURF_LAYER

/obj/structure/prop/mainship/name_stencil/Initialize()
	. = ..()
	name = SSmapping.configs[SHIP_MAP].map_name


/obj/structure/prop/mainship/hangar_stencil
	name = "floor"
	desc = "A large number stenciled on the hangar floor used to designate which dropship it is."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "dropship1"
	density = FALSE
	layer = ABOVE_TURF_LAYER

/obj/structure/prop/mainship/hangar_stencil/two
	icon_state = "dropship2"

/obj/structure/prop/mainship/brokengen //all the aesthetics of having a generator without any of the function
	name = "\improper G-11 geothermal generator"
	desc = "A thermoelectric generator sitting atop a plasma-filled borehole. The powercell is missing and strange lines of text scroll by on its status panel, you get the feeling there's no fixing it."
	icon = 'icons/turf/geothermal.dmi'
	icon_state = "destroyedgen"
	resistance_flags = RESIST_ALL //normal generators can't be destroyed, so for appearances our fake ones can't be destroyed either.

/obj/structure/prop/mainship/cannon_cables
	name = "\improper Cannon cables"
	desc = "Some large cables."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "cannon_cables"
	density = FALSE
	mouse_opacity = 0
	layer = LADDER_LAYER

/obj/structure/prop/mainship/supermatter //functionally inert, but will consume mobs and objects
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "darkmatter"
	layer = LADDER_LAYER
	light_range = 4
	resistance_flags = RESIST_ALL //no delaminations here


/obj/structure/prop/mainship/supermatter/proc/consume(atom/movable/consumed_object) //dust() and destroy living mobs, qdel thrown objects
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		consumed_mob.dust() //dust() plays a dusting animation and sets the mob to dead
	else if(isobj(consumed_object))
		qdel(consumed_object) //we cannot dust() objects so we just delete them

/obj/structure/prop/mainship/supermatter/Bumped(atom/movable/hit_object)
	if(isliving(hit_object)) //living objects get a nifty message about heat
		hit_object.visible_message(span_danger("\The [hit_object] slams into \the [src] inducing a resonance... [hit_object.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [src] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(hit_object) //all bumped objects get consume() called on them

/obj/structure/prop/mainship/radiationcollector
	name = "Radiation Collector Array"
	desc = "A device which uses radiation and plasma to produce power."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "radcollector"
	layer = LADDER_LAYER
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/invincibleshutter
	name = "\improper heavy shutters"
	desc = "A heavy set of blast resistant shutters."
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	icon_state = "shutter1"
	density = TRUE
	layer = LADDER_LAYER
	light_range = 4
	resistance_flags = RESIST_ALL //no delaminations here

/obj/structure/prop/mainship/doorblocker //doors that exist only to block access, used mostly for valhalla omegastation
	name = "\improper Barred Airlock"
	icon = 'icons/Marine/mainship_props.dmi'
	resistance_flags = RESIST_ALL
	desc = "It opens and closes."

/obj/structure/prop/mainship/doorblocker/maint
	name = "\improper Maintenance Hatch"
	icon_state = "maint_locked"

/obj/structure/prop/mainship/doorblocker/external
	name = "\improper External Airlock"
	icon_state = "exit_locked"

/obj/structure/prop/mainship/doorblocker/engi
	name = "\improper External Airlock"
	icon_state = "engi_locked"

/obj/structure/prop/mainship/doorblocker/evac
	name = "\improper Evacuation Airlock"
	icon_state = "secure_locked"

/obj/structure/prop/mainship/doorblocker/command
	name = "\improper Command Airlock"
	icon_state = "command_locked"

/obj/structure/prop/mainship/telecomms
	name = "\improper Command Airlock"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "broadcaster_send"

/obj/structure/prop/mainship/telecomms/bus
	name = "\improper Command Airlock"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bus"

/obj/structure/prop/mainship/suit_storage_prop
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\". This one appears to be magnetically locked."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "suitstorageclose"

/obj/structure/prop/mainship/protolathe
	name = "Suit Storage Unit"
	desc = "A giant machine for processing data and producing department specific tools. A small warning light labeled 'server connection' is flashing red"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"

/obj/structure/prop/mainship/protolathe/engi
	name = "Engineering Protolathe"

/obj/structure/prop/mainship/protolathe/sci
	name = "Research Protolathe"

/obj/structure/prop/mainship/protolathe/medical
	name = "Medical Protolathe"

/obj/structure/prop/mainship/protolathe/security
	name = "Security Protolathe"

/obj/structure/prop/mainship/protolathe/service
	name = "Service Protolathe"

/obj/structure/prop/mainship/cannon_cables/ex_act()
	return

/obj/structure/prop/mainship/cannon_cable_connector
	name = "\improper Cannon cable connector"
	desc = "A connector for the large cannon cables."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "cannon_cable_connector"
	density = TRUE

/obj/structure/prop/mainship/cannon_cable_connector/ex_act()
	return

/obj/structure/prop/mainship/propcarp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "carpprop"
	density = TRUE

/obj/structure/prop/templedoor
	name = "Strange Temple"
	icon = 'icons/obj/doors/Doorsand.dmi'
	icon_state = "door_open"
	density = FALSE

/obj/structure/prop/oresilo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the colony's mineral distribution needs. This one appears to be deactivated."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "silo"
	density = TRUE

/obj/structure/prop/mainship/propcarp/Initialize(mapload) //slightly randomize carp to simulate life
	. = ..()
	var/pickedrotate = pick(0,1,2,4,8,10)
	switch(pickedrotate) //prop carp can randomly move two tiles in any direction
		if(0) //1/6th chance of not moving in a random direction
			return
		if(1)
			dir = NORTH
			pixel_y = 64
		if(2)
			dir = SOUTH
			pixel_y = -64
		if(4)
			dir = EAST
			pixel_x = 64
		if(8)
			dir = WEST
			pixel_x = -64
		if(10)
			qdel(src)
		//remember that each carp must have at least 2 free spaces around them per carp, or they'll glitch into walls and/or each other

/obj/structure/prop/mainship/aislipprop
	name = "foam dispenser"
	desc = "A remotely-activatable dispenser for crowd-controlling foam."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "aislipper"
	density = FALSE
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/turretprop
	name = "laser turret"
	desc = "A point-defense laser turret supplied by NanoTrasen. This one looks inactive"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "turretprop"
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/tubeprop
	name = "pneumatic tube"
	desc = "A pneumatic tube commonly used for transportation on NanoTrasen research stations."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "tubeprop"
	resistance_flags = RESIST_ALL
	layer = ABOVE_TURF_LAYER //so our fake prop can visually pass under glass panels

/obj/structure/prop/mainship/tubeprop/decorative
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "decorative"
	resistance_flags = RESIST_ALL
	mouse_opacity = 0

/obj/structure/prop/mainship/meterprop/
	name = "meter"
	desc = "That's a gas flow meter. It measures something."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "propmeterempty"
	resistance_flags = RESIST_ALL
	density = FALSE

/obj/structure/prop/mainship/meterprop/empty
	icon_state = "propmeterempty"

/obj/structure/prop/mainship/meterprop/random
	icon_state = "propmeter"
	var/kpa //fake temperatures and pressures for our meter
	var/kelvin

/obj/structure/prop/mainship/meterprop/random/examine(mob/user)
	. = ..()
	. += span_notice("The pressure gauge reads [kpa] kPa; [kelvin] K ([kelvin - 273.15]°C)") //output fake kelvin and celsius on examine

/obj/structure/prop/mainship/meterprop/empty/examine(mob/user)
	. = ..()
	. += span_notice("The pressure gauge reads 0 kPa; 0 K (-273.15°C)") //output fake kelvin and celsius on examine

/obj/structure/prop/mainship/meterprop/random/Initialize(mapload)
	. = ..()
	kpa = rand(9.3, 21.4)
	kelvin = rand(10.3, 28.4)

/obj/structure/prop/mainship/pipeprop //does not init and so doesn't generate lag at all
	name = "pipe"
	desc = "A one meter section of regular pipe."
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-2"
	density = FALSE
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/structure/prop/mainship/pipeprop/manifold
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-2"

/obj/structure/prop/mainship/pipeprop/pump
	name = "pipe manifold"
	desc = "A pump that moves gas by pressure."
	icon = 'icons/obj/atmospherics/components/binary_devices.dmi'
	icon_state = "pump_map-2"

/obj/structure/prop/mainship/pipeprop/pump/on
	icon_state =  "pump_on"
	layer = GAS_PUMP_LAYER

/obj/structure/prop/mainship/printer
	name = "printer"
	desc = "Machine for printing text or pictures onto paper."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "printer"

/obj/structure/prop/mainship/cashregister
	name = "cash register"
	desc = "Registers cash and calculate transactions."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "register_idle"
	density = FALSE

/obj/structure/prop/mainship/commstower
	name = "communications tower"
	desc = "A powerful communications tower able to transmit data at great distances"
	icon = 'icons/obj/machines/comm_tower.dmi'
	icon_state = "comm_tower"

//items props

/obj/item/prop
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P03' IF SEEN IN ROUND WITH LOCATION"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "hangarbox"

/obj/item/prop/aimodule
	name = "AI module"
	desc = "An AI Module for programming laws to an AI."
	icon_state = "std_mod"

/obj/item/prop/aimodule/Initialize(mapload)
	. = ..()
	name = pick("'Safeguard' AI Module'",
				"'OneHuman' AI Module",
				"'ProtectStation' AI Module",
				"'Quarantine' AI Module",
				"'OxygenIsToxicToHumans' AI Module",
				"'Freeform' AI Module",
				"\improper 'Remove Law' AI module",
				"\improper 'Reset' AI module",
				"'Purge' AI Module",
				"'Asimov' Core AI Module",
				"'Asimov++' Core AI Module",
				"'Corporate' Core AI Module",
				"'P.A.L.A.D.I.N. version 3.5e' Core AI Module",
				"'T.Y.R.A.N.T.' Core AI Module",
				"'Robo-Officer' Core AI Module",
				"'Antimov' Core AI Module",
				"'Freeform' Core AI Module",
				"'Mother Drone' Core AI Module",
				"'Robodoctor' Core AI Module",
				"'Reportertron' Core AI Module",
				"'Thermodynamic' Core AI Module",
				"'Live And Let Live' Core AI Module",
				"'Guardian of Balance' Core AI Module",
				"'Station Efficiency' Core AI Module",
				"'Peacekeeper' Core AI Module",
				"'H.O.G.A.N.' Core AI Module",
	)

///BROKEN MARINE VENDOR PROPS

/obj/structure/prop/brokenvendor
	name = "\improper Broken vendor"
	icon = 'icons/Marine/mainship_props.dmi'
	desc = "The insides of this vendor are visible and rusted through, you get the feeling there's no fixing this machine."
	density = TRUE

/obj/structure/prop/brokenvendor/brokenweaponsrack
	icon_state = "marinearmory-broken"

/obj/structure/prop/brokenvendor/brokenuniformvendor
	name = "\improper Broken automated uniform closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenuniformvendor/specialist
	name = "\improper Broken specialist equipment rack"
	icon_state = "specialist-broken"
	desc = "You study the rusted hulk in vain trying to determine what this vendor was before realizing that it's hopeless."

/obj/structure/prop/brokenvendor/brokenspecialistvendor/sg
	name = "\improper Broken automated smart gunner closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenspecialistvendor/leader
	name = "\improper Broken automated leader closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenspecialistvendor/corpsman
	name = "\improper Broken automated corpsman closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenspecialistvendor/engineer
	name = "\improper Broken automated engineer closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenmarinemedvendor
	icon_state = "marinemed-broken"

/obj/structure/prop/brokenvendor/brokennanomedvendor
	icon_state = "med-broken"

/obj/structure/prop/brokenvendor/brokencorpsmanvendor
	icon_state = "corpsmanvendor-broken"

/obj/structure/prop/brokenvendor/engivend
	icon_state = "engivend-broken"

/obj/structure/prop/brokenvendor/surplusclothes
	name = "\improper Broken surplus clothes vendor"
	icon_state = "surplus_clothes-broken"

/obj/structure/prop/brokenvendor/surplusarmor
	name = "\improper Broken armor clothes vendor"
	icon_state = "surplus_armor-broken"

///BROKEN VEHICLE PROPS

/obj/structure/prop/vehicle/van
	name = "van"
	desc = "An old van, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "van"
	density = TRUE
	coverage = 70
	bound_height = 32
	bound_width = 64
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/truck
	name = "truck"
	desc = "An old truck, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "truck"
	density = TRUE
	coverage = 70
	bound_height = 32
	bound_width = 64
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/truck/truckcargo
	icon_state = "truck_cargo"

/obj/structure/prop/vehicle/crane
	name = "crane"
	desc = "An old crane, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "crane"
	density = TRUE
	coverage = 70
	bound_height = 64
	bound_width = 64
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/crane/cranecargo
	icon_state = "crane_cargo"

/obj/structure/prop/vehicle/crawler
	name = "crawler"
	desc = "An old crawler, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "crawler"
	density = TRUE
	coverage = 70
	bound_height = 32
	bound_width = 64
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/crawler/crawler_blue
	icon_state = "crawler_crate_b"

/obj/structure/prop/vehicle/crawler/crawler_red
	icon_state = "crawler_crate_r"

/obj/structure/prop/vehicle/crawler/crawler_green
	icon_state = "crawler_crate_g"

/obj/structure/prop/vehicle/crawler/crawler_fuel
	icon_state = "crawler_fuel"

/obj/structure/prop/vehicle/crawler/crawler_cargo
	icon_state = "crawler_cargo"

/obj/structure/prop/vehicle/tank
	name = "Decommissioned TAV - Rhino"
	desc = "A decomissioned tank, all methods of propulsion have been disabled and the entrances sealed."
	icon = 'icons/Marine/tank_propns.dmi'
	icon_state = "tank_complete"
	density = TRUE
	coverage = 80
	bound_height = 128
	bound_width = 128
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/tank/north
	icon = 'icons/Marine/tank_propns.dmi'
	icon_state = "tank_complete"
	bound_height = 128
	bound_width = 96

/obj/structure/prop/vehicle/tank/north/base
	name = "Decommissioned TAV - Rhino"
	desc = "The base of a decomissioned tank."
	icon_state = "tank_base"

/obj/structure/prop/vehicle/tank/north/altnorth
	icon_state = "tank_complete_alt"

/obj/structure/prop/vehicle/tank/east
	icon = 'icons/Marine/tank_propew.dmi'
	icon_state = "tank_complete"
	bound_height = 96
	bound_width = 128

/obj/structure/prop/vehicle/tank/east/base
	name = "Decommissioned TAV - Rhino"
	desc = "The base of a decomissioned tank."
	icon_state = "tank_base"

/obj/structure/prop/vehicle/tank/east/turret
	icon_state = "turret_viper"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/east/turret/complete
	icon_state = "turret_complete"

/obj/structure/prop/vehicle/tank/east/turretalt
	icon_state = "turret_cobra"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/east/barrel
	icon_state = "ltb_cannon_0"
	layer = TANK_BARREL_LAYER
	mouse_opacity = 0

/obj/structure/prop/vehicle/tank/east/barrel/broken
	icon_state = "ltb_cannon_1"

/obj/structure/prop/vehicle/tank/east/barrel/minigun
	icon_state = "ltaaap_minigun_0"

/obj/structure/prop/vehicle/tank/east/barrel/minigunbroken
	icon_state = "ltaaap_minigun_1"

/obj/structure/prop/vehicle/tank/east/alteast
	icon_state = "tank_complete_alt"

/obj/structure/prop/vehicle/tank/east/decoration
	density = FALSE
	mouse_opacity = 0
	layer = TANK_DECORATION_LAYER

/obj/structure/prop/vehicle/tank/east/decoration/treads
	icon_state = "treads_stationary"

/obj/structure/prop/vehicle/tank/east/decoration/damagedtreads
	icon_state = "damaged_hardpt_treads"

/obj/structure/prop/vehicle/tank/east/decoration/armor
	icon_state = "caustic_armor"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/tank/east/decoration/armor/causticarmor
	icon_state = "caustic_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/concussivearmor
	icon_state = "concussive_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/ballisticarmor
	icon_state = "ballistic_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/paladinarmor
	icon_state = "paladin_armor"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpoint
	icon_state = "damaged_hardpt_armor"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointframe
	icon_state = "damaged_hardpt_frame"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointturret
	icon_state = "damaged_hardpt_turret"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointone
	icon_state = "damaged_hardpt_primary"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointtwo
	icon_state = "damaged_hardpt_secondary"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointthree
	icon_state = "damaged_hardpt_support"

/obj/structure/prop/vehicle/tank/east/decoration/slaunchone
	icon_state = "slauncher_0"

/obj/structure/prop/vehicle/tank/east/decoration/slaunchtwo
	icon_state = "slauncher_1"

/obj/structure/prop/vehicle/tank/east/decoration/slaunchthree
	icon_state = "slauncher_2"

/obj/structure/prop/vehicle/tank/east/decoration/driveenhancerone
	icon_state = "odrive_enhancer_1"

/obj/structure/prop/vehicle/tank/east/decoration/driveenhancerzero
	icon_state = "odrive_enhancer_0"

/obj/structure/prop/vehicle/tank/east/decoration/flamer
	icon_state = "flamer_1"

/obj/structure/prop/vehicle/tank/east/decoration/glauncherone
	icon_state = "glauncher_1"

/obj/structure/prop/vehicle/tank/east/decoration/glauncherzero
	icon_state = "glauncher_0"

/obj/structure/prop/vehicle/tank/east/decoration/cupolaone
	icon_state = "m56cupola_1"

/obj/structure/prop/vehicle/tank/east/decoration/cupolazero
	icon_state = "m56cupola_0"

/obj/structure/prop/vehicle/tank/east/decoration/towlauncherone
	icon_state = "towlauncher_1"

/obj/structure/prop/vehicle/tank/east/decoration/towlauncherzero
	icon_state = "towlauncher_0"

/obj/structure/prop/vehicle/tank/east/decoration/warrayone
	icon_state = "warray_1"

/obj/structure/prop/vehicle/tank/east/decoration/warrayzero
	icon_state = "warray_0"

/obj/structure/prop/vehicle/tank/east/decoration/artmodone
	icon_state = "artillerymod_1"

/obj/structure/prop/vehicle/tank/east/decoration/artmodzero
	icon_state = "artillerymod_0"

/obj/structure/prop/vehicle/tank/east/armor/snowplow
	icon_state = "snowplow_0"

/obj/structure/prop/vehicle/tank/east/armor/snowplowone
	icon_state = "snowplow_1"

/obj/structure/prop/vehicle/tank/north/turret
	icon_state = "turret_viper"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/north/turret/complete
	icon_state = "turret_complete"

/obj/structure/prop/vehicle/tank/north/turretalt
	icon_state = "turret_cobra"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/north/barrel
	icon_state = "ltb_cannon_0"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0

/obj/structure/prop/vehicle/tank/north/barrel/broken
	icon_state = "ltb_cannon_1"

/obj/structure/prop/vehicle/tank/north/barrel/minigun
	icon_state = "ltaaap_minigun_0"

/obj/structure/prop/vehicle/tank/north/barrel/minigunbroken
	icon_state = "ltaaap_minigun_1"

/obj/structure/prop/vehicle/tank/north/altnorth
	icon_state = "tank_complete_alt"

/obj/structure/prop/vehicle/tank/north/decoration
	density = FALSE
	mouse_opacity = 0
	layer = TANK_DECORATION_LAYER

/obj/structure/prop/vehicle/tank/north/decoration/treads
	icon_state = "treads_stationary"

/obj/structure/prop/vehicle/tank/north/decoration/damagedtreads
	icon_state = "damaged_hardpt_treads"

/obj/structure/prop/vehicle/tank/north/decoration/armor
	icon_state = "caustic_armor"
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/tank/north/decoration/armor/causticarmor
	icon_state = "caustic_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/concussivearmor
	icon_state = "concussive_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/ballisticarmor
	icon_state = "ballistic_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/paladinarmor
	icon_state = "paladin_armor"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpoint
	icon_state = "damaged_hardpt_armor"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointframe
	icon_state = "damaged_hardpt_frame"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointturret
	icon_state = "damaged_hardpt_turret"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointone
	icon_state = "damaged_hardpt_primary"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointtwo
	icon_state = "damaged_hardpt_secondary"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointthree
	icon_state = "damaged_hardpt_support"

/obj/structure/prop/vehicle/tank/north/decoration/slaunchone
	icon_state = "slauncher_0"

/obj/structure/prop/vehicle/tank/north/decoration/slaunchtwo
	icon_state = "slauncher_1"

/obj/structure/prop/vehicle/tank/north/decoration/slaunchthree
	icon_state = "slauncher_2"

/obj/structure/prop/vehicle/tank/north/decoration/driveenhancerone
	icon_state = "odrive_enhancer_1"

/obj/structure/prop/vehicle/tank/north/decoration/driveenhancerzero
	icon_state = "odrive_enhancer_0"

/obj/structure/prop/vehicle/tank/north/decoration/flamer
	icon_state = "flamer_1"

/obj/structure/prop/vehicle/tank/north/decoration/glauncherone
	icon_state = "glauncher_1"

/obj/structure/prop/vehicle/tank/north/decoration/glauncherzero
	icon_state = "glauncher_0"

/obj/structure/prop/vehicle/tank/north/decoration/cupolaone
	icon_state = "m56cupola_1"

/obj/structure/prop/vehicle/tank/north/decoration/cupolazero
	icon_state = "m56cupola_0"

/obj/structure/prop/vehicle/tank/north/decoration/towlauncherone
	icon_state = "towlauncher_1"

/obj/structure/prop/vehicle/tank/north/decoration/towlauncherzero
	icon_state = "towlauncher_0"

/obj/structure/prop/vehicle/tank/north/decoration/warrayone
	icon_state = "warray_1"

/obj/structure/prop/vehicle/tank/north/decoration/warrayzero
	icon_state = "warray_0"

/obj/structure/prop/vehicle/tank/north/decoration/artmodone
	icon_state = "artillerymod_1"

/obj/structure/prop/vehicle/tank/north/decoration/artmodzero
	icon_state = "artillerymod_0"

/obj/structure/prop/vehicle/tank/north/armor/snowplow
	icon_state = "snowplow_0"

/obj/structure/prop/vehicle/tank/north/armor/snowplowone
	icon_state = "snowplow_1"

/obj/structure/prop/vehicle/apc
	name = "Decommissioned TAV - Athena"
	desc = "A decomissioned APC, all methods of propulsion have been disabled and the entrances sealed."
	icon = 'icons/Marine/apc_prop.dmi'
	icon_state = "apc_base"
	density = TRUE
	coverage = 70
	bound_height = 128
	bound_width = 128
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/vehicle/apc/med
	icon_state = "apc_base_med"

/obj/structure/prop/vehicle/apc/com
	icon_state = "apc_base_com"

/obj/structure/prop/vehicle/apc/wheelszero
	icon_state = "wheels_0"
	layer = TANK_TURRET_LAYER
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/wheelsone
	icon_state = "wheels_1"
	layer = TANK_TURRET_LAYER
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/damagedframe
	icon_state = "damaged_frame"
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/damagedhptone
	icon_state = "damaged_hdpt_primary"
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/damagedhpttwo
	icon_state = "damaged_hdpt_secondary"
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/damagedhpthree
	icon_state = "damaged_hdpt_support"
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/dualcannonzero
	icon_state = "dualcannon_0"
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/dualcannonone
	icon_state = "dualcannon_1"
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/decoration
	icon_state = "frontalcannon_0"
	density = FALSE
	layer = TANK_DECORATION_LAYER
	mouse_opacity = 0

/obj/structure/prop/vehicle/apc/decoration/frontturretzero
	icon_state = "frontalcannon_0"

/obj/structure/prop/vehicle/apc/decoration/frontturretone
	icon_state = "frontalcannon_1"

/obj/structure/prop/vehicle/apc/decoration/freightzero
	icon_state = "freight_0"

/obj/structure/prop/vehicle/apc/decoration/freightone
	icon_state = "freight_1"

/obj/structure/prop/vehicle/apc/decoration/freighttwo
	icon_state = "freight_2"

/obj/structure/prop/vehicle/apc/decoration/freighttwo
	icon_state = "freight_2"

/obj/structure/prop/vehicle/apc/decoration/commsrelayzero
	icon_state = "comms_relay_0"

/obj/structure/prop/vehicle/apc/decoration/commsrelayone
	icon_state = "comms_relay_1"

/obj/structure/prop/vehicle/apc/decoration/flarelauncherzero
	icon_state = "flare_launcher_0"

/obj/structure/prop/vehicle/apc/decoration/flarelauncherone
	icon_state = "flare_launcher_1"

/obj/structure/prop/vehicle/apc/decoration/flarelaunchertwo
	icon_state = "flare_launcher_2"

/obj/structure/prop/vehicle/apc/decoration/emptyfuelcell
	icon_state = "emptyfuelcell"

/obj/structure/prop/vehicle/som_mech
	name = "Marauder Assault Mech"
	desc = "A heavily armed mech used by the SOM to spearhead an assault, this one seems to be non-functional."
	icon = 'icons/Marine/mech_prop.dmi'
	icon_state = "som_mech"
	density = TRUE
	coverage = 70
	bound_width = 64
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER
