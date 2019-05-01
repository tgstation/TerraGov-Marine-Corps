
//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(ACCESS_MARINE_PREP)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	max_integrity = 100
	var/locked = 0.0
//	req_access = list(access_maint_tunnels)

	New()
		..()

		src.icon_state = "barrier[src.locked]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/card/id/))
			if (src.allowed(user))
				if	(src.emagged < 2.0)
					src.locked = !src.locked
					src.anchored = !src.anchored
					src.icon_state = "barrier[src.locked]"
					if ((src.locked == 1.0) && (src.emagged < 2.0))
						to_chat(user, "Barrier lock toggled on.")
						return
					else if ((src.locked == 0.0) && (src.emagged < 2.0))
						to_chat(user, "Barrier lock toggled off.")
						return
				else
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(2, 1, src)
					s.start()
					visible_message("<span class='warning'> BZZzZZzZZzZT</span>")
					return
			return
		else if (istype(W, /obj/item/card/emag))
			if (src.emagged == 0)
				src.emagged = 1
				src.req_access = null
				to_chat(user, "You break the ID authentication lock on \the [src].")
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("<span class='warning'> BZZzZZzZZzZT</span>")
				return
			else if (src.emagged == 1)
				src.emagged = 2
				to_chat(user, "You short out the anchoring mechanism on \the [src].")
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("<span class='warning'> BZZzZZzZZzZT</span>")
				return
		else if (iswrench(W))
			if (src.obj_integrity < max_integrity)
				src.obj_integrity = max_integrity
				src.emagged = 0
				src.req_access = list(ACCESS_MARINE_PREP)
				visible_message("<span class='warning'> [user] repairs \the [src]!</span>")
				return
			else if (src.emagged > 0)
				src.emagged = 0
				src.req_access = list(ACCESS_MARINE_PREP)
				visible_message("<span class='warning'> [user] repairs \the [src]!</span>")
				return
			return
		else
			switch(W.damtype)
				if("fire")
					src.obj_integrity -= W.force * 0.75
				if("brute")
					src.obj_integrity -= W.force * 0.5
				else
			if (src.obj_integrity <= 0)
				src.explode()
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.explode()
				return
			if(2.0)
				src.obj_integrity -= 25
				if (src.obj_integrity <= 0)
					src.explode()
				return
	emp_act(severity)
		if(machine_stat & (BROKEN|NOPOWER))
			return
		if(prob(50/severity))
			locked = !locked
			anchored = !anchored
			icon_state = "barrier[src.locked]"

	CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)//So bullets will fly over and stuff.
		if(air_group || (height == 0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

	proc/explode()

		visible_message("<span class='danger'>[src] blows apart!</span>")
		var/turf/Tsec = get_turf(src)

	/*	var/obj/item/stack/rods/ =*/
		new /obj/item/stack/rods(Tsec)

		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		explosion(src.loc,-1,-1,0)
		if(src)
			qdel(src)
