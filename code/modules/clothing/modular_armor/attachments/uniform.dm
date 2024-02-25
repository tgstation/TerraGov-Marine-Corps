
//Uniform Storage.
/obj/item/armor_module/storage/uniform
	slot = ATTACHMENT_SLOT_UNIFORM
	w_class = WEIGHT_CLASS_BULKY
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_APPLY_ON_MOB|ATTACH_SEPERATE_MOB_OVERLAY|ATTACH_NO_HANDS
	icon = 'icons/obj/clothing/ties.dmi'
	attach_icon = 'icons/obj/clothing/ties_overlay.dmi'
	mob_overlay_icon = 'icons/mob/ties.dmi'

/obj/item/armor_module/storage/uniform/webbing
	name = "webbing"
	desc = "A sturdy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	storage = /obj/item/storage/internal/webbing

/obj/item/storage/internal/webbing
	storage_type = /datum/storage/internal/webbing

/obj/item/armor_module/storage/uniform/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	storage = /obj/item/storage/internal/vest

/obj/item/storage/internal/vest
	storage_type = /datum/storage/internal/vest

/obj/item/armor_module/storage/uniform/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	storage = /obj/item/storage/internal/vest

/obj/item/armor_module/storage/uniform/white_vest
	name = "white webbing vest"
	desc = "A clean white Nylon vest with large pockets specially designed for medical supplies"
	icon_state = "vest_white"
	storage = /obj/item/storage/internal/white_vest

/obj/item/storage/internal/white_vest
	storage_type = /datum/storage/internal/white_vest

/obj/item/armor_module/storage/uniform/surgery_webbing
	name = "surgical webbing"
	desc = "A clean white Nylon webbing composed of many straps and pockets to hold surgical tools."
	icon_state = "webbing_white"
	storage = /obj/item/storage/internal/surgery_webbing

/obj/item/storage/internal/surgery_webbing
	storage_type = /datum/storage/internal/surgery_webbing

/obj/item/storage/internal/surgery_webbing/PopulateContents()
	new /obj/item/tool/surgery/scalpel/manager(src)
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/surgical_membrane(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/tool/surgery/suture(src)

/obj/item/armor_module/storage/uniform/holster
	name = "shoulder holster"
	desc = "A handgun holster"
	icon_state = "holster"
	storage = /obj/item/storage/internal/holster

/obj/item/armor_module/storage/uniform/holster/freelancer/PopulateContents()
	new /obj/item/ammo_magazine/pistol/g22(storage)
	new /obj/item/ammo_magazine/pistol/g22(storage)
	new /obj/item/ammo_magazine/pistol/g22(storage)
	new /obj/item/weapon/gun/pistol/g22(storage)

/obj/item/armor_module/storage/uniform/holster/vp/PopulateContents()
	new /obj/item/ammo_magazine/pistol/vp70(storage)
	new /obj/item/ammo_magazine/pistol/vp70(storage)
	new /obj/item/ammo_magazine/pistol/vp70(storage)
	new /obj/item/weapon/gun/pistol/vp70(storage)

/obj/item/armor_module/storage/uniform/holster/highpower/PopulateContents()
	new /obj/item/ammo_magazine/pistol/highpower(storage)
	new /obj/item/ammo_magazine/pistol/highpower(storage)
	new /obj/item/ammo_magazine/pistol/highpower(storage)
	new /obj/item/weapon/gun/pistol/highpower(storage)

/obj/item/armor_module/storage/uniform/holster/deathsquad/PopulateContents()
	new /obj/item/ammo_magazine/revolver/mateba(storage)
	new /obj/item/ammo_magazine/revolver/mateba(storage)
	new /obj/item/ammo_magazine/revolver/mateba(storage)
	new /obj/item/weapon/gun/revolver/mateba(storage)

/obj/item/storage/internal/holster
	storage_type = /datum/storage/internal/holster

/obj/item/armor_module/storage/uniform/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"

/obj/item/armor_module/storage/uniform/holster/waist
	name = "shoulder holster"
	desc = "A handgun holster. Made of expensive leather."
	icon_state = "holster"
	item_state = "holster_low"
