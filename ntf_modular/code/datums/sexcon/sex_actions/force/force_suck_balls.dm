/datum/sex_action/force_suck_balls
	name = "Force them to suck balls"
	require_grab = TRUE
	stamina_cost = 1.0

/datum/sex_action/force_suck_balls/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_suck_balls/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_suck_balls/on_start(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] forces [target]'s head down to swallow and suck on [user.p_their()] balls!"))
	playsound(target, pick(list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg')), 20, TRUE, 7, ignore_walls = FALSE)

/datum/sex_action/force_suck_balls/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to suck [user.p_their()]  balls."))
	target.make_sucking_noise()

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	if(user.sexcon.check_active_ejaculation())
		user.visible_message(span_love("cums on [target]'s head!"))
		user.sexcon.cum_onto(target)
		if(isxeno(user))
			target.adjustFireLoss(5, TRUE)

	user.sexcon.perform_sex_action(target, 0, 7, FALSE)
	if(!user.sexcon.considered_limp())
		var/oxyloss = 0.6
		if(isxeno(user))
			oxyloss *= 2
		user.sexcon.perform_deepthroat_oxyloss(target, oxyloss)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/force_suck_balls/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] pulls [user.p_their()] balls out of [target]'s mouth."))

/datum/sex_action/force_suck_balls/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
