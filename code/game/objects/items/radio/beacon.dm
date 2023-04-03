/obj/item/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	item_state = "signaler"
	var/code = "electronic"


/obj/item/radio/beacon/Initialize()
	. = ..()
	GLOB.beacon_list += src

/obj/item/radio/beacon/Destroy()
	GLOB.beacon_list -= src
	return ..()

/obj/item/radio/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if ((usr.canmove && !( usr.restrained() )))
		src.code = t
	if (!( src.code ))
		src.code = "beacon"
