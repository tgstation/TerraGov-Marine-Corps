/datum/sex_action/rub_body
	name = "Rub their body"
	check_same_tile = FALSE
	heal_sex = FALSE

/datum/sex_action/rub_body/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/rub_body/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/rub_body/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] places [user.p_their()] hands onto [target]..."))

/datum/sex_action/rub_body/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] rubs [target]'s body..."))
	user.make_sucking_noise()

	user.sexcon.perform_sex_action(target, 0.5, 0, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/rub_body/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops rubbing [target]'s body ..."))

/datum/sex_action/rub_body/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
