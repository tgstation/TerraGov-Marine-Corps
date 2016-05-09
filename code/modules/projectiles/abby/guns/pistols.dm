//-------------------------------------------------------
//M4A3 PISTOL

/obj/item/ammo_magazine/pistol
	name = "M4A3 Pistol Magazine (9mm)"
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 12
	default_ammo = "/datum/ammo/bullet/pistol"
	gun_type = "/obj/item/weapon/gun/pistol/m4a3"

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


/obj/item/weapon/gun/pistol
	icon_state = "" //Defaults to revolver pistol when there's no sprite.
	slot_flags = SLOT_BELT
	w_class = 3
	fire_sound = 'sound/weapons/servicepistol.ogg'

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
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 21
	under_pixel_y = 17

//	New()
//		..()
		//if(initial(icon_state) == "colt1")
			//icon_state = "colt[rand(1,7)]" //Lets get some variations up in this shit

//-------------------------------------------------------
//M44 MAGNUM REVOLVER

/obj/item/ammo_magazine/revolver
	name = "Revolver Speed Loader (.44)"
	default_ammo = "/datum/ammo/bullet/revolver"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/m44"

/obj/item/ammo_magazine/revolver/marksman
	name = "Marksman Speed Loader (.44)"
	default_ammo = "/datum/ammo/bullet/revolver/marksman"

/obj/item/weapon/gun/revolver
	fire_sound = 'sound/weapons/44mag.ogg'

/obj/item/weapon/gun/revolver/m44
	name = "\improper M44 Combat Revolver"
	desc = "A bulky 44-calibre revolver, occasionally carried by assault troops and officers in the Colonial Marines. Uses 44 Magnum rounds."
	icon_state = "44"
	icon_empty = "44_dry"
	item_state = "44"
	mag_type = "/obj/item/ammo_magazine/revolver"
	fire_delay = 8
	recoil = 1
	force = 8
	muzzle_pixel_x = 29
	muzzle_pixel_y = 17
	rail_pixel_x = 17
	rail_pixel_y = 23
	under_pixel_x = 24
	under_pixel_y = 19

//-------------------------------------------------------
//375 REVOLVER

/obj/item/ammo_magazine/revolver/small
	name = "Revolver Speed Loader (.357)"
	default_ammo = "/datum/ammo/bullet/revolver/small"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/small"

/obj/item/weapon/gun/revolver/small
	name = "\improper S&W .357 Revolver"
	desc = "A lean 357 made by Smith & Wesson. A timeless classic, from antiquity to the future."
	icon_state = "detective"
	item_state = "detective"
	mag_type = "/obj/item/ammo_magazine/revolver/small"
	fire_delay = 3
	recoil = 0
	force = 6
	muzzle_pixel_x = 30
	muzzle_pixel_y = 19
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 20
	under_pixel_y = 15
	found_on_mercs = 1

//-------------------------------------------------------
//RUSSIAN PISTOL

/obj/item/ammo_magazine/revolver/upp
	name = "Revolver Ammo Feed (7.62mm)"
	default_ammo = "/datum/ammo/bullet/revolver"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/upp"

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm Revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "revolver"
	item_state = "revolver"
	mag_type = "/obj/item/ammo_magazine/revolver/upp"
	fire_sound = 'sound/weapons/gunshot_glock.ogg'
	fire_delay = 8
	recoil = 1
	force = 10
	muzzle_pixel_x = 28
	muzzle_pixel_y = 21
	rail_pixel_x = 14
	rail_pixel_y = 23
	under_pixel_x = 24
	under_pixel_y = 19
	found_on_mercs = 1
	found_on_russians = 1

//-------------------------------------------------------
//BURST REVOLVER

/obj/item/ammo_magazine/revolver/mateba
	name = "Revolver Speed Loader (.454)"
	default_ammo = "/datum/ammo/bullet/revolver/heavy"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/mateba"

/obj/item/weapon/gun/revolver/mateba
	name = "\improper Mateba Autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. It uses heavy .454 rounds."
	icon_state = "mateba"
	item_state = "mateba"
	mag_type = "/obj/item/ammo_magazine/revolver/mateba"
	fire_sound = 'sound/weapons/mateba.ogg'
	fire_delay = 8
	burst_amount = 2
	burst_delay = 4
	recoil = 1
	force = 15
	muzzle_pixel_x = 30
	muzzle_pixel_y = 19
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 22
	under_pixel_y = 15
	found_on_russians = 1
	slot_flags = SLOT_BELT

//-------------------------------------------------------
//DEAGLE

/obj/item/ammo_magazine/pistol/heavy
	name = "Heavy Pistol Magazine (.50)"
	default_ammo = "/datum/ammo/bullet/pistol/heavy"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 12
	gun_type = "/obj/item/weapon/gun/pistol/heavy"

//Captain's vintage pistol.
/obj/item/weapon/gun/pistol/heavy
	name = "\improper Vintage Desert Eagle"
	desc = "A bulky 50 caliber pistol with a serious kick. This one is engraved, 'Peace through superior firepower.'"
	icon_state = "deagle"
	item_state = "deagle"
	fire_sound = 'sound/weapons/44mag.ogg'
	mag_type = "/obj/item/ammo_magazine/pistol/heavy"
	fire_sound = 'sound/weapons/gunshot_glock.ogg'
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
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 16
	gun_type = "/obj/item/weapon/gun/pistol/c99"

/obj/item/weapon/gun/pistol/c99
	name = "\improper Korovin PK-9 Pistol"
	desc = "An updated variant of an russian old design, dating back to from the 19th century. Commonly found among mercenary companies due to its reliability, but also issued to armed forces. Comes pre-loaded with hollowpoint rounds and features an integrated silencer."
	icon_state = "p08"
	item_state = "p08"
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
	silenced = 1

/obj/item/weapon/gun/pistol/c99/russian
	found_on_russians = 1
	found_on_mercs = 0
	icon_state = "russianp08"
	item_state = "russianp08"
//-------------------------------------------------------
//HIGH TECH PISTOL

/obj/item/ammo_magazine/pistol/m1911
	name = "M1911 Pulse Pistol Magazine (.40)"
	default_ammo = "/datum/ammo/bullet/pistol/heavy"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 12
	gun_type = "/obj/item/weapon/gun/pistol/m1911"

/obj/item/weapon/gun/pistol/m1911
	name = "\improper M1911 Pulse Pistol"
	desc = "A modern variant of an old design, using the same technology found in the M41 series of Pulse Rifles."
	icon_state = "m1911-p"
	icon_empty = "m1911-p0"
	item_state = "m4a3"
	fire_sound = 'sound/weapons/44mag.ogg'
	mag_type = "/obj/item/ammo_magazine/pistol/m1911"
	fire_sound = 'sound/weapons/gunshot_rifle.ogg'
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
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 21
	gun_type = "/obj/item/weapon/gun/pistol/kt42"

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
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 5
	gun_type = "/obj/item/weapon/gun/pistol/holdout"

/obj/item/weapon/gun/pistol/holdout
	name = "\improper Holdout Pistol"
	desc = "A tiny 22-calibre pistol meant for hiding in hard-to-reach areas."
	icon_state = "holdout_pistol"
	item_state = "holdout"
	mag_type = "/obj/item/ammo_magazine/pistol/holdout"
	fire_sound = 'sound/weapons/holdout.ogg'
	fire_delay = 1
	recoil = 0
	w_class = 1
	force = 2
	muzzle_pixel_x = 25
	muzzle_pixel_y = 19
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
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 9
	gun_type = "/obj/item/weapon/gun/pistol/highpower"

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
//MARSHALS REVOLVER

/obj/item/ammo_magazine/revolver/cmb
	name = "Revolver Speed Loader (357)"
	default_ammo = "/datum/ammo/bullet/revolver/small"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 6
	gun_type = "/obj/item/weapon/gun/revolver/cmb"

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB Spearhead Autorevolver"
	desc = "A powerful automatic revolver chambered in .357. Commonly issued to Colonial Marshals."
	icon_state = "CMBpistol"
	item_state = "cmbpistol"
	mag_type = "/obj/item/ammo_magazine/revolver/cmb"
	fire_sound = 'sound/weapons/44mag2.ogg'
	fire_delay = 12
	burst_amount = 3
	burst_delay = 6
	recoil = 1
	w_class = 3
	force = 12
	muzzle_pixel_x = 31
	muzzle_pixel_y = 22
	rail_pixel_x = 11
	rail_pixel_y = 25
	under_pixel_x = 20
	under_pixel_y = 18

//-------------------------------------------------------
//VP70

/obj/item/ammo_magazine/pistol/vp70
	name = "VP70 AP Magazine (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/ap"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 9
	gun_type = "/obj/item/weapon/gun/pistol/vp70"

/obj/item/weapon/gun/pistol/vp70
	name = "\improper VP70 Pistol"
	desc = "A powerful sidearm issed mainly to Weyland Yutani response teams. Fires 9mm armor piercing rounds and is capable of 3-round burst."
	icon_state = "vp70"
	item_state = "vp70"
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
	name = "VP78 Magazine (9mm)"
	default_ammo = "/datum/ammo/bullet/pistol/incendiary/vp78"
	icon_state = "45-10"
	icon_empty = "45-0"
	max_rounds = 18
	gun_type = "/obj/item/weapon/gun/pistol/vp78"

/obj/item/weapon/gun/pistol/vp78
	name = "\improper VP78 Pistol"
	desc = "A massive formidable automatic handgun chambered in 9mm Special rounds. These will light targets on fire. Inscribed on the side is, 'Smells like napalm'. Commonly seen in the hands of wealthy Weyland Yutani members."
	icon_state = "VP78"
	item_state = "vp78"
	mag_type = "/obj/item/ammo_magazine/pistol/vp78"
	fire_sound = 'sound/weapons/44mag2.ogg'
	fire_delay = 6
	burst_amount = 3
	burst_delay = 3
	recoil = 1
	w_class = 3
	force = 8
	muzzle_pixel_x = 32
	muzzle_pixel_y = 20
	rail_pixel_x = 8
	rail_pixel_y = 24
	under_pixel_x = 23
	under_pixel_y = 13
