
/obj/structure/supply_drop
	name = "Supply Drop Pad"
	desc = "Place unanchored supplies on here to allow bridge Overwatch officers to drop them on people's heads."
	icon = 'icons/effects/warning_stripes.dmi'
	anchored = TRUE
	density = FALSE
	resistance_flags = RESIST_ALL
	layer = ABOVE_TURF_LAYER
	var/squad_name = "Alpha"
	var/sending_package = 0

/obj/structure/supply_drop/Initialize()
	. = ..()
	GLOB.supply_pad_list += src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/supply_drop/LateInitialize(mapload)
	. = ..()
	force_link()

/obj/structure/supply_drop/Destroy()
	GLOB.supply_pad_list += src
	return ..()

/// Proc used to force a connection with the squad
/obj/structure/supply_drop/proc/force_link()
	var/datum/squad/S = SSjob.squads[squad_name]
	if(!S)
		CRASH("Supply pad at [AREACOORD(src)] was unable to init with for squad '[squad_name]'")
	S.drop_pad = src

/obj/structure/supply_drop/alpha
	icon_state = "alphadrop"
	squad_name = "Alpha"

/obj/structure/supply_drop/bravo
	icon_state = "bravodrop"
	squad_name = "Bravo"

/obj/structure/supply_drop/charlie
	icon_state = "charliedrop"
	squad_name = "Charlie"

/obj/structure/supply_drop/delta
	icon_state = "deltadrop"
	squad_name = "Delta"
