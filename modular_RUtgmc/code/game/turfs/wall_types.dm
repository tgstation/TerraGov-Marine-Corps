/turf/closed/wall/indestructible/splashscreen
	icon = 'modular_RUtgmc/icons/misc/title.dmi'

/turf/closed/wall/indestructible/splashscreen/New()
	..()
	if(icon_state == "title_painting1")
		icon_state = "title_painting[rand(0,39)]"
