//thrown NTC assist drone
/obj/item/weapon/gun/rifle/drone
	name = "theoritical drone"
	desc = "what da heeell"
	var/det_time = 1 SECONDS
	///The sound made when activated
	var/arm_sound = 'sound/weapons/armbomb.ogg'

/obj/item/weapon/gun/rifle/drone/nut
	name = "\improper NUT drone"
	desc = "The Ninetails Unmanned Turret drone is a portable, automated drone attack system utilised by the NTC. It is activated in hand then thrown into place before it deploys, where it begins to hover, making it a difficult target to accurately hit. Equipped with a compact rotating small caliber weapon system with limited ammo and basic AI, It can work up to 5 minutes on it's battery and self destructs if it's out of ammo or it's battery lifetime is up... Those are fabricated in a factorio."
	icon_state = "nut"
	icon = 'ntf_modular/icons/obj/machines/deployable/sentry/nut.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/grenades_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/grenades_right.dmi',
	)
	worn_icon_state = "grenade"
	max_integrity = 100
	deploy_time = 1 SECONDS
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL|TURRET_INACCURATE
	deployable_item = /obj/machinery/deployable/mounted/sentry/nut
	starting_attachment_types = list()
	attachable_allowed = list()
	turret_range = 11
	w_class = WEIGHT_CLASS_SMALL //disposable drones take little space too.
	sentry_iff_signal = TGMC_LOYALIST_IFF

	soft_armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 100, ACID = 50)

	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_IFF|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	item_flags = TWOHANDED

	max_shots = 300
	rounds_per_shot = 2
	scatter = 2
	fire_delay = 0.1 SECONDS
	accuracy_mult = 0.8
	ammo_datum_type = /datum/ammo/bullet/rifle/nut
	default_ammo_type = /obj/item/ammo_magazine/rifle/nut_ammo
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/nut_ammo)

/obj/item/ammo_magazine/rifle/nut_ammo
	name = "\improper NUT Dual Ammo Canisters (10x24mm)"
	max_rounds = 300
	item_flags = DELONDROP

/datum/ammo/bullet/rifle/nut
	//lil peashooter
	damage = 15
	penetration = 5
	bonus_projectiles_amount = 1 //dual guns
	bonus_projectiles_scatter = 1
	bonus_projectiles_type = /datum/ammo/bullet/rifle/nut/second

/datum/ammo/bullet/rifle/nut/second
	bonus_projectiles_amount = 0

/obj/item/weapon/gun/rifle/drone/attack_self(mob/user)
	if(active)
		return

	if(ishuman(user) && sentry_iff_signal)
		var/mob/living/carbon/human/human_user = user
		if(!human_user.wear_id?.iff_signal || human_user.wear_id?.iff_signal != sentry_iff_signal)
			balloon_alert_to_viewers("Unauthorized user, self destruct engaged!")
			explosion(loc, light_impact_range = 3, explosion_cause=human_user)
			Destroy()
			return

	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	activate(user)

	user.visible_message(span_warning("[user] activate \a [name]!"), \
	span_warning("You activate \a [name]!"))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

/obj/item/weapon/gun/rifle/drone/activate(mob/user)
	if(active)
		return

	icon_state = initial(icon_state) + "_active"
	active = TRUE
	playsound(loc, arm_sound, 25, 1, 6)
	var/obj/item/card/id/user_id = user?.get_idcard(TRUE)
	if(user_id)
		sentry_iff_signal = user_id?.iff_signal
	addtimer(CALLBACK(src, PROC_REF(prime), user), det_time)

///Deploys the weapon into a sentry after activation
/obj/item/weapon/gun/rifle/drone/proc/prime(mob/user)
	if(!isturf(loc)) //no deploying out of bags or in hand
		reset()
		return
	do_deploy(user)

/obj/item/weapon/gun/rifle/drone/do_deploy(mob/user, turf/location)
	. = ..()
	spawn(1)
		if(!(CHECK_BITFIELD(item_flags, IS_DEPLOYED)))
			reset()

///Reverts the gun back to it's unarmed state, allowing it to be activated again
/obj/item/weapon/gun/rifle/drone/proc/reset()
	active = FALSE
	icon_state = initial(icon_state)

/obj/item/storage/box/crate/drone/nut
	name = "\improper NUT disposable drone crate (x2)"
	desc = "A large case containing two NUT drones, each last 5 minutes after deployment and then run out of power."
	icon_state = "sentry_mini_case"
	w_class = WEIGHT_CLASS_HUGE

/obj/item/storage/box/crate/drone/nut/Initialize(mapload, ...)
	. = ..()
	storage_datum.storage_slots = 6
	storage_datum.set_holdable(can_hold_list = list(
		/obj/item/weapon/gun/rifle/drone/nut,
		/obj/item/weapon/gun/rifle/drone/nut,
	))

/obj/item/storage/box/crate/drone/nut/PopulateContents()
	new /obj/item/weapon/gun/rifle/drone/nut(src)
	new /obj/item/weapon/gun/rifle/drone/nut(src)

//Throwable drone
/obj/machinery/deployable/mounted/sentry/nut
	light_range = 3
	anchored = FALSE
	drag_delay = 0.5
	knockdown_threshold = 75
	allow_pass_flags = PASSABLE|HOVERING
	/* add this if those shit are too hard to fight.
	obj_flags = CAN_BE_HIT|PROJ_IGNORE_DENSITY
	*/
	density = FALSE //so it wont block people.
	atom_flags = BUMP_ATTACKABLE
	var/next_movement = 0
	var/movement_delay = 3 SECONDS

/obj/machinery/deployable/mounted/sentry/nut/Initialize(mapload, obj/item/_internal_item, mob/deployer)
	. = ..()
	//it has limited lifespan
	addtimer(CALLBACK(src, PROC_REF(self_destruct_warning)), 4 MINUTES, TIMER_STOPPABLE)
	addtimer(CALLBACK(src, PROC_REF(self_destruct)), 5 MINUTES, TIMER_STOPPABLE)
	if(!HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
		playsound(loc, 'sound/effects/pred_cloakon.ogg', 15, TRUE)
		become_warped_invisible(100) //100 is most visible.

/obj/machinery/deployable/mounted/sentry/nut/proc/self_destruct_warning()
	radio.talk_into(src, "NUT at [AREACOORD_NO_Z(src)] will be self destructing in 1 minute due low power.")

/obj/machinery/deployable/mounted/sentry/nut/proc/self_destruct()
	radio.talk_into(src, "NUT at [AREACOORD_NO_Z(src)] self destructing.")
	deconstruct(FALSE)

/obj/machinery/deployable/mounted/sentry/nut/sentry_alert(alert_code, mob/mob)
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(!gun)
		return
	if(!alert_code || !CHECK_BITFIELD(gun.turret_flags, TURRET_ALERTS) || !CHECK_BITFIELD(gun.turret_flags, TURRET_ON))
		return

	var/notice
	switch(alert_code)
		if(SENTRY_ALERT_HOSTILE)
			if(world.time < (last_alert + SENTRY_ALERT_DELAY))
				return
			notice = "<b>ALERT! [src] detected Hostile/Unknown: [mob.name] at: [AREACOORD_NO_Z(src)].</b>"
			last_alert = world.time
			walk_towards(src, get_adjacent_open_turfs(mob), 3, 1)
			if(HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
				playsound(loc, 'sound/effects/pred_cloakoff.ogg', 25, TRUE)
				stop_warped_invisible()
		if(SENTRY_ALERT_AMMO)
			if(world.time < (last_damage_alert + SENTRY_ALERT_DELAY))
				return
			var/atom/target = get_target()
			if(target)
				notice = "<b>ALERT! [src] at [AREACOORD_NO_Z(src)] attempting to kamikaze [target.name] due running out of ammo.</b>"
				walk_towards(src, target, 3, 1) //suicide bomb les go
				addtimer(CALLBACK(src, PROC_REF(self_destruct)), 3 SECONDS, TIMER_STOPPABLE)
				last_damage_alert = world.time
			else
				addtimer(CALLBACK(src, PROC_REF(self_destruct)), 3 SECONDS, TIMER_STOPPABLE)
		if(SENTRY_ALERT_FALLEN)
			notice = "<b>ALERT! [src] has been knocked over at: [AREACOORD_NO_Z(src)].</b>"
			walk(src,0)
		if(SENTRY_ALERT_DAMAGE)
			if(world.time < (last_damage_alert + SENTRY_DAMAGE_ALERT_DELAY))
				return
			notice = "<b>ALERT! [src] has taken damage at: [AREACOORD_NO_Z(src)]. Remaining Structural Integrity: ([obj_integrity]/[max_integrity])[obj_integrity < 50 ? " CONDITION CRITICAL!!" : ""]</b>"
			last_damage_alert = world.time
		if(SENTRY_ALERT_DESTROYED)
			notice = "<b>ALERT! [src] at: [AREACOORD_NO_Z(src)] has been destroyed!</b>"

	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
	radio.talk_into(src, "[notice]")

/obj/machinery/deployable/mounted/sentry/nut/process()
	. = ..()
	if(CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return
	if(world.time > next_movement)
		walk(src,0)
		next_movement = world.time + movement_delay + movement_delay
		var/atom/target = get_target()
		if(target)
			if(HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
				playsound(loc, 'sound/effects/pred_cloakoff.ogg', 25, TRUE)
				stop_warped_invisible()
			switch(rand(1,2))
				if(1)
					walk_rand(src, 3, 1)
				if(2)
					walk_towards(src, get_adjacent_open_turfs(target), 3, 1)
		else
			walk_rand(src, 4, 0.3)
			if(!HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
				playsound(loc, 'sound/effects/pred_cloakon.ogg', 25, TRUE)
				become_warped_invisible(100) //100 is most visible.

/obj/machinery/deployable/mounted/sentry/nut/disassemble(mob/user)
	balloon_alert(user, "Not reusable.")
	return

/obj/machinery/deployable/mounted/sentry/reload(mob/user, ammo_magazine)
	return
