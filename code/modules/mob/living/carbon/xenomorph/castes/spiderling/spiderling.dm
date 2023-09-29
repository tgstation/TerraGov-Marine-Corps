/mob/living/carbon/xenomorph/spiderling
	caste_base_type = /mob/living/carbon/xenomorph/spiderling
	name = "Spiderling"
	desc = "A widow spawn, it chitters angrily without any sense of self-preservation, only to obey the widow's will."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "Spiderling Running"
	health = 250
	maxHealth = 250
	plasma_stored = 200
	pixel_x = 0
	old_x = 0
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -2
	allow_pass_flags = PASS_XENO
	pass_flags = PASS_XENO|PASS_LOW_STRUCTURE
	density = FALSE

/mob/living/carbon/xenomorph/spiderling/Initialize(mapload, mob/living/carbon/xenomorph/spidermother)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/spiderling, spidermother)

/mob/living/carbon/xenomorph/spiderling/on_death()
	///We QDEL them as cleanup and preventing them from being sold
	QDEL_IN(src, TIME_TO_DISSOLVE)
	return ..()

// ***************************************
// *********** Spiderling AI Section
// ***************************************
/datum/ai_behavior/spiderling
	target_distance = 1
	base_action = ESCORTING_ATOM
	//The atom that will be used in only_set_escorted_atom proc, by default this atom is the spiderling's widow
	var/datum/weakref/default_escorted_atom

/datum/ai_behavior/spiderling/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	default_escorted_atom = WEAKREF(escorted_atom)
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(go_to_target))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(go_to_obj_target))
	RegisterSignal(escorted_atom, COMSIG_MOB_DEATH, PROC_REF(spiderling_rage))
	RegisterSignal(escorted_atom, COMSIG_LIVING_DO_RESIST, PROC_REF(parent_resist))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, PROC_REF(apply_spiderling_jelly))
	RegisterSignals(escorted_atom, list(COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST), PROC_REF(toggle_rest))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_MARK, PROC_REF(decide_mark))

/// Decides what to do when widow uses spiderling mark ability
/datum/ai_behavior/spiderling/proc/decide_mark(source, atom/A)
	SIGNAL_HANDLER
	if(!A)
		only_set_escorted_atom()
		UnregisterSignal(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_QDELETING))
		atom_to_walk_to = null
		return
	if(atom_to_walk_to == A)
		return
	escorted_atom = null
	if(ishuman(A))
		INVOKE_ASYNC(src, PROC_REF(triggered_spiderling_rage), source, A)
		return
	if(isobj(A))
		var/obj/obj_target = A
		RegisterSignal(obj_target, COMSIG_QDELETING, PROC_REF(only_set_escorted_atom))
		go_to_obj_target(source, A)
		return

/// Sets escorted atom to our pre-defined default escorted atom, which by default is this spiderling's widow
/datum/ai_behavior/spiderling/proc/only_set_escorted_atom(source, atom/A)
	SIGNAL_HANDLER
	escorted_atom = default_escorted_atom.resolve()

/// Signal handler to check if we can attack the obj's that our escorted_atom is attacking
/datum/ai_behavior/spiderling/proc/go_to_obj_target(source, obj/target)
	SIGNAL_HANDLER
	if(QDELETED(target))
		return
	atom_to_walk_to = target
	change_action(MOVING_TO_ATOM, target)

/// Signal handler to check if we can attack what our escorted_atom is attacking
/datum/ai_behavior/spiderling/proc/go_to_target(source, mob/living/target)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	if(target.stat != CONSCIOUS)
		return
	if(mob_parent?.get_xeno_hivenumber() == target.get_xeno_hivenumber())
		return
	atom_to_walk_to = target
	change_action(MOVING_TO_ATOM, target)

///Signal handler to try to attack our target
/datum/ai_behavior/spiderling/proc/attack_target(datum/source)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	if(Adjacent(atom_to_walk_to))
		return
	if(isliving(atom_to_walk_to))
		var/mob/living/victim = atom_to_walk_to
		if(victim.stat != CONSCIOUS)
			change_action(ESCORTING_ATOM, escorted_atom)
			return
	mob_parent.face_atom(atom_to_walk_to)
	mob_parent.UnarmedAttack(atom_to_walk_to, mob_parent)

/// Check if escorted_atom moves away from the spiderling while it's attacking something, this is to always keep them close to escorted_atom
/datum/ai_behavior/spiderling/look_for_new_state()
	if(current_action == MOVING_TO_ATOM)
		if(escorted_atom && !(mob_parent.Adjacent(escorted_atom)))
			change_action(ESCORTING_ATOM, escorted_atom)

/// Check so that we dont keep attacking our target beyond it's death
/datum/ai_behavior/spiderling/register_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(attack_target))
		if(!isobj(atom_to_walk_to))
			RegisterSignals(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_QDELETING), PROC_REF(look_for_new_state))
	return ..()

/datum/ai_behavior/spiderling/unregister_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		if(!isnull(atom_to_walk_to))
			UnregisterSignal(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_QDELETING))
	return ..()

/// This happens when the spiderlings mother dies, they move faster and will attack any nearby marines
/datum/ai_behavior/spiderling/proc/spiderling_rage()
	var/mob/living/carbon/xenomorph/spiderling/x = mob_parent
	var/list/mob/living/carbon/human/possible_victims = list()
	for(var/mob/living/carbon/human/victim in cheap_get_humans_near(x, SPIDERLING_RAGE_RANGE))
		if(victim.stat == DEAD)
			continue
		possible_victims += victim
	if(!length(possible_victims))
		kill_parent()
		return
	x.emote("roar")
	change_action(MOVING_TO_ATOM, pick(possible_victims))
	addtimer(CALLBACK(src, PROC_REF(kill_parent)), 10 SECONDS)

/// Makes the spiderling roar and then kill themselves after some time
/datum/ai_behavior/spiderling/proc/triggered_spiderling_rage(mob/M, mob/victim)
	var/mob/living/carbon/xenomorph/spiderling/x = mob_parent
	change_action(MOVING_TO_ATOM, victim)
	x.emote("roar")
	addtimer(CALLBACK(src, PROC_REF(kill_parent)), 15 SECONDS)

///This kills the spiderling
/datum/ai_behavior/spiderling/proc/kill_parent()
	var/mob/living/carbon/xenomorph/spiderling/spiderling_parent = mob_parent
	spiderling_parent.death(gibbing = FALSE)

/// resist when widow does
/datum/ai_behavior/spiderling/proc/parent_resist()
	var/mob/living/carbon/xenomorph/spiderling/spiderling_parent = mob_parent
	spiderling_parent.do_resist()

/// rest and unrest when widow does
/datum/ai_behavior/spiderling/proc/toggle_rest()
	var/mob/living/carbon/xenomorph/spiderling/spiderling_parent = mob_parent
	if(HAS_TRAIT(spiderling_parent, TRAIT_FLOORED))
		spiderling_parent.set_resting(FALSE)
	else
		spiderling_parent.set_resting(TRUE)

/// Signal handler to apply resin jelly to the spiderling whenever widow gets it
/datum/ai_behavior/spiderling/proc/apply_spiderling_jelly()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/spiderling/beno_to_coat = mob_parent
	beno_to_coat.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
