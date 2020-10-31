/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."
// ***************************************
// *********** Reposition Core
// ***************************************
/datum/action/xeno_action/activable/reposition_core
	name = "Reposition Core"
	action_icon_state = "emit_neurogas"
	mechanics_text = "Reposition your core to a target location on weeds. The further away the location is the longer this will take up to a maximum of 60 seconds. 3 minute cooldown."
	ability_name = "reposition core"
	plasma_cost = 150
	cooldown_timer = 180 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_REPOSITION_CORE

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/reposition_core/on_cooldown_finish()
	owner.playsound_local(owner.loc, 'sound/voice/alien_drool1.ogg', 50, TRUE)
	to_chat(owner, "<span class='xenonotice'>We regain the strength to reposition our neural core.</span>")
	return ..()

/datum/action/xeno_action/activable/reposition_core/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/hivemind/X = owner
	var/obj/effect/alien/hivemindcore/core = X.core
	var/turf/target_turf = get_turf(X)
	var/distance = get_dist(target_turf, get_turf(core))

	var/delay = max(HIVEMIND_REPOSITION_CORE_DELAY_MIN, HIVEMIND_REPOSITION_CORE_DELAY_MOD * distance) //Calculate the distance scaling delay before we complete the reposition


	if(!check_build_location(target_turf, X)) //Check target turf for suitability
		return fail_activate()
	to_chat(owner, "<span class='xenodanger'>We begin the process of transfering our consciousness... We estimate this will require [delay * 0.1] seconds.</span>")

	succeed_activate()
	if(!do_after(X, delay, TRUE, null, BUSY_ICON_BUILD))
		if(!QDELETED(src))
			to_chat(X, "<span class='xenodanger'>We abort transferring our consciousness, expending our precious plasma for naught.</span>")
			return fail_activate()

	if(!check_build_location(target_turf, X)) //Check target turf for suitability after completion
		return fail_activate()

	core.forceMove(get_turf(target_turf)) //Move the core
	core.obj_integrity = core.max_integrity //Reset the core's health
	to_chat(owner, "<span class='xenodanger'>We succeed in transferring our consciousness to a new neural core!</span>")

	add_cooldown()

	GLOB.round_statistics.hivemind_reposition_core_uses++ //Increment the statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivemind_reposition_core_uses")

	if(!is_centcom_level(core))
		var/area/core_new_area = get_area(core)
		xeno_message("Hive: \The [X] has <b>transferred its core</b>[A? " to [sanitize(core_new_area.name)]":""]!", 3, X.hivenumber) //Let the hive know the Hivemind's new location.

/datum/action/xeno_action/activable/reposition_core/proc/check_build_location(turf/target_turf, mob/living/carbon/xenomorph/hivemind/X)

	if(!X || !target_turf) //Sanity
		return FALSE

	if(target_turf.density) //Check to see if there's room
		to_chat(X, "<span class='xenodanger'>We require adequate room to transfer our core.</span>")
		return FALSE

	var/obj/effect/alien/weeds/W = locate() in range(0, target_turf) //Make sure we actually have weeds at our destination.
	if(!W)
		to_chat(X, "<span class='xenodanger'>There are no weeds for us to transfer our consciousness to!</span>")
		return FALSE

	for(var/obj/structure/O in target_turf.contents)
		if(O.density && !(O.flags_atom = ON_BORDER))
			to_chat(X, "<span class='xenodanger'>An object is occupying this space!</span>")
			return FALSE

	return TRUE



// ***************************************
// *********** Mind Wrack
// ***************************************
/datum/action/xeno_action/activable/mind_wrack
	name = "Mind Wrack"
	action_icon_state = "screech"
	mechanics_text = "Afflicts the target's mind with disorienting and painful psychic energy. Effect is greater the closer the target is to your core, and the more xenos that are within 3 tiles when used."
	ability_name = "mind wrack"
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_MIND_WRACK
	cooldown_timer = 30 SECONDS

/datum/action/xeno_action/activable/mind_wrack/on_cooldown_finish()
	owner.playsound_local(owner.loc, 'sound/voice/alien_drool1.ogg', 50, TRUE)
	to_chat(owner, "<span class='xenonotice'>We regain the strength to assault the minds of our enemies.</span>")
	return ..()


/datum/action/xeno_action/activable/mind_wrack/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/hivemind/X = owner
	var/mob/living/carbon/victim = A

	if(!istype(victim) )
		return FALSE

	if(victim.stat == DEAD)
		to_chat(X, "<span class='xenonotice'>Even we cannot touch the minds of the dead...</span>")
		return FALSE

	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/alien = victim
		if(alien.hivenumber == X.hivenumber)
			to_chat(X, "<span class='xenonotice'>We would not assail the minds of our sisters!</span>")
			return FALSE

	if(!X.line_of_sight(victim))
		to_chat(X, "<span class='xenowarning'>We can't focus our psychic energy properly without a clear line of sight!</span>")
		return FALSE

	var/distance = get_dist(X, victim)
	if(distance > 7)
		to_chat(X, "<span class='xenowarning'>They are too far for us to reach their minds! The target must be [distance - 7] tiles closer!</spam>")

	var/power_level //What does the scouter say about it?
	for(var/mob/living/carbon/xenomorph/ally in range(HIVEMIND_MIND_WRACK_POWER_CHORUS_RANGE, X ) ) //For each friendly xeno nearby, effect is more powerful
		if(istype(ally) && ally.hivenumber == X.hivenumber)
			++power_level //Increment the power level for each Xeno nearby
		if(power_level > HIVEMIND_MIND_WRACK_POWER_MAX_CHORUS)
			break

	for(var/obj/effect/alien/hivemindcore/node_core in range(HIVEMIND_MIND_WRACK_POWER_CHORUS_RANGE, get_turf(X) ) ) //If our core is nearby, the effect is *especially* powerful.
		if(node_core == X.core)
			power_level = max(power_level, power_level + 2)

	if(power_level < 2) //We need at least one core or xeno other than us.
		to_chat(owner, "<span class='xenodanger'>We require our core or a sister nearby to relay our psychic energy!</span>")
		return FALSE

	succeed_activate()

	var/proximity_offset = get_dist(get_turf(victim), get_turf(X.core) ) //Effect is more powerful the closer the target is to the core, and less powerful the further away it is
	proximity_offset = clamp(-100, (HIVEMIND_MIND_WRACK_POWER_DISTANCE - proximity_offset) * 5, 100)

	power_level = clamp(HIVEMIND_MIND_WRACK_POWER_MINIMUM, power_level * HIVEMIND_MIND_WRACK_POWER_MULTIPLIER + proximity_offset, HIVEMIND_MIND_WRACK_POWER_MAXIMUM)

	X.playsound_local(X.loc, 'sound/magic/invoke_general.ogg', 50, TRUE)
	victim.playsound_local(victim.loc, pick('sound/voice/alien_distantroar_3.ogg','sound/voice/alien_queen_command.ogg','sound/voice/alien_queen_command2.ogg','sound/voice/alien_queen_command3.ogg'), 50, TRUE)
	to_chat(X, "<span class='danger'>We scour the mind of this unfortunate creature with [calculate_power(power_level, X)] power.</span>")
	to_chat(victim, "<span class='danger'>Your mind is suddenly overwhelmed by alien thoughts as unworldly screaming fills your ears. Your brain feels as though it's on fire and your world convulses!</span>")
	new /obj/effect/temp_visual/telepathy(get_turf(victim))
	shake_camera(victim, power_level * 0.01 SECONDS, 1)
	victim.ParalyzeNoChain(0.5 SECONDS)
	victim.hallucination = clamp(power_level, victim.hallucination + power_level, 200) //I want the hallucination effect to *eventually* go away; capped at 200 stacks.
	victim.Confused(power_level * 0.025)
	victim.set_drugginess(power_level * 0.025) //visuals
	victim.adjustStaminaLoss(power_level * 0.25)
	victim.adjustBrainLoss(power_level * 0.2, TRUE) //dain brammage
	victim.adjust_stagger(power_level * 0.05)
	victim.add_slowdown(power_level * 0.05)

	add_cooldown()

	GLOB.round_statistics.hivemind_mind_wrack_uses++ //Increment the statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivemind_reposition_wrack_uses")


/datum/action/xeno_action/activable/mind_wrack/proc/calculate_power(power_level, mob/living/carbon/xenomorph/hivemind/X)
	. = ..()
	if(isnull(X))
		return
	switch(power_level)
		if(0 to HIVEMIND_MIND_WRACK_POWER_MINIMUM)
			return "<b>minimum</b>"
		if(51 to 100)
			return "<b>low</b>"
		if(101 to 200)
			return "<b>middling</b>"
		if(201 to 299)
			return "<b>high</b>"
		if(HIVEMIND_MIND_WRACK_POWER_MAXIMUM to INFINITY)
			return "<b>MAXIMUM</b>"
