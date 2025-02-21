/obj/item/supply_beacon
	name = "supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon = 'icons/obj/items/beacon.dmi'
	icon_state = "motion_0"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/supply_beacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/beacon, TRUE, 60, "motion_2")
