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
	///Internal storage of the module. Its parent is switched to the parent item when attached.
	var/obj/item/storage/internal/storage = /obj/item/storage/internal/modular
	///If TRUE it will add extra overlays for the items within.
	var/show_storage = FALSE
	///Icon for the extra storage overlays.
	var/show_storage_icon = 'icons/mob/modular/modular_helmet_storage.dmi'

/obj/item/armor_module/storage/Initialize()
	. = ..()
	storage = new storage(src)

/obj/item/armor_module/storage/Destroy()
	. = ..()
	QDEL_NULL(storage)

/obj/item/armor_module/storage/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	time_to_equip = parent.time_to_equip
	time_to_unequip = parent.time_to_unequip
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/open_storage)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/insert_item)
	storage.master_item = parent

/obj/item/armor_module/storage/on_detach(obj/item/detaching_from, mob/user)
	time_to_equip = initial(time_to_equip)
	time_to_unequip = initial(time_to_unequip)
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_ATTACKBY))
	storage.master_item = src
	return ..()

///Opens the internal storage when the parent is clicked on.
/obj/item/armor_module/storage/proc/open_storage(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(parent.loc != user)
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
	INVOKE_ASYNC(storage, /atom.proc/attackby, I, user)
	return COMPONENT_NO_AFTERATTACK

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

/** General storage */
/obj/item/armor_module/storage/general
	name = "General Purpose Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Certainly not as specialised as any other storage modules, but definitely able to hold some larger things, like binoculars, maps, and motion detectors."
	icon_state = "mod_general_bag"
	storage =  /obj/item/storage/internal/modular/general

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
	storage =  /obj/item/storage/internal/modular/ammo_mag
	slowdown = 0.1

/obj/item/armor_module/storage/ammo_mag/freelancer/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rifle/m16(storage)
	new /obj/item/ammo_magazine/rifle/m16(storage)
	new /obj/item/ammo_magazine/rifle/m16(storage)
	new /obj/item/ammo_magazine/rifle/m16(storage)

/obj/item/armor_module/storage/ammo_mag/freelancer_two/Initialize()
	. = ..()
	new /obj/item/ammo_magazine/rifle/tx11(storage)
	new /obj/item/ammo_magazine/rifle/tx11(storage)
	new /obj/item/ammo_magazine/rifle/tx11(storage)
	new /obj/item/ammo_magazine/rifle/tx11(storage)

/obj/item/armor_module/storage/ammo_mag/freelancer_three/Initialize()
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
	storage =  /obj/item/storage/internal/modular/engineering

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
		/obj/item/stack/razorwire,
		/obj/item/tool/shovel/etool,
		/obj/item/tool/wrench,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wirecutters,
		/obj/item/tool/crowbar,
		/obj/item/tool/screwdriver,
		/obj/item/tool/handheld_charger,
		/obj/item/multitool,
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
		/obj/item/tool/surgery/solderingtool,
	)
	cant_hold = list()

/obj/item/armor_module/storage/medical
	name = "Medical Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of medical supplies and apparatus, but cannot hold as much as a medkit could."
	icon_state = "mod_medic_bag"
	storage =  /obj/item/storage/internal/modular/medical

/obj/item/armor_module/storage/medical/freelancer/Initialize()
	. = ..()
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(storage)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(storage)
	new /obj/item/storage/pill_bottle/meralyne(storage)
	new /obj/item/storage/pill_bottle/dermaline(storage)
	new /obj/item/storage/pill_bottle/tramadol(storage)

/obj/item/armor_module/storage/medical/basic/Initialize()
	. = ..()
	new /obj/item/storage/pill_bottle/packet/bicaridine(storage)
	new /obj/item/storage/pill_bottle/packet/kelotane(storage)
	new /obj/item/storage/pill_bottle/packet/tramadol(storage)
	new /obj/item/stack/medical/splint(storage)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(storage)

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

/obj/item/armor_module/storage/injector
	name = "Injector Storage module"
	desc = "Designed for mounting on the Jaeger Combat Exoskeleton. Can hold a substantial variety of injectors."
	icon_state = "mod_injector_bag"
	storage =  /obj/item/storage/internal/modular/injector

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
	storage =  /obj/item/storage/internal/modular/integrated
	slowdown = 0.2

/obj/item/storage/internal/modular/integrated
	bypass_w_limit = list()
	storage_slots = null
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/armor_module/storage/helmet
	name = "Jaeger Pattern helmet storage"
	desc = "A small set of bands and straps to allow easy storage of small items."
	icon_state = "invisible" //It is invisible
	storage =  /obj/item/storage/internal/marinehelmet
	slowdown = 0
	show_storage = TRUE
	flags_attach_features = NONE

/obj/item/armor_module/storage/helmet/som_leader/Initialize()
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(storage)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(storage)

/obj/item/armor_module/storage/helmet/som_vet/Initialize()
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone(storage)
	new /obj/item/reagent_containers/hypospray/autoinjector/russian_red(storage)

/obj/item/armor_module/storage/helmet/som/Initialize()
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone(storage)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat(storage)
