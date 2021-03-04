/obj/structure/resin
	hit_sound = "alien_resin_break"
	layer = RESIN_STRUCTURE_LAYER
	resistance_flags = UNACIDABLE


/obj/structure/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210)
		if(EXPLODE_HEAVY)
			take_damage(140)
		if(EXPLODE_LIGHT)
			take_damage(70)

/obj/structure/resin/attack_hand(mob/living/user)
	to_chat(user, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE

/obj/structure/resin/flamer_fire_act()
	take_damage(10, BURN, "fire")

/obj/structure/resin/fire_act()
	take_damage(10, BURN, "fire")


/obj/structure/resin/silo
	name = "resin silo"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "resin_silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	max_integrity = 1000
	var/turf/center_turf
	var/datum/hive_status/associated_hive
	var/silo_area
	var/number_silo
	///How old this silo is in seconds
	var/maturity = 0
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)
	COOLDOWN_DECLARE(silo_proxy_alert_cooldown)

/obj/structure/resin/silo/Initialize()
	. = ..()
	var/static/number = 1
	name = "[name] [number]"
	number_silo = number
	number++
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), .proc/start_maturing)
	GLOB.xeno_resin_silos += src
	center_turf = get_step(src, NORTHEAST)
	if(!istype(center_turf))
		center_turf = loc

	for(var/i in RANGE_TURFS(XENO_SILO_DETECTION_RANGE, src))
		RegisterSignal(i, COMSIG_ATOM_ENTERED, .proc/resin_silo_proxy_alert)

	if(SSsilo.silos_do_mature)
		start_maturing()

	return INITIALIZE_HINT_LATELOAD


/obj/structure/resin/silo/LateInitialize()
	. = ..()
	if(!locate(/obj/effect/alien/weeds) in center_turf)
		new /obj/effect/alien/weeds/node(center_turf)
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(associated_hive)
		RegisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)
		associated_hive.handle_silo_death_timer()
	silo_area = get_area(src)

/obj/structure/resin/silo/Destroy()
	GLOB.xeno_resin_silos -= src
	if(associated_hive)
		UnregisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		
		if(isdistress(SSticker.mode)) //Silo can only be destroy in distress mode, but this check can create bugs if new gamemodes are added.
			var/datum/game_mode/infestation/distress/distress_mode
			distress_mode = SSticker.mode
			if (!(distress_mode.round_stage == DISTRESS_DROPSHIP_CRASHING))//No need to notify the xenos shipside
				associated_hive.xeno_message("<span class='xenoannounce'>A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!</span>", 2, FALSE,src.loc, 'sound/voice/alien_help2.ogg',FALSE , null, /obj/screen/arrow/silo_damaged_arrow)
				associated_hive.handle_silo_death_timer()
				associated_hive = null
				notify_ghosts("\ A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", source = get_turf(src), action = NOTIFY_JUMP)

	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(center_turf, pick(CARDINAL_ALL_DIRS)))
	playsound(loc,'sound/effects/alien_egg_burst.ogg', 75)

	silo_area = null
	center_turf = null
	STOP_PROCESSING(SSslowprocess, src)
	return ..()


/obj/structure/resin/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			to_chat(user, "<span class='warning'>It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.</span>")
		if(20 to 40)
			to_chat(user, "<span class='warning'>It looks severely damaged, its movements slow.</span>")
		if(40 to 60)
			to_chat(user, "<span class='warning'>It's quite beat up, but it seems alive.</span>")
		if(60 to 80)
			to_chat(user, "<span class='warning'>It's slightly damaged, but still seems healthy.</span>")
		if(80 to 100)
			to_chat(user, "<span class='info'>It appears in good shape, pulsating healthily.</span>")


/obj/structure/resin/silo/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()

	//We took damage, so it's time to start regenerating if we're not already processing
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

	resin_silo_damage_alert()

/obj/structure/resin/silo/proc/resin_silo_damage_alert()
	if(!COOLDOWN_CHECK(src, silo_damage_alert_cooldown))
		return

	associated_hive.xeno_message("<span class='xenoannounce'>Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.</span>", 2, FALSE, src, 'sound/voice/alien_help1.ogg',FALSE, null, /obj/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, silo_damage_alert_cooldown, XENO_HEALTH_ALERT_COOLDOWN) //set the cooldown.

///Alerts the Hive when hostiles get too close to their resin silo
/obj/structure/resin/silo/proc/resin_silo_proxy_alert(datum/source, atom/hostile)
	SIGNAL_HANDLER

	if(!COOLDOWN_CHECK(src, silo_proxy_alert_cooldown)) //Proxy alert triggered too recently; abort
		return

	if(!isliving(hostile))
		return

	var/mob/living/living_triggerer = hostile
	if(living_triggerer.stat == DEAD) //We don't care about the dead
		return

	if(isxeno(hostile))
		var/mob/living/carbon/xenomorph/X = hostile
		if(X.hive == associated_hive) //Trigger proxy alert only for hostile xenos
			return

	associated_hive.xeno_message("<span class='xenoannounce'>Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).</span>", 2, FALSE, hostile, 'sound/voice/alien_help1.ogg', FALSE, null, /obj/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, silo_proxy_alert_cooldown, XENO_SILO_DETECTION_COOLDOWN) //set the cooldown.

///Signal handler to tell the silo it can start maturing, so it adds it to the process if that's not the case
/obj/structure/resin/silo/proc/start_maturing()
	SIGNAL_HANDLER
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

/obj/structure/resin/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec
	
	if(SSsilo.silos_do_mature)
		maturity += 5


/obj/structure/resin/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(associated_hive)
		silos += src

/obj/structure/resin/xeno_turret
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = "acid_turret"
	name = "resin acid turret"
	desc = "A menacing looking construct of resin, it seems to be alive. It fires acid against intruders."
	bound_width = 32
	bound_height = 32
	max_integrity = 1800
	layer =  ABOVE_MOB_LAYER
	density = TRUE
	///The hive it belongs to
	var/datum/hive_status/associated_hive
	///What kind of spit it uses
	var/datum/ammo/ammo
	///Range of the turret
	var/range = 7
	///Target of the turret
	var/mob/living/carbon/hostile
	///Last target of the turret
	var/mob/living/carbon/last_hostile
	///Fire rate of the target in ticks
	var/firerate = 5
	///If true, the sentry will try to find a target to shoot on every second. If not, will do a scan a regular time interval
	var/awake = FALSE
	///The last time the sentry did a scan
	var/last_scan_time

/obj/structure/resin/xeno_turret/Initialize(mapload, hivenumber = XENO_HIVE_NORMAL)
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/xeno/acid/heavy/turret]
	associated_hive = GLOB.hive_datums[hivenumber]
	START_PROCESSING(SSprocessing, src)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, .proc/shoot)
	set_light(2, 2, LIGHT_COLOR_GREEN)

/obj/structure/resin/xeno_turret/Destroy()
	set_hostile(null)
	set_last_hostile(null)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/resin/xeno_turret/process()
	if(world.time > last_scan_time + TURRET_SCAN_FREQUENCY)
		awake = scan()
		last_scan_time = world.time
	if(!awake)
		return
	set_hostile(get_target())
	if (!hostile)
		if(last_hostile)
			set_last_hostile(null)
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_XENO_TURRETS_ALERT))
		associated_hive.xeno_message("<span class='xenoannounce'>Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)]. [name] has [obj_integrity]/[max_integrity] health remaining.</span>", 2, FALSE, src, 'sound/voice/alien_help1.ogg', FALSE, null, /obj/screen/arrow/turret_attacking_arrow)
		TIMER_COOLDOWN_START(src, COOLDOWN_XENO_TURRETS_ALERT, 20 SECONDS)
	if(hostile != last_hostile)
		set_last_hostile(hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)

///Signal handler for hard del of hostile
/obj/structure/resin/xeno_turret/proc/unset_hostile()
	SIGNAL_HANDLER
	hostile = null

///Signal handler for hard del of last_hostile
/obj/structure/resin/xeno_turret/proc/unset_last_hostile()
	SIGNAL_HANDLER
	last_hostile = null

///Setter for hostile with hard del in mind
/obj/structure/resin/xeno_turret/proc/set_hostile(_hostile)
	if(hostile != _hostile)
		hostile = _hostile
		RegisterSignal(hostile, COMSIG_PARENT_QDELETING, .proc/unset_hostile)

///Setter for last_hostile with hard del in mind
/obj/structure/resin/xeno_turret/proc/set_last_hostile(_last_hostile)
	if(last_hostile)
		UnregisterSignal(last_hostile, COMSIG_PARENT_QDELETING)
	last_hostile = _last_hostile

///Look for the closest human in range and in light of sight. If no human is in range, will look for xenos of other hives
/obj/structure/resin/xeno_turret/proc/get_target()
	var/distance = INFINITY
	var/buffer_distance
	var/list/turf/path = list()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, range))
		if(nearby_human.stat == DEAD)
			continue
		buffer_distance = get_dist(nearby_human, src)
		if (distance <= buffer_distance) //If we already found a target that's closer
			continue
		path = getline(src, nearby_human)
		path -= get_turf(src)
		if(!path.len) //Can't shoot if it's on the same turf
			continue
		var/blocked = FALSE
		for(var/turf/T AS in path)
			if(IS_OPAQUE_TURF(T) || T.density && T.throwpass == FALSE)
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/machinery/MA in T)
				if(MA.opacity || MA.density && MA.throwpass == FALSE)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/S in T)
				if(S.opacity || S.density && S.throwpass == FALSE )
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			distance = buffer_distance
			. = nearby_human
	if(.)//We have found the closest human target, human takes priority on xenos for performance issue
		return

	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(associated_hive == nearby_xeno.hive) //Xenomorphs not in our hive will be attacked as well!
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		buffer_distance = get_dist(nearby_xeno, src)
		if (distance <= buffer_distance) //If we already found a target that's closer
			continue
		path = getline(src, nearby_xeno)
		path -= get_turf(src)
		if(!path.len) //Can't shoot if it's on the same turf
			continue
		var/blocked = FALSE
		for(var/turf/T AS in path)
			if(IS_OPAQUE_TURF(T) || T.density && T.throwpass == FALSE)
				blocked = TRUE
				break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/machinery/MA in T)
				if(MA.opacity || MA.density && MA.throwpass == FALSE)
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.

			for(var/obj/structure/S in T)
				if(S.opacity || S.density && S.throwpass == FALSE )
					blocked = TRUE
					break //LoF Broken; stop checking; we can't proceed further.
		if(!blocked)
			distance = buffer_distance
			. = nearby_xeno

///Return TRUE if a possible target is near
/obj/structure/resin/xeno_turret/proc/scan()
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(src, TURRET_SCAN_RANGE))
		if(nearby_human.stat == DEAD)
			continue
		return TRUE
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(src, range))
		if(associated_hive == nearby_xeno.hive) //Xenomorphs not in our hive will be attacked as well!
			continue
		if(nearby_xeno.stat == DEAD)
			continue
		return TRUE
	return FALSE

///Signal handler to make the turret shoot at its target
/obj/structure/resin/xeno_turret/proc/shoot()
	SIGNAL_HANDLER
	if(!hostile)
		SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT)
		return
	face_atom(hostile)
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.permutated += src
	newshot.fire_at(hostile, src, null, ammo.max_range, ammo.shell_speed)
