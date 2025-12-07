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
	max_integrity = 60
	deploy_time = 1 SECONDS
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL|TURRET_INACCURATE
	deployable_item = /obj/machinery/deployable/mounted/sentry/nut
	starting_attachment_types = list()
	attachable_allowed = list()
	turret_range = 11 //shit accuracy anyway
	w_class = WEIGHT_CLASS_NORMAL //same as copes
	faction = FACTION_TERRAGOV

	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 100, FIRE = 100, ACID = 30)

	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_IFF|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	item_flags = TWOHANDED

	max_shots = 300
	rounds_per_shot = 2
	scatter = 10
	throw_range = 4
	fire_delay = 0.1 SECONDS
	accuracy_mult = 0.8
	ammo_datum_type = /datum/ammo/bullet/rifle/nut
	default_ammo_type = /obj/item/ammo_magazine/rifle/nut_ammo
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/nut_ammo)

/obj/item/weapon/gun/rifle/drone/nut/unload(mob/living/user, drop, after_fire)
	to_chat(user, span_warning("You can't remove the disposable drone's fixed ammo canisters!"))
	return FALSE

/obj/item/ammo_magazine/rifle/nut_ammo
	name = "\improper NUT Dual Ammo Canisters (10x24mm)"
	max_rounds = 300
	item_flags = DELONDROP

/datum/ammo/bullet/rifle/nut
	damage = 10
	penetration = 5

/obj/item/weapon/gun/rifle/drone/attack_self(mob/user)
	if(active)
		return

	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	if(ishuman(user) && faction)
		var/mob/living/carbon/human/human_user = user
		if(!human_user.faction || human_user.faction != faction)
			balloon_alert_to_viewers("Unauthorized user, self destruct engaged!", vision_distance = 4)
			playsound(loc, arm_sound, 25, 1, 6)
			sleep(4 SECONDS)
			explosion(loc, light_impact_range = 3, explosion_cause=human_user)
			qdel(src)
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
	faction = user?.faction || faction
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
	knockdown_threshold = 25
	allow_pass_flags = PASSABLE|HOVERING
	/* add this if those shit are too hard to fight.
	obj_flags = CAN_BE_HIT|PROJ_IGNORE_DENSITY
	*/
	density = FALSE //so it wont block people.
	atom_flags = BUMP_ATTACKABLE
	var/movement_delay = 0.7 SECONDS

/obj/machinery/deployable/mounted/sentry/nut/lava_act()
	return

/obj/machinery/deployable/mounted/sentry/nut/Initialize(mapload, obj/item/_internal_item, mob/deployer)
	. = ..()
	//it has limited lifespan
	addtimer(CALLBACK(src, PROC_REF(self_destruct_warning)), 4 MINUTES, TIMER_STOPPABLE)
	addtimer(CALLBACK(src, PROC_REF(self_destruct)), 5 MINUTES, TIMER_STOPPABLE)
	/*
	if(!HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
		playsound(loc, 'sound/effects/pred_cloakon.ogg', 15, TRUE)
		become_warped_invisible(100) //100 is most visible.
	*/

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
			walk_towards(src, get_adjacent_open_turfs(mob), movement_delay, 1)
			/*
			if(HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
				playsound(loc, 'sound/effects/pred_cloakoff.ogg', 25, TRUE)
				stop_warped_invisible()
			*/
		if(SENTRY_ALERT_AMMO)
			if(world.time < (last_damage_alert + SENTRY_ALERT_DELAY))
				return
			var/atom/target = get_target()
			if(target)
				notice = "<b>ALERT! [src] at [AREACOORD_NO_Z(src)] attempting to kamikaze [target.name] due running out of ammo.</b>"
				walk_towards(src, target, movement_delay, 1) //suicide bomb les go
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
	walk(src,0) //stop walking
	var/atom/target = get_target()
	if(target)
	/*
		if(HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
			playsound(loc, 'sound/effects/pred_cloakoff.ogg', 25, TRUE)
			stop_warped_invisible()
	*/
		switch(rand(1,2))
			if(1)
				walk_rand(src, movement_delay) //start walking randomly
			if(2)
				walk_towards(src, pick(get_adjacent_open_turfs(target)),  movement_delay)
	else
		walk_rand(src,  movement_delay*1.334)
		/*
		if(!HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
			playsound(loc, 'sound/effects/pred_cloakon.ogg', 25, TRUE)
			become_warped_invisible(100) //100 is most visible.
		*/

/obj/machinery/deployable/mounted/sentry/nut/disassemble(mob/user)
	balloon_alert(user, "Not reusable.")
	return

GLOBAL_VAR_INIT(ads_intercept_range, 9)

//Air defense system
/obj/machinery/deployable/mounted/sentry/ads_system
	name = "Archercorp 'ACADS01' Air Defense Sentry"
	desc = "An air defense sentry developed to protect bases and shuttles against air strikes and alike. Even when manually controlled this only shoots into the air and cannot hit ground targets. Uses about 10 rounds per shell shot down. Alt + RClick to briefly display it's range. "
	use_power = TRUE
	range = 0
	var/intercept_cooldown = 0
	var/preview_cooldown = 0

/obj/effect/overlay/blinking_laser/marine/lines/nowarning

/obj/machinery/deployable/mounted/sentry/ads_system/AltRightClick(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, preview_cooldown))
		balloon_alert_to_viewers("on cooldown.")
		return
	COOLDOWN_START(src, preview_cooldown, 4 SECONDS)
	balloon_alert_to_viewers("showing range now.")
	for(var/turf/aroundplace in orange(GLOB.ads_intercept_range, loc))
		QDEL_IN(new /obj/effect/overlay/blinking_laser/marine/pod_warning(aroundplace), 3 SECONDS)

//this will make it not shoot people etc, this is barely a sentry but we want ammo things so
/obj/machinery/deployable/mounted/sentry/ads_system/process()
	update_icon()
	if((machine_stat & EMPED))
		return
	playsound(loc, 'sound/items/detector.ogg', 25, FALSE)

/obj/machinery/deployable/mounted/sentry/ads_system/proc/try_intercept(turf/target_turf, atom/proj)
	if((machine_stat & EMPED) || !COOLDOWN_FINISHED(src, intercept_cooldown))
		return
	COOLDOWN_START(src, intercept_cooldown, rand(0.5 SECONDS, 1.5 SECONDS))
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(gun.rounds <= 0)
		playsound(loc, 'sound/vox/ammunition.ogg', 30, FALSE)
		radio.talk_into(src, "<b>ALERT! [src] failed to shoot down a [proj.name]! due depleted ammo at: [AREACOORD_NO_Z(src)].</b>")
		return FALSE
	face_atom(target_turf)
	gun.set_target(target_turf)
	playsound(loc, pick('sound/vox/alert.ogg','sound/vox/warning.ogg','sound/vox/incoming.ogg'), 30, FALSE)
	addtimer(CALLBACK(src, PROC_REF(firing_loop), target_turf), 1) //so it works detached from the proc and doesnt delay.
	radio.talk_into(src, "<b>ALERT! [src] has shot down a [proj.name] at: [AREACOORD_NO_Z(src)].</b>")
	playsound(loc, SFX_EXPLOSION_SMALL_DISTANT, 50, 1, falloff = 5)
	return TRUE

/obj/machinery/deployable/mounted/sentry/ads_system/proc/firing_loop(turf/target_turf)
	var/obj/item/weapon/gun/gun = get_internal_item()
	for(var/times in 1 to 10)
		if(gun.rounds <= 0)
			radio.talk_into(src, "<b>ALERT! [src] ran out of ammo at: [AREACOORD_NO_Z(src)].</b>")
			break
		gun.set_target(target_turf)
		gun.Fire()
		sleep(0.1 SECONDS)

/obj/item/weapon/gun/sentry/ads_system
	name = "\improper Archercorp ACADS01 Air Defense Sentry"
	desc = "A deployable air defense sentry requiring 100 rounds drum of special flak ammunition."
	icon = 'ntf_modular/icons/obj/machines/deployable/point-defense/point_defense.dmi'
	icon_state = "pointdef"
	burst_amount = 10
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS
	max_integrity = 300 //hopefully will withstand a strafe or so cause its stupidly easy to cheese
	integrity_failure = 50
	fire_delay = 0.1 SECONDS
	burst_delay = 0.1 SECONDS
	max_shells = 100

	fire_sound = SFX_AC_FIRE
	ammo_datum_type = /datum/ammo/bullet/turret/air_defense
	default_ammo_type = /obj/item/ammo_magazine/sentry/ads_system
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/ads_system)
	deployable_item = /obj/machinery/deployable/mounted/sentry/ads_system

	gun_firemode_list = list(GUN_FIREMODE_BURSTFIRE)

/obj/item/weapon/gun/sentry/ads_system/premade
	faction = FACTION_TERRAGOV
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/storage/box/crate/sentry/ads
	name = "\improper ACADS01 air defense sentry crate"
	desc = "A large case containing all you need to set up an automated air defense sentry."
	icon_state = "sentry_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_type = /datum/storage/box/crate/sentry

/obj/item/storage/box/crate/sentry/ads/PopulateContents()
	new /obj/item/weapon/gun/sentry/ads_system(src)
	new /obj/item/ammo_magazine/sentry/ads_system(src)
	new /obj/item/ammo_magazine/sentry/ads_system(src)

/datum/ammo/bullet/turret/air_defense
	name = "flak autocannon bullet"
	hud_state = "sniper_flak"
	max_range = 11
	damage = 0
	damage_falloff = 0
	accuracy = -100 //we dont want it to hit anything actually
	scatter = 1
	ammo_behavior_flags = AMMO_IFF|AMMO_PASS_THROUGH_MOB|AMMO_PASS_THROUGH_MOVABLE|AMMO_PASS_THROUGH_TURF|AMMO_BETTER_COVER_RNG

/obj/item/ammo_magazine/sentry/ads_system
	name = "\improper ACADS01 box magazine (10x28mm Flak)"
	desc = "A drum of 100 10x28mm flak rounds for the ACADS01. Just feed it into the sentry gun's ammo port."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "sentry"
	icon = 'icons/obj/items/ammo/sentry.dmi'
	magazine_flags = NONE //can't be refilled or emptied by hand
	caliber = CALIBER_10X28
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/turret/air_defense

