/datum/sex_action/masturbate_penis_other
	name = "Jerk them off"
	check_same_tile = FALSE
	heal_sex = FALSE

/datum/sex_action/masturbate_penis_other/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/masturbate_penis_other/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/masturbate_penis_other/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] starts jerking [target]'s off..."))

/datum/sex_action/masturbate_penis_other/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] jerks [target]'s cock off..."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 30, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(target, 2, 0, TRUE)

	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/masturbate_penis_other/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops jerking [target]'s off."))

/datum/sex_action/masturbate_penis_other/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
