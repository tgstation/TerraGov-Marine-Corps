/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	icon_state = "ai-crash"

	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
		set_eyeobj_visible(FALSE)