//Everything needed for the mirage ability

/mob/illusion
	density = FALSE
	status_flags = GODMODE
	///The parent xenomorph the illusion is a copy of
	var/mob/living/carbon/xenomorph/original_xeno

/mob/illusion/Initialize(mapload, mob/living/carbon/xenomorph/original_xeno, life_time)
	. = ..()
	src.original_xeno = original_xeno
	add_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED, TRUE, 0, NONE, TRUE, original_xeno.xeno_caste.speed * 1.3)
	appearance = original_xeno.appearance
	desc = original_xeno.desc
	name = original_xeno.name
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno/illusion, original_xeno)
	RegisterSignal(original_xeno, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/destroy_illusion)
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, life_time)

/mob/illusion/Destroy()
	original_xeno = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

///Delete this illusion when the original xeno is dead
/mob/illusion/proc/destroy_illusion()
	SIGNAL_HANDLER
	qdel(src)

/mob/illusion/process()
	appearance = original_xeno.appearance

/datum/ai_behavior/carbon/xeno/illusion
	target_distance = 3 //We attack only near
	base_behavior = ESCORTING_ATOM

/datum/ai_behavior/carbon/xeno/illusion/attack_atom(atom/attacked)
	var/mob/living/carbon/xenomorph/xeno = escorted_atom
	mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_BITE)
	mob_parent.changeNext_move(xeno.xeno_caste.attack_delay)
