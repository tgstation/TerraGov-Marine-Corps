


/obj/vehicle/powerloader
	name = "\improper Power Loader"
	icon = 'icons/obj/powerloader.dmi'
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world."
	icon_state = "powerloader_open"
	layer = OBJ_LAYER
	anchored = 1
	density = 1
	move_delay = 6
	buckling_y = 9
	health = 200
	maxhealth = 200
	req_one_access = list(ACCESS_CIVILIAN_ENGINEERING,ACCESS_CIVILIAN_LOGISTICS,ACCESS_MARINE_CARGO,ACCESS_MARINE_PILOT,ACCESS_MARINE_BRIG)
	pixel_x = -16
	pixel_y = -2

	New()
		..()
		cell = new /obj/item/weapon/cell/apc
		for(var/i=1, i<=2, i++)
			var/obj/item/weapon/powerloader_clamp/PC = new(src)
			PC.linked_powerloader = src

	relaymove(mob/user, direction)
		if(user.is_mob_incapacitated()) return
		if(world.time > l_move_time + move_delay)
			if(dir != direction)
				l_move_time = world.time
				dir = direction
				handle_rotation()
				pick(playsound(src.loc, 'sound/mecha/powerloader_turn.ogg', 25, 1), playsound(src.loc, 'sound/mecha/powerloader_turn2.ogg', 25, 1))
				. = TRUE
			else
				. = step(src, direction)
				if(.)
					pick(playsound(loc, 'sound/mecha/powerloader_step.ogg', 25), playsound(loc, 'sound/mecha/powerloader_step2.ogg', 25))


	attack_hand(mob/user)
		if(buckled_mob && user != buckled_mob)
			buckled_mob.visible_message("<span class='warning'>[user] tries to move [buckled_mob] out of [src].</span>",\
							"<span class='danger'>[user] tries to move you out of [src]!</span>")
			var/oldloc = loc
			var/olddir = dir
			var/old_buckled_mob = buckled_mob
			if(do_after(user, 30, TRUE, 5, BUSY_ICON_CLOCK) && dir == olddir && loc == oldloc && buckled_mob == old_buckled_mob)
				manual_unbuckle(user)


	attackby(obj/item/weapon/W, mob/user)
		if(istype(W, /obj/item/weapon/powerloader_clamp))
			var/obj/item/weapon/powerloader_clamp/PC = W
			if(PC.linked_powerloader == src)
				unbuckle() //clicking the powerloader with its own clamp unbuckles the pilot.
				return 1
		. = ..()

	afterbuckle(mob/M)
		. = ..()
		overlays.Cut()
		if(.)
			icon_state = "powerloader"
			overlays += image(icon_state= "powerloader_overlay", layer = MOB_LAYER + 0.1)
			var/clamp_equipped = 0
			for(var/obj/item/weapon/powerloader_clamp/PC in contents)
				if(!M.put_in_hands(PC)) PC.forceMove(src)
				else clamp_equipped++
			if(clamp_equipped != 2) unbuckle() //can't use the powerloader without both clamps equipped
		else
			icon_state = "powerloader_open"
			M.drop_held_items() //drop the clamp when unbuckling

	buckle_mob(mob/M, mob/user)
		if(M != user) return
		if(!ishuman(M))	return
		var/mob/living/carbon/human/H = M
		if(!check_access(H.wear_id))
			H << "<span class='warning'>You don't have the access to use [src].</span>"
			return
		if(H.r_hand || H.l_hand)
			H << "<span class='warning'>You need your two hands to use [src].</span>"
			return
		. = ..()

	verb/enter_powerloader(mob/M)
		set category = "Object"
		set name = "Enter Power Loader"

		set src in oview(1)
		buckle_mob(M, usr)

	handle_rotation()

		if(buckled_mob)
			buckled_mob.dir = dir
			switch(dir)
				if(EAST) buckled_mob.pixel_x = 7
				if(WEST) buckled_mob.pixel_x = -7
				else buckled_mob.pixel_x = 0

	explode()
		new /obj/structure/powerloader_wreckage(loc)
		..()


/obj/item/weapon/powerloader_clamp
	name = "\improper Power Loader Clamp"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "loader_clamp"
	force = 20
	abstract = TRUE //to prevent placing the item on a table/closet.
					//We're controlling the clamp but the item isn't really in our hand.
	var/obj/vehicle/powerloader/linked_powerloader
	var/obj/loaded

	dropped(mob/user)
		if(linked_powerloader)
			forceMove(linked_powerloader)
			if(linked_powerloader.buckled_mob && linked_powerloader.buckled_mob == user)
				linked_powerloader.unbuckle() //drop a clamp, you auto unbuckle from the powerloader.
		else cdel(src)


	attack(mob/living/M, mob/living/user, def_zone)
		if(M == linked_powerloader.buckled_mob)
			unbuckle() //if the pilot clicks themself with the clamp, it unbuckles them.
			return 1
		else
			return ..()

	afterattack(atom/target, mob/user, proximity)
		if(!proximity) return
		if(loaded)
			if(isturf(target))
				var/turf/T = target
				if(!T.density)
					for(var/atom/movable/AM in T.contents)
						if(AM.density)
							user << "<span class='warning'>You can't drop [loaded] here, [AM] blocks the way.</span>"
							return
					if(loaded.bound_height > 32)
						var/turf/next_turf = get_step(T, NORTH)
						if(next_turf.density)
							user << "<span class='warning'>You can't drop [loaded] here, something blocks the way.</span>"
							return
						for(var/atom/movable/AM in next_turf.contents)
							if(AM.density)
								user << "<span class='warning'>You can't drop [loaded] here, [AM] blocks the way.</span>"
								return
					if(loaded.bound_width > 32)
						var/turf/next_turf = get_step(T, EAST)
						if(next_turf.density)
							user << "<span class='warning'>You can't drop [loaded] here, something blocks the way.</span>"
							return
						for(var/atom/movable/AM in next_turf.contents)
							if(AM.density)
								user << "<span class='warning'>You can't drop [loaded] here, [AM] blocks the way.</span>"
								return
					loaded.forceMove(T)
					loaded = null
					playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
					update_icon()
		else if(istype(target, /obj/structure/closet/crate))
			var/obj/structure/closet/crate/C = target
			if(!C.anchored && !C.store_mobs)
				for(var/X in C)
					if(ismob(X)) //just in case.
						user << "<span class='warning'>Can't grab [loaded], it has a creature inside!</span>"
						return
				if(linked_powerloader)
					C.forceMove(linked_powerloader)
					loaded = C
					playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
					update_icon()
					user << "<span class='notice'>You grab [loaded] with [src].</span>"
			else
				user << "<span class='warning'>Can't grab [loaded].</span>"

	update_icon()
		if(loaded) icon_state = "loader_clamp_full"
		else icon_state = "loader_clamp"

	attack_self(mob/user)
		if(linked_powerloader)
			linked_powerloader.unbuckle()


/obj/structure/powerloader_wreckage
	name = "\improper Power Loader wreckage"
	desc = "Remains of some unfortunate Power Loader. Completely unrepairable."
	icon = 'icons/obj/powerloader.dmi'
	icon_state = "wreck"
	density = 1
	anchored = 0
	opacity = 0
	pixel_x = -18
	pixel_y = -5
