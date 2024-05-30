/** Storage modules */
/obj/item/vehicle_module/storage
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_is_bag"
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

/obj/item/vehicle_module/storage/motorbike
	name = "internal storage"
	desc = "A set of handy compartments to store things in."
	icon_state = ""
	storage_type = /datum/storage/internal/motorbike_pack
	attach_features_flags = NONE
