/obj/item/ammo_magazine/sentry
	name = "\improper M30 box magazine (10x28mm Caseless)"
	desc = "A drum of 50 10x28mm caseless rounds for the ST-571 sentry gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "sentry"
	icon = 'icons/obj/items/ammo/sentry.dmi'
	magazine_flags = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret

/obj/item/ammo_magazine/minisentry
	name = "\improper M30 box magazine (10x20mm Caseless)"
	desc = "A box of 100 10x20mm caseless rounds for the ST-580 point defense sentry. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "ua580"
	icon = 'icons/obj/items/ammo/sentry.dmi'
	magazine_flags = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X20
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/turret/mini

/obj/item/ammo_magazine/sentry_premade/dumb
	name = "M30 box magazine (10x28mm Caseless)"
	desc = "A box of 50 10x28mm caseless rounds for the ST-571 Sentry Gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "sentry"
	icon = 'icons/obj/items/ammo/sentry.dmi'
	magazine_flags = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/turret/dumb

/obj/item/ammo_magazine/sentry/fob_sentry
	max_rounds = INFINITY

// Sniper Sentry

/obj/item/ammo_magazine/sentry/sniper
	name = "\improper SST-574 box magazine (10x28mm Caseless)"
	desc = "A magazine of 50 10x28mm caseless rounds for the SST-574 sentry gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	icon_state = "sniper_sentry"
	max_rounds = 75
	default_ammo = /datum/ammo/bullet/turret/sniper

// Shotgun Sentry

/obj/item/ammo_magazine/sentry/shotgun
	name = "\improper SHT-573 drum magazine (12G Caseless)"
	desc = "A drum of 200 specialized telescopic 12G rounds for the SST-573 sentry gun. Just feed it into the sentry gun's ammo port when its ammo is depleted."
	caliber = CALIBER_12G
	icon_state = "shotgun_sentry"
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/turret/buckshot

// Flamer Sentry

/obj/item/ammo_magazine/sentry/flamer
	name = "\improper SFT-575 fuel canister"
	desc = "A fuel canister for the SFT-575 sentry gun. Just feed it into the sentry gun's fuel port when its fuel is depleted."
	caliber = CALIBER_FUEL
	icon_state = "flamer_sentry"
	max_rounds = 500
	default_ammo = /datum/ammo/flamethrower/sentry

/obj/item/ammo_magazine/sentry/laser
	name = "\improper SLT-576 sentry gun laser battery"
	desc = "A battery for the SLT-576 sentry gun. Just feed it into the sentry gun's battery port when its charge is depleted."
	caliber = CALIBER_LASER
	icon_state = "laser_sentry"
	max_rounds = 500
	default_ammo = /datum/ammo/energy/lasersentry
