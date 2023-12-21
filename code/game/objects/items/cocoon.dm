/obj/structure/cocoon
	name = "resin cocoon"
	desc = "A slimy-looking cocoon made out of resin. It is vibrating."
	icon = 'icons/obj/cocoon.dmi'
	icon_state = "xeno_cocoon"
	density = FALSE
	layer = BELOW_OBJ_LAYER
	hit_sound = 'sound/effects/alien_resin_break2.ogg'
	max_integrity = 400
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	resistance_flags = UNACIDABLE
	///Which hive it belongs too
	var/hivenumber
	///What is inside the cocoon
	var/mob/living/victim
	///How much time the cocoon takes to deplete the life force of the marine
	var/cocoon_life_time = 5 MINUTES
	///Standard busy check
	var/busy = FALSE
	///How much larva points it gives at the end of its life time (8 points for one larva in distress)
	var/larva_point_reward = 1.5


/obj/structure/cocoon/Initialize(mapload, _hivenumber, mob/living/_victim)
	. = ..()
	if(!_hivenumber)
		return
	hivenumber = _hivenumber
	victim = _victim
	victim.forceMove(src)
	START_PROCESSING(SSslowprocess, src)
	addtimer(CALLBACK(src, PROC_REF(life_draining_over), null, TRUE), cocoon_life_time)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(life_draining_over))
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(on_shuttle_crush))

/obj/structure/cocoon/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(anchored && victim && ishuman(user))
		. += span_notice("There seems to be someone inside it. You think you can open it with a sharp object.")

/obj/structure/cocoon/process()
	var/psych_points_output = COCOON_PSY_POINTS_REWARD_MIN + ((HIGH_PLAYER_POP - SSmonitor.maximum_connected_players_count) / HIGH_PLAYER_POP * (COCOON_PSY_POINTS_REWARD_MAX - COCOON_PSY_POINTS_REWARD_MIN))
	psych_points_output = clamp(psych_points_output, COCOON_PSY_POINTS_REWARD_MIN, COCOON_PSY_POINTS_REWARD_MAX)
	SSpoints.add_psy_points(hivenumber, psych_points_output)
	//Gives marine cloneloss for a total of 30.
	victim.adjustCloneLoss(0.5)

/obj/structure/cocoon/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	if(anchored && obj_integrity < max_integrity / 2)
		unanchor_from_nest()

///Allow the cocoon to be opened and dragged
/obj/structure/cocoon/proc/unanchor_from_nest()
	new /obj/structure/bed/nest(loc)
	anchored = FALSE
	update_icon()
	playsound(loc, "alien_resin_move", 35)

///Stop producing points and release the victim if needed
/obj/structure/cocoon/proc/life_draining_over(datum/source, must_release_victim = FALSE)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSslowprocess, src)
	if(anchored)
		unanchor_from_nest()
	if(must_release_victim)
		var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
		xeno_job.add_job_points(larva_point_reward)
		var/datum/hive_status/hive_status = GLOB.hive_datums[hivenumber]
		hive_status.update_tier_limits()
		GLOB.round_statistics.larva_from_cocoon += larva_point_reward / xeno_job.job_points_needed
		release_victim()
	update_icon()

/obj/structure/cocoon/Destroy()
	if(victim)
		release_victim()
	return ..()

/// Signal proc, makes sure the victim gets gibbed if a shuttle lands on the cocoon
/obj/structure/cocoon/proc/on_shuttle_crush(datum/source, obj/docking_port/mobile/shuttle)
	SIGNAL_HANDLER
	release_victim(TRUE)

///Open the cocoon and move the victim out
/obj/structure/cocoon/proc/release_victim(gib = FALSE)
	REMOVE_TRAIT(victim, TRAIT_STASIS, TRAIT_STASIS)
	playsound(loc, "alien_resin_move", 35)
	victim.forceMove(loc)
	victim.setDir(NORTH)
	victim.med_hud_set_status()
	if(gib)
		victim.gib()
	victim = null
	STOP_PROCESSING(SSslowprocess, src)

/obj/structure/cocoon/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!anchored && victim)
		if(busy)
			return
		if(!I.sharp)
			return
		busy = TRUE
		var/channel = SSsounds.random_available_channel()
		playsound(user, "sound/effects/cutting_cocoon.ogg", 30, channel = channel)
		if(!do_after(user, 8 SECONDS, NONE, src))
			busy = FALSE
			user.stop_sound_channel(channel)
			return
		release_victim()
		update_icon()
		busy = FALSE
		return
	return ..()

/obj/structure/cocoon/update_icon_state()
	if(anchored)
		icon_state = "xeno_cocoon"
		return
	if(victim)
		icon_state = "xeno_cocoon_unnested"
		return
	icon_state = "xeno_cocoon_open"

/obj/structure/cocoon/opened_cocoon
	icon_state = "xeno_cocoon_open"
	anchored = FALSE

/obj/structure/cocoon/opened_cocoon/Initialize(mapload)
	. = ..()
	new /obj/structure/bed/nest(loc)
