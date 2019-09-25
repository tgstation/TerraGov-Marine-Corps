/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 3
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
			to_chat(user, "<span class='warning'>It appears to be broken.</span>")
			return
		
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied</span>")
			return

		locked = !locked
		if(locked)
			icon_state = icon_locked
			to_chat(user, "<span class='warning'>You lock the [src]!</span>")
		else
			icon_state = icon_closed
			to_chat(user, "<span class='warning'>You unlock the [src]!</span>")

	if(locked)
		to_chat(user, "<span class='warning'>Its locked!</span>")
		return

	return ..()


/obj/item/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>Its locked!</span>")
		return

	return ..()


/obj/item/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_MARINE_BRIG)


/obj/item/storage/lockbox/clusterbang/Initialize()
	. = ..()
	new /obj/item/explosive/grenade/flashbang/clusterbang(src)
