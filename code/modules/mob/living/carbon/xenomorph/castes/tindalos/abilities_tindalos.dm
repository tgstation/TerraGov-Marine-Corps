// ***************************************
// *********** Place Warp Beacon
// ***************************************
/datum/action/xeno_action/place_warp_beacon
	name = "Place Warp Beacon"
	action_icon_state = "oldbuild_tunnel"
	mechanics_text = "Binds our psychic essence to a spot of our choosing. We can use Hyperposition to swap locations with this essence."
	plasma_cost = TINDALOS_PLACE_WARP_BEACON_PLASMA_COST
	cooldown_timer = TINDALOS_PLACE_WARP_BEACON_COOLDOWN
	keybind_signal = COMSIG_XENOABILITY_PLACE_WARP_BEACON

/datum/action/xeno_action/place_warp_beacon/action_activate()
	var/mob/living/carbon/xenomorph/tindalos/TI = owner

	TI.visible_message("<span class='xenowarning'>The air starts to violently roil and shimmer around [TI]!</span>", \
	"<span class='xenodanger'>We begin to imprint our essence upon reality, causing the air about us to roil and shimmer...</span>") //Fluff

	if(!do_after(TI, TINDALOS_PLACE_WARP_BEACON_WINDUP, TRUE, TI, BUSY_ICON_BUILD)) //Channel time/wind up
		TI.visible_message("<span class='xenowarning'>The space around [TI] abruptly stops shifting and wavering.</span>", \
		"<span class='xenodanger'>We cease binding our essence to this place...</span>")
		return fail_activate()

	var/turf/T = get_turf(TI)
	TI.visible_message("<span class='xenonotice'>\A shimmering point suddenly coalesces from the warped space around [T].</span>", \
	"<span class='xenodanger'>We complete our work, binding our essence to this point.</span>", null, 5) //Fluff
	var/obj/effect/alien/warp_beacon/WB = new(T) //Create the new beacon.
	playsound(T, 'sound/weapons/emitter.ogg', 25, 1)
	TI.warp_beacon = WB //Set our warp beacon

	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Hyperposition
// ***************************************
/datum/action/xeno_action/hyperposition
	name = "Hyperposition"
	action_icon_state = "hyperposition"
	mechanics_text = "We teleport back to our warp beacon after a delay. The delay scales with the distance teleported."
	plasma_cost = TINDALOS_HYPERPOSITION_PLASMA_COST
	cooldown_timer = TINDALOS_HYPERPOSITION_COOLDOWN
	keybind_signal = COMSIG_XENOABILITY_HYPERPOSITION


/datum/action/xeno_action/hyperposition/action_activate()

	var/mob/living/carbon/xenomorph/tindalos/TI = owner
	var/obj/effect/alien/warp_beacon/WB = TI.warp_beacon

	if(!WB)
		to_chat(TI, "<span class='xenodanger'>We have no warp beacon to teleport to!</span>")

	var/area/A = get_area(WB)

	TI.do_jitter_animation(2000) //Animation

	var/distance = get_dist(TI, TI.warp_beacon) //Get the distance so we can calculate the wind up
	var/hyperposition_windup = clamp(TINDALOS_HYPERPOSITION_MIN_WINDUP, distance * 0.5 SECONDS - 10 SECONDS, TINDALOS_HYPERPOSITION_MAX_WINDUP)

	TI.visible_message("<span class='warning'>The air starts to violently roil and shimmer around [TI]!</span>", \
	"<span class='xenodanger'>We begin to teleport to our warp beacon located at [A] (X: [WB.x], Y: [WB.y]). We estimate this will take [hyperposition_windup * 0.1] seconds.</span>")

	if(!do_after(TI, hyperposition_windup, TRUE, TI, BUSY_ICON_FRIENDLY)) //Channel time/wind up
		TI.visible_message("<span class='xenowarning'>The space around [TI] abruptly stops shifting and wavering.</span>", \
		"<span class='xenodanger'>We abort teleporting back to our warp beacon.</span>")
		return fail_activate()


	hyperposition_warp() //We swap positions with our warp beacon

	succeed_activate()
	GLOB.round_statistics.tindalos_hyperpositions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "tindalos_hyperpositions") //Statistics

	add_cooldown()

/datum/action/xeno_action/hyperposition/proc/hyperposition_warp() //This handles the location swap between the Tindalos and the Warp Beacon

	var/mob/living/carbon/xenomorph/tindalos/TI = owner
	var/obj/effect/alien/warp_beacon/WB = TI.warp_beacon
	var/beacon_turf = get_turf(WB)
	var/tindalos_turf = get_turf(TI)

	if(!TI) //Sanity
		return FALSE

	if(!WB)
		to_chat(TI, "<span class='xenodanger'>We have no warp beacon to teleport to!</span>")
		return FALSE

	if(!beacon_turf || !tindalos_turf)
		to_chat(TI, "<span class='xenodanger'>Our warp beacon is currently beyond our power to influence!</span>")
		return FALSE

	WB.forceMove(tindalos_turf) //Move the beacon to where we are leaving
	teleport_debuff_aoe(TI) //Apply tele debuff

	TI.forceMove(beacon_turf) //Move to where the beacon was
	teleport_debuff_aoe(TI) //Apply tele debuff

	var/area/A = get_area(WB)
	TI.visible_message("<span class='warning'>\ [TI] suddenly vanishes in a bleak cloud of warped space!</span>", \
	"<span class='xenonotice'>We teleport, swapping positions with our warp beacon. Our warp beacon has moved to [A] (X: [WB.x], Y: [WB.y]).</span>", null, 5) //Let user know the new location


// ***************************************
// *********** Phase Shift
// ***************************************
/datum/action/xeno_action/phase_shift
	name = "Phase Shift"
	action_icon_state = "stealth_on"
	mechanics_text = "We force ourselves temporarily out of sync with reality, allowing us to become incorporeal and move through any physical obstacles for a short duration."
	plasma_cost = TINDALOS_PHASE_SHIFT_PLASMA_COST
	cooldown_timer = TINDALOS_PHASE_SHIFT_COOLDOWN
	keybind_signal = COMSIG_XENOABILITY_PHASE_SHIFT
	var/turf/starting_turf = null


/datum/action/xeno_action/phase_shift/action_activate()
	var/mob/living/carbon/xenomorph/tindalos/TI = owner

	TI.visible_message("<span class='warning'>[TI.name] is becoming faint and translucent!</span>", \
	"<span class='xenodanger'>We begin to move out of phase with reality....</span>") //Fluff

	TI.do_jitter_animation(2000) //Animation

	if(!do_after(TI, TINDALOS_PHASE_SHIFT_WINDUP, TRUE, TI, BUSY_ICON_FRIENDLY)) //Channel time/wind up
		TI.visible_message("<span class='xenowarning'>[TI]'s form abruptly consolidates, returning to normalcy.</span>", \
		"<span class='xenodanger'>We abort our desynchronization.</span>")
		return fail_activate()

	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, TI, "<span class='highdanger'>We begin to move back into phase with reality...</span>"), TINDALOS_PHASE_SHIFT_DURATION * 0.7) //Warn them when Phase Shift is about to end
	addtimer(CALLBACK(TI, /mob/.proc/playsound_local, TI, 'sound/voice/hiss4.ogg', 50), TINDALOS_PHASE_SHIFT_DURATION * 0.7)
	addtimer(CALLBACK(src, .proc/phase_shift_deactivate), TINDALOS_PHASE_SHIFT_DURATION)

	TI.status_flags = GODMODE | INCORPOREAL //Become temporarily invulnerable and incorporeal
	TI.resistance_flags = RESIST_ALL
	TI.density = FALSE
	TI.throwpass = TRUE
	TI.alpha = TINDALOS_PHASE_SHIFT_ALPHA //Become translucent
	succeed_activate()
	starting_turf = get_turf(TI) //Get our starting turf so we can calculate the stun duration later.

	GLOB.round_statistics.tindalos_phase_shifts++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "tindalos_phase_shifts") //Statistics

	add_cooldown()


/datum/action/xeno_action/phase_shift/proc/phase_shift_deactivate()

	var/mob/living/carbon/xenomorph/tindalos/TI = owner

	if(!TI) //Sanity
		return

	TI.status_flags = initial(TI.status_flags) //Become merely mortal again
	TI.resistance_flags = initial(TI.resistance_flags)
	TI.density = initial(TI.density)
	TI.throwpass = initial(TI.throwpass)
	TI.alpha = initial(TI.alpha) //Become opaque

	playsound(owner, "sound/effects/escape_pod_launch.ogg", 25, 0, 1)

	var/current_turf = get_turf(TI)

	if(isclosedturf(current_turf) || isspaceturf(current_turf)) //So we rematerialized in a solid wall/space for some reason; Darwin award winner folks.
		to_chat(owner, "<span class='highdanger'>As we idiotically rematerialize in an obviously unsafe position, we revert to where we slipped out of reality through sheer instinct, albeit at great cost.</span>")
		TI.apply_damage(TI.health - 1, BURN) //1 HP left
		TI.Stun(10 SECONDS) //That oughta teach them.
		TI.forceMove(starting_turf)
		starting_turf = null
		return

	var/distance = get_dist(current_turf, starting_turf)
	var/phase_shift_stun_time = clamp(1 SECONDS, distance * 0.1 SECONDS, 3 SECONDS) //Recovery time
	TI.Stun(phase_shift_stun_time * 2)

	TI.visible_message("<span class='warning'>[TI.name] form wavers and becomes opaque.</span>", \
	"<span class='highdanger'>We phase back into reality, our mind reeling from the experience. We estimate we will take [phase_shift_stun_time * 0.1] seconds to recover!</span>")

	starting_turf = null

/datum/action/xeno_action/evasion/on_cooldown_finish()
	to_chat(owner, "<span class='xenonotice'>We are able to take evasive action again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()


// ***************************************
// *********** Blink
// ***************************************
/datum/action/xeno_action/activable/blink
	name = "Blink"
	action_icon_state = "blink"
	mechanics_text = "We teleport ourselves a short distance to a location within line of sight."
	use_state_flags = XABB_TURF_TARGET
	plasma_cost = TINDALOS_BLINK_PLASMA_COST
	cooldown_timer = TINDALOS_BLINK_COOLDOWN
	keybind_signal = COMSIG_XENOABILITY_BLINK

/datum/action/xeno_action/activable/blink/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(A)

	if(!T)
		to_chat(owner, "<span class='xenowarning'>Even we cannot go there!</span>")
		return FALSE

	var/distance = get_dist(owner, T)
	if(distance > TINDALOS_BLINK_RANGE) //Needs to be in range.
		to_chat(owner, "<span class='xenowarning'>Our destination is too far away! It must be [distance - TINDALOS_BLINK_RANGE] tiles closer!</span>")
		return FALSE

	if(!owner.line_of_sight(T)) //Needs to be in line of sight.
		to_chat(owner, "<span class='xenowarning'>We can't blink without line of sight to our destination!</span>")
		return FALSE

/datum/action/xeno_action/activable/blink/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/tindalos/TI = owner
	var/turf/T = get_turf(A)
	var/mob/pulled

	if(ismob(TI.pulling)) //bring the target we're pulling with us, but at the cost of sharply increasing the next cooldown
		pulled = TI.pulling

	blink_warp(TI, T, pulled)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.tindalos_blinks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "tindalos_blinks") //Statistics


/datum/action/xeno_action/activable/blink/proc/blink_warp(mob/living/carbon/xenomorph/tindalos/TI, turf/T, mob/pulled = null) //This handles the location swap between the Tindalos and the Warp Beacon

	TI.face_atom(T) //Face the target so we don't look like an ass

	teleport_debuff_aoe(TI) //Debuff when we vanish

	TI.forceMove(T) //Teleport to our target turf

	if(pulled) //bring the pulled target with us if applicable
		cooldown_timer *= TINDALOS_BLINK_DRAG_MULTIPLIER
		to_chat(TI, "<span class='xenodanger'>We bring [pulled.name] with us. We won't be ready to blink again for [cooldown_timer * 0.1] seconds due to the strain of doing so.</span>")

	teleport_debuff_aoe(TI) //Debuff when we reappear


/datum/action/xeno_action/proc/teleport_debuff_aoe(atom/movable/teleporter) //Called by many of the Tindalos' teleportation effects

	if(!teleporter) //Sanity
		return

	var/mob/living/carbon/xenomorph/source = owner

	playsound(teleporter, 'sound/effects/bamf.ogg', 25, 1) //Sound at the location we are arriving at
	new /obj/effect/temp_visual/blink_portal(get_turf(teleporter))

	for(var/turf/affected_tile in range(1,teleporter.loc))
		affected_tile.Shake(4, 4, 1 SECONDS) //SFX
		for(var/mob/living/target in affected_tile)
			target.Shake(4, 4, 1 SECONDS) //SFX
			if(target.stat == DEAD)
				continue
			if(isxeno(target))
				var/mob/living/carbon/xenomorph/X = target
				if(X.hive == source.hive) //No friendly fire
					continue

			shake_camera(target, 2, 1)
			target.adjust_stagger(TINDALOS_TELEPORT_DEBUFF_STACKS)
			target.add_slowdown(TINDALOS_TELEPORT_DEBUFF_STACKS)
			target.adjust_drugginess(TINDALOS_TELEPORT_DEBUFF_STACKS) //minor visual distortion
			to_chat(target, TINDALOS_TELEPORT_DEBUFF_MSG)

/datum/action/xeno_action/evasion/on_cooldown_finish()
	if(cooldown_timer > TINDALOS_BLINK_COOLDOWN) //Reset the cooldown if increased from dragging someone.
		to_chat(owner, "<span class='xenonotice'>We are able to take blink again.</span>")
		owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
		cooldown_timer = TINDALOS_BLINK_COOLDOWN
	return ..()
// ***************************************
// *********** Banish
// ***************************************
/datum/action/xeno_action/activable/banish
	name = "Banish"
	action_icon_state = "banish"
	mechanics_text = "We banish a target object or creature within line of sight to nullspace for a short duration. Can target onself and allies."
	use_state_flags = XACT_TARGET_SELF
	plasma_cost = TINDALOS_BANISH_PLASMA_COST
	cooldown_timer = TINDALOS_BANISH_COOLDOWN
	keybind_signal = COMSIG_XENOABILITY_BANISH
	var/turf/banished_turf = null //The turf the target was banished on
	var/atom/movable/banishment_target = null //Target we've banished

/datum/action/xeno_action/activable/banish/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()

	if(!ismovable(A) || A.resistance_flags == RESIST_ALL) //Cannot banish non-movables/things that are supposed to be invul
		to_chat(owner, "<span class='xenowarning'>We cannot banish this!</span>")
		return FALSE

	var/distance = get_dist(owner, A)
	if(distance > TINDALOS_BANISH_RANGE) //Needs to be in range.
		to_chat(owner, "<span class='xenowarning'>Our target is too far away! It must be [distance - TINDALOS_BANISH_RANGE] tiles closer!</span>")
		return FALSE

	if(!owner.line_of_sight(A)) //Needs to be in line of sight.
		to_chat(owner, "<span class='xenowarning'>We can't banish without line of sight to our target!</span>")
		return FALSE

/datum/action/xeno_action/activable/banish/use_ability(atom/movable/A)
	var/mob/living/carbon/xenomorph/tindalos/TI = owner
	banished_turf = get_turf(A) //Set the banishment turf.
	banishment_target = A //Set the banishment target

	TI.face_atom(A) //Face the target so we don't look like an ass

	teleport_debuff_aoe(banishment_target) //Debuff when we reappear
	banishment_target.moveToNullspace() //Banish the target to Brazil; yes he's going there
	new /obj/effect/temp_visual/banishment_portal(banished_turf)

	var/duration = TINDALOS_BANISH_BASE_DURATION //Set the duration

	if(isxeno(banishment_target) ) //We halve the max duration for living non-allies
		var/mob/living/carbon/xenomorph/X = banishment_target
		if(X.hive != TI.hive) //Enemy hive
			duration *= 0.5

	else if(isliving(banishment_target) ) //We halve the max duration for living non-allies
		duration *= 0.5

	banishment_target.visible_message("<span class='warning'>Space abruptly twists and warps around [banishment_target.name] as it suddenly vanishes!</span>", \
	"<span class='highdanger'>The world around you spin wildly, reality seeming to twist and tear until you find yourself in a forsaken place beyond space and time.</span>")
	playsound(banished_turf, 'sound/weapons/emitter2.ogg', 50, 1) //this isn't quiet

	to_chat(TI,"<span class='xenodanger'>We have banished [banishment_target.name] to nullspace for [duration * 0.1] seconds.</span>")

	addtimer(CALLBACK(src, .proc/banish_warning), duration * 0.7) //Warn when Banish is about to end
	addtimer(CALLBACK(src, .proc/banish_deactivate), duration)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.tindalos_banishes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "tindalos_banishes") //Statistics

/datum/action/xeno_action/activable/banish/proc/banish_warning()
	var/mob/living/carbon/xenomorph/tindalos/TI = owner

	if(!TI) //Sanity
		return

	if(!banished_turf || !banishment_target)
		return

	to_chat(TI,"<span class='highdanger'>Our banishment target [banishment_target.name] is about to return!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)


/datum/action/xeno_action/activable/banish/proc/banish_deactivate()

	var/mob/living/carbon/xenomorph/tindalos/TI = owner

	if(!TI) //Sanity
		return

	if(!banished_turf || !banishment_target)
		return

	banishment_target.forceMove(banished_turf)
	teleport_debuff_aoe(banishment_target) //Debuff/distortion when we reappear

	banishment_target.visible_message("<span class='warning'>[banishment_target.name] abruptly reappears!</span>", \
	"<span class='warning'>You suddenly rematerialize back in what you believe to be reality. It takes you a moment to regain your bearings.</span>")

	if(isliving(banishment_target))
		var/mob/living/L = banishment_target
		var/stun_time = 1 SECONDS
		if(isxeno(L))
			stun_time *= 2 //Compensate for halved stun time
		L.Stun(stun_time) //Short stun upon returning to reality

	to_chat(TI, "<span class='xenodanger'>Our target [banishment_target.name] has returned to reality.</span>") //Always alert the Tindalos

	banishment_target = null //Clear vars
	banished_turf = null

// ***************************************
// *********** Recall
// ***************************************
/datum/action/xeno_action/recall
	name = "Recall"
	action_icon_state = "recall"
	mechanics_text = "We recall a target we've banished back from the depths of nullspace."
	use_state_flags = XACT_USE_NOTTURF //So we can recall ourselves from nether Brazil
	cooldown_timer = 1 SECONDS //Token for anti-spam
	keybind_signal = COMSIG_XENOABILITY_RECALL


/datum/action/xeno_action/recall/action_activate()

	var/mob/living/carbon/xenomorph/tindalos/TI = owner

	var/datum/action/xeno_action/activable/banish/B = locate(/datum/action/xeno_action/activable/banish) in TI.xeno_abilities

	B.banish_deactivate() //manual deactivate
	succeed_activate()
	add_cooldown()

