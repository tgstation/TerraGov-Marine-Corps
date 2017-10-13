/turf/simulated/wall/wood
	name = "wood wall"
	icon = 'icons/turf/wood.dmi'
	icon_state = "wood0"
	walltype = "wood"

/turf/simulated/wall/wood/handle_icon_junction(junction)
	if (!walltype)
		return

	var/r1 = rand(0,10) //Make a random chance for this to happen
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "wood_variant"
	else
		icon_state = "[walltype][junction]"