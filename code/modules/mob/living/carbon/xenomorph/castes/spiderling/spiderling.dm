/mob/living/carbon/xenomorph/spiderling
	caste_base_type = /mob/living/carbon/xenomorph/spiderling
	name = "Spiderling"
	desc = "Spawn of Widow"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "Spiderling Running"
	health = 200
	maxHealth = 200
	plasma_stored = 200
	pixel_x = 0
	old_x = 0
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -2
	flags_pass = PASSXENO

/mob/living/carbon/xenomorph/spiderling/Initialize(mapload, mob/living/carbon/xenomorph/spidermother)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/spiderling, spidermother)

/mob/living/carbon/xenomorph/spiderling/update_stat()
	. = ..()
	if(.)
		return

	if(stat == DEAD)
		return

	if(health <= 0)
		death(FALSE, null, TRUE)

/mob/living/carbon/xenomorph/on_death()
	. = ..()
	death_cry()
	return

// ***************************************
// *********** Spiderling AI Section
// ***************************************
/datum/ai_behavior/spiderling
	target_distance = 1
	base_action = ESCORTING_ATOM
/// This happens whenever a spiderling is created, they register a signal on escorted_atom and
/datum/ai_behavior/spiderling/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/go_to_target)

/// Signal handler to check if we can attack what our escorted_atom is attacking
/datum/ai_behavior/spiderling/proc/go_to_target(source, mob/living/target)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	if(mob_parent.get_xeno_hivenumber() == target.get_xeno_hivenumber())
		return
	change_action(MOVING_TO_ATOM, target)

///Signal handler to try to attack our target
/datum/ai_behavior/spiderling/proc/attack_target(datum/source)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	if(get_dist(atom_to_walk_to, mob_parent) > 1)
		return
	var/mob/living/victim = atom_to_walk_to
	if(victim.stat != CONSCIOUS)
		change_action(ESCORTING_ATOM, escorted_atom)
		return
	mob_parent.face_atom(atom_to_walk_to)
	mob_parent.UnarmedAttack(atom_to_walk_to, mob_parent)

/// Check if escorted_atom moves away from the spiderling while it's attacking something, this is to always keep them close to escorted_atom
/datum/ai_behavior/spiderling/look_for_new_state()
	switch(current_action)
		if(MOVING_TO_ATOM)
			if(escorted_atom && get_dist(escorted_atom, mob_parent) > 1)
				change_action(ESCORTING_ATOM, escorted_atom)

/// Check so that we dont keep attacking our target beyond it's death
/datum/ai_behavior/spiderling/register_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attack_target)
		if(ishuman(atom_to_walk_to))
			RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/ai_behavior.proc/change_action, ESCORTING_ATOM, escorted_atom)
	return ..()

/datum/ai_behavior/spiderling/unregister_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		if(ishuman(atom_to_walk_to))
			UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH)
	return ..()
