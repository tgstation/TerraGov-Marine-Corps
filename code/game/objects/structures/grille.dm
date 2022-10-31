/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures/grille.dmi'
	icon_state = "grille"
	hit_sound = 'sound/effects/grillehit.ogg'
	density = TRUE
	anchored = TRUE
	coverage = 10
	flags_atom = CONDUCT
	layer = OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 100, BOMB = 10, BIO = 100, FIRE = 0, ACID = 0)
	max_integrity = 10

/obj/structure/grille/Initialize()
	. = ..()
	AddElement(/datum/element/egrill)

/obj/structure/grille/broken
	icon_state = "brokengrille"
	obj_integrity = 0
	density = FALSE

/obj/structure/grille/fence
	var/width = 3
	max_integrity = 50

/obj/structure/grille/fence/Initialize()
	. = ..()

	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size


/obj/structure/grille/fence/east_west
	//width=80
	//height=42
	icon='icons/obj/structures/fence_ew.dmi'
	icon_state = "fence-ew"
	dir = 4

/obj/structure/grille/fence/north_south
	//width=80
	//height=42
	icon='icons/obj/structures/fence_ns.dmi'
	icon_state = "fence-ns"


/obj/structure/grille/ex_act(severity)
	qdel(src)

/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)

	user.visible_message(span_warning("[user] kicks [src]."), \
						span_warning("You kick [src]."), \
						"You hear twisting metal.")

/obj/structure/grille/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGRILLE))
		return TRUE
	else if(istype(mover, /obj/projectile))
		return prob(90)

/obj/structure/grille/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswirecutter(I))
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		new /obj/item/stack/rods(loc, 2)
		qdel(src)

	else if(isscrewdriver(I) && isopenturf(loc))
		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		anchored = !anchored
		user.visible_message(span_notice("[user] [anchored ? "fastens" : "unfastens"] the grille."), \
							span_notice("You have [anchored ? "fastened the grille to" : "unfastened the grill from"] the floor."))

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/ST = I
		var/dir_to_set = NORTH

		if(loc == user.loc)
			dir_to_set = user.dir

		else
			if(x != user.x  && y != user.y) //Only supposed to work for cardinal directions.
				to_chat(user, span_notice("You can't reach."))
				return

			else if(x == user.x)
				if(y > user.y)
					dir_to_set = SOUTH
				else
					dir_to_set = NORTH
			else if(y == user.y)
				if(x > user.x)
					dir_to_set = EAST
				else
					dir_to_set = WEST


		for(var/obj/structure/window/W in loc)
			if(W.dir == dir_to_set)
				to_chat(user, span_notice("There is already a window facing this way there."))
				return

		to_chat(user, span_notice("You start placing the window."))

		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		for(var/obj/structure/window/W in loc)
			if(W.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
				to_chat(user, span_notice("There is already a window facing this way there."))
				return

		var/wtype = ST.created_window
		if(!ST.use(1))
			return

		var/obj/structure/window/WD = new wtype(loc, dir_to_set, 1)
		to_chat(user, span_notice("You place the [WD] on [src]."))
		WD.update_icon()

/obj/structure/grille/fire_act(exposed_temperature, exposed_volume)
	if(obj_integrity > integrity_failure && exposed_temperature > T0C + 1500)
		take_damage(1, BURN, "fire")
	return ..()



//MARINE SHIP GRILLE

/obj/structure/grille/smoothing
	icon = 'icons/turf/mainship.dmi'
	icon_state = "grille0"
	smoothing_behavior = DIAGONAL_SMOOTHING
	smoothing_groups = SMOOTH_GENERAL_STRUCTURES

/obj/structure/grille/smoothing/update_icon()
	smooth_self()
	smooth_neighbors()
