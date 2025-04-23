
/obj/structure/supply_drop
	name = "Supply Drop Pad"
	desc = "Place unanchored supplies on here to allow bridge Overwatch officers to drop them on people's heads."
	icon = 'icons/turf/decals.dmi'
	icon_state = "stripe_box_thick"
	anchored = TRUE
	density = FALSE
	resistance_flags = RESIST_ALL
	layer = ABOVE_NORMAL_TURF_LAYER
	faction = FACTION_TERRAGOV

/obj/structure/supply_drop/Initialize(mapload)
	. = ..()
	GLOB.supply_pad_list += src

/obj/structure/supply_drop/Destroy()
	GLOB.supply_pad_list -= src
	return ..()

