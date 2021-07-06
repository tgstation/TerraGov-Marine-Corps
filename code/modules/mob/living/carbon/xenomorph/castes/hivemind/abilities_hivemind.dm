/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

// ***************************************
// *********** Hivemind healing
// ***************************************
/datum/action/xeno_action/activable/hivemind_heal
	name = "Hivemind Heal"
	action_icon_state = "heal_xeno"
	mechanics_text = "Heal."
	cooldown_timer = 1 MINUTES
	plasma_cost = 200
	keybind_signal = COMSIG_XENOABILITY_HIVEMIND_HEAL
	var/heal_range = HIVEMIND_HEAL_RANGE
	target_flags = XABB_MOB_TARGET


/datum/action/xeno_action/activable/hivemind_heal/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to cure sisters again.</span>")
	return ..()


/datum/action/xeno_action/activable/hivemind_heal/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!check_distance(target, silent))
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			to_chat(owner, "<span class='warning'>It's too late. This sister won't be coming back.</span>")
		return FALSE


/datum/action/xeno_action/activable/hivemind_heal/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > heal_range)
		to_chat(owner, "<span class='warning'>Too far for our reach... We need to be [dist - heal_range] steps closer!</span>")
		return FALSE
	return TRUE


/datum/action/xeno_action/activable/hivemind_heal/use_ability(atom/target)
	if(owner.do_actions)
		return FALSE

	if(!do_mob(owner, target, 0.3 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE

	GLOB.round_statistics.psychic_cures++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_cures")
	owner.visible_message("<span class='xenowarning'>A strange psychic aura is suddenly emitted from \the [owner]!</span>", \
	"<span class='xenowarning'>We cure [target] with the power of our mind!</span>")
	target.visible_message("<span class='xenowarning'>[target] suddenly shimmers in a chill light.</span>", \
	"<span class='xenowarning'>We feel a sudden soothing chill.</span>")

	playsound(target,'sound/effects/magic.ogg', 75, 1)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	patient.heal_wounds(HIVEMIND_HEAL_MULTIPLIER)
	if(patient.health > 0) //If they are not in crit after the heal, let's remove evil debuffs.
		patient.SetUnconscious(0)
		patient.SetStun(0)
		patient.SetParalyzed(0)
		patient.set_stagger(0)
		patient.set_slowdown(0)
	patient.updatehealth()

	owner.changeNext_move(CLICK_CD_RANGE)

	log_combat(owner, patient, "psychically cured")

	succeed_activate()
	add_cooldown()
