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

///Clears parent if parent is deleted
/mob/illusion/proc/on_parent_del()
	SIGNAL_HANDLER
	original_mob = null

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

/mob/illusion/xeno/Initialize(mapload, mob/living/carbon/xenomorph/original_mob, atom/escorted_atom, life_time, ai_behavior_typepath = /datum/ai_behavior/xeno/illusion)
	. = ..()
	if(.)
		return INITIALIZE_HINT_QDEL
	add_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED, TRUE, 0, NONE, TRUE, MOB_RUN_MOVE_MOD + original_mob.xeno_caste.speed * 1.3)
	AddComponent(/datum/component/ai_controller, ai_behavior_typepath, escorted_atom)

/mob/illusion/xeno/copy_appearance(mob/copy_mob)
	. = ..()
	RegisterSignal(original_mob, COMSIG_MOB_DEATH, PROC_REF(on_parent_del))

/mob/illusion/xeno/on_parent_del()
	qdel(src)

/mob/illusion/mirage_nade/process()
	. = ..()
	step(src, pick(GLOB.cardinals))
