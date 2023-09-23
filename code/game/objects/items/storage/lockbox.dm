/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 14
	storage_slots = 4
	req_access = list(ACCESS_MARINE_CAPTAIN)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


/obj/item/storage/lockbox/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/card/id))
		if(broken)
			to_chat(user, span_warning("It appears to be broken."))
			return

		if(!allowed(user))
			to_chat(user, span_warning("Access Denied"))
			return

		locked = !locked
		if(locked)
			icon_state = icon_locked
			to_chat(user, span_warning("You lock the [src]!"))
		else
			icon_state = icon_closed
			to_chat(user, span_warning("You unlock the [src]!"))

	if(locked)
		to_chat(user, span_warning("Its locked!"))
		return

	return ..()


/obj/item/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, span_warning("Its locked!"))
		return

	return ..()
