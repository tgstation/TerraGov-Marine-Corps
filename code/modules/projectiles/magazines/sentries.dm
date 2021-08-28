/obj/item/ammo_magazine/sentry
	name = "\improper M30 box magazine (10x28mm Caseless)"
	desc = "A drum of 50 10x28mm caseless rounds for the UA 571-C sentry gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "ua571c"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 75
	default_ammo = /datum/ammo/bullet/turret
	gun_type = /obj/item/weapon/gun/sentry/big_sentry

/obj/item/ammo_magazine/minisentry
	name = "\improper M30 box magazine (10x20mm Caseless)"
	desc = "A box of 100 10x20mm caseless rounds for the UA-580 point defense sentry. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "ua580"
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X20
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/turret/mini
	gun_type = /obj/item/weapon/gun/sentry/mini

/obj/item/ammo_magazine/sentry_premade/dumb
	name = "M30 box magazine (10x28mm Caseless)"
	desc = "A box of 50 10x28mm caseless rounds for the UA 571-C Sentry Gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_BULKY
	flags_magazine = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 50
	default_ammo = /datum/ammo/bullet/turret/dumb
	gun_type = /obj/item/weapon/gun/sentry/premade/dumb
