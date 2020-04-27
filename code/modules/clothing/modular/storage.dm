/**
	Modular armor storage storage attachments

	These are storage attachments that equip into storage slots on modular armor
*/

/** Storage modules */
/obj/item/armor_module/storage
	icon = 'icons/mob/modular/modular_armor.dmi'
	icon_state = "mod_is_bag"
	var/storage_type = /obj/item/storage/internal/modular

/obj/item/storage/internal/modular
	max_storage_space = 2
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY
	bypass_w_limit = list(
		/obj/item/clothing/glasses,
		/obj/item/reagent_containers/food/drinks/flask
	)
	cant_hold = list(
		/obj/item/stack/
	)



/obj/item/armor_module/storage/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent)
	. = ..()

	if(parent.storage)
		if(!silent)
			to_chat(user, "There is already another storage module installed")
		return FALSE


/obj/item/armor_module/storage/can_detach(mob/living/user, obj/item/clothing/suit/modular/parent, silent)
	. = ..()

	if(parent.storage.contents)
		if(!silent)
			to_chat(user, "You can't remove this while there are items inside")
		return FALSE


/obj/item/armor_module/storage/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.installed_storage = src
	parent.storage = new storage_type(parent)

/obj/item/armor_module/storage/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.installed_storage = null
	QDEL_NULL(parent.storage)
	return ..()

/** General storage */
/obj/item/armor_module/storage/general
	name = "General Purpose Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Certainly not as specialised as any other storage rigs, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_"

/obj/item/armor_module/storage/ammo_mag
	name = "Magazine Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Holds some magazines. Don’t expect to fit specialist munitions or LMG drums in, but you can get some good mileage."
	icon_state = "mod_mag_bag"


/obj/item/armor_module/storage/engineering
	name = "Engineering Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold about as much as a tool belt, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag"


/obj/item/armor_module/storage/medical
	name = "Medical Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of medical supplies and apparatus, but cannot hold much more than a medkit could."
	icon_state = "mod_medic_bag"


/obj/item/armor_module/storage/integrated
	name = "IS Pattern Storage rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
