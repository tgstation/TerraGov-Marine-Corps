/mob/illusion
	density = FALSE
	status_flags = GODMODE
	layer = BELOW_MOB_LAYER
	///The parent mob the illusion is a copy of
	var/mob/original_mob

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

/mob/illusion/xeno/Initialize(mapload, mob/living/carbon/xenomorph/original_mob, atom/escorted_atom, life_time)
	. = ..()
	add_movespeed_modifier(MOVESPEED_ID_XENO_CASTE_SPEED, TRUE, 0, NONE, TRUE, original_mob.xeno_caste.speed * 1.3)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno/illusion, escorted_atom)
