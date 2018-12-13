

//Minigun

/obj/item/ammo_magazine/minigun
	name = "rotating ammo drum (7.62x51mm)"
	desc = "A huge ammo drum for a huge gun."
	caliber = "7.62x51mm"
	icon_state = "painless" //PLACEHOLDER
	origin_tech = "combat=3;materials=3"
	matter = list("metal" = 10000)
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 300
	reload_delay = 24 //Hard to reload.
	gun_type = /obj/item/weapon/gun/minigun


//rocket launchers

/obj/item/ammo_magazine/rocket/toy
	name = "\improper toy rocket tube"
	desc = "Where did this come from?"
	default_ammo = /datum/ammo/rocket/toy
	caliber = "toy rocket"

/obj/item/ammo_magazine/internal/launcher/rocket/toy
	default_ammo = /datum/ammo/rocket/toy
	gun_type = /obj/item/weapon/gun/launcher/rocket/toy


