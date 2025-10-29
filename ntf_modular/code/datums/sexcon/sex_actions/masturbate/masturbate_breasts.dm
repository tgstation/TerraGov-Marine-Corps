/datum/sex_action/masturbate_breasts
	name = "Rub breasts"
	heal_sex = FALSE

/datum/sex_action/masturbate_breasts/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user != target)
		return FALSE

	return TRUE

/datum/sex_action/masturbate_breasts/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user != target)
		return FALSE


	return TRUE

/datum/sex_action/masturbate_breasts/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts rubbing [user.p_their()] breasts..."))

/datum/sex_action/masturbate_breasts/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fondles [user.p_their()] breasts..."))

	user.sexcon.perform_sex_action(user, 1, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/masturbate_breasts/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops fondling [user.p_their()] breasts."))

/datum/sex_action/masturbate_breasts/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
