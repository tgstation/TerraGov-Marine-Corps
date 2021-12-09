/mob/living/silicon/ai/Login()
	. = ..()
	if(stat != DEAD)
		for(var/obj/machinery/status_display/ai/O AS in GLOB.ai_status_displays) //change status
			O.mode = 1
			O.emotion = "Neutral"
			O.update()
	set_eyeobj_visible(TRUE)
	view_core()
