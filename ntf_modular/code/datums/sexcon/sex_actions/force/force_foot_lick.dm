/datum/sex_action/force_foot_lick
	name = "Force them to lick your feet"
	check_same_tile = FALSE
	require_grab = TRUE
	stamina_cost = 1.0
	heal_sex = FALSE

/datum/sex_action/force_foot_lick/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_foot_lick/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/force_foot_lick/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] shoves [user.p_their()] feet against [target]'s head!"))

/datum/sex_action/force_foot_lick/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] forces [target] to lick [user.p_their()] feet."))
	target.make_sucking_noise()

/datum/sex_action/force_foot_lick/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] feet away from [target]'s head."))
