/datum/storage/briefcase
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 16

/datum/storage/briefcase/standard_magnum
	max_storage_space = 15
	storage_slots = 9
	storage_type_limits = list(/obj/item/weapon/gun = 1)
	can_hold = list(
		/obj/item/weapon/gun/revolver/standard_magnum,
		/obj/item/attachable/stock/t76,
		/obj/item/attachable/scope/standard_magnum,
		/obj/item/ammo_magazine/revolver/standard_magnum,
	)
