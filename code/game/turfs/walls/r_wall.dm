/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "rwall"
	opacity = 1
	density = TRUE

	damage_cap = 3000
	max_temperature = 6000

	walltype = "rwall"

/turf/closed/wall/r_wall/attack_hand(mob/user)
	return

/turf/closed/wall/r_wall/can_be_dissolved()
	if(hull)
		return 0
	else
		return 2


//Just different looking wall
/turf/closed/wall/r_wall/research
	icon_state = "research"
	walltype = "research"

/turf/closed/wall/r_wall/dense
	icon_state = "iron0"
	walltype = "iron"
	hull = 1

/turf/closed/wall/r_wall/unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon_state = "rwall"
	walltype = "rwall"
	hull = 1

/turf/closed/wall/r_wall/unmeltable/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return





//Chigusa

/turf/closed/wall/r_wall/chigusa
	name = "facility wall"
	icon = 'icons/turf/chigusa.dmi'
	icon_state = "chigusa0"
	walltype = "chigusa"

/turf/closed/wall/r_wall/chigusa/handle_icon_junction(junction)
	if (!walltype)
		return
	//lets make some detailed randomized shit happen.
	var/r1 = rand(0,10) //Make a random chance for this to happen
	var/r2 = rand(0,2) // Which wall if we do choose it
	if(junction == 12)
		switch(r1)
			if(0 to 8)
				icon_state = "[walltype]12"
			if(9 to 10)
				icon_state = "deco_wall[r2]"
	else
		icon_state = "[walltype][junction]"



//Prison

/turf/closed/wall/r_wall/prison
	name = "reinforced metal wall"
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "rwall0"
	walltype = "rwall"

/turf/closed/wall/r_wall/prison_unmeltable
	name = "heavy reinforced wall"
	desc = "A huge chunk of ultra-reinforced metal used to seperate rooms. Looks virtually indestructible."
	icon = 'icons/turf/walls/prison.dmi'
	icon_state = "rwall0"
	walltype = "rwall"
	hull = 1

/turf/closed/wall/r_wall/prison_unmeltable/ex_act(severity) //Should make it indestructable
		return

/turf/closed/wall/r_wall/prison_unmeltable/fire_act(exposed_temperature, exposed_volume)
		return

/turf/closed/wall/r_wall/prison_unmeltable/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return