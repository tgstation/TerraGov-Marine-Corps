/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	var/old_icon = icon_state
	if("[icon_state]_dead" in icon_states(icon))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"
	if("[old_icon]_death_transition" in icon_states(icon))
		flick("[old_icon]_death_transition", src)

	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
		set_eyeobj_visible(FALSE)