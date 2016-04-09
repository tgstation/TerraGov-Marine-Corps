//-------------------------------------------------------

/obj/item/weapon/gun/rifle
	twohanded = 1
	slot_flags = SLOT_BACK
	w_class = 4
	force = 15
	burst_amount = 2

//-------------------------------------------------------
//M41A PULSE RIFLE

/obj/item/ammo_magazine/rifle
	name = "M41A Magazine (10mm)"
	desc = "A 10mm assault rifle magazine."
	icon_state = "m309a"
	icon_empty = "m309a0"
	default_ammo = "/datum/ammo/bullet/rifle"
	max_rounds = 30
	gun_type = "/obj/item/weapon/gun/rifle/m41a"

/obj/item/ammo_magazine/rifle/incendiary
	name = "M41A Incendiary Magazine (10mm)"
	desc = "A 10mm assault rifle magazine."
	default_ammo = "/datum/ammo/bullet/rifle/incendiary"

/obj/item/weapon/gun/rifle/m41a
	name = "\improper M41A Pulse Rifle"
	desc = "The standard issue rifle of the Colonial Marines. Commonly carried by most combat personnel. Uses 10mm special ammunition."
	icon_state = "m41a"
	icon_empty = "m41a0"
	icon_wielded = "m41a-w"
	item_state = "m41a"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	mag_type = "/obj/item/ammo_magazine/rifle"
	fire_delay = 4
	recoil = 0
	burst_amount = 3
	burst_delay = 2
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 13
	rail_pixel_y = 20
	under_pixel_x = 24
	under_pixel_y = 13
	ammo_counter = 1

	New()
		..()
		var/obj/item/attachable/grenade/G = new(src)
		G.Attach(src)
		update_attachables()


//-------------------------------------------------------
//M41A MARKSMAN VARIANT

/obj/item/ammo_magazine/rifle/marksman
	name = "M41A/M Marksman Magazine (10mm)"
	desc = "A 10mm marksman rifle magazine."
	default_ammo = "/datum/ammo/bullet/rifle/marksman"
	gun_type = "/obj/item/weapon/gun/rifle/m41a/scoped"

/obj/item/weapon/gun/rifle/m41a/scoped
	name = "\improper M41A/M Marksman Rifle"
	desc = "An advanced prototype pulse rifle based on the tried and true M41A. Uses any standard M41 magazine and is equipped with rail scope."
	icon_state = "m41b"
	icon_empty = "m41b0"
	item_state = "m41a"
	mag_type = "/obj/item/ammo_magazine/rifle/marksman"
	force = 16
	twohanded = 1
	fire_delay = 5
	recoil = 1
	burst_amount = 0
	accuracy = 15

	New()
		var/obj/item/attachable/scope/S = new(src)
		S.Attach(src)
		var/obj/item/attachable/compensator/riflestock/Q = new(src)
		Q.Attach(src)
		var/obj/item/attachable/bipod/B = new(src)
		B.Attach(src)

		update_attachables()

		//Have to do all this stuff manually since we don't want the m41 underbarrel grenade launcher installed.
		var/magpath = text2path(mag_type)
		if(magpath)
			current_mag = new magpath(src)
			current_mag.current_rounds = current_mag.max_rounds //Eh. For now they can always start full.
			var/ammopath = text2path(current_mag.default_ammo)
			if(ammopath)
				ammo = new ammopath()
		if(burst_delay == 0 && burst_amount > 0) //Okay.
			burst_delay = fire_delay / 2

//-------------------------------------------------------
//M41A PMC VARIANT

/obj/item/weapon/gun/rifle/m41a/elite
	name = "\improper M41A/2 Battle Rifle"
	desc = "A reinforced and remachined version of the tried and tested M41A Pulse Rifle. Given only to elite units."
	icon_state = "pmc_m41a"
	icon_empty = "pmc_m41a0"
	item_state = "m41a"
	fire_delay = 6
	burst_amount = 3
	accuracy = 35

//-------------------------------------------------------
//MAR-40 AK CLONE

/obj/item/ammo_magazine/rifle/mar40
	name = "Assault Rifle Magazine (12mm)"
	desc = "A 12mm MAR-40 assault rifle magazine."
	icon_state = "a762"
	icon_empty = "a762-0"
	default_ammo = "/datum/ammo/bullet/rifle/mar40"
	max_rounds = 40
	gun_type = "/obj/item/weapon/gun/rifle/mar40"

/obj/item/weapon/gun/rifle/mar40
	name = "\improper MAR-40 Battle Rifle"
	desc = "A cheap, reliable assault rifle chambered in 12mm. Commonly found in the hands of criminals or mercenaries."
	icon_state = "rsprifle"
	icon_empty = "rsprifle0"
	icon_wielded = "mar40-w"
	item_state = "mar40"
	mag_type = "/obj/item/ammo_magazine/rifle/mar40"
	fire_sound = 'sound/weapons/gunshot_ak47.ogg' //Change
	fire_delay = 8
	recoil = 0
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 11
	rail_pixel_y = 19
	under_pixel_x = 20
	under_pixel_y = 15
	burst_amount = 4
	accuracy = -15
	found_on_mercs = 1
	found_on_russians = 1

//-------------------------------------------------------
//M41AE2 HEAVY PULSE RIFLE

/obj/item/ammo_magazine/rifle/lmg
	name = "Heavy Pulse Rifle Ammo Box"
	desc = "A semi-rectangular box of rounds for the M41AE2 Heavy Pulse Rifle."
	icon_state = "a762"
	icon_empty = "a762-0"
	default_ammo = "/datum/ammo/bullet/rifle"
	max_rounds = 100
	gun_type = "/obj/item/weapon/gun/rifle/lmg"

/obj/item/weapon/gun/rifle/lmg
	name = "\improper M41AE2 Heavy Pulse Rifle"
	desc = "Almost adapted for use by the USCM as a support machinegun, it was instead turned down. The 10mm gun instead found its way to other buyers."
	icon_state = "rsplmg"
	icon_empty = "rsplmg0"
	item_state = "l6closedmag" //Replace
	icon_wielded = "l6closedmag"
	mag_type = "/obj/item/ammo_magazine/rifle/lmg"
	fire_sound = 'sound/weapons/gunshot_rifle.ogg' //Change
	fire_delay = 4
	recoil = 0
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 11
	rail_pixel_y = 19
	under_pixel_x = 20
	under_pixel_y = 15
	burst_amount = 5
	accuracy = -35
	found_on_mercs = 1
	found_on_russians = 1

//-------------------------------------------------------

