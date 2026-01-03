/mob/living/carbon/xenomorph/hunter/assassin
	icon_state = "Assassin Hunter Running"
	caste_base_type = /datum/xeno_caste/hunter/assassin

/mob/living/carbon/xenomorph/hunter/assassin/Life(seconds_per_tick, times_fired)
	. = ..()
	if(status_flags & INCORPOREAL)
		if(!loc_weeds_type)
			use_plasma(4, TRUE)
			if(plasma_stored <= 0)
				var/datum/action/ability/xeno_action/displacement/displacement = actions_by_path[/datum/action/ability/xeno_action/displacement]
				displacement.do_change_form(src)
				emote("roar3")
				death(TRUE)

/mob/living/carbon/xenomorph/hunter/assassin/death(gibbing, deathmessage, silent)
	if(status_flags & INCORPOREAL)
		var/datum/action/ability/xeno_action/displacement/displacement = actions_by_path[/datum/action/ability/xeno_action/displacement]
		displacement.do_change_form(src)
		death(FALSE)
	. = ..()
