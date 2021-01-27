/obj/item/ammo_magazine/smg
	name = "\improper SMG magazine"
	desc = "A submachinegun magazine."
	default_ammo = /datum/ammo/bullet/smg
	max_rounds = 30

//-------------------------------------------------------
//M25 SMG ammo

/obj/item/ammo_magazine/smg/m25
	name = "\improper MR-25 magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine."
	caliber = "10x20mm caseless"
	icon_state = "m25"
	max_rounds = 60
	w_class = WEIGHT_CLASS_SMALL
	gun_type = /obj/item/weapon/gun/smg/m25

/obj/item/ammo_magazine/smg/m25/ap
	name = "\improper MR-25 AP magazine (10x20mm)"
	icon_state = "m25_ap"
	default_ammo = /datum/ammo/bullet/smg/ap

/obj/item/ammo_magazine/smg/m25/extended
	name = "\improper MR-25 extended magazine (10x20mm)"
	icon_state = "m25_ext"
	max_rounds = 90

//-------------------------------------------------------
//T-19 Machinepistol ammo

/obj/item/ammo_magazine/smg/standard_machinepistol
	name = "\improper T-19 machinepistol magazine (10x20mm)"
	desc = "A 10x20mm caseless machine pistol magazine."
	caliber = "10x20mm caseless"
	icon_state = "t19"
	max_rounds = 30
	w_class = WEIGHT_CLASS_SMALL
	gun_type = /obj/item/weapon/gun/smg/standard_machinepistol

//-------------------------------------------------------
//T-90 SMG ammo

/obj/item/ammo_magazine/smg/standard_smg
	name = "\improper T-90 submachine gun magazine (10x20mm)"
	desc = "A 10x20mm caseless submachine gun magazine."
	caliber = "10x20mm caseless"
	icon_state = "t90"
	max_rounds = 50
	w_class = WEIGHT_CLASS_SMALL
	gun_type = /obj/item/weapon/gun/smg/standard_smg

//-------------------------------------------------------
//MP27, based on the MP27, based on the M7.

/obj/item/ammo_magazine/smg/mp7
	name = "\improper MP27 magazine (4.6x30mm)"
	desc = "A 4.6mm magazine for the MP27."
	default_ammo = /datum/ammo/bullet/smg/ap
	caliber = "4.6x30mm"
	icon_state = "mp7"
	gun_type = /obj/item/weapon/gun/smg/mp7
	max_rounds = 30


//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/ammo_magazine/smg/skorpion
	name = "\improper CZ-81 magazine (.32ACP)"
	desc = "A .32ACP caliber magazine for the CZ-81."
	caliber = ".32 ACP"
	icon_state = "skorpion"
	gun_type = /obj/item/weapon/gun/smg/skorpion
	max_rounds = 20 //Can also be 10.


//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/ammo_magazine/smg/ppsh
	name = "\improper PPSh-17b magazine (7.62x25mm)"
	desc = "A drum magazine for the PPSh submachinegun."
	default_ammo = /datum/ammo/bullet/smg
	caliber = "7.62x25mm"
	icon_state = "ppsh"
	max_rounds = 35
	gun_type = /obj/item/weapon/gun/smg/ppsh


/obj/item/ammo_magazine/smg/ppsh/extended
	name = "\improper PPSh-17b drum magazine (7.62x25mm)"
	icon_state = "ppsh_ext"
	max_rounds = 71

//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/ammo_magazine/smg/uzi
	name = "\improper GAL9 magazine (9mm)"
	desc = "A magazine for the GAL9."
	caliber = "9x21mm IMI"
	icon_state = "uzi"
	max_rounds = 32
	gun_type = /obj/item/weapon/gun/smg/uzi

/obj/item/ammo_magazine/smg/uzi/extended
	name = "\improper GAL9 extended magazine (9mm)"
	icon_state = "uzi_ext"
	max_rounds = 50
	bonus_overlay = "uzi_ex"
