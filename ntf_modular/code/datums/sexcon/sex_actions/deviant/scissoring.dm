/datum/sex_action/scissoring
	name = "Scissor them"
	check_incapacitated = FALSE

/datum/sex_action/scissoring/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE


	return TRUE

/datum/sex_action/scissoring/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/scissoring/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] spreads [user.p_their()] legs and aligns [user.p_their()] cunt against [target]'s own!"))

/datum/sex_action/scissoring/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] scissors with [target]'s cunt."))
	playsound(target, 'ntf_modular/sound/misc/mat/segso.ogg', 50, TRUE, 5, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	user.sexcon.perform_sex_action(user, 1, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	user.sexcon.perform_sex_action(target, 1, 4, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/scissoring/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] stops scissoring with [target]."))
