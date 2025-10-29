/datum/sex_action/force_footjob
	name = "Use their feet to get off"
	check_same_tile = FALSE
	require_grab = TRUE
	stamina_cost = 1.0

/datum/sex_action/force_footjob/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_footjob/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/force_footjob/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] grabs [target]'s feet and clamps them around [user.p_their()] cock!"))

/datum/sex_action/force_footjob/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] uses [target] feet to jerk off."))
	playsound(user, 'ntf_modular/sound/misc/mat/fingering.ogg', 20, TRUE, 7, ignore_walls = FALSE)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

/datum/sex_action/force_footjob/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out from inbetween [target]'s feet."))
