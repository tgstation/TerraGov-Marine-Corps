GLOBAL_LIST_INIT(wraith_banish_very_short_duration_list, typecacheof(list(
	/obj/structure/barricade)))

// ***************************************
// *********** Place Warp Shadow
// ***************************************
/datum/action/xeno_action/place_warp_shadow
	name = "Place Warp Shadow"
	action_icon_state = "warp_shadow"
	mechanics_text = "Binds our psychic essence to a spot of our choosing. We can use Hyperposition to swap locations with this essence."
	plasma_cost = 150
	cooldown_timer = 60 SECONDS
	keybind_signal = COMSIG_XENOABILITY_PLACE_WARP_BEACON
	/// This is the warp shadow that the Wraith creates with its Place Warp Shadow ability, and teleports to with Hyperposition
	var/obj/effect/xenomorph/warp_shadow/warp_shadow

/datum/action/place_warp_shadow_data_storage_datum
	var/obj/effect/xenomorph/warp_shadow/warp_shadow

///Store all relevant variables to pass along
/datum/action/xeno_action/place_warp_shadow/on_xeno_pre_upgrade()
	var/datum/action/place_warp_shadow_data_storage_datum/storage_datum = new /datum/action/place_warp_shadow_data_storage_datum
	owner.actions_by_path[storage_datum.type] = storage_datum //store it in actions for reference later
	storage_datum.warp_shadow = warp_shadow

/datum/action/xeno_action/place_warp_shadow/on_xeno_upgrade()
	//Pass along relevant variables
	var/datum/action/place_warp_shadow_data_storage_datum/storage_datum = owner.actions_by_path[/datum/action/place_warp_shadow_data_storage_datum]
	warp_shadow = storage_datum.warp_shadow

	//Null out and delete the storage datum
	storage_datum.warp_shadow = null
	owner.actions_by_path[storage_datum.type] = null
	QDEL_NULL(storage_datum)

/datum/action/xeno_action/place_warp_shadow/give_action()
	. = ..()
	RegisterSignal(owner, COMSIG_XENOMORPH_DEATH, .proc/unset_warp_shadow) //Removes warp shadow on death

/datum/action/xeno_action/place_warp_shadow/action_activate()
	var/mob/living/carbon/xenomorph/wraith/ghost = owner

	ghost.visible_message("<span class='xenowarning'>The air starts to violently roil and shimmer around [ghost]!</span>", \
	"<span class='xenodanger'>We begin to imprint our essence upon reality, causing the air about us to roil and shimmer...</span>") //Fluff

	if(!do_after(ghost, WRAITH_PLACE_WARP_BEACON_WINDUP, TRUE, ghost, BUSY_ICON_BUILD)) //Channel time/wind up
		ghost.visible_message("<span class='xenowarning'>The space around [ghost] abruptly stops shifting and wavering.</span>", \
		"<span class='xenodanger'>We cease binding our essence to this place...</span>")
		add_cooldown(cooldown_override = WRAITH_PLACE_WARP_BEACON_FAIL_COOLDOWN_OVERRIDE)
		return fail_activate()

	var/turf/T = get_turf(ghost)
	ghost.visible_message("<span class='xenonotice'>\A shimmering point suddenly coalesces from the warped space above [T].</span>", \
	"<span class='xenodanger'>We complete our work, binding our essence to this point.</span>", null, 5) //Fluff
	var/obj/effect/xenomorph/warp_shadow/shadow = new(T) //Create the new warp shadow.
	playsound(T, 'sound/weapons/emitter.ogg', 25, 1)
	QDEL_NULL(warp_shadow) //Delete the old warp shadow
	warp_shadow = shadow //Set the new warp shadow
	RegisterSignal(warp_shadow, COMSIG_PARENT_PREQDELETED, .proc/unset_warp_shadow) //For var clean up
	RegisterSignal(owner, COMSIG_PARENT_PREQDELETED, .proc/unset_warp_shadow) //For var clean up
	warp_shadow.setDir(ghost.dir) //Have it imitate our facing
	warp_shadow.pixel_x = ghost.pixel_x //Inherit pixel offsets
	warp_shadow.pixel_y = ghost.pixel_y //Inherit pixel offsets
	teleport_debuff_aoe(warp_shadow) //SFX

	succeed_activate()
	add_cooldown()

///Nulls out the warp shadow
/datum/action/xeno_action/place_warp_shadow/proc/unset_warp_shadow()
	SIGNAL_HANDLER
	if(!warp_shadow) //In the event the parent dies without placing a shadow
		return
	UnregisterSignal(warp_shadow, COMSIG_PARENT_PREQDELETED)
	UnregisterSignal(owner, COMSIG_PARENT_PREQDELETED)
	QDEL_NULL(warp_shadow) //remove the actual shadow
	warp_shadow = null


/datum/action/xeno_action/place_warp_shadow/on_cooldown_finish()
	to_chat(owner, "<span class='xenonotice'>We are able to place another warp shadow.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Hyperposition
// ***************************************
/datum/action/xeno_action/hyperposition
	name = "Hyperposition"
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

	if(!warp_shadow_check.warp_shadow)
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We have no warp shadow to teleport to!</span>")
		return FALSE

	if(warp_shadow_check.warp_shadow.z != owner.z) //We must be on the same Z level to teleport to the warp shadow
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>Our warp shadow is beyond our ability to teleport to!</span>")
		return FALSE

/datum/action/xeno_action/hyperposition/action_activate()
	. = ..()
	var/datum/action/xeno_action/place_warp_shadow/warp_shadow_check = owner.actions_by_path[/datum/action/xeno_action/place_warp_shadow]
	var/obj/effect/xenomorph/warp_shadow/shadow = warp_shadow_check.warp_shadow

	var/area/A = get_area(shadow)

	var/distance = get_dist(owner, shadow) //Get the distance so we can calculate the wind up
	var/hyperposition_windup = clamp(distance * 0.5 SECONDS - 5 SECONDS, WRAITH_HYPERPOSITION_MIN_WINDUP, WRAITH_HYPERPOSITION_MAX_WINDUP)

	owner.visible_message("<span class='warning'>The air starts to violently roil and shimmer around [owner]!</span>", \
	"<span class='xenodanger'>We begin to teleport to our warp shadow located at [A] (X: [shadow.x], Y: [shadow.y]). We estimate this will take [hyperposition_windup * 0.1] seconds.</span>")

	owner.add_filter("wraith_hyperposition_windup_filter_1", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	owner.add_filter("wraith_hyperposition_windup_filter_2", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear

	animate(owner.get_filter("wraith_hyperposition_windup_filter_1"), x = 30*rand() - 15, y = 30*rand() - 15, time = 0.5 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	animate(owner.get_filter("wraith_hyperposition_windup_filter_2"), x = 30*rand() - 15, y = 30*rand() - 15, time = 0.5 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)

	if(!do_after(owner, hyperposition_windup, TRUE, owner, BUSY_ICON_FRIENDLY)) //Channel time/wind up
		owner.visible_message("<span class='xenowarning'>The space around [owner] abruptly stops shifting and wavering.</span>", \
		"<span class='xenodanger'>We abort teleporting back to our warp shadow.</span>")
		owner.remove_filter("wraith_hyperposition_windup_filter_1")
		owner.remove_filter("wraith_hyperposition_windup_filter_2")
		add_cooldown(cooldown_override = WRAITH_HYPERPOSITION_COOLDOWN_OVERRIDE)
		return fail_activate()

	owner.remove_filter("wraith_hyperposition_windup_filter_1")
	owner.remove_filter("wraith_hyperposition_windup_filter_2")

	if(!can_use_action()) //Check if we can actually position swap again due to the wind up delay.
		return fail_activate()

	var/beacon_turf = get_turf(shadow)

	shadow.forceMove(get_turf(owner)) //Move the beacon to where we are leaving
	shadow.dir = owner.dir //Have it imitate our facing
	shadow.pixel_x = owner.pixel_x //Inherit pixel offsets
	teleport_debuff_aoe(owner) //Apply tele debuff

	owner.forceMove(beacon_turf) //Move to where the beacon was
	teleport_debuff_aoe(owner) //Apply tele debuff

	owner.visible_message("<span class='warning'>\ [owner] suddenly vanishes in a vortex of warped space!</span>", \
	"<span class='xenodanger'>We teleport, swapping positions with our warp shadow. Our warp shadow has moved to  [AREACOORD_NO_Z(shadow)].</span>", null, 5) //Let user know the new location

	GLOB.round_statistics.wraith_hyperpositions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_hyperpositions") //Statistics
	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/hyperposition/on_cooldown_finish()
	to_chat(owner, "<span class='xenonotice'>We are able to swap locations with our warp shadow once again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Phase Shift
// ***************************************
/datum/action/xeno_action/phase_shift
	name = "Phase Shift"
	action_icon_state = "phase_shift"
	mechanics_text = "We force ourselves temporarily out of sync with reality, allowing us to become incorporeal and move through any physical obstacles for a short duration."
	plasma_cost = 75
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_PHASE_SHIFT
	var/turf/starting_turf = null
	var/phase_shift_active = FALSE
	var/phase_shift_duration_timer_id

/datum/action/phase_shift_data_storage_datum
	var/turf/starting_turf = null
	var/phase_shift_active = FALSE
	var/phase_shift_timer_duration

///Store all relevant variables to pass along
/datum/action/xeno_action/phase_shift/on_xeno_pre_upgrade()
	var/datum/action/phase_shift_data_storage_datum/storage_datum = new /datum/action/phase_shift_data_storage_datum
	owner.actions_by_path[storage_datum.type] = storage_datum //store it in actions for reference later
	storage_datum.starting_turf = starting_turf
	storage_datum.phase_shift_active = phase_shift_active
	storage_datum.phase_shift_timer_duration = timeleft(phase_shift_duration_timer_id)

/datum/action/xeno_action/phase_shift/on_xeno_upgrade()
	//Pass along relevant variables
	var/datum/action/phase_shift_data_storage_datum/storage_datum = owner.actions_by_path[/datum/action/phase_shift_data_storage_datum]
	starting_turf = storage_datum.starting_turf
	phase_shift_active = storage_datum.phase_shift_active
	if(phase_shift_active && storage_datum.phase_shift_timer_duration)
		phase_shift_duration_timer_id = addtimer(CALLBACK(src, .proc/phase_shift_deactivate), storage_datum.phase_shift_timer_duration, TIMER_STOPPABLE)

	//Null out and delete the storage datum
	storage_datum.starting_turf = null
	storage_datum.phase_shift_active = null
	storage_datum.phase_shift_timer_duration = null
	owner.actions_by_path[storage_datum.type] = null
	QDEL_NULL(storage_datum)

/datum/action/xeno_action/phase_shift/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/ghost = owner
	var/atom/movable/ghost_movable = owner

	ghost.visible_message("<span class='warning'>[ghost.name] is becoming faint and translucent!</span>", \
	"<span class='xenodanger'>We begin to move out of phase with reality....</span>") //Fluff

	ghost.do_jitter_animation(2000) //Animation

	ghost.add_filter("wraith_phase_shift_windup_1", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	ghost.add_filter("wraith_phase_shift_windup_2", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	animate(ghost.get_filter("wraith_phase_shift_windup_1"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	animate(ghost.get_filter("wraith_phase_shift_windup_2"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)

	if(!do_after(ghost, WRAITH_PHASE_SHIFT_WINDUP, TRUE, ghost, BUSY_ICON_FRIENDLY)) //Channel time/wind up
		ghost.visible_message("<span class='xenowarning'>[ghost]'s form abruptly consolidates, returning to normalcy.</span>", \
		"<span class='xenodanger'>We abort our desynchronization.</span>")
		ghost.remove_filter("wraith_phase_shift_windup_1")
		ghost.remove_filter("wraith_phase_shift_windup_2")
		return fail_activate()

	ghost.remove_filter("wraith_phase_shift_windup_1")
	ghost.remove_filter("wraith_phase_shift_windup_2")

	playsound(owner, "sound/effects/ghost.ogg", 25, 0, 1)

	addtimer(CALLBACK(src, .proc/phase_shift_warning), WRAITH_PHASE_SHIFT_DURATION * WRAITH_PHASE_SHIFT_DURATION_WARNING) //Warn them when Phase Shift is about to end
	phase_shift_duration_timer_id = addtimer(CALLBACK(src, .proc/phase_shift_deactivate), WRAITH_PHASE_SHIFT_DURATION, TIMER_STOPPABLE)
	ghost.add_filter("wraith_phase_shift", 4, list("type" = "blur", 5)) //Cool filter appear

	ghost_movable.generic_canpass = FALSE //So incorporeality is actually checked for collision
	ghost.status_flags = GODMODE | INCORPOREAL //Become temporarily invulnerable and incorporeal
	ghost.resistance_flags = RESIST_ALL
	ghost.density = FALSE
	ghost.throwpass = TRUE
	ghost.alpha = WRAITH_PHASE_SHIFT_ALPHA //Become translucent

	starting_turf = get_turf(ghost) //Get our starting turf so we can calculate the stun duration later.

	GLOB.round_statistics.wraith_phase_shifts++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_phase_shifts") //Statistics

	phase_shift_active = TRUE //Flag phase shift as being active
	succeed_activate()
	add_cooldown()

///Warns the user when Phase Shift is about to end.
/datum/action/xeno_action/phase_shift/proc/phase_shift_warning()

	if(!phase_shift_active) //If phase shift isn't active, cancel out
		return

	owner.alpha = WRAITH_PHASE_SHIFT_ALPHA * 1.5 //Become less translucent

	to_chat(owner,"<span class='highdanger'>We begin to move back into phase with reality... We can only remain out of phase for [WRAITH_PHASE_SHIFT_DURATION * (1-WRAITH_PHASE_SHIFT_DURATION_WARNING) * 0.1] more seconds!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Deactivates and turns off the Phase Shift ability/effects
/datum/action/xeno_action/phase_shift/proc/phase_shift_deactivate()
	if(!phase_shift_active) //If phase shift isn't active, don't deactivate again; generally here for the timed proc.
		return

	phase_shift_active = FALSE //Flag phase shift as being off

	var/mob/living/carbon/xenomorph/wraith/ghost = owner
	var/atom/movable/ghost_movable = owner

	ghost_movable.generic_canpass = initial(ghost_movable.generic_canpass)
	ghost.status_flags = initial(ghost.status_flags) //Become merely mortal again
	ghost.resistance_flags = initial(ghost.resistance_flags)
	ghost.density = initial(ghost.density)
	ghost.throwpass = initial(ghost.throwpass)
	ghost.alpha = initial(ghost.alpha) //Become opaque
	ghost.remove_filter("wraith_phase_shift") //Cool filter begone

	playsound(owner, "sound/effects/phasein.ogg", 25, 0, 1)

	ghost.add_filter("wraith_phase_shift_windup_1", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	ghost.add_filter("wraith_phase_shift_windup_2", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	animate(ghost.get_filter("wraith_phase_shift_windup_1"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	animate(ghost.get_filter("wraith_phase_shift_windup_2"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	addtimer(CALLBACK(ghost, /atom.proc/remove_filter, "wraith_phase_shift_windup_1"), 0.5 SECONDS)
	addtimer(CALLBACK(ghost, /atom.proc/remove_filter, "wraith_phase_shift_windup_2"), 0.5 SECONDS)

	var/current_turf = get_turf(ghost)

	if(isclosedturf(current_turf) || isspaceturf(current_turf)) //So we rematerialized in a solid wall/space for some reason; Darwin award winner folks.
		to_chat(ghost, "<span class='highdanger'>As we idiotically rematerialize in an obviously unsafe position, we revert to where we slipped out of reality at great cost.</span>")
		ghost.adjustFireLoss((ghost.health * 0.5), TRUE) //Lose half of our health
		ghost.Paralyze(5 SECONDS * XENO_PARALYZE_NORMALIZATION_MULTIPLIER) //That oughta teach them.
		ghost.forceMove(starting_turf)
		teleport_debuff_aoe(ghost) //Debuff when we reappear
		starting_turf = null
		return

	var/distance = get_dist(current_turf, starting_turf)
	var/phase_shift_stun_time = clamp(distance * 0.1 SECONDS, 0.5 SECONDS, 3 SECONDS) //Recovery time
	ghost.ParalyzeNoChain(phase_shift_stun_time * XENO_PARALYZE_NORMALIZATION_MULTIPLIER)
	ghost.visible_message("<span class='warning'>[ghost] form wavers and becomes opaque.</span>", \
	"<span class='highdanger'>We phase back into reality, our mind reeling from the experience. We estimate we will take [phase_shift_stun_time * 0.1] seconds to recover!</span>")

	starting_turf = null

/datum/action/xeno_action/phase_shift/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We are able to fade from reality again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()


// ***************************************
// *********** Resync
// ***************************************
/datum/action/xeno_action/resync
	name = "Resync"
	action_icon_state = "resync"
	mechanics_text = "Resynchronize with realspace, ending Phase Shift's effect."
	cooldown_timer = 1 SECONDS //Token for anti-spam
	keybind_signal = COMSIG_XENOABILITY_RESYNC

/datum/action/xeno_action/resync/can_use_action(silent = FALSE, override_flags)
	. = ..()

	if(!(owner.status_flags & INCORPOREAL))
		if(!silent)
			to_chat(owner,"<span class='xenodanger'>We are already synchronized with realspace!</span>")
		return FALSE

/datum/action/xeno_action/resync/action_activate()
	. = ..()

	var/datum/action/xeno_action/phase_shift/disable_shift = owner.actions_by_path[/datum/action/xeno_action/phase_shift]
	disable_shift.phase_shift_deactivate()

	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Blink
// ***************************************
/datum/action/xeno_action/activable/blink
	name = "Blink"
	action_icon_state = "blink"
	mechanics_text = "We teleport ourselves a short distance to a location within line of sight."
	use_state_flags = XABB_TURF_TARGET
	plasma_cost = 50
	cooldown_timer = 0.5 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BLINK

/datum/action/xeno_action/activable/blink/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(A)

	if(isclosedturf(T) || isspaceturf(T))
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We cannot blink here!</span>")
		return FALSE

	if(!owner.line_of_sight(T)) //Needs to be in line of sight.
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We can't blink without line of sight to our destination!</span>")
		return FALSE

	if(IS_OPAQUE_TURF(T))
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We can't blink into this space without vision!</span>")
		return FALSE

	for(var/atom/blocker as() in T)
		if(blocker.CanPass(owner, T))
			continue

		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We can't blink into a solid object!</span>")
		return FALSE

	if(owner.pulling) //We can't teleport into forbidden areas while pulling a mob
		var/area/target_area = get_area(T) //Have to set this as vars or is_type_in freaks out
		var/area/current_area = get_area(owner)
		if(is_type_in_typecache(target_area, GLOB.wraith_no_incorporeal_pass_areas) && !is_type_in_typecache(current_area, GLOB.wraith_no_incorporeal_pass_areas)) //If we're incorporeal via Phase Shift and we enter an off-limits area while not in one, it's time to stop
			if(!silent)
				to_chat(owner, "<span class='xenowarning'>We can't blink into this area from here while grabbing something!</span>")
			return FALSE


/datum/action/xeno_action/activable/blink/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/X = owner
	var/turf/T = X.loc
	var/turf/temp = X.loc

	for (var/x = 1 to WRAITH_BLINK_RANGE)
		temp = get_step(T, get_dir(T, A))
		if (!temp)
			break
		T = temp

	if(!can_use_ability(T)) //Since we updated the turf, check it again.
		return fail_activate()

	X.face_atom(T) //Face the target so we don't look like an ass

	var/cooldown_mod = 1
	var/mob/pulled_target = owner.pulling
	if(pulled_target) //bring the pulled target with us if applicable but at the cost of sharply increasing the next cooldown

		if(pulled_target.issamexenohive(X))
			cooldown_mod = WRAITH_BLINK_DRAG_FRIENDLY_MULTIPLIER
		else
			if(!do_after(owner, 0.5 SECONDS, TRUE, owner, BUSY_ICON_HOSTILE)) //Grap-porting hostiles has a slight wind up
				return fail_activate()
			cooldown_mod = WRAITH_BLINK_DRAG_NONFRIENDLY_MULTIPLIER

		to_chat(X, "<span class='xenodanger'>We bring [pulled_target] with us. We won't be ready to blink again for [cooldown_timer * cooldown_mod * 0.1] seconds due to the strain of doing so.</span>")

	teleport_debuff_aoe(X) //Debuff when we vanish

	if(pulled_target) //Yes, duplicate check because otherwise we end up with the initial teleport debuff AoE happening prior to the wind up which looks really bad and is actually exploitable via deliberate do after cancels
		pulled_target.forceMove(T) //Teleport to our target turf

	X.forceMove(T) //Teleport to our target turf
	teleport_debuff_aoe(X) //Debuff when we reappear

	succeed_activate()
	add_cooldown(cooldown_mod)

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
		animate(affected_tile.get_filter("wraith_blink_distortion"), x = 60*rand() - 30, y = 60*rand() - 30, time = 0.5 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
		addtimer(CALLBACK(affected_tile, /atom.proc/remove_filter, "wraith_blink_distortion"), 1 SECONDS)

		for(var/obj/obj_target in affected_tile) //This is just about SFX, so we don't have objects not distorting while everything else does
			obj_target.add_filter("wraith_aoe_debuff_filter", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
			animate(obj_target.get_filter("wraith_aoe_debuff_filter"), x = 60*rand() - 30, y = 60*rand() - 30, time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
			addtimer(CALLBACK(obj_target, /atom.proc/remove_filter, "wraith_aoe_debuff_filter"), 0.5 SECONDS)

		for(var/mob/living/living_target in affected_tile)
			living_target.add_filter("wraith_aoe_debuff_filter", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
			animate(living_target.get_filter("wraith_aoe_debuff_filter"), x = 60*rand() - 30, y = 60*rand() - 30, time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
			addtimer(CALLBACK(living_target, /atom.proc/remove_filter, "wraith_aoe_debuff_filter"), 0.5 SECONDS)

			if(living_target.stat == DEAD)
				continue

			if(isxeno(living_target))
				var/mob/living/carbon/xenomorph/X = living_target
				if(X.issamexenohive(ghost)) //No friendly fire
					continue

			shake_camera(living_target, 2, 1)
			living_target.adjust_stagger(WRAITH_TELEPORT_DEBUFF_STACKS)
			living_target.add_slowdown(WRAITH_TELEPORT_DEBUFF_STACKS)
			living_target.adjust_blurriness(WRAITH_TELEPORT_DEBUFF_STACKS) //minor visual distortion
			to_chat(living_target, "<span class='warning'>You feel nauseous as reality warps around you!</span>")

/datum/action/xeno_action/activable/blink/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We are able to blink again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Banish
// ***************************************
/datum/action/xeno_action/activable/banish
	name = "Banish"
	action_icon_state = "banish"
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
	///Luminosity of the banished target
	var/stored_luminosity

/datum/action/banish_data_storage_datum
	var/atom/movable/banishment_target
	var/obj/effect/temp_visual/banishment_portal/portal
	var/banish_timer_duration
	var/stored_luminosity

///Store all relevant variables to pass along so nothing breaks if we're banishing a target while upgrading/maturing
/datum/action/xeno_action/activable/banish/on_xeno_pre_upgrade()
	var/datum/action/banish_data_storage_datum/storage_datum = new /datum/action/banish_data_storage_datum
	owner.actions_by_path[storage_datum.type] = storage_datum //store it in actions for reference later
	storage_datum.banishment_target = banishment_target
	storage_datum.portal = portal
	storage_datum.stored_luminosity = stored_luminosity
	storage_datum.banish_timer_duration = timeleft(banish_duration_timer_id)

/datum/action/xeno_action/activable/banish/on_xeno_upgrade()
	//Pass along relevant variables
	var/datum/action/banish_data_storage_datum/storage_datum = owner.actions_by_path[/datum/action/banish_data_storage_datum]
	banishment_target = storage_datum.banishment_target
	portal = storage_datum.portal
	stored_luminosity = storage_datum.stored_luminosity
	if(banishment_target && storage_datum.banish_timer_duration) //set the remaining time for the banishment portal
		banish_duration_timer_id = addtimer(CALLBACK(src, .proc/banish_deactivate), storage_datum.banish_timer_duration, TIMER_STOPPABLE)

	//Null out and delete the storage datum
	storage_datum.banishment_target = null
	storage_datum.portal = null
	storage_datum.banish_timer_duration = null
	storage_datum.stored_luminosity = null
	owner.actions_by_path[storage_datum.type] = null
	QDEL_NULL(storage_datum)


/datum/action/xeno_action/activable/banish/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()

	if(!ismovableatom(A) || iseffect(A) || CHECK_BITFIELD(A.resistance_flags, INDESTRUCTIBLE)) //Cannot banish non-movables/things that are supposed to be invul; also we ignore effects
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We cannot banish this!</span>")
		return FALSE

	var/distance = get_dist(owner, A)
	if(distance > WRAITH_BANISH_RANGE) //Needs to be in range.
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>Our target is too far away! It must be [distance - WRAITH_BANISH_RANGE] tiles closer!</span>")
		return FALSE

	if(!owner.line_of_sight(A)) //Needs to be in line of sight.
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>We can't banish without line of sight to our target!</span>")
		return FALSE

/datum/action/xeno_action/activable/banish/use_ability(atom/movable/A)
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/ghost = owner
	var/banished_turf = get_turf(A) //Set the banishment turf.
	banishment_target = A //Set the banishment target

	ghost.face_atom(A) //Face the target so we don't look like an ass

	teleport_debuff_aoe(banishment_target) //Debuff when we disappear
	portal = new /obj/effect/temp_visual/banishment_portal(banished_turf)
	banishment_target.forceMove(portal) //Banish the target to Brazil; yes he's going there
	banishment_target.resistance_flags = RESIST_ALL
	stored_luminosity = banishment_target.luminosity //Store the target's luminosity
	banishment_target.luminosity = 0 //Zero out the target's lights
	if(isliving(A))
		var/mob/living/stasis_target = banishment_target
		stasis_target.apply_status_effect(/datum/status_effect/incapacitating/unconscious) //Force the target to KO
		stasis_target.notransform = TRUE //Stasis
		stasis_target.overlay_fullscreen("banish", /obj/screen/fullscreen/blind) //Force the blind overlay

	var/duration = WRAITH_BANISH_BASE_DURATION //Set the duration

	portal.add_filter("banish_portal_1", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	portal.add_filter("banish_portal_2", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	animate(portal.get_filter("banish_portal_1"), x = 20*rand() - 10, y = 20*rand() - 10, time = 0.5 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	animate(portal.get_filter("banish_portal_2"), x = 20*rand() - 10, y = 20*rand() - 10, time = 0.5 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)

	if(isliving(banishment_target) && !(banishment_target.issamexenohive(ghost))) //We halve the max duration for living non-allies
		duration *= WRAITH_BANISH_NONFRIENDLY_LIVING_MULTIPLIER

	else if(is_type_in_typecache(banishment_target, GLOB.wraith_banish_very_short_duration_list)) //Barricades should only be gone long enough to admit an infiltrator xeno or two; one way.
		duration *= WRAITH_BANISH_VERY_SHORT_MULTIPLIER

	banishment_target.visible_message("<span class='warning'>Space abruptly twists and warps around [banishment_target] as it suddenly vanishes!</span>", \
	"<span class='highdanger'>The world around you reels, reality seeming to twist and tear until you find yourself trapped in a forsaken void beyond space and time.</span>")
	playsound(banished_turf, 'sound/weapons/emitter2.ogg', 50, 1) //this isn't quiet

	to_chat(ghost,"<span class='xenodanger'>We have banished [banishment_target] to nullspace for [duration * 0.1] seconds.</span>")

	addtimer(CALLBACK(src, .proc/banish_warning), duration * 0.7) //Warn when Banish is about to end
	banish_duration_timer_id = addtimer(CALLBACK(src, .proc/banish_deactivate), duration, TIMER_STOPPABLE) //store the timer ID

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.wraith_banishes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_banishes") //Statistics

///Warns the user when Banish's duration is about to lapse.
/datum/action/xeno_action/activable/banish/proc/banish_warning()

	if(!banishment_target)
		return

	to_chat(owner,"<span class='highdanger'>Our banishment target [banishment_target.name] is about to return to reality at [AREACOORD_NO_Z(portal)]!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Ends the effect of the Banish ability
/datum/action/xeno_action/activable/banish/proc/banish_deactivate()
	SIGNAL_HANDLER
	if(!banishment_target)
		return

	banishment_target.forceMove(get_turf(portal))
	banishment_target.resistance_flags = initial(banishment_target.resistance_flags)
	teleport_debuff_aoe(banishment_target) //Debuff/distortion when we reappear
	banishment_target.add_filter("wraith_banishment_filter", 3, list("type" = "blur", 5)) //Cool filter appear
	banishment_target.luminosity = stored_luminosity
	addtimer(CALLBACK(banishment_target, /atom.proc/remove_filter, "wraith_banishment_filter"), 1 SECONDS) //1 sec blur duration

	if(isliving(banishment_target))
		var/mob/living/living_target = banishment_target
		living_target = banishment_target
		living_target.status_flags = initial(living_target.status_flags) //Remove stasis and temp invulerability
		living_target.remove_status_effect(/datum/status_effect/incapacitating/unconscious) //Force the target to KO
		living_target.notransform = initial(living_target.notransform)
		living_target.clear_fullscreen("banish") //Remove the blind overlay

	banishment_target.visible_message("<span class='warning'>[banishment_target.name] abruptly reappears!</span>", \
	"<span class='warning'>You suddenly reappear back in what you believe to be reality.</span>")

	to_chat(owner, "<span class='highdanger'>Our target [banishment_target] has returned to reality at [AREACOORD_NO_Z(banishment_target)]</span>") //Always alert the Wraith


	QDEL_NULL(portal) //Eliminate the Brazil portal if we need to

	banishment_target = null

	return TRUE //For the recall sub-ability

/datum/action/xeno_action/activable/banish/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We are able to banish again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Recall
// ***************************************
/datum/action/xeno_action/recall
	name = "Recall"
	action_icon_state = "recall"
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
			to_chat(owner,"<span class='xenodanger'>We have no targets banished!</span>")
		return FALSE


/datum/action/xeno_action/recall/action_activate()
	. = ..()
	var/datum/action/xeno_action/activable/banish/banish_check = owner.actions_by_path[/datum/action/xeno_action/activable/banish]
	banish_check.banish_deactivate()
	succeed_activate()
	add_cooldown()

