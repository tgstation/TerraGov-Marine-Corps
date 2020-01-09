/obj/item/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"


/obj/item/radio/beacon/Initialize()
	. = ..()
	GLOB.beacon_list += src

/obj/item/radio/beacon/Destroy()
	GLOB.beacon_list -= src
	return ..()
