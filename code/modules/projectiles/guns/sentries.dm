/obj/item/weapon/gun/sentry
	name = "sentry"
	desc = "sentry"
	icon = 'icons/obj/machines/deployable/sentry/sentry.dmi'

	fire_sound = 'sound/weapons/guns/fire/smg_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/smartgun_unload.ogg'

	max_integrity = 200
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 80, ACID = 50)

	fire_delay = 0.6 SECONDS
	extra_delay = 0.6 SECONDS
	burst_delay = 0.3 SECONDS
	scatter = 20
	scatter_unwielded = 0
	burst_scatter_mult = 0
	burst_amount = 4
	turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	deployable_item = /obj/machinery/deployable/mounted/sentry
	item_flags = IS_DEPLOYABLE|TWOHANDED
	deploy_time = 5 SECONDS

	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

/obj/item/storage/box/crate/sentry
	name = "\improper ST-571 sentry crate"
	desc = "A large case containing all you need to set up an automated sentry."
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_type = /datum/storage/box/crate/sentry

/obj/item/storage/box/crate/sentry/PopulateContents()
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

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/hsg_102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/hsg_102,
	)

/obj/item/weapon/gun/sentry/pod_sentry
	name = "\improper ST-583 sentry gun"
	desc = "A fully automatic turret with AI targeting capabilities, designed specifically for deploying inside a paired drop pod shell. Armed with a M30 autocannon and a 500-round drum magazine. Designed to sweeping a landing area to support orbital assaults."
	icon_state = "pod_sentry"
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL
	item_flags = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	sentry_iff_signal = TGMC_LOYALIST_IFF
	turret_range = 10
	knockdown_threshold = 500
	max_shells = 500
	fire_delay = 0.15 SECONDS
	burst_amount = 1
	scatter = 12
	ammo_datum_type = /datum/ammo/bullet/turret
	default_ammo_type = /obj/item/ammo_magazine/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

//thrown SOM sentry
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope
	name = "\improper COPE sentry"
	desc = "The Centurion Omnidirectional Point-defense Energy sentry is a man portable, automated weapon system utilised by the SOM. It is activated in hand then thrown into place before it deploys, where it's ground hugging profile makes it a difficult target to accurately hit. Equipped with a compact volkite weapon system, and a recharging battery to allow for prolonged use, but can take normal volkite cells in a pinch."
	icon_state = "cope"
	icon = 'icons/obj/machines/deployable/sentry/cope.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/guns/misc_left_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/guns/misc_right_1.dmi',
	)
	max_integrity = 225
	integrity_failure = 50
	deploy_time = 1 SECONDS
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL
	deployable_item = /obj/machinery/deployable/mounted/sentry/cope
	turret_range = 9
	w_class = WEIGHT_CLASS_NORMAL //same as other sentries
	sentry_iff_signal = SOM_IFF

	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 80, ACID = 50)

	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_ENERGY|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE //doesn't autoeject its recharging battery
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	item_flags = IS_DEPLOYABLE|TWOHANDED

	max_shots = 150
	rounds_per_shot = 12
	fire_delay = 0.2 SECONDS
	scatter = -3
	damage_falloff_mult = 0.5
	ammo_datum_type = /datum/ammo/energy/volkite/light
	default_ammo_type = /obj/item/cell/lasgun/volkite/turret
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite/turret, /obj/item/cell/lasgun/volkite)

	///How long to deploy after thrown
	var/det_time = 4 SECONDS
	///The sound made when activated
	var/arm_sound = 'sound/weapons/armbomb.ogg'

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/attack_self(mob/user)
	if(active)
		return

	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	activate(user)

	user.visible_message(span_warning("[user] primes \a [name]!"), \
	span_warning("You prime \a [name]!"))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/activate(mob/user)
	if(active)
		return

	icon_state = initial(icon_state) + "_active"
	active = TRUE
	playsound(loc, arm_sound, 25, 1, 6)
	var/obj/item/card/id/user_id = user?.get_idcard(TRUE)
	if(user_id)
		sentry_iff_signal = user_id?.iff_signal
	addtimer(CALLBACK(src, PROC_REF(prime), user), det_time)

///Reverts the gun back to it's unarmed state, allowing it to be activated again
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/proc/reset()
	active = FALSE
	icon_state = initial(icon_state)

///Deploys the weapon into a sentry after activation
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/proc/prime(mob/user)
	if(!isturf(loc)) //no deploying out of bags or in hand
		reset()
		return
	do_deploy(user)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/predeployed
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/weapon/gun/sentry/big_sentry/premade
	sentry_iff_signal = TGMC_LOYALIST_IFF
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/big_sentry/premade/radial
	turret_range = 9
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/weapon/gun/sentry/big_sentry/dropship
	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	var/obj/structure/dropship_equipment/shuttle/sentry_holder/deployment_system
	turret_flags = TURRET_HAS_CAMERA|TURRET_IMMOBILE
	density = FALSE

/obj/item/weapon/gun/sentry/big_sentry/fob_sentry
	max_integrity = INFINITY //Good luck killing it
	fire_delay = 0.2 SECONDS
	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	item_flags = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	turret_flags = TURRET_IMMOBILE|TURRET_RADIAL|TURRET_LOCKED|TURRET_ON
	default_ammo_type = /obj/item/ammo_magazine/sentry/fob_sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/fob_sentry)

/obj/item/storage/box/crate/minisentry
	name = "\improper ST-580 point defense sentry crate"
	desc = "A large case containing all you need to set up an ST-580 point defense sentry."
	icon_state = "sentry_mini_case"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/storage/box/crate/minisentry/Initialize(mapload, ...)
	. = ..()
	storage_datum.storage_slots = 6
	storage_datum.set_holdable(can_hold_list = list(
		/obj/item/weapon/gun/sentry/mini,
		/obj/item/ammo_magazine/minisentry,
	))

/obj/item/storage/box/crate/minisentry/PopulateContents()
	new /obj/item/weapon/gun/sentry/mini(src)
	new /obj/item/ammo_magazine/minisentry(src)
	new /obj/item/ammo_magazine/minisentry(src)

/obj/item/weapon/gun/sentry/mini
	name = "\improper ST-580 point defense sentry"
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 300-round drum magazine."
	icon_state = "mini_sentry"
	icon = 'icons/obj/machines/deployable/sentry/mini.dmi'

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

	deploy_time = 1 SECONDS
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

/obj/item/weapon/gun/sentry/mini/combat_patrol
	sentry_iff_signal = TGMC_LOYALIST_IFF
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS

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
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/premade/dumb
	name = "\improper Modified ST-571 sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
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

// Sniper Sentry

/obj/item/weapon/gun/sentry/sniper_sentry
	name = "\improper SST-574 sentry gun"
	desc = "A deployable, fully automatic turret with AI targeting capabilities. Armed with a heavy caliber AM-5 antimaterial rifle and a 75-round drum magazine."
	icon_state = "sniper_sentry"
	icon = 'icons/obj/machines/deployable/sentry/sniper.dmi'
	fire_sound = 'sound/weapons/guns/fire/sniper_heavy.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_heavy_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_heavy_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/sniper_heavy_cocked.ogg'

	turret_range = 12
	deploy_time = 10 SECONDS
	max_shells = 75
	fire_delay = 2 SECONDS
	burst_amount = 1

	scatter = 0

	ammo_datum_type = /datum/ammo/bullet/turret/sniper
	default_ammo_type = /obj/item/ammo_magazine/sentry/sniper
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/sniper)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable,
	)

/obj/item/storage/box/crate/sentry_sniper
	name = "\improper SST-574 sentry crate"
	desc = "A large case containing all you need to set up an automated sentry."
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/storage/box/crate/sentry_sniper/Initialize(mapload)
	. = ..()
	storage_datum.max_w_class = WEIGHT_CLASS_HUGE
	storage_datum.storage_slots = 6
	storage_datum.max_storage_space = 16
	storage_datum.set_holdable(
		can_hold_list = list(
			/obj/item/weapon/gun/sentry/sniper_sentry,
			/obj/item/ammo_magazine/sentry/sniper,
		),
		storage_type_limits_list = list(
			/obj/item/weapon/gun/sentry/sniper_sentry,
			/obj/item/ammo_magazine/sentry/sniper,
		)
	)

/obj/item/storage/box/crate/sentry_sniper/PopulateContents()
	new /obj/item/weapon/gun/sentry/sniper_sentry(src)
	new /obj/item/ammo_magazine/sentry/sniper(src)

// Shotgun Sentry

/obj/item/weapon/gun/sentry/shotgun_sentry
	name = "\improper SHT-573 sentry gun"
	desc = "A deployable, fully automatic turret with AI targeting capabilities. Armed with a heavy caliber SM-10 shotgun and a 100-round drum magazine."
	icon_state = "shotgun_sentry"
	icon = 'icons/obj/machines/deployable/sentry/shotgun.dmi'
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/shotgun_empty.ogg'

	turret_range = 8
	deploy_time = 5 SECONDS
	max_shells = 75
	fire_delay = 1 SECONDS
	burst_amount = 1

	scatter = 5

	ammo_datum_type = /datum/ammo/bullet/turret/buckshot
	default_ammo_type = /obj/item/ammo_magazine/sentry/shotgun
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/shotgun)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/hsg_102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/hsg_102,
	)

/obj/item/storage/box/crate/sentry_shotgun
	name = "\improper SHT-573 sentry crate"
	desc = "A large case containing all you need to set up an automated sentry."
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/storage/box/crate/sentry_shotgun/Initialize(mapload)
	. = ..()
	storage_datum.max_w_class = WEIGHT_CLASS_HUGE
	storage_datum.storage_slots = 6
	storage_datum.max_storage_space = 16
	storage_datum.set_holdable(
		can_hold_list = list(
			/obj/item/weapon/gun/sentry/shotgun_sentry,
			/obj/item/ammo_magazine/sentry/shotgun,
		),
		storage_type_limits_list = list(
			/obj/item/weapon/gun/sentry/shotgun_sentry,
			/obj/item/ammo_magazine/sentry/shotgun,
		)
	)

/obj/item/storage/box/crate/sentry_shotgun/PopulateContents()
	new /obj/item/weapon/gun/sentry/shotgun_sentry(src)
	new /obj/item/ammo_magazine/sentry/shotgun(src)

// Flamethrower Sentry

/obj/item/weapon/gun/sentry/flamer_sentry
	name = "\improper SFT-575 sentry gun"
	desc = "A deployable, fully automatic turret with AI targeting capabilities. Armed with a heavy flamethrower and a 200-round drum magazine."
	icon_state = "flamer_sentry"
	icon = 'icons/obj/machines/deployable/sentry/flamer.dmi'
	fire_sound = "gun_flamethrower"

	turret_range = 8
	deploy_time = 5 SECONDS
	max_shells = 500
	fire_delay = 0.1 SECONDS
	burst_amount = 1

	scatter = 5

	ammo_datum_type = /datum/ammo/flamethrower/sentry
	default_ammo_type = /obj/item/ammo_magazine/sentry/flamer
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/flamer)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/hsg_102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/hsg_102,
	)

/obj/item/storage/box/crate/sentry_flamer
	name = "\improper SHT-575 sentry crate"
	desc = "A large case containing all you need to set up an automated sentry."
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/storage/box/crate/sentry_flamer/Initialize(mapload)
	. = ..()
	storage_datum.max_w_class = WEIGHT_CLASS_HUGE
	storage_datum.storage_slots = 6
	storage_datum.max_storage_space = 16
	storage_datum.set_holdable(
		can_hold_list = list(
			/obj/item/weapon/gun/sentry/flamer_sentry,
			/obj/item/ammo_magazine/sentry/flamer,
		),
		storage_type_limits_list = list(
			/obj/item/weapon/gun/sentry/flamer_sentry,
			/obj/item/ammo_magazine/sentry/flamer,
		)
	)

/obj/item/storage/box/crate/sentry_flamer/PopulateContents()
	new /obj/item/weapon/gun/sentry/flamer_sentry(src)
	new /obj/item/ammo_magazine/sentry/flamer(src)

/obj/item/weapon/gun/sentry/laser_sentry // yes this isnt a subtype of lasers, because we use normal ammo instead of batteries
	name = "\improper SLT-576 sentry gun"
	desc = "A deployable, fully automatic turret with AI targeting capabilities. Armed with a high-energy laser and a 500-shot magazine."
	icon_state = "laser_sentry"
	icon = 'icons/obj/machines/deployable/sentry/laser.dmi'
	fire_sound = 'sound/weapons/guns/fire/laser.ogg'

	turret_range = 7
	deploy_time = 5 SECONDS
	max_shells = 500
	fire_delay = 0.2 SECONDS
	burst_amount = 1

	scatter = 0

	ammo_datum_type = /datum/ammo/energy/lasersentry
	default_ammo_type = /obj/item/ammo_magazine/sentry/laser
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/laser)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_ENERGY

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/hsg_102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/hsg_102,
	)

/obj/item/storage/box/crate/sentry_laser
	name = "\improper SLT-576 sentry crate"
	desc = "A large case containing all you need to set up an automated laser sentry."
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/storage/box/crate/sentry_laser/Initialize(mapload)
	. = ..()
	storage_datum.max_w_class = WEIGHT_CLASS_HUGE
	storage_datum.storage_slots = 6
	storage_datum.max_storage_space = 16
	storage_datum.set_holdable(
		can_hold_list = list(
			/obj/item/weapon/gun/sentry/laser_sentry,
			/obj/item/ammo_magazine/sentry/laser,
		),
		storage_type_limits_list = list(
			/obj/item/weapon/gun/sentry/laser_sentry,
			/obj/item/ammo_magazine/sentry/laser,
		)
	)

/obj/item/storage/box/crate/sentry_laser/PopulateContents()
	new /obj/item/weapon/gun/sentry/laser_sentry(src)
	new /obj/item/ammo_magazine/sentry/laser(src)
