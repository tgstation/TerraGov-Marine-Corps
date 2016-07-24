/obj/item/ammo_magazine/smg
	name = "\improper default SMG magazine"
	default_ammo = "submachinegun bullet"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 30

/obj/item/weapon/gun/smg
	reload_sound = 'sound/weapons/rifle_reload.ogg' //Could use a unique sound.
	cocked_sound = 'sound/weapons/rifle_cocked.ogg'
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/Gunshot_m39.ogg'
	eject_casings = 1
	slot_flags = SLOT_BELT
	force = 8
	w_class = 4
	fire_delay = 4
	burst_delay = 2
	burst_amount = 3
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK

	New()
		..()
		load_into_chamber()

//-------------------------------------------------------
//M39 SMG ammo

/obj/item/ammo_magazine/smg/m39
	name = "\improper M39 magazine (10x20mm)"
	desc = "A 10x20mm caseless submachinegun magazine."
	caliber = "10×20mm"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 35 //Should be 48
	gun_type = /obj/item/weapon/gun/smg/m39

/obj/item/ammo_magazine/smg/m39/extended
	name = "\improper M39 extended magazine (10x20mm)"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 72
	bonus_overlay = "m39_mag"

/obj/item/ammo_magazine/smg/m39/ap
	name = "\improper M39 AP magazine (10x20mm)"
	caliber = "9mm"
	icon_state = "9x"
	icon_empty = "9x0"
	default_ammo = "armor-piercing submachinegun bullet"
	gun_type = /obj/item/weapon/gun/smg/m39/elite
	max_rounds = 48

//-------------------------------------------------------
//M39 SMG

/obj/item/weapon/gun/smg/m39
	name = "\improper M39 submachinegun"
	desc = "Armat Battlefield Systems M-39 submachinegun. Occasionally carried by light-infantry, scouts, engineers or medics. Uses 9mm rounds in a 35 round magazine."
	icon_state = "smg"
	icon_empty = "smg_empty"
	item_state = "m39"
	mag_type = /obj/item/ammo_magazine/smg/m39
	eject_casings = 0
	fire_delay = 3
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_AMMO_COUNTER

	New()
		..()
		attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 11, "rail_y" = 22, "under_x" = 24, "under_y" = 16)
		if(ticker && istype(ticker.mode,/datum/game_mode/ice_colony)) //Snow camo
			if(icon_state == "smg") //Only change this one
				icon_state = "smg_pmc"
				icon_empty = "smg_pmc_empty"
				item_state = "m39_pmc"

//-------------------------------------------------------

/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B/2 submachinegun"
	desc = "Armat Battlefield Systems M-39 submachinegun, version B2. This reliable weapon fires armor piercing 9mm rounds and is used by elite troops."
	icon_state = "smg_pmc"
	icon_empty = "smg_pmc_empty"
	item_state = "m39_pmc"
	origin_tech = "combat=6;materials=5"
	mag_type = /obj/item/ammo_magazine/smg/m39/ap
	accuracy = 15
	damage = 15
	fire_delay = 4
	burst_delay = 1
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_AMMO_COUNTER | GUN_WY_RESTRICTED

//-------------------------------------------------------

/obj/item/ammo_magazine/smg/mp7
	name = "\improper MP27 magazine (4.6x30mm)"
	desc = "A 4.6mm magazine for the MP7."
	default_ammo = "armor-piercing submachinegun bullet"
	caliber = "4.6×30mm"
	icon_state = "9x"
	icon_empty = "9x0"
	gun_type = /obj/item/weapon/gun/smg/mp7
	max_rounds = 30 //Also comes in 20 and 40.

/obj/item/weapon/gun/smg/mp7
	name = "\improper MP27 submachinegun"
	desc = "An archaic design going back hundreds of years, the MP27 was common in its day. Today it sees limited use as cheap computer-printed replicas or family heirlooms."
	icon_state = "mp7"
	icon_empty = "mp7_empty"
	item_state = "mp7"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/smg_light.ogg'
	mag_type = /obj/item/ammo_magazine/smg/mp7
	accuracy = 5
	damage = 15
	burst_amount = 4
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 21, "under_x" = 28, "under_y" = 17)

//-------------------------------------------------------
//SKORPION //Based on the same thing.

/obj/item/ammo_magazine/smg/skorpion
	name = "\improper Skorpion magazine (.32ACP)"
	desc = "A .32ACP caliber magazine for the Skorpion."
	caliber = ".32ACP"
	icon_state = "12mm"
	icon_empty = "12mm0"
	gun_type = /obj/item/weapon/gun/smg/skorpion
	max_rounds = 20 //Can also be 10.

/obj/item/weapon/gun/smg/skorpion
	name = "\improper Skorpion submachinegun"
	desc = "A robust, 20th century firearm that's a combination of pistol and submachinegun. Fires .32ACP caliber rounds from a 20 round magazine."
	icon_state = "skorpion"
	icon_empty = "skorpion_empty"
	item_state = "skorpion"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/skorpion.ogg'
	mag_type = /obj/item/ammo_magazine/smg/skorpion
	accuracy = 8
	damage = 10
	fire_delay = 3
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS | GUN_ON_RUSSIANS

	New()
		..()
		attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 22, "under_x" = 23, "under_y" = 15)

//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

/obj/item/ammo_magazine/smg/ppsh
	name = "\improper PPSh-17b drum magazine (7.62x25mm)"
	desc = "A drum magazine for the PPSh submachinegun."
	caliber = "7.62×25mm"
	icon_state = "darts-0" //Dumb
	icon_empty = "darts-0"
	max_rounds = 35
	gun_type = /obj/item/weapon/gun/smg/ppsh

/obj/item/ammo_magazine/smg/ppsh/extended
	name = "\improper PPSh-17b extended magazine (7.62x25mm)"
	max_rounds = 71

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b submachinegun"
	desc = "An unauthorized copy of a replica of a prototype submachinegun developed in a third world shit hole somewhere."
	icon_state = "ppsh"
	icon_empty = "ppsh_empty"
	item_state = "ppsh"
	origin_tech = "combat=3;materials=2;syndicate=4"
	fire_sound = 'sound/weapons/smg_heavy.ogg'
	mag_type = /obj/item/ammo_magazine/smg/ppsh
	accuracy = -8
	fire_delay = 6
	burst_delay = 1
	gun_features = GUN_CAN_POINTBLANK | GUN_ON_RUSSIANS

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 26, "under_y" = 15)

//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/ammo_magazine/smg/uzi //Based on the Uzi.
	name = "\improper Mac-15 magazine (9mm)"
	desc = "A magazine for the MAC-15."
	caliber = "9mm"
	icon_state = "9x"
	icon_empty = "9x0"
	max_rounds = 32 //Can also be 20, 25, 40, and 50.
	gun_type = /obj/item/weapon/gun/smg/uzi

/obj/item/weapon/gun/smg/uzi
	name = "\improper MAC-15 submachinegun"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age. Turn on burst mode for maximum firepower."
	icon_state = "mini-uzi"
	icon_empty = "mini-uzi_empty"
	item_state = "mini-uzi"
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/uzi.ogg'
	mag_type = /obj/item/ammo_magazine/smg/uzi
	damage = -5
	burst_delay = 1
	burst_amount = 4
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 22, "under_x" = 22, "under_y" = 16)

//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/ammo_magazine/smg/p90
	name = "P90 magazine (5.7x28mm)"
	desc = "A magazine for the P90 SMG."
	default_ammo = "armor-piercing submachinegun bullet"
	caliber = "5.7×28mm"
	icon_state = "763"
	icon_empty = "763-0"
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/smg/p90

/obj/item/weapon/gun/smg/p90
	name = "\improper FN FP9000 Submachinegun"
	desc = "An archaic design, but one that's stood the test of time. Fires fast armor piercing rounds."
	icon_state = "p90"
	icon_empty = "p90_empty"
	item_state = "p90"
	origin_tech = "combat=5;materials=4"
	fire_sound = 'sound/weapons/p90.ogg'
	mag_type = /obj/item/ammo_magazine/smg/p90
	accuracy = 27
	damage = 8
	fire_delay = 5
	gun_features = GUN_AUTO_EJECTOR | GUN_CAN_POINTBLANK | GUN_ON_MERCS

	New()
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 18, "rail_y" = 20, "under_x" = 22, "under_y" = 16)

//-------------------------------------------------------
