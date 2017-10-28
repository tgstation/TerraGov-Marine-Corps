
/mob/living/carbon/hellhound/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "hellhound_dead"
	else
		if(lying)
			if(resting)
				icon_state = "hellhound_sleeping"
			else
				icon_state = "hellhound_ko"
		else
			icon_state = "hellhound"

		if(src.health < 30)
			var/image/bloody = image("icon" = src.icon, "icon_state" = "bloodsmear")
			overlays += bloody