/datum/sex_action/force_ear_sex
	name = "Force them to fuck ear"
	require_grab = TRUE
	stamina_cost = 1.0

/datum/sex_action/force_ear_sex/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_ear_sex/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE


	return TRUE

/datum/sex_action/force_ear_sex/on_start(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] forces [user.p_their()] ear against [target]'s cock!"))
	playsound(target, pick(list('ntf_modular/sound/misc/mat/insert (1).ogg','ntf_modular/sound/misc/mat/insert (2).ogg')), 20, TRUE, 7, ignore_walls = FALSE)

/datum/sex_action/force_ear_sex/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to fuck [user.p_their()] ear."))
	user.make_sucking_noise()
	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	if(target.sexcon.considered_limp())
		target.sexcon.perform_sex_action(target, 1.2, 3, FALSE)
	else
		target.sexcon.perform_sex_action(target, 2.4, 7, FALSE)
		if(user.sexcon.force > SEX_FORCE_HIGH)
			user.adjust_ear_damage(0.2)
		if(user.sexcon.force > SEX_FORCE_HIGH)
			if(prob(15))
				to_chat(target, span_warning("I feel something squish against my tip..."))
			user.adjustBrainLoss(0.2)

	if(target.sexcon.check_active_ejaculation())
		target.visible_message(span_lovebold("[target] cums into [user]'s ear!"))
		target.sexcon.cum_into(FALSE, user)
		if(isxeno(target))
			var/mob/living/carbon/xenomorph/X = target
			X.impregify(user, "ear")

/datum/sex_action/force_ear_sex/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] pulls [user.p_their()] ear away from [target]'s cock."))

/datum/sex_action/force_ear_sex/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
