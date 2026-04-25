/*!
	Modular armor storage storage attachments
	These are storage attachments that equip into storage slots on modular armor
*/

/** Storage modules */
/obj/item/armor_module/storage
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_is_bag"
	slot = ATTACHMENT_SLOT_STORAGE
	w_class = WEIGHT_CLASS_BULKY
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/style = "")
	///Determines what subtype of storage is on our item, see datums\storage\subtypes
	var/datum/storage/storage_type = /datum/storage
	///If TRUE it will add extra overlays for the items within.
	var/show_storage = FALSE
	///Icon for the extra storage overlays.
	var/show_storage_icon = 'icons/mob/modular/modular_helmet_storage.dmi'

/obj/item/armor_module/storage/Initialize(mapload)
	. = ..()
	create_storage(storage_type)
	PopulateContents()

/obj/item/armor_module/storage/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	equip_delay_self = parent.equip_delay_self
	strip_delay = parent.strip_delay

	storage_datum.register_storage_signals(attaching_to)

/obj/item/armor_module/storage/on_detach(obj/item/detaching_from, mob/user)
	equip_delay_self = initial(equip_delay_self)
	strip_delay = initial(strip_delay)

	storage_datum.unregister_storage_signals(detaching_from)

	return ..()

///Use this to fill your storage with items. USE THIS INSTEAD OF NEW/INIT
/obj/item/armor_module/storage/proc/PopulateContents()
	return

/obj/item/storage/internal/modular
	storage_type = /datum/storage/internal/modular

/* Pockets */
/obj/item/armor_module/storage/pocket
	icon_state = ""
	worn_icon_state = ""
	attach_features_flags = ATTACH_APPLY_ON_MOB
	storage_type = /datum/storage/internal/pocket

/obj/item/armor_module/storage/pocket/medical
	storage_type = /datum/storage/internal/pocket/medical

/** General storage */
/obj/item/armor_module/storage/general
	name = "general-purpose storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_general_bag"
	storage_type = /datum/storage/internal/general

/obj/item/armor_module/storage/general/som
	name = "general-purpose storage module"
	desc = "Designed for mounting on SOM combat armor. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like pistols or magazines."
	icon_state = "mod_general_bag_som"
	worn_icon_state = "mod_general_bag_som_a"

/obj/item/armor_module/storage/ammo_mag
	name = "magazine storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Holds some magazines. Don’t expect to fit specialist munitions or LMG drums in, but you can get some good mileage."
	icon_state = "mod_mag_bag"
	storage_type = /datum/storage/internal/ammo_mag

/obj/item/armor_module/storage/satchel
	name = "IS Pattern Storage module"
	desc = "Designed for mounting on the MAGNUM mercenaries modular armor. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
	storage_type = /datum/storage/internal/satchel
	slowdown = 0.2

/obj/item/armor_module/storage/engineering
	name = "engineering storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Can hold about as much as a tool pouch, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag"
	storage_type = /datum/storage/internal/engineering

/obj/item/armor_module/storage/engineering/som
	name = "engineering storage module"
	desc = "Designed for mounting on SOM combat armor. Can hold about as much as a tool pouch, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag_som"
	worn_icon_state = "mod_engineer_bag_som_a"

/obj/item/armor_module/storage/medical
	name = "medical storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag"
	storage_type = /datum/storage/internal/medical

/obj/item/armor_module/storage/medical/som
	name = "medical storage module"
	desc = "Designed for mounting on SOM combat armor. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag_som"
	worn_icon_state = "mod_medic_bag_som_a"

/obj/item/armor_module/storage/injector
	name = "injector storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Can hold a substantial variety of injectors."
	icon_state = "mod_injector_bag"
	storage_type = /datum/storage/internal/injector

/obj/item/armor_module/storage/integrated
	name = "bulk storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
	storage_type = /datum/storage/internal/integrated
	slowdown = 0.2

/obj/item/armor_module/storage/grenade
	name = "grenade storage module"
	desc = "Designed for mounting on the TGMC's modular armor systems. Can hold a respectable amount of grenades."
	icon_state = "mod_grenade_harness"
	storage_type = /datum/storage/internal/grenade

/obj/item/armor_module/storage/boot
	name = "boot storage module"
	desc = "A small set of straps to hold something in your boot."
	icon_state = ""
	storage_type = /datum/storage/internal/shoes/boot_knife
	attach_features_flags = ATTACH_APPLY_ON_MOB

/obj/item/armor_module/storage/boot/full/PopulateContents()
	new /obj/item/weapon/combat_knife(src)

/obj/item/armor_module/storage/boot/som_knife/PopulateContents()
	new /obj/item/attachable/bayonet/som(src)

/obj/item/armor_module/storage/boot/pmc_knife/PopulateContents()
	new /obj/item/weapon/combat_knife/pmc(src)

/obj/item/armor_module/storage/helmet
	name = "helmet storage module"
	desc = "A small set of bands and straps to allow easy storage of small items."
	icon_state = ""
	storage_type = /datum/storage/internal/marinehelmet
	show_storage = TRUE
	attach_features_flags = NONE
