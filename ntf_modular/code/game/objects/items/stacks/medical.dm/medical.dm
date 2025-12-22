/obj/item/stack/medical/proc/heal_xeno(mob/living/carbon/xenomorph/M, mob/living/user)
	var/unskilled_penalty = (user.skills.getRating(SKILL_MEDICAL) < skill_level_needed) ? 0.5 : 1
	while(amount)
		if(!do_after(user, SKILL_TASK_VERY_EASY / (unskilled_penalty ** 2), NONE, M, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
			M.balloon_alert(user, "stopped tending")
			return FALSE
		use(1)
		record_healing(user,M)
		if(M.health >= M.maxHealth)
			to_chat(user, span_warning("The wounds on [M] have already been treated."))
			return
		user.visible_message(span_green("[user] treats the wounds on [M] with [src]."),
		span_green("You treat the wounds on [M] with [src].") )
		M.heal_overall_damage((M.maxHealth/10) * unskilled_penalty, (M.maxHealth/10) * unskilled_penalty, updating_health = TRUE)
	M.balloon_alert(user, "finished tending")
