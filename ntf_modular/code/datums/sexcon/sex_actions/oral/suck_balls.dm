/datum/sex_action/suck_balls
	name = "Suck their balls"
	check_incapacitated = FALSE


/datum/sex_action/suck_balls/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/suck_balls/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/suck_balls/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts sucking [target]'s balls..."))


/datum/sex_action/suck_balls/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] sucks [target]'s balls..."))
	user.make_sucking_noise()

	user.sexcon.perform_sex_action(target, 1, 3, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/suck_balls/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops sucking [target]'s balls ..."))


/datum/sex_action/suck_balls/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
