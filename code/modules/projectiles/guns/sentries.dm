/obj/item/weapon/gun/sentry
	name = "sentry"
	desc = "sentry"
	icon = 'icons/Marine/sentry.dmi'

	fire_sound = 'sound/weapons/guns/fire/smg_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/smartgun_unload.ogg'

	max_integrity = 200

	fire_delay = 0.6 SECONDS
	extra_delay = 0.6 SECONDS
	burst_delay = 0.3 SECONDS
	scatter = 20
	scatter_unwielded = 0
	burst_scatter_mult = 0
	burst_amount = 4

	turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IS_SENTRY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	flags_item = IS_DEPLOYABLE|TWOHANDED
	deploy_time = 5 SECONDS

	sentry_battery_type = /obj/item/cell/lasgun/lasrifle/marine


/obj/item/weapon/gun/sentry/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/sentry/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

/obj/item/storage/box/sentry
	name = "\improper UA 571-C sentry crate"
	desc = "A large case containing all you need to set up an automated sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 5
	storage_slots = 6
	max_storage_space = 16
	bypass_w_limit = list(
		/obj/item/weapon/gun/sentry,
		/obj/item/cell,
		/obj/item/ammo_magazine/sentry,
	)

/obj/item/storage/box/sentry/Initialize()
	. = ..()
	new /obj/item/weapon/gun/sentry/big_sentry(src)
	new /obj/item/ammo_magazine/sentry(src)
	new /obj/item/cell/lasgun/lasrifle/marine(src)
	new /obj/item/cell/lasgun/lasrifle/marine(src)

/obj/item/weapon/gun/sentry/big_sentry
	name = "\improper UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with a M30 autocannon and a 25-round box magazine. Use Alt-Click to remove its battery."
	icon_state = "sentry"

	turret_range = 8
	deploy_time = 8 SECONDS
	max_shells = 50

	ammo = /datum/ammo/bullet/turret
	current_mag = /obj/item/ammo_magazine/sentry

	sentry_battery_drain = 50

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

/obj/item/weapon/gun/sentry/big_sentry/premade
	sentry_iff_signal = TGMC_LOYALIST_IFF
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/big_sentry/dropship
	ammo = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE
	var/obj/structure/dropship_equipment/sentry_holder/deployment_system
	turret_flags = TURRET_HAS_CAMERA|TURRET_IMMOBILE
	density = FALSE

/obj/item/weapon/gun/sentry/big_sentry/dropship/rebel
	sentry_iff_signal = TGMC_REBEL_IFF

/obj/item/storage/box/minisentry
	name = "\improper UA-580 point defense sentry crate"
	desc = "A large case containing all you need to set up an UA-580 point defense sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 6
	can_hold = list(
		/obj/item/weapon/gun/sentry/mini,
		/obj/item/ammo_magazine/minisentry,
		/obj/item/cell/lasgun/lasrifle/marine,
	)

/obj/item/storage/box/minisentry/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/sentry/mini(src)
	new /obj/item/ammo_magazine/minisentry(src)
	new /obj/item/ammo_magazine/minisentry(src)
	new /obj/item/cell/lasgun/lasrifle/marine(src)
	new /obj/item/cell/lasgun/lasrifle/marine(src)

/obj/item/weapon/gun/sentry/mini
	name = "\improper UA-580 point defense sentry"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 100-round drum magazine. Use Alt-Click to remove its battery."
	icon_state = "minisentry"

	max_shells = 100
	knockdown_threshold = 80

	ammo = /datum/ammo/bullet/turret/mini
	current_mag = /obj/item/ammo_magazine/minisentry

	fire_delay = 0.3 SECONDS
	burst_delay = 0.2 SECONDS
	burst_amount = 3
	extra_delay = 0.3 SECONDS
	scatter = 2

	deploy_time = 3 SECONDS
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

/obj/item/weapon/gun/sentry/premade
	name = "UA-577 Gauss Turret"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an armor penetrating MIC Gauss Cannon and a high-capacity drum magazine."
	icon_state = "sentry"
	turret_flags = TURRET_HAS_CAMERA|TURRET_ON|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL
	max_shells = 100

	ammo = /datum/ammo/bullet/turret/gauss
	current_mag = /obj/item/ammo_magazine/sentry

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/premade/dumb
	name = "\improper Modified UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IS_SENTRY
	ammo = /datum/ammo/bullet/turret/dumb
	current_mag = /obj/item/ammo_magazine/sentry_premade/dumb
	max_shells = 500
	turret_flags = TURRET_ON|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL

/obj/item/weapon/gun/sentry/premade/dumb/hostile
	name = "malfunctioning UA 571-C sentry gun"
	desc = "Oh god oh fuck."
	turret_flags = TURRET_LOCKED|TURRET_ON|TURRET_IMMOBILE|TURRET_RADIAL
	sentry_iff_signal = NONE

/obj/item/weapon/gun/sentry/premade/canterbury
	name = "UA-577 Gauss Dropship Turret"
	ammo = /datum/ammo/bullet/turret
	sentry_iff_signal = TGMC_LOYALIST_IFF


