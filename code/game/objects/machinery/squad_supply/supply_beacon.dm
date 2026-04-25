/obj/item/supply_beacon
	name = "supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon = 'icons/obj/items/beacon.dmi'
	icon_state = "motion_0"
	w_class = WEIGHT_CLASS_SMALL
	///Var for the window pop-up
	var/datum/supply_ui/requests/supply_interface

/obj/item/supply_beacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/beacon, TRUE, 60, "motion_2")

/obj/item/supply_beacon/examine(mob/user)
	. = ..()
	. += span_notice("Right-Click with empty hand when anchored to open requisitions interface.")

/obj/item/supply_beacon/attack_hand_alternate(mob/living/user)
	if(!allowed(user) || !anchored)
		return ..()
	if(!supply_interface)
		supply_interface = new(src)

	return supply_interface.interact(user)
