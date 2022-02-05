/mob/living/silicon/ai/Logout()
	. = ..()
	for(var/obj/machinery/status_display/ai/O AS in GLOB.ai_status_displays) //change status
		O.mode = 0
		O.update()
	set_eyeobj_visible(FALSE)
	view_core()
