/obj/machinery/deployable/mounted/sentry

	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	layer = ABOVE_MOB_LAYER
	use_power = 0
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_LEADER)
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)

	///Spark system for making sparks
	var/datum/effect_system/spark_spread/spark_system
	///Camera for viewing with cam consoles
	var/obj/machinery/camera/camera
	///View and fire range of the sentry
	var/range = 7
	///Damage required to knock the sentry over and disable it
	var/knockdown_threshold = 150

	///List of targets that can be shot at
	var/list/mob/living/potential_targets = list()

	///Time of last alert
	var/last_alert = 0
	///Time of last damage alert
	var/last_damage_alert = 0

	///Radio so that the sentry can scream for help
	var/obj/item/radio/radio

	///Iff signal of the sentry. If the /gun has a set IFF then this will be the same as that. If not the sentry will get its IFF signal from the deployer
	var/iff_signal = NONE
	///List of terrains/structures/machines that the sentry ignores for targetting. (If a window is inside the list, the sentry will shot at targets even if the window breaks los) For accuracy, this is on a specific typepath base and not istype().
	var/list/ignored_terrains

//------------------------------------------------------------------
//Setup and Deletion

/obj/machinery/deployable/mounted/sentry/Initialize(mapload, _internal_item, deployer)
	. = ..()
	var/obj/item/weapon/gun/gun = internal_item

	iff_signal = gun.sentry_iff_signal
	if(deployer)
		var/mob/living/carbon/human/_deployer = deployer
		var/obj/item/card/id/id = _deployer.get_idcard(TRUE)
		iff_signal = id?.iff_signal

	knockdown_threshold = gun.knockdown_threshold
	range = CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL) ?  gun.turret_range - 2 : gun.turret_range
	ignored_terrains = gun.ignored_terrains

	radio = new(src)

	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	if(CHECK_BITFIELD(gun.turret_flags, TURRET_INACCURATE))
		gun.accuracy_mult -= 0.15
		gun.scatter += 10

	if(CHECK_BITFIELD(gun.turret_flags, TURRET_HAS_CAMERA))
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[name] ([rand(0, 1000)])"

	GLOB.marine_turrets += src
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/update_icon_state()
	. = ..()
	if(!CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return
	icon_state += "_f"

/obj/machinery/deployable/mounted/sentry/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(camera)
	QDEL_NULL(spark_system)
	STOP_PROCESSING(SSobj, src)
	if(internal_item)
		UnregisterSignal(internal_item, COMSIG_MOB_GUN_FIRED)
	GLOB.marine_turrets -= src
	return ..()

/obj/machinery/deployable/mounted/sentry/deconstruct(disassembled = TRUE)
	if(!disassembled)
		explosion(loc, light_impact_range = 3)
	return ..()

/obj/machinery/deployable/mounted/sentry/on_deconstruction()
	sentry_alert(SENTRY_ALERT_DESTROYED)
	return ..()

//-----------------------------------------------------------------
// Interaction

/obj/machinery/deployable/mounted/sentry/on_set_interaction(mob/user)
	. = ..()
	to_chat(user, span_notice("You disable the [src]'s automatic to operate it manually."))
	set_on(FALSE)

/obj/machinery/deployable/mounted/sentry/on_unset_interaction(mob/user)
	. = ..()
	to_chat(user, span_notice("You stop using the [src] and its automatic functions re-activate"))
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/attack_hand(mob/living/user)
	. = ..()
	if(!. || !CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return
	user.visible_message(span_notice("[user] begins to set [src] upright."),
		span_notice("You begin to set [src] upright.</span>"))

	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_BUILD))
		return

	user.visible_message(span_notice("[user] sets [src] upright."),
		span_notice("You set [src] upright."))

	DISABLE_BITFIELD(machine_stat, KNOCKED_DOWN)
	density = TRUE
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/reload(mob/user, ammo_magazine)
	. = ..()
	update_static_data(user)

/obj/machinery/deployable/mounted/sentry/interact(mob/user, manual_mode = FALSE)
	var/obj/item/weapon/gun/gun = internal_item
	if(manual_mode)
		return ..()

	if(CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return TRUE

	if(CHECK_BITFIELD(gun.turret_flags, TURRET_IMMOBILE))
		to_chat(user, span_warning("[src]'s panel is completely locked, you can't do anything."))
		return TRUE

	ui_interact(user)
	update_static_data(user)

/obj/machinery/deployable/mounted/sentry/ui_interact(mob/user, datum/tgui/ui)

	if(CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sentry", "Sentry Gun")
		ui.open()

/obj/machinery/deployable/mounted/sentry/ui_data(mob/user)
	var/obj/item/weapon/gun/gun = internal_item
	var/current_rounds
	current_rounds = gun.rounds
	. = list(
		"rounds" =  current_rounds,
		"health" = obj_integrity
	)

/obj/machinery/deployable/mounted/sentry/ui_static_data(mob/user)
	var/obj/item/weapon/gun/gun = internal_item
	var/rounds_max
	rounds_max = gun.max_rounds
	. = list(
		"name" = copytext(name, 2),
		"rounds_max" = rounds_max,
		"fire_mode" = gun.gun_firemode,
		"health_max" = max_integrity,
		"safety_toggle" = CHECK_BITFIELD(gun.turret_flags, TURRET_SAFETY),
		"manual_override" = operator,
		"alerts_on" = CHECK_BITFIELD(gun.turret_flags, TURRET_ALERTS),
		"radial_mode" = CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL)
	)

/obj/machinery/deployable/mounted/sentry/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/obj/item/weapon/gun/gun = internal_item
	if(isxeno(usr))
		return
	var/mob/living/user = usr
	if(!istype(user) || CHECK_BITFIELD(gun.turret_flags, TURRET_IMMOBILE) || CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return
	switch(action)
		if("safety")
			TOGGLE_BITFIELD(gun.turret_flags, TURRET_SAFETY)
			var/safe = CHECK_BITFIELD(gun.turret_flags, TURRET_SAFETY)
			user.visible_message(span_warning("[user] [safe ? "" : "de"]activates [src]'s safety lock."),
				span_warning("You [safe ? "" : "de"]activate [src]'s safety lock.</span>"))
			visible_message(span_warning("A red light on [src] blinks brightly!"))
			update_static_data(user)
			. = TRUE

		if("firemode")
			gun.do_toggle_firemode(user)
			update_static_data(user)
			. = TRUE

		if("manual")
			if(isAI(user))
				return
			if(operator)
				user.unset_interaction()
			else
				interact(user, TRUE)
			update_static_data(user)
			. = TRUE

		if("toggle_alert")
			TOGGLE_BITFIELD(gun.turret_flags, TURRET_ALERTS)
			var/alert = CHECK_BITFIELD(gun.turret_flags, TURRET_ALERTS)
			user.visible_message(span_notice("[user] [alert ? "" : "de"]activates [src]'s alert notifications."),
				span_notice("You [alert ? "" : "de"]activate [src]'s alert notifications."))
			say("Alert notification system [alert ? "initiated" : "deactivated"]")
			update_static_data(user)
			. = TRUE

		if("toggle_radial")
			TOGGLE_BITFIELD(gun.turret_flags, TURRET_RADIAL)
			if(!CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL))
				range = gun.turret_range
			else
				range = gun.turret_range - 2
			var/rad_msg = CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL) ? "activate" : "deactivate"
			user.visible_message(span_notice("[user] [rad_msg]s [src]'s radial mode."), span_notice("You [rad_msg] [src]'s radial mode."))
			say("Radial mode [rad_msg]d.")
			update_static_data(user)
			. = TRUE

	attack_hand(user)

///Handles turning the sentry ON and OFF. new_state is a bool
/obj/machinery/deployable/mounted/sentry/proc/set_on(new_state)
	var/obj/item/weapon/gun/gun = internal_item
	if(!new_state)
		visible_message(span_notice("The [name] powers down and goes silent."))
		DISABLE_BITFIELD(gun.turret_flags, TURRET_ON)
		gun.set_target(null)
		set_light(0)
		update_icon()
		STOP_PROCESSING(SSobj, src)
		UnregisterSignal(gun, COMSIG_MOB_GUN_FIRED)
		return

	ENABLE_BITFIELD(gun.turret_flags, TURRET_ON)
	visible_message(span_notice("The [name] powers up with a warm hum."))
	set_light_range(initial(light_power))
	set_light_color(initial(light_color))
	set_light(SENTRY_LIGHT_POWER,SENTRY_LIGHT_POWER)
	update_icon()
	START_PROCESSING(SSobj, src)
	RegisterSignal(gun, COMSIG_MOB_GUN_FIRED, .proc/check_next_shot)

///Bonks the sentry onto its side. This currently is used here, and in /living/carbon/xeno/warrior/xeno_abilities in punch
/obj/machinery/deployable/mounted/sentry/proc/knock_down()
	if(CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return
	var/obj/item/weapon/gun/internal_gun = internal_item
	internal_gun.stop_fire() //Comrade sentry has been sent to the gulags. He served the revolution well.
	visible_message(span_highdanger("The [name] is knocked over!"))
	sentry_alert(SENTRY_ALERT_FALLEN)
	ENABLE_BITFIELD(machine_stat, KNOCKED_DOWN)
	density = FALSE
	set_on(FALSE)
	update_icon()

/obj/machinery/deployable/mounted/sentry/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_SENTRY)
	return ..()

/obj/machinery/deployable/mounted/sentry/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	if(damage_amount <= 0)
		return
	if(prob(10))
		spark_system.start()
	if(damage_amount >= knockdown_threshold) //Knockdown is certain if we deal this much in one hit; no more RNG nonsense, the fucking thing is bolted.
		knock_down()

	. = ..()
	if(!internal_item)
		return
	sentry_alert(SENTRY_ALERT_DAMAGE)
	update_icon()

/obj/machinery/deployable/mounted/sentry/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(90, 150))
		if(EXPLODE_HEAVY)
			take_damage(rand(50, 150))
		if(EXPLODE_LIGHT)
			take_damage(rand(30, 100))

//----------------------------------------------------------------------------
// Sentry Functions

///Sentry wants to scream for help.
/obj/machinery/deployable/mounted/sentry/proc/sentry_alert(alert_code, mob/mob)
	if(!internal_item)
		return
	var/obj/item/weapon/gun/gun = internal_item
	if(!alert_code || !CHECK_BITFIELD(gun.turret_flags, TURRET_ALERTS) || !CHECK_BITFIELD(gun.turret_flags, TURRET_ON))
		return

	var/notice
	switch(alert_code)
		if(SENTRY_ALERT_HOSTILE)
			if(world.time < (last_alert + SENTRY_ALERT_DELAY))
				return
			notice = "<b>ALERT! [src] detected Hostile/Unknown: [mob.name] at: [AREACOORD_NO_Z(src)].</b>"
			last_alert = world.time
		if(SENTRY_ALERT_AMMO)
			if(world.time < (last_damage_alert + SENTRY_ALERT_DELAY))
				return
			notice = "<b>ALERT! [src]'s ammo depleted at: [AREACOORD_NO_Z(src)].</b>"
			last_damage_alert = world.time
		if(SENTRY_ALERT_FALLEN)
			notice = "<b>ALERT! [src] has been knocked over at: [AREACOORD_NO_Z(src)].</b>"
		if(SENTRY_ALERT_DAMAGE)
			if(world.time < (last_damage_alert + SENTRY_DAMAGE_ALERT_DELAY))
				return
			notice = "<b>ALERT! [src] has taken damage at: [AREACOORD_NO_Z(src)]. Remaining Structural Integrity: ([obj_integrity]/[max_integrity])[obj_integrity < 50 ? " CONDITION CRITICAL!!" : ""]</b>"
			last_damage_alert = world.time
		if(SENTRY_ALERT_DESTROYED)
			notice = "<b>ALERT! [src] at: [AREACOORD_NO_Z(src)] has been destroyed!</b>"

	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
	radio.talk_into(src, "[notice]", FREQ_COMMON)


/obj/machinery/deployable/mounted/sentry/process()
	update_icon()
	if(!scan())
		var/obj/item/weapon/gun/gun = internal_item
		gun.stop_fire()
		return
	playsound(loc, 'sound/items/detector.ogg', 25, FALSE)

	sentry_start_fire()

///Checks the nearby mobs for eligability. If they can be targets it stores them in potential_targets. Returns TRUE if there are targets, FALSE if not.
/obj/machinery/deployable/mounted/sentry/proc/scan()
	var/obj/item/weapon/gun/gun = internal_item
	potential_targets.Cut()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, range))
		if(nearby_human.stat == DEAD || CHECK_BITFIELD(nearby_human.status_flags, INCORPOREAL)  || (CHECK_BITFIELD(gun.turret_flags, TURRET_SAFETY) || nearby_human.wear_id?.iff_signal & iff_signal))
			continue
		potential_targets += nearby_human
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(nearby_xeno.stat == DEAD || HAS_TRAIT(nearby_xeno, TRAIT_TURRET_HIDDEN) || CHECK_BITFIELD(nearby_xeno.status_flags, INCORPOREAL)) //So wraiths wont be shot at when in phase shift
			continue
		potential_targets += nearby_xeno
	return potential_targets.len

///Checks the range and the path of the target currently being shot at to see if it is eligable for being shot at again. If not it will stop the firing.
/obj/machinery/deployable/mounted/sentry/proc/check_next_shot(datum/source, atom/gun_target, obj/item/weapon/gun/gun)
	SIGNAL_HANDLER
	var/obj/item/weapon/gun/internal_gun = internal_item
	if(CHECK_BITFIELD(internal_gun.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && length(internal_gun.chamber_items))
		INVOKE_ASYNC(internal_gun, /obj/item/weapon/gun.proc/do_unique_action)
	if(get_dist(src, gun_target) > range || (!CHECK_BITFIELD(get_dir(src, gun_target), dir) && !CHECK_BITFIELD(internal_gun.turret_flags, TURRET_RADIAL)) || !check_target_path(gun_target))
		internal_gun.stop_fire()
		return
	if(internal_gun.gun_firemode != GUN_FIREMODE_SEMIAUTO)
		return
	addtimer(CALLBACK(src, .proc/sentry_start_fire), internal_gun.fire_delay) //This schedules the next shot if the gun is on semi-automatic. This is so that semi-automatic guns don't fire once every two seconds.

///Sees if theres a target to shoot, then handles firing.
/obj/machinery/deployable/mounted/sentry/proc/sentry_start_fire()
	var/obj/item/weapon/gun/gun = internal_item
	var/mob/living/target = get_target()
	update_icon()
	if(!target || get_dist(src, target) > range)
		gun.stop_fire()
		return
	if(target != gun.target)
		gun.stop_fire()
	if(!gun.rounds)
		sentry_alert(SENTRY_ALERT_AMMO)
		return
	if(CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL))
		setDir(get_cardinal_dir(src, target))
	if(HAS_TRAIT(gun, TRAIT_GUN_BURST_FIRING))
		gun.set_target(target)
		return
	gun.start_fire(src, target, bypass_checks = TRUE)

///Checks the path to the target for obstructions. Returns TRUE if the path is clear, FALSE if not.
/obj/machinery/deployable/mounted/sentry/proc/check_target_path(mob/living/target)
	var/list/turf/path = getline(src, target)
	path -= get_turf(src)
	if(!path.len)
		return FALSE
	for(var/turf/T AS in path)
		var/obj/effect/particle_effect/smoke/smoke = locate() in T
		if(smoke && smoke.opacity)
			return FALSE

		if(IS_OPAQUE_TURF(T) || T.density && T.throwpass == FALSE && !(T.type in ignored_terrains))
			return FALSE

		for(var/obj/machinery/MA in T)
			if(MA.density && MA.throwpass == FALSE && !(MA.type in ignored_terrains))
				return FALSE

		for(var/obj/structure/S in T)
			if(S.density && S.throwpass == FALSE && !(S.type in ignored_terrains))
				return FALSE

	return TRUE

///Works through potential targets. First checks if they are in range, and if they are friend/foe. Then checks the path to them. Returns the first eligable target.
/obj/machinery/deployable/mounted/sentry/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	var/obj/item/weapon/gun/gun = internal_item
	for (var/mob/living/nearby_target AS in potential_targets)
		if(!(get_dir(src, nearby_target) & dir) && !CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL))
			continue

		buffer_distance = get_dist(nearby_target, src)

		if (distance <= buffer_distance)
			continue

		if(!check_target_path(nearby_target))
			continue

		sentry_alert(SENTRY_ALERT_HOSTILE, nearby_target)

		distance = buffer_distance
		return nearby_target


/obj/machinery/deployable/mounted/sentry/disassemble(mob/user)
	. = ..()
	var/obj/item/weapon/gun/gun = internal_item
	if(CHECK_BITFIELD(gun.turret_flags, TURRET_INACCURATE))
		gun.accuracy_mult += 0.15
		gun.scatter -= 10


/obj/machinery/deployable/mounted/sentry/buildasentry
	name = "broken build-a-sentry"
	desc = "You should not be seeing this unless a mapper, coder or admin screwed up."

/obj/machinery/deployable/mounted/sentry/buildasentry/Initialize(mapload, _internal_item, deployer) //I know the istype spam is a bit much, but I don't think there is a better way.
	. = ..()
	name = "Deployed " + internal_item.name
	icon = 'icons/Marine/sentry.dmi'
	default_icon_state = "build_a_sentry"
	update_icon()

/obj/machinery/deployable/mounted/sentry/buildasentry/update_overlays()
	. = ..()
	var/obj/item/weapon/gun/internal_gun = internal_item
	. += image('icons/Marine/sentry.dmi', src, internal_gun.placed_overlay_iconstate, dir = dir)
