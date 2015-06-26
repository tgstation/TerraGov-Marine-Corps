
/*
 * effect/alien
 */
/obj/effect/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'icons/Xeno/Effects.dmi'

/*
 * Resin
 */
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"

	density = 1
	opacity = 1
	anchored = 1
	var/health = 200
	//var/mob/living/affecting = null

/obj/effect/alien/resin/wall
	name = "resin wall"
	desc = "Weird slime solidified into a wall."
	icon_state = "ResinWall1" //same as resin, but consistency ho!

/obj/effect/alien/resin/membrane
	name = "resin membrane"
	desc = "Weird slime just translucent enough to let light pass through."
	icon_state = "Resin Membrane"
	opacity = 0
	health = 120

/obj/effect/alien/resin/sticky
	name = "sticky resin"
	desc = "Some disgusting sticky slime. Gross!."
	icon_state = "sticky"
	density = 0
	opacity = 0
	health = 150

/obj/effect/alien/resin/proc/healthcheck()
	if(health <=0)
		density = 0
		del(src)
	return

/obj/effect/alien/resin/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/effect/alien/resin/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/effect/alien/resin/blob_act()
	health-=50
	healthcheck()
	return

/obj/effect/alien/resin/meteorhit()
	health-=50
	healthcheck()
	return

/obj/effect/alien/resin/hitby(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/Xenomorph))
		return
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src] was hit by [AM].</B>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	return

/obj/effect/alien/resin/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(isXenoLarva(M)) return //Larvae can't do shit
	M.visible_message("\red [M] claws at the [name]!", "\blue You claw at the [name].")
	playsound(loc, 'sound/effects/attackblob.ogg', 30, 1)
	health -= rand(M.melee_damage_lower,M.melee_damage_upper)
	healthcheck()
	return

/obj/effect/alien/resin/attack_hand()
	usr << "\blue You scrape ineffectually at the [name]."
	return

/obj/effect/alien/resin/attack_paw()
	return attack_hand()

/obj/effect/alien/resin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	return ..(W,user)

/obj/effect/alien/resin/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density


/*
 * Weeds
 */
#define NODERANGE 3

/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird purple weeds."
	icon_state = "weeds"

	anchored = 1
	density = 0
	layer = 2
	var/health = 15
	var/obj/effect/alien/weeds/node/linked_node = null
	var/on_fire = 0

/obj/effect/alien/weeds/node
	icon_state = "weednode"
	name = "purple sac"
	desc = "Weird purple octopus-like thing."
	layer = 3
	luminosity = NODERANGE
	var/node_range = NODERANGE


/obj/effect/alien/weeds/node/New()
	..(src.loc, src)


/obj/effect/alien/weeds/New(pos, node)
	..()
	if(istype(loc, /turf/space))
		del(src)
		return
	linked_node = node
	if(icon_state == "weeds")icon_state = pick("weeds", "weeds1", "weeds2")
	spawn(rand(150, 200))
		if(src)
			Life()
	return

/obj/effect/alien/weeds/proc/Life()
	set background = 1
	var/turf/U = get_turf(src)

	if (istype(U, /turf/space) || isnull(U))
		del(src)
		return

	if(!linked_node || (get_dist(linked_node, src) > linked_node.node_range) )
		return

	direction_loop:
		for(var/dirn in cardinal)
			var/turf/T = get_step(src, dirn)

			if (!istype(T) || T.density || locate(/obj/effect/alien/weeds) in T || istype(T.loc, /area/arrival) || istype(T, /turf/space))
				continue

	//		if (locate(/obj/movable, T)) // don't propogate into movables
	//			continue
			if(istype(T,/turf/simulated/floor/gm/grass) || istype(T,/turf/simulated/floor/gm/river) || istype(T,/turf/simulated/floor/gm/coast))
				continue

			for(var/obj/O in T)
				if(O.density)
					continue direction_loop

			new /obj/effect/alien/weeds(T, linked_node)


/obj/effect/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				del(src)
		if(3.0)
			if (prob(25))
				del(src)
	return

/obj/effect/alien/weeds/attackby(var/obj/item/weapon/W, var/mob/user)
	if(W.attack_verb.len)
		visible_message("\red <B>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		visible_message("\red <B>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 100, 1)

	health -= damage
	healthcheck()

/obj/effect/alien/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)

/obj/effect/alien/weeds/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alien_fire"

/obj/effect/alien/weeds/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(100,175))
			del(src)

#undef NODERANGE


/*
 * Acid
 */
/obj/effect/alien/acid
	name = "acid"
	desc = "Burbling corrossive stuff. I wouldn't want to touch it."
	icon_state = "acid"

	density = 0
	opacity = 0
	anchored = 1

	var/atom/target
	var/ticks = 0
	var/target_strength = 0

/obj/effect/alien/acid/New(loc, target)
	..(loc)
	src.target = target

	if(isturf(target)) // Turf take twice as long to take down.
		target_strength = 8
	else
		target_strength = 4
	tick()

/obj/effect/alien/acid/proc/tick()
	if(!target)
		del(src)

	ticks += 1

	if(ticks >= target_strength)

		for(var/mob/O in hearers(src, null))
			O.show_message("\green <B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B>", 1)

		if(istype(target, /turf/simulated/wall)) // I hate turf code.
			var/turf/simulated/wall/W = target
			W.dismantle_wall(1)
		else
			if(target.contents) //Hopefully won't auto-delete things inside melted stuff..
				for(var/mob/S in target)
					if(S in target.contents && !isnull(target.loc))
						S.loc = target.loc
			del(target)
		del(src)
		return

	switch(target_strength - ticks)
		if(6)
			visible_message("\green <B>[src.target] is holding up against the acid!</B>")
		if(4)
			visible_message("\green <B>[src.target]\s structure is being melted by the acid!</B>")
		if(2)
			visible_message("\green <B>[src.target] is struggling to withstand the acid!</B>")
		if(0 to 1)
			visible_message("\green <B>[src.target] begins to crumble under the acid!</B>")
	spawn(rand(150, 200)) tick()

/*
 * Egg
 */
/var/const //for the status var
	BURST = 0
	BURSTING = 1
	GROWING = 2
	GROWN = 3

	MIN_GROWTH_TIME = 1800 //time it takes to grow a hugger
	MAX_GROWTH_TIME = 3000

/obj/effect/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "Egg Growing"
	density = 0
	anchored = 1

	var/health = 100
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive
	var/on_fire = 0

/obj/effect/alien/egg/New()
	..()
	spawn(rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))
		Grow()


/obj/effect/alien/egg/attack_alien(user as mob)

	var/mob/living/carbon/M = user
	if(!istype(M) || !istype(M,/mob/living/carbon/Xenomorph) )
		return attack_hand(user)

	switch(status)
		if(BURST)
			user << "\red You clear the hatched egg."
			del(src)
			return
		if(GROWING)
			user << "\red The child is not developed yet."
			return
		if(GROWN)
			user << "\red You retrieve the child."
			Burst(0)
			return

/obj/effect/alien/egg/proc/GetFacehugger()
	return locate(/obj/item/clothing/mask/facehugger) in contents

/obj/effect/alien/egg/proc/Grow()
	icon_state = "Egg"
	status = GROWN
	new /obj/item/clothing/mask/facehugger(src)
	return

/obj/effect/alien/egg/proc/Burst(var/kill = 1) //drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		var/obj/item/clothing/mask/facehugger/child = GetFacehugger()
		icon_state = "Egg Opened"
		flick("Egg Opening", src)
		status = BURSTING
		spawn(15)
			status = BURST
			child.loc = get_turf(src)
			if(kill && istype(child)) //Make sure it's still there
				child.Die()

/obj/effect/alien/egg/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/effect/alien/egg/update_icon()
	overlays.Cut()
	if(on_fire)
		overlays += "alienegg_fire"

/obj/effect/alien/egg/fire_act()
	on_fire = 1
	if(on_fire)
		update_icon()
		spawn(rand(125,200))
			del(src)

/obj/effect/alien/egg/attackby(var/obj/item/weapon/W, var/mob/user)
	if(health <= 0)
		return
	if(W.attack_verb.len)
		src.visible_message("\red <B>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

	src.health -= damage
	src.healthcheck()

/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst()

/obj/effect/alien/egg/HasProximity(atom/movable/AM as mob|obj)
	if(status == GROWN)
		if(!CanHug(AM))
			return
		Burst(0)

/obj/structure/tunnel
	name = "tunnel"
	desc = "A tunnel entrance. Looks like it was dug by some kind of clawed beast."
	icon = 'icons/Xeno/effects.dmi'
	icon_state = "hole"

	density = 0
	opacity = 0
	anchored = 1
	unacidable = 1

	var/health = 140
	var/obj/structure/tunnel/other = null
	var/mob/living/carbon/Xenomorph/builder = null
	var/being_used = 0
	var/id = null //For mapping

	New()
		if(id)
			spawn(5)
				if(other == null)
					for(var/obj/structure/tunnel/T in world)
						if(T.id == id && T != src && T.other == null) //Found a matching tunnel
							T.other = src
							src.other = T //Link them!
							break

/obj/structure/tunnel/proc/healthcheck()
	if(health <= 0)
		visible_message("The [src] suddenly collapses!")
		if(other && isturf(other.loc))
			visible_message("The [other] suddenly collapses!")
			del(other)
		del(src)
	return

/obj/structure/tunnel/bullet_act(var/obj/item/projectile/Proj)
	return

/obj/structure/tunnel/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=200
		if(2.0)
			health-=120
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/structure/tunnel/blob_act()
	health-=50
	healthcheck()
	return

/obj/structure/tunnel/meteorhit()
	health-=50
	healthcheck()
	return

/obj/structure/tunnel/attack_alien(mob/living/carbon/Xenomorph/M as mob)
	if(!istype(M) || M.stat || M.health < 1) return
	var/tunnel_time = 40

	if(M.adjust_pixel_x) //Big xenos take WAY longer
		tunnel_time = 120

	if(istype(M,/mob/living/carbon/Xenomorph/Larva)) //Larva can zip through near-instantly, they are wormlike after all
		tunnel_time = 5

	if(being_used)
		M << "Someone's already climbing down there! Wait your turn!"
		return

	if(!other || !isturf(other.loc))
		M << "The tunnel doesn't seem to lead anywhere."
		return
	if(tunnel_time == 50)
		visible_message("[M] begins crawling down into the tunnel.","You begin crawling down into the tunnel..")
	else
		visible_message("[M] begins heaving their huge bulk down into the tunnel.","You begin heaving your monstrous bulk into the tunnel.")
	being_used = 1
	if(do_after(M,tunnel_time))
		being_used = 0
		if(other && isturf(other.loc)) //Make sure the end tunnel is still there
			M.loc = other.loc
			visible_message("\blue [M] pops out of a tunnel.","\blue You pop out the other side!")
		else
			M << "The tunnel ended unexpectedly, so you return back up."
	else
		M << "Your crawling was interrupted!"
	return

/obj/structure/tunnel/attack_hand()
	usr << "\blue No way are you going down there! 2spooky!"
	return

/obj/structure/tunnel/attack_paw()
	return attack_hand()

