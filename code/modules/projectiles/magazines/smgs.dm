/obj/item/ammo_magazine/smg
	name = "\improper SMG magazine"
	desc = "A submachinegun magazine."
	default_ammo = /datum/ammo/bullet/smg
	max_rounds = 30
	icon_state_mini = "mag_smg"

//-------------------------------------------------------
//M25 SMG ammo

/obj/item/ammo_magazine/smg/m25
	name = "\improper SMG-25 magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine."
	caliber = CALIBER_10X20_CASELESS
	icon_state = "m25"
	max_rounds = 60
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/smg/m25/ap
	name = "\improper SMG-25 AP magazine (10x20mm)"
	icon_state = "m25_ap"
	default_ammo = /datum/ammo/bullet/smg/ap
	icon_state_mini = "mag_smg_green"
	bonus_overlay = "m25_ap"

/obj/item/ammo_magazine/smg/m25/extended
	name = "\improper SMG-25 extended magazine (10x20mm)"
	icon_state = "m25_ext"
	max_rounds = 90
	icon_state_mini = "mag_smg_yellow"
	bonus_overlay = "m25_ex"

//-------------------------------------------------------
//MP-19 Machinepistol ammo

/obj/item/ammo_magazine/smg/standard_machinepistol
	name = "\improper MP-19 machinepistol magazine (10x20mm)"
	desc = "A 10x20mm caseless machine pistol magazine."
	caliber = CALIBER_10X20_CASELESS
	icon_state = "t19"
	max_rounds = 30
	w_class = WEIGHT_CLASS_SMALL

//-------------------------------------------------------
//SMG-90 SMG ammo

/obj/item/ammo_magazine/smg/standard_smg
	name = "\improper SMG-90 submachine gun magazine (10x20mm)"
	desc = "A 10x20mm caseless submachine gun magazine."
	caliber = CALIBER_10X20_CASELESS
	icon_state = "t90"
	max_rounds = 50
	w_class = WEIGHT_CLASS_SMALL
	icon_state_mini = "mag_t90"

//-------------------------------------------------------
//SMG-27, based on the SMG-27, based on the M7.

/obj/item/ammo_magazine/smg/mp7
	name = "\improper SMG-27 magazine (4.6x30mm)"
	desc = "A 4.6mm magazine for the SMG-27."
	default_ammo = /datum/ammo/bullet/smg/ap
	caliber = CALIBER_46X30
	icon_state = "mp7"
	max_rounds = 30


//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/ammo_magazine/smg/skorpion
	name = "\improper CZ-81 magazine (.32ACP)"
	desc = "A .32ACP caliber magazine for the CZ-81."
	caliber = CALIBER_32ACP
	icon_state = "skorpion"
	max_rounds = 20 //Can also be 10.


//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/ammo_magazine/smg/ppsh
	name = "\improper PPSh-17b magazine (7.62x25mm)"
	desc = "A drum magazine for the PPSh submachinegun."
	default_ammo = /datum/ammo/bullet/smg
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_762X25
	icon_state = "ppsh"
	max_rounds = 42
	bonus_overlay = "ppsh_standard"


/obj/item/ammo_magazine/smg/ppsh/extended
	name = "\improper PPSh-17b drum magazine (7.62x25mm)"
	icon_state = "ppsh_ext"
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 78
	bonus_overlay = "ppsh_ex"
	scatter_mod = 5
	scatter_unwielded_mod = 10
	wield_delay_mod = 0.2 SECONDS
	aim_speed_mod = 0.3

//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/ammo_magazine/smg/uzi
	name = "\improper SMG-2 magazine (9mm)"
	desc = "A magazine for the SMG-2."
	caliber = CALIBER_9X21
	icon_state = "uzi"
	max_rounds = 32

/obj/item/ammo_magazine/smg/uzi/extended
	name = "\improper GAL9 extended magazine (9mm)"
	icon_state = "uzi_ext"
	max_rounds = 50
	bonus_overlay = "uzi_ex"
	icon_state_mini = "mag_smg_yellow"

//-------------------------------------------------------
//V-21 SOM SMG

/obj/item/ammo_magazine/smg/som
	name = "\improper V-21 submachinegun magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine."
	caliber = CALIBER_10X20_CASELESS
	icon_state = "v21"
	max_rounds = 50
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/smg/som/ap
	name = "\improper V-21 AP submachinegun magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine, loaded in armor piercing rounds."
	icon_state = "v21_ap"
	default_ammo = /datum/ammo/bullet/smg/ap
	icon_state_mini = "mag_smg_green"

/obj/item/ammo_magazine/smg/som/incendiary
	name = "\improper V-21 incendiary submachinegun magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine, loaded in incendiary rounds."
	icon_state = "v21_incend"
	default_ammo = /datum/ammo/bullet/smg/incendiary
	icon_state_mini = "mag_smg_green"

/obj/item/ammo_magazine/smg/som/extended
	name = "\improper V-21 extended submachinegun magazine (10x20mm)"
	desc = "An extended 10x20mm caseless submachinegun magazine."
	icon_state = "v21_extended"
	max_rounds = 75
	icon_state_mini = "mag_smg_yellow"
	w_class = WEIGHT_CLASS_NORMAL
	aim_speed_mod = 0.1
