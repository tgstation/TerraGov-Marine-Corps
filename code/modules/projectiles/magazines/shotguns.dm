//-------------------------------------------------------
//Generic shotgun magazines. Only three of them, since all shotguns can use the same ammo unless we add other gauges.

/*
Shotguns don't really use unique "ammo" like other guns. They just load from a pool of ammo and generate the projectile
on the go. There's also buffering involved. But, we do need the ammo to check handfuls type, and it's nice to have when
you're looking back on the different shotgun projectiles available. In short of it, it's not needed to have more than
one type of shotgun ammo, but I think it helps in referencing it. ~N
*/
/obj/item/ammo_magazine/shotgun
	name = "box of 12 gauge shotgun slugs"
	desc = "A box filled with heavy shotgun shells. A timeless classic. 12 Gauge."
	icon_state = "slugs"
	default_ammo = /datum/ammo/bullet/shotgun/slug
	caliber = CALIBER_12G //All shotgun rounds are 12g right now.
	gun_type = /obj/item/weapon/gun/shotgun
	max_rounds = 25 // Real shotgun boxes are usually 5 or 25 rounds. This works with the new system, five handfuls.
	w_class = WEIGHT_CLASS_BULKY // Can't throw it in your pocket, friend.
	icon_state_mini = "slugs"

/obj/item/ammo_magazine/shotgun/incendiary
	name = "box of 12 gauge incendiary slugs"
	desc = "A box filled with self-detonating incendiary shotgun rounds. 12 Gauge."
	icon_state = "incendiary"
	default_ammo = /datum/ammo/bullet/shotgun/incendiary
	icon_state_mini = "incendiary"

/obj/item/ammo_magazine/shotgun/buckshot
	name = "box of 12 gauge buckshot shells"
	desc = "A box filled with buckshot spread shotgun shells. 12 Gauge."
	icon_state = "buckshot"
	default_ammo = /datum/ammo/bullet/shotgun/buckshot
	icon_state_mini = "buckshot"

/obj/item/ammo_magazine/shotgun/flechette
	name = "box of 12 gauge flechette shells"
	desc = "A box filled with flechette shotgun shells. 12 Gauge."
	icon_state = "flechette"
	default_ammo = /datum/ammo/bullet/shotgun/flechette
	icon_state_mini = "flechette"

/obj/item/ammo_magazine/shotgun/beanbag
	name = "box of 12 gauge beanbag slugs"
	desc = "A box filled with beanbag shotgun shells used for non-lethal crowd control. 12 Gauge."
	icon_state = "beanbag"
	default_ammo = /datum/ammo/bullet/shotgun/beanbag
	icon_state_mini = "beanbag"

/obj/item/ammo_magazine/shotgun/tracker
	name = "box of 12 gauge tracker shells"
	desc = "A box filled with tracker shotgun shells. 12 Gauge."
	icon_state = "tracking"
	default_ammo = /datum/ammo/bullet/shotgun/tracker
	icon_state_mini = "tracking"

/obj/item/ammo_magazine/rifle/bolt
	name = "box of 7.62x54mmR rifle rounds"
	desc = "A box filled with rifle bullets."
	icon_state = "7.62" //Thank you Alterist
	default_ammo = /datum/ammo/bullet/sniper/svd
	caliber = CALIBER_762X54 //Cyka Blyat
	gun_type = /obj/item/weapon/gun/shotgun/pump/bolt
	max_rounds = 20 // Real rifle boxes are usually 20 rounds. This works with the new system, four handfuls.
	w_class = WEIGHT_CLASS_SMALL // CAN throw it in your pocket, friend.
	icon_state_mini = "mosin"

/obj/item/ammo_magazine/rifle/martini
	name = "box of .557/440 rifle rounds"
	desc = "A box filled with rifle bullets."
	icon_state = ".557"
	default_ammo = /datum/ammo/bullet/sniper/martini
	caliber = CALIBER_557
	gun_type = /obj/item/weapon/gun/shotgun/double/martini
	max_rounds = 20
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/pistol/derringer
	name = "box of .40 rimfire pistol rounds"
	desc = "A box filled with pistol bullets."
	icon_state = "derringer_box"
	default_ammo = /datum/ammo/bullet/pistol/superheavy/derringer
	caliber = CALIBER_41RIM
	gun_type = /obj/item/weapon/gun/shotgun/double/derringer
	max_rounds = 10
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_magazine/shotgun/mbx900
	name = "box of .410 sabot shells"
	desc = "A box filled with .410 sabot rounds."
	icon_state = "mbx900_sabot"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_sabot
	caliber = CALIBER_410
	gun_type = /obj/item/weapon/gun/shotgun/pump/lever/mbx900
	max_rounds = 25
	w_class = WEIGHT_CLASS_NORMAL
	icon_state_mini = "mbx900_sabot"

/obj/item/ammo_magazine/shotgun/mbx900/buckshot
	name = "box of .410 buckshot shells"
	desc = "A box filled with .410 buckshot rounds."
	icon_state = "mbx900_buckshot"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_buckshot
	icon_state_mini = "mbx900_buckshot"

/obj/item/ammo_magazine/shotgun/mbx900/tracking
	name = "box of .410 tracker shells"
	desc = "A box filled with .410 tracker rounds."
	icon_state = "mbx900_tracker"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_tracker
	icon_state_mini = "mbx900_tracker"

//-------------------------------------------------------

/*
Generic internal magazine. All shotguns will use this or a variation with different ammo number.
Since all shotguns share ammo types, the gun path is going to be the same for all of them. And it
also doesn't really matter. You can only reload them with handfuls.
*/
/obj/item/ammo_magazine/internal/shotgun
	name = "shotgun tube"
	desc = "An internal magazine. It is not supposed to be seen or removed."
	default_ammo = /datum/ammo/bullet/shotgun/flechette
	caliber = CALIBER_12G
	max_rounds = 8
	chamber_closed = 0

/obj/item/ammo_magazine/internal/shotgun/pump

/obj/item/ammo_magazine/internal/shotgun/pump/buckshot
	default_ammo = /datum/ammo/bullet/shotgun/buckshot

/obj/item/ammo_magazine/internal/shotgun/pump/CMB
	max_rounds = 8

/obj/item/ammo_magazine/internal/shotgun/masterkey
	max_rounds = 2

/obj/item/ammo_magazine/internal/shotgun/pump/bolt
	name = "internal magazine"
	default_ammo = /datum/ammo/bullet/sniper/svd
	caliber = CALIBER_762X54
	max_rounds = 5

/obj/item/ammo_magazine/internal/shotgun/martini
	name = "internal chamber"
	default_ammo = /datum/ammo/bullet/sniper/martini
	caliber = CALIBER_557
	max_rounds = 1
	chamber_closed = 1

/obj/item/ammo_magazine/internal/shotgun/derringer
	default_ammo = /datum/ammo/bullet/pistol/superheavy/derringer
	caliber = CALIBER_41RIM
	max_rounds = 2
	chamber_closed = 1

/obj/item/ammo_magazine/internal/shotgun/pump/lever
	name = "tubular magazine"
	default_ammo = /datum/ammo/bullet/revolver
	caliber = CALIBER_44
	max_rounds = 10

/obj/item/ammo_magazine/internal/shotgun/pump/lever/repeater
	name = "tubular magazine"
	default_ammo = /datum/ammo/bullet/revolver
	caliber = CALIBER_44
	max_rounds = 14

/obj/item/ammo_magazine/internal/shotgun/pump/lever/mbx900
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_buckshot
	caliber = CALIBER_410
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
