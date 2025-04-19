/// Applies several debuffs to eligible targets in a given area of effect.
/proc/wraith_teleport_effect(atom/owner, turf/T, range = 1, stagger = 1, slowdown = 1)
	if(!owner || !T)
		CRASH("wraith_teleport_effect(): invalid args")
	new /obj/effect/temp_visual/wraith_warp(T)
	playsound(T, 'sound/effects/EMPulse.ogg', 25, 1)
	if(!range)
		return
	for(var/turf/turf_to_check AS in RANGE_TURFS(range, T))
		for(var/mob/mob_target AS in turf_to_check)
			if(!isliving(mob_target) || mob_target.stat == DEAD)
				continue
			if(isxeno(mob_target))
				var/mob/living/carbon/xenomorph/xeno_target = mob_target
				if(xeno_target.issamexenohive(owner))
					continue
			var/mob/living/living_target = mob_target
			if(stagger)
				living_target.adjust_stagger(stagger)
			if(slowdown)
				living_target.add_slowdown(slowdown)


// ***************************************
// *********** Wraith's Blink
// ***************************************
#define WRAITH_BLINK_RANGE 3
#define WRAITH_BLINK_EFFECT_RADIUS 1 // in tiles
#define WRAITH_BLINK_STAGGER 1 // in stacks
#define WRAITH_BLINK_SLOWDOWN 1 // in stacks
#define WRAITH_BLINK_PASS_FLAGS (PASS_LOW_STRUCTURE|PASS_GLASS|PASS_GRILLE|PASS_MOB|PASS_FIRE|PASS_XENO|PASS_PROJECTILE)

/datum/action/ability/activable/xeno/wraith_blink
	name = "Blink"
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "blink"
	desc = "Teleport a short distance towards a target location within sight."
	ability_cost = 30
	cooldown_duration = 4 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_WRAITH_BLINK,
	)
	/// Stores the turf from which we used this ability.
	var/turf/old_turf

/datum/action/ability/activable/xeno/wraith_blink/remove_action(mob/living/L)
	if(old_turf)
		clean_up()
	return ..()

/datum/action/ability/activable/xeno/wraith_blink/on_cooldown_finish()
	. = ..()
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

/datum/action/ability/activable/xeno/wraith_blink/use_ability(atom/target)
	. = ..()
	if(xeno_owner.buckled)
		xeno_owner.buckled.unbuckle_mob(xeno_owner, TRUE)
	old_turf = xeno_owner.loc
	RegisterSignal(old_turf, COMSIG_QDELETING, PROC_REF(clean_up))
	xeno_owner.add_pass_flags(WRAITH_BLINK_PASS_FLAGS, WRAITH_BLINK_TRAIT)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_ended))
	xeno_owner.throw_at(target, WRAITH_BLINK_RANGE, WRAITH_BLINK_RANGE, xeno_owner)
	add_cooldown()
	succeed_activate()
	GLOB.round_statistics.wraith_blinks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_blinks")

/datum/action/ability/activable/xeno/wraith_blink/clean_action()
	if(old_turf)
		clean_up()
	return ..()

/// Handles anything that would happen when this ability's throw ends.
/datum/action/ability/activable/xeno/wraith_blink/proc/throw_ended(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW)
	xeno_owner.remove_pass_flags(WRAITH_BLINK_PASS_FLAGS, WRAITH_BLINK_TRAIT)
	wraith_teleport_effect(xeno_owner, xeno_owner.loc, WRAITH_BLINK_EFFECT_RADIUS, WRAITH_BLINK_STAGGER, WRAITH_BLINK_SLOWDOWN)
	if(old_turf)
		old_turf.beam(xeno_owner.loc, "sm_arc", time = 2)
		clean_up()

/// Cleans up after the ability and clears refs.
/datum/action/ability/activable/xeno/wraith_blink/proc/clean_up(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(old_turf, COMSIG_QDELETING)
	old_turf = null


// ***************************************
// *********** Wraith's Rewind
// ***************************************
#define WRAITH_REWIND_RESET_TIME 4 SECONDS
#define WRAITH_REWIND_MAX_CHECK 10 // How far we'll go to check for a valid turf.
#define WRAITH_REWIND_EFFECT_RADIUS 1 // in tiles
#define WRAITH_REWIND_STAGGER 2 // in stacks
#define WRAITH_REWIND_SLOWDOWN 2 // in stacks

/datum/action/ability/xeno_action/wraith_rewind
	name = "Rewind"
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "rewind"
	desc = "Return to the location you were in a few seconds ago."
	ability_cost = 100
	cooldown_duration = 20 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_WRAITH_REWIND
	)
	/// The turf we will rewind to.
	var/turf/rewind_loc
	/// Contains the reset timer, after which expiry a new location to rewind to will be set.
	var/reset_timer
	/// Holds the image that serves as a unique indicator of where we can rewind to.
	var/image/indicator_holder = null

/datum/action/ability/xeno_action/wraith_rewind/New(Target)
	. = ..()
	desc = "Return to the location you were in [WRAITH_REWIND_RESET_TIME / 10] seconds ago."

/datum/action/ability/xeno_action/wraith_rewind/give_action(mob/living/L)
	. = ..()
	action_setup()

/datum/action/ability/xeno_action/wraith_rewind/remove_action(mob/living/L)
	clean_up()
	return ..()

/datum/action/ability/xeno_action/wraith_rewind/action_activate()
	. = ..()
	if(!.)
		return
	if(!wraith_tile_check(rewind_loc))
		for(var/i in 1 to WRAITH_REWIND_MAX_CHECK)
			for(var/turf/turf_to_check AS in RANGE_TURFS(i, rewind_loc))
				if(wraith_tile_check(turf_to_check))
					rewind_loc = turf_to_check
					break
			xeno_owner.balloon_alert(xeno_owner, "Unable to rewind")
			return
	if(xeno_owner.buckled)
		xeno_owner.buckled.unbuckle_mob(xeno_owner, TRUE)
	var/turf/old_turf = xeno_owner.loc
	xeno_owner.forceMove(rewind_loc)
	old_turf.beam(rewind_loc, "nzcrentrs_power", time = 2)
	wraith_teleport_effect(xeno_owner, rewind_loc, WRAITH_REWIND_EFFECT_RADIUS, WRAITH_REWIND_STAGGER, WRAITH_REWIND_SLOWDOWN)
	add_cooldown()
	succeed_activate()
	GLOB.round_statistics.wraith_rewinds++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_rewinds")

/datum/action/ability/xeno_action/wraith_rewind/clean_action()
	clean_up()
	return ..()

/// Sets up the action for usage.
/datum/action/ability/xeno_action/wraith_rewind/proc/action_setup(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(owner_death))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED, PROC_REF(clean_up))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(rewind_setup))
	rewind_setup()

/// Cleans up after the ability and its references.
/datum/action/ability/xeno_action/wraith_rewind/proc/clean_up(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED)
	if(rewind_loc)
		UnregisterSignal(rewind_loc, COMSIG_QDELETING)
		rewind_loc = null
	if(reset_timer)
		deltimer(reset_timer)
	if(indicator_holder)
		QDEL_NULL(indicator_holder)

/// Handles any events that happen as a result of the owner's death.
/datum/action/ability/xeno_action/wraith_rewind/proc/owner_death(datum/source, gibbing)
	SIGNAL_HANDLER
	clean_up()
	RegisterSignal(xeno_owner, COMSIG_MOB_REVIVE, PROC_REF(action_setup))

/// Sets up everything needed for the activation of this ability.
/datum/action/ability/xeno_action/wraith_rewind/proc/rewind_setup(datum/source)
	SIGNAL_HANDLER
	var/turf/T = get_turf(xeno_owner)
	if(!wraith_tile_check(T))
		RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(reattempt_rewind_setup))
		return
	if(rewind_loc != T)
		if(rewind_loc)
			UnregisterSignal(rewind_loc, COMSIG_QDELETING)
		rewind_loc = T
		RegisterSignal(rewind_loc, COMSIG_QDELETING, PROC_REF(rewind_setup))
	visuals_setup(rewind_loc)
	reset_timer = addtimer(CALLBACK(src, PROC_REF(rewind_setup)), WRAITH_REWIND_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/// Checks if the passed tile is valid for this ability.
/datum/action/ability/xeno_action/wraith_rewind/proc/wraith_tile_check(turf/T)
	if(turf_block_check(xeno_owner, T, ignore_invulnerable = TRUE) || isspacearea(get_area(T)))
		return FALSE
	if(IS_OPAQUE_TURF(T))
		return FALSE
	return TRUE

/// Attempts to setup rewind again.
/datum/action/ability/xeno_action/wraith_rewind/proc/reattempt_rewind_setup(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED)
	rewind_setup()

/// Setups visuals for this ability.
/datum/action/ability/xeno_action/wraith_rewind/proc/visuals_setup(turf/T)
	if(indicator_holder)
		indicator_holder.loc = T
		indicator_holder.dir = xeno_owner.dir
		if(xeno_owner.client && !(indicator_holder in xeno_owner.client.images))
			xeno_owner.client.images += indicator_holder
		return
	indicator_holder = image(loc = T)
	indicator_holder.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SET_PLANE_EXPLICIT(indicator_holder, SEETHROUGH_PLANE, xeno_owner)
	animate(indicator_holder, appearance = xeno_owner.appearance, alpha = 128, color = COLOR_BLACK, dir = xeno_owner.dir, time = 0, flags = ANIMATION_END_NOW, loop = -1)
	animate(alpha = 25, time = WRAITH_REWIND_RESET_TIME)
	apply_wibbly_filters(indicator_holder)
	if(xeno_owner.client)
		xeno_owner.client.images += indicator_holder
		RegisterSignal(xeno_owner, COMSIG_MOB_LOGOUT, PROC_REF(client_disconnected))
		return
	RegisterSignal(xeno_owner, COMSIG_MOB_LOGIN, PROC_REF(client_connected))

/// Adds a signal for when a client connects to this mob.
/datum/action/ability/xeno_action/wraith_rewind/proc/client_disconnected(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOB_LOGOUT)
	RegisterSignal(xeno_owner, COMSIG_MOB_LOGIN, PROC_REF(client_connected))

/// Setups visual effects whenever a client connects to this mob.
/datum/action/ability/xeno_action/wraith_rewind/proc/client_connected(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOB_LOGIN)
	RegisterSignal(xeno_owner, COMSIG_MOB_LOGOUT, PROC_REF(client_disconnected))
	if(reset_timer) // Wait for the ability's next reset to setup visuals. Gotta keep them synchronized!
		addtimer(CALLBACK(src, PROC_REF(visuals_setup), rewind_loc), timeleft(reset_timer))
		return
	visuals_setup()


// ***************************************
// *********** Temporal Strike
// ***************************************
#define TEMPORAL_STRIKE_DELAY 3.3 SECONDS
#define TEMPORAL_STRIKE_EFFECT_RADIUS 1
#define TEMPORAL_STRIKE_STAGGER 5
#define TEMPORAL_STRIKE_SLOWDOWN 5
#define TEMPORAL_STRIKE_DAMAGE_MODIFIER 2
#define TEMPORAL_STRIKE_KNOCKDOWN 1.5 SECONDS

/datum/action/ability/activable/xeno/temporal_strike
	name = "Temporal Strike"
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "temporal_strike"
	desc = "Strike at a target enemy. After a set amount of time, the attack will repeat itself, disrupting reality."
	ability_cost = 40
	cooldown_duration = 20 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TEMPORAL_STRIKE,
	)

/datum/action/ability/activable/xeno/temporal_strike/New(Target)
	. = ..()
	desc = "Strike at a target enemy. After [TEMPORAL_STRIKE_DELAY / 10] seconds, the attack will repeat itself, disrupting reality."

/datum/action/ability/activable/xeno/temporal_strike/on_cooldown_finish()
	. = ..()
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)

/datum/action/ability/activable/xeno/temporal_strike/use_ability(atom/target)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	new /obj/effect/temp_visual/temporal_strike(living_target.loc)
	playsound(living_target, 'sound/magic/timeparadox2.ogg', 40, TRUE, frequency = -1)
	playsound(living_target.loc, 'sound/effects/alien/wraith/temporal_strike.ogg', 30, TRUE)
	addtimer(CALLBACK(src, PROC_REF(incoming_anim), living_target), TEMPORAL_STRIKE_DELAY - 3.1)
	addtimer(CALLBACK(src, PROC_REF(delayed_attack), living_target), TEMPORAL_STRIKE_DELAY)
	add_cooldown()
	succeed_activate()
	GLOB.round_statistics.wraith_temporal_strikes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_temporal_strikes")

/// Creates an animation that indicates an incoming delayed attack.
/datum/action/ability/activable/xeno/temporal_strike/proc/incoming_anim(mob/target)
	if(!target)
		return
	var/visual_effect = new /obj/effect/temp_visual/temporal_delay(target.loc)
	target.vis_contents += visual_effect

/// After a set amount of time, executes the second part of this ability.
/datum/action/ability/activable/xeno/temporal_strike/proc/delayed_attack(atom/target)
	if(!target)
		return
	new /obj/effect/temp_visual/temporal_strike/delayed_strike(target.loc)
	playsound(target.loc, 'sound/effects/alien/wraith/delayed_strike.ogg', 40, 1)
	wraith_teleport_effect(xeno_owner, target, TEMPORAL_STRIKE_EFFECT_RADIUS, TEMPORAL_STRIKE_STAGGER, TEMPORAL_STRIKE_SLOWDOWN)
	var/damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * TEMPORAL_STRIKE_DAMAGE_MODIFIER
	var/damage_type = xeno_owner.xeno_caste.melee_damage_type
	var/defense_zone = xeno_owner.zone_selected
	var/defense_armor = xeno_owner.xeno_caste.melee_damage_armor
	var/damage_penetration = xeno_owner.xeno_caste.melee_ap
	for(var/turf/affected_turf AS in RANGE_TURFS(TEMPORAL_STRIKE_EFFECT_RADIUS, target.loc))
		for(var/mob/mob_target AS in affected_turf)
			if(!isliving(mob_target) || mob_target.stat == DEAD || xeno_owner.issamexenohive(mob_target))
				continue
			var/mob/living/living_target = mob_target
			living_target.Knockdown(TEMPORAL_STRIKE_KNOCKDOWN)
			living_target.do_jitter_animation(TEMPORAL_STRIKE_KNOCKDOWN * 10, TEMPORAL_STRIKE_KNOCKDOWN / 10, TEMPORAL_STRIKE_KNOCKDOWN / 10)
			living_target.apply_damage(damage, damage_type, defense_zone, defense_armor, FALSE, FALSE, TRUE, damage_penetration)

/obj/effect/temp_visual/temporal_strike
	icon = 'icons/effects/effects.dmi'
	icon_state = "temporal_strike"
	duration = 5

/obj/effect/temp_visual/temporal_strike/Initialize()
	. = ..()
	animate(src, time = duration - 1.5)
	animate(alpha = 0, time = 1.5)

/obj/effect/temp_visual/temporal_delay
	icon = 'icons/effects/64x64.dmi'
	icon_state = "temporal_delay"
	duration = 3.1
	alpha = 0
	pixel_x = -17
	pixel_y = -16

/obj/effect/temp_visual/temporal_delay/Initialize()
	. = ..()
	animate(src, alpha = 255, time = 0.4)
	animate(time = 2.3)
	animate(alpha = 0, time = 0.4)

/obj/effect/temp_visual/temporal_strike/delayed_strike
	icon = 'icons/effects/160x160.dmi'
	icon_state = "delayed_strike"
	duration = 4.9
	pixel_x = -78
	pixel_y = -42


// ***************************************
// *********** Time Stop
// ***************************************
#define TIME_STOP_RANGE 1 // in tiles
#define TIME_STOP_DURATION 7 SECONDS

/datum/action/ability/xeno_action/time_stop
	name = "Time Stop"
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "time_stop"
	desc = "Stops time in an area, freezing bullets. Once this effect expires, bullets will resume their movement."
	ability_cost = 100
	cooldown_duration = 1 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TIME_STOP,
	)

/datum/action/ability/xeno_action/time_stop/on_cooldown_finish()
	. = ..()
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)

/datum/action/ability/xeno_action/time_stop/action_activate()
	. = ..()
	var/list/turf/turfs_affected = list()
	var/turf/central_turf = get_turf(owner)
	for(var/turf/affected_turf in view(TIME_STOP_RANGE, central_turf))
		ADD_TRAIT(affected_turf, TRAIT_TURF_BULLET_MANIPULATION, REF(src))
		turfs_affected += affected_turf
		affected_turf.add_filter("wraith_magic", 2, drop_shadow_filter(color = "#04080FAA", size = -10))
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE)
	new /obj/effect/overlay/temp/timestop_effect(central_turf, TIME_STOP_DURATION)
	addtimer(CALLBACK(src, PROC_REF(remove_bullet_freeze), turfs_affected, central_turf), TIME_STOP_DURATION)
	addtimer(CALLBACK(src, PROC_REF(play_sound_stop)), TIME_STOP_DURATION - 3 SECONDS)
	add_cooldown()
	succeed_activate()
	GLOB.round_statistics.wraith_time_stops++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_time_stops")

/// Remove the bullet freeze effect on affected turfs.
/datum/action/ability/xeno_action/time_stop/proc/remove_bullet_freeze(list/turf/turfs_affected)
	for(var/turf/affected_turf AS in turfs_affected)
		REMOVE_TRAIT(affected_turf, TRAIT_TURF_BULLET_MANIPULATION, REF(src))
		if(HAS_TRAIT(affected_turf, TRAIT_TURF_BULLET_MANIPULATION))
			continue
		SEND_SIGNAL(affected_turf, COMSIG_TURF_RESUME_PROJECTILE_MOVE)
		affected_turf.remove_filter("wraith_magic")

///Play the end ability sound
/datum/action/ability/xeno_action/time_stop/proc/play_sound_stop()
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE, frequency = -1)
