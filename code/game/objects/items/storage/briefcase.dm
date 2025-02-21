/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	icon = 'icons/obj/items/storage/briefcase.dmi'
	worn_icon_state = "briefcase"
	atom_flags = CONDUCT
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/briefcase

/obj/item/storage/briefcase/standard_magnum
	name = "R-76 Magnum case"
	desc = "A well made, expensive looking case, made to fit an R-76 Magnum and its accessories. For the discerning gun owner."
	icon_state = "magnum_case"
	worn_icon_state = "briefcase"
	atom_flags = CONDUCT
	force = 12
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/briefcase/standard_magnum

/obj/item/storage/briefcase/standard_magnum/gold/PopulateContents()
	new /obj/item/weapon/gun/revolver/standard_magnum/fancy/gold(src)
	new /obj/item/attachable/scope/standard_magnum(src)
	new /obj/item/attachable/stock/t76(src)
	new /obj/item/attachable/compensator(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)

/obj/item/storage/briefcase/standard_magnum/silver/PopulateContents()
	new /obj/item/weapon/gun/revolver/standard_magnum/fancy/silver(src)
	new /obj/item/attachable/scope/standard_magnum(src)
	new /obj/item/attachable/stock/t76(src)
	new /obj/item/attachable/compensator(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)

/obj/item/storage/briefcase/standard_magnum/nickle/PopulateContents()
	new /obj/item/weapon/gun/revolver/standard_magnum/fancy/nickle(src)
	new /obj/item/attachable/scope/standard_magnum(src)
	new /obj/item/attachable/stock/t76(src)
	new /obj/item/attachable/compensator(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
	new /obj/item/ammo_magazine/revolver/standard_magnum(src)
