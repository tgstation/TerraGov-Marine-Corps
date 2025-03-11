/obj/structure/cable/multilayer/multiz //This bridges powernets betwen Z levels
	name = "multi z layer cable hub"
	desc = "A flexible, superconducting insulated multi Z layer hub for heavy-duty multi Z power transfer."
	icon = 'icons/obj/power.dmi'
	icon_state = "cablerelay-on"
	cable_layer = CABLE_LAYER_1|CABLE_LAYER_2|CABLE_LAYER_3
	machinery_layer = null
	resistance_flags = RESIST_ALL //deleting multi-z connectors causes problems, so we don't

/obj/structure/cable/multilayer/multiz/get_cable_connections(powernetless_only)
	. = ..()
	var/turf/T = get_turf(src)
	. +=  locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_BELOW(T))
	. +=  locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_ABOVE(T))

/obj/structure/cable/multilayer/multiz/examine(mob/user)
	. += ..()
	var/turf/T = get_turf(src)
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_BELOW(T)) ? "Detected" : "Undetected"] hub UP.")
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_ABOVE(T)) ? "Detected" : "Undetected"] hub DOWN.")

// no cutting the cable either
/obj/structure/cable/multilayer/multiz/handlecable(obj/item/W, mob/user, params)
	return
