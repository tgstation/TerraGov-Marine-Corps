/datum/sex_action/candle_breasts
	name = "Use candle wax on their breasts"
	heal_sex = FALSE

/datum/sex_action/candle_breasts/shows_on_menu(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	if(!get_candle_in_either_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/candle_breasts/can_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user == target)
		return FALSE
	if(!get_candle_in_either_hand(user))
		return FALSE
	var/obj/item/tool/candle/C = get_candle_in_either_hand(user)
	if(!C.heat)
		to_chat(usr, span_warning("Light it first!"))
		return FALSE

	return TRUE

/datum/sex_action/candle_breasts/on_start(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] begins to drop wax [target]'s breasts..."))

/datum/sex_action/candle_breasts/on_perform(mob/living/carbon/user, mob/living/carbon/target)
	if(user.sexcon.do_message_signature("[type]"))
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] drops wax on [target]'s breasts..."))

	user.sexcon.perform_sex_action(target, 0.5, 0, TRUE)
	target.sexcon.handle_passive_ejaculation(user)

	if(prob(33))
		to_chat(target, span_warning("It's hot!"))
		playsound(src, 'sound/items/cig_snuff.ogg', 20, FALSE, 7, ignore_walls = FALSE)

/datum/sex_action/candle_breasts/on_finish(mob/living/carbon/user, mob/living/carbon/target)
	user.visible_message(span_warning("[user] stops dropping wax on [target]'s breasts..."))

/datum/sex_action/candle_breasts/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
