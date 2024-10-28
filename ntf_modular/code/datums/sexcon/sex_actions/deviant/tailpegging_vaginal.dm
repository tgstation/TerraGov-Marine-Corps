/datum/sex_action/tailpegging_vaginal
	name = "Peg cunt with tail"
	check_incapacitated = FALSE

/datum/sex_action/tailpegging_vaginal/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	if(isxeno(target))
		var/mob/living/carbon/xenomorph/targetxeno
		if(targetxeno.client?.prefs?.xenogender != 2)
			return FALSE
	else
		if(target.gender != FEMALE)
			return FALSE
	if(!isxeno(user))
		return FALSE
	return TRUE

/datum/sex_action/tailpegging_vaginal/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)

	if(!isxeno(user))
		return FALSE
	return TRUE

/datum/sex_action/tailpegging_vaginal/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] slides their tail into [target]'s cunt!"))
	playsound(target, list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg'), 20, TRUE)

/datum/sex_action/tailpegging_vaginal/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [target]'s cunt with their tail."))
	playsound(target, 'ntf_modular/sound/misc/mat/segso.ogg', 50, TRUE)
	do_thrust_animate(user, target)

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.2, 4, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.4, 9, FALSE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/tailpegging_vaginal/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls their tail out of [target]'s cunt."))
