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
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)
	COOLDOWN_DECLARE(silo_proxy_alert_cooldown)

/obj/structure/resin/silo/Initialize()
	. = ..()

	var/static/number = 1
	name = "[name] [number]"
	number_silo = number
	number++

	GLOB.xeno_resin_silos += src
	associated_hive?.handle_silo_death_timer()
	center_turf = get_step(src, NORTHEAST)
	if(!istype(center_turf))
		center_turf = loc

	for(var/i in RANGE_TURFS(2, src))
		RegisterSignal(i, COMSIG_ATOM_ENTERED, .proc/resin_silo_proxy_alert)

	return INITIALIZE_HINT_LATELOAD


/obj/structure/resin/silo/LateInitialize()
	. = ..()
	if(!locate(/obj/effect/alien/weeds) in center_turf)
		new /obj/effect/alien/weeds/node(center_turf)
	associated_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(associated_hive)
		RegisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)
	silo_area = get_area(src)

/obj/structure/resin/silo/Destroy()
	GLOB.xeno_resin_silos -= src
	if(associated_hive)
		UnregisterSignal(associated_hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		var/datum/game_mode/infestation/distress/distress_mode
		if(isdistress(SSticker.mode)) //Silo can only be destroy in distress mode, but this check can create bugs if new gamemodes are added.
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

	if(get_dist(loc, hostile) > 2) //Can only send alerts for those within 2 of us; so we don't have all silos sending alerts when one is proxy tripped
		return

	associated_hive.xeno_message("<span class='xenoannounce'>Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]). [name] has [obj_integrity]/[max_integrity] Health remaining.</span>", 2, FALSE, hostile, 'sound/voice/alien_help1.ogg')
	COOLDOWN_START(src, silo_proxy_alert_cooldown, XENO_HEALTH_ALERT_COOLDOWN) //set the cooldown.


/obj/structure/resin/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec
		return

	//If we're at max integrity, stop regenerating and processing.
	return PROCESS_KILL

/obj/structure/resin/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(associated_hive)
		silos += src
