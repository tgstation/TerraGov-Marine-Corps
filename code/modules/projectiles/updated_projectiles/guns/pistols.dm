//Base pistol and revolver for inheritance/
//--------------------------------------------------

/obj/item/weapon/gun/pistol
	icon_state = "" //Defaults to revolver pistol when there's no sprite.
	reload_sound = 'sound/weapons/flipblade.ogg'
	cocked_sound = 'sound/weapons/pistol_cocked.ogg'
	origin_tech = "combat=3;materials=2"
	matter = list("metal" = 65000)
	slot_flags = SLOT_BELT
	w_class = 3
	fire_sound = 'sound/weapons/servicepistol.ogg'
	eject_casings = 1
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK //For easy reference.

	New()
		..()
		load_into_chamber()

//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol
	name = "\improper M4A3 magazine (9mm)"
	caliber = "9mm"
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 12
	default_ammo = "pistol bullet"
	gun_type = /obj/item/weapon/gun/pistol/m4a3

/obj/item/ammo_magazine/pistol/hp
	name = "\improper M4A3 hollowpoint magazine (9mm)"
	default_ammo = "hollowpoint pistol bullet"

/obj/item/ammo_magazine/pistol/ap
	name = "\improper M4A3 AP magazine (9mm)"
	default_ammo = "armor-piercing pistol bullet"

/obj/item/ammo_magazine/pistol/incendiary
	name = "\improper M4A3 incendiary magazine (9mm)"
	default_ammo = "incendiary pistol bullet"

/obj/item/ammo_magazine/pistol/extended
	name = "\improper M4A3 extended magazine (9mm)"
	max_rounds = 22
	icon_state = "9mm_mag"
	icon_empty = "9mm_mag0"
	bonus_overlay = "pistol_mag"

/obj/item/weapon/gun/pistol/m4a3
	name = "\improper M4A3 service pistol"
	desc = "An M4A3 Colt Service Pistol, the standard issue sidearm of the Colonial Marines. Uses 9mm pistol rounds."
	icon_state = "colt1"
	icon_empty = "colt1-0"
	item_state = "m4a3"
	fire_sound = 'sound/weapons/servicepistol.ogg'
	mag_type = /obj/item/ammo_magazine/pistol
	fire_delay = 7
	w_class = 2
	force = 6

	New()
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17)
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "colt1") //Only change this one
				icon_state = "colt3"
				icon_empty = "colt3-0" //Pump shotguns don't really have 'empty' states.
				item_state = "m4a3S"

/obj/item/weapon/gun/pistol/m4a3/custom
	name = "\improper M4A3 custom pistol"
	desc = "An M4A3 Service Pistol, the standard issue sidearm of the Colonial Marines. Uses 9mm pistol rounds. This one is crested with an elephant-tusk ivory grip and has a slide carefully polished by a team of orphan children. Looks important."
	icon_state = "colt2"
	icon_empty = "colt2-0"
	item_state = "COlt"
	damage = 7
	fire_delay = 5


//-------------------------------------------------------
//DEAGLE //This one is obvious.

/obj/item/ammo_magazine/pistol/heavy
	name = "\improper Desert Eagle magazine (.50)"
	default_ammo = "heavy pistol bullet"
	caliber = ".50"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/heavy

//Captain's vintage pistol.
/obj/item/weapon/gun/pistol/heavy
	name = "\improper vintage Desert Eagle"
	desc = "A bulky 50 caliber pistol with a serious kick, probably taken from some museum somewhere. This one is engraved, 'Peace through superior firepower.'"
	icon_state = "deagle"
	item_state = "deagle"
	fire_sound = 'sound/weapons/44mag.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/heavy
	damage = 10 //Youch.
	fire_delay = 9
	force = 13
	recoil = 2
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..() //Pick some variant sprites.
		icon_state = pick("deagle","deagleg","deaglecamo")
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 23, "under_x" = 20, "under_y" = 17)

//-------------------------------------------------------
//MAUSER MERC PISTOL //Inspired by the Makarov.

/obj/item/ammo_magazine/pistol/c99
	name = "\improper PK-9 magazine (9mmM)"
	default_ammo = "hollowpoint pistol bullet"
	caliber = ".9mmM"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/pistol/c99

/obj/item/weapon/gun/pistol/c99
	name = "\improper Korovin PK-9 pistol"
	desc = "An updated variant of an old Russian design, dating back to from the 19th century. Commonly found among mercenary companies due to its reliability, but also issued to armed forces. Features extended magazine capacity and an integrated silencer."
	icon_state = "p08"
	item_state = "p08"
	origin_tech = "combat=3;materials=1;syndicate=3"
	fire_sound = 'sound/weapons/p08.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/c99
	fire_delay = 5
	force = 6
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()//Making the gun have an invisible silencer since it's supposed to have one.
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18)
		var/obj/item/attachable/suppressor/S = new(src)
		S.icon_state = ""
		S.attach_features &= ~ATTACH_REMOVABLE
		S.Attach(src)
		update_attachables()

/obj/item/weapon/gun/pistol/c99/russian
	icon_state = "russianp08"
	item_state = "russianp08"
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_RUSSIANS

//-------------------------------------------------------
//HIGH TECH PISTOL //Inspired by the 1911

/obj/item/ammo_magazine/pistol/m1911
	name = "\improper M4A3 magazine (.45)"
	default_ammo = "heavy pistol bullet"
	caliber = ".45"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/m1911

/obj/item/weapon/gun/pistol/m1911
	name = "\improper M4A3 service pistol (.45)"
	desc = "A standard M4A3 chambered in .45 rounds. Has a smaller magazine capacity, but packs a better punch."
	icon_state = "m1911-p"
	icon_empty = "m1911-p0"
	item_state = "m4a3"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshot_glock.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/m1911
	fire_delay = 7
	force = 9
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS | GUN_ON_RUSSIANS

	New()
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17)

//-------------------------------------------------------
//GENERIC .32 PISTOL //Inspired by the .44 Auto Mag pistol

/obj/item/ammo_magazine/pistol/automatic
	name = "\improper KT-42 magazine (.44)"
	default_ammo = "heavy pistol bullet"
	caliber = ".32"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/pistol/kt42

/obj/item/weapon/gun/pistol/kt42
	name = "\improper KT-42 automag"
	desc = "The KT-42 Automag is an archaic but reliable design, going back many decades. There have been many versions and variations, but the 42 is by far the most common. You can't go wrong with this handcannon."
	icon_state = "autopistol"
	item_state = "autopistol"
	fire_sound = 'sound/weapons/automag.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/automatic
	fire_delay = 10
	recoil = 1
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 22, "under_y" = 17)

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "tiny pistol magazine (.22)"
	default_ammo = "light pistol bullet"
	caliber = ".22"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 5
	gun_type = /obj/item/weapon/gun/pistol/holdout

/obj/item/weapon/gun/pistol/holdout
	name = "holdout pistol"
	desc = "A tiny pistol meant for hiding in hard-to-reach areas. Best not ask where it came from."
	icon_state = "holdout_pistol"
	item_state = "holdout"
	origin_tech = "combat=2;materials=1"
	fire_sound = 'sound/weapons/holdout.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/holdout
	fire_delay = 2
	w_class = 1
	force = 2
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 17, "under_y" = 15)

//-------------------------------------------------------
//.45 MARSHALS PISTOL //Inspired by the Browning Hipower

/obj/item/ammo_magazine/pistol/highpower
	name = "\improper Highpower magazine (9mm)"
	default_ammo = "armor-piercing pistol bullet"
	caliber = "9mm"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 13
	gun_type = /obj/item/weapon/gun/pistol/highpower

/obj/item/weapon/gun/pistol/highpower
	name = "\improper Highpower automag"
	desc = "A Colonial Marshals issued, powerful semi-automatic pistol chambered in armor piercing 9mm caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	icon_state = "highpower"
	item_state = "highpower"
	fire_sound = 'sound/weapons/automag.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/highpower
	damage = 7
	recoil = 1
	force = 10
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 16, "under_y" = 15)

//-------------------------------------------------------
//VP70 //Not actually the VP70, but it's more or less the same thing. VP70 was the standard sidearm in Aliens though.

/obj/item/ammo_magazine/pistol/vp70
	name = "\improper 88M4 AP magazine (9mm)"
	default_ammo = "armor-piercing pistol bullet"
	caliber = "9mm"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp70

/obj/item/weapon/gun/pistol/vp70
	name = "\improper 88 Mod 4 combat pistol"
	desc = "A powerful sidearm issed mainly to Weyland Yutani response teams, but issued to the USCM in small numbers, based on the original vp70 more than a century ago. Fires 9mm armor piercing rounds and is capable of 3-round burst."
	icon_state = "vp70"
	item_state = "vp70"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/vp70.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/vp70
	damage = 13
	burst_amount = 3
	burst_delay = 3
	force = 8

	New()
		..()
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 21, "under_y" = 16)

//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = "\improper VP78 magazine (9mm)"
	default_ammo = "squash-head pistol bullet"
	caliber = "9mm"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp78

/obj/item/weapon/gun/pistol/vp78
	name = "\improper VP78 pistol"
	desc = "A massive, formidable automatic handgun chambered in 9mm squash-head rounds. Commonly seen in the hands of wealthy Weyland Yutani members."
	icon_state = "VP78"
	item_state = "vp78"
	fire_sound = 'sound/weapons/pistol_large.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/vp78
	fire_delay = 9
	burst_amount = 3
	burst_delay = 3
	recoil = 1
	force = 8

	New()
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 24, "under_x" = 23, "under_y" = 13)
