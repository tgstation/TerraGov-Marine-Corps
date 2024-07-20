/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY

/obj/item/key/atv
	name = "ATV key"
	desc = "A small grey key for starting and operating ATVs."

/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/item/key/door
	name = "door key"
	desc = "Used for unlocking locked doors. Or locking unlocked doors."
	///ID for un/locking locks that match this string; override on a child key to make it start out compatible with certain locks
	var/personal_lock_id = ""

/obj/item/key/door/Initialize(mapload, unique_id)
	. = ..()
	if(unique_id)
		personal_lock_id = unique_id

/obj/item/key/door/examine(mob/user)
	. = ..()
	if(personal_lock_id)
		. += span_notice("It has [span_bold(personal_lock_id)] engraved on it.")
	else
		. += span_warning("It can be paired with a lock.")
