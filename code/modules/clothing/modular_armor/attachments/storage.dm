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
	create_storage(storage_type, storage_type.can_hold, storage_type.cant_hold, storage_type.bypass_w_limit)

/obj/item/armor_module/storage/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	equip_delay_self = parent.equip_delay_self
	strip_delay = parent.strip_delay
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(access_storage))
	RegisterSignal(parent, COMSIG_CLICK_ALT_RIGHT, PROC_REF(open_storage))	//Open storage if the armor is alt right clicked
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(insert_item))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(open_storage))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, PROC_REF(draw_from_storage))
	RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(left_draw_from_storage))

/obj/item/armor_module/storage/on_detach(obj/item/detaching_from, mob/user)
	equip_delay_self = initial(equip_delay_self)
	strip_delay = initial(strip_delay)
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_CLICK_ALT_RIGHT, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_GHOST, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, COMSIG_CLICK_CTRL))
	return ..()

///Triggers attack hand interaction for storage when the parent is clicked on.
/obj/item/armor_module/storage/proc/access_storage(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attack_hand), user)
	return COMPONENT_NO_ATTACK_HAND

///Opens the internal storage when the parent is alt right clicked on.
/obj/item/armor_module/storage/proc/open_storage(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!isobserver(user) && parent.loc != user)
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, AltRightClick), user)
	return COMPONENT_NO_ATTACK_HAND

///Inserts I into storage when parent is attacked by I.
/obj/item/armor_module/storage/proc/insert_item(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(istype(I, /obj/item/facepaint) || istype(I, /obj/item/armor_module))
		return
	if(parent.loc != user)
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attackby), I, user)
	return COMPONENT_NO_AFTERATTACK

///We draw from the item's storage
/obj/item/armor_module/storage/proc/draw_from_storage(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
		return
	INVOKE_ASYNC(atom_storage, TYPE_PROC_REF(/datum/storage, attempt_draw_object), user)
	return COMPONENT_NO_ATTACK_HAND


///We draw the leftmost item from the item's storage
/obj/item/armor_module/storage/proc/left_draw_from_storage(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
		return
	INVOKE_ASYNC(atom_storage, TYPE_PROC_REF(/datum/storage, attempt_draw_object), user, TRUE)
	return COMPONENT_NO_ATTACK_HAND

///Use this to fill your storage with items. USE THIS INSTEAD OF NEW/INIT
/obj/item/armor_module/storage/proc/PopulateContents()
	return

/obj/item/storage/internal/modular
	storage_type = /datum/storage/internal/modular

/* Pockets */
/obj/item/armor_module/storage/pocket
	icon_state = ""
	item_state = ""
	flags_attach_features = ATTACH_APPLY_ON_MOB
	storage_type = /datum/storage/internal/pocket

/obj/item/armor_module/storage/pocket/medical
	storage_type = /datum/storage/internal/pocket/medical

/** General storage */
/obj/item/armor_module/storage/general
	name = "General Purpose Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_general_bag"
	storage_type = /datum/storage/internal/modular/general

/obj/item/armor_module/storage/general/som
	name = "General Purpose Storage module"
	desc = "Designed for mounting on SOM combat armor. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like pistols or magazines."
	icon_state = "mod_general_bag_som"
	item_state = "mod_general_bag_som_a"

/obj/item/armor_module/storage/ammo_mag
	name = "Magazine Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Holds some magazines. Don’t expect to fit specialist munitions or LMG drums in, but you can get some good mileage. Looks like it might slow you down a bit."
	icon_state = "mod_mag_bag"
	storage_type = /datum/storage/internal/modular/ammo_mag
	slowdown = 0.1

/obj/item/armor_module/storage/ammo_mag/freelancer/PopulateContents()
	new /obj/item/ammo_magazine/rifle/m16(src)
	new /obj/item/ammo_magazine/rifle/m16(src)
	new /obj/item/ammo_magazine/rifle/m16(src)
	new /obj/item/ammo_magazine/rifle/m16(src)

/obj/item/armor_module/storage/ammo_mag/freelancer_two/PopulateContents()
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)
	new /obj/item/ammo_magazine/rifle/tx11(src)

/obj/item/armor_module/storage/ammo_mag/freelancer_three/PopulateContents()
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(src)

/obj/item/armor_module/storage/engineering
	name = "Engineering Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold about as much as a tool pouch, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag"
	storage_type = /datum/storage/internal/modular/engineering

/obj/item/armor_module/storage/engineering/som
	name = "Engineering Storage module"
	desc = "Designed for mounting on SOM combat armor. Can hold about as much as a tool pouch, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag_som"
	item_state = "mod_engineer_bag_som_a"

/obj/item/armor_module/storage/medical
	name = "Medical Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag"
	storage_type = /datum/storage/internal/modular/medical

/obj/item/armor_module/storage/medical/freelancer/PopulateContents()
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/storage/pill_bottle/meralyne(src)
	new /obj/item/storage/pill_bottle/dermaline(src)
	new /obj/item/storage/pill_bottle/tramadol(src)

/obj/item/armor_module/storage/medical/som
	name = "Medical Storage module"
	desc = "Designed for mounting on SOM combat armor. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag_som"
	item_state = "mod_medic_bag_som_a"

/obj/item/armor_module/storage/injector
	name = "Injector Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of injectors."
	icon_state = "mod_injector_bag"
	storage_type = /datum/storage/internal/modular/injector

/obj/item/armor_module/storage/integrated
	name = "IS Pattern Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
	storage_type = /datum/storage/internal/modular/integrated
	slowdown = 0.2

/obj/item/armor_module/storage/grenade
	name = "Grenade Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a respectable amount of grenades."
	icon_state = "mod_grenade_harness"
	storage_type = /datum/storage/internal/modular/grenade

/obj/item/armor_module/storage/boot
	name = "boot storage module"
	desc = "A small set of straps to hold something in your boot."
	icon_state = ""
	storage_type = /datum/storage/internal/shoes/boot_knife
	flags_attach_features = ATTACH_APPLY_ON_MOB

/obj/item/armor_module/storage/boot/full/PopulateContents()
	new /obj/item/weapon/combat_knife(src)

/obj/item/armor_module/storage/boot/som_knife/PopulateContents()
	new /obj/item/attachable/bayonetknife/som(src)

/obj/item/armor_module/storage/helmet
	name = "Jaeger Pattern helmet storage"
	desc = "A small set of bands and straps to allow easy storage of small items."
	icon_state = ""
	storage_type = /datum/storage/internal/marinehelmet
	show_storage = TRUE
	flags_attach_features = NONE
