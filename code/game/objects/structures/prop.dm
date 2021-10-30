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
	desc = "Cold launch tubes that can fire a few varieties of missiles out of them The most common being the ASAT-21 Rapier IV missile used against satellites and other spacecraft and the BGM-227 Sledgehammer missile which is used for ground attack."
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
		to_chat(user, "[span_notice("To our fallen soldiers:")] <b>[faltext]</b>.")


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
