/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "grille"
	hit_sound = 'sound/effects/grillehit.ogg'
	density = TRUE
	anchored = TRUE
	flags_atom = CONDUCT
	layer = OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	max_integrity = 10
	var/destroyed = FALSE

/obj/structure/grille/broken
	icon_state = "brokengrille"
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

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)


/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)

	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
						"<span class='warning'>You kick [src].</span>", \
						"You hear twisting metal.")

	shock(user, 70)


/obj/structure/grille/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGRILLE))
		return TRUE
	else
		if(istype(mover, /obj/item/projectile))
			return prob(90)
		else
			return !density


/obj/structure/grille/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswirecutter(I))
		if(shock(user, 100))
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		new /obj/item/stack/rods(loc, 2)
		qdel(src)

	else if(isscrewdriver(I) && isopenturf(loc))
		if(shock(user, 90))
			return

		playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
		anchored = !anchored
		user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille.</span>", \
							"<span class='notice'>You have [anchored ? "fastened the grille to" : "unfastened the grill from"] the floor.</span>")


	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/ST = I
		var/dir_to_set = NORTH

		if(loc == user.loc)
			dir_to_set = user.dir

		else
			if(x != user.x  && y != user.y) //Only supposed to work for cardinal directions.
				to_chat(user, "<span class='notice'>You can't reach.</span>")
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
				to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
				return

		to_chat(user, "<span class='notice'>You start placing the window.</span>")

		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		for(var/obj/structure/window/W in loc)
			if(W.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
				to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
				return

		var/wtype = ST.created_window
		if(!ST.use(1))
			return
			
		var/obj/structure/window/WD = new wtype(loc, dir_to_set, 1)
		to_chat(user, "<span class='notice'>You place the [WD] on [src].</span>")
		WD.update_icon()


// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
/obj/structure/grille/proc/shock(mob/user as mob, prb)

	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return TRUE
		else
			return FALSE
	return FALSE

/obj/structure/grille/fire_act(exposed_temperature, exposed_volume)
	if(!destroyed && exposed_temperature > T0C + 1500)
		take_damage(1, BURN, "fire")
	return ..()



//MARINE SHIP GRILLE

/obj/structure/grille/mainship
	icon = 'icons/turf/mainship.dmi'
	icon_state = "grille0"
	tiles_with = list(
		/turf/closed/wall,
		/obj/machinery/door/airlock,
		/obj/structure/grille/mainship)

/obj/structure/grille/mainship/Initialize()
	. = ..()
	relativewall()
	relativewall_neighbours()

/obj/structure/grille/mainship/update_icon()
	relativewall()
