/obj/item/weapon/gun/smg
	fire_sound = 'sound/weapons/Gunshot_m39.ogg'
	slot_flags = SLOT_BELT
	force = 8
	w_class = 4
	recoil = 0
	twohanded = 0

//-------------------------------------------------------
/obj/item/ammo_magazine/smg
	name = "default SMG magazine"
	default_ammo = "/datum/ammo/bullet/smg"
	max_rounds = 30

/obj/item/ammo_magazine/smg/m39
	name = "M39 SMG Mag (9mm)"
	desc = "A 9mm submachinegun magazine."
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 35
	gun_type = "/obj/item/weapon/gun/smg/m39"

/obj/item/ammo_magazine/smg/m39/extended
	name = "M39 Extended Mag (9mm)"
	desc = "A 9mm submachinegun magazine."
	icon_state = "9e"
	icon_empty = "9e0"
	max_rounds = 60
	bonus_overlay = "m39_mag"

/obj/item/weapon/gun/smg/m39
	name = "\improper M39 SMG"
	desc = "Armat Battlefield Systems M-39 submachinegun. Occasionally carried by light-infantry, scouts, engineers or medics. Uses 9mm rounds in a 35 round magazine."
	icon_state = "smg"
	icon_empty = "smg_empty"
	item_state = "m39"
	mag_type = "/obj/item/ammo_magazine/smg/m39"
	muzzle_pixel_x = 33
	muzzle_pixel_y = 20
	rail_pixel_x = 11
	rail_pixel_y = 22
	under_pixel_x = 24
	under_pixel_y = 16
	burst_amount = 3
	fire_delay = 3
	burst_delay = 2

	New()
		..()
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "smg") //Only change this one
				icon_state = "smg_pmc"
				icon_empty = "smg_pmc_empty"
				item_state = "m39_pmc"

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/elite
	name = "AP SMG Magazine (9mm)"
	desc = "A 9mm special magazine."
	icon_state = "9x"
	icon_empty = "9x0"
	default_ammo = "/datum/ammo/bullet/smg/ap"
	gun_type = "/obj/item/weapon/gun/smg/m39/elite"
	max_rounds = 45

/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B/2 SMG"
	desc = "Armat Battlefield Systems M-39 submachinegun, version B2. This reliable weapon fires armor piercing 9mm rounds and is used by elite troops."
	icon_state = "smg_pmc"
	icon_empty = "smg_pmc_empty"
	item_state = "m39_pmc"
	burst_amount = 3
	mag_type = "/obj/item/ammo_magazine/smg/elite"
	accuracy = 15
	dam_bonus = 15

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/mp7
	name = "MP27 Magazine (4.6mm)"
	desc = "A 9mm special magazine."
	default_ammo = "/datum/ammo/bullet/smg/ap"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 40
	gun_type = "/obj/item/weapon/gun/smg/mp7"

/obj/item/weapon/gun/smg/mp7
	name = "\improper MP27"
	desc = "An archaic design going back hundreds of years, the MP27 was common in its day. Today it sees limited use as cheap computer-printed replicas or family heirlooms."
	icon_state = "mp7"
	icon_empty = "mp7_empty"
	item_state = "mp7"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	fire_delay = 4
	mag_type = "/obj/item/ammo_magazine/smg/mp7"
	muzzle_pixel_x = 33
	muzzle_pixel_y = 18
	rail_pixel_x = 12
	rail_pixel_y = 21
	under_pixel_x = 28
	under_pixel_y = 17
	burst_amount = 4
	burst_delay = 2
	accuracy = 5
	found_on_mercs = 1
	dam_bonus = 15

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/skorpion
	name = "Skorpion Magazine (.32)"
	desc = "A .32 caliber magazine for the Skorpion."
	default_ammo = "/datum/ammo/bullet/smg"
	icon_state = "12mm"
	icon_empty = "12mm0"
	max_rounds = 20
	gun_type = "/obj/item/weapon/gun/smg/skorpion"

/obj/item/weapon/gun/smg/skorpion
	name = "\improper Skorpion"
	desc = "A robust, 20th century firearm that's a combination of pistol and submachinegun. Fires .32 caliber rounds from a 20 round magazine."
	icon_state = "skorpion"
	icon_empty = "skorpion_empty"
	item_state = "skorpion"
	fire_sound = 'sound/weapons/holdout.ogg'
	fire_delay = 3
	mag_type = "/obj/item/ammo_magazine/smg/skorpion"
	muzzle_pixel_x = 29
	muzzle_pixel_y = 18
	rail_pixel_x = 10
	rail_pixel_y = 20
	under_pixel_x = 23
	under_pixel_y = 15
	burst_amount = 3
	burst_delay = 2
	accuracy = 8
	found_on_mercs = 1
	found_on_russians = 1
	dam_bonus = 10

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/ppsh
	name = "PPSh-17b Drum Magazine (7.62mm)"
	desc = "A drum magazine for the PPSh submachinegun."
	default_ammo = "/datum/ammo/bullet/smg"
	icon_state = "darts-0" //Dumb
	icon_empty = "darts-0"
	max_rounds = 71
	gun_type = "/obj/item/weapon/gun/smg/ppsh"

/obj/item/ammo_magazine/smg/ppsh/extended
	name = "PPSh-17b Magazine (7.62mm)"
	desc = "A standard 7.62mm magazine for the PPSh submachinegun."
	icon_state = "darts-0" //Dumb
	icon_empty = "darts-0"
	max_rounds = 35
	bonus_overlay = "ppsh_mag"

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b Submachinegun"
	desc = "An unauthorized copy of a replica of a prototype submachinegun developed in a third world shit hole somewhere. This one has a 71-round drum magazine."
	icon_state = "ppsh"
	icon_empty = "ppsh_empty"
	item_state = "ppsh"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	fire_delay = 6
	mag_type = "/obj/item/ammo_magazine/smg/ppsh"
	muzzle_pixel_x = 33
	muzzle_pixel_y = 17
	rail_pixel_x = 15
	rail_pixel_y = 19
	under_pixel_x = 26
	under_pixel_y = 15
	burst_amount = 3
	burst_delay = 1
	accuracy = -8
	found_on_russians = 1

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/uzi
	name = "Mac-15 Magazine (9mm)"
	desc = "A magazine for the P90 SMG."
	default_ammo = "/datum/ammo/bullet/smg"
	icon_state = "darts"
	icon_empty = "darts-0"
	max_rounds = 50
	gun_type = "/obj/item/weapon/gun/smg/p90"

/obj/item/weapon/gun/smg/uzi
	name = "\improper MAC-15"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age. Turn on burst mode for maximum firepower."
	icon_state = "mini-uzi"
	icon_empty = "mini-uzi_empty"
	item_state = "mini-uzi"
	fire_sound = 'sound/weapons/uzi.ogg'
	fire_delay = 4
	mag_type = "/obj/item/ammo_magazine/smg/uzi"
	muzzle_pixel_x = 32
	muzzle_pixel_y = 19
	rail_pixel_x = 11
	rail_pixel_y = 22
	under_pixel_x = 22
	under_pixel_y = 16
	burst_amount = 4
	burst_delay = 1
	found_on_mercs = 1
	dam_bonus = -5

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/p90
	name = "P90 Magazine (5.7mm)"
	desc = "A magazine for the P90 SMG."
	default_ammo = "/datum/ammo/bullet/smg/ludicrous"
	icon_state = "763"
	icon_empty = "763-0"
	max_rounds = 50
	gun_type = "/obj/item/weapon/gun/smg/p90"

/obj/item/weapon/gun/smg/p90
	name = "\improper FN FP9000"
	desc = "An archaic design, but one that's stood the test of time. Fires fast armor piercing rounds in a 50 round magazine."
	icon_state = "p90"
	icon_empty = "p90_empty"
	item_state = "p90"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	fire_delay = 5
	mag_type = "/obj/item/ammo_magazine/smg/p90"
	muzzle_pixel_x = 33
	muzzle_pixel_y = 18
	rail_pixel_x = 22
	rail_pixel_y = 24
	under_pixel_x = 22
	under_pixel_y = 16
	burst_amount = 3
	burst_delay = 2
	accuracy = 12
	found_on_mercs = 1

//-------------------------------------------------------