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
	handle_casing = EJECT_CASINGS

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
	default_ammo = "/datum/ammo/bullet/pistol"
	gun_type = "/obj/item/weapon/gun/pistol/m4a3"
	handful_type = "Bullets (9mm)"

/obj/item/ammo_magazine/pistol/hp
	name = "Hollowpoint Pistol Mag (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/hollow"

/obj/item/ammo_magazine/pistol/ap
	name = "AP Pistol Mag (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/ap"

/obj/item/ammo_magazine/pistol/incendiary
	name = "Incendiary Pistol Magazine (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/incendiary"
	max_rounds = 10

/obj/item/ammo_magazine/pistol/extended
	name = "Extended Pistol Magazine (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol"
	max_rounds = 22
	icon_state = ".45e"
	icon_empty = ".45e0"
	bonus_overlay = "pistol_mag"

/obj/item/weapon/gun/pistol/m4a3
	name = "\improper M4A3 Service Pistol"
	desc = "An M4A3 Colt Service Pistol, the standard issue sidearm of the Colonial Marines. Uses 9mm pistol rounds."
	icon_state = "colt1"
	item_state = "m4a3"
	mag_type = "/obj/item/ammo_magazine/pistol"
	fire_sound = 'sound/weapons/servicepistol.ogg'
	fire_delay = 2
	recoil = 0
	w_class = 2
	force = 6
	muzzle_pixel_x = 28
	muzzle_pixel_y = 20
	rail_pixel_x = 10
	rail_pixel_y = 22
	under_pixel_x = 21
	under_pixel_y = 17

	New()
		..()
		icon_state = pick("colt1","colt2")

//-------------------------------------------------------
//DEAGLE

/obj/item/ammo_magazine/pistol/heavy
	name = "Heavy Pistol Magazine (.50)"
	default_ammo = "/datum/ammo/bullet/pistol/heavy"
	caliber = ".50"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 12
	gun_type = "/obj/item/weapon/gun/pistol/heavy"
	handful_type = "Bullets (.50)"

//Captain's vintage pistol.
/obj/item/weapon/gun/pistol/heavy
	name = "\improper Vintage Desert Eagle"
	desc = "A bulky 50 caliber pistol with a serious kick. This one is engraved, 'Peace through superior firepower.'"
	icon_state = "deagle"
	item_state = "deagle"
	fire_sound = 'sound/weapons/44mag.ogg'
	mag_type = "/obj/item/ammo_magazine/pistol/heavy"
	fire_sound = 'sound/weapons/pistol_large.ogg'
	fire_delay = 9
	force = 13
	recoil = 2
	muzzle_pixel_x = 31
	muzzle_pixel_y = 21
	rail_pixel_x = 9
	rail_pixel_y = 23
	under_pixel_x = 20
	under_pixel_y = 17
	found_on_mercs = 1

	New()
		..() //Pick some variant sprites.
		icon_state = pick("deagle","deagleg","deaglecamo")

//-------------------------------------------------------
//MAUSER MERC PISTOL

/obj/item/ammo_magazine/pistol/c99
	name = "PK-9 Pistol Magazine (9mm HP)"
	default_ammo = "/datum/ammo/bullet/pistol/hollow"
	handful_type = "9mm"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 16
	gun_type = "/obj/item/weapon/gun/pistol/c99"
	handful_type = "HP Bullets (9mm)"

/obj/item/weapon/gun/pistol/c99
	name = "\improper Korovin PK-9 Pistol"
	desc = "An updated variant of an russian old design, dating back to from the 19th century. Commonly found among mercenary companies due to its reliability, but also issued to armed forces. Comes pre-loaded with hollowpoint rounds and features an integrated silencer."
	icon_state = "p08"
	item_state = "p08"
	origin_tech = "combat=3;materials=1;syndicate=3"
	fire_sound = 'sound/weapons/p08.ogg'
	mag_type = "/obj/item/ammo_magazine/pistol/c99"
	fire_sound = 'sound/weapons/p08.ogg'
	fire_delay = 3
	force = 6
	recoil = 0
	muzzle_pixel_x = 30
	muzzle_pixel_y = 19
	rail_pixel_x = 10
	rail_pixel_y = 22
	under_pixel_x = 21
	under_pixel_y = 18
	found_on_mercs = 1
	found_on_russians = 0

	New()//Making the gun have an invisible silencer since it's supposed to have one.
		..()
		var/obj/item/attachable/suppressor/S = new(src)
		S.icon_state = ""
		S.can_be_removed = 0
		S.Attach(src)
		update_attachables()

/obj/item/weapon/gun/pistol/c99/russian
	found_on_russians = 1
	found_on_mercs = 0
	icon_state = "russianp08"
	item_state = "russianp08"
//-------------------------------------------------------
//HIGH TECH PISTOL

/obj/item/ammo_magazine/pistol/m1911
	name = "M1911 Pulse Pistol Magazine (.40 Caseless)"
	default_ammo = "/datum/ammo/bullet/pistol/heavy"
	caliber = ".40 Caseless"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 12
	gun_type = "/obj/item/weapon/gun/pistol/m1911"
	handful_type = "Bullets (.40 Caseless)"

/obj/item/weapon/gun/pistol/m1911
	name = "\improper M1911 Pulse Pistol"
	desc = "A modern variant of an old design, using the same technology found in the M41 series of Pulse Rifles."
	icon_state = "m1911-p"
	icon_empty = "m1911-p0"
	item_state = "m4a3"
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/44mag.ogg'
	mag_type = "/obj/item/ammo_magazine/pistol/m1911"
	fire_sound = 'sound/weapons/gunshot_glock.ogg'
	handle_casing = CLEAR_CASINGS
	fire_delay = 2
	force = 1
	recoil = 0
	muzzle_pixel_x = 28
	muzzle_pixel_y = 20
	rail_pixel_x = 10
	rail_pixel_y = 22
	under_pixel_x = 21
	under_pixel_y = 17
	found_on_mercs = 1
	found_on_russians = 1

//-------------------------------------------------------
//GENERIC .32 PISTOL

/obj/item/ammo_magazine/pistol/automatic
	name = "Automatic Pistol Mag (.32)"
	default_ammo = "/datum/ammo/bullet/pistol"
	caliber = ".32"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 21
	gun_type = "/obj/item/weapon/gun/pistol/kt42"
	handful_type = "Bullets (.32)"

/obj/item/weapon/gun/pistol/kt42
	name = "\improper KT-42 Automag"
	desc = "The KT-42 Automag is an archaic but reliable design, going back many decades. There have been many versions and variations, but the 42 is by far the most common. It is a simple, rapid firing 32 calibre pistol."
	icon_state = "autopistol"
	item_state = "autopistol" //Invisible in hand.
	mag_type = "/obj/item/ammo_magazine/pistol/automatic"
	fire_sound = 'sound/weapons/automag.ogg'
	fire_delay = 4
	burst_amount = 2
	burst_delay = 1
	recoil = 1
	force = 5
	muzzle_pixel_x = 32
	muzzle_pixel_y = 20
	rail_pixel_x = 8
	rail_pixel_y = 22
	under_pixel_x = 22
	under_pixel_y = 17
	found_on_mercs = 1

//-------------------------------------------------------
//PIZZACHIMP PROTECTION

/obj/item/ammo_magazine/pistol/holdout
	name = "Pistol Magazine (.22)"
	default_ammo = "/datum/ammo/bullet/pistol/tiny"
	caliber = ".22"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 5
	gun_type = "/obj/item/weapon/gun/pistol/holdout"
	handful_type = "Bullets (.22)"

/obj/item/weapon/gun/pistol/holdout
	name = "\improper Holdout Pistol"
	desc = "A tiny 22-calibre pistol meant for hiding in hard-to-reach areas."
	icon_state = "holdout_pistol"
	item_state = "holdout"
	origin_tech = "combat=2;materials=1"
	mag_type = "/obj/item/ammo_magazine/pistol/holdout"
	fire_sound = 'sound/weapons/holdout.ogg'
	fire_delay = 1
	recoil = 0
	w_class = 1
	force = 2
	muzzle_pixel_x = 25
	muzzle_pixel_y = 20
	rail_pixel_x = 12
	rail_pixel_y = 22
	under_pixel_x = 17
	under_pixel_y = 15
	found_on_mercs = 1

//-------------------------------------------------------
//.45 MARSHALS PISTOL

/obj/item/ammo_magazine/pistol/highpower
	name = "CMB Pistol Magazine (.45)"
	default_ammo = "/datum/ammo/bullet/pistol/ap"
	caliber = ".45"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 9
	gun_type = "/obj/item/weapon/gun/pistol/highpower"
	handful_type = "Bullets (.45)"

/obj/item/weapon/gun/pistol/highpower
	name = "\improper .45 Highpower Automag"
	desc = "A Colonial Marshals issued, powerful semi-automatic pistol chambered in .45 caliber rounds. Used for centuries by law enforcement and criminals alike."
	icon_state = "highpower"
	item_state = "highpower"
	mag_type = "/obj/item/ammo_magazine/pistol/highpower"
	fire_sound = 'sound/weapons/automag.ogg'
	fire_delay = 15
	recoil = 1
	w_class = 3
	force = 10
	muzzle_pixel_x = 27
	muzzle_pixel_y = 20
	rail_pixel_x = 8
	rail_pixel_y = 22
	under_pixel_x = 16
	under_pixel_y = 15
	found_on_mercs = 1
	dam_bonus = 20 //She a beefy pistol meng

//-------------------------------------------------------
//VP70

/obj/item/ammo_magazine/pistol/vp70
	name = "VP70 AP Magazine (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/ap"
	caliber = "9mm"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 9
	gun_type = "/obj/item/weapon/gun/pistol/vp70"
	handful_type = "AP Bullets (9mm)"

/obj/item/weapon/gun/pistol/vp70
	name = "\improper VP70 Pistol"
	desc = "A powerful sidearm issed mainly to Weyland Yutani response teams. Fires 9mm armor piercing rounds and is capable of 3-round burst."
	icon_state = "vp70"
	item_state = "vp70"
	origin_tech = "combat=4;materials=3"
	mag_type = "/obj/item/ammo_magazine/pistol/vp70"
	fire_sound = 'sound/weapons/vp70.ogg'
	fire_delay = 6
	burst_amount = 3
	burst_delay = 3
	recoil = 0
	w_class = 3
	force = 8
	muzzle_pixel_x = 31
	muzzle_pixel_y = 20
	rail_pixel_x = 11
	rail_pixel_y = 22
	under_pixel_x = 21
	under_pixel_y = 16

//-------------------------------------------------------
//VP78

/obj/item/ammo_magazine/pistol/vp78
	name = "VP78 Magazine (9mm Spec)"
	default_ammo = "/datum/ammo/bullet/pistol/incendiary/vp78"
	caliber = "9mm Spec"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 18
	gun_type = "/obj/item/weapon/gun/pistol/vp78"
	handful_type = "Bullets (9mm Spec)"

/obj/item/weapon/gun/pistol/vp78
	name = "\improper VP78 Pistol"
	desc = "A massive formidable automatic handgun chambered in 9mm Special rounds. These will light targets on fire. Inscribed on the side is, 'Smells like napalm'. Commonly seen in the hands of wealthy Weyland Yutani members."
	icon_state = "VP78"
	item_state = "vp78"
	mag_type = "/obj/item/ammo_magazine/pistol/vp78"
	fire_sound = 'sound/weapons/pistol_large.ogg'
	fire_delay = 6
	burst_amount = 3
	burst_delay = 3
	recoil = 1
	w_class = 3
	force = 8
	muzzle_pixel_x = 30
	muzzle_pixel_y = 21
	rail_pixel_x = 9
	rail_pixel_y = 24
	under_pixel_x = 23
	under_pixel_y = 13
