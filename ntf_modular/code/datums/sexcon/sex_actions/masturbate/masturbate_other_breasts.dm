/datum/sex_action/masturbate_other_breasts
	name = "Rub their breasts"
	check_same_tile = FALSE
	heal_sex = FALSE

/datum/sex_action/masturbate_other_breasts/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate_other_breasts/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate_other_breasts/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts rubbing [target]'s breasts..."))

/datum/sex_action/masturbate_other_breasts/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fondles [target]'s breasts..."))

	user.sexcon.perform_sex_action(target, 1, 4, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/masturbate_other_breasts/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops stroking [target]'s breasts."))

/datum/sex_action/masturbate_other_breasts/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
