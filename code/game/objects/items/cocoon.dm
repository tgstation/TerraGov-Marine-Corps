/obj/structure/cocoon
	name = "resin cocoon"
	desc = "A slimy-looking cocoon made out of resin. It is vibrating."
	icon = 'icons/obj/cocoon.dmi'
	icon_state = "xeno_cocoon"
	density = FALSE
	layer = BELOW_OBJ_LAYER
	hit_sound = 'sound/effects/alien/resin_break2.ogg'
	max_integrity = 400
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	resistance_flags = UNACIDABLE
	/// Which hive do we belong to?
	var/hivenumber
	/// Who is inside the cocoon?
	var/mob/living/victim
	/// The amount of deciseconds the victim will be in the cocoon.
	var/cocoon_life_time = 5 SECONDS
	/// The timer ID for the proc that calls when the cocoon's time has elapsed.
	var/cocoon_timer_id
	/// Is someone interacting with us right now?
	var/busy = FALSE
	/// How much larva points does it reward the owner hive after [cocoon_life_time] amount of time elapsed?
	var/larva_point_reward = 1.5

/obj/structure/cocoon/Initialize(mapload, _hivenumber, mob/living/_victim)
	. = ..()
	if(!_hivenumber || !_victim)
		return
	hivenumber = _hivenumber
	victim = _victim
	victim.forceMove(src)
	START_PROCESSING(SSslowprocess, src)
	cocoon_timer_id = addtimer(CALLBACK(src, PROC_REF(life_draining_over), null, TRUE), cocoon_life_time, TIMER_UNIQUE|TIMER_STOPPABLE)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(on_hijack))
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(on_shuttle_crush))

/obj/structure/cocoon/Destroy()
	if(cocoon_timer_id)
		deltimer(cocoon_timer_id)
		cocoon_timer_id = null
	if(victim)
		release_victim()
	return ..()

/obj/structure/cocoon/examine(mob/user)
	. = ..()
	if(victim && ishuman(user))
		. += span_notice("There seems to be someone inside it. You think you can open it with a sharp object.")

/obj/structure/cocoon/process(seconds_per_tick)
	if(!QDELETED(victim))
		// Each second gives 0.1 clone loss. 5 minutes = 30 cloneloss.
		victim.adjustCloneLoss(0.1 * seconds_per_tick)
		// No "lifeforce" to drain = no points.
		if(iszombie(victim))
			return

	var/psych_points_output = COCOON_PSY_POINTS_REWARD_MIN + ((HIGH_PLAYER_POP - SSmonitor.maximum_connected_players_count) / HIGH_PLAYER_POP * (COCOON_PSY_POINTS_REWARD_MAX - COCOON_PSY_POINTS_REWARD_MIN))
	psych_points_output = clamp(psych_points_output, COCOON_PSY_POINTS_REWARD_MIN, COCOON_PSY_POINTS_REWARD_MAX)
	psych_points_output *= seconds_per_tick
	SSpoints.add_strategic_psy_points(hivenumber, psych_points_output)
	SSpoints.add_tactical_psy_points(hivenumber, psych_points_output * 0.25)

/obj/structure/cocoon/update_icon_state()
	. = ..()
	if(anchored)
		icon_state = "xeno_cocoon"
		return
	if(victim)
		icon_state = "xeno_cocoon_unnested"
		return
	icon_state = "xeno_cocoon_open"

/obj/structure/cocoon/attacked_by(obj/item/attacking_item, mob/living/user, def_zone)
	if(!anchored && victim)
		if(busy)
			return
		if(!attacking_item.sharp)
			return
		busy = TRUE
		var/channel = SSsounds.random_available_channel()
		playsound(user, "sound/effects/cutting_cocoon.ogg", 30, channel = channel)
		if(!do_after(user, 8 SECONDS, NONE, src))
			busy = FALSE
			user.stop_sound_channel(channel)
			return
		busy = FALSE
		release_victim()
		update_icon()
		return
	return ..()

/obj/structure/cocoon/can_be_pulled(user, force)
	if(isxeno(user) && victim)
		return FALSE
	return ..()

/obj/structure/cocoon/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(anchored && obj_integrity < max_integrity / 2)
		unanchor_from_nest()

/// Allows the cocoon to be opened and dragged.
/obj/structure/cocoon/proc/unanchor_from_nest()
	new /obj/structure/bed/nest(loc)
	anchored = FALSE
	update_icon()
	playsound(loc, SFX_ALIEN_RESIN_MOVE, 35)

/// Stop producing points and release the victim if needed.
/obj/structure/cocoon/proc/life_draining_over(datum/source, must_release_victim = FALSE)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSslowprocess, src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED)
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

/// On hijack, stops psychic point generation and changes larva point reward
/// as we don't want to carry over any points from groundside -> shipside.
/obj/structure/cocoon/proc/on_hijack(datum/source)
	SIGNAL_HANDLER
	if(is_ground_level(z))
		larva_point_reward = 0 // We'll still time out as usual, but there is no reward at the end.
	life_draining_over(source)

/// Releases and gibs the victim if we get shuttle crushed.
/obj/structure/cocoon/proc/on_shuttle_crush(datum/source, obj/docking_port/mobile/shuttle)
	SIGNAL_HANDLER
	release_victim(TRUE)

/// Open the cocoon and move the victim out.
/obj/structure/cocoon/proc/release_victim(gib = FALSE)
	STOP_PROCESSING(SSslowprocess, src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED)
	UnregisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH)
	if(cocoon_timer_id)
		deltimer(cocoon_timer_id)
		cocoon_timer_id = null
	playsound(loc, SFX_ALIEN_RESIN_MOVE, 35)
	if(!QDELETED(victim)) // Since zombies can be cocooned, odds are that they're deleted.
		REMOVE_TRAIT(victim, TRAIT_STASIS, TRAIT_STASIS)
		victim.forceMove(loc)
		victim.setDir(NORTH)
		victim.med_hud_set_status()
		if(gib)
			victim.gib()
	victim = null

/obj/structure/cocoon/opened_cocoon
	icon_state = "xeno_cocoon_open"
	anchored = FALSE

/obj/structure/cocoon/opened_cocoon/Initialize(mapload)
	. = ..()
	new /obj/structure/bed/nest(loc)
