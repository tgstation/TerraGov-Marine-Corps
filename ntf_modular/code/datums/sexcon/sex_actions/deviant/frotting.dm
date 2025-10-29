/datum/sex_action/frotting
	name = "Frot them"
	check_incapacitated = FALSE

/datum/sex_action/frotting/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/frotting/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/frotting/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] shoves [user.p_their()] cock against [target]'s own!"))

/datum/sex_action/frotting/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] frots cocks together with [target]'s."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 20, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(user, 1, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	user.sexcon.perform_sex_action(target, 1, 4, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/frotting/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] lets go of both their cocks."))
