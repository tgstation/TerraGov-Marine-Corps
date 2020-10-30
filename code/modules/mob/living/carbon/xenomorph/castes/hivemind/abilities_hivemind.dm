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
	plasma_cost = 200
	cooldown_timer = 180 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_EMIT_NEUROGAS

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/reposition_core/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(owner, "<span class='notice'>We regain the strength to reposition our neural core.</span>")
	return ..()

/datum/action/xeno_action/activable/reposition_core/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/hivemind/X = owner
	var/obj/effect/alien/hivemindcore/core = X.core

	succeed_activate()

	var/turf/target_turf = get_turf(X)
	var/distance = get_dist(target_turf, get_turf(core))
	var/delay = max(HIVEMIND_REPOSITION_CORE_COOLDOWN_MIN, HIVEMIND_REPOSITION_CORE_COOLDOWN_MOD * distance) //Calculate the distance scaling delay before we complete the reposition

	to_chat(owner, "<span class='xenodanger'>We begin the process of transfering our consciousness... We estimate this will require [delay] seconds.</span>")

	if(!do_after(X, delay, TRUE, null, BUSY_ICON_HOSTILE))
		if(!QDELETED(src))
			to_chat(X, "<span class='xenodanger'>We abort transferring our consciousness, expending our precious plasma for naught.</span>")
			return fail_activate()

	var/obj/effect/alien/weeds/W = locate() in range(1, target_turf) //Make sure we actually have weeds at our destination.
	if(!W)
		to_chat(X, "<span class='xenodanger'>There are no weeds for us to transfer our consciousness to!</span>")
		return fail_activate()

	add_cooldown()

	GLOB.round_statistics.hivemind_reposition_core_uses++ //Increment the statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivemind_reposition_core_uses")

	core.forceMove(get_turf(target_turf)) //Move the core
	to_chat(owner, "<span class='xenodanger'>We succeed in transferring our consciousness to a new neural core!</span>")

	if(is_centcom_level(core))
		return
	var/area/core_new_area = get_area(core)
	xeno_message("Hive: \The [X] has <b>transferred its core</b>[A? " to [sanitize(core_new_area.name)]":""]!", 3, X.hivenumber) //Let the hive know the Hivemind's new location.
