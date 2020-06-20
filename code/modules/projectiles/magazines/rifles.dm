


//-------------------------------------------------------
//M41A PULSE RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle/
	name = "\improper M41A1 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = "10x24mm caseless"
	icon_state = "m41a1"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/m41a1

/obj/item/ammo_magazine/rifle/extended
	name = "\improper M41A1 extended magazine (10x24mm)"
	desc = "A 10mm assault extended rifle magazine."
	icon_state = "m41a1_ext"
	max_rounds = 60
	bonus_overlay = "m41a1_ex"
	gun_type = /obj/item/weapon/gun/rifle/m41a1

/obj/item/ammo_magazine/rifle/incendiary
	name = "\improper M41A1 incendiary magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	icon_state = "m41a1_incendiary"
	default_ammo = /datum/ammo/bullet/rifle/incendiary
	gun_type = /obj/item/weapon/gun/rifle/m41a1

/obj/item/ammo_magazine/rifle/ap
	name = "\improper M41A1 AP magazine (10x24mm)"
	desc = "A 10mm armor piercing magazine."
	icon_state = "m41a1_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap
	gun_type = /obj/item/weapon/gun/rifle/m41a1

//-------------------------------------------------------
//T18 Carbine

/obj/item/ammo_magazine/rifle/standard_carbine
	name = "\improper T-18 magazine (10x24mm)"
	desc = "A 10mm carbine magazine."
	caliber = "10x24mm caseless"
	icon_state = "t18"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 32
	gun_type = /obj/item/weapon/gun/rifle/standard_carbine

//-------------------------------------------------------
//T12 Assault Rifle

/obj/item/ammo_magazine/rifle/standard_assaultrifle
	name = "\improper T-12 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = "10x24mm caseless"
	icon_state = "t12"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 50
	gun_type = /obj/item/weapon/gun/rifle/standard_assaultrifle

//-------------------------------------------------------
//T37 DMR

/obj/item/ammo_magazine/rifle/standard_dmr
	name = "\improper T-37 magazine (10x27mm)"
	desc = "A 10mm DMR magazine."
	caliber = "10x27mm caseless"
	icon_state = "t37"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/standard_dmr

/obj/item/ammo_magazine/rifle/standard_dmr/incendiary
	name = "\improper T-64 incendiary magazine (10x27mm)"
	desc = "A 10mm incendiary DMR magazine, carries less rounds however."
	caliber = "10x27mm incendiary caseless"
	icon_state = "t37_incin"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr/incendiary
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/standard_dmr

//-------------------------------------------------------
//T64 BR

/obj/item/ammo_magazine/rifle/standard_br
	name = "\improper T-64 magazine (10x27mm)"
	desc = "A 10mm battle rifle magazine."
	caliber = "10x27mm caseless"
	icon_state = "t64"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	max_rounds = 25
	gun_type = /obj/item/weapon/gun/rifle/standard_br

/obj/item/ammo_magazine/rifle/standard_br/incendiary
	name = "\improper T-64 BR incendiary magazine (10x27mm)"
	desc = "A 10mm incendiary battle rifle magazine, carries less rounds however."
	caliber = "10x27mm incendiary caseless"
	icon_state = "t64_incin"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr/incendiary
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/standard_br

//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/ammo_magazine/rifle/m41a
	name = "\improper M41A magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the original M41A Pulse Rifle."
	icon_state = "m41a"
	max_rounds = 95
	gun_type = /obj/item/weapon/gun/rifle/m41a



//-------------------------------------------------------
//MAR-40 AK CLONE //AK47 and FN FAL together as one.

/obj/item/ammo_magazine/rifle/ak47
	name = "\improper AK magazine (7.62x39mm)"
	desc = "A 7.62x39mm magazine for the Kalashnikov series of firearms."
	caliber = "7.62x39mm"
	icon_state = "ak47"
	default_ammo = /datum/ammo/bullet/rifle/ak47
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/ak47

/obj/item/ammo_magazine/rifle/ak47/extended
	name = "\improper AK extended magazine (7.62x39mm)"
	desc = "A 7.62x39mm Kalashnikov magazine, this one carries more rounds than the average magazine."
	max_rounds = 60
	bonus_overlay = "ak47_ex"



//-------------------------------------------------------
//M16 RIFLE

/obj/item/ammo_magazine/rifle/m16
	name = "\improper M16 magazine (5.56x45mm)"
	desc = "A 5.56x45mm magazine for the M16 assault rifle platform."
	caliber = "5.56x45mm"
	icon_state = "m16" //PLACEHOLDER
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 30 //Also comes in 30 and 100 round Beta-C mag.
	gun_type = /obj/item/weapon/gun/rifle/m16


//-------------------------------------------------------
//T-42 Light Machine Gun

/obj/item/ammo_magazine/standard_lmg
	name = "\improper T-42 drum magazine (10x24mm)"
	desc = "A drum magazine for the T-42 light machine gun."
	icon_state = "t42"
	caliber = "10x24mm caseless"
	default_ammo = /datum/ammo/bullet/rifle
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 120
	gun_type = /obj/item/weapon/gun/rifle/standard_lmg

//-------------------------------------------------------
//T-60 General Purpose Machine Gun

/obj/item/ammo_magazine/standard_gpmg
	name = "\improper T-60 GPMG box magazine (10x26mm)"
	desc = "A drum magazine for the T-60 general purpose machinegun."
	icon_state = "t60"
	caliber = "10x26mm caseless"
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 250
	gun_type = /obj/item/weapon/gun/rifle/standard_gpmg
	reload_delay = 3 SECONDS

//-------------------------------------------------------
//M41AE2 HEAVY PULSE RIFLE

/obj/item/ammo_magazine/m41ae2_hpr
    name = "\improper M41AE2 box magazine (10x24mm)"
    desc = "A semi-rectangular box of rounds for the M41AE2 heavy pulse rifle."
    icon_state = "m41ae2"
    caliber = "10x24mm caseless"
    default_ammo = /datum/ammo/bullet/rifle
    w_class = WEIGHT_CLASS_NORMAL
    max_rounds = 200
    gun_type = /obj/item/weapon/gun/rifle/m41ae2_hpr

//-------------------------------------------------------
//UPP TYPE 71 RIFLE

/obj/item/ammo_magazine/rifle/type71
	name = "\improper Type 71 magazine (7.62x39mm)"
	desc = "A 7.62x39mm magazine that fits in the Type 71 rifle."
	caliber = "7.62x39mm"
	icon_state = "type_71"
	default_ammo = /datum/ammo/bullet/rifle/ak47
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/type71


//-------------------------------------------------------
//SX-16 AUTOMATIC SHOTGUN (makes more sense for it to be a rifle)

/obj/item/ammo_magazine/rifle/sx16_buckshot
	name = "\improper SX-16 buckshot magazine (16 gauge)"
	desc = "A magazine of 16 gauge buckshot, for the SX-16."
	caliber = "16 gauge"
	icon_state = "sx16_buckshot"
	default_ammo = /datum/ammo/bullet/shotgun/sx16_buckshot
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/sx16

/obj/item/ammo_magazine/rifle/sx16_flechette
	name = "\improper SX-16 flechette magazine (16 gauge)"
	desc = "A magazine of 16 gauge flechette rounds, for the SX-16."
	caliber = "16 gauge"
	icon_state = "sx16_flechette"
	default_ammo = /datum/ammo/bullet/shotgun/sx16_flechette
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/sx16

/obj/item/ammo_magazine/rifle/sx16_slug
	name = "\improper SX-16 slug magazine (16 gauge)"
	desc = "A magazine of 16 gauge slugs, for the SX-16."
	caliber = "16 gauge"
	icon_state = "sx16_slug"
	default_ammo = /datum/ammo/bullet/shotgun/sx16_slug
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/sx16

//TX-16 AUTOMATIC SHOTGUN

/obj/item/ammo_magazine/rifle/tx15_flechette
	name = "\improper TX-15 flechette magazine (16 gauge)"
	desc = "A magazine of 16 gauge flechette rounds, for the TX-15."
	caliber = "16 gauge"
	icon_state = "tx15_flechette"
	default_ammo = /datum/ammo/bullet/shotgun/tx15_flechette
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/rifle/standard_autoshotgun

/obj/item/ammo_magazine/rifle/tx15_slug
	name = "\improper TX-15 slug magazine (16 gauge)"
	desc = "A magazine of 16 gauge slugs, for the TX-15."
	caliber = "16 gauge"
	icon_state = "tx15_slug"
	default_ammo = /datum/ammo/bullet/shotgun/tx15_slug
	max_rounds = 12
	gun_type = /obj/item/weapon/gun/rifle/standard_autoshotgun

//-------------------------------------------------------
//SMARTMACHINEGUN AMMUNITION

/obj/item/ammo_magazine/standard_smartmachinegun
	name = "\improper T-29 drum magazine (10x26mm)"
	desc = "A 10mm drum magazine."
	caliber = "10x26mm caseless"
	icon_state = "t29"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/smartmachinegun
	max_rounds = 200
	gun_type = /obj/item/weapon/gun/rifle/standard_smartmachinegun
	reload_delay = 2.5 SECONDS


//-------------------------------------------------------
//Sectoid Rifle

/obj/item/ammo_magazine/rifle/sectoid_rifle
	name = "alien rifle plasma magazine"
	desc = "A magazine filled with powerful plasma rounds. The ammo inside doesn't look like anything you've seen before."
	caliber = "alien alloy"
	icon_state = "alien_rifle"
	default_ammo = /datum/ammo/energy/plasma
	max_rounds = 20
	gun_type = /obj/item/weapon/gun/rifle/sectoid_rifle
