GLOBAL_LIST_INIT(wraith_banish_very_short_duration_list, typecacheof(list(
	/obj/structure/barricade)))

// ***************************************
// *********** Place Warp Shadow
// ***************************************
/datum/action/xeno_action/place_warp_shadow
	name = "Place Warp Shadow"
	ability_name = "Place Warp Shadow"
	action_icon_state = "warp_shadow"
	mechanics_text = "Binds our psychic essence to a spot of our choosing. We can use Hyperposition to swap locations with this essence."
	plasma_cost = 150
	cooldown_timer = 60 SECONDS
	keybind_signal = COMSIG_XENOABILITY_PLACE_WARP_BEACON
	/// This is the warp shadow that the Wraith creates with its Place Warp Shadow ability, and teleports to with Hyperposition
	var/obj/effect/xenomorph/warp_shadow/warp_shadow

/datum/action/xeno_action/place_warp_shadow/can_use_action(silent = FALSE, override_flags)
	. = ..()

	var/turf/T = get_turf(owner)

	if(turf_block_check(owner, T, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE)) //Check if there's anything non-mob that blocks us
		if(!silent)
			to_chat(owner, span_xenowarning("We cannot create our warp shadow in a solid object!"))
		return FALSE



/datum/action/xeno_action/place_warp_shadow/action_activate()
	var/mob/living/carbon/xenomorph/wraith/ghost = owner

	ghost.visible_message(span_xenowarning("The air starts to violently roil and shimmer around [ghost]!"), \
	span_xenodanger("We begin to imprint our essence upon reality, causing the air about us to roil and shimmer...")) //Fluff

	owner.add_filter("wraith_hyperposition_windup_filter_1", 3, motion_blur_filter()) //Cool filter appear
	owner.add_filter("wraith_hyperposition_windup_filter_2", 3, motion_blur_filter()) //Cool filter appear

	animate(owner.get_filter("wraith_hyperposition_windup_filter_1"), x = 30*rand() - 15, y = 30*rand() - 15, time = 0.5 SECONDS, loop = -1)
	animate(owner.get_filter("wraith_hyperposition_windup_filter_2"), x = 30*rand() - 15, y = 30*rand() - 15, time = 0.5 SECONDS, loop = -1)

	if(!do_after(ghost, WRAITH_PLACE_WARP_BEACON_WINDUP, TRUE, ghost, BUSY_ICON_BUILD)) //Channel time/wind up
		ghost.visible_message(span_xenowarning("The space around [ghost] abruptly stops shifting and wavering."), \
		span_xenodanger("We cease binding our essence to this place..."))
		owner.remove_filter("wraith_hyperposition_windup_filter_1")
		owner.remove_filter("wraith_hyperposition_windup_filter_2")
		add_cooldown(cooldown_override = WRAITH_PLACE_WARP_BEACON_FAIL_COOLDOWN_OVERRIDE)
		return fail_activate()

	owner.remove_filter("wraith_hyperposition_windup_filter_1")
	owner.remove_filter("wraith_hyperposition_windup_filter_2")

	var/turf/T = get_turf(ghost)
	ghost.visible_message(span_xenonotice("A shimmering point suddenly coalesces from the warped space above [T]."), \
	span_xenodanger("We complete our work, binding our essence to this point."), null, 5) //Fluff
	var/obj/effect/xenomorph/warp_shadow/shadow = new(T) //Create the new warp shadow.
	playsound(T, 'sound/weapons/emitter.ogg', 25, 1)
	QDEL_NULL(warp_shadow) //Delete the old warp shadow
	warp_shadow = shadow //Set the new warp shadow
	RegisterSignal(owner, COMSIG_MOB_DEATH, .proc/clean_warp_shadow) //Removes warp shadow on death
	RegisterSignal(warp_shadow, COMSIG_PARENT_PREQDELETED, .proc/unset_warp_shadow) //For var clean up
	RegisterSignal(owner, COMSIG_PARENT_PREQDELETED, .proc/clean_warp_shadow) //For var clean up
	warp_shadow.setDir(ghost.dir) //Have it imitate our facing
	warp_shadow.pixel_x = ghost.pixel_x //Inherit pixel offsets
	warp_shadow.pixel_y = ghost.pixel_y //Inherit pixel offsets
	teleport_debuff_aoe(warp_shadow) //SFX

	succeed_activate()
	add_cooldown()

///Nulls out the warp shadow
/datum/action/xeno_action/place_warp_shadow/proc/unset_warp_shadow()
	SIGNAL_HANDLER
	UnregisterSignal(warp_shadow, COMSIG_PARENT_PREQDELETED)
	UnregisterSignal(owner, list(
		COMSIG_MOB_DEATH,
		COMSIG_PARENT_PREQDELETED,
	))
	warp_shadow = null //remove the actual shadow

/// clean up when owner dies/deleted
/datum/action/xeno_action/place_warp_shadow/proc/clean_warp_shadow()
	SIGNAL_HANDLER
	UnregisterSignal(warp_shadow, COMSIG_PARENT_PREQDELETED)
	QDEL_NULL(warp_shadow)

/datum/action/xeno_action/place_warp_shadow/on_cooldown_finish()
	to_chat(owner, span_xenonotice("We are able to place another warp shadow."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()


// ***************************************
// *********** Hyperposition
// ***************************************
/datum/action/xeno_action/hyperposition
	name = "Hyperposition"
	ability_name = "Hyperposition"
	action_icon_state = "hyperposition"
	mechanics_text = "We teleport back to our warp shadow after a delay. The delay scales with the distance teleported."
	plasma_cost = 25
	cooldown_timer = 5 SECONDS
	keybind_signal = COMSIG_XENOABILITY_HYPERPOSITION


/datum/action/xeno_action/hyperposition/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/datum/action/xeno_action/place_warp_shadow/warp_shadow_check = owner.actions_by_path[/datum/action/xeno_action/place_warp_shadow]
	if(!warp_shadow_check) //Mainly for when we transition on upgrading
		return FALSE

	var/obj/effect/xenomorph/warp_shadow/shadow = warp_shadow_check.warp_shadow
	if(!shadow)
		if(!silent)
			to_chat(owner, span_xenodanger("We have no warp shadow to teleport to!"))
		return FALSE

	if(shadow.z != owner.z) //We must be on the same Z level to teleport to the warp shadow
		if(!silent)
			to_chat(owner, span_xenodanger("Our warp shadow is beyond our ability to teleport to!"))
		return FALSE

	if(turf_block_check(owner, shadow, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE)) //Check if there's anything that blocks us; we only care about Canpass here
		if(!silent)
			to_chat(owner, span_xenowarning("We can't teleport to our warp shadow while it's somewhere we can't occupy!"))
		return FALSE


/datum/action/xeno_action/hyperposition/action_activate()
	. = ..()
	var/datum/action/xeno_action/place_warp_shadow/warp_shadow_check = owner.actions_by_path[/datum/action/xeno_action/place_warp_shadow]
	var/obj/effect/xenomorph/warp_shadow/shadow = warp_shadow_check.warp_shadow

	var/area/A = get_area(shadow)

	var/distance = get_dist(owner, shadow) //Get the distance so we can calculate the wind up
	var/hyperposition_windup = clamp(distance * 0.25 SECONDS - 5 SECONDS, WRAITH_HYPERPOSITION_MIN_WINDUP, WRAITH_HYPERPOSITION_MAX_WINDUP)

	owner.visible_message(span_warning("The air starts to violently roil and shimmer around [owner]!"), \
	span_xenodanger("We begin to teleport to our warp shadow located at [A] (X: [shadow.x], Y: [shadow.y]). We estimate this will take [hyperposition_windup * 0.1] seconds."))

	owner.add_filter("wraith_hyperposition_windup_filter_1", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	owner.add_filter("wraith_hyperposition_windup_filter_2", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear

	animate(owner.get_filter("wraith_hyperposition_windup_filter_1"), x = 30*rand() - 15, y = 30*rand() - 15, time = 0.5 SECONDS, loop = -1)
	animate(owner.get_filter("wraith_hyperposition_windup_filter_2"), x = 30*rand() - 15, y = 30*rand() - 15, time = 0.5 SECONDS, loop = -1)

	if(!do_after(owner, hyperposition_windup, TRUE, owner, BUSY_ICON_FRIENDLY)) //Channel time/wind up
		owner.visible_message(span_xenowarning("The space around [owner] abruptly stops shifting and wavering."), \
		span_xenodanger("We abort teleporting back to our warp shadow."))
		owner.remove_filter("wraith_hyperposition_windup_filter_1")
		owner.remove_filter("wraith_hyperposition_windup_filter_2")
		add_cooldown(cooldown_override = WRAITH_HYPERPOSITION_COOLDOWN_OVERRIDE)
		return fail_activate()

	owner.remove_filter("wraith_hyperposition_windup_filter_1")
	owner.remove_filter("wraith_hyperposition_windup_filter_2")

	if(!can_use_action()) //Check if we can actually position swap again due to the wind up delay.
		return fail_activate()

	var/turf/beacon_turf = get_turf(shadow)

	shadow.forceMove(get_turf(owner)) //Move the beacon to where we are leaving
	shadow.dir = owner.dir //Have it imitate our facing
	shadow.pixel_x = owner.pixel_x //Inherit pixel offsets
	teleport_debuff_aoe(owner) //Apply tele debuff

	owner.forceMove(beacon_turf) //Move to where the beacon was
	teleport_debuff_aoe(owner) //Apply tele debuff

	var/warp_shadow_dissipate = FALSE
	if(turf_block_check(owner, get_turf(shadow), TRUE, TRUE, FALSE, FALSE, FALSE, TRUE)) //Check if there's anything that blocks the warp shadow; we only care about solid walls/objects
		warp_shadow_dissipate = TRUE
		warp_shadow_check.clean_warp_shadow() //Remove the warp shadow

	owner.visible_message(span_warning("\ [owner] suddenly vanishes in a vortex of warped space!"), \
	span_xenodanger("We teleport, swapping positions with our warp shadow. [warp_shadow_dissipate ? "Our warp shadow dissipates as it is teleported into a solid object." : "Our warp shadow has moved to [AREACOORD_NO_Z(shadow)]."]"), null, 5) //Let user know the new location

	GLOB.round_statistics.wraith_hyperpositions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_hyperpositions") //Statistics
	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/hyperposition/on_cooldown_finish()
	to_chat(owner, span_xenonotice("We are able to swap locations with our warp shadow once again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Phase Shift
// ***************************************
/datum/action/xeno_action/phase_shift
	name = "Phase Shift"
	ability_name = "Phase Shift"
	action_icon_state = "phase_shift"
	mechanics_text = "We force ourselves temporarily out of sync with reality, allowing us to become incorporeal and move through any physical obstacles for a short duration."
	plasma_cost = 25
	cooldown_timer = WRAITH_PHASE_SHIFT_COOLDOWN
	keybind_signal = COMSIG_XENOABILITY_PHASE_SHIFT
	var/turf/starting_turf = null
	var/phase_shift_active = FALSE
	var/phase_shift_duration_timer_id
	///Timer for the phase shift duration alerts
	var/phase_shift_duration_alert_id

/datum/action/xeno_action/phase_shift/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	for(var/shutter_check in GLOB.wraith_no_incorporeal_pass_shutters)
		if(locate(shutter_check) in T)
			if(!silent)
				to_chat(owner, span_xenowarning("We can't Phase Shift while in the space of warp protected shutters!"))
			return FALSE


/datum/action/xeno_action/phase_shift/action_activate()
	. = ..()

	if(phase_shift_active) //Toggle off if phase shift is active
		phase_shift_deactivate()
		return

	owner.visible_message(span_warning("[owner.name] is becoming faint and translucent!"), \
	span_xenodanger("We begin to move out of phase with reality....")) //Fluff

	owner.add_filter("wraith_phase_shift_windup_1", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	owner.add_filter("wraith_phase_shift_windup_2", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	animate(owner.get_filter("wraith_phase_shift_windup_1"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1)
	animate(owner.get_filter("wraith_phase_shift_windup_2"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1)

	if(!do_after(owner, WRAITH_PHASE_SHIFT_WINDUP, TRUE, owner, BUSY_ICON_FRIENDLY)) //Channel time/wind up
		owner.visible_message(span_xenowarning("[owner]'s form abruptly consolidates, returning to normalcy."), \
		span_xenodanger("We abort our desynchronization."))
		owner.remove_filter("wraith_phase_shift_windup_1")
		owner.remove_filter("wraith_phase_shift_windup_2")
		return fail_activate()

	owner.remove_filter("wraith_phase_shift_windup_1")
	owner.remove_filter("wraith_phase_shift_windup_2")

	playsound(owner, "sound/effects/ghost.ogg", 25, 0, 1)

	phase_shift_duration_alert_id = addtimer(CALLBACK(src, .proc/phase_shift_warning), WRAITH_PHASE_SHIFT_DURATION * WRAITH_PHASE_SHIFT_DURATION_WARNING, TIMER_STOPPABLE) //Warn them when Phase Shift is about to end
	phase_shift_duration_timer_id = addtimer(CALLBACK(src, .proc/phase_shift_deactivate), WRAITH_PHASE_SHIFT_DURATION, TIMER_STOPPABLE)
	owner.add_filter("wraith_phase_shift", 4, list("type" = "blur", 5)) //Cool filter appear
	owner.stop_pulling() //We can't pull things while incorporeal

	owner.generic_canpass = FALSE //So incorporeality is actually checked for collision
	owner.status_flags = GODMODE | INCORPOREAL //Become temporarily invulnerable and incorporeal
	owner.resistance_flags = RESIST_ALL
	owner.density = FALSE
	owner.throwpass = TRUE
	owner.alpha = WRAITH_PHASE_SHIFT_ALPHA //Become translucent
	owner.move_resist = INFINITY //Become immovable

	starting_turf = get_turf(owner) //Get our starting turf so we can calculate the stun duration later.

	GLOB.round_statistics.wraith_phase_shifts++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_phase_shifts") //Statistics

	phase_shift_active = TRUE //Flag phase shift as being active
	update_button_icon("phase_shift_off") //Set to resync icon while active
	plasma_cost = 0 //Toggling is free
	return succeed_activate()

///Warns the user when Phase Shift is about to end.
/datum/action/xeno_action/phase_shift/proc/phase_shift_warning()

	if(!phase_shift_active) //If phase shift isn't active, cancel out
		return

	owner.alpha = WRAITH_PHASE_SHIFT_ALPHA * 1.5 //Become less translucent

	to_chat(owner,span_highdanger("We begin to move back into phase with reality... We can only remain out of phase for [WRAITH_PHASE_SHIFT_DURATION * (1-WRAITH_PHASE_SHIFT_DURATION_WARNING) * 0.1] more seconds!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Deactivates and turns off the Phase Shift ability/effects
/datum/action/xeno_action/phase_shift/proc/phase_shift_deactivate(resync = FALSE)
	if(!phase_shift_active) //If phase shift isn't active, don't deactivate again; generally here for the timed proc.
		return

	deltimer(phase_shift_duration_timer_id) //Delete any existing timers
	deltimer(phase_shift_duration_alert_id)
	phase_shift_active = FALSE //Flag phase shift as being off
	update_button_icon("phase_shift") //Revert the icon to phase shift

	var/mob/living/carbon/xenomorph/wraith/ghost = owner

	ghost.generic_canpass = initial(ghost.generic_canpass)
	ghost.status_flags = initial(ghost.status_flags) //Become merely mortal again
	ghost.resistance_flags = initial(ghost.resistance_flags)
	ghost.density = initial(ghost.density)
	ghost.throwpass = initial(ghost.throwpass)
	ghost.alpha = initial(ghost.alpha) //Become opaque
	ghost.remove_filter("wraith_phase_shift") //Cool filter begone
	ghost.move_resist = initial(ghost.move_resist)

	playsound(owner, "sound/effects/phasein.ogg", 25, 0, 1)

	ghost.add_filter("wraith_phase_shift_windup_1", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	ghost.add_filter("wraith_phase_shift_windup_2", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	animate(ghost.get_filter("wraith_phase_shift_windup_1"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1)
	animate(ghost.get_filter("wraith_phase_shift_windup_2"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1)
	addtimer(CALLBACK(ghost, /atom.proc/remove_filter, "wraith_phase_shift_windup_1"), 0.5 SECONDS)
	addtimer(CALLBACK(ghost, /atom.proc/remove_filter, "wraith_phase_shift_windup_2"), 0.5 SECONDS)

	var/current_turf = get_turf(ghost)
	var/block_check //Are we trying to rematerialize in a solid object? Check.

	if(isspaceturf(current_turf) || turf_block_check(owner, current_turf, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE)) //So we rematerialized in a solid wall/space or invincible dense object
		block_check = TRUE

	if(block_check) //We tried to rematerialize in a solid object/wall of some kind; return to sender
		to_chat(ghost, span_highdanger("As we rematerialize in a solid object, we revert to where we slipped out of reality."))
		resync = TRUE
		ghost.forceMove(starting_turf)
		teleport_debuff_aoe(ghost) //Debuff when we reappear

	var/distance = get_dist(current_turf, starting_turf)
	var/phase_shift_plasma_cost = clamp(distance * 4, 0, 100) //We lose 4 additional plasma per tile travelled, up to a maximum of 100
	var/plasma_deficit = ghost.plasma_stored - phase_shift_plasma_cost
	var/cooldown_override

	if(resync) //If we were shunted back willingly or otherwise this is true
		cooldown_override = 3 SECONDS //Partial cooldown if we cancelled out of Phase Shift with Resync
	else
		ghost.use_plasma(phase_shift_plasma_cost) //Pay the extra cost if we didn't resync
		ghost.visible_message(span_warning("[ghost] form wavers and becomes opaque."), \
		span_xenodanger("We phase back into reality[phase_shift_plasma_cost > 0 ? " expending [phase_shift_plasma_cost] additional plasma for [distance] tiles travelled." : "."]"))
		if(plasma_deficit < 0) //If we don't have enough plasma, we pay in blood and sunder instead.
			plasma_deficit *= -1 //Normalize to a positive value
			to_chat(owner, span_highdanger("We haven't enough plasma to safely move back into phase, suffering [plasma_deficit] damage and sunder as our body is torn apart!"))
			ghost.apply_damages(plasma_deficit)
			ghost.adjust_sunder(plasma_deficit)

	starting_turf = null
	plasma_cost = initial(plasma_cost) //Revert the plasma cost to its initial amount
	add_cooldown(cooldown_override)

/datum/action/xeno_action/phase_shift/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to fade from reality again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/phase_shift/update_button_icon(input) //So we display the proper icon
	if(!input) //If we're not overriding, proceed as normal
		return ..()
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, input)
	return ..()

// ***************************************
// *********** Resync
// ***************************************
/datum/action/xeno_action/resync
	name = "Resync"
	ability_name = "Resync"
	action_icon_state = "resync"
	mechanics_text = "Resynchronize with realspace, ending Phase Shift's effect and returning you to where the Phase Shift began with minimal cooldown."
	cooldown_timer = 1 SECONDS //Token for anti-spam
	keybind_signal = COMSIG_XENOABILITY_RESYNC

/datum/action/xeno_action/resync/can_use_action(silent = FALSE, override_flags)
	. = ..()

	if(!(owner.status_flags & INCORPOREAL))
		if(!silent)
			to_chat(owner,span_xenodanger("We are already synchronized with realspace!"))
		return FALSE

/datum/action/xeno_action/resync/action_activate()
	. = ..()

	var/datum/action/xeno_action/phase_shift/disable_shift = owner.actions_by_path[/datum/action/xeno_action/phase_shift]
	owner.forceMove(disable_shift.starting_turf) //Return to our initial position, then cancel the shift
	disable_shift.phase_shift_deactivate(TRUE) //Resync is true; cooldown is sharply reduced
	teleport_debuff_aoe(owner) //Debuff when we reappear

	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Blink
// ***************************************
/datum/action/xeno_action/activable/blink
	name = "Blink"
	action_icon_state = "blink"
	ability_name = "Blink"
	mechanics_text = "We teleport ourselves a short distance to a location within line of sight."
	use_state_flags = XABB_TURF_TARGET
	plasma_cost = 50
	cooldown_timer = 0.5 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BLINK

///Check target Blink turf to see if it can be blinked to
/datum/action/xeno_action/activable/blink/proc/check_blink_tile(turf/T, ignore_blocker = FALSE, silent = FALSE)
	if(isclosedturf(T) || isspaceturf(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We cannot blink here!"))
		return FALSE

	var/area/target_area = get_area(T) //We are forced to set this; will not work otherwise
	if(is_type_in_typecache(target_area, GLOB.wraith_strictly_forbidden_areas)) //We can't enter these period.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this area!"))
		return FALSE

	if(!owner.line_of_sight(T)) //Needs to be in line of sight.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink without line of sight to our destination!"))
		return FALSE

	if(IS_OPAQUE_TURF(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this space without vision!"))
		return FALSE

	if(ignore_blocker) //If we don't care about objects occupying the target square, return TRUE; used for checking pathing through transparents
		return TRUE

	if(turf_block_check(owner, T, FALSE, TRUE, TRUE, TRUE, TRUE)) //Check if there's anything that blocks us; we only care about Canpass here
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink here!"))
		return FALSE

	return TRUE

///Check for whether the target turf has dense objects inside
/datum/action/xeno_action/activable/blink/proc/check_blink_target_turf_density(turf/T, silent = FALSE)
	for(var/atom/blocker AS in T)
		if(!blocker.CanPass(owner, T))
			if(!silent)
				to_chat(owner, span_xenowarning("We can't blink into a solid object!"))
			return FALSE

	return TRUE

/datum/action/xeno_action/activable/blink/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/X = owner
	var/turf/T = X.loc
	var/turf/temp_turf = X.loc
	var/check_distance = min(X.xeno_caste.wraith_blink_range, get_dist(X,A))
	var/list/fully_legal_turfs = list()

	for (var/x = 1 to check_distance)
		temp_turf = get_step(T, get_dir(T, A))
		if (!temp_turf)
			break
		if(!check_blink_tile(temp_turf, TRUE, TRUE)) //Verify that the turf is legal; if not we cancel out. We ignore transparent dense objects like windows here for now
			break
		if(check_blink_target_turf_density(temp_turf, TRUE)) //If we could ultimately teleport to this square, it is fully legal; add it to the list
			fully_legal_turfs += temp_turf
		T = temp_turf

	check_distance = min(fully_legal_turfs.len, check_distance) //Cap the check distance to the number of fully legal turfs
	T = X.loc //Reset T to be our initial position
	if(check_distance)
		T = fully_legal_turfs[check_distance]

	X.face_atom(T) //Face the target so we don't look like an ass

	var/cooldown_mod = 1
	var/mob/pulled_target = owner.pulling
	if(pulled_target) //bring the pulled target with us if applicable but at the cost of sharply increasing the next cooldown

		if(pulled_target.issamexenohive(X))
			cooldown_mod = X.xeno_caste.wraith_blink_drag_friendly_multiplier
		else
			if(!do_after(owner, 0.5 SECONDS, TRUE, owner, BUSY_ICON_HOSTILE)) //Grap-porting hostiles has a slight wind up
				return fail_activate()
			cooldown_mod = X.xeno_caste.wraith_blink_drag_nonfriendly_living_multiplier
			if(ishuman(pulled_target))
				var/mob/living/carbon/human/H = pulled_target
				if(H.stat == UNCONSCIOUS) //Apply critdrag damage as if they were quickly pulled the same distance
					var/critdamage = HUMAN_CRITDRAG_OXYLOSS * get_dist(H.loc, T)
					if(!H.adjustOxyLoss(critdamage))
						H.adjustBruteLoss(critdamage)

		to_chat(X, span_xenodanger("We bring [pulled_target] with us. We won't be ready to blink again for [cooldown_timer * cooldown_mod * 0.1] seconds due to the strain of doing so."))

	teleport_debuff_aoe(X) //Debuff when we vanish

	if(pulled_target) //Yes, duplicate check because otherwise we end up with the initial teleport debuff AoE happening prior to the wind up which looks really bad and is actually exploitable via deliberate do after cancels
		pulled_target.forceMove(T) //Teleport to our target turf

	X.forceMove(T) //Teleport to our target turf
	teleport_debuff_aoe(X) //Debuff when we reappear

	succeed_activate()
	add_cooldown(cooldown_timer * cooldown_mod)

	GLOB.round_statistics.wraith_blinks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_blinks") //Statistics

///Called by many of the Wraith's teleportation effects
/datum/action/xeno_action/proc/teleport_debuff_aoe(atom/movable/teleporter, silent = FALSE)
	var/mob/living/carbon/xenomorph/ghost = owner

	if(!silent) //Sound effects
		playsound(teleporter, 'sound/effects/EMPulse.ogg', 25, 1) //Sound at the location we are arriving at

	new /obj/effect/temp_visual/blink_portal(get_turf(teleporter))

	for(var/turf/affected_tile as() in RANGE_TURFS(1,teleporter.loc))
		affected_tile.add_filter("wraith_blink_distortion", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
		animate(affected_tile.get_filter("wraith_blink_distortion"), x = 60*rand() - 30, y = 60*rand() - 30, time = 0.5 SECONDS, loop = 2)
		addtimer(CALLBACK(affected_tile, /atom.proc/remove_filter, "wraith_blink_distortion"), 1 SECONDS)

		for(var/obj/obj_target in affected_tile) //This is just about SFX, so we don't have objects not distorting while everything else does
			obj_target.add_filter("wraith_aoe_debuff_filter", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
			animate(obj_target.get_filter("wraith_aoe_debuff_filter"), x = 60*rand() - 30, y = 60*rand() - 30, time = 0.25 SECONDS, loop = -1)
			addtimer(CALLBACK(obj_target, /atom.proc/remove_filter, "wraith_aoe_debuff_filter"), 0.5 SECONDS)

		for(var/mob/living/living_target in affected_tile)
			living_target.add_filter("wraith_aoe_debuff_filter", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
			animate(living_target.get_filter("wraith_aoe_debuff_filter"), x = 60*rand() - 30, y = 60*rand() - 30, time = 0.25 SECONDS, loop = -1)
			addtimer(CALLBACK(living_target, /atom.proc/remove_filter, "wraith_aoe_debuff_filter"), 0.5 SECONDS)

			if(living_target.stat == DEAD)
				continue

			if(isxeno(living_target))
				var/mob/living/carbon/xenomorph/X = living_target
				if(X.issamexenohive(ghost)) //No friendly fire
					continue

			shake_camera(living_target, 2, 1)
			living_target.adjust_stagger(WRAITH_TELEPORT_DEBUFF_STAGGER_STACKS)
			living_target.add_slowdown(WRAITH_TELEPORT_DEBUFF_SLOWDOWN_STACKS)
			living_target.adjust_blurriness(WRAITH_TELEPORT_DEBUFF_SLOWDOWN_STACKS) //minor visual distortion
			to_chat(living_target, span_warning("You feel nauseous as reality warps around you!"))

/datum/action/xeno_action/activable/blink/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to blink again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Banish
// ***************************************
/datum/action/xeno_action/activable/banish
	name = "Banish"
	action_icon_state = "Banish"
	ability_name = "Banish"
	mechanics_text = "We banish a target object or creature within line of sight to nullspace for a short duration. Can target onself and allies. Non-friendlies are banished for half as long."
	use_state_flags = XACT_TARGET_SELF
	plasma_cost = 100
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BANISH
	///Target we've banished
	var/atom/movable/banishment_target = null
	///SFX indicating the banished target's position
	var/obj/effect/temp_visual/banishment_portal/portal = null
	///The timer ID of any Banish currently active
	var/banish_duration_timer_id
	///Phantom zone reserved area
	var/datum/turf_reservation/reserved_area

/datum/action/xeno_action/activable/banish/Destroy()
	QDEL_NULL(reserved_area) //clean up
	return ..()

/datum/action/xeno_action/activable/banish/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()

	if(owner.status_flags & INCORPOREAL) //We can't use this while phased out.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't banish while incorporeal!"))
		return FALSE

	if(!ismovableatom(A) || iseffect(A) || CHECK_BITFIELD(A.resistance_flags, INDESTRUCTIBLE) || CHECK_BITFIELD(A.resistance_flags, BANISH_IMMUNE)) //Cannot banish non-movables/things that are supposed to be invul; also we ignore effects
		if(!silent)
			to_chat(owner, span_xenowarning("We cannot banish this!"))
		return FALSE

	var/mob/living/carbon/xenomorph/X = owner

	var/distance = get_dist(owner, A)
	if(distance > X.xeno_caste.wraith_banish_range) //Needs to be in range.
		if(!silent)
			to_chat(owner, span_xenowarning("Our target is too far away! It must be [distance - WRAITH_BANISH_RANGE] tiles closer!"))
		return FALSE

	if(!owner.line_of_sight(A)) //Needs to be in line of sight.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't banish without line of sight to our target!"))
		return FALSE


/datum/action/xeno_action/activable/banish/use_ability(atom/movable/A)
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/ghost = owner
	var/banished_turf = get_turf(A) //Set the banishment turf.
	banishment_target = A //Set the banishment target

	ghost.face_atom(A) //Face the target so we don't look like an ass

	teleport_debuff_aoe(banishment_target) //Debuff when we disappear
	portal = new /obj/effect/temp_visual/banishment_portal(banished_turf)
	banishment_target.resistance_flags = RESIST_ALL

	if(isliving(A))
		var/mob/living/stasis_target = banishment_target
		stasis_target.apply_status_effect(/datum/status_effect/incapacitating/unconscious) //Force the target to KO
		stasis_target.notransform = TRUE //Stasis
		stasis_target.overlay_fullscreen("banish", /obj/screen/fullscreen/blind) //Force the blind overlay

	if(!reserved_area) //If we don't have a reserved area, set one
		reserved_area = SSmapping.RequestBlockReservation(3,3, SSmapping.transit.z_value, /datum/turf_reservation/banish)
		if(!reserved_area) //If we *still* don't have a reserved area we've got a problem
			CRASH("failed to reserve an area for [owner]'s Banish.")

	var/turf/target_turf = reserved_area.reserved_turfs[5]
	new /area/arrival(target_turf) //So we don't get instagibbed from the space area

	if(isxeno(banishment_target)) //If we're a xeno, disgorge all vored contents
		var/mob/living/carbon/xenomorph/xeno_target = banishment_target
		xeno_target.eject_victim()

	for(var/mob/living/living_contents in banishment_target.contents) //Safety measure so living mobs inside the target don't get lost in Brazilspace forever
		living_contents.forceMove(banished_turf)

	banishment_target.forceMove(target_turf)

	var/duration = ghost.xeno_caste.wraith_banish_base_duration //Set the duration

	portal.add_filter("banish_portal_1", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	portal.add_filter("banish_portal_2", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	animate(portal.get_filter("banish_portal_1"), x = 20*rand() - 10, y = 20*rand() - 10, time = 0.5 SECONDS, loop = -1)
	animate(portal.get_filter("banish_portal_2"), x = 20*rand() - 10, y = 20*rand() - 10, time = 0.5 SECONDS, loop = -1)

	var/cooldown_mod = 1
	var/plasma_mod = 1
	if(isliving(banishment_target) && !(banishment_target.issamexenohive(ghost))) //We halve the max duration for living non-allies
		duration *= WRAITH_BANISH_NONFRIENDLY_LIVING_MULTIPLIER
	else if(is_type_in_typecache(banishment_target, GLOB.wraith_banish_very_short_duration_list)) //Barricades should only be gone long enough to admit an infiltrator xeno or two; one way.
		duration *= WRAITH_BANISH_VERY_SHORT_MULTIPLIER
	else
		cooldown_mod = 0.6 //40% cooldown reduction if used on non-hostile, non-blacklisted targets.
		plasma_mod = 0.4 //60% plasma cost reduction if used on non-hostile, non-blacklisted targets.

	banishment_target.visible_message(span_warning("Space abruptly twists and warps around [banishment_target] as it suddenly vanishes!"), \
	span_highdanger("The world around you reels, reality seeming to twist and tear until you find yourself trapped in a forsaken void beyond space and time."))
	playsound(banished_turf, 'sound/weapons/emitter2.ogg', 50, 1) //this isn't quiet

	to_chat(ghost,span_xenodanger("We have banished [banishment_target] to nullspace for [duration * 0.1] seconds."))
	log_attack("[key_name(ghost)] has banished [key_name(banishment_target)] for [duration * 0.1] seconds at [AREACOORD(banishment_target)]")

	addtimer(CALLBACK(src, .proc/banish_warning), duration * 0.7) //Warn when Banish is about to end
	banish_duration_timer_id = addtimer(CALLBACK(src, .proc/banish_deactivate), duration, TIMER_STOPPABLE) //store the timer ID

	succeed_activate(plasma_cost * plasma_mod)
	add_cooldown(cooldown_timer * cooldown_mod)

	GLOB.round_statistics.wraith_banishes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_banishes") //Statistics

///Warns the user when Banish's duration is about to lapse.
/datum/action/xeno_action/activable/banish/proc/banish_warning()

	if(!banishment_target)
		return

	to_chat(owner,span_highdanger("Our banishment target [banishment_target.name] is about to return to reality at [AREACOORD_NO_Z(portal)]!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Ends the effect of the Banish ability
/datum/action/xeno_action/activable/banish/proc/banish_deactivate()
	SIGNAL_HANDLER
	if(!banishment_target)
		return

	banishment_target.forceMove(get_turf(portal))
	banishment_target.resistance_flags = initial(banishment_target.resistance_flags)
	banishment_target.status_flags = initial(banishment_target.status_flags) //Remove stasis and temp invulerability
	teleport_debuff_aoe(banishment_target) //Debuff/distortion when we reappear
	banishment_target.add_filter("wraith_banishment_filter", 3, list("type" = "blur", 5)) //Cool filter appear
	addtimer(CALLBACK(banishment_target, /atom.proc/remove_filter, "wraith_banishment_filter"), 1 SECONDS) //1 sec blur duration

	if(isliving(banishment_target))
		var/mob/living/living_target = banishment_target
		living_target = banishment_target
		living_target.remove_status_effect(/datum/status_effect/incapacitating/unconscious) //Force the target to KO
		living_target.notransform = initial(living_target.notransform)
		living_target.clear_fullscreen("banish") //Remove the blind overlay

	banishment_target.visible_message(span_warning("[banishment_target.name] abruptly reappears!"), \
	span_warning("You suddenly reappear back in what you believe to be reality."))

	to_chat(owner, span_highdanger("Our target [banishment_target] has returned to reality at [AREACOORD_NO_Z(banishment_target)]")) //Always alert the Wraith
	log_attack("[key_name(owner)] has unbanished [key_name(banishment_target)] at [AREACOORD(banishment_target)]")

	QDEL_NULL(portal) //Eliminate the Brazil portal if we need to

	banishment_target = null

	return TRUE //For the recall sub-ability

/datum/action/xeno_action/activable/banish/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to banish again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Recall
// ***************************************
/datum/action/xeno_action/recall
	name = "Recall"
	ability_name = "Recall"
	action_icon_state = "Recall"
	mechanics_text = "We recall a target we've banished back from the depths of nullspace."
	use_state_flags = XACT_USE_NOTTURF|XACT_USE_STAGGERED|XACT_USE_INCAP|XACT_USE_LYING //So we can recall ourselves from nether Brazil
	cooldown_timer = 1 SECONDS //Token for anti-spam
	keybind_signal = COMSIG_XENOABILITY_RECALL

/datum/action/xeno_action/recall/can_use_action(silent = FALSE, override_flags)
	. = ..()

	var/datum/action/xeno_action/activable/banish/banish_check = owner.actions_by_path[/datum/action/xeno_action/activable/banish]
	if(!banish_check) //Mainly for when we transition on upgrading
		return FALSE

	if(!banish_check.banishment_target)
		if(!silent)
			to_chat(owner,span_xenodanger("We have no targets banished!"))
		return FALSE


/datum/action/xeno_action/recall/action_activate()
	. = ..()
	var/datum/action/xeno_action/activable/banish/banish_check = owner.actions_by_path[/datum/action/xeno_action/activable/banish]
	banish_check.banish_deactivate()
	succeed_activate()
	add_cooldown()

///Return TRUE if we have a block, return FALSE otherwise
/proc/turf_block_check(atom/subject, atom/target, ignore_can_pass = FALSE, ignore_density = FALSE, ignore_closed_turf = FALSE, ignore_invulnerable = FALSE, ignore_objects = FALSE, ignore_mobs = FALSE, ignore_space = FALSE)
	var/turf/T = get_turf(target)
	if(isspaceturf(T) && !ignore_space)
		return TRUE
	for(var/atom/blocker AS in T)
		if((blocker.flags_atom & ON_BORDER) || blocker == subject) //If they're a border entity or our subject, we don't care
			continue
		if(!blocker.CanPass(subject, T) && !ignore_can_pass) //If the subject atom can't pass and we care about that, we have a block
			return TRUE
		if(!blocker.density) //Check if we're dense
			continue
		if(!ignore_density) //If we care about all dense atoms or only certain types of dense atoms
			return TRUE
		if(isclosedturf(blocker) && !ignore_closed_turf) //If we care about closed turfs
			return TRUE
		if((blocker.resistance_flags & INDESTRUCTIBLE) && !ignore_invulnerable) //If we care about dense invulnerable objects
			return TRUE
		if(isobj(blocker) && !ignore_objects) //If we care about dense objects
			var/obj/obj_blocker = blocker
			if(!isstructure(obj_blocker)) //If it's not a structure and we care about objects, we have a block
				return TRUE
			var/obj/structure/blocker_structure = obj_blocker
			if(!blocker_structure.climbable) //If it's a structure and can't be climbed, we have a block
				return TRUE
		if(ismob(blocker) && !ignore_mobs) //If we care about mobs
			return TRUE

	return FALSE

/datum/action/xeno_action/timestop
	name = "Time stop"
	ability_name = "Time stop"
	action_icon_state = "time_stop"
	mechanics_text = "Freezes bullets in their course, and they will start to move again only after a certain time"
	plasma_cost = 200
	cooldown_timer = 1 MINUTES
	keybind_signal = COMSIG_XENOABILITY_TIMESTOP
	///The range of the ability
	var/range = 4
	///How long is the bullet freeze staying
	var/duration = 7 SECONDS

/datum/action/xeno_action/timestop/action_activate()
	. = ..()
	var/range_square = range * range
	var/list/turf/turfs_affected = list()
	var/turf/central_turf = get_turf(owner)
	for(var/turf/affected_turf in view(range, central_turf))
		if(get_dist_euclide_square(affected_turf, central_turf) > range_square)
			continue
		ADD_TRAIT(affected_turf, TRAIT_TURF_FREEZE_BULLET, REF(owner))
		turfs_affected += affected_turf
		affected_turf.add_filter("wraith_magic", 2, drop_shadow_filter(color = "#04080FAA", size = -10))
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE)
	succeed_activate()
	add_cooldown()
	var/mutable_appearance/MA = mutable_appearance('icons/effects/160x160.dmi', "time", FLY_LAYER, GAME_PLANE, 70)
	var/matrix/M = MA.transform
	M.Translate(-60, -50)
	MA.transform = M
	central_turf.add_overlay(MA)
	addtimer(CALLBACK(src, .proc/remove_bullet_freeze, turfs_affected, central_turf, MA), duration)
	addtimer(CALLBACK(src, .proc/play_sound_stop), duration - 3 SECONDS)

///Remove the bullet freeze effect on affected turfs
/datum/action/xeno_action/timestop/proc/remove_bullet_freeze(list/turf/turfs_affected, turf/central_turf, mutable_appearance/MA)
	central_turf.cut_overlay(MA)
	for(var/turf/affected_turf AS in turfs_affected)
		REMOVE_TRAIT(affected_turf, TRAIT_TURF_FREEZE_BULLET, REF(owner))
		if(HAS_TRAIT(affected_turf, TRAIT_TURF_FREEZE_BULLET))
			continue
		SEND_SIGNAL(affected_turf, COMSIG_TURF_RESUME_PROJECTILE_MOVE)
		affected_turf.remove_filter("wraith_magic")

///Play the end ability sound
/datum/action/xeno_action/timestop/proc/play_sound_stop()
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE, frequency = -1)

