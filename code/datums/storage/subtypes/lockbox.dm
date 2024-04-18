/datum/storage/lockbox
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 14
	storage_slots = 4

/datum/storage/lockbox/show_to(mob/user)
	var/obj/item/storage/lockbox/parent_box = parent
	if(parent_box.locked)
		to_chat(user, span_warning("Its locked!"))
		return

	return ..()
