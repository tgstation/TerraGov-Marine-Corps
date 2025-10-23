/datum/sex_action/masturbate_vagina
	name = "Stroke clit"
	heal_sex = FALSE

/datum/sex_action/masturbate_vagina/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user != target)
		return FALSE

	return TRUE

/datum/sex_action/masturbate_vagina/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user != target)
		return FALSE

	return TRUE

/datum/sex_action/masturbate_vagina/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts stroking [user.p_their()] clit..."))

/datum/sex_action/masturbate_vagina/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] strokes [user.p_their()] clit..."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 30, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)

	user.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/masturbate_vagina/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops stroking."))

/datum/sex_action/masturbate_vagina/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
