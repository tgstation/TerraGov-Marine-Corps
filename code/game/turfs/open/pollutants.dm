/obj/effect/pollutant_effect
	name = ""
	desc = ""
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	mouse_opacity = 0
	nomouseover = TRUE
	layer = AREA_LAYER-1
	plane = GAME_PLANE_UPPER
	anchored = TRUE
	pixel_x = -32
	pixel_y = -32
	alpha = 0
	var/list/pollute_list = list()
	var/last_process = 0

/obj/effect/pollutant_effect/Initialize()
	. = ..()
	dir = pick(GLOB.cardinals)
	START_PROCESSING(SSrogpollutants, src)

/obj/effect/pollutant_effect/Destroy()
	STOP_PROCESSING(SSrogpollutants, src)
	for(var/X in pollute_list)
		qdel(X)
		pollute_list -= X
	if(isopenturf(loc))
		var/turf/open/T = loc
		if(T.pollutants == src)
			T.pollutants = null
	. = ..()

/obj/effect/pollutant_effect/process()
	var/amt2take = 2
	if(last_process)
		amt2take = ((world.time - last_process)/10) * amt2take
	last_process = world.time
	if(!pollute_list.len)
		qdel(src)
	if(isopenturf(loc))
		var/turf/open/T = loc
		if(!QDELETED(T))
			if(!T.pollutants)
				T.pollutants = src
			else
				if(T.pollutants != src)
					qdel(src)
	else
		qdel(src)
	var/combo_color
	var/total_amt = 0
	for(var/datum/pollutant/P in pollute_list)
		if(P.amt > 100)
			P.amt = 100
		P.amt -= amt2take
		if(P.amt <= 0)
			pollute_list -= P
			qdel(P)
		else
			total_amt = min(total_amt + P.amt, 100)
			if(!combo_color)
				combo_color = P.color
			else
				combo_color = BlendRGB(combo_color, P.color)
	if(total_amt <= 0)
		qdel(src)
	//update the appearance of this
	alpha = CLAMP((total_amt/100 * 88), 33, 88)
	color = combo_color


/turf
	var/obj/effect/pollutant_effect/pollutants

/turf/proc/add_pollutants(type, amt=1, spread = TRUE)
	if(pollutants)
		var/found = FALSE
		for(var/datum/pollutant/X in pollutants.pollute_list)
			if(istype(X, type))
				if(X.amt + amt > 100)
					if(spread)
						spread_pollutants(type,amt)
				X.amt = min(X.amt + amt,100)
				found = TRUE
		if(!found)
			var/datum/pollutant/P = new type(pollutants)
			P.amt = amt
			pollutants.pollute_list += P
	else
		pollutants = new /obj/effect/pollutant_effect(src)
		var/datum/pollutant/P = new type(pollutants)
		P.amt = amt
		pollutants.pollute_list += P

/turf/proc/spread_pollutants(type, amt=1)
	for(var/D in GLOB.cardinals)
		var/turf/T = get_step(src, D)
		if(isopenturf(T))
			T.add_pollutants(type, amt, FALSE)

/datum/pollutant
	var/reagents_on_breathe = list() //list(/datum/reagent/water = 3)
	var/color = "#ffffff"
	var/amt = 0

/datum/pollutant/rot
	color = "#76b418"
	reagents_on_breathe = list(/datum/reagent/miasmagas = 1)

/datum/pollutant/steam
	color = "#ffffff"