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
	gun_type = /obj/item/weapon/gun/tl102
	reload_delay = 5 SECONDS

///This is the one that comes in the mapbound version of the TL-102, it has a stupid amount of ammo. Even more than the ammo counter can display.
/obj/item/ammo_magazine/tl102/hsg_nest
	max_rounds = 1500
	gun_type = /obj/item/weapon/gun/tl102/hsg_nest
