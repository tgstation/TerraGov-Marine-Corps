/proc/mix_color_from_reagents(list/reagent_list)
	if(!istype(reagent_list))
		return

	var/mixcolor
	var/vol_counter = 0
	var/vol_temp

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		vol_temp = R.volume
		vol_counter += vol_temp

		if(!mixcolor)
			mixcolor = R.color

		else if (length(mixcolor) >= length(R.color))
			mixcolor = BlendRGB(mixcolor, R.color, vol_temp/vol_counter)
		else
			mixcolor = BlendRGB(R.color, mixcolor, vol_temp/vol_counter)

	return mixcolor
