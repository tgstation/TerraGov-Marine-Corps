/datum/sex_action/crotch_nuzzle
	name = "Nuzzle their crotch"
	check_incapacitated = FALSE
	heal_sex = FALSE

/datum/sex_action/crotch_nuzzle/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/crotch_nuzzle/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/crotch_nuzzle/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] moves [user.p_their()] head against [target]'s crotch..."))

/datum/sex_action/crotch_nuzzle/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] nuzzles [target]'s crotch..."))

	user.sexcon.perform_sex_action(target, 0.5, 0, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/crotch_nuzzle/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops nuzzling [target]'s crotch..."))

/datum/sex_action/crotch_nuzzle/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
