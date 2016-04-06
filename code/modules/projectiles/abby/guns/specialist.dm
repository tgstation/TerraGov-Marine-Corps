//-------------------------------------------------------
//SNIPER RIFLES

/obj/item/ammo_magazine/sniper
	name = "M42C Sniper Rifle Magazine (.50)"
	desc = "A magazine of sniper rifle ammo."
	icon_state = "75"
	icon_empty = "75-0"
	max_rounds = 7
	default_ammo = "/datum/ammo/bullet/sniper"
	gun_type = "/obj/item/weapon/gun/sniper"
	reload_delay = 3

/obj/item/ammo_magazine/sniper/incendiary
	name = "M42C Incendiary Magazine (.50)"
	default_ammo = "/datum/ammo/bullet/sniper/incendiary"

/obj/item/ammo_magazine/sniper/flak
	name = "M42C Flak Magazine (.50)"
	default_ammo = "/datum/ammo/bullet/sniper/flak"
	icon_state = "a762"
	icon_empty = "a762-0"

//Pow! Headshot.
/obj/item/weapon/gun/sniper
	name = "\improper M42C Scoped Rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 7-round magazine.\n'Peace Through Superior Firepower'"
	icon_state = "M42c"
	icon_empty = "M42c_empty"
	item_state = "l6closednomag"  //placeholder
	fire_sound = 'sound/weapons/GunFireSniper.ogg'
	mag_type = "/obj/item/ammo_magazine/sniper"
	fire_delay = 60
	w_class = 4.0
	force = 12
	recoil = 1
	twohanded = 1
	zoomdevicename = "scope"
	slot_flags = SLOT_BACK
	muzzle_pixel_x = 33
	muzzle_pixel_y = 17
	rail_pixel_x = 13
	rail_pixel_y = 20
	under_pixel_x = 25
	under_pixel_y = 12

/obj/item/weapon/gun/sniper/verb/scope()
	set category = "Weapons"
	set name = "Use Scope"
	set popup_menu = 1

	zoom()


//-------------------------------------------------------
//SMARTGUN
/obj/item/ammo_magazine/smartgun_integrated
	name = "Integrated Smartgun Belt"
	icon_state = ".45a"
	icon_empty = ".45a0"
	max_rounds = 50
	default_ammo = "/datum/ammo/bullet/smartgun"
	gun_type = "/obj/item/weapon/gun/smartgun"

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper M56 smartgun"
	desc = "The actual firearm in the 4-piece M56 Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a Powerpack. Click the powerpack icon in the top left to reload."
	icon_state = "m56"
	item_state = "m56"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	mag_type = "/obj/item/ammo_magazine/smartgun_integrated"
	w_class = 5.0
	force = 20.0
	twohanded = 1
	recoil = 0
	fire_delay = 2
	muzzle_pixel_x = 33
	muzzle_pixel_y = 16
	rail_pixel_x = 18
	rail_pixel_y = 18
	under_pixel_x = 22
	under_pixel_y = 14
	burst_amount = 3
	autoejector = 0

	attackby(obj/item/I as obj, mob/user as mob)
		if(!istype(I,/obj/item/attachable)) //Don't allow reloading by clicking it somehow.
			return
		return ..()

//-------------------------------------------------------