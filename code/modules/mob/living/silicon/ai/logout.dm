/mob/living/silicon/ai/Logout()
	. = ..()
	for(var/i in GLOB.ai_status_displays) //change status
		var/obj/machinery/status_display/ai/O = i
		O.mode = 0
		O.update()
	set_eyeobj_visible(FALSE)
	view_core()