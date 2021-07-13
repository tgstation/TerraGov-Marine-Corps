/obj/item/weapon/gun/sentry
	name = "sentry"
	desc = "sentry"
	icon = 'icons/Marine/sentry.dmi'

	fire_sound = 'sound/weapons/guns/fire/smg_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/smartgun_unload.ogg'

	max_integrity = 200

	///Flags that the deployed sentry uses upon deployment.
	var/turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	///Damage threshold for whether a turret will be knocked down.
	var/knockdown_threshold = 150
	///Range of deployed turret
	var/range = 7
	///Battery used for radial mode on deployed turrets.
	var/obj/item/cell/lasgun/lasrifle/marine/battery = new()

	fire_delay = 1 SECONDS
	scatter = 0
	scatter_unwielded = 0
	burst_scatter_mult = 0

	gun_iff_signal = list(ACCESS_IFF_MARINE)
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER|GUN_LOAD_INTO_CHAMBER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	flags_item = IS_SENTRY|TWOHANDED
	deploy_time = 5 SECONDS


/obj/item/weapon/gun/sentry/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/sentry/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

/obj/item/weapon/gun/sentry/Destroy()
	. = ..()
	QDEL_NULL(battery)

/obj/item/weapon/gun/sentry/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cell/lasgun/lasrifle/marine))
		var/obj/item/cell/lasgun/lasrifle/marine/new_battery = I
		if(!new_battery.charge)
			to_chat(user, "<span class='warning'>[new_battery] is out of charge!</span>")
			return
		playsound(src, 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg', 20)
		battery = new_battery
		user.temporarilyRemoveItemFromInventory(new_battery)
		new_battery.forceMove(src)
		to_chat(user, "<span class='notice'>You install the [new_battery] into the [src].</span>")
		return
	return ..()

/obj/item/weapon/gun/sentry/AltClick(mob/user)
	. = ..()
	if(!user.Adjacent(src) || !ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(!battery)
		to_chat(human, "<span class='warning'> There is no battery to remove from [src].</span>")
		return
	if(human.get_active_held_item() != src && human.get_inactive_held_item() != src && !CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		to_chat(human, "<span class='notice'>You have to hold [src] to take out its battery.</span>")
		return
	playsound(src, 'sound/weapons/flipblade.ogg', 20)
	human.put_in_hands(battery)
	battery = null

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
	new /obj/item/cell/lasgun/lasrifle/marine(src)
	new /obj/item/cell/lasgun/lasrifle/marine(src)
	new /obj/item/ammo_magazine/sentry(src)
	new /obj/item/ammo_magazine/sentry(src)

/obj/item/weapon/gun/sentry/big_sentry
	name = "\improper UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with a M30 autocannon and a 25-round box magazine."
	icon_state = "sentry"

	range = 9
	deploy_time = 12 SECONDS
	max_shells = 25

	ammo = /datum/ammo/bullet/turret
	current_mag = /obj/item/ammo_magazine/sentry

	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/tl102,
	)

/obj/item/weapon/gun/sentry/big_sentry/premade
	flags_item = IS_SENTRY|TWOHANDED|DEPLOY_ON_INITIALIZE

/obj/item/storage/box/minisentry
	name = "\improper UA-580 point defense sentry crate"
	desc = "A large case containing all you need to set up an UA-580 point defense sentry."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 4
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
	desc = "A deployable, automated turret with AI targeting capabilities. This is a lightweight portable model meant for rapid deployment and point defense. Armed with an light, high velocity machine gun and a 100-round drum magazine."
	icon_state = "minisentry"

	max_shells = 100
	knockdown_threshold = 100

	ammo = /datum/ammo/bullet/turret/mini
	current_mag = /obj/item/ammo_magazine/minisentry

	fire_delay = 3
	scatter = 2

	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)

/obj/item/weapon/gun/sentry/premade
	name = "UA-577 Gauss Turret"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an armor penetrating MIC Gauss Cannon and a high-capacity drum magazine."
	icon_state = "sentry"
	turret_flags = TURRET_HAS_CAMERA|TURRET_ON|TURRET_BURSTFIRE|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL
	max_shells = 50000

	fire_delay = 3
	scatter = 2

	ammo = /datum/ammo/bullet/turret/gauss
	current_mag = /obj/item/ammo_magazine/sentry_premade
	flags_item = IS_SENTRY|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/premade/dumb
	name = "\improper Modified UA 571-C sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	gun_iff_signal = list()
	ammo = /datum/ammo/bullet/turret/dumb
	current_mag = /obj/item/ammo_magazine/sentry_premade/dumb
	max_shells = 500
	turret_flags = TURRET_ON|TURRET_BURSTFIRE|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL

/obj/item/weapon/gun/sentry/premade/dumb/hostile
	name = "malfunctioning UA 571-C sentry gun"
	desc = "Oh god oh fuck."
	turret_flags = TURRET_LOCKED|TURRET_ON|TURRET_BURSTFIRE|TURRET_IMMOBILE|TURRET_RADIAL


/obj/item/weapon/gun/sentry/premade/dropship
	name = "UA-577 Gauss Dropship Turret"
	density = FALSE
	turret_flags = TURRET_HAS_CAMERA|TURRET_BURSTFIRE|TURRET_IMMOBILE
	var/obj/structure/dropship_equipment/sentry_holder/deployment_system
	current_mag = /obj/item/ammo_magazine/sentry_premade/dropship

/obj/item/weapon/gun/sentry/premade/canterbury
	name = "UA-577 Gauss Dropship Turret"
	ammo = /datum/ammo/bullet/turret
