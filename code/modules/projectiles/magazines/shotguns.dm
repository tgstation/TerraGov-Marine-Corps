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
	max_rounds = 20 // Real rifle boxes are usually 20 rounds. This works with the new system, four handfuls.
	w_class = WEIGHT_CLASS_SMALL // CAN throw it in your pocket, friend.
	icon_state_mini = "mosin"

/obj/item/ammo_magazine/rifle/boltclip //Nearly 1:1 copy of above
	name = "clip of 7.62x54mmR rifle rounds"
	desc = "A Disposible Stripper clip filled with rifle bullets."
	icon_state = "clip"
	default_ammo = /datum/ammo/bullet/sniper/svd
	caliber = CALIBER_762X54
	max_rounds = 4
	w_class = WEIGHT_CLASS_SMALL
	icon_state_mini = "clip"

/obj/item/ammo_magazine/rifle/martini
	name = "box of .557/440 rifle rounds"
	desc = "A box filled with rifle bullets."
	icon_state = ".557"
	default_ammo = /datum/ammo/bullet/sniper/martini
	caliber = CALIBER_557
	max_rounds = 20
	w_class = WEIGHT_CLASS_SMALL
	icon_state_mini = "martini"

/obj/item/ammo_magazine/pistol/derringer
	name = "box of .40 rimfire pistol rounds"
	desc = "A box filled with pistol bullets."
	icon_state = "derringer_box"
	default_ammo = /datum/ammo/bullet/pistol/superheavy/derringer
	caliber = CALIBER_41RIM
	max_rounds = 10
	w_class = WEIGHT_CLASS_SMALL
	icon_state_mini = "ammo_packet"

/obj/item/ammo_magazine/shotgun/mbx900
	name = "box of .410 sabot shells"
	desc = "A box filled with .410 sabot rounds."
	icon_state = "mbx900_sabot"
	default_ammo = /datum/ammo/bullet/shotgun/mbx900_sabot
	caliber = CALIBER_410
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

/obj/item/ammo_magazine/internal/shotgun/pump/arrow
	name = "internal magazine"
	default_ammo = /datum/ammo/bullet/sniper/arrow
	caliber = "Arrows"
	max_rounds = 1
