/datum/sex_action/masturbate_penis_over
	name = "Jerk over them"
	check_same_tile = FALSE
	heal_sex = FALSE

/datum/sex_action/masturbate_penis_over/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate_penis_over/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate_penis_over/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts jerking over [target]..."))

/datum/sex_action/masturbate_penis_over/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/chosen_verb = pick(list("jerks [user.p_their()] cock", "strokes [user.p_their()] cock", "masturbates", "jerks off"))
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [chosen_verb] over [target]"))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 30, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)

	if(user.sexcon.check_active_ejaculation())
		user.visible_message(span_lovebold("[user] cums over [target]'s body!"))
		user.sexcon.cum_onto(target)
		if(isxeno(user))
			target.adjustFireLoss(5, TRUE)

/datum/sex_action/masturbate_penis_over/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops jerking off."))

/datum/sex_action/masturbate_penis_over/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
