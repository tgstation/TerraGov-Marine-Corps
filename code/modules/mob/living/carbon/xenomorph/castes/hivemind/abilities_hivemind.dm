/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

// ***************************************
// *********** Reposition Core
// ***************************************
/datum/action/xeno_action/activable/reposition_core
	name = "Reposition Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Reposition your core to a target location on weeds. The further away the location is the longer this will take up to a maximum of 60 seconds. 10 minute cooldown."
	ability_name = "reposition core"
	plasma_cost = 150
	cooldown_timer = 600 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_REPOSITION_CORE

/datum/action/xeno_action/activable/reposition_core/on_cooldown_finish()
	owner.playsound_local(owner.loc, 'sound/voice/alien_drool1.ogg', 50, TRUE)
	to_chat(owner, "<span class='xenonotice'>We regain the strength to reposition our neural core.</span>")
	return ..()

/datum/action/xeno_action/activable/reposition_core/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE

	var/mob/living/carbon/xenomorph/hivemind/X = owner
	var/turf/T = get_turf(target)

	if(!istype(T))
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We can't transfer our core here!</span>")
		return FALSE

	if(!X.Adjacent(T))
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We can only reposition to a space adjacent to us!</span>")
		return FALSE

	if(!check_build_location(T, X, silent))
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We can't transfer our core here!</span>")
		return FALSE

/datum/action/xeno_action/activable/reposition_core/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/hivemind/X = owner
	var/obj/effect/alien/hivemindcore/core = X.core
	var/turf/T = get_turf(X)
	var/distance = get_dist(T, get_turf(core))

	var/delay = max(HIVEMIND_REPOSITION_CORE_DELAY_MIN, HIVEMIND_REPOSITION_CORE_DELAY_MOD * distance) //Calculate the distance scaling delay before we complete the reposition

	to_chat(owner, "<span class='xenodanger'>We begin the process of transfering our consciousness... We estimate this will require [delay * 0.1] seconds.</span>")

	succeed_activate()
	if(!do_after(X, delay, TRUE, null, BUSY_ICON_BUILD))
		to_chat(X, "<span class='xenodanger'>We abort transferring our consciousness, expending our precious plasma for naught.</span>")
		return fail_activate()

	if(!can_use_ability(T, FALSE, XACT_IGNORE_PLASMA))
		return fail_activate()

	core.forceMove(get_turf(T)) //Move the core
	playsound(core.loc, "alien_resin_build", 50)
	core.obj_integrity = 1 //Reset the core's health to 1; travelling is hard, exhausting work!

	if(!CHECK_BITFIELD(core.datum_flags, DF_ISPROCESSING)) //Start processing if we haven't already because we just lost a bunch of health
		START_PROCESSING(SSslowprocess, core)

	X.update_core() //Update the core

	to_chat(X, "<span class='xenodanger'>We succeed in transferring our consciousness to a new neural core!</span>")

	add_cooldown()

	GLOB.round_statistics.hivemind_reposition_core_uses++ //Increment the statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivemind_reposition_core_uses")

	X.hivemind_core_alert() //Alert the hive and marines

/datum/action/xeno_action/activable/reposition_core/proc/check_build_location(turf/T, mob/living/carbon/xenomorph/hivemind/X, silent = FALSE)

	if(T.z != X.core.z)
		if(!silent)
			to_chat(X, "<span class='xenodanger'>We cannot transfer our core here.</span>")
		return FALSE

	if(T.density) //Check to see if there's room
		if(!silent)
			to_chat(X, "<span class='xenodanger'>We require adequate room to transfer our core.</span>")
		return FALSE

	if(!locate(/obj/effect/alien/weeds) in T) //Make sure we actually have weeds at our destination.
		if(!silent)
			to_chat(X, "<span class='xenodanger'>There are no weeds for us to transfer our consciousness to!</span>")
		return FALSE

	for(var/obj/structure/O in T.contents)
		if(O.density && !CHECK_BITFIELD(O.flags_atom, ON_BORDER))
			if(!silent)
				to_chat(X, "<span class='xenodanger'>An object is occupying this space!</span>")
			return FALSE

	return TRUE



// ***************************************
// *********** Mind Wrack
// ***************************************
/datum/action/xeno_action/activable/mind_wrack
	name = "Mind Wrack"
	action_icon_state = "screech"
	mechanics_text = "Afflicts the target's mind with disorienting and painful psychic energy. Effect is greater the closer the target is to your core, and the more xenos that are within 5 tiles when used. Must have a core or other xeno within 5 tiles to use."
	ability_name = "mind wrack"
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_MIND_WRACK
	cooldown_timer = 60 SECONDS

/datum/action/xeno_action/activable/mind_wrack/give_action(mob/living/L)
	. = ..()
	RegisterSignal(owner, COMSIG_XENOABILITY_USED_PSYCHIC_CURE_HIVEMIND, .proc/add_cooldown) //Shared cooldown with Psychic Cure, Hivemind

/datum/action/xeno_action/activable/mind_wrack/remove_action(mob/living/L)
	UnregisterSignal(owner, COMSIG_XENOABILITY_USED_PSYCHIC_CURE_HIVEMIND)
	return ..()

/datum/action/xeno_action/activable/mind_wrack/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/effects/ghost2.ogg', 25, TRUE)
	to_chat(owner, "<span class='xenodanger'>We regain the strength to assault the minds of our enemies.</span>")
	return ..()

/datum/action/xeno_action/activable/mind_wrack/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/hivemind/X = owner

	if(!isliving(target))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>Our mind cannot interface with such an entity!</spam>")
		return FALSE

	var/mob/living/victim = target

	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/alien = victim
		if(X.issamexenohive(alien))
			if(!silent)
				to_chat(X, "<span class='xenonotice'>We would not assail the minds of our sisters!</span>")
			return FALSE

	if(get_dist(owner, victim) > HIVEMIND_MIND_WRACK_MAX_RANGE)
		if(!silent)
			to_chat(X, "<span class='xenowarning'>They are too far for us to reach their minds! The target must be [get_dist(owner, victim) - HIVEMIND_MIND_WRACK_MAX_RANGE] tiles closer!</spam>")
		return FALSE

	if(!owner.line_of_sight(target, HIVEMIND_MIND_WRACK_MAX_RANGE))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>We can't focus our psychic energy properly without a clear line of sight!</span>")
		return FALSE

	if(victim.stat == DEAD)
		if(!silent)
			to_chat(X, "<span class='xenonotice'>Even we cannot touch the minds of the dead...</span>")
		return FALSE


/datum/action/xeno_action/activable/mind_wrack/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/hivemind/X = owner
	var/mob/living/victim = A

	var/power_level = 0 //What does the scouter say about it?
	for(var/mob/living/carbon/xenomorph/ally in range(HIVEMIND_MIND_WRACK_POWER_CHORUS_RANGE, X ) ) //For each friendly xeno nearby, effect is more powerful
		if(istype(ally) && ally.hivenumber == X.hivenumber)
			++power_level //Increment the power level for each Xeno nearby
			X.beam(ally,"curse1",'icons/effects/beam.dmi',10, 10,/obj/effect/ebeam,1)
		if(power_level > HIVEMIND_MIND_WRACK_POWER_MAX_CHORUS)
			break

	if(get_dist(X, X.core) <= HIVEMIND_MIND_WRACK_POWER_CHORUS_RANGE) //If our core is nearby, the effect is *especially* powerful.
		power_level += 5
		X.beam(X.core,"curse1",'icons/effects/beam.dmi',10, 10,/obj/effect/ebeam,1)

	if(power_level < 2) //We need at least one core or xeno other than us.
		to_chat(owner, "<span class='xenodanger'>We require our core or a sister nearby to relay our psychic energy!</span>")
		return FALSE

	var/proximity_offset = get_dist(get_turf(victim), get_turf(X.core) ) //Effect is more powerful the closer the target is to the core, and less powerful the further away it is
	proximity_offset = clamp(-100, (HIVEMIND_MIND_WRACK_POWER_DISTANCE - proximity_offset) * 5, 100)

	power_level = clamp(HIVEMIND_MIND_WRACK_POWER_MINIMUM, power_level * HIVEMIND_MIND_WRACK_POWER_MULTIPLIER + proximity_offset, HIVEMIND_MIND_WRACK_POWER_MAXIMUM)

	X.playsound_local(X, 'sound/magic/invoke_general.ogg', 50, TRUE)
	X.beam(victim,"curse1",'icons/effects/beam.dmi',10, 10,/obj/effect/ebeam,1)
	victim.playsound_local(victim, pick('sound/effects/ghost2.ogg','sound/effects/ghost.ogg','sound/voice/alien_distantroar_3.ogg','sound/voice/alien_queen_command.ogg','sound/voice/alien_queen_command2.ogg','sound/voice/alien_queen_command3.ogg'), clamp(25, power_level * 0.5, 75), TRUE)
	to_chat(X, "<span class='danger'>We scour the mind of this unfortunate creature with [calculate_power(power_level, X)] power.</span>")
	to_chat(victim, "<span class='danger'>Your thoughts are suddenly overwhelmed by an alien presence as unworldly screaming fills your mind. Your brain feels as though it's on fire and your world convulses!</span>")
	new /obj/effect/temp_visual/telepathy(get_turf(victim))
	victim.add_filter("hivemind_mindwrack_sfx_1", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	victim.add_filter("hivemind_mindwrack_sfx_2", 3, list("type" = "wave", 0, 0, size=rand()*2.5+0.5, offset=rand())) //Cool filter appear
	animate(victim.get_filter("hivemind_mindwrack_sfx_1"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	animate(victim.get_filter("hivemind_mindwrack_sfx_2"), x = 60*rand() - 30, y = 60*rand() - 30, size=rand()*2.5+0.5, offset=rand(), time = 0.25 SECONDS, loop = -1, flags=ANIMATION_PARALLEL)
	addtimer(CALLBACK(victim, /atom.proc/remove_filter, "hivemind_mindwrack_sfx_1"), 1 SECONDS)
	addtimer(CALLBACK(victim, /atom.proc/remove_filter, "hivemind_mindwrack_sfx_2"), 1 SECONDS)
	shake_camera(victim, power_level * 0.01 SECONDS, 1)
	if(power_level > 100) //Need a minimum power to stun
		victim.ParalyzeNoChain(0.0033 SECONDS * power_level)
	victim.hallucination = min(victim.hallucination + power_level, 200) //I want the hallucination effect to *eventually* go away; capped at 200 stacks.
	victim.set_drugginess(power_level * 0.05) //visuals
	victim.blur_eyes(power_level * 0.05)
	victim.adjustStaminaLoss(power_level * 0.75)
	victim.adjust_stagger(power_level * 0.05)
	victim.add_slowdown(power_level * 0.05)

	if(!victim.hud_used)

		var/obj/screen/plane_master/floor/OT = victim.hud_used.plane_masters["[FLOOR_PLANE]"]
		var/obj/screen/plane_master/game_world/GW = victim.hud_used.plane_masters["[GAME_PLANE]"]

		addtimer(CALLBACK(OT, /atom.proc/remove_filter, "mindwrack_disorientation"), 1 SECONDS)
		GW.add_filter("mindwrack_disorientation", 2, list("type" = "radial_blur", "size" = 0.07))
		animate(GW.get_filter("mindwrack_disorientation"), size = 0.12, time = 5, loop = -1)
		OT.add_filter("mindwrack_disorientation", 2, list("type" = "radial_blur", "size" = 0.07))
		animate(OT.get_filter("mindwrack_disorientation"), size = 0.12, time = 5, loop = -1)
		addtimer(CALLBACK(GW, /atom.proc/remove_filter, "mindwrack_disorientation"), 1 SECONDS)


	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.hivemind_mind_wrack_uses++ //Increment the statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivemind_reposition_wrack_uses")

	var/datum/action/xeno_action/activable/psychic_cure/hivemind/psychic_cure_cooldown = locate(/datum/action/xeno_action/activable/psychic_cure/hivemind) in X.xeno_abilities //Shared cooldown with Psychic Cooldown
	psychic_cure_cooldown.add_cooldown()

/datum/action/xeno_action/activable/mind_wrack/proc/calculate_power(power_level, mob/living/carbon/xenomorph/hivemind/X)
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

// ***************************************
// *********** Psychic Cure, Hivemind
// ***************************************
/datum/action/xeno_action/activable/psychic_cure/hivemind

/datum/action/xeno_action/activable/psychic_cure/hivemind/give_action(mob/living/L)
	. = ..()
	RegisterSignal(owner, COMSIG_XENOABILITY_USED_MIND_WRACK, .proc/add_cooldown) //Shared cooldown with Mind Wrack

/datum/action/xeno_action/activable/psychic_cure/hivemind/remove_action(mob/living/L)
	UnregisterSignal(owner, COMSIG_XENOABILITY_USED_MIND_WRACK)
	return ..()

/datum/action/xeno_action/activable/psychic_cure/hivemind/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/hivemind/bigbrain = owner
	var/datum/action/xeno_action/activable/mind_wrack/mind_wrack_cooldown = locate(/datum/action/xeno_action/activable/mind_wrack) in bigbrain.xeno_abilities //Shared cooldown with Mind Wrack
	mind_wrack_cooldown.add_cooldown()
