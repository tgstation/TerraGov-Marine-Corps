/**
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
	///Internal storage of the module. Its parent is switched to the parent item when attached.
	var/obj/item/storage/internal/storage = /obj/item/storage/internal/modular
	///If TRUE it will add extra overlays for the items within.
	var/show_storage = FALSE
	///Icon for the extra storage overlays.
	var/show_storage_icon = 'icons/mob/modular/modular_helmet_storage.dmi'

/obj/item/armor_module/storage/Initialize(mapload)
	. = ..()
	storage = new storage(src)

/obj/item/armor_module/storage/Destroy()
	. = ..()
	QDEL_NULL(storage)

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
	storage.master_item = parent

/obj/item/armor_module/storage/on_detach(obj/item/detaching_from, mob/user)
	equip_delay_self = initial(equip_delay_self)
	strip_delay = initial(strip_delay)
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_CLICK_ALT_RIGHT, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_GHOST, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, COMSIG_CLICK_CTRL))
	storage.master_item = src
	return ..()

///Triggers attack hand interaction for storage when the parent is clicked on.
/obj/item/armor_module/storage/proc/access_storage(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
		return
	INVOKE_ASYNC(storage, TYPE_PROC_REF(/obj/item/storage/internal, handle_attack_hand), user)
	return COMPONENT_NO_ATTACK_HAND

///Opens the internal storage when the parent is alt right clicked on.
/obj/item/armor_module/storage/proc/open_storage(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(!isobserver(user) && parent.loc != user)
		return
	storage.open(user)
	return COMPONENT_NO_ATTACK_HAND

///Inserts I into storage when parent is attacked by I.
/obj/item/armor_module/storage/proc/insert_item(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(istype(I, /obj/item/facepaint) || istype(I, /obj/item/armor_module))
		return
	if(parent.loc != user)
		return
	INVOKE_ASYNC(storage, TYPE_PROC_REF(/atom, attackby), I, user)
	return COMPONENT_NO_AFTERATTACK

///We draw from the item's storage
/obj/item/armor_module/storage/proc/draw_from_storage(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
		return
	INVOKE_ASYNC(storage, TYPE_PROC_REF(/obj/item/storage/internal, attempt_draw_object), user)
	return COMPONENT_NO_ATTACK_HAND


///We draw the leftmost item from the item's storage
/obj/item/armor_module/storage/proc/left_draw_from_storage(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
		return
	INVOKE_ASYNC(storage, TYPE_PROC_REF(/obj/item/storage/internal, attempt_draw_object), user, TRUE)
	return COMPONENT_NO_ATTACK_HAND

/obj/item/armor_module/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	storage.attackby(I, user, params)

/obj/item/armor_module/storage/attack_hand(mob/living/user)
	if(loc == user)
		storage.open(user)
		return
	return ..()

/obj/item/storage/internal/modular
	max_storage_space = 2
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY
	bypass_w_limit = list(
		/obj/item/clothing/glasses,
	)

	cant_hold = list(
		/obj/item/stack,
	)

/* Pockets */
/obj/item/armor_module/storage/pocket
	icon_state = ""
	item_state = ""
	flags_attach_features = ATTACH_APPLY_ON_MOB
	storage = /obj/item/storage/internal/pocket

/obj/item/storage/internal/pocket
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

/obj/item/storage/internal/pocket/insertion_message(obj/item/item, mob/user)
	var/visidist = item.w_class >= WEIGHT_CLASS_NORMAL ? 3 : 1
	//Grab the name of the object this pocket belongs to
	user.visible_message(span_notice("[user] puts \a [item] into \the [master_item.name]."),\
						span_notice("You put \the [item] into \the [master_item.name]."),\
						null, visidist)

/obj/item/armor_module/storage/pocket/medical
	storage = /obj/item/storage/internal/pocket/medical

/obj/item/storage/internal/pocket/medical
	max_storage_space = 30
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/hypospray/advanced,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/gloves/latex,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
		/obj/item/whistle,
	)

/** General storage */
/obj/item/armor_module/storage/general
	name = "General Purpose Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_general_bag"
	storage = /obj/item/storage/internal/modular/general

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

/obj/item/armor_module/storage/general/som
	name = "General Purpose Storage module"
	desc = "Designed for mounting on SOM combat armor. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like pistols or magazines."
	icon_state = "mod_general_bag_som"
	item_state = "mod_general_bag_som_a"

/obj/item/armor_module/storage/ammo_mag
	name = "Magazine Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Holds some magazines. Don’t expect to fit specialist munitions or LMG drums in, but you can get some good mileage. Looks like it might slow you down a bit."
	icon_state = "mod_mag_bag"
	storage = /obj/item/storage/internal/modular/ammo_mag
	slowdown = 0.1

/obj/item/armor_module/storage/ammo_mag/freelancer/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/m16(storage)
	new /obj/item/ammo_magazine/rifle/m16(storage)
	new /obj/item/ammo_magazine/rifle/m16(storage)
	new /obj/item/ammo_magazine/rifle/m16(storage)

/obj/item/armor_module/storage/ammo_mag/freelancer_two/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx11(storage)
	new /obj/item/ammo_magazine/rifle/tx11(storage)
	new /obj/item/ammo_magazine/rifle/tx11(storage)
	new /obj/item/ammo_magazine/rifle/tx11(storage)

/obj/item/armor_module/storage/ammo_mag/freelancer_three/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx54(storage)
	new /obj/item/ammo_magazine/rifle/tx54(storage)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(storage)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(storage)


/obj/item/storage/internal/modular/ammo_mag
	max_storage_space = 15
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/explosive/grenade/flare/civilian,
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
	storage = /obj/item/storage/internal/modular/engineering

/obj/item/storage/internal/modular/engineering
	max_storage_space = 15
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/stack/sandbags_empty,
		/obj/item/stack/sandbags,
		/obj/item/stack/razorwire,
		/obj/item/tool/shovel/etool,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/tool/handheld_charger,
		/obj/item/tool/multitool,
		/obj/item/binoculars/tactical/range,
		/obj/item/explosive/plastique,
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol,
		/obj/item/explosive/grenade/chem_grenade/razorburn_large,
		/obj/item/cell/apc,
		/obj/item/cell/high,
		/obj/item/cell/rtg,
		/obj/item/cell/super,
		/obj/item/cell/potato,
		/obj/item/assembly/signaler,
		/obj/item/detpack,
		/obj/item/circuitboard,
		/obj/item/lightreplacer,
	)
	cant_hold = list()

/obj/item/armor_module/storage/engineering/som
	name = "Engineering Storage module"
	desc = "Designed for mounting on SOM combat armor. Can hold about as much as a tool pouch, and sometimes small spools of things like barbed wire, or an entrenching tool."
	icon_state = "mod_engineer_bag_som"
	item_state = "mod_engineer_bag_som_a"

/obj/item/armor_module/storage/medical
	name = "Medical Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag"
	storage = /obj/item/storage/internal/modular/medical

/obj/item/armor_module/storage/medical/freelancer/Initialize(mapload)
	. = ..()
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(storage)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(storage)
	new /obj/item/storage/pill_bottle/meralyne(storage)
	new /obj/item/storage/pill_bottle/dermaline(storage)
	new /obj/item/storage/pill_bottle/tramadol(storage)

/obj/item/storage/internal/modular/medical
	max_storage_space = 30
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/hypospray/advanced,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/syringe_case,
		/obj/item/roller/medevac,
		/obj/item/roller,
		/obj/item/bodybag,
		/obj/item/storage/pill_bottle,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/clothing/gloves/latex,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
		/obj/item/whistle,
	)

/obj/item/armor_module/storage/medical/som
	name = "Medical Storage module"
	desc = "Designed for mounting on SOM combat armor. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag_som"
	item_state = "mod_medic_bag_som_a"

/obj/item/armor_module/storage/injector
	name = "Injector Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of injectors."
	icon_state = "mod_injector_bag"
	storage = /obj/item/storage/internal/modular/injector

/obj/item/storage/internal/modular/injector
	max_storage_space = 10
	storage_slots = 10
	max_w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray/autoinjector,
	)

/obj/item/armor_module/storage/integrated
	name = "IS Pattern Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Impedes movement somewhat, but holds about as much as a satchel could."
	icon_state = "mod_is_bag"
	storage = /obj/item/storage/internal/modular/integrated
	slowdown = 0.2

/obj/item/storage/internal/modular/integrated
	bypass_w_limit = list()
	storage_slots = null
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/armor_module/storage/grenade
	name = "Grenade Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a respectable amount of grenades."
	icon_state = "mod_grenade_harness"
	storage = /obj/item/storage/internal/modular/grenade

/obj/item/storage/internal/modular/grenade
	max_storage_space = 12
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/explosive/grenade,
		/obj/item/reagent_containers/food/drinks/cans,
	)

/obj/item/armor_module/storage/boot
	name = "boot storage module"
	desc = "A small set of straps to hold something in your boot."
	icon_state = ""
	storage = /obj/item/storage/internal/shoes/boot_knife
	flags_attach_features = ATTACH_APPLY_ON_MOB

/obj/item/storage/internal/shoes/boot_knife
	max_storage_space = 3
	storage_slots = 1
	draw_mode = TRUE
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/gun/pistol/standard_pocketpistol,
		/obj/item/weapon/gun/shotgun/double/derringer,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/stack/throwing_knife,
		/obj/item/storage/box/MRE,
	)

/obj/item/armor_module/storage/boot/full/Initialize(mapload)
	. = ..()
	new /obj/item/weapon/combat_knife(storage)

/obj/item/armor_module/storage/boot/som_knife/Initialize(mapload)
	. = ..()
	new /obj/item/attachable/bayonetknife/som(storage)

/obj/item/armor_module/storage/helmet
	name = "Jaeger Pattern helmet storage"
	desc = "A small set of bands and straps to allow easy storage of small items."
	icon_state = ""
	storage = /obj/item/storage/internal/marinehelmet
	show_storage = TRUE
	flags_attach_features = NONE

/obj/item/storage/internal/marinehelmet
	max_storage_space = 3
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY
	bypass_w_limit = list(
		/obj/item/clothing/glasses,
		/obj/item/reagent_containers/food/snacks,
		/obj/item/stack/medical/heal_pack/gauze,
		/obj/item/stack/medical/heal_pack/ointment,
		/obj/item/ammo_magazine/handful,
	)
	cant_hold = list(
		/obj/item/stack/sheet,
		/obj/item/stack/catwalk,
		/obj/item/stack/rods,
		/obj/item/stack/sandbags_empty,
		/obj/item/stack/tile,
		/obj/item/stack/cable_coil,
	)
