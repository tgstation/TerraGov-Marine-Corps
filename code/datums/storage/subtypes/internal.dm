/datum/storage/internal
	allow_drawing_method = FALSE /// Unable to set draw_mode ourselves

/datum/storage/internal/handle_item_insertion(obj/item/W, prevent_warning = FALSE)
	. = ..()
	var/obj/master_item = parent.loc
	master_item?.on_pocket_insertion()

/datum/storage/internal/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	var/obj/master_item = parent.loc
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
