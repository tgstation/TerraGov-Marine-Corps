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
	var/obj/effect/alien/weeds/node/linked_node = null
	var/on_fire = 0

	New(pos, node)
		..()
		if(istype(loc, /turf/space))
			cdel(src)
			return

		linked_node = node
		if(!linked_node || !linked_node.loc || (get_dist(linked_node, src) > linked_node.node_range))
			linked_node = null
			cdel(src)
			return

		spawn(rand(150, 200))
			if(src)
				Life()

	Crossed(atom/movable/AM)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(!has_species(H,"Yautja")) //predators are immune to weed slowdown effect
				H.next_move_slowdown += 1

/obj/effect/alien/weeds/proc/Life()
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space) || isnull(U))
		cdel(src)
		return

	var/list/weeds_to_update = list(src)

	direction_loop:
		for (var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T))
				continue

			if (T.density)
				//TODO: Wall/Window check and overlay apply.
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if (W)
				weeds_to_update |= W
				continue

			if (istype(T.loc, /area/arrival))
				continue

			if (!T.is_weedable())
				continue

			for (var/obj/O in T)
				if (O.density)
					continue direction_loop

			for (var/check_dir in cardinal)
				var/turf/check = get_step(T, check_dir)

				if (!istype(check))
					continue

				var/obj/effect/alien/weeds/Y = locate() in check
				if (Y)
					weeds_to_update |= Y

			var/obj/effect/alien/weeds/NW = new /obj/effect/alien/weeds(T, linked_node)
			weeds_to_update |= NW

	for (var/W in weeds_to_update)
		var/obj/effect/alien/weeds/Z = W
		Z.update_sprite()

/obj/effect/alien/weeds/proc/update_sprite()
	if (linked_node && loc == linked_node.loc)
		return

	var/my_dir = 0
	for (var/check_dir in cardinal)
		var/turf/check = get_step(src, check_dir)

		if (!istype(check))
			continue

		if (locate(/obj/effect/alien/weeds) in check)
			my_dir |= check_dir

	if (my_dir == 15)
		icon_state = "weed[rand(0,15)]"
		return

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

/obj/effect/alien/weeds/attackby(obj/item/W as obj, mob/user as mob)
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

/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "A weird, pulsating node."
	layer = RESIN_STRUCTURE_LAYER
	var/node_range = NODERANGE
	var/planter_ckey //ckey of the mob who planted it.
	var/planter_name //nameof the mob who planted it.
	health = 15

/obj/effect/alien/weeds/node/New(loc, mob/living/carbon/Xenomorph/X)
	..(loc, src)
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