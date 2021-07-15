//rocket launchers

/obj/item/ammo_magazine/rocket/toy
	name = "\improper toy rocket tube"
	desc = "Where did this come from?"
	default_ammo = /datum/ammo/rocket/toy
	caliber = "toy rocket"

/obj/item/ammo_magazine/internal/launcher/rocket/toy
	default_ammo = /datum/ammo/rocket/toy
	gun_type = /obj/item/weapon/gun/launcher/rocket/toy


// ammo boxes

/obj/item/ammo_magazine/packet
	name = "box of some kind of ammo"
	desc = "A packet containing some kind of ammo.."
	icon_state_mini = "ammo_packet"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_magazine/packet/p10x24mm
	name = "box of 10x24mm"
	desc = "A box containing 150 rounds of 10x24mm caseless.."
	caliber = CALIBER_10X24_CASELESS
	icon_state = "box_10x24mm"
	default_ammo = /datum/ammo/bullet/rifle
	current_rounds = 150
	max_rounds = 150

/obj/item/ammo_magazine/packet/p10x27mm
	name = "box of 10x27mm"
	desc = "A box containing 100 rounds of 10x27mm caseless.."
	caliber = CALIBER_10x27_CASELESS
	icon_state = "box_10x27mm"
	default_ammo = /datum/ammo/bullet/rifle/standard_dmr
	current_rounds = 100
	max_rounds = 100

/obj/item/ammo_magazine/packet/p492x34mm
	name = "box of 4.92x34mm"
	desc = "A box containing 210 rounds of 4.92x34mm caseless.."
	caliber = CALIBER_492X34_CASELESS
	icon_state = "box_492x34mm"
	default_ammo = /datum/ammo/bullet/rifle/hv
	max_rounds = 210
	gun_type = /obj/item/weapon/gun/rifle/tx11

/obj/item/ammo_magazine/packet/t25
	name = "box of 10x26mm (T-25)"
	desc = "A box containing 200 rounds of 10x26mm caseless tuned for a T-25 smartrifle.."
	icon_state = "box_t25"
	default_ammo = /datum/ammo/bullet/smartgun/smartrifle
	caliber = CALIBER_10x26_CASELESS
	max_rounds = 200

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
	current_rounds = 50
	max_rounds = 50
	w_class = WEIGHT_CLASS_SMALL
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver


/obj/item/ammo_magazine/packet/acp
	name = "packet of .45 ACP"
	icon_state = "box_45acp"
	default_ammo = /datum/ammo/bullet/pistol/heavy
	w_class = WEIGHT_CLASS_SMALL
	caliber = CALIBER_45ACP
	current_rounds = 50
	max_rounds = 50

/obj/item/ammo_magazine/packet/p10x26mm
	name = "packet of 10x26mm"
	desc = "A packet containing 100 rounds of 10x26mm caseless.."
	icon_state = "box_10x26mm"
	caliber = CALIBER_10x26_CASELESS
	default_ammo = /datum/ammo/bullet/rifle/machinegun
	w_class = WEIGHT_CLASS_SMALL
	current_rounds = 100
	max_rounds = 100

