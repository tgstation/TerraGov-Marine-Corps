/datum/sex_action/facesitting
	name = "Sit on their face"
	check_incapacitated = FALSE


/datum/sex_action/facesitting/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/facesitting/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE	// Need to stand up
	if(user.resting)
		return FALSE
	// Target can't stand up
	if(!target.resting)
		return FALSE
	return TRUE

/datum/sex_action/facesitting/on_start(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] sits [user.p_their()] butt on [target]'s face!"))

/datum/sex_action/facesitting/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	var/verbstring = pick(list("rubs", "smushes", "forces"))
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [verbstring] [user.p_their()] butt against [target] face."))
	target.make_sucking_noise()
	do_thrust_animate(user, target)

	user.sexcon.perform_sex_action(user, 1, 3, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	var/oxyloss = 1.3
	if(isxeno(user))
		oxyloss *= 2
	user.sexcon.perform_deepthroat_oxyloss(target, oxyloss)
	user.sexcon.perform_sex_action(target, 0, 2, FALSE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/facesitting/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	..()
	user.visible_message(span_warning("[user] gets off [target]'s face."))

/datum/sex_action/facesitting/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

/datum/sex_action/facesittingtwo
	name = "Sit on their face with cunt"

/datum/sex_action/facesittingtwo/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE

	return TRUE

/datum/sex_action/facesittingtwo/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	// Need to stand up
	if(user.resting)
		return FALSE
	// Target can't stand up
	if(!target.resting)
		return FALSE
	return TRUE

/datum/sex_action/facesittingtwo/on_start(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] sits [user.p_their()] cunt on [target]'s face!"))

/datum/sex_action/facesittingtwo/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	var/verbstring = pick(list("rubs", "smushes", "forces"))
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [verbstring] their cunt against [target] face."))
	target.make_sucking_noise()

	user.sexcon.perform_sex_action(user, 1, 3, TRUE)
	user.sexcon.handle_passive_ejaculation(target)

	var/oxyloss = 1.3
	if(isxeno(user))
		oxyloss *= 2
	user.sexcon.perform_deepthroat_oxyloss(target, oxyloss)
	user.sexcon.perform_sex_action(target, 0, 2, FALSE)
	target.sexcon.handle_passive_ejaculation(user)

/datum/sex_action/facesittingtwo/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] gets off [target]'s face."))

/datum/sex_action/facesittingtwo/is_finished(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
