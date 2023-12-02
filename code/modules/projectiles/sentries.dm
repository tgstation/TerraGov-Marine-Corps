/obj/machinery/deployable/mounted/sentry

	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
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
	var/list/atom/potential_targets = list()

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
	///For minimap icon change if sentry is firing
	var/firing

//------------------------------------------------------------------
//Setup and Deletion

/obj/machinery/deployable/mounted/sentry/Initialize(mapload, _internal_item, deployer)
	. = ..()
	var/obj/item/weapon/gun/gun = get_internal_item()

	iff_signal = gun?.sentry_iff_signal ? gun.sentry_iff_signal : initial(iff_signal)
	if(deployer)
		var/mob/living/carbon/human/_deployer = deployer
		var/obj/item/card/id/id = _deployer.get_idcard(TRUE)
		iff_signal = id?.iff_signal

	knockdown_threshold = gun?.knockdown_threshold ? gun.knockdown_threshold : initial(gun.knockdown_threshold)
	range = CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL) ?  gun.turret_range - 2 : gun.turret_range
	ignored_terrains = gun?.ignored_terrains ? gun.ignored_terrains : initial(gun.ignored_terrains)

	radio = new(src)

	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	if(CHECK_BITFIELD(gun?.turret_flags, TURRET_INACCURATE))
		gun.accuracy_mult -= 0.15
		gun.scatter += 10

	if(CHECK_BITFIELD(gun?.turret_flags, TURRET_HAS_CAMERA))
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[name] ([rand(0, 1000)])"

	GLOB.marine_turrets += src
	set_on(TRUE)

///Change minimap icon if its firing or not firing
/obj/machinery/deployable/mounted/sentry/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	if(!z)
		return
	var/marker_flags
	switch(iff_signal)
		if(TGMC_LOYALIST_IFF)
			marker_flags = MINIMAP_FLAG_MARINE
		if(SOM_IFF)
			marker_flags = MINIMAP_FLAG_MARINE_SOM
		else
			marker_flags = MINIMAP_FLAG_MARINE
	SSminimaps.add_marker(src, marker_flags, image('icons/UI_icons/map_blips.dmi', null, "sentry[firing ? "_firing" : "_passive"]"))

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
	if(get_internal_item())
		var/obj/item/internal_sentry = get_internal_item()
		if(internal_sentry)
			UnregisterSignal(internal_sentry, COMSIG_MOB_GUN_FIRED)
	GLOB.marine_turrets -= src
	return ..()

/obj/machinery/deployable/mounted/sentry/deconstruct(disassembled = TRUE)
	if(!disassembled)
		explosion(loc, light_impact_range = 3)
	return ..()

/obj/machinery/deployable/mounted/sentry/on_deconstruction()
	sentry_alert(SENTRY_ALERT_DESTROYED)
	return ..()

/obj/machinery/deployable/mounted/sentry/AltClick(mob/user)
	if(!match_iff(user))
		to_chat(user, span_notice("Access denied."))
		return
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

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return

	user.visible_message(span_notice("[user] sets [src] upright."),
		span_notice("You set [src] upright."))

	DISABLE_BITFIELD(machine_stat, KNOCKED_DOWN)
	density = TRUE
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/reload(mob/user, ammo_magazine)
	if(!match_iff(user)) //You can't pull the ammo out of hostile turrets
		to_chat(user, span_notice("Access denied."))
		return
	. = ..()
	update_static_data(user)

/obj/machinery/deployable/mounted/sentry/interact(mob/user, manual_mode = FALSE)
	if(!match_iff(user)) //You can't mess with hostile turrets
		to_chat(user, span_notice("Access denied."))
		return
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(manual_mode)
		return ..()

	if(CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return TRUE

	if(CHECK_BITFIELD(gun?.turret_flags, TURRET_IMMOBILE))
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
	var/obj/item/weapon/gun/gun = get_internal_item()
	var/current_rounds
	current_rounds = gun?.rounds ? gun.rounds : 0
	. = list(
		"rounds" = current_rounds,
		"health" = obj_integrity
	)

/obj/machinery/deployable/mounted/sentry/ui_static_data(mob/user)
	var/obj/item/weapon/gun/gun = get_internal_item()
	var/rounds_max
	rounds_max = gun?.max_rounds ? gun.max_rounds : 0
	. = list(
		"name" = copytext(name, 2),
		"rounds_max" = rounds_max,
		"fire_mode" = gun?.gun_firemode ? gun.gun_firemode : initial(gun.gun_firemode),
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
	var/obj/item/weapon/gun/gun = get_internal_item()
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
			gun?.do_toggle_firemode(user)
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
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(!new_state)
		visible_message(span_notice("The [name] powers down and goes silent."))
		DISABLE_BITFIELD(gun.turret_flags, TURRET_ON)
		gun?.set_target(null)
		set_light(0)
		update_icon()
		STOP_PROCESSING(SSobj, src)
		if(gun)
			UnregisterSignal(gun, COMSIG_MOB_GUN_FIRED)
		return

	ENABLE_BITFIELD(gun?.turret_flags, TURRET_ON)
	visible_message(span_notice("The [name] powers up with a warm hum."))
	set_light_range(initial(light_power))
	set_light_color(initial(light_color))
	set_light(SENTRY_LIGHT_POWER,SENTRY_LIGHT_POWER)
	update_icon()
	START_PROCESSING(SSobj, src)
	RegisterSignal(gun, COMSIG_MOB_GUN_FIRED, PROC_REF(check_next_shot))
	update_minimap_icon()

///Bonks the sentry onto its side. This currently is used here, and in /living/carbon/xeno/warrior/mob_abilities in punch
/obj/machinery/deployable/mounted/sentry/proc/knock_down()
	if(CHECK_BITFIELD(machine_stat, KNOCKED_DOWN))
		return
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	internal_gun.stop_fire() //Comrade sentry has been sent to the gulags. He served the revolution well.
	firing = FALSE
	update_minimap_icon()
	visible_message(span_highdanger("The [name] is knocked over!"))
	sentry_alert(SENTRY_ALERT_FALLEN)
	ENABLE_BITFIELD(machine_stat, KNOCKED_DOWN)
	density = FALSE
	set_on(FALSE)
	update_icon()

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

//----------------------------------------------------------------------------
// Sentry Functions

///Sentry wants to scream for help.
/obj/machinery/deployable/mounted/sentry/proc/sentry_alert(alert_code, mob/mob)
	if(!internal_item)
		return
	var/obj/item/weapon/gun/gun = get_internal_item()
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
		var/obj/item/weapon/gun/gun = get_internal_item()
		gun?.stop_fire()
		firing = FALSE
		update_minimap_icon()
		return
	playsound(loc, 'sound/items/detector.ogg', 25, FALSE)

	sentry_start_fire()

///Checks the nearby mobs for eligability. If they can be targets it stores them in potential_targets. Returns TRUE if there are targets, FALSE if not.
/obj/machinery/deployable/mounted/sentry/proc/scan()
	var/obj/item/weapon/gun/gun = get_internal_item()
	potential_targets.Cut()
	if(!gun)
		return length(potential_targets)
	for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, range))
		if(nearby_human.stat == DEAD || CHECK_BITFIELD(nearby_human.status_flags, INCORPOREAL)  || (CHECK_BITFIELD(gun.turret_flags, TURRET_SAFETY) || nearby_human.wear_id?.iff_signal & iff_signal))
			continue
		potential_targets += nearby_human
	for(var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(nearby_xeno.stat == DEAD || HAS_TRAIT(nearby_xeno, TRAIT_TURRET_HIDDEN) || CHECK_BITFIELD(nearby_xeno.status_flags, INCORPOREAL) || CHECK_BITFIELD(nearby_xeno.xeno_iff_check(), iff_signal)) //So wraiths wont be shot at when in phase shift
			continue
		potential_targets += nearby_xeno
	for(var/obj/vehicle/sealed/mecha/nearby_mech AS in cheap_get_mechs_near(src, range))
		if(!length(nearby_mech.occupants))
			continue
		var/mob/living/carbon/human/human_occupant = nearby_mech.occupants[1]
		if(!istype(human_occupant) || (human_occupant.wear_id?.iff_signal & iff_signal))
			continue
		potential_targets += nearby_mech
	return length(potential_targets)

///Checks the range and the path of the target currently being shot at to see if it is eligable for being shot at again. If not it will stop the firing.
/obj/machinery/deployable/mounted/sentry/proc/check_next_shot(datum/source, atom/gun_target, obj/item/weapon/gun/gun)
	SIGNAL_HANDLER
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	if(!internal_gun)
		return
	if(CHECK_BITFIELD(internal_gun.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && length(internal_gun.chamber_items))
		INVOKE_ASYNC(internal_gun, TYPE_PROC_REF(/obj/item/weapon/gun, do_unique_action))
	if(!CHECK_BITFIELD(internal_gun.flags_item, IS_DEPLOYED) || get_dist(src, gun_target) > range || (!CHECK_BITFIELD(get_dir(src, gun_target), dir) && !CHECK_BITFIELD(internal_gun.turret_flags, TURRET_RADIAL)) || !check_target_path(gun_target))
		internal_gun.stop_fire()
		firing = FALSE
		update_minimap_icon()
		return
	if(internal_gun.gun_firemode != GUN_FIREMODE_SEMIAUTO)
		return
	addtimer(CALLBACK(src, PROC_REF(sentry_start_fire)), internal_gun.fire_delay) //This schedules the next shot if the gun is on semi-automatic. This is so that semi-automatic guns don't fire once every two seconds.

///Sees if theres a target to shoot, then handles firing.
/obj/machinery/deployable/mounted/sentry/proc/sentry_start_fire()
	var/obj/item/weapon/gun/gun = get_internal_item()
	var/mob/living/target = get_target()
	update_icon()
	if(!target || get_dist(src, target) > range)
		gun.stop_fire()
		firing = FALSE
		update_minimap_icon()
		return
	if(target != gun.target)
		gun.stop_fire()
		firing = FALSE
		update_minimap_icon()
	if(!gun.rounds)
		sentry_alert(SENTRY_ALERT_AMMO)
		return
	if(CHECK_BITFIELD(gun.turret_flags, TURRET_RADIAL))
		setDir(get_cardinal_dir(src, target))
	if(HAS_TRAIT(gun, TRAIT_GUN_BURST_FIRING))
		gun.set_target(target)
		return
	gun.start_fire(src, target, bypass_checks = TRUE)
	firing = TRUE
	update_minimap_icon()

///Checks the path to the target for obstructions. Returns TRUE if the path is clear, FALSE if not.
/obj/machinery/deployable/mounted/sentry/proc/check_target_path(atom/target)
	var/list/turf/path = getline(src, target)
	var/turf/starting_turf = get_turf(src)
	var/turf/target_turf = path[length(path)-1]
	path -= get_turf(src)
	if(!length(path))
		return FALSE

	var/old_turf_dir_to_us = get_dir(starting_turf, target_turf)
	if(ISDIAGONALDIR(old_turf_dir_to_us))
		for(var/i in 0 to 2)
			var/between_turf = get_step(target_turf, turn(old_turf_dir_to_us, i == 1 ? 45 : -45))
			if(can_see_through(starting_turf, between_turf))
				break
			if(i==2)
				return FALSE
	for(var/turf/T AS in path)
		var/obj/effect/particle_effect/smoke/smoke = locate() in T
		if(smoke?.opacity)
			return FALSE

		if(IS_OPAQUE_TURF(T) || T.density && !(T.allow_pass_flags & PASS_PROJECTILE) && !(T.type in ignored_terrains))
			return FALSE

		for(var/obj/machinery/MA in T)
			if(MA.density && !(MA.allow_pass_flags & PASS_PROJECTILE) && !(MA.type in ignored_terrains))
				return FALSE

		for(var/obj/structure/S in T)
			if(S.density && !(S.allow_pass_flags & PASS_PROJECTILE) && !(S.type in ignored_terrains))
				return FALSE

	return TRUE

///Works through potential targets. First checks if they are in range, and if they are friend/foe. Then checks the path to them. Returns the first eligable target.
/obj/machinery/deployable/mounted/sentry/proc/get_target()
	var/distance = range + 0.5 //we add 0.5 so if a potential target is at range, it is accepted by the system
	var/buffer_distance
	var/obj/item/weapon/gun/gun = get_internal_item()
	for (var/atom/nearby_target AS in potential_targets)
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
	if(!match_iff(user)) //You can't steal other faction's turrets
		to_chat(user, span_notice("Access denied."))
		return
	. = ..()
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(!gun)
		return
	if(CHECK_BITFIELD(gun.turret_flags, TURRET_INACCURATE))
		gun.accuracy_mult += 0.15
		gun.scatter -= 10

///Checks the users faction against turret IFF, used to stop hostile factions from interacting with turrets in ways they shouldn't.
/obj/machinery/deployable/mounted/sentry/proc/match_iff(mob/user)
	if(!user)
		return TRUE
	if((GLOB.faction_to_iff[user.faction] != iff_signal) && iff_signal) //You can't steal other faction's turrets
		return FALSE
	return TRUE

/obj/machinery/deployable/mounted/sentry/buildasentry
	name = "broken build-a-sentry"
	desc = "You should not be seeing this unless a mapper, coder or admin screwed up."

/obj/machinery/deployable/mounted/sentry/buildasentry/Initialize(mapload, _internal_item, deployer) //I know the istype spam is a bit much, but I don't think there is a better way.
	. = ..()
	var/obj/item/internal_sentry = get_internal_item()
	if(internal_sentry)
		name = "Deployed " + internal_sentry.name
	icon = 'icons/Marine/sentry.dmi'
	default_icon_state = "build_a_sentry"
	update_icon()

/obj/machinery/deployable/mounted/sentry/buildasentry/update_overlays()
	. = ..()
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	if(internal_gun)
		. += image('icons/Marine/sentry.dmi', src, internal_gun.placed_overlay_iconstate, dir = dir)


//Throwable turret
/obj/machinery/deployable/mounted/sentry/cope
	density = FALSE

/obj/machinery/deployable/mounted/sentry/cope/sentry_start_fire()
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	internal_gun?.update_ammo_count() //checks if the battery has recharged enough to fire
	return ..()

///Dissassembles the device
/obj/machinery/deployable/mounted/sentry/cope/disassemble(mob/user)
	var/obj/item/item = get_internal_item()
	if(!item)
		return
	if(CHECK_BITFIELD(item.flags_item, DEPLOYED_NO_PICKUP))
		to_chat(user, span_notice("[src] is anchored in place and cannot be disassembled."))
		return
	if(!match_iff(user)) //You can't steal other faction's turrets
		to_chat(user, span_notice("Access denied."))
		return
	operator?.unset_interaction()

	var/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/attached_item = get_internal_item() //Item the machine is undeploying

	if(!ishuman(user))
		return
	set_on(FALSE)
	user.balloon_alert(user, "You start disassembling [attached_item]")
	if(!do_after(user, attached_item.undeploy_time, NONE, src, BUSY_ICON_BUILD))
		set_on(TRUE)
		return

	DISABLE_BITFIELD(attached_item.flags_item, IS_DEPLOYED)

	attached_item.reset()
	user.unset_interaction()
	user.put_in_hands(attached_item)

	attached_item.max_integrity = max_integrity
	attached_item.obj_integrity = obj_integrity

	internal_item = null

	QDEL_NULL(src)
	attached_item.update_icon_state()
