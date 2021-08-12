/datum/ai_behavior/carbon/xeno/illusion
	target_distance = 3 //We attack only near
	base_action = ESCORTING_ATOM

/datum/ai_behavior/carbon/xeno/illusion/attack_target(atom/attacked)
	var/mob/illusion/illusion_parent = mob_parent
	var/mob/living/carbon/xenomorph/original_xeno = illusion_parent.original_mob
	mob_parent.changeNext_move(original_xeno.xeno_caste.attack_delay)
	if(ismob(attacked))
		mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_REDSLASH)
		playsound(mob_parent.loc, "alien_claw_flesh", 25, 1)
		return
	mob_parent.do_attack_animation(attacked, ATTACK_EFFECT_CLAW)
