


//-------------------------------------------------------
//M41A PULSE RIFLE AMMUNITION

/obj/item/ammo_magazine/rifle
	name = "\improper M41A1 magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = "10x24mm caseless"
	icon_state = "m41a1"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/m41a

/obj/item/ammo_magazine/rifle/extended
	name = "\improper M41A1 extended magazine (10x24mm)"
	desc = "A 10mm assault extended rifle magazine."
	icon_state = "m41a1_ext"
	max_rounds = 60
	bonus_overlay = "m41a1_ex"

/obj/item/ammo_magazine/rifle/incendiary
	name = "\improper M41A1 incendiary magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	icon_state = "m41a1_incendiary"
	default_ammo = /datum/ammo/bullet/rifle/incendiary

/obj/item/ammo_magazine/rifle/ap
	name = "\improper M41A1 AP magazine (10x24mm)"
	desc = "A 10mm armor piercing magazine."
	icon_state = "m41a1_ap"
	default_ammo = /datum/ammo/bullet/rifle/ap

//-------------------------------------------------------
//T12 DMR

/obj/item/ammo_magazine/rifledmr
	name = "\improper T12 DMR magazine (10x27mm)"
	desc = "A 10mm DMR magazine."
	caliber = "T12 DMR bullet"
	icon_state = "t12"
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo = /datum/ammo/bullet/rifle/t12
	max_rounds = 15
	gun_type = /obj/item/weapon/gun/rifle/t12

//-------------------------------------------------------
//M41A TRUE AND ORIGINAL

/obj/item/ammo_magazine/rifle/m41aMK1
	name = "\improper M41A magazine (10x24mm)"
	desc = "A semi-rectangular box of rounds for the original M41A Pulse Rifle."
	icon_state = "m41a"
	max_rounds = 95
	gun_type = /obj/item/weapon/gun/rifle/m41aMK1



//-------------------------------------------------------
//MAR-40 AK CLONE //AK47 and FN FAL together as one.

/obj/item/ammo_magazine/rifle/ak47
	name = "\improper MAR magazine (7.62x39mm)"
	desc = "A 7.62x39mm magazine for the MAR series of firearms."
	caliber = "7.62x39mm"
	icon_state = "ak47"
	default_ammo = /datum/ammo/bullet/rifle/ak47
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/ak47

/obj/item/ammo_magazine/rifle/ak47/extended
	name = "\improper MAR extended magazine (7.62x39mm)"
	desc = "A 7.62x39mm MAR magazine, this one carries more rounds than the average magazine."
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
//M41AE2 HEAVY PULSE RIFLE

/obj/item/ammo_magazine/lmg
	name = "\improper M41AE2 ammo box (10x24mm)"
	desc = "A semi-rectangular box of rounds for the M41AE2 Heavy Pulse Rifle."
	icon_state = "m41ae2"
	caliber = "10x24mm caseless"
	default_ammo = /datum/ammo/bullet/rifle
	w_class = WEIGHT_CLASS_NORMAL
	max_rounds = 200
	gun_type = /obj/item/weapon/gun/rifle/lmg


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
