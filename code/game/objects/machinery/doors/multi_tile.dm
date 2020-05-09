//Terribly sorry for the code doubling, but things go derpy otherwise.
/obj/machinery/door/airlock/multi_tile
	width = 2

/obj/machinery/door/airlock/multi_tile/close() //Nasty as hell O(n^2) code but unfortunately necessary
	for(var/turf/T in locs)
		for(var/obj/vehicle/multitile/M in T)
			if(M) return FALSE

	return ..()

/obj/machinery/door/airlock/multi_tile/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Door2x1glass.dmi'
	opacity = FALSE
	glass = TRUE
	assembly_type = /obj/structure/door_assembly/multi_tile


/obj/machinery/door/airlock/multi_tile/security
	name = "Security Airlock"
	icon = 'icons/obj/doors/Door2x1security.dmi'
	opacity = FALSE
	glass = TRUE


/obj/machinery/door/airlock/multi_tile/command
	name = "Command Airlock"
	icon = 'icons/obj/doors/Door2x1command.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/medical
	name = "Medical Airlock"
	icon = 'icons/obj/doors/Door2x1medbay.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/engineering
	name = "Engineering Airlock"
	icon = 'icons/obj/doors/Door2x1engine.dmi'
	opacity = FALSE
	glass = TRUE


/obj/machinery/door/airlock/multi_tile/research
	name = "Research Airlock"
	icon = 'icons/obj/doors/Door2x1research.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/secure
	name = "Secure Airlock"
	icon = 'icons/obj/doors/Door2x1_secure.dmi'
	openspeed = 34

/obj/machinery/door/airlock/multi_tile/secure2
	name = "Secure Airlock"
	icon = 'icons/obj/doors/Door2x1_secure2.dmi'
	openspeed = 31
	req_access = null

/obj/machinery/door/airlock/multi_tile/secure2_glass
	name = "Secure Airlock"
	icon = 'icons/obj/doors/Door2x1_secure2_glass.dmi'
	opacity = FALSE
	glass = TRUE
	openspeed = 31
	req_access = null





// MARINE MAIN SHIP

/obj/machinery/door/airlock/multi_tile/mainship
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/closed/wall,
		/obj/structure/window/framed/mainship,
		/obj/machinery/door/airlock)

/obj/machinery/door/airlock/multi_tile/mainship/generic
	name = "\improper Airlock"
	icon = 'icons/obj/doors/mainship/2x1generic.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/generic/canteen
	name = "\improper Canteen"

/obj/machinery/door/airlock/multi_tile/mainship/generic/cryo
	name = "\improper Cryogenics Bay"	

/obj/machinery/door/airlock/multi_tile/mainship/generic/garden
	name = "\improper Garden"	

/obj/machinery/door/airlock/multi_tile/mainship/medidoor
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/mainship/2x1medidoor.dmi'
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/medidoor/medbay
	name = "\improper Medical Bay"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/machinery/door/airlock/multi_tile/mainship/research
	name = "\improper Research Airlock"
	icon = 'icons/obj/doors/mainship/2x1medidoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/door/airlock/multi_tile/mainship/comdoor
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/mainship/2x1comdoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/airlock/multi_tile/mainship/comdoor/free_access
	req_access = null

/obj/machinery/door/airlock/multi_tile/mainship/comdoor/cargopads
	name = "\improper Cargo Pads"
	req_access = list(ACCESS_NT_CORPORATE)

/obj/machinery/door/airlock/multi_tile/mainship/secdoor
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/mainship/2x1secdoor.dmi'
	opacity = FALSE
	glass = TRUE
	req_access = list(ACCESS_MARINE_BRIG)


/obj/machinery/door/airlock/multi_tile/mainship/handle_multidoor()
	if(!(width > 1)) return //Bubblewrap

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			T.set_opacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			T.set_opacity(opacity)

	if(dir in list(NORTH, SOUTH))
		bound_height = world.icon_size * width
	else if(dir in list(EAST, WEST))
		bound_width = world.icon_size * width

//We have to find these again since these doors are used on shuttles a lot so the turfs changes
/obj/machinery/door/airlock/multi_tile/mainship/proc/update_filler_turfs()

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) T.set_opacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) T.set_opacity(opacity)

/obj/machinery/door/airlock/multi_tile/mainship/proc/get_filler_turfs()
	var/list/filler_turfs = list()
	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) filler_turfs += T
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) filler_turfs += T
	return filler_turfs

/obj/machinery/door/airlock/multi_tile/mainship/open()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/mainship/close()
	. = ..()
	update_filler_turfs()

//------Dropship Cargo Doors -----//

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear
	opacity = TRUE
	width = 3
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	no_panel = TRUE
	not_weldable = TRUE

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/proc/lockdown()
	unlock()
	close()
	lock()

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/proc/release()
	unlock()

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/ex_act(severity)
	return

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/close(forced=0)
	if(forced)
		for(var/turf/T in get_filler_turfs())
			for(var/mob/living/L in T)
				step(L, pick(NORTH,SOUTH)) // bump them off the tile
		safe = FALSE // in case anyone tries to run into the closing door~
		..()
		safe = TRUE // without having to rewrite closing proc~spookydonut
	else
		..()

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/ds1
	name = "\improper Alamo cargo door"
	icon = 'icons/obj/doors/mainship/dropship1_cargo.dmi'

/obj/machinery/door/airlock/multi_tile/mainship/dropshiprear/ds2
	name = "\improper Normandy cargo door"
	icon = 'icons/obj/doors/mainship/dropship2_cargo.dmi'


//nice colony colony entrance
/obj/machinery/door/airlock/multi_tile/ice
	name = "ice colony door"
	icon = 'icons/obj/doors/icecolony.dmi'
	icon_state = "door_closed"
	width = 4
	openspeed = 17
	no_panel = TRUE
	opacity = TRUE
