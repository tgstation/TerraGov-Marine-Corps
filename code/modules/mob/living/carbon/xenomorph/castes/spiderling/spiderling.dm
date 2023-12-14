#define SPIDERLING_ATTEMPTING_GUARD "spiderling_attempting_guard"
#define SPIDERLING_NOT_GUARDING "spiderling_not_guarding"
#define SPIDERLING_GUARDING "spiderling_guarding"
#define SPIDERLING_ENRAGED "spiderling_enraged"
#define SPIDERLING_NORMAL "spiderling_normal"

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
	/// The widow that this spiderling belongs to
	var/mob/living/carbon/xenomorph/spidermother
	/// What sprite state this - normal, enraged, guarding? Used for update_icons()
	var/spiderling_state = SPIDERLING_NORMAL

/mob/living/carbon/xenomorph/spiderling/Initialize(mapload, mob/living/carbon/xenomorph/mother)
	. = ..()
	spidermother = mother
	if(spidermother)
		AddComponent(/datum/component/ai_controller, /datum/ai_behavior/spiderling, spidermother)
		transfer_to_hive(spidermother.get_xeno_hivenumber())
	else
		AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)

/mob/living/carbon/xenomorph/spiderling/update_icons(state_change = TRUE)
	. = ..()
	if(state_change)
		if(spiderling_state == SPIDERLING_ENRAGED)
			icon_state = "[icon_state] Enraged"
		if(spiderling_state == SPIDERLING_GUARDING)
			icon_state = "[icon_state] Guarding"

/mob/living/carbon/xenomorph/spiderling/on_death()
	//We QDEL them as cleanup and preventing them from being sold
	QDEL_IN(src, TIME_TO_DISSOLVE)
	return ..()

///If we're covering our widow, any clicks should be transferred to them
/mob/living/carbon/xenomorph/spiderling/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!get_dist(src, spidermother) && isxeno(x))
		spidermother.attack_alien(X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
		return
	return ..()

// ***************************************
// *********** Spiderling AI Section
// ***************************************
/datum/ai_behavior/spiderling
	target_distance = 1
	base_action = ESCORTING_ATOM
	//The atom that will be used in revert_to_default_escort proc, by default this atom is the spiderling's widow
	var/datum/weakref/default_escorted_atom
	//Whether we are currently guarding a crit widow or not
	var/guarding_status = SPIDERLING_NOT_GUARDING

/datum/ai_behavior/spiderling/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	default_escorted_atom = WEAKREF(escorted_atom)
	RegisterSignals(escorted_atom, list(COMSIG_XENOMORPH_ATTACK_LIVING, COMSIG_XENOMORPH_ATTACK_HOSTILE_XENOMORPH), PROC_REF(go_to_target))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(go_to_obj_target))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_GUARD, PROC_REF(attempt_guard))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_UNGUARD, PROC_REF(attempt_unguard))
	RegisterSignal(escorted_atom, COMSIG_MOB_DEATH, PROC_REF(spiderling_rage))
	RegisterSignal(escorted_atom, COMSIG_LIVING_DO_RESIST, PROC_REF(parent_resist))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED, PROC_REF(apply_spiderling_jelly))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_REST, PROC_REF(start_resting))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_UNREST, PROC_REF(stop_resting))
	RegisterSignal(escorted_atom, COMSIG_ELEMENT_JUMP_STARTED, PROC_REF(do_jump))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_MARK, PROC_REF(decide_mark))
	RegisterSignal(escorted_atom, COMSIG_SPIDERLING_RETURN, PROC_REF(revert_to_default_escort))

/// Decides what to do when widow uses spiderling mark ability
/datum/ai_behavior/spiderling/proc/decide_mark(source, atom/A)
	SIGNAL_HANDLER
	if(!A)
		revert_to_default_escort()
		return
	if(atom_to_walk_to == A)
		return
	escorted_atom = null
	if(ishuman(A))
		INVOKE_ASYNC(src, PROC_REF(triggered_spiderling_rage), source, A)
		return
	if(isobj(A))
		var/obj/obj_target = A
		RegisterSignal(obj_target, COMSIG_QDELETING, PROC_REF(revert_to_default_escort))
		go_to_obj_target(source, A)
		return

/// Sets escorted atom to our pre-defined default escorted atom, which by default is this spiderling's widow, and commands the spiderling to follow it
/datum/ai_behavior/spiderling/proc/revert_to_default_escort(source)
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
	if(world.time < mob_parent?.next_move)
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

/// If the spiderling's mother goes into crit, the spiderlings will stop what they are doing and attempt to shield her
/datum/ai_behavior/spiderling/proc/attempt_guard()
	SIGNAL_HANDLER
	if(guarding_status == SPIDERLING_NOT_GUARDING) //Nothing to cleanup
		INVOKE_ASYNC(src, PROC_REF(guard_owner))
		return

/// Spiderling's mother woke up from crit; reset stuff back to normal
/datum/ai_behavior/spiderling/proc/attempt_unguard()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(revert_to_default_escort))
	guarding_status = SPIDERLING_NOT_GUARDING
	var/mob/living/carbon/xenomorph/spiderling/X = mob_parent
	X?.spiderling_state = SPIDERLING_NORMAL
	X?.update_icons()

/datum/ai_behavior/spiderling/ai_do_move()
	if((guarding_status == SPIDERLING_ATTEMPTING_GUARD) && (get_dist(mob_parent, atom_to_walk_to) <= 1))
		var/mob/living/carbon/xenomorph/spiderling/X = mob_parent
		if(prob(50))
			X?.emote("hiss")
		guarding_status = SPIDERLING_GUARDING
		var/mob/living/carbon/xenomorph/widow/to_guard = escorted_atom
		to_guard.buckle_mob(X, TRUE, TRUE)
		X?.dir = SOUTH
	return ..()

/// Moves spiderlings to the widow
/datum/ai_behavior/spiderling/proc/guard_owner()
	var/mob/living/carbon/xenomorph/spiderling/X = mob_parent
	if(QDELETED(X))
		return
	if(prob(50))
		X.emote("roar")
	if(X.spiderling_state != SPIDERLING_ENRAGED)
		X.spiderling_state = SPIDERLING_GUARDING
		X.update_icons()
	distance_to_maintain = 0
	revert_to_default_escort()
	atom_to_walk_to = escorted_atom
	guarding_status = SPIDERLING_ATTEMPTING_GUARD

/// This happens when the spiderlings mother dies, they move faster and will attack any nearby marines
/datum/ai_behavior/spiderling/proc/spiderling_rage()
	SIGNAL_HANDLER
	escorted_atom = null
	var/mob/living/carbon/xenomorph/spiderling/x = mob_parent
	if(QDELETED(x))
		return
	var/list/mob/living/carbon/human/possible_victims = list()
	for(var/mob/living/victim in get_nearest_target(x, SPIDERLING_RAGE_RANGE))
		if(victim.stat == DEAD)
			continue
		possible_victims += victim
	if(!length(possible_victims))
		kill_parent()
		return
	x.spiderling_state = SPIDERLING_ENRAGED
	x.update_icons()
	// Makes the spiderlings roar at slightly different times so they don't stack their roars
	addtimer(CALLBACK(x, TYPE_PROC_REF(/mob, emote), "roar"), rand(1, 4))
	change_action(MOVING_TO_ATOM, pick(possible_victims))
	addtimer(CALLBACK(src, PROC_REF(kill_parent)), 10 SECONDS)

/// Makes the spiderling roar and then kill themselves after some time
/datum/ai_behavior/spiderling/proc/triggered_spiderling_rage(mob/M, mob/victim)
	var/mob/living/carbon/xenomorph/spiderling/spiderling_parent = mob_parent
	if(QDELETED(spiderling_parent))
		return
	change_action(MOVING_TO_ATOM, victim)
	spiderling_parent.spiderling_state = SPIDERLING_ENRAGED
	spiderling_parent.update_icons()
	addtimer(CALLBACK(spiderling_parent, TYPE_PROC_REF(/mob, emote), "roar"), rand(1, 4))
	addtimer(CALLBACK(src, PROC_REF(kill_parent)), 15 SECONDS)

///This kills the spiderling
/datum/ai_behavior/spiderling/proc/kill_parent()
	var/mob/living/carbon/xenomorph/spiderling/spiderling_parent = mob_parent
	spiderling_parent?.death(gibbing = FALSE)

/// resist when widow does
/datum/ai_behavior/spiderling/proc/parent_resist()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/spiderling/spiderling_parent = mob_parent
	spiderling_parent?.do_resist()

/// rest when widow does
/datum/ai_behavior/spiderling/proc/start_resting(mob/source)
	SIGNAL_HANDLER
	var/mob/living/living = mob_parent
	living?.set_resting(TRUE)

/// stop resting when widow does, plus unbuckle all mobs so the widow won't get stuck
/datum/ai_behavior/spiderling/proc/stop_resting(mob/source)
	SIGNAL_HANDLER
	var/mob/living/living = mob_parent
	living?.set_resting(FALSE)
	source?.unbuckle_all_mobs()

/// Signal handler to make the spiderling jump when widow does
/datum/ai_behavior/spiderling/proc/do_jump()
	SIGNAL_HANDLER
	var/datum/component/jump/jumpy_spider = mob_parent.GetComponent(/datum/component/jump)
	jumpy_spider?.do_jump(mob_parent)

/// Signal handler to apply resin jelly to the spiderling whenever widow gets it
/datum/ai_behavior/spiderling/proc/apply_spiderling_jelly()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/spiderling/beno_to_coat = mob_parent
	beno_to_coat?.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
