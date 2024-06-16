/obj/item/vehicle_module/storage
	icon = 'icons/obj/vehicles.dmi'
	icon_state = ""
	slot = ATTACHMENT_SLOT_STORAGE
	w_class = WEIGHT_CLASS_BULKY
	///Determines what subtype of storage is on our item, see datums\storage\subtypes
	var/datum/storage/storage_type = /datum/storage

/obj/item/vehicle_module/storage/Initialize(mapload)
	. = ..()
	create_storage(storage_type)
	PopulateContents()

/obj/item/vehicle_module/storage/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	storage_datum.register_storage_signals(attaching_to)

/obj/item/vehicle_module/storage/on_detach(obj/item/detaching_from, mob/user)
	storage_datum.unregister_storage_signals(detaching_from)
	return ..()

/obj/item/vehicle_module/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return loc.Adjacent(neighbor, target, mover)

///Use this to fill your storage with items. USE THIS INSTEAD OF NEW/INIT
/obj/item/vehicle_module/storage/proc/PopulateContents()
	return
