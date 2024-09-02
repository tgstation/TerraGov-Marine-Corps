/datum/ai_behavior/xeno/illusion
	target_distance = 3 //We attack only nearby
	base_action = ESCORTING_ATOM
	is_offered_on_creation = FALSE
	/// How close a human has to be in order for illusions to react
	var/illusion_react_range = 5

/datum/ai_behavior/xeno/illusion/New(loc, parent_to_assign, escorted_atom)
	if(!escorted_atom)
		base_action = MOVING_TO_NODE
	..()

/// We want a separate look_for_new_state in order to make illusions behave as we wish
/datum/ai_behavior/xeno/illusion/look_for_new_state()
	switch(current_action)
		if(ESCORTING_ATOM)
			for(var/mob/living/carbon/human/victim in view(illusion_react_range, mob_parent))
				if(victim.stat == DEAD)
					continue
				attack_target(src, victim)
				set_escorted_atom(src, victim)
				return

/datum/ai_behavior/xeno/illusion/attack_target(datum/soure, atom/attacked)
	if(!attacked)
		attacked = atom_to_walk_to
	var/mob/illusion/illusion_parent = mob_parent
	var/mob/living/carbon/xenomorph/original_xeno = illusion_parent.original_mob
	mob_parent.changeNext_move(original_xeno.xeno_caste.attack_delay)
	if(ismob(attacked))
		mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_REDSLASH)
		playsound(mob_parent.loc, SFX_ALIEN_CLAW_FLESH, 25, 1)
		return
	mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_CLAW)

/mob/illusion
	density = FALSE
	status_flags = GODMODE
	layer = BELOW_MOB_LAYER
	move_resist = MOVE_FORCE_OVERPOWERING
	///The parent mob the illusion is a copy of
	var/mob/original_mob
	/// Timer to remove the hit effect
	var/timer_effect

/mob/illusion/Initialize(mapload, mob/copy_mob, atom/escorted_atom, life_time)
	. = ..()
	if(!copy_mob)
		return INITIALIZE_HINT_QDEL
	copy_appearance(copy_mob)
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, life_time)

/mob/illusion/Destroy()
	original_mob = null
	deltimer(timer_effect)
	return ..()

/mob/illusion/examine(mob/user)
	if(original_mob)
		return original_mob.examine(user)
	return ..()

/mob/illusion/process()
	if(original_mob)
		appearance = original_mob.appearance
		vis_contents = original_mob.vis_contents

/mob/illusion/projectile_hit()
	add_hit_filter()
	return FALSE

/mob/illusion/ex_act(severity)
	add_hit_filter()

///Sets the illusion to a specified mob
/mob/illusion/proc/copy_appearance(mob/copy_mob)
	original_mob = copy_mob
	appearance = original_mob.appearance
	vis_contents = original_mob.vis_contents
	render_target = null
	faction = original_mob.faction
	setDir(original_mob.dir)
	RegisterSignal(original_mob, COMSIG_QDELETING, PROC_REF(on_parent_del))

///Delete this illusion when the original xeno is ded
/mob/illusion/proc/destroy_illusion()
	SIGNAL_HANDLER
	qdel(src)

///Adds an animated hit filter
/mob/illusion/proc/add_hit_filter()
	remove_filter(ILLUSION_HIT_FILTER)
	deltimer(timer_effect)
	add_filter(ILLUSION_HIT_FILTER, 2, wave_filter(20, 5))
	animate(get_filter(ILLUSION_HIT_FILTER), x = 0, y = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
	timer_effect = addtimer(CALLBACK(src, PROC_REF(remove_hit_filter)), 0.5 SECONDS, TIMER_STOPPABLE)

///Remove the filter effect added when it is hit
/mob/illusion/proc/remove_hit_filter()
	remove_filter(ILLUSION_HIT_FILTER)

///Clears parent if parent is deleted
/mob/illusion/proc/on_parent_del()
	SIGNAL_HANDLER
	original_mob = null

/mob/illusion/xeno/Initialize(mapload, mob/living/carbon/xenomorph/original_mob, atom/escorted_atom, life_time)
	. = ..()
	if(.)
		return INITIALIZE_HINT_QDEL
	add_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED, TRUE, 0, NONE, TRUE, MOB_RUN_MOVE_MOD + original_mob.xeno_caste.speed * 1.3)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/illusion, escorted_atom)

/mob/illusion/xeno/copy_appearance(mob/copy_mob)
	. = ..()
	RegisterSignal(original_mob, COMSIG_MOB_DEATH, PROC_REF(on_parent_del))

/mob/illusion/mirage_nade/process()
	. = ..()
	step(src, pick(GLOB.cardinals))
