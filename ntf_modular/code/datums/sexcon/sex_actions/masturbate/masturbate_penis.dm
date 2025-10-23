/datum/sex_action/masturbate_penis
	name = "Jerk off"
	heal_sex = FALSE

/datum/sex_action/masturbate_penis/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user != target)
		return FALSE

	return TRUE

/datum/sex_action/masturbate_penis/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user != target)
		return FALSE


	return TRUE

/datum/sex_action/masturbate_penis/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts jerking off..."))

/datum/sex_action/masturbate_penis/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/chosen_verb = pick(list("jerks [user.p_their()] cock", "strokes [user.p_their()] cock", "masturbates", "jerks off"))
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [chosen_verb]..."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 30, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(user, 2, 0, TRUE)

	user.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/masturbate_penis/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops jerking off."))

/datum/sex_action/masturbate_penis/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
