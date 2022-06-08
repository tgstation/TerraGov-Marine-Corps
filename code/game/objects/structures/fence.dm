/obj/structure/fence
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/structures/fence.dmi'
	icon_state = "fence0"
	density = TRUE
	throwpass = TRUE //So people and xenos can shoot through!
	anchored = TRUE //We can not be moved.
	coverage = 5
	layer = WINDOW_LAYER
	max_integrity = 150 //Its cheap but still viable to repair, cant be moved around, about 7 runner hits to take down
	resistance_flags = XENO_DAMAGEABLE
	minimap_color = MINIMAP_FENCE
	var/cut = FALSE //Cut fences can be passed through
	var/junction = 0 //Because everything is terrible, I'm making this a fence-level var
	var/basestate = "fence"
	coverage = 0 //Were like 4 rods
	//We dont have armor do to being a bit more healthy!

/obj/structure/fence/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 125))//Almost broken or half way
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 75))

/obj/structure/fence/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/rods) && obj_integrity < max_integrity)
		if(user.skills.getRating("construction") < SKILL_CONSTRUCTION_PLASTEEL)
			user.visible_message(span_notice("[user] fumbles around figuring out how to fix [src]'s wiring."),
			span_notice("You fumble around figuring out how to fix [src]'s wiring."))
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("construction")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

		var/obj/item/stack/rods/R = I
		var/amount_needed = 4
		if(obj_integrity)
			amount_needed = 4

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		user.visible_message(span_notice("[user] starts repairing [src] with [R]."),
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
		user.visible_message(span_notice("[user] repairs [src] with [R]."),
		"<span class='notice'>You repair [src] with [R]")

	else if(cut) //Cut/brokn grilles can't be messed with further than this
		return

	else if(istype(I, /obj/item/grab) && get_dist(src, user) < 2)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		var/state = user.grab_state
		user.drop_held_item()
		switch(state)
			if(GRAB_PASSIVE)
				M.visible_message(span_warning("[user] slams [M] against \the [src]!"))
				M.apply_damage(7)
				UPDATEHEALTH(M)
				take_damage(10)
			if(GRAB_AGGRESSIVE)
				M.visible_message(span_danger("[user] bashes [M] against \the [src]!"))
				if(prob(50))
					M.Paralyze(20)
				M.apply_damage(10)
				UPDATEHEALTH(M)
				take_damage(25)
			if(GRAB_NECK)
				M.visible_message(span_danger("<big>[user] crushes [M] against \the [src]!</big>"))
				M.Paralyze(10 SECONDS)
				M.apply_damage(20)
				UPDATEHEALTH(M)
				take_damage(50)

	else if(iswirecutter(I))
		user.visible_message(span_notice("[user] starts cutting through [src] with [I]."),
		"<span class='notice'>You start cutting through [src] with [I]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message(span_notice("[user] cuts through [src] with [I]."),
		"<span class='notice'>You cut through [src] with [I]")
		deconstruct(TRUE)


/obj/structure/fence/deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(FALSE)
	if(disassembled)
		new /obj/item/stack/rods(loc)
	cut = TRUE
	density = FALSE
	update_icon() //Make it appear cut through!


/obj/structure/fence/Initialize(mapload, start_dir)
	. = ..()

	if(prob(80))
		obj_integrity = 0
		deconstruct(FALSE)

	if(start_dir)
		setDir(start_dir)

	update_nearby_icons()

/obj/structure/fence/Destroy()
	density = FALSE
	update_nearby_icons()
	return ..()

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
