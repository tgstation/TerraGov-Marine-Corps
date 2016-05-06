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
	name = "Pulse Rifle Magazine (10mm)"
	desc = "A 10mm assault rifle magazine."
	icon_state = "m309a"
	icon_empty = "m309a0"
	default_ammo = "/datum/ammo/bullet/rifle"
	max_rounds = 30
	gun_type = "/obj/item/weapon/gun/rifle/m41a"

/obj/item/ammo_magazine/rifle/extended
	name = "Pulse Rifle Extended Magazine (10mm)"
	desc = "A 10mm assault extended rifle magazine."
	max_rounds = 70
	bonus_overlay = "m41a_exmag"

/obj/item/ammo_magazine/rifle/incendiary
	name = "Pulse Rifle Incendiary Magazine (10mm)"
	desc = "A 10mm assault rifle magazine."
	default_ammo = "/datum/ammo/bullet/rifle/incendiary"

/obj/item/ammo_magazine/rifle/ap
	name = "Pulse Rifle AP Magazine (10mm)"
	desc = "A 10mm armor piercing magazine."
	default_ammo = "/datum/ammo/bullet/rifle/ap"

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
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 24
	under_pixel_y = 13
	ammo_counter = 1

	New()
		..()
		var/obj/item/attachable/grenade/G = new(src)
		G.Attach(src)
		update_attachables()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "m41a") //Only change this one
				icon_state = "s_m41a"
				icon_empty = "s_m41a0"
				icon_wielded = "s_m41a-w"
				item_state = "s_m41a"

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
	under_pixel_x = 22
	under_pixel_y = 14

	New()
		var/obj/item/attachable/scope/S = new(src)
		S.Attach(src)
		var/obj/item/attachable/compensator/riflestock/Q = new(src)
		Q.Attach(src)

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

/obj/item/ammo_magazine/rifle/elite
	name = "M41A/2 Magazine (10mm)"
	desc = "A 10mm rifle magazine."
	default_ammo = "/datum/ammo/bullet/rifle/ap"
	gun_type = "/obj/item/weapon/gun/rifle/m41a/elite"
	max_rounds = 40

/obj/item/weapon/gun/rifle/m41a/elite
	name = "\improper M41A/2 Battle Rifle"
	desc = "A reinforced and remachined version of the tried and tested M41A Pulse Rifle. Given only to elite units."
	icon_state = "pmc_m41a"
	icon_empty = "pmc_m41a0"
	item_state = "pmc_m41a"
	icon_wielded = "pmc_m41a-w"
	mag_type = "/obj/item/ammo_magazine/rifle/elite"
	fire_delay = 7
	burst_amount = 3
	accuracy = 35
	dam_bonus = 15


//-------------------------------------------------------
//MAR-40 AK CLONE

/obj/item/ammo_magazine/rifle/mar40
	name = "Ammo Magazine (12mm)"
	desc = "A 12mm magazine for the MAR series of firearms."
	icon_state = "5.56"
	icon_empty = "5.56"
	default_ammo = "/datum/ammo/bullet/rifle/mar40"
	max_rounds = 40
	gun_type = "/obj/item/weapon/gun/rifle/mar40"

/obj/item/ammo_magazine/rifle/mar40/extended
	name = "Extended Magazine (12mm)"
	desc = "A 12mm MAR magazine."
	max_rounds = 60
	bonus_overlay = "mar40_mag"

/obj/item/weapon/gun/rifle/mar40
	name = "\improper MAR-40 Battle Rifle"
	desc = "A cheap, reliable assault rifle chambered in 12mm. Commonly found in the hands of criminals or mercenaries, or in the hands of the UPP or Iron Bears."
	icon_state = "rsprifle"
	icon_empty = "rsprifle0"
	icon_wielded = "mar40-w"
	item_state = "mar40"
	mag_type = "/obj/item/ammo_magazine/rifle/mar40"
	fire_sound = 'sound/weapons/automag.ogg'
	fire_delay = 6
	recoil = 0
	muzzle_pixel_x = 32
	muzzle_pixel_y = 17
	rail_pixel_x = 11
	rail_pixel_y = 19
	under_pixel_x = 24
	under_pixel_y = 15
	burst_amount = 4
	burst_delay = 2
	accuracy = -12
	found_on_mercs = 1
	found_on_russians = 1

/obj/item/weapon/gun/rifle/mar40/carbine
	name = "\improper MAR-30 Battle Carbine"
	desc = "A cheap, reliable assault rifle chambered in 12mm. Commonly found in the hands of criminals or mercenaries. This is the carbine variant."
	icon_state = "shortrsprifle"
	icon_empty = "shortrsprifle0"
	icon_wielded = "shortrsprifle-w"
	fire_sound = 'sound/weapons/gunshot_ak47.ogg' //Change
	item_state = "mar40short"
	fire_delay = 5
	accuracy = -16

/obj/item/ammo_magazine/rifle/mar40/svd
	name = "SVD Magazine (12mm)"
	desc = "A 12mm marksman rifle magazine."
	icon_state = "a762"
	icon_empty = "a762-0"
	default_ammo = "/datum/ammo/bullet/rifle/marksman"
	max_rounds = 30
	gun_type = "/obj/item/weapon/gun/rifle/mar40/svd"

/obj/item/weapon/gun/rifle/mar40/svd
	name = "\improper SVD Dragunov-033"
	desc = "A marksman variant of the MAR-40 rifle, with a new stock, barrel, and scope. Finely crafted in 2133 by someone probably illiterate. Fires 12mm rounds and can use MAR-40 magazines."
	icon_state = "VSS"
	icon_empty = "VSS_empty"
	icon_wielded = "SVD-w"
	item_state = "mar40"
	accuracy = 0

	New()
		..()
		var/obj/item/attachable/S = new /obj/item/attachable/scope/slavic(src)
		S.Attach(src)
		S = new /obj/item/attachable/slavicbarrel(src)
		S.Attach(src)
		S = new /obj/item/attachable/compensator/stock/slavic(src)
		S.Attach(src)
		update_attachables()

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
	desc = "A large weapon capable of laying down supressing fire. Currently undergoing field testing among USCM scout platoons and in mercenary companies. Like it's smaller brother, the M41A, the M41AE2 is chambered in 10mm."
	icon_state = "rsplmg"
	icon_empty = "rsplmg0"
	item_state = "rsplmg"
	icon_wielded = "rsplmg-w"
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
	burst_amount = 4
	accuracy = -25
	found_on_mercs = 1
	found_on_russians = 0

//-------------------------------------------------------

