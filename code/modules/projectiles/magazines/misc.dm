// ammo boxes

/obj/item/ammo_magazine/packet
	name = "box of some kind of ammo"
	desc = "A packet containing some kind of ammo."
	icon_state_mini = "ammo_packet"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_magazine/packet/p10x24mm
	name = "box of 10x24mm"
	desc = "A box containing 150 rounds of 10x24mm caseless."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "box_10x24mm"
	default_ammo = /datum/ammo/bullet/rifle
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/p10x265mm
	name = "box of 10x26.5mm"
	desc = "A box containing 100 rounds of 10x26.5mm caseless."
	caliber = CALIBER_10x265_CASELESS
	icon_state = "box_10x265mm"
	default_ammo = /datum/ammo/bullet/rifle/standard_br
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p10x27mm
	name = "box of 10x27mm"
	desc = "A box containing 100 rounds of 10x27mm caseless."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "box_10x27mm"
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p10x25mm
	name = "box of 10x25mm"
	desc = "A box containing 125 rounds of 10x25mm caseless."
	caliber = CALIBER_10X25_CASELESS
	icon_state = "box_10x25mm"
	default_ammo = /datum/ammo/bullet/rifle/heavy
	current_rounds = 125
	max_rounds = 125

/obj/item/ammo_magazine/packet/p492x34mm
	name = "box of 4.92x34mm"
	desc = "A box containing 210 rounds of 4.92x34mm caseless."
	caliber = CALIBER_492X34_CASELESS
	icon_state = "box_492x34mm"
	default_ammo = /datum/ammo/bullet/rifle/hv
	current_rounds = 210
	max_rounds = 210

/obj/item/ammo_magazine/packet/p86x70mm
	name = "box of 8.6x70mm"
	desc = "A box containing 50 rounds of 8.6x70mm caseless."
	caliber = CALIBER_86X70
	icon_state = "box_86x70mm"
	default_ammo = /datum/ammo/bullet/sniper/pfc
	current_rounds = 50
	max_rounds = 50

/obj/item/ammo_magazine/packet/smart_minigun
	name = "SG-85 ammo bin"
	desc = "A hefty container stuffed to the absolute brim with 1000 rounds for the SG-85 powerpack."
	icon_state = "box_smartminigun"
	default_ammo = /datum/ammo/bullet/smart_minigun
	caliber = CALIBER_10x26_CASELESS
	current_rounds = 500
	max_rounds = 500
	w_class = WEIGHT_CLASS_NORMAL

// pistol packets

/obj/item/ammo_magazine/packet/p9mm
	name = "packet of 9mm"
	desc = "A packet containing 70 rounds of 9mm."
	caliber = CALIBER_9X19
	icon_state = "box_9mm"
	current_rounds = 70
	max_rounds = 70
	w_class = WEIGHT_CLASS_SMALL
	default_ammo = /datum/ammo/bullet/pistol

/obj/item/ammo_magazine/packet/magnum
	name = "packet of .44 magnum"
	icon_state = "box_44mag" //Maybe change this
	default_ammo = /datum/ammo/bullet/revolver/tp44
	caliber = CALIBER_44
	current_rounds = 49
	max_rounds = 49
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/packet/mateba
	name = "packet of .454 casull"
	icon_state = "box_454"
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	current_rounds = 42
	max_rounds = 42

/obj/item/ammo_magazine/packet/acp
	name = "packet of .45 ACP"
	icon_state = "box_45acp"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45ACP
	current_rounds = 50
	max_rounds = 50

/obj/item/ammo_magazine/packet/p9mmap
	name = "packet of 9mm AP"
	desc = "A packet containing 70 rounds of 9mm armor-piercing."
	icon_state = "box_9mmap"
	default_ammo = /datum/ammo/bullet/pistol/ap
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_9X19
	current_rounds = 70
	max_rounds = 70

/obj/item/ammo_magazine/packet/p10x26mm
	name = "packet of 10x26mm"
	desc = "A packet containing 100 rounds of 10x26mm caseless."
	icon_state = "box_10x26mm"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p10x20mm
	name = "packet of 10x20mm"
	desc = "A packet containing 125 rounds of 10x20mm caseless."
	icon_state = "box_10x20mm"
	caliber = CALIBER_10X20_CASELESS
	default_ammo = /datum/ammo/bullet/smg
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/p4570
	name = "packet of .45-70"
	desc = "A packet containing 50 rounds of .45-70 Government."
	caliber = CALIBER_4570
	icon_state = "box_44rim_mag"
	default_ammo = /datum/ammo/bullet/rifle/repeater
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 50
	max_rounds = 50
