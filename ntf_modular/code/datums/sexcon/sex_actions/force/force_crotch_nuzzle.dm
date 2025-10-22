/datum/sex_action/force_crotch_nuzzle
	name = "Force them to nuzzle"
	require_grab = TRUE
	stamina_cost = 1.0
	heal_sex = FALSE


/datum/sex_action/force_crotch_nuzzle/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_crotch_nuzzle/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_crotch_nuzzle/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] forces [target]'s head against [user.p_their()] crotch!"))

/datum/sex_action/force_crotch_nuzzle/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to nuzzle [user.p_their()] crotch."))

	user.sexcon.perform_sex_action(user, 0.5, 0, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

/datum/sex_action/force_crotch_nuzzle/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls [target]'s head away from [user.p_their()] crotch."))

/datum/sex_action/force_crotch_nuzzle/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
