/datum/sex_action/titjob
	name = "Use their tits to get off"

/datum/sex_action/titjob/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/titjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/titjob/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] grabs [target]'s tits and shoves [user.p_their()] cock inbetween!"))

/datum/sex_action/titjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [target]'s tits."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 20, TRUE, 5, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

/datum/sex_action/titjob/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out from inbetween [target]'s tits."))
