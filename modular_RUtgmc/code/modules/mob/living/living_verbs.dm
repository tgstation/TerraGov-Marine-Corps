/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	if(!resting)
		if(is_ventcrawling)
			return FALSE
		set_resting(TRUE, FALSE)
	else if(do_actions)
		to_chat(src, span_warning("You are still in the process of standing up."))
		return
	else if(do_mob(src, src, 2 SECONDS, ignore_flags = (IGNORE_LOC_CHANGE|IGNORE_HAND)))
		get_up()

/mob/living/proc/get_up()
	set_resting(FALSE, FALSE)

