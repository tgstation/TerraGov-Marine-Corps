/*!
 * Contains obj/item/storage template
 */

/**
 * When creating a new storage, you may use /obj/item/storage as a template which automates create_storage() on .../Initialize
 * However, this is no longer a hard requirement, since storage is a /datum now
 * Just make sure to pass whatever arguments you need to create_storage() which is an /atom level proc
 * (This means that any atom can have storage :D )
 */
/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage/misc.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/containers_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/containers_right.dmi',
	)
	w_class = WEIGHT_CLASS_NORMAL
	///Determines what subtype of storage is on our item, see datums\storage\subtypes
	var/storage_type = /datum/storage

/obj/item/storage/Initialize(mapload, ...)
	..()
	create_storage(storage_type)
	return INITIALIZE_HINT_LATELOAD

/obj/item/storage/LateInitialize()
	PopulateContents()

///Use this to fill your storage with items. USE THIS INSTEAD OF NEW/INIT
/obj/item/storage/proc/PopulateContents()
	return

/obj/item/storage/update_icon_state()
	. = ..()
	if(!storage_datum?.sprite_slots)
		icon_state = initial(icon_state)
		return

	var/total_weight = 0

	if(!storage_datum.storage_slots)
		for(var/obj/item/i in contents)
			total_weight += i.w_class
		total_weight = ROUND_UP(total_weight / storage_datum.max_storage_space * storage_datum.sprite_slots)
	else
		total_weight = ROUND_UP(length(contents) / storage_datum.storage_slots * storage_datum.sprite_slots)

	if(!total_weight)
		icon_state = initial(icon_state) + "_e"
		return
	if(storage_datum.sprite_slots > total_weight)
		icon_state = initial(icon_state) + "_" + num2text(total_weight)
	else
		icon_state = initial(icon_state)
