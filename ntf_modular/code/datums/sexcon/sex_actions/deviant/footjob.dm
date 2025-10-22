/datum/sex_action/footjob
	name = "Jerk them off with feet"
	check_same_tile = FALSE
	check_incapacitated = FALSE

/datum/sex_action/footjob/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/footjob/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/footjob/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] puts [user.p_their()] feet on [target]'s cock..."))

/datum/sex_action/footjob/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] jerks [target]'s cock with [user.p_their()] feet..."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 30, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(target, 2, 4, TRUE)

	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/footjob/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops jerking [target] off with [user.p_their()] feet."))

/datum/sex_action/footjob/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
