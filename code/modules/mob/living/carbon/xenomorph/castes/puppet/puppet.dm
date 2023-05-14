/mob/living/carbon/xenomorph/puppet
	caste_base_type = /mob/living/carbon/xenomorph/puppet
	name = "Puppet"
	desc = "A reanimated body, crudely pieced together and held in place by an ominous energy tethered to some unknown force."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Puppet Running"
	health = 150
	maxHealth = 150
	plasma_stored = 0
	pixel_x = 0
	old_x = 0
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -1
	flags_pass = PASSXENO
	density = FALSE
	var/mob/living/carbon/xenomorph/master

/mob/living/carbon/xenomorph/puppet/Initialize(mapload, mob/living/carbon/xenomorph/puppeteer)
	. = ..()
	master = puppeteer
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/puppet, puppeteer)

/mob/living/carbon/xenomorph/puppet/Life()
	. = ..()
	if(get_dist(src, master) > 15)
		adjustBruteLoss(15)
//widow code again hooray
/datum/ai_behavior/puppet
	target_distance = 7
	base_action = ESCORTING_ATOM
	//The atom that will be used in only_set_escorted_atom proc, by default this atom is the spiderling's widow
	var/datum/weakref/default_escorted_atom

/datum/ai_behavior/puppet/New(loc, parent_to_assign, escorted_atom)
	. = ..()
	default_escorted_atom = WEAKREF(escorted_atom)
	RegisterSignal(escorted_atom, COMSIG_MOB_DEATH, PROC_REF(fucking_die))
	RegisterSignal(escorted_atom, COMSIG_PUPPET_SEEK_CLOSEST, PROC_REF(seek_and_attack_closest))
	RegisterSignal(escorted_atom, COMSIG_PUPPET_SEEK, PROC_REF(seek_and_attack))

/datum/ai_behavior/puppet/proc/fucking_die(mob/living/source)
	SIGNAL_HANDLER
	mob_parent.death() //die

///Signal handler to try to attack our target (widow code my beloved (fuck tgmc AI))
/datum/ai_behavior/puppet/proc/attack_target(datum/source)
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

/datum/ai_behavior/puppet/register_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(attack_target))
		if(!isobj(atom_to_walk_to))
			RegisterSignal(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(look_for_new_state))
	return ..()

/datum/ai_behavior/puppet/unregister_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		if(!isnull(atom_to_walk_to))
			UnregisterSignal(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))
	return ..()

/datum/ai_behavior/puppet/proc/seek_and_attack_closest(mob/living/source)
	var/victim = get_nearest_target(mob_parent, 9, TARGET_HUMAN, mob_parent.faction)
	if(!victim)
		return FALSE
	change_action(MOVING_TO_ATOM, victim)
	return TRUE

/datum/ai_behavior/puppet/proc/seek_and_attack(mob/living/source)
	SIGNAL_HANDLER
	var/list/mob/living/carbon/human/possible_victims = list()
	for(var/mob/living/carbon/human/victim in cheap_get_humans_near(mob_parent, 9))
		if(victim.stat == DEAD)
			continue
		possible_victims += victim
	if(!length(possible_victims))
		return FALSE

	change_action(MOVING_TO_ATOM, pick(possible_victims))
	return TRUE
