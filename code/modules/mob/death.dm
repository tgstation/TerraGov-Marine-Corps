//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	gib_animation()
	spawn_gibs()
	death(TRUE)


/mob/proc/gib_animation()
	return

/mob/proc/spawn_gibs()
	hgibs(loc)





//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust()
	dust_animation()
	spawn_dust_remains()
	death(TRUE)


/mob/proc/spawn_dust_remains()
	new /obj/effect/decal/cleanable/ash(loc)

/mob/proc/dust_animation()
	return



/mob/proc/death(gibbing, deathmessage = "seizes up and falls limp...", silent)
	if(stat == DEAD)
		if(gibbing)
			qdel(src)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src)
	SEND_SIGNAL(src, COMSIG_MOB_DEATH, gibbing)
	log_combat(src, src, "[deathmessage]")

	if(deathmessage && !silent && !gibbing)
		visible_message("<b>\The [name]</b> [deathmessage]")

	set_stat(DEAD)

	if(!QDELETED(src) && gibbing)
		qdel(src)


/mob/proc/on_death()
	SHOULD_CALL_PARENT(TRUE) // no exceptions
	client?.change_view(WORLD_VIEW) //just so we never get stuck with a large view somehow

	hide_fullscreens()

	update_sight()

	drop_r_hand()
	drop_l_hand()

	if(hud_used && hud_used.healths)
		hud_used.healths.icon_state = "health7"

	timeofdeath = world.time
	if(mind)
		mind.store_memory("Time of death: [worldtime2text()]", 0)
		if(mind.active && is_gameplay_level(z))
			var/turf/T = get_turf(src)
			deadchat_broadcast(" has died at <b>[get_area_name(T)]</b>.", "<b>[mind.name]</b>", follow_target = src, turf_target = T, message_type = DEADCHAT_DEATHRATTLE)

	GLOB.dead_mob_list |= src
	GLOB.offered_mob_list -= src

	med_pain_set_perceived_health()
	med_hud_set_health()
	med_hud_set_status()

	update_icons()

	if(SSticker.HasRoundStarted())
		SSblackbox.ReportDeath(src)
