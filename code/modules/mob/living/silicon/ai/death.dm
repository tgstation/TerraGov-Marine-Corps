/mob/living/silicon/ai/on_death()
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

	to_chat(src,"<b>[span_deadsay("<p style='font-size:1.5em'><big>You have been shut down.</big></p>")]</b>")

	return ..()
