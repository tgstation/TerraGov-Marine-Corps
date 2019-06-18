/mob/living/silicon/ai/Login()
	. = ..()
	if(stat != DEAD)
		for(var/i in GLOB.ai_status_displays) //change status
			var/obj/machinery/status_display/ai/O = i
			O.mode = 1
			O.emotion = "Neutral"
			O.update()
	set_eyeobj_visible(TRUE)
	view_core()