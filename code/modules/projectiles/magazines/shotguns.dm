//-------------------------------------------------------
//Generic shotgun magazines. Only three of them, since all shotguns can use the same ammo unless we add other gauges.

/*
Shotguns don't really use unique "ammo" like other guns. They just load from a pool of ammo and generate the projectile
on the go. There's also buffering involved. But, we do need the ammo to check handfuls type, and it's nice to have when
you're looking back on the different shotgun projectiles available. In short of it, it's not needed to have more than
one type of shotgun ammo, but I think it helps in referencing it. ~N
*/
/obj/item/ammo_magazine/shotgun
	name = "box of shotgun slugs"
	desc = "A box filled with heavy shotgun shells. A timeless classic. 12 Gauge."
	icon_state = "slugs"
	default_ammo = /datum/ammo/bullet/shotgun/slug
	caliber = "12g" //All shotgun rounds are 12g right now.
	gun_type = /obj/item/weapon/gun/shotgun
	max_rounds = 25 // Real shotgun boxes are usually 5 or 25 rounds. This works with the new system, five handfuls.
	w_class = WEIGHT_CLASS_BULKY // Can't throw it in your pocket, friend.

/obj/item/ammo_magazine/shotgun/incendiary
	name = "box of incendiary slugs"
	desc = "A box filled with self-detonating incendiary shotgun rounds. 12 Gauge."
	icon_state = "incendiary"
	default_ammo = /datum/ammo/bullet/shotgun/incendiary

/obj/item/ammo_magazine/shotgun/buckshot
	name = "box of buckshot shells"
	desc = "A box filled with buckshot spread shotgun shells. 12 Gauge."
	icon_state = "buckshot"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot

/obj/item/ammo_magazine/shotgun/flechette
	name = "box of flechette shells"
	desc = "A box filled with flechette shotgun shells. 12 Gauge."
	icon_state = "flechette"
	default_ammo = /datum/ammo/bullet/shotgun/flechette

/obj/item/ammo_magazine/shotgun/beanbag
	name = "box of beanbag slugs"
	desc = "A box filled with beanbag shotgun shells used for non-lethal crowd control. 12 Gauge."
	icon_state = "beanbag"
	default_ammo = /datum/ammo/bullet/shotgun/beanbag

/obj/item/ammo_magazine/rifle/bolt
	name = "box of rifle bullets"
	desc = "A box filled with rifle bullets."
	icon_state = "7.62" //Thank you Alterist
	default_ammo = /datum/ammo/bullet/sniper/svd
	caliber = "7.62x54mmR" //Cyka Blyat
	gun_type = /obj/item/weapon/gun/shotgun/pump/bolt
	max_rounds = 20 // Real rifle boxes are usually 20 rounds. This works with the new system, four handfuls.
	w_class = WEIGHT_CLASS_SMALL // CAN throw it in your pocket, friend.

/obj/item/ammo_magazine/shotgun/mbx900
	name = ".410 sabot ammo box"
	desc = "A box filled with .410 Sabot rounds."
	icon_state = "mbx900_sabot"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_sabot
	caliber = ".410"
	gun_type = /obj/item/weapon/gun/shotgun/pump/lever/mbx900
	max_rounds = 25
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_magazine/shotgun/mbx900/buckshot
	name = ".410 buckshot ammo box"
	desc = "A box filled with .410 buckshot rounds."
	icon_state = "mbx900_buckshot"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_buckshot

/obj/item/ammo_magazine/shotgun/mbx900/tracking
	name = ".410 tracker ammo box"
	desc = "A box filled with .410 tracker rounds."
	icon_state = "mbx900_tracker"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_tracker

//-------------------------------------------------------

/*
Generic internal magazine. All shotguns will use this or a variation with different ammo number.
Since all shotguns share ammo types, the gun path is going to be the same for all of them. And it
also doesn't really matter. You can only reload them with handfuls.
*/
/obj/item/ammo_magazine/internal/shotgun
	name = "shotgun tube"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = /datum/ammo/bullet/shotgun/slug
	caliber = "12g"
	max_rounds = 8
	chamber_closed = 0

/obj/item/ammo_magazine/internal/shotgun/pump

/obj/item/ammo_magazine/internal/shotgun/pump/CMB
	max_rounds = 8

/obj/item/ammo_magazine/internal/shotgun/pump/ksg
	max_rounds = 12

/obj/item/ammo_magazine/internal/shotgun/pump/bolt
	name = "internal magazine"
	default_ammo = /datum/ammo/bullet/sniper/svd
	caliber = "7.62x54mmR"
	max_rounds = 5

/obj/item/ammo_magazine/internal/shotgun/pump/lever
	name = "tubular magazine"
	default_ammo = /datum/ammo/bullet/revolver
	caliber = ".44"
	max_rounds = 10

/obj/item/ammo_magazine/internal/shotgun/pump/lever/mbx900
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_buckshot
	caliber = ".410"
	current_rounds = 0

/obj/item/ammo_magazine/internal/shotgun/double
	default_ammo = /datum/ammo/bullet/shotgun/buckshot
	max_rounds = 2
	chamber_closed = 1 //Starts out with a closed tube.

/obj/item/ammo_magazine/internal/shotgun/combat
	max_rounds = 9

/obj/item/ammo_magazine/internal/shotgun/merc
	max_rounds = 5

/obj/item/ammo_magazine/internal/shotgun/scout
	max_rounds = 9
	current_rounds = 0
