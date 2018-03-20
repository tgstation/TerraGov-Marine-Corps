
/mob/living/carbon/hellhound/update_icons()
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