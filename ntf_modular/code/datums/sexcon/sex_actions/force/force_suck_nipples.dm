/datum/sex_action/force_suck_nipples
	name = "Force them to suck nipples"
	require_grab = TRUE
	stamina_cost = 1.0

/datum/sex_action/force_suck_nipples/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_suck_nipples/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_suck_nipples/on_start(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] forces [target]'s head down to suck on their nipples!"))
	playsound(target, list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg'), 20, TRUE)

/datum/sex_action/force_suck_nipples/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to suck their nipples."))
	target.make_sucking_noise()

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)

	user.sexcon.perform_sex_action(target, 0, 7, FALSE)
	if(!user.sexcon.considered_limp())
		var/oxyloss = 0.6
		if(isxeno(user))
			oxyloss *= 2
		user.sexcon.perform_deepthroat_oxyloss(target, oxyloss)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/force_suck_nipples/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] pulls their nipples out of [target]'s mouth."))

/datum/sex_action/force_suck_nipples/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
