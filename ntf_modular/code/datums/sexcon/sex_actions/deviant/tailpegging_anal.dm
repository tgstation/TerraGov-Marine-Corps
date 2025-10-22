/datum/sex_action/tailpegging_anal
	name = "Peg butt with tail"
	check_incapacitated = FALSE

/datum/sex_action/tailpegging_anal/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	if(isxeno(user))
		return TRUE
	return FALSE

/datum/sex_action/tailpegging_anal/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(isxeno(user))
		return TRUE
	return FALSE

/datum/sex_action/tailpegging_anal/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] slides [user.p_their()] tail into [target]'s butt!"))
	playsound(target, pick(list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg')), 20, TRUE, 7, ignore_walls = FALSE)

/datum/sex_action/tailpegging_anal/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [target]'s butt with [user.p_their()] tail."))
	playsound(target, 'ntf_modular/sound/misc/mat/segso.ogg', 50, TRUE, 5, ignore_walls = FALSE)
	do_thrust_animate(user, target)


	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.2, 4, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.4, 9, FALSE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/tailpegging_anal/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] tail out of [target]'s butt."))
