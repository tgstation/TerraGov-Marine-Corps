/turf/simulated/wall/prison
	name = "metal wall"
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "metal0"
	walltype = "metal"

/turf/simulated/wall/r_wall/prison
	name = "reinforced metal wall"
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "rwall0"
	walltype = "rwall"

/turf/simulated/wall/r_wall/prison_unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "rwall0"
	walltype = "rwall"
	hull = 1

	ex_act(severity) //Should make it indestructable
		return

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	attackby() //This should fix everything else. No cables, etc
		return