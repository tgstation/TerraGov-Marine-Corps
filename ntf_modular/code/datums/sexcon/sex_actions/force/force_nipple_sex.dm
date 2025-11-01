/datum/sex_action/force_nipple_sex
	name = "Force them to fuck nipple"
	require_grab = TRUE
	stamina_cost = 1.0

/datum/sex_action/force_nipple_sex/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_nipple_sex/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_nipple_sex/on_start(mob/living/carbon/user, mob/living/carbon/target)
	target.visible_message(span_warning("[user] grabs [target] and shoves [target.p_their()] cock into [user.p_their()]  own nipple!"))
	playsound(target, pick(list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg')), 20, TRUE, 7, ignore_walls = FALSE)

/datum/sex_action/force_nipple_sex/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [user.p_their()]  nipple against [target]'s cock forcibly."))
	target.make_sucking_noise()

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	if(target.sexcon.check_active_ejaculation())
		user.visible_message(span_love("[target] cums into [user]'s nipple!"))
		target.sexcon.cum_into(FALSE, user)
		if(isxeno(target))
			var/mob/living/carbon/xenomorph/X = target
			X.impregify(user, "nipple")

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.2, 3, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.4, 7, FALSE)
	user.sexcon.handle_passive_ejaculation(target)

/datum/sex_action/force_nipple_sex/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] pulls [target]'s cock out of [user.p_their()]  nipple."))

/datum/sex_action/force_nipple_sex/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
