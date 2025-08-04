/obj/structure/xeno
	hit_sound = SFX_ALIEN_RESIN_BREAK
	layer = BELOW_OBJ_LAYER
	resistance_flags = UNACIDABLE
	///Bitflags specific to xeno structures
	var/xeno_structure_flags
	///Which hive(number) do we belong to?
	var/hivenumber = XENO_HIVE_NORMAL
	///Is the structure currently detecting a threat
	var/threat_warning
	///proximity monitor for threat detection
	var/datum/proximity_monitor/proximity_monitor
	COOLDOWN_DECLARE(proxy_alert_cooldown)
	COOLDOWN_DECLARE(damage_alert_cooldown)

/obj/structure/xeno/Initialize(mapload, _hivenumber)
	. = ..()
	if(!(xeno_structure_flags & IGNORE_WEED_REMOVAL))
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, PROC_REF(weed_removed))
	if(_hivenumber)
		hivenumber = _hivenumber
	else if(is_centcom_level(z) && hivenumber == XENO_HIVE_NORMAL) // For admins that want to play with it.
		if(istype(get_area(src), /area/centcom/valhalla/xenocave))
			hivenumber = XENO_HIVE_FALLEN
		else
			hivenumber = XENO_HIVE_ADMEME
	LAZYADDASSOC(GLOB.xeno_structures_by_hive, hivenumber, src)
	if(xeno_structure_flags & CRITICAL_STRUCTURE)
		LAZYADDASSOC(GLOB.xeno_critical_structures_by_hive, hivenumber, src)
	if((xeno_structure_flags & XENO_STRUCT_WARNING_RADIUS))
		proximity_monitor = new(src, XENO_STRUCTURE_DETECTION_RANGE)

/obj/structure/xeno/Destroy()
	//prox_warning_turfs = null
	if(!locate(src) in GLOB.xeno_structures_by_hive[hivenumber]+GLOB.xeno_critical_structures_by_hive[hivenumber]) //The rest of the proc is pointless to look through if its not in the lists
		stack_trace("[src] not found in the list of (potentially critical) xeno structures!") //We dont want to CRASH because that'd block deletion completely. Just trace it and continue.
		return ..()
	GLOB.xeno_structures_by_hive[hivenumber] -= src
	if(xeno_structure_flags & CRITICAL_STRUCTURE)
		GLOB.xeno_critical_structures_by_hive[hivenumber] -= src
	if(proximity_monitor)
		QDEL_NULL(proximity_monitor)
	return ..()

/obj/structure/xeno/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(210, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(140, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(70, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(35, BRUTE, BOMB)

/obj/structure/xeno/attack_hand(mob/living/user)
	balloon_alert(user, "You only scrape at it")
	return TRUE

/obj/structure/xeno/fire_act(burn_level)
	take_damage(burn_level / 3, BURN, FIRE)

///Alerts the Hive when hostiles get too close to this structure
/obj/structure/xeno/HasProximity(atom/movable/hostile)
	if(!COOLDOWN_FINISHED(src, proxy_alert_cooldown))
		return

	if(issamexenohive(hostile))
		return

	if(!iscarbon(hostile) && !isvehicle(hostile))
		return

	if(iscarbon(hostile))
		var/mob/living/carbon/carbon_triggerer = hostile
		if(carbon_triggerer.stat == DEAD)
			return

	if(isvehicle(hostile))
		var/obj/vehicle/vehicle_triggerer = hostile
		if(vehicle_triggerer.trigger_gargoyle == FALSE)
			return

	threat_warning = TRUE
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] has detected a nearby hostile [hostile] at [get_area(hostile)] (X: [hostile.x], Y: [hostile.y]).", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien/help1.ogg', FALSE, null, /atom/movable/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, proxy_alert_cooldown, XENO_STRUCTURE_DETECTION_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_STRUCTURE_DETECTION_COOLDOWN)
	update_minimap_icon()
	update_appearance(UPDATE_ICON)

/// Destroy the xeno structure when the weed it was on is destroyed
/obj/structure/xeno/proc/weed_removed()
	SIGNAL_HANDLER
	obj_destruction(damage_flag = MELEE)

/obj/structure/xeno/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(xeno_structure_flags & XENO_STRUCT_DAMAGE_ALERT)
		damage_alert()

/obj/structure/xeno/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!(HAS_TRAIT(xeno_attacker, TRAIT_VALHALLA_XENO) && xeno_attacker.a_intent == INTENT_HARM && (tgui_alert(xeno_attacker, "Are you sure you want to tear down [src]?", "Tear down [src]?", list("Yes","No"))) == "Yes"))
		return ..()
	if(!do_after(xeno_attacker, 3 SECONDS, NONE, src))
		return
	xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	balloon_alert_to_viewers("\The [xeno_attacker] tears down \the [src]!", "We tear down \the [src].")
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	take_damage(max_integrity) // Ensure its destroyed

/obj/structure/xeno/plasmacutter_act(mob/living/user, obj/item/I)
	if(!isplasmacutter(I) || user.do_actions)
		return FALSE
	if(!(obj_flags & CAN_BE_HIT) || CHECK_BITFIELD(resistance_flags, PLASMACUTTER_IMMUNE) || CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return FALSE
	var/obj/item/tool/pickaxe/plasmacutter/plasmacutter = I
	if(!plasmacutter.powered || (plasmacutter.item_flags & NOBLUDGEON))
		return FALSE
	var/charge_cost = PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD
	if(!plasmacutter.start_cut(user, name, src, charge_cost, no_string = TRUE))
		return FALSE

	user.changeNext_move(plasmacutter.attack_speed)
	user.do_attack_animation(src, used_item = plasmacutter)
	plasmacutter.cut_apart(user, name, src, charge_cost)
	take_damage(max(0, plasmacutter.force * (1 + PLASMACUTTER_RESIN_MULTIPLIER)), plasmacutter.damtype, MELEE)
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	return TRUE

///Notifies the hive when we take damage
/obj/structure/xeno/proc/damage_alert()
	if(!COOLDOWN_FINISHED(src, damage_alert_cooldown))
		return
	threat_warning = TRUE
	update_minimap_icon()
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.", "xenoannounce", 5, FALSE, src, 'sound/voice/alien/help1.ogg',FALSE, null, /atom/movable/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, damage_alert_cooldown, XENO_STRUCTURE_HEALTH_ALERT_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_STRUCTURE_HEALTH_ALERT_COOLDOWN)

///Clears any threat warnings
/obj/structure/xeno/proc/clear_warning()
	threat_warning = FALSE
	update_minimap_icon()
	update_appearance(UPDATE_ICON)

///resets minimap icon for structure
/obj/structure/xeno/proc/update_minimap_icon()
	return
