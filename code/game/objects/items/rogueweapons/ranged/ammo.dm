/obj/item/ammo_casing/caseless/rogue/bolt
	name = "bolt"
	desc = ""
	projectile_type = /obj/projectile/bullet/reusable/bolt
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)
	caliber = "regbolt"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt"
	dropshrink = 0.6
	max_integrity = 10
	force = 10

/obj/projectile/bullet/reusable/bolt
	name = "bolt"
	damage = 80
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bolt
	range = 15
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	woundclass = BCLASS_STAB
	flag = "bullet"
	speed = 0.3

/obj/item/ammo_casing/caseless/rogue/arrow
	name = "arrow"
	desc = ""
	projectile_type = /obj/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow"
	force = 20
	dropshrink = 0.6
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/thrust)
	max_integrity = 20

/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	damage = 35
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow
	range = 15
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	woundclass = BCLASS_STAB
	flag = "bullet"
	speed = 0.4

/obj/item/ammo_casing/caseless/rogue/arrow/stone
	icon_state = "stonearrow"
	max_integrity = 5

/obj/projectile/bullet/reusable/bullet
	name = "lead ball"
	damage = 50
	damage_type = BRUTE
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	ammo_type = /obj/item/ammo_casing/caseless/rogue/bullet
	range = 30
	hitsound = 'sound/combat/hits/hi_arrow2.ogg'
	embedchance = 100
	woundclass = BCLASS_STAB
	flag = "bullet"
	armor_penetration = 200
	speed = 0.1

/obj/item/ammo_casing/caseless/rogue/bullet
	name = "lead ball"
	desc = ""
	projectile_type = /obj/projectile/bullet/reusable/bullet
	caliber = "musketball"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball"
	dropshrink = 0.5
	possible_item_intents = list(/datum/intent/use)
	max_integrity = 0