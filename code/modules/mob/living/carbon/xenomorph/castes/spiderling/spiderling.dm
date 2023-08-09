#define SPIDERLING_GUARDING "spiderling_guarding"
#define SPIDERLING_ATTEMPTING_GUARD "spiderling_attempting_guard"
#define SPIDERLING_NOT_GUARDING "spiderling_not_guarding"

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
	// The widow that this spiderling belongs to
	var/mob/living/carbon/xenomorph/spidermother

/mob/living/carbon/xenomorph/spiderling/Initialize(mapload, mob/living/carbon/xenomorph/mother)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/spiderling, mother)
	spidermother = mother

/mob/living/carbon/xenomorph/spiderling/on_death()
	///We QDEL them as cleanup and preventing them from being sold
	QDEL_IN(src, TIME_TO_DISSOLVE)
	return ..()

//If we're covering our widow, any friendly nabs, grabs/etc should be transferred to them
/mob/living/carbon/xenomorph/spiderling/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!get_dist(src, spidermother))
		spidermother.attack_alien(X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
		return
	return ..()

/mob/living/carbon/xenomorph/spiderling/CtrlClick(mob/user)
	if(!get_dist(src, spidermother))
		spidermother.CtrlClick(user)
		return
	return ..()


// ***************************************
// *********** Spiderling AI Section
// ***************************************
/datum/ai_behavior/spiderling
	target_distance = 1
	base_action = ESCORTING_ATOM
	//The atom that will be used in only_set_escorted_atom proc, by default this atom is the spiderling's widow
	var/datum/weakref/default_escorted_atom
	//Whether we are currently guarding a crit widow or not
	var/guarding_status = SPIDERLING_NOT_GUARDING

/datum/ai_behavior/spiderling/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	default_escorted_atom = WEAKREF(escorted_atom)
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(go_to_target))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(go_to_obj_target))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_GUARD, PROC_REF(attempt_guard))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_UNGUARD, PROC_REF(attempt_unguard))
	RegisterSignal(escorted_atom, COMSIG_MOB_DEATH, PROC_REF(spiderling_rage))
	RegisterSignal(escorted_atom, COMSIG_LIVING_DO_RESIST, PROC_REF(parent_resist))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, PROC_REF(apply_spiderling_jelly))
	RegisterSignals(escorted_atom, list(COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST), PROC_REF(toggle_rest))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_MARK, PROC_REF(decide_mark))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_RETURN, PROC_REF(only_set_escorted_atom))

/// Decides what to do when widow uses spiderling mark ability
/datum/ai_behavior/spiderling/proc/decide_mark(source, atom/A)
	SIGNAL_HANDLER
	if(!A)
		only_set_escorted_atom()
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

/// Sets escorted atom to our pre-defined default escorted atom, which by default is this spiderling's widow, and commands the spiderling to follow it
/datum/ai_behavior/spiderling/proc/only_set_escorted_atom(source, atom/A)
	SIGNAL_HANDLER
	escorted_atom = default_escorted_atom.resolve()
	change_action(ESCORTING_ATOM, escorted_atom)

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
		if(escorted_atom)
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

/// If the spiderling's mother goes into crit, the spiderlings will stop what they are doing and attempt to shield her
/datum/ai_behavior/spiderling/proc/attempt_guard()
	SIGNAL_HANDLER
	if(guarding_status == SPIDERLING_NOT_GUARDING) //Nothing to cleanup
		INVOKE_ASYNC(src, PROC_REF(guard_owner))
		return

/// Spiderling's mother woke up from crit; reset stuff back to normal
/datum/ai_behavior/spiderling/proc/attempt_unguard()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(only_set_escorted_atom))
	guarding_status = SPIDERLING_NOT_GUARDING

/datum/ai_behavior/spiderling/ai_do_move()
	if(guarding_status == SPIDERLING_ATTEMPTING_GUARD)
		if(get_dist(mob_parent, atom_to_walk_to) <= 1)
			var/mob/living/carbon/xenomorph/spiderling/X = mob_parent
			if(prob(50))
				X.emote("hiss") //NEED TO DO MORE. Update status, buckle, clickthrough, etc.
			guarding_status = SPIDERLING_GUARDING
			var/mob/living/carbon/xenomorph/widow/to_guard = escorted_atom
			to_guard.buckle_mob(X, TRUE, TRUE)
			X.dir = SOUTH
	return ..()

/// Moves spiderlings to the widow
/datum/ai_behavior/spiderling/proc/guard_owner()
	var/mob/living/carbon/xenomorph/spiderling/X = mob_parent
	if(prob(50))
		X.emote("roar")
	distance_to_maintain = 0
	only_set_escorted_atom()
	atom_to_walk_to = escorted_atom
	guarding_status = SPIDERLING_ATTEMPTING_GUARD

/// This happens when the spiderlings mother dies, they move faster and will attack any nearby marines
/datum/ai_behavior/spiderling/proc/spiderling_rage()
	escorted_atom = null
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
	var/mob/living/carbon/xenomorph/widow/spiderling_mother = mob_parent.spidermother
	if(HAS_TRAIT(spiderling_mother, TRAIT_FLOORED))
		spiderling_parent.set_resting(FALSE)
	else
		spiderling_parent.set_resting(TRUE)

/// Signal handler to apply resin jelly to the spiderling whenever widow gets it
/datum/ai_behavior/spiderling/proc/apply_spiderling_jelly()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/spiderling/beno_to_coat = mob_parent
	beno_to_coat.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
