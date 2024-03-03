/datum/storage/internal
	allow_drawing_method = FALSE /// Unable to set draw_mode ourselves

//Reason for this override is due to conflict signal from modules, which detach on ALT+CLICK
/datum/storage/internal/register_storage_signals(atom/parent)
	//Clicking signals
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby)) //Left click
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand)) //Left click empty hand
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self)) //Item clicking on itself
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, PROC_REF(on_attack_hand_alternate)) //Right click empty hand
	RegisterSignal(parent, COMSIG_CLICK_ALT_RIGHT, PROC_REF(on_alt_right_click)) //ALT + right click
	RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click)) //CTRL + Left click
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost)) //Ghosts can see inside your storages
	RegisterSignal(parent, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto)) //Click dragging

	//Something is happening to our storage
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp)) //Getting EMP'd
	RegisterSignal(parent, COMSIG_CONTENTS_EX_ACT, PROC_REF(on_contents_explode)) //Getting exploded

	RegisterSignal(parent, COMSIG_ATOM_CONTENTS_DEL, PROC_REF(handle_atom_del))
	RegisterSignal(parent, ATOM_MAX_STACK_MERGING, PROC_REF(max_stack_merging))
	RegisterSignal(parent, ATOM_RECALCULATE_STORAGE_SPACE, PROC_REF(recalculate_storage_space))
	RegisterSignals(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(update_verbs))
	RegisterSignal(parent, COMSIG_ITEM_QUICK_EQUIP, PROC_REF(on_quick_equip_request))

//Reason for this override is due to conflict signal from modules, which detach on ALT+CLICK
/datum/storage/internal/unregister_storage_signals(atom/parent)
	UnregisterSignal(parent, list(
	COMSIG_ATOM_ATTACKBY,
	COMSIG_ATOM_ATTACK_HAND,
	COMSIG_ITEM_ATTACK_SELF,
	COMSIG_ATOM_ATTACK_HAND_ALTERNATE,
	COMSIG_CLICK_ALT_RIGHT,
	COMSIG_CLICK_CTRL,
	COMSIG_ATOM_ATTACK_GHOST,
	COMSIG_MOUSEDROP_ONTO,

	COMSIG_ATOM_EMP_ACT,
	COMSIG_CONTENTS_EX_ACT,

	COMSIG_ATOM_CONTENTS_DEL,
	ATOM_MAX_STACK_MERGING,
	ATOM_RECALCULATE_STORAGE_SPACE,
	COMSIG_ITEM_EQUIPPED,
	COMSIG_ITEM_DROPPED,
	COMSIG_ITEM_QUICK_EQUIP,
	))

/datum/storage/internal/handle_item_insertion(obj/item/W, prevent_warning = FALSE)
	. = ..()
	var/obj/master_item = parent.loc
	master_item?.on_pocket_insertion()

/datum/storage/internal/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	var/obj/master_item = parent.loc
	if(isturf(master_item) || ismob(master_item))
		return
	master_item?.on_pocket_removal()

/datum/storage/internal/motorbike_pack
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_SMALL
	max_storage_space = 8

/datum/storage/internal/webbing
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 3
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
		/obj/item/cell/lasgun,
	)
	cant_hold = list(
		/obj/item/stack/razorwire,
		/obj/item/stack/sheet,
		/obj/item/stack/sandbags,
		/obj/item/stack/snow,
		/obj/item/cell/lasgun/volkite/powerpack,
		/obj/item/cell/lasgun/plasma_powerpack,
	)

/datum/storage/internal/vest
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL
	cant_hold = list(
		/obj/item/stack/razorwire,
		/obj/item/stack/sheet,
		/obj/item/stack/sandbags,
		/obj/item/stack/snow,
	)

/datum/storage/internal/white_vest
	max_w_class = WEIGHT_CLASS_BULKY
	storage_slots = 6 //one more than the brown webbing but you lose out on being able to hold non-medic stuff
	max_storage_space = 24
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
		/obj/item/bodybag,
		/obj/item/roller,
		/obj/item/whistle,
	)

/datum/storage/internal/surgery_webbing
	storage_slots = 12
	max_storage_space = 24
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
	)

/datum/storage/internal/holster
	storage_slots = 4
	max_storage_space = 10
	max_w_class = WEIGHT_CLASS_BULKY
	storage_type_limits = list(/obj/item/weapon/gun = 1)
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/lasrifle,
	)

/datum/storage/internal/modular
	max_storage_space = 2
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY
	bypass_w_limit = list(
		/obj/item/clothing/glasses,
	)
	cant_hold = list(
		/obj/item/stack,
	)

/datum/storage/internal/pocket
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
	cant_hold = list(/obj/item/cell/lasgun/volkite/powerpack)

/datum/storage/internal/pocket/insertion_message(obj/item/item, mob/user)
	var/visidist = item.w_class >= WEIGHT_CLASS_NORMAL ? 3 : 1
	//Grab the name of the object this pocket belongs to
	user.visible_message(span_notice("[user] puts \a [item] into \the [parent.name]."),\
						span_notice("You put \the [item] into \the [parent.name]."),\
						null, visidist)

/datum/storage/internal/pocket/medical
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

/datum/storage/internal/modular/general
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
		/obj/item/cell/lasgun/plasma_powerpack,
	)
	cant_hold = list(/obj/item/cell/lasgun/volkite/powerpack)

/datum/storage/internal/modular/ammo_mag
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

/datum/storage/internal/modular/engineering
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
		/obj/item/explosive/grenade/chem_grenade/razorburn_small,
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

/datum/storage/internal/modular/medical
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

/datum/storage/internal/modular/injector
	max_storage_space = 10
	storage_slots = 10
	max_w_class = WEIGHT_CLASS_TINY
	can_hold = list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray/autoinjector,
	)

/datum/storage/internal/modular/integrated
	bypass_w_limit = list()
	storage_slots = null
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/internal/modular/grenade
	max_storage_space = 12
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/explosive/grenade,
		/obj/item/reagent_containers/food/drinks/cans,
	)

/datum/storage/internal/shoes/boot_knife
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

/datum/storage/internal/marinehelmet
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
