/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls/rwall.dmi'
	icon_state = "wall-reinforced"
	base_icon_state = "rwall"
	opacity = TRUE
	density = TRUE

	max_integrity = 3000
	max_temperature = 6000

	walltype = "rwall"
	explosion_block = 4

/turf/closed/wall/r_wall/get_acid_delay()
	return 10 SECONDS

/turf/closed/wall/r_wall/dissolvability(acid_strength)
	if(acid_strength < STRONG_ACID_STRENGTH)
		return 0
	return 0.5

//Just different looking wall
/turf/closed/wall/r_wall/research
	icon_state = "research"
	walltype = "research"

/turf/closed/wall/r_wall/dense
	icon_state = "iron0"
	walltype = "iron"
	resistance_flags = RESIST_ALL

/turf/closed/wall/r_wall/unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon_state = "wall-invincible"
	walltype = "rwall"
	resistance_flags = RESIST_ALL

/turf/closed/wall/r_wall/unmeltable/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return

/turf/closed/wall/r_wall/unmeltable/regular //looks like a regular wall, behaves like an invincible wall
	icon = 'icons/turf/walls/regular_wall.dmi'
	icon_state = "metal-0"
	walltype = "metal"
	base_icon_state = "metal"


//Chigusa

/turf/closed/wall/r_wall/chigusa
	name = "facility wall"
	icon = 'icons/turf/walls/chigusa.dmi'
	icon_state = "wall-reinforced"
	walltype = "chigusa"
	base_icon_state = "chigusa"




//Prison

/turf/closed/wall/r_wall/prison
	name = "reinforced metal wall"
	icon = 'icons/turf/walls/gorg_prison_rwall_two.dmi'
	icon_state = "rwall-0"
	walltype = "rwall"
	base_icon_state = "rwall"
	icon_state = "wall-reinforced"

/turf/closed/wall/r_wall/prison_unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon = 'icons/turf/walls/gorg_prison_rwall_two.dmi'
	icon_state = "wall-invincible"
	walltype = "rwall"
	resistance_flags = RESIST_ALL
	base_icon_state = "rwall"

/turf/closed/wall/r_wall/prison_unmeltable/ex_act(severity) //Should make it indestructable
	return

/turf/closed/wall/r_wall/prison_unmeltable/fire_act(exposed_temperature, exposed_volume)
	return

/turf/closed/wall/r_wall/prison_unmeltable/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return
