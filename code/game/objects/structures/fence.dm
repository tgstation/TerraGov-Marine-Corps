/obj/structure/fence
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/smooth_objects/fence.dmi'
	base_icon_state = "fence"
	icon_state = "fence-icon"
	density = TRUE
	anchored = TRUE //We can not be moved.
	coverage = 5
	layer = WINDOW_LAYER
	max_integrity = 150 //Its cheap but still viable to repair, cant be moved around, about 7 runner hits to take down
	resistance_flags = XENO_DAMAGEABLE
	minimap_color = MINIMAP_FENCE
	var/cut = FALSE //Cut fences can be passed through
	coverage = 0 //4 rods doesn't provide any cover
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_FENCE)
	canSmoothWith = list(SMOOTH_GROUP_FENCE)

/obj/structure/fence/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 125), BRUTE, BOMB)//Almost broken or half way
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 75), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(30, BRUTE, BOMB)

/obj/structure/fence/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/rods) && obj_integrity < max_integrity)
		if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_PLASTEEL)
			user.visible_message(span_notice("[user] fumbles around figuring out how to fix [src]'s wiring."),
			span_notice("You fumble around figuring out how to fix [src]'s wiring."))
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_CONSTRUCTION)
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
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

		if(!do_after(user, 30, NONE, src, BUSY_ICON_FRIENDLY))
			return

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		R.use(amount_needed)
		repair_damage(max_integrity, user)
		cut = 0
		density = TRUE
		icon = 'icons/obj/smooth_objects/fence.dmi'
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
				M.apply_damage(7, blocked = MELEE)
				UPDATEHEALTH(M)
				take_damage(10)
			if(GRAB_AGGRESSIVE)
				M.visible_message(span_danger("[user] bashes [M] against \the [src]!"))
				if(prob(50))
					M.Paralyze(2 SECONDS)
				M.apply_damage(10, blocked = MELEE)
				UPDATEHEALTH(M)
				take_damage(25)
			if(GRAB_NECK)
				M.visible_message(span_danger("<big>[user] crushes [M] against \the [src]!</big>"))
				M.Paralyze(10 SECONDS)
				M.apply_damage(20, blocked = MELEE)
				UPDATEHEALTH(M)
				take_damage(50)

	else if(iswirecutter(I))
		user.visible_message(span_notice("[user] starts cutting through [src] with [I]."),
		"<span class='notice'>You start cutting through [src] with [I]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
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
	icon = 'icons/obj/smooth_objects/brokenfence.dmi'

/obj/structure/fence/Initialize(mapload, start_dir)
	. = ..()

	if(prob(80))
		obj_integrity = 0
		deconstruct(FALSE)

	if(start_dir)
		setDir(start_dir)

/obj/structure/fence/Destroy()
	density = FALSE
	icon = 'icons/obj/smooth_objects/brokenfence.dmi'
	return ..()

/obj/structure/fence/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 800)
		take_damage(round(exposed_volume / 100), BURN, "fire")
	return ..()
