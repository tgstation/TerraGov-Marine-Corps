//generic procs copied from obj/effect/alien
/obj/effect/spider
	name = "web"
	desc = "it's stringy and sticky"
	icon = 'icons/effects/effects.dmi'
	anchored = 1
	density = 0
	max_integrity = 15

//similar to weeds, but only barfed out by nurses manually
/obj/effect/spider/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(5))
				qdel(src)
	return

/obj/effect/spider/attackby(var/obj/item/W, var/mob/user)
	if(W.attack_verb.len)
		visible_message("<span class='danger'>\The [src] have been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]</span>")
	else
		visible_message("<span class='danger'>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]</span>")

	var/damage = W.force / 4.0

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)

	obj_integrity -= damage
	healthcheck()

/obj/effect/spider/bullet_act(var/obj/item/projectile/Proj)
	..()
	obj_integrity -= Proj.ammo.damage
	healthcheck()
	return 1

/obj/effect/spider/proc/healthcheck()
	if(obj_integrity <= 0)
		qdel(src)

/obj/effect/spider/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		obj_integrity -= 5
		healthcheck()

/obj/effect/spider/stickyweb
	icon_state = "stickyweb1"
	New()
		if(prob(50))
			icon_state = "stickyweb2"

/obj/effect/spider/stickyweb/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return 1
	else if(isliving(mover))
		if(prob(50))
			to_chat(mover, "<span class='warning'>You get stuck in [src] for a moment.</span>")
			return 0
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return 1

/obj/effect/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life"
	icon_state = "eggs"
	var/amount_grown = 0
	New()
		pixel_x = rand(3,-3)
		pixel_y = rand(3,-3)
		START_PROCESSING(SSobj, src)

/obj/effect/spider/eggcluster/process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = rand(6,24)
		for(var/i=0, i<num, i++)
			new /obj/effect/spider/spiderling(src.loc)
		qdel(src)

/obj/effect/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = 0
	layer = BELOW_TABLE_LAYER
	max_integrity = 3
	var/amount_grown = -1
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	New()
		pixel_x = rand(6,-6)
		pixel_y = rand(6,-6)
		START_PROCESSING(SSobj, src)
		//50% chance to grow up
		if(prob(50))
			amount_grown = 1

/obj/effect/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		src.loc = user.loc
	else
		..()

/obj/effect/spider/spiderling/proc/die()
	visible_message("<span class='alert'>[src] dies!</span>")
	new /obj/effect/decal/cleanable/spiderling_remains(src.loc)
	qdel(src)

/obj/effect/spider/spiderling/healthcheck()
	if(obj_integrity <= 0)
		die()

/obj/effect/spider/spiderling/process()
	if(travelling_in_vent)
		if(istype(src.loc, /turf))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			if(entry_vent.parents?.members.len)
				var/list/vents = list()
				for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent.parents.members)
					vents.Add(temp_vent)
				if(!vents.len)
					entry_vent = null
					return
				var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
				/*if(prob(50))
					src.visible_message("<B>[src] scrambles into the ventillation ducts!</B>")*/

				spawn(rand(20,60))
					loc = exit_vent
					var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
					spawn(travel_time)

						if(!exit_vent || exit_vent.welded)
							loc = entry_vent
							entry_vent = null
							return

						if(prob(50))
							src.visible_message("<span class='notice'> You hear something squeezing through the ventilation ducts.</span>",2)
						sleep(travel_time)

						if(!exit_vent || exit_vent.welded)
							loc = entry_vent
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
			else
				entry_vent = null
	//=================

	else if(prob(25))
		var/list/nearby = oview(5, src)
		if(nearby.len)
			var/target_atom = pick(nearby)
			walk_to(src, target_atom, 5)
			if(prob(25))
				src.visible_message("<span class='notice'> \the [src] skitters[pick(" away"," around","")].</span>")
	else if(prob(5))
		//vent crawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				walk_to(src, entry_vent, 5)
				break

	if(prob(1))
		src.visible_message("<span class='notice'> \the [src] chitters.</span>")
	if(isturf(loc) && amount_grown > 0)
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			var/spawn_type = pick(typesof(/mob/living/simple_animal/hostile/giant_spider))
			new spawn_type(src.loc)
			qdel(src)

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"

/obj/effect/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web"
	icon_state = "cocoon1"
	max_integrity = 60

	New()
		icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/effect/spider/cocoon/Destroy()
	visible_message("<span class='warning'> [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	. = ..()
