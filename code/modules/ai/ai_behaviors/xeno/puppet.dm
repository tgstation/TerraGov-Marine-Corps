/datum/ai_behavior/puppet
	target_distance = 7
	upper_escort_dist = 1
	base_action = IDLE
	identifier = IDENTIFIER_XENO
	///should we go back to escorting the puppeteer if we stray too far
	var/too_far_escort = TRUE
	///weakref to our puppeteer
	var/datum/weakref/master_ref
	///the feed ability
	var/datum/action/ability/activable/xeno/feed


/datum/ai_behavior/puppet/New(loc, mob/parent_to_assign, atom/escorted_atom)
	. = ..()
	master_ref = WEAKREF(escorted_atom)
	change_order(null, PUPPET_RECALL)
	feed = mob_parent.actions_by_path[/datum/action/ability/activable/xeno/feed]

///starts AI and registers obstructed move signal
/datum/ai_behavior/puppet/start_ai()
	var/master = master_ref?.resolve()
	if(master)
		RegisterSignal(master, COMSIG_PUPPET_CHANGE_ALL_ORDER, PROC_REF(change_order))
	RegisterSignal(mob_parent, COMSIG_PUPPET_CHANGE_ORDER, PROC_REF(change_order))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_REST, PROC_REF(start_resting))
	RegisterSignal(escorted_atom, COMSIG_XENOMORPH_UNREST, PROC_REF(stop_resting))
	RegisterSignal(escorted_atom, COMSIG_ELEMENT_JUMP_STARTED, PROC_REF(do_jump))
	RegisterSignal(escorted_atom, COMSIG_LIVING_DO_RESIST, PROC_REF(parent_resist))
	return ..()

///cleans up signals and unregisters obstructed move signal
/datum/ai_behavior/puppet/cleanup_signals()
	. = ..()
	UnregisterSignal(mob_parent, COMSIG_PUPPET_CHANGE_ORDER)
	var/master = master_ref?.resolve()
	if(master)
		UnregisterSignal(master, COMSIG_PUPPET_CHANGE_ALL_ORDER)

/datum/ai_behavior/puppet/melee_interact(datum/source, atom/interactee, melee_tool)
	if(world.time < mob_parent.next_move)
		return
	var/atom/target = interactee ? interactee : atom_to_walk_to
	if(!mob_parent.Adjacent(target))
		return
	if(mob_parent.z != target.z)
		return
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.stat == DEAD)
			late_initialize()
			return
		do_feed(victim) //todo: This way this action is triggered is extremely stinky. Refactor action and remove this entire proc from this type

	mob_parent.face_atom(target)
	mob_parent.UnarmedAttack(target, mob_parent)

///looks for a new state, handles recalling if too far and some AI shenanigans
/datum/ai_behavior/puppet/look_for_new_state()
	switch(current_action)
		if(MOVING_TO_NODE, FOLLOWING_PATH)
			if(get_dist(mob_parent, escorted_atom) > PUPPET_WITHER_RANGE && too_far_escort)
				change_order(null, PUPPET_RECALL)
				return
			if(!change_order(null, PUPPET_SEEK_CLOSEST))
				change_action(MOVING_TO_NODE)
				return
		if(IDLE)
			if(!change_order(null, PUPPET_SEEK_CLOSEST))
				return
		if(ESCORTING_ATOM)
			if(!escorted_atom && master_ref)
				escorted_atom = master_ref.resolve()
		if(MOVING_TO_ATOM)
			if(!atom_to_walk_to) //edge case
				late_initialize()
	return ..()

///attack the first closest human, by moving towards it
/datum/ai_behavior/puppet/proc/seek_and_attack_closest(mob/living/source)
	var/victim = get_nearest_target(mob_parent, target_distance, TARGET_HUMAN, mob_parent.faction)
	if(!victim)
		return FALSE
	set_combat_target(victim)
	change_action(MOVING_TO_ATOM, victim)
	return TRUE

///seeks a living humans in a 9 tile range near our parent, picks one, then changes our action to move towards it and attack.
/datum/ai_behavior/puppet/proc/seek_and_attack()
	var/list/mob/living/carbon/human/possible_victims = list()
	for(var/mob/living/carbon/human/victim in cheap_get_humans_near(mob_parent, 9))
		if(victim.stat == DEAD)
			continue
		possible_victims += victim
	if(!length(possible_victims))
		return FALSE

	set_combat_target(pick(possible_victims))
	change_action(MOVING_TO_ATOM, combat_target)
	return TRUE

///changes our current behavior with a define (order), optionally with a target, FALSE means fail and TRUE means success
/datum/ai_behavior/puppet/proc/change_order(mob/living/source, order, atom/target)
	SIGNAL_HANDLER
	if(!order)
		stack_trace("puppet AI was somehow passed a null order")
		return FALSE
	switch(order)
		if(PUPPET_SEEK_CLOSEST) //internal order, to attack closest enemy
			return seek_and_attack_closest()
		if(PUPPET_RECALL) //reset our escorted atom to master_ref and change our action to escorting it, and turn on recalling if out of range.
			escorted_atom = master_ref?.resolve()
			base_action = ESCORTING_ATOM
			change_action(ESCORTING_ATOM, escorted_atom)
			too_far_escort = TRUE
			return TRUE
		if(PUPPET_ATTACK) //turns on recalling out of range, if there is a target, attacks it, otherwise seeks and attacks one
			too_far_escort = TRUE
			if(target)
				set_combat_target(target)
				change_action(MOVING_TO_ATOM, target)
				return TRUE
			else
				return seek_and_attack()

///uses our feed ability if possible and it exists, on the target
/datum/ai_behavior/puppet/proc/do_feed(atom/target)
	if(mob_parent.do_actions)
		return
	if(!feed)
		return
	if(feed.ai_should_use(target))
		feed.use_ability(target)

/// rest when puppeter does
/datum/ai_behavior/puppet/proc/start_resting(mob/source)
	SIGNAL_HANDLER
	var/mob/living/living = mob_parent
	living?.set_resting(TRUE)

/// stop resting when puppeter does
/datum/ai_behavior/puppet/proc/stop_resting(mob/source)
	SIGNAL_HANDLER
	var/mob/living/living = mob_parent
	living?.set_resting(FALSE)

/// resist when puppeter does
/datum/ai_behavior/puppet/proc/do_jump()
	SIGNAL_HANDLER
	var/datum/component/jump/puppet_jump = mob_parent.GetComponent(/datum/component/jump)
	puppet_jump?.do_jump(mob_parent)

/// resist when puppeter does
/datum/ai_behavior/puppet/proc/parent_resist()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/puppet/puppet_parent = mob_parent
	puppet_parent?.do_resist()
