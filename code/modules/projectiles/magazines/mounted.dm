///Default ammo for the TL-102.
/obj/item/ammo_magazine/tl102
	name = "TL-102 drum magazine (10x30mm Caseless)"
	desc = "A box of 300, 10x30mm caseless tungsten rounds for the TL-102 mounted heavy smartgun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mag"
	flags_magazine = NONE
	caliber = CALIBER_10X30
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 5 SECONDS
	icon_state_mini = "mag_tl102"

///This is the one that comes in the mapbound version of the TL-102, it has a stupid amount of ammo. Even more than the ammo counter can display.
/obj/item/ammo_magazine/tl102/hsg_nest
	max_rounds = 1500

/obj/item/ammo_magazine/heavymachinegun
	name = "MG-08/495 drum magazine (10x30mm Caseless)"
	desc = "A box of 500, 10x28mm caseless tungsten rounds for the MG-08/495 mounted heavy machinegun. Is probably not going to fit in your backpack. Put it on your belt or back."
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mg08_mag"
	flags_magazine = NONE
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 10 SECONDS

/obj/item/ammo_magazine/standard_mmg
	name = "T-27 box magazine (10x27m Caseless)"
	desc = "A box of 100 10x25mm caseless rounds for the T-27 medium machinegun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "mag"
	flags_magazine = NONE
	caliber = CALIBER_10X25_CASELESS
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/rifle/heavy
	reload_delay = 1 SECONDS
