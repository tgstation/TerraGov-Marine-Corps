
/obj/structure/xeno/silo
	name = "Resin silo"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "weed_silo"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -24
	max_integrity = 1001
	integrity_failure = 1
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE | PLASMACUTTER_IMMUNE | XENO_DAMAGEABLE
	xeno_structure_flags = IGNORE_WEED_REMOVAL|CRITICAL_STRUCTURE|XENO_STRUCT_WARNING_RADIUS|XENO_STRUCT_DAMAGE_ALERT
	///How many larva points one silo produce in one minute
	var/larva_spawn_rate = 0.5
	var/number_silo
	COOLDOWN_DECLARE(silo_damage_alert_cooldown)

/obj/structure/xeno/silo/Initialize(mapload, _hivenumber)
	. = ..()
	if(SSticker.mode?.round_type_flags & MODE_SILOS_SPAWN_MINIONS)
		SSspawning.registerspawner(src, INFINITY, GLOB.xeno_ai_spawnable, 0, 0, CALLBACK(src, PROC_REF(on_spawn)))
		SSspawning.spawnerdata[src].required_increment = 2 * max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER)/SSspawning.wait
		SSspawning.spawnerdata[src].max_allowed_mobs = max(1, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count * 0.5)
	update_minimap_icon()

	if(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN)
		SSaura.add_emitter(src, AURA_XENO_RECOVERY, 30, 4, -1, FACTION_XENO, hivenumber)
		SSaura.add_emitter(src, AURA_XENO_WARDING, 30, 4, -1, FACTION_XENO, hivenumber)
		SSaura.add_emitter(src, AURA_XENO_FRENZY, 30, 4, -1, FACTION_XENO, hivenumber)

	return INITIALIZE_HINT_LATELOAD

/obj/structure/xeno/silo/LateInitialize()
	. = ..()
	if(!(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN))
		QDEL_NULL(proximity_monitor)
	number_silo = length(GLOB.xeno_resin_silos_by_hive[hivenumber]) + 1
	name = "[name] [number_silo]"
	LAZYADDASSOC(GLOB.xeno_resin_silos_by_hive, hivenumber, src)

	if(!locate(/obj/alien/weeds) in loc)
		new /obj/alien/weeds/node(loc)
	if(GLOB.hive_datums[hivenumber])
		RegisterSignals(GLOB.hive_datums[hivenumber], list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), PROC_REF(is_burrowed_larva_host))
		if(length(GLOB.xeno_resin_silos_by_hive[hivenumber]) == 1)
			GLOB.hive_datums[hivenumber].give_larva_to_next_in_queue()
	var/turf/tunnel_turf = get_step(src, NORTH)
	if(tunnel_turf.can_dig_xeno_tunnel())
		var/obj/structure/xeno/tunnel/newt = new(tunnel_turf, hivenumber)
		newt.tunnel_desc = "[AREACOORD_NO_Z(newt)]"
		newt.name += " [name]"

/obj/structure/xeno/silo/obj_break(damage_flag)
	if(length(GLOB.xeno_resin_silos_by_hive[hivenumber]) == 1)
		obj_integrity = max_integrity
		GLOB.hive_datums[hivenumber].trigger_silo_shock(src)
		return
	obj_integrity = 0
	. = ..()

/obj/structure/xeno/silo/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	if(GLOB.hive_datums[hivenumber])
		UnregisterSignal(GLOB.hive_datums[hivenumber], list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))
		GLOB.hive_datums[hivenumber].xeno_message("A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, FALSE, loc, 'sound/voice/alien/help2.ogg',FALSE , null, /atom/movable/screen/arrow/silo_damaged_arrow)
		notify_ghosts("\ A resin silo has been destroyed at [AREACOORD_NO_Z(src)]!", source = get_turf(src), action = NOTIFY_JUMP)
		playsound(loc,'sound/effects/alien/egg_burst.ogg', 75)
	return ..()

/obj/structure/xeno/silo/Destroy()
	GLOB.xeno_resin_silos_by_hive[hivenumber] -= src

	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(get_step(src, pick(CARDINAL_ALL_DIRS)))

	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/silo/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			. += span_warning("It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.")
		if(20 to 40)
			. += span_warning("It looks severely damaged, its movements slow.")
		if(40 to 60)
			. += span_warning("It's quite beat up, but it seems alive.")
		if(60 to 80)
			. += span_warning("It's slightly damaged, but still seems healthy.")
		if(80 to 100)
			. += span_info("It appears in good shape, pulsating healthily.")

//*******************
//Corpse recyclinging and larva force burrow
//*******************
/obj/structure/xeno/silo/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I
	if(!iscarbon(G.grabbed_thing))
		return
	var/mob/living/carbon/victim = G.grabbed_thing
	if(!ishuman(victim) && !isxenolarva(victim)) //humans and monkeys only for now
		to_chat(user, "<span class='notice'>[src] can only process humanoid anatomies or larvas!</span>")
		return

	if(ishuman(victim))
		if(victim.stat != DEAD)
			to_chat(user, "<span class='notice'>[victim] is not dead!</span>")
			return
		if(!HAS_TRAIT(victim, TRAIT_UNDEFIBBABLE) && !ismonkey(victim))
			to_chat(user, "<span class='notice'>[victim] is not unrevivable yet, this might make problems.</span>")
			return

		if(issynth(victim))
			to_chat(user, "<span class='notice'>[victim] has no useful biomass for us.</span>")
			return

		visible_message("[user] starts putting [victim] into [src].", 3)

		if(!do_after(user, 20, FALSE, victim, BUSY_ICON_DANGER) || QDELETED(src))
			return

		victim.despawn() //basically gore cryo

		shake(4 SECONDS)

		var/datum/job/xeno_job = SSjob.GetJobType(GLOB.hivenumber_to_job_type[hivenumber])
		xeno_job.add_job_points(4.5) //4.5 corpses per burrowed; 8 points per larva

		log_combat(victim, user, "was consumed by a resin silo")
		log_game("[key_name(victim)] was consumed by a resin silo at [AREACOORD(victim.loc)].")

	else
		if(isxenolarva(victim))
			if(victim.stat == DEAD)
				to_chat(user, "<span class='notice'>[victim] is dead!</span>")
				return
			var/mob/living/carbon/xenomorph/larva/larba = G.grabbed_thing
			if(isxenolarva(larba))
				if(!larba.issamexenohive(user))
					to_chat(user, "<span class='notice'>[larba] is not of our hive!</span>")
					return

			visible_message("[user] starts making [victim] burrow into [src].", 3)

			if(!do_after(user, 1 SECONDS, FALSE, victim, BUSY_ICON_DANGER) || QDELETED(src))
				return

			larba.ghostize(FALSE, FALSE, TRUE)
			larba.burrow()
			shake(4 SECONDS)

/// Make the silo shake
/obj/structure/xeno/silo/proc/shake(duration)
	/// How important should be the shaking movement
	var/offset = prob(50) ? -2 : 2
	/// Track the last position of the silo for the animation
	var/old_pixel_x = pixel_x
	/// Sound played when shaking
	var/shake_sound = rand(1, 100) == 1 ? 'sound/machines/blender.ogg' : 'sound/machines/juicer.ogg'
	if(prob(1))
		playsound(src, shake_sound, 25, TRUE)
	animate(src, pixel_x = pixel_x + offset, time = 2, loop = -1) //start shaking
	addtimer(CALLBACK(src, PROC_REF(stop_shake), old_pixel_x), duration)

/// Stop the shaking animation
/obj/structure/xeno/silo/proc/stop_shake(old_px)
	animate(src)
	pixel_x = old_px

/obj/structure/xeno/silo/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob, silent)
	. = ..()
	//We took damage, so it's time to start regenerating if we're not already processing
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

/obj/structure/xeno/silo/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, GLOB.hivenumber_to_minimap_flag[hivenumber], image('icons/UI_icons/map_blips.dmi', null, "silo[threat_warning ? "_warn" : "_passive"]", MINIMAP_LABELS_LAYER))

/obj/structure/xeno/silo/process()
	//Regenerate if we're at less than max integrity
	if(obj_integrity < max_integrity)
		obj_integrity = min(obj_integrity + 25, max_integrity) //Regen 5 HP per sec

/obj/structure/xeno/silo/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	SIGNAL_HANDLER
	if(GLOB.hive_datums[hivenumber])
		silos += src

/// Transfers the spawned minion to the silo's hivenumber.
/obj/structure/xeno/silo/proc/on_spawn(list/newly_spawned_things)
	for(var/mob/living/carbon/xenomorph/spawned_minion AS in newly_spawned_things)
		spawned_minion.transfer_to_hive(hivenumber)

/obj/structure/xeno/silo/MouseDrop_T(mob/M, mob/user)
	. = ..()
	if(isxeno(user))
		if(M == user)
			if(isxenolarva(user))
				if(user.stat == DEAD)
					to_chat(user, span_xenonotice("We are... dead?"))
					return
				var/mob/living/carbon/xenomorph/larva/larba = user

				visible_message("[user] starts burrowing into [src].", 3)

				if(!do_after(user, 1 SECONDS, FALSE, user, BUSY_ICON_DANGER) || QDELETED(src))
					return

				larba.ghostize(FALSE, FALSE, TRUE)
				larba.burrow()
				shake(4 SECONDS)

			else
				to_chat(user, span_xenonotice("We need to be a larva to fit there."))
