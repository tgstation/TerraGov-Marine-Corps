
//########################## CONTRABAND ;3333333333333333333 -Agouri ###################################################

/obj/item/contraband
	name = "contraband item"
	desc = "You probably shouldn't be holding this."
	icon = 'icons/obj/contraband.dmi'
	force = 0


/obj/item/contraband/poster
	name = "rolled-up poster"
	desc = "The poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface."
	icon_state = "rolled_poster"
	var/serial_number = 0


/obj/item/contraband/poster/Initialize(mapload, given_serial)
	. = ..()
	if(!given_serial)
		serial_number = rand(1, length(GLOB.poster_designs))
	else
		serial_number = given_serial
	name += " - No. [serial_number]"

//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "A large piece of space-resistant printed paper. "
	icon = 'icons/obj/contraband.dmi'
	icon_state = "poster_map"
	anchored = TRUE
	var/serial_number	//Will hold the value of src.loc if nobody initialises it
	var/ruined = 0

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = 30
		if(SOUTH)
			pixel_y = -30
		if(EAST)
			pixel_x = 30
		if(WEST)
			pixel_x = -30

obj/structure/sign/poster/New(var/serial)

	serial_number = serial

	if(serial_number == loc)
		serial_number = rand(1, length(GLOB.poster_designs))	//This is for the mappers that want individual posters without having to use rolled posters.

	var/designtype = GLOB.poster_designs[serial_number]
	var/datum/poster/design=new designtype
	name += " - [design.name]"
	desc += " [design.desc]"
	icon_state = design.icon_state // poster[serial_number]
	..()

/obj/structure/sign/poster/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iswirecutter(I))
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		if(ruined)
			to_chat(user, span_notice("You remove the remnants of the poster."))
			qdel(src)
		else
			to_chat(user, span_notice("You carefully remove the poster from the wall."))
			roll_and_drop(user.loc)


/obj/structure/sign/poster/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(ruined)
		return
	var/temp_loc = user.loc
	switch(tgui_alert(user, "Do I want to rip the poster from the wall?", "You think...", list("Yes","No")))
		if("Yes")
			if(user.loc != temp_loc)
				return
			visible_message(span_warning("[user] rips [src] in a single, decisive motion!") )
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 25, 1)
			ruined = 1
			icon_state = "poster_ripped"
			name = "ripped poster"
			desc = "You can't make out anything from the poster's original print. It's ruined."
		if("No")
			return

/obj/structure/sign/poster/proc/roll_and_drop(turf/newloc)
	var/obj/item/contraband/poster/P = new(src, serial_number)
	P.loc = newloc
	src.loc = P
	qdel(src)


//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/wall/proc/place_poster(obj/item/contraband/poster/P, mob/user)

	if(!istype(src,/turf/closed/wall))
		to_chat(user, span_warning("You can't place this here!"))
		return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O,/obj/structure/sign/poster))
			to_chat(user, span_notice("The wall is far too cluttered to place a poster!"))
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			to_chat(user, span_notice("The wall is far too cluttered to place a poster!"))
			return

	to_chat(user, span_notice("You start placing the poster on the wall..."))

	//declaring D because otherwise if P gets 'deconstructed' we lose our reference to P.resulting_poster
	var/obj/structure/sign/poster/D = new(P.serial_number)

	var/temp_loc = user.loc
	flick("poster_being_set",D)
	D.loc = src
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 25, 1)

	sleep(17)
	if(!D)	return

	if(istype(src,/turf/closed/wall) && user && user.loc == temp_loc)//Let's check if everything is still there
		to_chat(user, span_notice("You place the poster!"))
	else
		D.roll_and_drop(temp_loc)

/datum/poster
	// Name suffix. Poster - [name]
	var/name=""
	// Description suffix
	var/desc=""
	var/icon_state=""
