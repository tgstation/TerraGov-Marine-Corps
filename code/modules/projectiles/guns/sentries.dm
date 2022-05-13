/obj/item/weapon/gun/sentry
	name = "sentry"
	desc = "sentry"
	icon = 'icons/Marine/sentry.dmi'

	fire_sound = 'sound/weapons/guns/fire/smg_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/smartgun_unload.ogg'

	max_integrity = 200
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 80, "acid" = 50)

	fire_delay = 0.6 SECONDS
	extra_delay = 0.6 SECONDS
	burst_delay = 0.3 SECONDS
	scatter = 20
	scatter_unwielded = 0
	burst_scatter_mult = 0
	burst_amount = 4

	ignored_terrains = list(
		/obj/machinery/deployable/mounted,
		/obj/machinery/miner,
	)

	turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	deployed_item = /obj/machinery/deployable/mounted/sentry
	flags_item = IS_DEPLOYABLE|TWOHANDED
	deploy_time = 5 SECONDS

	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

/obj/item/storage/box/sentry
	name = "\improper ST-571 sentry crate"
	desc = "A large case containing all you need to set up an automated sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 5
	storage_slots = 6
	max_storage_space = 16
	can_hold = list(
		/obj/item/weapon/gun/sentry,
		/obj/item/ammo_magazine/sentry,
	)
	bypass_w_limit = list(
		/obj/item/weapon/gun/sentry,
		/obj/item/ammo_magazine/sentry,
	)

/obj/item/storage/box/sentry/Initialize()
	. = ..()
	new /obj/item/weapon/gun/sentry/big_sentry(src)
	new /obj/item/ammo_magazine/sentry(src)

/obj/item/weapon/gun/sentry/big_sentry
	name = "\improper ST-571 sentry gun"
	desc = "A deployable, fully automatic turret with AI targeting capabilities. Armed with a M30 autocannon and a 500-round drum magazine."
	icon_state = "sentry"

	turret_range = 8
	deploy_time = 6 SECONDS
	max_shells = 500
	fire_delay = 0.25 SECONDS

	scatter = 2

	ammo_datum_type = /datum/ammo/bullet/turret
	default_ammo_type = /obj/item/ammo_magazine/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/tl102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

/obj/item/weapon/gun/sentry/big_sentry/premade
	sentry_iff_signal = TGMC_LOYALIST_IFF
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/big_sentry/dropship
	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	var/obj/structure/dropship_equipment/sentry_holder/deployment_system
	turret_flags = TURRET_HAS_CAMERA|TURRET_IMMOBILE
	density = FALSE

/obj/item/weapon/gun/sentry/big_sentry/dropship/rebel
	sentry_iff_signal = TGMC_REBEL_IFF

/obj/item/weapon/gun/sentry/big_sentry/fob_sentry
	max_integrity = INFINITY //Good luck killing it
	fire_delay = 0.2 SECONDS
	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	flags_item = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	turret_flags = TURRET_IMMOBILE|TURRET_RADIAL|TURRET_LOCKED|TURRET_ON
	default_ammo_type = /obj/item/ammo_magazine/sentry/fob_sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/fob_sentry)

/obj/item/weapon/gun/sentry/big_sentry/fob_sentry/rebel
	sentry_iff_signal = TGMC_REBEL_IFF

/obj/item/storage/box/minisentry
	name = "\improper ST-580 point defense sentry crate"
	desc = "A large case containing all you need to set up an ST-580 point defense sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	can_hold = list(
		/obj/item/weapon/gun/sentry/mini,
		/obj/item/ammo_magazine/minisentry,
	)

/obj/item/storage/box/minisentry/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/sentry/mini(src)
	new /obj/item/ammo_magazine/minisentry(src)
	new /obj/item/ammo_magazine/minisentry(src)

/obj/item/weapon/gun/sentry/mini
	name = "\improper ST-580 point defense sentry"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 100-round drum magazine."
	icon_state = "minisentry"

	max_shells = 300
	knockdown_threshold = 80

	ammo_datum_type = /datum/ammo/bullet/turret/mini
	default_ammo_type = /obj/item/ammo_magazine/minisentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/minisentry)

	fire_delay = 0.2 SECONDS
	burst_delay = 0.2 SECONDS
	burst_amount = 3
	extra_delay = 0.3 SECONDS
	scatter = 3

	deploy_time = 3 SECONDS
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

/obj/item/weapon/gun/sentry/premade
	name = "SG-577 Gauss Turret"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an armor penetrating MIC Gauss Cannon and a high-capacity drum magazine."
	icon_state = "sentry"
	turret_flags = TURRET_HAS_CAMERA|TURRET_ON|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL
	max_shells = 100

	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	default_ammo_type = /obj/item/ammo_magazine/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/premade/dumb
	name = "\improper Modified ST-571 sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY
	ammo_datum_type = /datum/ammo/bullet/turret/dumb
	default_ammo_type = /obj/item/ammo_magazine/sentry_premade/dumb
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry_premade/dumb)
	max_shells = 500
	turret_flags = TURRET_ON|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL

/obj/item/weapon/gun/sentry/premade/dumb/hostile
	name = "malfunctioning ST-571 sentry gun"
	desc = "Oh god oh fuck."
	turret_flags = TURRET_LOCKED|TURRET_ON|TURRET_IMMOBILE|TURRET_RADIAL
	sentry_iff_signal = NONE

/obj/item/weapon/gun/sentry/premade/canterbury
	name = "SG-577 Gauss Dropship Turret"
	ammo_datum_type = /datum/ammo/bullet/turret
	sentry_iff_signal = TGMC_LOYALIST_IFF


