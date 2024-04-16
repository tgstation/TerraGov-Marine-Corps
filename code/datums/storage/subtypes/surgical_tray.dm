/datum/storage/surgical_tray
	storage_slots = 12
	max_storage_space = 24

/datum/storage/surgical_tray/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(/obj/item/tool/surgery, /obj/item/stack/nanopaste,))
