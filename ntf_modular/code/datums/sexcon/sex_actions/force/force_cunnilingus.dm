/datum/sex_action/force_cunnilingus
	name = "Force them to suck clit"
	require_grab = TRUE
	stamina_cost = 1.0


/datum/sex_action/force_cunnilingus/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE


	return TRUE

/datum/sex_action/force_cunnilingus/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_cunnilingus/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] forces [target]'s head against [user.p_their()] cunt!"))

/datum/sex_action/force_cunnilingus/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to suck [user.p_their()] cunt."))
	target.make_sucking_noise()
	do_thrust_animate(target, user)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	user.sexcon.perform_sex_action(target, 0, 2, FALSE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/force_cunnilingus/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls [target]'s head away."))

/datum/sex_action/force_cunnilingus/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
