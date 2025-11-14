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
	RegisterSignal(parent, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(item_init_in_parent))

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
		COMSIG_ATOM_INITIALIZED_ON,
	))

/datum/storage/internal/handle_item_insertion(obj/item/W, prevent_warning = FALSE)
	. = ..()
	var/obj/master_item = parent.loc
	master_item?.update_icon()

/datum/storage/internal/remove_from_storage(obj/item/item, atom/new_location, mob/user, silent = FALSE, bypass_delay = FALSE)
	. = ..()
	var/obj/master_item = parent.loc
	if(isturf(master_item) || ismob(master_item))
		return
	master_item?.update_icon()

/datum/storage/internal/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	if(!ismodulararmormodule(attacking_item))
		return ..()

/datum/storage/internal/motorbike_pack
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_SMALL
	max_storage_space = 8

/datum/storage/internal/motorbike_pack/on_ctrl_click()
	return //We want to be able to grab the bike without pulling something out

/datum/storage/internal/motorbike_pack/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	if(!params) //we're clicking directly on storage, not the sprite. Avoids accidental storing
		return ..()

/datum/storage/internal/webbing
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 3

/datum/storage/internal/webbing/New(atom/parent)
	. = ..()
	set_holdable(
		cant_hold_list = list(
			/obj/item/cell/lasgun/volkite/powerpack,
			/obj/item/stack/razorwire,
			/obj/item/stack/sheet,
			/obj/item/stack/sandbags,
			/obj/item/stack/snow,
		),
		storage_type_limits_list = list(
			/obj/item/ammo_magazine/rifle,
			/obj/item/ammo_magazine/smg,
			/obj/item/ammo_magazine/sniper,
			/obj/item/cell/lasgun,
		)
	)

/datum/storage/internal/vest
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL

/datum/storage/internal/vest/New(atom/parent)
	. = ..()
	set_holdable(cant_hold_list = list(
		/obj/item/stack/razorwire,
		/obj/item/stack/sheet,
		/obj/item/stack/sandbags,
		/obj/item/stack/snow,
	))

/datum/storage/internal/white_vest
	max_w_class = WEIGHT_CLASS_BULKY
	storage_slots = 6 //one more than the brown webbing but you lose out on being able to hold non-medic stuff
	max_storage_space = 24

/datum/storage/internal/white_vest/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
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
	))

/datum/storage/internal/surgery_webbing
	storage_slots = 12
	max_storage_space = 24

/datum/storage/internal/surgery_webbing/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
	))

/datum/storage/internal/holster
	storage_slots = 4
	max_storage_space = 10
	max_w_class = WEIGHT_CLASS_BULKY

/datum/storage/internal/holster/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/ammo_magazine/pistol,
		/obj/item/weapon/gun/revolver,
		/obj/item/ammo_magazine/revolver,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/cell/lasgun/lasrifle,
	))
	storage_type_limits_max = list(/obj/item/weapon/gun = 1)

/datum/storage/internal/modular
	max_storage_space = 2
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY

/datum/storage/internal/modular/New(atom/parent)
	. = ..()
	set_holdable(
		can_hold_list = list(/obj/item/stack),
		storage_type_limits_list = list(/obj/item/clothing/glasses)
	)

/datum/storage/internal/pocket
	max_storage_space = 6
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/internal/pocket/New(atom/parent)
	. = ..()
	set_holdable(
		cant_hold_list = list(/obj/item/cell/lasgun/volkite/powerpack),
		storage_type_limits_list = list(
			/obj/item/ammo_magazine/rifle,
			/obj/item/cell/lasgun,
			/obj/item/ammo_magazine/smg,
			/obj/item/ammo_magazine/pistol,
			/obj/item/ammo_magazine/revolver,
			/obj/item/ammo_magazine/sniper,
			/obj/item/ammo_magazine/handful,
		)
	)

/datum/storage/internal/pocket/insertion_message(obj/item/item, mob/user)
	var/vision_distance = item.w_class >= WEIGHT_CLASS_NORMAL ? 3 : 1
	//Grab the name of the object this pocket belongs to
	user.visible_message(span_notice("[user] puts \a [item] into \the [parent.name]."),\
						span_notice("You put \the [item] into \the [parent.name]."),\
						null, vision_distance)

/datum/storage/internal/pocket/medical
	max_storage_space = 30
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL

/datum/storage/internal/pocket/medical/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
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
	))

/datum/storage/internal/general
	max_storage_space = 6
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/internal/general/New(atom/parent)
	. = ..()
	set_holdable(
		cant_hold_list = list(/obj/item/cell/lasgun/volkite/powerpack),
		storage_type_limits_list = list(
			/obj/item/ammo_magazine/rifle,
			/obj/item/cell/lasgun,
			/obj/item/ammo_magazine/smg,
			/obj/item/ammo_magazine/pistol,
			/obj/item/ammo_magazine/revolver,
			/obj/item/ammo_magazine/sniper,
			/obj/item/ammo_magazine/handful,
			/obj/item/cell/lasgun/plasma,
		)
	)

/datum/storage/internal/ammo_mag
	max_storage_space = 15
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/internal/ammo_mag/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
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
	))

/datum/storage/internal/satchel
	storage_slots = null
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/internal/engineering
	max_storage_space = 15
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_BULKY

/datum/storage/internal/engineering/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
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
		/obj/item/minerupgrade,
	))

/datum/storage/internal/medical
	max_storage_space = 30
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_SMALL

/datum/storage/internal/medical/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
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
	))

/datum/storage/internal/injector
	max_storage_space = 12
	storage_slots = 12
	max_w_class = WEIGHT_CLASS_TINY

/datum/storage/internal/injector/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray/autoinjector,
	))

/datum/storage/internal/integrated
	storage_slots = null
	max_storage_space = 15
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/internal/grenade
	max_storage_space = 12
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_SMALL

/datum/storage/internal/grenade/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/explosive/grenade,
		/obj/item/reagent_containers/food/drinks/cans,
	))

/datum/storage/internal/shoes/boot_knife
	max_storage_space = 3
	storage_slots = 1
	draw_mode = TRUE

/datum/storage/internal/shoes/boot_knife/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/gun/pistol/standard_pocketpistol,
		/obj/item/weapon/gun/shotgun/double/derringer,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/som,
		/obj/item/stack/throwing_knife,
		/obj/item/storage/box/MRE,
	))

/datum/storage/internal/marinehelmet
	max_storage_space = 3
	storage_slots = 2
	max_w_class = WEIGHT_CLASS_TINY

/datum/storage/internal/marinehelmet/New(atom/parent)
	. = ..()
	set_holdable(
		cant_hold_list = list(
			/obj/item/stack/sheet,
			/obj/item/stack/catwalk,
			/obj/item/stack/rods,
			/obj/item/stack/sandbags_empty,
			/obj/item/stack/tile,
			/obj/item/stack/cable_coil,
		),
		storage_type_limits_list = list(
			/obj/item/clothing/glasses,
			/obj/item/reagent_containers/food/snacks,
			/obj/item/stack/medical/heal_pack/gauze,
			/obj/item/stack/medical/heal_pack/ointment,
			/obj/item/ammo_magazine/handful,
		)
	)

/datum/storage/internal/ammo_rack //Hey isn't this great? Due to this storage refactor, deployables can have storage too!
	storage_slots = 10
	max_storage_space = 40
	max_w_class = WEIGHT_CLASS_BULKY

/datum/storage/internal/ammo_rack/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(/obj/item/ammo_magazine/standard_atgun))

//Reason for this override is due to conflict controls from deployables
/datum/storage/internal/ammo_rack/register_storage_signals(atom/parent)
	//Clicking signals
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby)) //Left click
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self)) //Item clicking on itself
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, PROC_REF(on_attack_hand_alternate)) //Right click empty hand
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost)) //Ghosts can see inside your storages

	//Something is happening to our storage
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp)) //Getting EMP'd
	RegisterSignal(parent, COMSIG_CONTENTS_EX_ACT, PROC_REF(on_contents_explode)) //Getting exploded

	RegisterSignal(parent, COMSIG_ATOM_CONTENTS_DEL, PROC_REF(handle_atom_del))
	RegisterSignal(parent, ATOM_MAX_STACK_MERGING, PROC_REF(max_stack_merging))
	RegisterSignal(parent, ATOM_RECALCULATE_STORAGE_SPACE, PROC_REF(recalculate_storage_space))
	RegisterSignals(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(update_verbs))
	RegisterSignal(parent, COMSIG_ITEM_QUICK_EQUIP, PROC_REF(on_quick_equip_request))
	RegisterSignal(parent, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(item_init_in_parent))

//Reason for this override is due to conflict controls from deployables
/datum/storage/internal/ammo_rack/unregister_storage_signals(atom/parent)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ATOM_ATTACK_HAND_ALTERNATE,
		COMSIG_ATOM_ATTACK_GHOST,

		COMSIG_ATOM_EMP_ACT,
		COMSIG_CONTENTS_EX_ACT,

		COMSIG_ATOM_CONTENTS_DEL,
		ATOM_MAX_STACK_MERGING,
		ATOM_RECALCULATE_STORAGE_SPACE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_QUICK_EQUIP,
		COMSIG_ATOM_INITIALIZED_ON,
	))

// Special override to reload our gun if it's empty before putting extra shells into storage
/datum/storage/internal/ammo_rack/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	if(user.s_active != src) //Only insert shells into storage if our storage UI is open
		return FALSE

	if(length(refill_types))
		for(var/typepath in refill_types)
			if(istype(attacking_item, typepath))
				INVOKE_ASYNC(src, PROC_REF(do_refill), attacking_item, user)
				return

	if(!can_be_inserted(attacking_item, user))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), attacking_item, FALSE, user)
	return COMPONENT_NO_AFTERATTACK

/datum/storage/internal/ammo_rack/on_attack_hand_alternate(datum/source, mob/living/user) //Override for subtype since this is in world storage
	if(user.CanReach(source))
		open(user)
