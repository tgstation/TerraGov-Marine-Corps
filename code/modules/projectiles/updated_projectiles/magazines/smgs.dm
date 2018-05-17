/obj/item/ammo_magazine/smg
	name = "\improper default SMG magazine"
	desc = "A submachinegun magazine."
	default_ammo = /datum/ammo/bullet/smg
	max_rounds = 30

//-------------------------------------------------------
//M39 SMG ammo

/obj/item/ammo_magazine/smg/m39
	name = "\improper M39 magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine."
	caliber = "10x20mm"
	icon_state = "m39"
	max_rounds = 48
	w_class = 3
	gun_type = /obj/item/weapon/gun/smg/m39

/obj/item/ammo_magazine/smg/m39/ap
	name = "\improper M39 AP magazine (10x20mm)"
	icon_state = "m39_AP"
	default_ammo = /datum/ammo/bullet/smg/ap

/obj/item/ammo_magazine/smg/m39/extended
	name = "\improper M39 extended magazine (10x20mm)"
	max_rounds = 72
	bonus_overlay = "m39_ex"


//-------------------------------------------------------
//M5, a classic SMG used in a lot of action movies.

/obj/item/ammo_magazine/smg/mp5
	name = "\improper MP5 magazine (9mm)"
	desc = "A 9mm magazine for the MP5."
	default_ammo = /datum/ammo/bullet/smg
	caliber = "9mm"
	icon_state = "mp7" //PLACEHOLDER
	gun_type = /obj/item/weapon/gun/smg/mp5
	max_rounds = 30 //Also comes in 10 and 40.


//-------------------------------------------------------
//MP27, based on the MP27, based on the M7.

/obj/item/ammo_magazine/smg/mp7
	name = "\improper MP27 magazine (4.6x30mm)"
	desc = "A 4.6mm magazine for the MP27."
	default_ammo = /datum/ammo/bullet/smg/ap
	caliber = "4.6x30mm"
	icon_state = "mp7"
	gun_type = /obj/item/weapon/gun/smg/mp7
	max_rounds = 30 //Also comes in 20 and 40.

//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/ammo_magazine/smg/skorpion
	name = "\improper CZ-81 magazine (.32ACP)"
	desc = "A .32ACP caliber magazine for the CZ-81."
	caliber = ".32ACP"
	icon_state = "skorpion" //PLACEHOLDER
	gun_type = /obj/item/weapon/gun/smg/skorpion
	max_rounds = 20 //Can also be 10.


//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/ammo_magazine/smg/ppsh
	name = "\improper PPSh-17b drum magazine (7.62x25mm)"
	desc = "A drum magazine for the PPSh submachinegun."
	caliber = "7.62x25mm"
	icon_state = "ppsh17b"
	max_rounds = 35
	gun_type = /obj/item/weapon/gun/smg/ppsh

/obj/item/ammo_magazine/smg/ppsh/extended
	name = "\improper PPSh-17b extended magazine (7.62x25mm)"
	max_rounds = 71


//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/ammo_magazine/smg/uzi //Based on the Uzi.
	name = "\improper MAC-15 magazine (9mm)"
	desc = "A magazine for the MAC-15."
	caliber = "9mm"
	icon_state = "mac15"
	max_rounds = 32 //Can also be 20, 25, 40, and 50.
	gun_type = /obj/item/weapon/gun/smg/uzi

/obj/item/ammo_magazine/smg/uzi/extended
	name = "\improper MAC-15 extended magazine (9mm)"
	max_rounds = 50


//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/ammo_magazine/smg/p90
	name = "FN FP9000 magazine (5.7x28mm)"
	desc = "A magazine for the FN FP9000 SMG."
	default_ammo = /datum/ammo/bullet/smg/ap
	caliber = "5.7x28mm"
	icon_state = "FP9000"
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/smg/p90
