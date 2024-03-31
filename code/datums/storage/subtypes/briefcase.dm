/datum/storage/briefcase
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 16

/datum/storage/briefcase/standard_magnum
	max_storage_space = 15
	storage_slots = 9

/datum/storage/briefcase/standard_magnum/New(atom/parent)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/weapon/gun/revolver/standard_magnum,
			/obj/item/attachable/stock/t76,
			/obj/item/attachable/scope/standard_magnum,
			/obj/item/ammo_magazine/revolver/standard_magnum,
		),
		storage_type_limits_list = list(/obj/item/weapon/gun)
	)
	storage_type_limits_max = list(/obj/item/weapon/gun = 1)
