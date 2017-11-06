#define NODERANGE 3

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird black weeds..."
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "base"

	anchored = 1
	density = 0
	layer = TURF_LAYER
	unacidable = 1
	health = 1
	var/on_fire = 0

/obj/effect/alien/weeds/New(pos, obj/effect/alien/weeds/node/node)
	..()
	if(istype(loc, /turf/space))
		cdel(src)
		return

	update_sprite()
	update_neighbours()
	if(node && node.loc && (get_dist(node, src) < node.node_range))
		spawn(rand(150, 200))
			if(loc && node && node.loc)
				weed_expand(node)


/obj/effect/alien/weeds/Dispose()
	var/oldloc = loc
	. = ..()
	update_neighbours(oldloc)



/obj/effect/alien/weeds/Crossed(atom/movable/AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(!has_species(H,"Yautja")) //predators are immune to weed slowdown effect
			H.next_move_slowdown += 1


/obj/effect/alien/weeds/proc/weed_expand(obj/effect/alien/weeds/node/node)
	var/turf/U = get_turf(src)

	if(!istype(U))
		return

	direction_loop:
		for (var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T))
				continue

			if (!T.is_weedable())
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if (W)
				continue

			if(istype(T, /turf/simulated/wall))
				new /obj/effect/alien/weeds/weedwall(T)
				continue

			if (istype(T.loc, /area/arrival))
				continue

			for (var/obj/O in T)
				if(istype(O, /obj/structure/window/framed) || istype(O, /obj/structure/window_frame))
					new /obj/effect/alien/weeds/weedwall/window(T)
					continue direction_loop
				else if(istype(O, /obj/machinery/door) && O.density && (!(O.flags_atom & ON_BORDER) || O.dir != dirn))
					continue direction_loop

			new /obj/effect/alien/weeds(T, node)


/obj/effect/alien/weeds/proc/update_neighbours(turf/U)
	if(!U)
		U = loc
	if(istype(U))
		for (var/dirn in cardinal)
			var/turf/T = get_step(U, dirn)

			if (!istype(T))
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if(W)
				W.update_sprite()


/obj/effect/alien/weeds/proc/update_sprite()
	if(locate(/obj/effect/alien/weeds/node) in loc)
		icon_state = "base"
		return

	var/my_dir = 0
	for (var/check_dir in cardinal)
		var/turf/check = get_step(src, check_dir)

		if (!istype(check))
			continue

		if (locate(/obj/effect/alien/weeds) in check)
			my_dir |= check_dir

	if (my_dir == 15 || my_dir == 0) //weeds in all four directions or in none
		icon_state = "weed[rand(0,15)]"
		return
	else
		icon_state = "weed_dir[my_dir]"


/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			cdel(src)
		if(2.0)
			if(prob(70))
				cdel(src)
		if(3.0)
			if(prob(50))
				cdel(src)

/obj/effect/alien/weeds/attackby(obj/item/W, mob/living/user)
	if(!W || !user || isnull(W) || (W.flags_atom & NOBLUDGEON))
		return 0

	if(istype(src, /obj/effect/alien/weeds/node)) //The pain is real
		user << "<span class='warning'>You hit \the [src] with \the [W].</span>"
	else
		user << "<span class='warning'>You cut \the [src] away with \the [W].</span>"

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)

	else
		playsound(loc, 'sound/effects/attackblob.ogg', 25, 1)
	user.animation_attack_on(src)

	health -= damage
	healthcheck()

/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		cdel(src)

/obj/effect/alien/weeds/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"

/obj/effect/alien/weeds/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(100,175))
			cdel(src)


/obj/effect/alien/weeds/weedwall
	icon_state = "weedwall"

/obj/effect/alien/weeds/weedwall/update_sprite()
	if(istype(loc, /turf/simulated/wall))
		var/turf/simulated/wall/W = loc
		if(W.junctiontype)
			icon_state = "weedwall[W.junctiontype]"



/obj/effect/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/window/update_sprite()
	var/obj/structure/window/framed/F = locate() in loc
	var/obj/structure/window_frame/WF = locate() in loc
	if(F)
		if(F.junction)
			icon_state = "weedwall[F.junction]"
	else if(WF)
		if(WF.junction)
			icon_state = "weedwall[WF.junction]"



/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "A weird, pulsating node."
	layer = RESIN_STRUCTURE_LAYER
	var/node_range = NODERANGE
	var/planter_ckey //ckey of the mob who planted it.
	var/planter_name //nameof the mob who planted it.
	health = 15

/obj/effect/alien/weeds/node/update_sprite()
	return

/obj/effect/alien/weeds/node/update_neighbours()
	return


/obj/effect/alien/weeds/node/New(loc, obj/effect/alien/weeds/node/node, mob/living/carbon/Xenomorph/X)
	..()
	if(X)
		planter_ckey = X.ckey
		planter_name = X.real_name
	new /obj/effect/alien/weeds(loc, src)

/obj/effect/alien/weeds/node/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(loc, 'sound/effects/attackblob.ogg', 25, 1)
	M.visible_message("<span class='xenonotice'>\The [M] clears [src].</span>", \
		"<span class='xenonotice'>You clear [src].</span>")
	cdel(src)




#undef NODERANGE