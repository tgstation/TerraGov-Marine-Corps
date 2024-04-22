/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = ""
	icon_state = "oldrifle-20"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	caliber = "laser"
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_icon()
	desc = ""
	icon_state = "oldrifle-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return
