/obj/machinery/door/poddoor
	name = "\improper Podlock"
	desc = "That looks like it doesn't open easily."
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	soft_armor = list("melee" = 50, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	layer = PODDOOR_OPEN_LAYER
	open_layer = PODDOOR_OPEN_LAYER
	closed_layer = PODDOOR_CLOSED_LAYER
	obj_flags = NONE
	explosion_block = 6


/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(!density)
		return ..()
	else
		return FALSE


/obj/machinery/door/poddoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/poddoor/update_icon()
	if(density)
		icon_state = "pdoor1"
	else
		icon_state = "pdoor0"

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("pdoorc0", src)
		if("closing")
			flick("pdoorc1", src)
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)
	return

/obj/machinery/door/poddoor/open
	density = FALSE
	opacity = FALSE
	icon_state = "pdoor0"

/obj/machinery/door/poddoor/open/bridge
	name = "Bridge Blast Doors"
	id = "bridge blast"

/obj/machinery/door/poddoor/open/sb
	name = "Blast Doors"
	id = "sb blast"

/obj/machinery/door/poddoor/open/port
	name = "Blast Doors"
	id = "port blast"

/obj/machinery/door/poddoor/open/engine
	name = "Engine Room Blast Door"
	id = "EngineBlast"

/obj/machinery/door/poddoor/open/security
	name = "Security Blast Door"
	id = "Secure Gate"

/obj/machinery/door/poddoor/open/isolation
	name = "Isolation Cell Lockdown"
	id = "IsoLock"

/obj/machinery/door/poddoor/open/east
	name = "Blast Door"
	id = "eastblast"

/obj/machinery/door/poddoor/telecomms
	name = "Telecomms Emergency Window"
	id = "tcomwind"
	opacity = FALSE

/obj/machinery/door/poddoor/two_tile_hor
	icon = 'icons/obj/doors/1x2blast_hor.dmi'
	dir = EAST
	width = 2
	resistance_flags = UNACIDABLE

/obj/machinery/door/poddoor/two_tile_hor/execution
	icon_state = "pdoor0"
	density = FALSE
	opacity = FALSE
	id = "execution"

/obj/machinery/door/poddoor/two_tile_hor/rocinante
	name = "Rocinante Cargo Bay Door"
	icon_state = "pdoor0"
	density = FALSE
	opacity = FALSE
	id = "pirate_cargo"

/obj/machinery/door/poddoor/two_tile_hor/secure
	icon = 'icons/obj/doors/1x2blast_hor.dmi'
	openspeed = 17
	resistance_flags = RESIST_ALL

/obj/machinery/door/poddoor/two_tile_ver
	icon = 'icons/obj/doors/1x2blast_vert.dmi'
	dir = NORTH
	width = 2
	resistance_flags = UNACIDABLE

/obj/machinery/door/poddoor/two_tile_ver/riotarmory
	icon_state = "pdoor0"
	density = FALSE
	opacity = FALSE
	id = "riot_armory"

/obj/machinery/door/poddoor/two_tile_ver/lethalarmory
	icon_state = "pdoor0"
	density = FALSE
	opacity = FALSE
	id = "lethal_armory"

/obj/machinery/door/poddoor/two_tile_ver/secure
	icon = 'icons/obj/doors/1x2blast_vert.dmi'
	openspeed = 17
	resistance_flags = RESIST_ALL

/obj/machinery/door/poddoor/four_tile_hor
	icon = 'icons/obj/doors/1x4blast_hor.dmi'
	dir = EAST
	width = 4
	resistance_flags = UNACIDABLE

/obj/machinery/door/poddoor/four_tile_hor/secure
	icon = 'icons/obj/doors/1x4blast_hor_secure.dmi'
	openspeed = 17
	resistance_flags = RESIST_ALL

/obj/machinery/door/poddoor/four_tile_ver
	icon = 'icons/obj/doors/1x4blast_vert.dmi'
	dir = NORTH
	width = 4
	resistance_flags = UNACIDABLE

/obj/machinery/door/poddoor/four_tile_ver/secure
	icon = 'icons/obj/doors/1x4blast_vert_secure.dmi'
	openspeed = 17
	resistance_flags = RESIST_ALL

//mainship poddoors
/obj/machinery/door/poddoor/mainship
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/closed/wall,
		/obj/structure/window/framed/mainship,
		/obj/machinery/door/airlock)

/obj/machinery/door/poddoor/mainship/open
    density = FALSE
    opacity = FALSE
    layer = PODDOOR_OPEN_LAYER
    icon_state = "pdoor0"


/obj/machinery/door/poddoor/mainship/ai
	name = "\improper AI Core Shutters"
	icon_state = "pdoor0"

/obj/machinery/door/poddoor/mainship/ai/exterior
	name = "\improper AI Core Shutters"
	id = "ailockdownexterior"
	icon_state = "pdoor0"

/obj/machinery/door/poddoor/mainship/ai/interior
	name = "\improper AI Core Shutters"
	id = "ailockdowninterior"
	icon_state = "pdoor0"

/obj/machinery/door/poddoor/mainship/ammo
	name = "\improper Ammunition Storage"
	id = "ammo2"	

/obj/machinery/door/poddoor/mainship/open/cic
	name = "\improper Combat Information Center Blast Door"
	id = "cic_lockdown"

/obj/machinery/door/poddooor/mainship/hangar
	name = "\improper Hangar Lockdown"
	id = "hangar_lockdown"	

/obj/machinery/door/poddoor/mainship/Initialize()
	relativewall_neighbours()
	return ..()


/obj/machinery/door/poddoor/mainship/umbilical
	name = "Umbilical Airlock"
	resistance_flags = RESIST_ALL


/obj/machinery/door/poddoor/mainship/umbilical/north
	id = "n_umbilical"


/obj/machinery/door/poddoor/mainship/umbilical/south
	id = "s_umbilical"


/obj/machinery/door/poddoor/mainship/indestructible
	resistance_flags = RESIST_ALL


/obj/machinery/door/poddoor/timed_late
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	name = "Timed Emergency Shutters"
	use_power = FALSE


/obj/machinery/door/poddoor/timed_late/Initialize()
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH), .proc/open)
	return ..()


/obj/machinery/door/poddoor/timed_late/containment
	name = "Containment shutters"
	desc = "Safety shutters triggered by some kind of lockdown event."
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	open_layer = UNDER_TURF_LAYER //No longer needs to be interacted with.
	closed_layer = ABOVE_WINDOW_LAYER //Higher than usual, this is only around on the start of the round.


/obj/machinery/door/poddoor/timed_late/containment/landing_zone
	id = "landing_zone"


/obj/machinery/door/poddoor/timed_late/containment/landing_zone/lz2
	id = "landing_zone_2"
