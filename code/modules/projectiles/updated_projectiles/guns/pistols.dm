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
	name = "M4A3 Pistol Magazine (9mm)"
	caliber = "9mm"
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 12
	default_ammo = "pistol bullet"
	gun_type = /obj/item/weapon/gun/pistol/m4a3
	handful_type = "Bullets (9mm)"

/obj/item/ammo_magazine/pistol/hp
	name = "Hollowpoint Pistol Mag (9mm)"
	default_ammo = "hollowpoint pistol bullet"
	handful_type = "Hollowpoint Bullets (9mm)"

/obj/item/ammo_magazine/pistol/ap
	name = "AP Pistol Mag (9mm)"
	default_ammo = "AP pistol bullet"
	handful_type = "AP Bullets (9mm)"

/obj/item/ammo_magazine/pistol/incendiary
	name = "Incendiary Pistol Magazine (9mm)"
	default_ammo = "incendiary pistol bullet"
	handful_type = "Incendiary Bullets (9mm)"
	max_rounds = 10

/obj/item/ammo_magazine/pistol/extended
	name = "Extended Pistol Magazine (9mm)"
	max_rounds = 22
	icon_state = "9mm_mag"
	icon_empty = "9mm_mag0"
	bonus_overlay = "pistol_mag"

/obj/item/weapon/gun/pistol/m4a3
	name = "\improper M4A3 Service Pistol"
	desc = "An M4A3 Colt Service Pistol, the standard issue sidearm of the Colonial Marines. Uses 9mm pistol rounds."
	icon_state = "colt1"
	item_state = "m4a3"
	fire_sound = 'sound/weapons/servicepistol.ogg'
	mag_type = /obj/item/ammo_magazine/pistol
	fire_delay = 2
	w_class = 2
	force = 6

	New()
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17)

//-------------------------------------------------------
//DEAGLE

/obj/item/ammo_magazine/pistol/heavy
	name = "Heavy Pistol Magazine (.50)"
	default_ammo = "heavy pistol bullet"
	caliber = ".50"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/pistol/heavy
	handful_type = "Bullets (.50)"

//Captain's vintage pistol.
/obj/item/weapon/gun/pistol/heavy
	name = "\improper Vintage Desert Eagle"
	desc = "A bulky 50 caliber pistol with a serious kick. This one is engraved, 'Peace through superior firepower.'"
	icon_state = "deagle"
	item_state = "deagle"
	fire_sound = 'sound/weapons/44mag.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/heavy
	fire_delay = 9
	force = 13
	recoil = 2
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..() //Pick some variant sprites.
		icon_state = pick("deagle","deagleg","deaglecamo")
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 23, "under_x" = 20, "under_y" = 17)

//-------------------------------------------------------
//MAUSER MERC PISTOL

/obj/item/ammo_magazine/pistol/c99
	name = "PK-9 Pistol Magazine (9mm HP)"
	default_ammo = "hollowpoint pistol bullet"
	handful_type = "9mm"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 16
	gun_type = /obj/item/weapon/gun/pistol/c99
	handful_type = "Hollowpoint Bullets (9mm)"

/obj/item/weapon/gun/pistol/c99
	name = "\improper Korovin PK-9 Pistol"
	desc = "An updated variant of an russian old design, dating back to from the 19th century. Commonly found among mercenary companies due to its reliability, but also issued to armed forces. Comes pre-loaded with hollowpoint rounds and features an integrated silencer."
	icon_state = "p08"
	item_state = "p08"
	origin_tech = "combat=3;materials=1;syndicate=3"
	fire_sound = 'sound/weapons/p08.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/c99
	fire_delay = 3
	force = 6
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()//Making the gun have an invisible silencer since it's supposed to have one.
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 18)
		var/obj/item/attachable/suppressor/S = new(src)
		S.icon_state = ""
		S.can_be_removed = 0
		S.Attach(src)
		update_attachables()

/obj/item/weapon/gun/pistol/c99/russian
	icon_state = "russianp08"
	item_state = "russianp08"
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_RUSSIANS

//-------------------------------------------------------
//HIGH TECH PISTOL

/obj/item/ammo_magazine/pistol/m1911
	name = "M1911 Pulse Pistol Magazine (.40 Caseless)"
	default_ammo = "heavy pistol bullet"
	caliber = ".40 Caseless"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/pistol/m1911
	handful_type = "Bullets (.40 Caseless)"

/obj/item/weapon/gun/pistol/m1911
	name = "\improper M1911 Pulse Pistol"
	desc = "A modern variant of an old design, using the same technology found in the M41 series of Pulse Rifles."
	icon_state = "m1911-p"
	icon_empty = "m1911-p0"
	item_state = "m4a3"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshot_glock.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/m1911
	eject_casings = 0
	fire_delay = 2
	force = 9
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS | GUN_ON_RUSSIANS

	New()
		..()
		attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 10, "rail_y" = 22, "under_x" = 21, "under_y" = 17)

//-------------------------------------------------------
//GENERIC .32 PISTOL

/obj/item/ammo_magazine/pistol/automatic
	name = "Automatic Pistol Mag (.32)"
	caliber = ".32"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 21
	gun_type = /obj/item/weapon/gun/pistol/kt42
	handful_type = "Bullets (.32)"

/obj/item/weapon/gun/pistol/kt42
	name = "\improper KT-42 Automag"
	desc = "The KT-42 Automag is an archaic but reliable design, going back many decades. There have been many versions and variations, but the 42 is by far the most common. It is a simple, rapid firing 32 calibre pistol."
	icon_state = "autopistol"
	item_state = "autopistol"
	fire_sound = 'sound/weapons/automag.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/automatic
	fire_delay = 4
	burst_amount = 2
	burst_delay = 1
	recoil = 1
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 22, "under_y" = 17)

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "Pistol Magazine (.22)"
	default_ammo = "light pistol bullet"
	caliber = ".22"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 5
	gun_type = /obj/item/weapon/gun/pistol/holdout
	handful_type = "Bullets (.22)"

/obj/item/weapon/gun/pistol/holdout
	name = "\improper Holdout Pistol"
	desc = "A tiny 22-calibre pistol meant for hiding in hard-to-reach areas."
	icon_state = "holdout_pistol"
	item_state = "holdout"
	origin_tech = "combat=2;materials=1"
	fire_sound = 'sound/weapons/holdout.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/holdout
	fire_delay = 1
	w_class = 1
	force = 2
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 25, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 17, "under_y" = 15)

//-------------------------------------------------------
//.45 MARSHALS PISTOL

/obj/item/ammo_magazine/pistol/highpower
	name = "CMB Pistol Magazine (.45)"
	default_ammo = "AP pistol bullet"
	caliber = ".45"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 9
	gun_type = /obj/item/weapon/gun/pistol/highpower
	handful_type = "Bullets (.45)"

/obj/item/weapon/gun/pistol/highpower
	name = "\improper .45 Highpower Automag"
	desc = "A Colonial Marshals issued, powerful semi-automatic pistol chambered in .45 caliber rounds. Used for centuries by law enforcement and criminals alike."
	icon_state = "highpower"
	item_state = "highpower"
	fire_sound = 'sound/weapons/automag.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/highpower
	dam_bonus = 12
	fire_delay = 15
	recoil = 1
	force = 10
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 27, "muzzle_y" = 20,"rail_x" = 8, "rail_y" = 22, "under_x" = 16, "under_y" = 15)

//-------------------------------------------------------
//VP70

/obj/item/ammo_magazine/pistol/vp70
	name = "VP70 AP Magazine (9mm)"
	default_ammo = "AP pistol bullet"
	caliber = "9mm"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 9
	gun_type = /obj/item/weapon/gun/pistol/vp70
	handful_type = "AP Bullets (9mm)"

/obj/item/weapon/gun/pistol/vp70
	name = "\improper VP70 Pistol"
	desc = "A powerful sidearm issed mainly to Weyland Yutani response teams. Fires 9mm armor piercing rounds and is capable of 3-round burst."
	icon_state = "vp70"
	item_state = "vp70"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/vp70.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/vp70
	dam_bonus = 18
	burst_amount = 3
	burst_delay = 3
	force = 8

	New()
		..()
		attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 21, "under_y" = 16)

//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = "VP78 Magazine (9mm SH)"
	default_ammo = "squash-head pistol bullet"
	caliber = "9mm SH"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 18
	gun_type = /obj/item/weapon/gun/pistol/vp78
	handful_type = "Bullets (9mm SH)"

/obj/item/weapon/gun/pistol/vp78
	name = "\improper VP78 Pistol"
	desc = "A massive, formidable automatic handgun chambered in 9mm squash-head rounds. Commonly seen in the hands of wealthy Weyland Yutani members."
	icon_state = "VP78"
	item_state = "vp78"
	fire_sound = 'sound/weapons/pistol_large.ogg'
	mag_type = /obj/item/ammo_magazine/pistol/vp78
	burst_amount = 3
	burst_delay = 3
	recoil = 1
	force = 8

	New()
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 21,"rail_x" = 9, "rail_y" = 24, "under_x" = 23, "under_y" = 13)
