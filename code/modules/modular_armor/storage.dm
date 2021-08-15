/**
	Modular armor storage storage attachments

	These are storage attachments that equip into storage slots on modular armor
*/


/** Storage modules */
/obj/item/armor_module/storage
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_is_bag"

	/// Internal storage type
	var/storage_type = /obj/item/storage/internal/modular

/obj/item/armor_module/storage/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(parent.installed_storage)
		if(!silent)
			to_chat(user,span_warning("There is already an installed storage module."))
		return FALSE

/obj/item/armor_module/storage/can_detach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(parent.storage && length(parent.storage.contents))
		if(!silent)
			to_chat(user, "You can't remove this while there are still items inside")
		return FALSE

/obj/item/armor_module/storage/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slowdown += slowdown
	time_to_equip = parent.time_to_equip
	time_to_unequip = parent.time_to_unequip

/obj/item/armor_module/storage/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slowdown -= slowdown
	time_to_equip = initial(time_to_equip)
	time_to_unequip = initial(time_to_unequip)
	return ..()

/obj/item/storage/internal/modular
	max_storage_space = 2
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY
	bypass_w_limit = list(
		/obj/item/clothing/glasses,
		/obj/item/reagent_containers/food/drinks/flask,
	)

	cant_hold = list(
		/obj/item/stack,
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
	name = "General Purpose Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_general_bag"
	storage_type =  /obj/item/storage/internal/modular/general

/obj/item/storage/internal/modular/general
	max_storage_space = 6
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_NORMAL

	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
	)

/obj/item/armor_module/storage/ammo_mag
	name = "Magazine Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Holds some magazines. Don’t expect to fit specialist munitions or LMG drums in, but you can get some good mileage. Looks like it might slow you down a bit."
	icon_state = "mod_mag_bag"
	storage_type =  /obj/item/storage/internal/modular/ammo_mag
	slowdown = 0.1

/obj/item/storage/internal/modular/ammo_mag
	max_storage_space = 15
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
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
		/obj/item/reagent_containers/food/snacks,
	)

/obj/item/armor_module/storage/engineering
	name = "Engineering Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold about as much as a tool pouch, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag"
	storage_type =  /obj/item/storage/internal/modular/engineering

/obj/item/storage/internal/modular/engineering
	max_storage_space = 15
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_BULKY
	bypass_w_limit = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/sandbags_empty,
	)
	can_hold = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/sandbags_empty,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/multitool,
		/obj/item/binoculars/tactical/range,
	)
	cant_hold = list()

/obj/item/armor_module/storage/medical
	name = "Medical Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag"
	storage_type =  /obj/item/storage/internal/modular/medical

/obj/item/storage/internal/modular/medical
	max_storage_space = 30
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/hypospray/advanced,
		/obj/item/reagent_containers/hypospray,
		/obj/item/stack/medical,
		/obj/item/tweezers,
	)

/obj/item/armor_module/storage/integrated
	name = "IS Pattern Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
	storage_type =  /obj/item/storage/internal/modular/integrated
	slowdown = 0.2

/obj/item/storage/internal/modular/integrated
	bypass_w_limit = list()
	storage_slots = null
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL
