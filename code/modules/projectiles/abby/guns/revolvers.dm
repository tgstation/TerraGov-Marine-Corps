//---------------------------------------------------
//Generic parent object.
/obj/item/weapon/gun/revolver
	slot_flags = SLOT_BELT
	w_class = 3
	origin_tech = "combat=3;materials=2"
	autoejector = 0 // Revolvers don't auto eject.
	fire_sound = 'sound/weapons/44mag.ogg'
	reload_sound = 'sound/weapons/revolver_load.ogg'
	reload_type = HANDFUL & SPEEDLOADER // Either handfuls or a speedloader.

//-------------------------------------------------------
//M44 MAGNUM REVOLVER

/obj/item/ammo_magazine/revolver
	name = "Revolver Speed Loader (.44)"
	default_ammo = "/datum/ammo/bullet/revolver"
	caliber = ".44"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver"
	handful_type = "Bullets (.44)"
	handle_casing = HOLD_CASINGS
	var/cylinder_closed = 1 //Starts out closed. Ye basic variable.

/obj/item/ammo_magazine/revolver/marksman
	name = "Marksman Speed Loader (.44)"
	default_ammo = "/datum/ammo/bullet/revolver/marksman"
	caliber = ".44"
	handful_type = "Marksman Bullets (.44)"

/obj/item/ammo_magazine/revolver/internal
	name = "Revolver Cylinder"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = "/datum/ammo/bullet/revolver"
	caliber = ".44"
	icon_state = "38"
	icon_empty = "38-0"
	gun_type = "/obj/item/weapon/gun/revolver"
	handful_type = "Bullets (.44)"
	max_rounds = 7

/obj/item/weapon/gun/revolver/m44
	name = "\improper M44 Combat Revolver"
	desc = "A bulky 44-calibre revolver, occasionally carried by assault troops and officers in the Colonial Marines. Uses 44 Magnum rounds."
	icon_state = "44"
	icon_empty = "44_dry"
	item_state = "44"
	mag_type = "/obj/item/ammo_magazine/revolver"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal"
	fire_sound = 'sound/weapons/44mag.ogg'
	fire_delay = 8
	recoil = 1
	force = 8
	muzzle_pixel_x = 30
	muzzle_pixel_y = 21
	rail_pixel_x = 17
	rail_pixel_y = 23
	under_pixel_x = 22
	under_pixel_y = 19

//-------------------------------------------------------
//RUSSIAN REVOLVER

/obj/item/ammo_magazine/revolver/upp
	name = "Revolver Speed Loader (7.62mm)"
	default_ammo = "/datum/ammo/bullet/revolver"
	caliber = "7.62mm"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/upp"
	handful_type = "Bullets (7.62mm)"

/obj/item/ammo_magazine/revolver/internal/upp
	caliber = "7.62mm"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/upp"
	handful_type = "Bullets (7.62mm)"

/obj/item/weapon/gun/revolver/upp
	name = "\improper N-Y 7.62mm Revolver"
	desc = "The Nagant-Yamasaki 7.62 is an effective killing machine designed by a consortion of shady Not-Americans. It is frequently found in the hands of criminals or mercenaries."
	icon_state = "revolver"
	icon_empty = "revolver_dry"
	item_state = "revolver"
	origin_tech = "combat=3;materials=1;syndicate=3"
	mag_type = "/obj/item/ammo_magazine/revolver/internal/upp"
	fire_sound = 'sound/weapons/pistol_medium.ogg'
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
//375 REVOLVER

/obj/item/ammo_magazine/revolver/small
	name = "Revolver Speed Loader (.357)"
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/small"
	handful_type = "Bullets (.357)"

/obj/item/ammo_magazine/revolver/internal/small
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	max_rounds = 7
	gun_type = "/obj/item/weapon/gun/revolver/small"
	handful_type = "Bullets (.357)"

/obj/item/weapon/gun/revolver/small
	name = "\improper S&W .357 Revolver"
	desc = "A lean 357 made by Smith & Wesson. A timeless classic, from antiquity to the future."
	icon_state = "357"
	icon_empty = "357_dry"
	item_state = "revolver"
	mag_type = "/obj/item/ammo_magazine/revolver/small"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal/small"
	fire_sound = 'sound/weapons/pistol_medium.ogg'
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
//BURST REVOLVER

/obj/item/ammo_magazine/revolver/mateba
	name = "Revolver Speed Loader (.454)"
	default_ammo = "/datum/ammo/bullet/revolver/heavy"
	caliber = ".454"
	icon_state = "T38"
	icon_empty = "T38-0"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/mateba"
	handful_type = "Bullets (.454)"

/obj/item/ammo_magazine/revolver/internal/mateba
	default_ammo = "/datum/ammo/bullet/revolver/heavy"
	caliber = ".454"
	max_rounds = 8
	gun_type = "/obj/item/weapon/gun/revolver/mateba"
	handful_type = "Bullets (.454)"

/obj/item/weapon/gun/revolver/mateba
	name = "\improper Mateba Autorevolver"
	desc = "The Mateba is a powerful, fast-firing revolver that uses its own recoil to rotate the cylinders. It uses heavy .454 rounds."
	icon_state = "mateba"
	icon_empty = "mateba_dry"
	item_state = "mateba"
	origin_tech = "combat=4;materials=3"
	mag_type = "/obj/item/ammo_magazine/revolver/mateba"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal/mateba"
	fire_sound = 'sound/weapons/mateba.ogg'
	fire_delay = 8
	burst_amount = 2
	burst_delay = 4
	recoil = 1
	force = 15
	muzzle_pixel_x = 28
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 22
	under_pixel_y = 15
	found_on_russians = 1

//-------------------------------------------------------
//MARSHALS REVOLVER

/obj/item/ammo_magazine/revolver/cmb
	name = "Revolver Speed Loader (.357)"
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	icon_state = "38"
	icon_empty = "38-0"
	max_rounds = 6
	gun_type = "/obj/item/weapon/gun/revolver/cmb"
	handful_type = "Bullets (.357)"

/obj/item/ammo_magazine/revolver/internal/cmb
	default_ammo = "/datum/ammo/bullet/revolver/small"
	caliber = ".357"
	max_rounds = 6
	gun_type = "/obj/item/weapon/gun/revolver/cmb"
	handful_type = "Bullets (.357)"

/obj/item/weapon/gun/revolver/cmb
	name = "\improper CMB Spearhead Autorevolver"
	desc = "A powerful automatic revolver chambered in .357. Commonly issued to Colonial Marshals."
	icon_state = "CMB"
	icon_empty = "CMB_dry"
	item_state = "cmbpistol"
	mag_type = "/obj/item/ammo_magazine/revolver/cmb"
	mag_type_internal = "/obj/item/ammo_magazine/revolver/internal/cmb"
	fire_sound = 'sound/weapons/44mag2.ogg'
	fire_delay = 12
	burst_amount = 3
	burst_delay = 6
	recoil = 1
	force = 12
	muzzle_pixel_x = 29
	muzzle_pixel_y = 22
	rail_pixel_x = 11
	rail_pixel_y = 25
	under_pixel_x = 20
	under_pixel_y = 18