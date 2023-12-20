/datum/ai_behavior/puppet
	target_distance = 7
	base_action = IDLE
	identifier = IDENTIFIER_XENO
	///should we go back to escorting the puppeteer if we stray too far
	var/too_far_escort = TRUE
	///weakref to our puppeteer
	var/datum/weakref/master_ref
	///the feed ability
	var/datum/action/ability/activable/xeno/feed


/datum/ai_behavior/puppet/New(loc, parent_to_assign, escorted_atom)
	. = ..()
	master_ref = WEAKREF(escorted_atom)
	RegisterSignals(escorted_atom, list(COMSIG_MOB_DEATH, COMSIG_QDELETING), PROC_REF(die_on_master_death))
	change_order(null, PUPPET_RECALL)
	feed = mob_parent.actions_by_path[/datum/action/ability/activable/xeno/feed]

///starts AI and registers obstructed move signal
/datum/ai_behavior/puppet/start_ai()
	var/master = master_ref?.resolve()
	if(master)
		RegisterSignal(master, COMSIG_PUPPET_CHANGE_ALL_ORDER, PROC_REF(change_order))
	RegisterSignal(mob_parent, COMSIG_OBSTRUCTED_MOVE, PROC_REF(deal_with_obstacle))
	RegisterSignal(mob_parent, COMSIG_PUPPET_CHANGE_ORDER, PROC_REF(change_order))
	return ..()

///cleans up signals and unregisters obstructed move signal
/datum/ai_behavior/puppet/cleanup_signals()
	. = ..()
	UnregisterSignal(mob_parent, list(COMSIG_OBSTRUCTED_MOVE,COMSIG_PUPPET_CHANGE_ORDER))
	var/master = master_ref?.resolve()
	if(master)
		UnregisterSignal(master, COMSIG_PUPPET_CHANGE_ALL_ORDER)

///signal handler for if the master (puppeteer) dies, gibs the puppet
/datum/ai_behavior/puppet/proc/die_on_master_death(mob/living/source)
	SIGNAL_HANDLER
	if(!QDELETED(mob_parent))
		mob_parent.gib()

///Signal handler to try to attack our target
///Attack our current atom we are moving to, if targetted is specified attack that instead
/datum/ai_behavior/puppet/proc/attack_target(datum/source, atom/targetted)
	SIGNAL_HANDLER
	if(world.time < mob_parent.next_move)
		return
	var/atom/target = targetted ? targetted : atom_to_walk_to
	if(!mob_parent.Adjacent(target))
		return
	if(mob_parent.z != target.z)
		return
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.stat == DEAD)
			late_initialize()
			return
		do_feed(victim)

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

///override for MOVING_TO_ATOM to register signals for maintaining distance with our target and attacking
/datum/ai_behavior/puppet/register_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, PROC_REF(attack_target))
		if(!isobj(atom_to_walk_to))
			RegisterSignal(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_QDELETING), PROC_REF(look_for_new_state))
	return ..()

///override for MOVING_TO_ATOM to unregister signals for maintaining distance with our target and attacking
/datum/ai_behavior/puppet/unregister_action_signals(action_type)
	if(action_type == MOVING_TO_ATOM)
		UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
		if(!isnull(atom_to_walk_to))
			UnregisterSignal(atom_to_walk_to, list(COMSIG_MOB_DEATH, COMSIG_QDELETING))
	return ..()

///attack the first closest human, by moving towards it
/datum/ai_behavior/puppet/proc/seek_and_attack_closest(mob/living/source)
	var/victim = get_nearest_target(mob_parent, target_distance, TARGET_HUMAN, mob_parent.faction)
	if(!victim)
		return FALSE
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

	change_action(MOVING_TO_ATOM, pick(possible_victims))
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
				change_action(MOVING_TO_ATOM, target)
				return TRUE
			else
				return seek_and_attack()
		if(PUPPET_SCOUT) //makes our parent wander and turn off recalling if out of range
			too_far_escort = FALSE
			base_action = MOVING_TO_NODE
			change_action(MOVING_TO_NODE)
			return TRUE

///behavior to deal with obstacles
/datum/ai_behavior/puppet/deal_with_obstacle(datum/source, direction)
	var/turf/obstacle_turf = get_step(mob_parent, direction)
	if(obstacle_turf.flags_atom & AI_BLOCKED)
		return
	for(var/thing in obstacle_turf.contents)
		if(istype(thing, /obj/structure/window_frame)) //if its a window, climb it after 2 seconds
			LAZYINCREMENT(mob_parent.do_actions, obstacle_turf)
			addtimer(CALLBACK(src, PROC_REF(climb_window_frame), obstacle_turf), 2 SECONDS)
			return COMSIG_OBSTACLE_DEALT_WITH
		if(istype(thing, /obj/alien)) //dont attack resin and such
			return
		if(isobj(thing)) //otherwise smash it if its damageable
			var/obj/obstacle = thing
			if(obstacle.resistance_flags & XENO_DAMAGEABLE)
				INVOKE_ASYNC(src, PROC_REF(attack_target), null, obstacle)
				return COMSIG_OBSTACLE_DEALT_WITH
	if(ISDIAGONALDIR(direction) && ((deal_with_obstacle(null, turn(direction, -45)) & COMSIG_OBSTACLE_DEALT_WITH) || (deal_with_obstacle(null, turn(direction, 45)) & COMSIG_OBSTACLE_DEALT_WITH)))
		return COMSIG_OBSTACLE_DEALT_WITH

///makes our parent climb over a turf with a window by setting its location to it
/datum/ai_behavior/puppet/proc/climb_window_frame(turf/window_turf)
	mob_parent.loc = window_turf
	mob_parent.last_move_time = world.time
	LAZYDECREMENT(mob_parent.do_actions, window_turf)

///uses our feed ability if possible and it exists, on the target
/datum/ai_behavior/puppet/proc/do_feed(atom/target)
	if(mob_parent.do_actions)
		return
	if(!feed)
		return
	if(feed.ai_should_use(target))
		feed.use_ability(target)
