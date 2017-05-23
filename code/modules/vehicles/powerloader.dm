


/obj/vehicle/powerloader
	name = "\improper Power Loader"
	icon = 'icons/obj/vehicles.dmi'
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world."
	icon_state = "powerloader"
	layer = OBJ_LAYER
	anchored = 1
	density = 1
	move_delay = 6
	buckling_y = 6
	health = 200
	maxhealth = 200


	New()
		..()
		cell = new /obj/item/weapon/cell/apc
		for(var/i=1, i<=2, i++)
			var/obj/item/weapon/powerloader_clamp/PC = new(src)
			PC.linked_powerloader = src

	relaymove(mob/user, direction)
		. = ..()
		if(.)
			pick(playsound(loc, 'sound/mecha/powerloader_step.ogg', 25, 1), playsound(loc, 'sound/mecha/powerloader_step2.ogg', 25, 1))


	attackby(obj/item/weapon/W, mob/user)
		if(istype(W, /obj/item/weapon/powerloader_clamp))
			var/obj/item/weapon/powerloader_clamp/PC
			if(PC.linked_powerloader == src)
				unbuckle() //clicking the powerloader with its own clamp unbuckles the pilot.
				return 1
		. = ..()

	afterbuckle(mob/M)
		. = ..()
		overlays.Cut()
		if(.)
			overlays += image(icon_state= "powerloader_overlay", layer = MOB_LAYER + 0.1)
			var/clamp_equipped = 0
			for(var/obj/item/weapon/powerloader_clamp/PC in contents)
				if(!M.put_in_hands(PC)) PC.forceMove(src)
				else clamp_equipped++
			if(clamp_equipped != 2) unbuckle() //can't use the powerloader without both clamps equipped
		else
			M.drop_held_items() //drop the clamp when unbuckling

	buckle_mob(mob/M, mob/user)
		if(M != user) return
		if(!ishuman(M))	return
		if(M.r_hand || M.l_hand) return
		. = ..()

	handle_rotation()
		if(dir == NORTH)
			layer = FLY_LAYER
		else
			layer = OBJ_LAYER

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
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "ripley-broken-old"
	density = 1
	anchored = 0
	opacity = 0