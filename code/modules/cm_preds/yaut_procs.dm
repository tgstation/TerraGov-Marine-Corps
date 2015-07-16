//Update the power display thing. This is called in Life()
/mob/living/carbon/human/proc/update_power_display(var/perc)
	if(pred_power_icon)
		switch(perc)
			if(91 to INFINITY)
				pred_power_icon.icon_state = "powerbar100"
			if(81 to 91)
				pred_power_icon.icon_state = "powerbar90"
			if(71 to 81)
				pred_power_icon.icon_state = "powerbar80"
			if(61 to 71)
				pred_power_icon.icon_state = "powerbar70"
			if(51 to 61)
				pred_power_icon.icon_state = "powerbar60"
			if(41 to 51)
				pred_power_icon.icon_state = "powerbar50"
			if(31 to 41)
				pred_power_icon.icon_state = "powerbar40"
			if(21 to 31)
				pred_power_icon.icon_state = "powerbar30"
			if(11 to 21)
				pred_power_icon.icon_state = "powerbar20"
			else
				pred_power_icon.icon_state = "powerbar10"

//Uses the base hud_data, which is human, but just tweaks one lil thing.
/datum/hud_data/yautja
	is_yautja = 1

