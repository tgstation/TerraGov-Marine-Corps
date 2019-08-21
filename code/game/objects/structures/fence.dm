/obj/structure/fence
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/structures/fence.dmi'
	icon_state = "fence0"
	density = TRUE
	anchored = TRUE
	layer = WINDOW_LAYER
	max_integrity = 100
	resistance_flags = XENO_DAMAGEABLE
	var/cut = FALSE //Cut fences can be passed through
	var/junction = 0 //Because everything is terrible, I'm making this a fence-level var
	var/basestate = "fence"


/obj/structure/fence/ex_act(severity)
	switch(severity)
		if(1)
			deconstruct(FALSE)
		if(2)
			deconstruct(FALSE)
		if(3)
			take_damage(rand(25, 55))


/obj/structure/fence/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/rods) && obj_integrity < max_integrity)
		if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_PLASTEEL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to fix [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out how to fix [src]'s wiring.</span>")
			var/fumbling_time = 100 - 20 * user.mind.cm_skills.construction
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

		var/obj/item/stack/rods/R = I
		var/amount_needed = 2
		if(obj_integrity)
			amount_needed = 1

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		user.visible_message("<span class='notice'>[user] starts repairing [src] with [R].</span>",
		"<span class='notice'>You start repairing [src] with [R]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_FRIENDLY))
			return

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		R.use(amount_needed)
		repair_damage(max_integrity)
		cut = 0
		density = TRUE
		update_icon()
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] repairs [src] with [R].</span>",
		"<span class='notice'>You repair [src] with [R]")

	else if(cut) //Cut/brokn grilles can't be messed with further than this
		return

	else if(istype(I, /obj/item/grab) && get_dist(src, user) < 2)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		var/state = user.grab_level
		user.drop_held_item()
		switch(state)
			if(GRAB_PASSIVE)
				M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
				M.apply_damage(7)
				take_damage(10)
			if(GRAB_AGGRESSIVE)
				M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
				if(prob(50))
					M.knock_down(1)
				M.apply_damage(10)
				take_damage(25)
			if(GRAB_NECK)
				M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
				M.knock_down(5)
				M.apply_damage(20)
				take_damage(50)

	else if(iswirecutter(I))
		user.visible_message("<span class='notice'>[user] starts cutting through [src] with [I].</span>",
		"<span class='notice'>You start cutting through [src] with [I]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] cuts through [src] with [I].</span>",
		"<span class='notice'>You cut through [src] with [I]")
		deconstruct(TRUE)


/obj/structure/fence/deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/stack/rods(loc)
	cut = TRUE
	density = FALSE
	update_icon() //Make it appear cut through!


/obj/structure/fence/Initialize(mapload, start_dir)
	. = ..()
	
	if(start_dir)
		setDir(start_dir)

	update_nearby_icons()

/obj/structure/fence/Destroy()
	density = FALSE
	update_nearby_icons()
	. = ..()

/obj/structure/fence/Move()
	var/ini_dir = dir
	..()
	setDir(ini_dir)

//This proc is used to update the icons of nearby windows.
/obj/structure/fence/proc/update_nearby_icons()
	update_icon()
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/fence/W in get_step(src, direction))
			W.update_icon()

//merges adjacent full-tile windows into one (blatant ripoff from game/smoothwall.dm)
/obj/structure/fence/update_icon()
	//A little cludge here, since I don't know how it will work with slim windows. Most likely VERY wrong.
	//this way it will only update full-tile ones
	//This spawn is here so windows get properly updated when one gets deleted.
	spawn(2)
		if(!src)
			return
		for(var/obj/structure/fence/W in orange(src, 1))
			if(abs(x - W.x) - abs(y - W.y)) //Doesn't count grilles, placed diagonally to src
				junction |= get_dir(src, W)
		if(cut)
			icon_state = "broken[basestate][junction]"
		else
			icon_state = "[basestate][junction]"

/obj/structure/fence/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, "fire")
	return ..()
