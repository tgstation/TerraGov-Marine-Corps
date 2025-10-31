/datum/looping_sound/femhornylite
	mid_sounds = list('ntf_modular/sound/vo/female/gen/se/horny1loop (1).ogg')
	mid_length = 470
	volume = 20
	range = 7

/datum/looping_sound/femhornylitealt
	mid_sounds = list('ntf_modular/sound/vo/female/gen/se/horny1loop (2).ogg')
	mid_length = 360
	volume = 20
	range = 7

/datum/looping_sound/femhornymed
	mid_sounds = list('ntf_modular/sound/vo/female/gen/se/horny2loop (1).ogg')
	mid_length = 420
	volume = 20
	range = 7

/datum/looping_sound/femhornymedalt
	mid_sounds = list('ntf_modular/sound/vo/female/gen/se/horny2loop (2).ogg')
	mid_length = 350
	volume = 20
	range = 7

/datum/looping_sound/femhornyhvy
	mid_sounds = list('ntf_modular/sound/vo/female/gen/se/horny3loop (1).ogg')
	mid_length = 440
	volume = 20
	range = 7

/datum/looping_sound/femhornyhvyalt
	mid_sounds = list('ntf_modular/sound/vo/female/gen/se/horny3loop (2).ogg')
	mid_length = 390
	volume = 20
	range = 7

/mob/living/verb/erp_panel()
	set category = "IC"
	set name = "ERP Panel"
	set desc = "Fuck 'em"
	set src in view(1)
	erptime(usr, src)

/mob/living/proc/erptime(mob/living/user, mob/living/target)
	if(!istype(target))
		return
	var/datum/sex_controller/usersexcon = user.sexcon
	usersexcon.start(target)

/* obsolete now
/mob/living/verb/Climax()
	set name = "Climax"
	set category = "IC"
	if(stat != DEAD)
		var/channel = SSsounds.random_available_channel()
		if(length(usr.do_actions))
			return
		playsound(usr, "sound/effects/squelch2.ogg", 30, channel = channel)
		if(!do_after(usr, 10 SECONDS, TRUE, usr, BUSY_ICON_GENERIC))
			usr?.balloon_alert(usr, "Interrupted")
			usr.stop_sound_channel(channel)
			return
		if(!usr)
			usr.stop_sound_channel(channel)
			return
		usr.emote("moan")
		usr.visible_message(span_warning("[usr] cums!"), span_warning("You cum."), span_warning("You hear a splatter."), 5)
		usr.balloon_alert(usr, "Orgasmed.")
		if(!isrobot(usr))
			if(usr.gender == MALE)
				new /obj/effect/decal/cleanable/blood/splatter/cum(usr.loc)
			else
				new /obj/effect/decal/cleanable/blood/splatter/girlcum(usr.loc)
		else
			new /obj/effect/decal/cleanable/blood/splatter/robotcum(usr.loc)
		if(isxeno(usr))
			new /obj/effect/decal/cleanable/blood/splatter/xenocum(usr.loc)
		playsound(usr.loc, "sound/effects/splat.ogg", 30)
		usr.reagents.remove_reagent(/datum/reagent/toxin/xeno_aphrotoxin, 4) // Remove aphrotoxin cause orgasm. Less than when you resist because takes shorter.
	else
		to_chat(usr, span_warning("You must be living to do that."))
		return
*/

/mob/living/proc/make_sucking_noise()
	if(gender == FEMALE)
		playsound(src, pick('ntf_modular/sound/misc/mat/girlmouth (1).ogg','ntf_modular/sound/misc/mat/girlmouth (2).ogg'), 25, TRUE, 7, ignore_walls = FALSE)
	else
		playsound(src, pick('ntf_modular/sound/misc/mat/guymouth (1).ogg','ntf_modular/sound/misc/mat/guymouth (2).ogg','ntf_modular/sound/misc/mat/guymouth (3).ogg','ntf_modular/sound/misc/mat/guymouth (4).ogg','ntf_modular/sound/misc/mat/guymouth (5).ogg'), 35, TRUE, 7, ignore_walls = FALSE)

/mob/living/proc/get_highest_grab_state_on(mob/living/victim)
	if(victim.pulledby == src)
		return TRUE
	return FALSE

/proc/add_cum_floor(turfu)
	if(!turfu || !isturf(turfu))
		return
	new /obj/effect/decal/cleanable/blood/splatter/cum(turfu)

//adds larva to a host.
/mob/living/carbon/xenomorph/proc/impregify(mob/living/carbon/victim, overrideflavor, maxlarvas = MAX_LARVA_PREGNANCIES, damaging = TRUE, damagemult = 1, damageloc = BODY_ZONE_PRECISE_GROIN)
	if(!istype(victim))
		return
	victim.reagents.remove_reagent(/datum/reagent/toxin/xeno_aphrotoxin, 10)
	if(damaging)
		new /obj/effect/decal/cleanable/blood/splatter/xenocum(loc)
		var/aciddamagetodeal = 5
		var/impregdamagetodeal = (xeno_caste.melee_damage * xeno_melee_damage_modifier) / 6
		if(damagemult > 0)
			aciddamagetodeal *= damagemult
			impregdamagetodeal *= damagemult
		victim.apply_damage(aciddamagetodeal, BURN, damageloc, updating_health = TRUE)
		victim.apply_damage(impregdamagetodeal, BRUTE, damageloc, updating_health = TRUE)
		if(ismonkey(victim))
			victim.apply_damage(impregdamagetodeal, BRUTE, damageloc, updating_health = TRUE)
	var/implanted_embryos = 0
	for(var/obj/item/alien_embryo/implanted in victim.contents)
		implanted_embryos++
		if(implanted_embryos >= maxlarvas)
			to_chat(src, span_warning("We came but this host is already full of young ones."))
			return
	if(victim.stat == DEAD)
		to_chat(src, span_warning("We impregnate \the [victim] with a dormant larva."))
	var/obj/item/alien_embryo/embryo = new(victim)
	if(prob(5))
		to_chat(src, span_warning("We sense we impregnated \the [victim] with TWINS!."))
		var/obj/item/alien_embryo/embryo2 = new(victim)
		embryo2.hivenumber = hivenumber
		if(overrideflavor == "mouth")
			embryo2.emerge_target = 1
			embryo2.emerge_target_flavor = "mouth"
		else
			if(!overrideflavor)
				if(victim.gender==FEMALE)
					embryo2.emerge_target = 2
					embryo2.emerge_target_flavor = "pussy"
				else
					embryo2.emerge_target = 3
					embryo2.emerge_target_flavor = "ass"
			else
				embryo2.emerge_target = 4
				embryo2.emerge_target_flavor = overrideflavor
		GLOB.round_statistics.now_pregnant++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "now_pregnant")
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
		personal_statistics.impregnations++
	embryo.hivenumber = hivenumber
	if(overrideflavor == "mouth")
		embryo.emerge_target = 1
		embryo.emerge_target_flavor = "mouth"
	else
		if(!overrideflavor)
			if(victim.gender==FEMALE)
				embryo.emerge_target = 2
				embryo.emerge_target_flavor = "pussy"
			else
				embryo.emerge_target = 3
				embryo.emerge_target_flavor = "ass"
		else
			embryo.emerge_target = 4
			embryo.emerge_target_flavor = overrideflavor
	GLOB.round_statistics.now_pregnant++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "now_pregnant")
	var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[ckey]
	personal_statistics.impregnations++
	if(HAS_TRAIT(victim, TRAIT_HIVE_TARGET))
		var/psy_points_reward = PSY_DRAIN_REWARD_MIN + ((HIGH_PLAYER_POP - SSmonitor.maximum_connected_players_count) / HIGH_PLAYER_POP * (PSY_DRAIN_REWARD_MAX - PSY_DRAIN_REWARD_MIN))
		psy_points_reward = clamp(psy_points_reward, PSY_DRAIN_REWARD_MIN, PSY_DRAIN_REWARD_MAX)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HIVE_TARGET_DRAINED, src, victim)
		psy_points_reward = psy_points_reward * 5
		SSpoints.add_strategic_psy_points(hivenumber, psy_points_reward)
		SSpoints.add_tactical_psy_points(hivenumber, psy_points_reward*0.25)
		GLOB.round_statistics.strategic_psypoints_from_hive_target_rewards += psy_points_reward
		GLOB.round_statistics.hive_target_rewards++
		GLOB.round_statistics.biomass_from_hive_target_rewards += MUTATION_BIOMASS_PER_HIVE_TARGET_REWARD
		SSpoints.add_biomass_points(hivenumber, MUTATION_BIOMASS_PER_HIVE_TARGET_REWARD)
		var/datum/job/xeno_job = SSjob.GetJobType(GLOB.hivenumber_to_job_type[hivenumber])
		xeno_job.add_job_points(1) //can be made a var if need be.
		hive.update_tier_limits()

/mob/living/carbon/xenomorph/proc/xenoimpregify()
	if(!preggo)
		to_chat(src, span_alien("We feel a new larva forming within us."))
		addtimer(CALLBACK(src, PROC_REF(xenobirth)), 5 MINUTES)
		preggo = TRUE
		return TRUE

/mob/living/carbon/xenomorph/proc/xenobirth()
	preggo = FALSE
	GLOB.round_statistics.total_larva_burst++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_larva_burst")
	playsound(src, pick('sound/voice/alien/chestburst.ogg','sound/voice/alien/chestburst2.ogg'), 10, FALSE, 7, ignore_walls = FALSE)
	visible_message(span_warning("a larva drops out of [usr]'s cunt and burrows away!"), span_warning("a larva drops out of our cunt and burrows away."), span_warning("You hear a splatter."), 5)
	var/datum/job/xeno_job = SSjob.GetJobType(GLOB.hivenumber_to_job_type[hivenumber])
	xeno_job.add_job_points(1) //can be made a var if need be.
	hive.update_tier_limits()
