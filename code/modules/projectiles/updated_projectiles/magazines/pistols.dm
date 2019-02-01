
//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol
	name = " M4A3 magazine (9mm)"
	desc = "A pistol magazine."
	caliber = "9mm"
	icon_state = "m4a3"
	max_rounds = 12
	w_class = 2
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/m4a3

/obj/item/ammo_magazine/pistol/hp
	name = " M4A3 hollowpoint magazine (9mm)"
	icon_state = "m4a3_HP"
	default_ammo = /datum/ammo/bullet/pistol/hollow

/obj/item/ammo_magazine/pistol/ap
	name = " M4A3 AP magazine (9mm)"
	icon_state = "m4a3_AP"
	default_ammo = /datum/ammo/bullet/pistol/ap

/obj/item/ammo_magazine/pistol/incendiary
	name = " M4A3 incendiary magazine (9mm)"
	icon_state = "m4a3_incendiary"
	default_ammo = /datum/ammo/bullet/pistol/incendiary

/obj/item/ammo_magazine/pistol/extended
	name = " M4A3 extended magazine (9mm)"
	max_rounds = 22
	icon_state = "m4a3_ext"
	bonus_overlay = "m4a3_ex"


//-------------------------------------------------------
//M4A3 45 //Inspired by the 1911

/obj/item/ammo_magazine/pistol/m1911
	name = " M4A3 magazine (.45)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".45"
	icon_state = "m4a345"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/m1911


//-------------------------------------------------------
//Beretta 92FS, the gun McClane carries around in Die Hard. Very similar to the service pistol, all around.

/obj/item/ammo_magazine/pistol/b92fs
	name = " Beretta 92FS magazine (9mm)"
	caliber = "9mm"
	icon_state = "m4a3"
	max_rounds = 15
	default_ammo = /datum/ammo/bullet/pistol
	gun_type = /obj/item/weapon/gun/pistol/b92fs

/obj/item/ammo_magazine/pistol/b92fstranq
	name = " M9 tranq magazine (9mm)"
	caliber = "9mm"
	icon_state = "m4a3"
	max_rounds = 12
	default_ammo = /datum/ammo/bullet/pistol/tranq
	gun_type = /obj/item/weapon/gun/pistol/b92fs/M9

//-------------------------------------------------------
//DEAGLE //This one is obvious.

/obj/item/ammo_magazine/pistol/heavy
	name = " Desert Eagle magazine (.50)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".50"
	icon_state = "m4a345" //PLACEHOLDER
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/heavy



//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/ammo_magazine/pistol/c99t
	name = " PK-9 magazine (.22 tranq)"
	default_ammo = /datum/ammo/bullet/pistol/tranq
	caliber = ".22"
	icon_state = "pk-9_tranq"
	max_rounds = 8
	gun_type = /obj/item/weapon/gun/pistol/c99

/obj/item/ammo_magazine/pistol/c99
	name = " PK-9 magazine (.22 hollowpoint)"
	default_ammo = /datum/ammo/bullet/pistol/hollow
	caliber = ".22"
	icon_state = "pk-9"
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/pistol/c99


//-------------------------------------------------------
//KT-42 //Inspired by the .44 Auto Mag pistol

/obj/item/ammo_magazine/pistol/automatic
	name = " KT-42 magazine (.44)"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	caliber = ".32"
	icon_state = "kt42"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/kt42


//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "tiny pistol magazine (.22)"
	desc = "A surprisingly small magazine, holding .22 bullets. No Kolibri, but it's getting there."
	default_ammo = /datum/ammo/bullet/pistol/tiny
	caliber = ".22"
	icon_state = "m4a3" //PLACEHOLDER
	max_rounds = 5
	w_class = 1
	gun_type = /obj/item/weapon/gun/pistol/holdout


//-------------------------------------------------------
//.45 MARSHALS PISTOL //Inspired by the Browning Hipower

/obj/item/ammo_magazine/pistol/highpower
	name = " Highpower magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = "9mm"
	icon_state = "m4a3" //PLACEHOLDER
	max_rounds = 13
	gun_type = /obj/item/weapon/gun/pistol/highpower


//-------------------------------------------------------
//VP70 //Not actually the VP70, but it's more or less the same thing. VP70 was the standard sidearm in Aliens though.

/obj/item/ammo_magazine/pistol/vp70
	name = " 88M4 AP magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/ap
	caliber = "9mm"
	icon_state = "88m4"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp70


//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = " VP78 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = "9mm"
	icon_state = "88m4" //PLACEHOLDER
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp78


//-------------------------------------------------------
/*
Auto 9 The gun RoboCop uses. A better version of the VP78, with more rounds per magazine. Probably the best pistol around, but takes no attachments.
It is a modified Beretta 93R, and can fire three round burst or single fire. Whether or not anyone else aside RoboCop can use it is not established.
*/

/obj/item/ammo_magazine/pistol/auto9
	name = " Auto-9 magazine (9mm)"
	default_ammo = /datum/ammo/bullet/pistol/squash
	caliber = "9mm"
	icon_state = "88m4" //PLACEHOLDER
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/pistol/auto9



//-------------------------------------------------------
//The first rule of monkey pistol is we don't talk about monkey pistol.
/obj/item/ammo_magazine/pistol/chimp
	name = " CHIMP70 magazine (.70M)"
	default_ammo = /datum/ammo/bullet/pistol/mankey
	caliber = ".70M"
	icon_state = "c70" //PLACEHOLDER
	origin_tech = "combat=8;materials=8;syndicate=8;bluespace=8"
	matter = list("metal" = 3000)
	max_rounds = 300
	gun_type = /obj/item/weapon/gun/pistol/chimp

