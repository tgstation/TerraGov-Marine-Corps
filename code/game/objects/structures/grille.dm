/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags_atom = CONDUCT
	layer = OBJ_LAYER
	explosion_resistance = 5
	var/health = 10
	var/destroyed = FALSE


/obj/structure/grille/fence/
	var/width = 3
	health = 50

/obj/structure/grille/fence/New()

	..()

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

/obj/structure/grille/fence/healthcheck()
	if(health <= 0)
		density = FALSE
		destroyed = TRUE
		new /obj/item/stack/rods(loc)
		cdel(src)
	return

/obj/structure/grille/ex_act(severity)
	cdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user)) shock(user, 70)


/obj/structure/grille/attack_paw(mob/user as mob)
	attack_hand(user)

/obj/structure/grille/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)
	var/damage_dealt = 5
	M.visible_message("<span class='danger'>\The [M] mangles [src]!</span>", \
	"<span class='danger'>You mangle [src]!</span>", \
	"<span class='danger'>You hear twisting metal!</span>", 5)

	if(shock(M, 70))
		M.visible_message("<span class='danger'>ZAP! \The [M] spazzes wildly amongst a smell of burnt ozone.</span>", \
		"<span class='danger'>ZAP! You twitch and dance like a monkey on hyperzine!</span>", \
		"<span class='danger'>You hear a sharp ZAP and a smell of ozone.</span>")
		return FALSE //Intended apparently ?

	health -= damage_dealt
	healthcheck()

/obj/structure/grille/attack_hand(mob/user as mob)

	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)

	var/damage_dealt
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			damage_dealt = 5
			user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
					 "<span class='warning'>You mangle [src].</span>", \
					 "You hear twisting metal.")

	if(!damage_dealt)
		user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
						 "<span class='warning'>You kick [src].</span>", \
						 "You hear twisting metal.")

	if(shock(user, 70))
		return

	if(HULK in user.mutations)
		damage_dealt += 5
	else
		damage_dealt += 1

	health -= damage_dealt
	healthcheck()


/obj/structure/grille/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		return

	playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='warning'>You smash against [src].</span>", \
					  "You hear twisting metal.")

	health -= M.melee_damage_upper
	healthcheck()
	return


/obj/structure/grille/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return TRUE
	else
		if(istype(mover, /obj/item/projectile))
			return prob(90)
		else
			return !density

/obj/structure/grille/bullet_act(var/obj/item/projectile/Proj)

	//Tasers and the like should not damage grilles.
	if(Proj.ammo.damage_type == HALLOSS)
		return FALSE

	src.health -= round(Proj.damage*0.3)
	healthcheck()
	return TRUE

/obj/structure/grille/attackby(obj/item/W as obj, mob/user as mob)
	if(iswirecutter(W))
		if(!shock(user, 100))
			playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
			new /obj/item/stack/rods(loc, 2)
			cdel(src)
	else if(isscrewdriver(W) && istype(loc, /turf/open))
		if(!shock(user, 90))
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] the grille.</span>", \
								 "<span class='notice'>You have [anchored ? "fastened the grille to" : "unfastened the grill from"] the floor.</span>")
			return

//window placing begin
	else if(istype(W,/obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/ST = W
		var/dir_to_set = 1
		if(loc == user.loc)
			dir_to_set = user.dir
		else
			if( ( x == user.x ) || (y == user.y) ) //Only supposed to work for cardinal directions.
				if( x == user.x )
					if( y > user.y )
						dir_to_set = 2
					else
						dir_to_set = 1
				else if( y == user.y )
					if( x > user.x )
						dir_to_set = 8
					else
						dir_to_set = 4
			else
				to_chat(user, "<span class='notice'>You can't reach.</span>")
				return //Only works for cardinal direcitons, diagonals aren't supposed to work like this.
		for(var/obj/structure/window/WINDOW in loc)
			if(WINDOW.dir == dir_to_set)
				to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
				return
		to_chat(user, "<span class='notice'>You start placing the window.</span>")
		if(do_after(user,20, TRUE, 5, BUSY_ICON_BUILD))
			for(var/obj/structure/window/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
					to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
					return

			var/wtype = ST.created_window
			if (ST.use(1))
				var/obj/structure/window/WD = new wtype(loc, dir_to_set, 1)
				to_chat(user, "<span class='notice'>You place the [WD] on [src].</span>")
				WD.update_icon()
		return
//window placing end

	else if(istype(W, /obj/item/shard))
		health -= W.force * 0.1
	else if(!shock(user, 70))
		playsound(loc, 'sound/effects/grillehit.ogg', 25, 1)
		switch(W.damtype)
			if("fire")
				health -= W.force
			if("brute")
				health -= W.force * 0.1
	healthcheck()
	..()
	return


/obj/structure/grille/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			icon_state = "brokengrille"
			density = 0
			destroyed = 1
			new /obj/item/stack/rods(loc)

		else
			if(health <= -6)
				new /obj/item/stack/rods(loc)
				cdel(src)
				return
	return

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
	if(!destroyed)
		if(exposed_temperature > T0C + 1500)
			health -= 1
			healthcheck()
	..()



//ALMAYER GRILLE

/obj/structure/grille/almayer
	icon = 'icons/turf/almayer.dmi'
	icon_state = "grille0"
	tiles_with = list(
		/turf/closed/wall,
		/obj/machinery/door/airlock,
		/obj/structure/grille/almayer)

/obj/structure/grille/almayer/New()
	spawn(0)
		relativewall()
		relativewall_neighbours()

/obj/structure/grille/almayer/update_icon()
	relativewall()
