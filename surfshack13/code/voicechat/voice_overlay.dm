/mob/proc/toggle_voice_overlay(on = TRUE, voice_icon_state = "default")
	if(on)
		if(!voice_image)
			voice_image = mutable_appearance('surfshack13/icon/mob/effects/voice_overlay.dmi', icon_state = voice_icon_state)
		else if(voice_image.icon_state != voice_icon_state)
			cut_overlay(voice_image)
			voice_image = mutable_appearance('surfshack13/icon/mob/effects/voice_overlay.dmi', icon_state = voice_icon_state)
		add_overlay(voice_image)
	else
		if(!voice_image)
			return
		cut_overlay(voice_image)

/mob/living/carbon/xenomorph/toggle_voice_overlay(on, voice_icon_state)
	if(mob_size == MOB_SIZE_BIG)
		voice_icon_state = "ayy_lmao"
	else
		voice_icon_state = "ayy"
	. = ..()


//left facing icons need to be added


