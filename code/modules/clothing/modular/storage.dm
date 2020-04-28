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


/obj/item/armor_module/storage/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.installed_storage = src
	parent.storage = new storage_type(parent)


/obj/item/armor_module/storage/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.installed_storage = null
	QDEL_NULL(parent.storage)
	return ..()


/** General storage */
/obj/item/armor_module/storage/general
	name = "General Purpose Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Certainly not as specialised as any other storage rigs, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_general_bag"
	storage_type =  /obj/item/storage/internal/modular/general

/obj/item/storage/internal/modular/general
	storage_slots = 3
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 10
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/flashlight/flare,
		/obj/item/explosive/grenade/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_containers/food/snacks
		)


/obj/item/armor_module/storage/ammo_mag
	name = "Magazine Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Holds some magazines. Don’t expect to fit specialist munitions or LMG drums in, but you can get some good mileage."
	icon_state = "mod_mag_bag"
	storage_type =  /obj/item/storage/internal/modular/ammo_mag

/obj/item/storage/internal/modular/ammo_mag
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 15
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/flashlight/flare,
		/obj/item/explosive/grenade/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_containers/food/snacks
		)


/obj/item/armor_module/storage/engineering
	name = "Engineering Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold about as much as a tool belt, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag"
	storage_type =  /obj/item/storage/internal/modular/general

// TODO: This still needs some balance
/obj/item/storage/internal/modular/engineering
	max_storage_space = 42
	storage_slots = 7
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/cable_coil
	)


/obj/item/armor_module/storage/medical
	name = "Medical Storage Rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of medical supplies and apparatus, but cannot hold much more than a medkit could."
	icon_state = "mod_medic_bag"
	storage_type =  /obj/item/storage/internal/modular/medical

/obj/item/storage/internal/modular/medical
	max_storage_space = 42
	storage_slots = 7
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical
	)


/obj/item/armor_module/storage/integrated
	name = "IS Pattern Storage rig"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
	storage_type =  /obj/item/storage/internal/modular/integrated

/obj/item/storage/internal/modular/integrated
	max_storage_space = 42
	storage_slots = 7
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical
	)
