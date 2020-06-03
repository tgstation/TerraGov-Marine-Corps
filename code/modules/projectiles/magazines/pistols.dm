
//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol/standard_pistol
	name = "\improper TP-14 magazine (9mm)"
	desc = "A pistol magazine."
	caliber = "9x19mm Parabellum"
	icon_state = "tp14"
	max_rounds = 14
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/standard_pistol


//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol
	name = "\improper M4A3 magazine (9mm)"
	desc = "A pistol magazine."
	caliber = "9x19mm Parabellum"
	icon_state = "m4a3"
	max_rounds = 14
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/m4a3

/obj/item/ammo_magazine/pistol/hp
	name = "\improper M4A3 hollowpoint magazine (9mm)"
	icon_state = "m4a3_hp"
	default_ammo = /datum/ammo/bullet/pistol/hollow

/obj/item/ammo_magazine/pistol/ap
	name = "\improper M4A3 AP magazine (9mm)"
	icon_state = "m4a3_ap"
	default_ammo = /datum/ammo/bullet/pistol/ap

/obj/item/ammo_magazine/pistol/incendiary
	name = "\improper M4A3 incendiary magazine (9mm)"
	icon_state = "m4a3_incendiary"
	default_ammo = /datum/ammo/bullet/pistol/incendiary

/obj/item/ammo_magazine/pistol/extended
	name = "\improper M4A3 extended magazine (9mm)"
	max_rounds = 24
	icon_state = "m4a3_ext"
	bonus_overlay = "m4a3_ex"


//-------------------------------------------------------
//M1911

/obj/item/ammo_magazine/pistol/m1911
	name = "\improper M1911 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".45 ACP"
	icon_state = ".45"
	max_rounds = 10
	gun_type = /obj/item/weapon/gun/pistol/m1911

/obj/item/ammo_magazine/acp
	name = "Box of .45 ACP"
	icon_state = "box45" //With thanks to Eris
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".45 ACP"
	current_rounds = 50
	max_rounds = 50


//-------------------------------------------------------
//TP-23

/obj/item/ammo_magazine/pistol/standard_heavypistol
	name = "\improper TP-23 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".45 ACP"
	icon_state = ".45"
	max_rounds = 11
	gun_type = /obj/item/weapon/gun/pistol/standard_heavypistol


//-------------------------------------------------------
//Beretta 92FS, the gun McClane carries around in Die Hard. Very similar to the service pistol, all around.

/obj/item/ammo_magazine/pistol/b92fs
	name = "\improper Beretta 92FS magazine (9mm)"
	caliber = "9x19mm Parabellum"
	icon_state = "beretta"
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/b92fs

/obj/item/ammo_magazine/pistol/b93r
	name = "\improper Beretta 93R magazine (9mm)"
	caliber = "9x19mm Parabellum"
	icon_state = "beretta"
	max_rounds = 20
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/b92fs/raffica

/obj/item/ammo_magazine/pistol/b92fstranq
	name = "\improper M9 tranq magazine (9mm)"
	caliber = "9x19mm tranquilizer"
	icon_state = "beretta"
	max_rounds = 12
	default_ammo = /datum/ammo/bullet/pistol/tranq
	gun_type = /obj/item/weapon/gun/pistol/b92fs/M9


//-------------------------------------------------------
//DEAGLE //DEAGLE BRAND DEAGLE

/obj/item/ammo_magazine/pistol/heavy
	name = "\improper Desert Eagle magazine (.50)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".50 AE"
	icon_state = "50ae"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/heavy



//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/ammo_magazine/pistol/c99t
	name = "\improper PK-9 magazine (.22 tranq)"
	default_ammo = /datum/ammo/bullet/pistol/tranq
	caliber = ".22 LR"
	icon_state = "pk-9_tranq"
	max_rounds = 8
	gun_type = /obj/item/weapon/gun/pistol/c99

/obj/item/ammo_magazine/pistol/c99
	name = "\improper PK-9 magazine (.22 hollowpoint)"
	default_ammo = /datum/ammo/bullet/pistol/hollow
	caliber = ".22 LR"
	icon_state = "pk-9"
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/pistol/c99


//-------------------------------------------------------
//KT-42 //Inspired by the .44 Auto Mag pistol

/obj/item/ammo_magazine/pistol/automatic
	name = "\improper KT-42 magazine (.44)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".44 magnum"
	icon_state = "kt42"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/kt42


//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "tiny pistol magazine (.22)"
	desc = "A surprisingly small magazine, holding .22 bullets. No Kolibri, but it's getting there."
	default_ammo = /datum/ammo/bullet/pistol/tiny
	caliber = ".22 LR"
	icon_state = ".22"
	max_rounds = 5
	w_class = WEIGHT_CLASS_TINY
	gun_type = /obj/item/weapon/gun/pistol/holdout


//-------------------------------------------------------
//.45 MARSHALS PISTOL //Inspired by the Browning Hipower

/obj/item/ammo_magazine/pistol/highpower
	name = "\improper Highpower magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = "9x19mm Parabellum"
	icon_state = "m4a3" //PLACEHOLDER
	max_rounds = 13
	gun_type = /obj/item/weapon/gun/pistol/highpower


//-------------------------------------------------------
//VP70 //Not actually the VP70, but it's more or less the same thing. VP70 was the standard sidearm in Aliens though.

/obj/item/ammo_magazine/pistol/vp70
	name = "\improper 88M4 AP magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = "9x19mm Parabellum"
	icon_state = "88m4"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp70


//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = "\improper VP78 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = "9x19mm Parabellum"
	icon_state = "50ae"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp78


//-------------------------------------------------------
/*
Auto 9 The gun RoboCop uses. A better version of the VP78, with more rounds per magazine. Probably the best pistol around, but takes no attachments.
It is a modified Beretta 93R, and can fire three round burst or single fire. Whether or not anyone else aside RoboCop can use it is not established.
*/

/obj/item/ammo_magazine/pistol/auto9
	name = "\improper Auto-9 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = "9x19mm Parabellum"
	icon_state = "beretta"
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/pistol/auto9



//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = "\improper CHIMP70 magazine (.70M)"
	default_ammo = /datum/ammo/bullet/pistol/mankey
	caliber = ".70 Mankey"
	icon_state = "c70"
	max_rounds = 300
	gun_type = /obj/item/weapon/gun/pistol/chimp

