/datum/ai_behavior/xeno/illusion
	target_distance = 3 //We attack only nearby
	base_action = ESCORTING_ATOM

/datum/ai_behavior/xeno/illusion/New(loc, parent_to_assign, escorted_atom)
	if(!escorted_atom)
		base_action = MOVING_TO_NODE
	..()

/datum/ai_behavior/xeno/illusion/attack_target(datum/soure, atom/attacked)
	if(!attacked)
		attacked = atom_to_walk_to
	var/mob/illusion/illusion_parent = mob_parent
	var/mob/living/carbon/xenomorph/original_xeno = illusion_parent.original_mob
	mob_parent.changeNext_move(original_xeno.xeno_caste.attack_delay)
	if(ismob(attacked))
		mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_REDSLASH)
		playsound(mob_parent.loc, "alien_claw_flesh", 25, 1)
		return
	mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_CLAW)

/mob/illusion
	density = FALSE
	status_flags = GODMODE
	layer = BELOW_MOB_LAYER
	///The parent mob the illusion is a copy of
	var/mob/original_mob
	///Last time it was hit by a projectile
	var/last_hit_time = 0

/mob/illusion/Initialize(mapload, mob/original_mob, atom/escorted_atom, life_time)
	. = ..()
	src.original_mob = original_mob
	appearance = original_mob.appearance
	desc = original_mob.desc
	name = original_mob.name
	RegisterSignal(original_mob, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/destroy_illusion)
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, life_time)

/mob/illusion/Destroy()
	original_mob = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

///Delete this illusion when the original xeno is dead
/mob/illusion/proc/destroy_illusion()
	SIGNAL_HANDLER
	qdel(src)

/mob/illusion/process()
	appearance = original_mob.appearance
	if(last_hit_time >= world.time + 1 SECONDS)
		remove_filter("illusion_hit")
		last_hit_time = 0

/mob/illusion/projectile_hit()
	remove_filter("illusion_hit")
	add_filter("illusion_hit", 2, wave_filter(10, 10, 10, 8))
	last_hit_time = world.time
	return FALSE

/mob/illusion/xeno/Initialize(mapload, mob/living/carbon/xenomorph/original_mob, atom/escorted_atom, life_time)
	. = ..()
	add_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED, TRUE, 0, NONE, TRUE, original_mob.xeno_caste.speed * 1.3)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/illusion, escorted_atom)
