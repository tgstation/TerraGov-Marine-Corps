/obj/machinery/deployable/mounted/sentry

	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	layer = ABOVE_MOB_LAYER
	use_power = 0
	req_one_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_LEADER)
	hud_possible = list(MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)


	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 80, "acid" = 50)

	///Spark system for making sparks
	var/datum/effect_system/spark_spread/spark_system 
	///Camera for viewing with cam consoles
	var/obj/machinery/camera/camera
	///True if the sentry is tipped over
	var/knocked_down = FALSE
	///View and fire range of the sentry
	var/range = 7
	///Damage required to knock the sentry over and disable it
	var/knockdown_threshold = 150
	///Current target of the sentry
	var/mob/living/target
	///Time of last alert
	var/last_alert = 0
	///Time of last damage alert
	var/last_damage_alert = 0
	///Radio so that the sentry can scream for help
	var/obj/item/radio/radio

//------------------------------------------------------------------
//Setup and Deletion

/obj/machinery/deployable/mounted/sentry/Initialize(mapload, _internal_item)
	. = ..()
	var/obj/item/weapon/gun/sentry = internal_item

	if((sentry.gun_firemode_list.len == 1 && sentry.gun_firemode != GUN_FIREMODE_SEMIAUTO))
		CRASH("[sentry] has been deployed, yet it does not have the option for Semi-Automatic fire. GUN_FIREMODE_SEMIAUTO should be available.")

	sentry.set_gun_user(null)
	sentry.do_toggle_firemode(new_firemode = GUN_FIREMODE_SEMIAUTO)
	knockdown_threshold = sentry.knockdown_threshold
	range = sentry.turret_range

	radio = new(src)

	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	if(CHECK_BITFIELD(sentry.turret_flags, TURRET_HAS_CAMERA))
		camera = new (src)
		camera.network = list("military")
		camera.c_tag = "[name] ([rand(0, 1000)])"

	GLOB.marine_turrets += src
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/update_icon_state()
	. = ..()
	if(!knocked_down)
		return
	icon_state += "_f"

/obj/machinery/deployable/mounted/sentry/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(camera)

	target = null

	stop_processing()
	GLOB.marine_turrets -= src
	return ..()

/obj/machinery/deployable/mounted/sentry/deconstruct(disassembled = TRUE)
	if(!disassembled)
		explosion(loc, light_impact_range = 3)
	return ..()

/obj/machinery/deployable/mounted/sentry/on_deconstruction()
	sentry_alert(SENTRY_ALERT_DESTROYED)
	. = ..()
	
//-----------------------------------------------------------------
// Interaction

/obj/machinery/deployable/mounted/sentry/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cell/lasgun/lasrifle/marine))
		internal_item.attackby(I, user, params)
		return
	return ..()

/obj/machinery/deployable/mounted/sentry/AltClick(mob/user)
	. = ..()
	internal_item.AltClick(user)

/obj/machinery/deployable/mounted/sentry/on_set_interaction(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You disable the [src]'s automatic to operate it manually.</span>")
	set_on(FALSE)

/obj/machinery/deployable/mounted/sentry/on_unset_interaction(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You stop using the [src] and its automatic functions re-activate</span>")
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/attack_hand(mob/living/user)
	var/obj/item/weapon/gun/sentry = internal_item
	if(CHECK_BITFIELD(sentry.turret_flags, TURRET_IMMOBILE))
		to_chat(user, "<span class='warning'>[src]'s panel is completely locked, you can't do anything.</span>")
		return

	if(!knocked_down)
		ui_interact(user)
		return

	user.visible_message("<span class='notice'>[user] begins to set [src] upright.</span>",
	"<span class='notice'>You begin to set [src] upright.</span>")

	if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
		return

	user.visible_message("<span class='notice'>[user] sets [src] upright.</span>",
	"<span class='notice'>You set [src] upright.</span>")

	knocked_down = FALSE
	set_on(TRUE)

/obj/machinery/deployable/mounted/sentry/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sentry", "Sentry Gun")
		ui.open()

/obj/machinery/deployable/mounted/sentry/ui_data(mob/user)
	var/obj/item/weapon/gun/sentry = internal_item
	. = list(
		"name" = copytext(src.name, 2),
		"rounds" = sentry.current_mag.current_rounds,
		"rounds_max" = sentry.current_mag.max_rounds,
		"health" = obj_integrity,
		"health_max" = max_integrity,
		"has_cell" = (sentry.battery ? 1 : 0),
		"cell_charge" = sentry.battery ? sentry.battery.charge : 0,
		"cell_maxcharge" = sentry.battery ? sentry.battery.maxcharge : 0,
		"dir" = dir,
		"safety_toggle" = CHECK_BITFIELD(sentry.turret_flags, TURRET_SAFETY),
		"manual_override" = operator,
		"alerts_on" = CHECK_BITFIELD(sentry.turret_flags, TURRET_ALERTS),
		"radial_mode" = CHECK_BITFIELD(sentry.turret_flags, TURRET_RADIAL),
	)

/obj/machinery/deployable/mounted/sentry/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/obj/item/weapon/gun/sentry = internal_item
	var/mob/living/carbon/human/user = usr
	if(!istype(user) || CHECK_BITFIELD(sentry.turret_flags, TURRET_IMMOBILE) || knocked_down)
		return

	switch(action)
		if("safety")

			TOGGLE_BITFIELD(sentry.turret_flags, TURRET_SAFETY)
			var/safe = CHECK_BITFIELD(sentry.turret_flags, TURRET_SAFETY)
			user.visible_message("<span class='warning'>[user] [safe ? "" : "de"]activates [src]'s safety lock.</span>",
			"<span class='warning'>You [safe ? "" : "de"]activate [src]'s safety lock.</span>")
			visible_message("<span class='warning'>A red light on [src] blinks brightly!")
			. = TRUE

		if("manual")
			if(operator)
				user.unset_interaction()
			else
				interact(user)
			. = TRUE

		if("toggle_alert")
			TOGGLE_BITFIELD(sentry.turret_flags, TURRET_ALERTS)
			var/alert = CHECK_BITFIELD(sentry.turret_flags, TURRET_ALERTS)
			user.visible_message("<span class='notice'>[user] [alert ? "" : "de"]activates [src]'s alert notifications.</span>",
			"<span class='notice'>You [alert ? "" : "de"]activate [src]'s alert notifications.</span>")
			say("Alert notification system [alert ? "initiated" : "deactivated"]")
			update_icon()
			. = TRUE

		if("toggle_radial")
			TOGGLE_BITFIELD(sentry.turret_flags, TURRET_RADIAL)
			var/rad_msg = CHECK_BITFIELD(sentry.turret_flags, TURRET_RADIAL) ? "activate" : "deactivate"
			user.visible_message("<span class='notice'>[user] [rad_msg]s [src]'s radial mode.</span>", "<span class='notice'>You [rad_msg] [src]'s radial mode.</span>")
			say("Radial mode [rad_msg]d.")
			. = TRUE

	attack_hand(user)

///Handles turning the sentry ON and OFF. new_state is a bool
/obj/machinery/deployable/mounted/sentry/proc/set_on(new_state)
	var/obj/item/weapon/gun/sentry = internal_item
	if(!new_state)
		visible_message("<span class='notice'>The [name] powers down and goes silent.</span>")
		DISABLE_BITFIELD(sentry.turret_flags, TURRET_ON)
		target = null
		set_light(0)
		update_icon_state()
		stop_processing()
		return

	ENABLE_BITFIELD(sentry.turret_flags, TURRET_ON)
	visible_message("<span class='notice'>The [name] powers up with a warm hum.</span>")
	set_light_range(initial(light_power))
	set_light_color(initial(light_color))
	set_light(SENTRY_LIGHT_POWER)
	update_icon_state()
	start_processing()

///Bonks the sentry onto its side. This currently is used here, and in /living/carbon/xeno/warrior/xeno_abilities in punch
/obj/machinery/deployable/mounted/sentry/proc/knock_down()
	visible_message("<span class='danger'>The [name] is knocked over!</span>")
	sentry_alert(SENTRY_ALERT_FALLEN)
	knocked_down = TRUE
	density = FALSE
	set_on(FALSE)
	update_icon_state()

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
	update_icon_state()

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
	var/obj/item/weapon/gun/sentry = internal_item
	if(!alert_code || !CHECK_BITFIELD(sentry.turret_flags, TURRET_ALERTS) || !CHECK_BITFIELD(sentry.turret_flags, TURRET_ON))
		return
	
	var/notice

	if(alert_code == SENTRY_ALERT_HOSTILE && (world.time >= (last_alert + SENTRY_ALERT_DELAY)))
		notice = "<b>ALERT! [src] detected Hostile/Unknown: [mob.name] at: [AREACOORD_NO_Z(src)].</b>"
		last_alert = world.time

	else 
		if(world.time < (last_damage_alert + SENTRY_DAMAGE_ALERT_DELAY))
			return

		switch(alert_code)
			if(SENTRY_ALERT_AMMO)
				notice = "<b>ALERT! [src]'s ammo depleted at: [AREACOORD_NO_Z(src)].</b>"
			if(SENTRY_ALERT_FALLEN)
				notice = "<b>ALERT! [src] has been knocked over at: [AREACOORD_NO_Z(src)].</b>"
			if(SENTRY_ALERT_DAMAGE)
				notice = "<b>ALERT! [src] has taken damage at: [AREACOORD_NO_Z(src)]. Remaining Structural Integrity: ([obj_integrity]/[max_integrity])[obj_integrity < 50 ? " CONDITION CRITICAL!!" : ""]</b>"
			if(SENTRY_ALERT_DESTROYED)
				notice = "<b>ALERT! [src] at: [AREACOORD_NO_Z(src)] has been destroyed!</b>"
			if(SENTRY_ALERT_BATTERY)
				notice = "<b>ALERT! [src]'s battery depleted at: [AREACOORD_NO_Z(src)].</b>"

	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
	radio.talk_into(src, "[notice]", FREQ_COMMON)
	last_damage_alert = world.time

/obj/machinery/deployable/mounted/sentry/process()
	var/obj/item/weapon/gun/sentry = internal_item
	if(knocked_down)
		stop_processing()
		return

	if(!sentry.current_mag)
		sentry_alert(SENTRY_ALERT_AMMO)
		return

	playsound(loc, 'sound/items/detector.ogg', 25, FALSE)

	var/fire_delay = sentry.fire_delay
	if(fire_delay >= 2 SECONDS)
		fire_delay = 2 SECONDS
	var/checks_per_proccess = round(2 SECONDS / fire_delay, 1)

	for(var/check = 1, check < checks_per_proccess, check++)
		addtimer(CALLBACK(src, .proc/sentry_start_fire), fire_delay*check)

///Sees if theres a target to shoot, then handles firing.
/obj/machinery/deployable/mounted/sentry/proc/sentry_start_fire()
	var/obj/item/weapon/gun/sentry = internal_item

	var/new_target = get_target()

	if(!new_target)
		target = new_target
		sentry.stop_fire()
		return

	target = new_target
	if(CHECK_BITFIELD(sentry.turret_flags, TURRET_RADIAL))
		sentry.battery.charge -= 20
		var/new_dir = get_dir(src, target)
		switch(new_dir)
			if(NORTHWEST)
				new_dir = NORTH
			if(NORTHEAST)
				new_dir = EAST
			if(SOUTHWEST)
				new_dir = WEST
			if(SOUTHEAST)
				new_dir = SOUTH
		setDir(new_dir)
		if(sentry.battery.charge <= 0)
			sentry_alert(SENTRY_ALERT_BATTERY)
			DISABLE_BITFIELD(sentry.turret_flags, TURRET_RADIAL)
			sentry.battery.forceMove(loc)
			sentry.battery.charge = 0
			sentry.battery = null
	if(sentry.gun_firemode != GUN_FIREMODE_SEMIAUTO)
		sentry.do_toggle_firemode(new_firemode = GUN_FIREMODE_SEMIAUTO)
	sentry.start_fire(src, target, bypass_checks = TRUE)

///Gets eligable targets for the sentry.
/obj/machinery/deployable/mounted/sentry/proc/get_target()
	var/obj/item/weapon/gun/sentry = internal_item
	var/list/mob/potential_targets = view(range, src)

	var/list/turf/path = list()
	var/turf/turf

	var/list/mob/targets = list()

	if(!potential_targets.len)
		return null

	for(var/mob/living/mob AS in potential_targets)
		if(!istype(mob) || mob.stat == DEAD)
			continue

		var/mob/living/carbon/human/human = mob
		if(istype(human) && (CHECK_BITFIELD(sentry.turret_flags, TURRET_SAFETY) || human.get_target_lock(sentry.gun_iff_signal)))
			continue

		var/angle = get_dir(src, mob)
		if(!(angle & dir) && !CHECK_BITFIELD(sentry.turret_flags, TURRET_RADIAL))
			continue

		path = getline(src, mob)
		path -= get_turf(src)

		sentry_alert(SENTRY_ALERT_HOSTILE, mob)

		if(!path.len)
			return
		var/blocked = FALSE
		for(turf in path)

			var/obj/effect/particle_effect/smoke/smoke = locate() in turf
			if(smoke)
				blocked = TRUE
				break

			if(IS_OPAQUE_TURF(turf) || turf.density && turf.throwpass == FALSE)
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.
	
			for(var/obj/machinery/machinery in turf)
				if(machinery.opacity || machinery.density && machinery.throwpass == FALSE)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/structure in turf)
				if(structure.opacity || structure.density && structure.throwpass == FALSE )
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			targets.Add(mob)

	if(target in targets)
		return target

	if(targets.len) 
		return pick(targets)

	return null

