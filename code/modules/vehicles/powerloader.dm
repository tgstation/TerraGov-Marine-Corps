/obj/vehicle/powerloader
	name = "\improper RPL-Y Cargo Loader"
	icon = 'icons/obj/powerloader.dmi'
	desc = "The RPL-Y Cargo Loader is a commercial mechanized exoskeleton used for lifting heavy materials and objects. An old but trusted design used in warehouses, constructions and military ships everywhere."
	icon_state = "powerloader_open"
	layer = POWERLOADER_LAYER //so the top appears above windows and wall mounts
	anchored = 1
	density = 1
	luminosity = 5
	move_delay = 8
	health = 200
	maxhealth = 200
	var/panel_open = FALSE

/obj/vehicle/powerloader/New()
	. = ..()
	cell = new /obj/item/cell/apc(src)
	for(var/i = 1, i <= 2, i++)
		var/obj/item/powerloader_clamp/PC = new(src)
		PC.linked_powerloader = src

/obj/vehicle/powerloader/relaymove(mob/user, direction)
	if(user.is_mob_incapacitated()) 
		return
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

/obj/vehicle/powerloader/attack_hand(mob/user)
	if(buckled_mob && user != buckled_mob)
		buckled_mob.visible_message("<span class='warning'>[user] tries to move [buckled_mob] out of [src].</span>",\
		"<span class='danger'>[user] tries to move you out of [src]!</span>")
		var/oldloc = loc
		var/olddir = dir
		var/old_buckled_mob = buckled_mob
		if(do_after(user, 30, TRUE, 5, BUSY_ICON_HOSTILE) && dir == olddir && loc == oldloc && buckled_mob == old_buckled_mob)
			manual_unbuckle(user)
			playsound(loc, 'sound/mecha/powerloader_unbuckle.ogg', 25)
	if(panel_open)
		if(cell)
			usr.put_in_hands(cell)
			playsound(src,'sound/machines/click.ogg', 25, 1)
			to_chat(usr, "You take out the [cell] out of the [src].")
			cell = null
		else
			to_chat(usr, "There is no cell in the [src].")


/obj/vehicle/powerloader/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/powerloader_clamp))
		var/obj/item/powerloader_clamp/PC = W
		if(PC.linked_powerloader == src)
			unbuckle() //clicking the powerloader with its own clamp unbuckles the pilot.
			playsound(loc, 'sound/mecha/powerloader_unbuckle.ogg', 25)
			return TRUE
	else if(istype(W, /obj/item/tool/screwdriver))
		to_chat(user, "<span class='notice'>You screw the panel [panel_open ? "closed" : "open"].</span>")
		playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
		panel_open = !panel_open
	else if(istype(W, /obj/item/cell) && panel_open)
		if(!cell)
			var/obj/item/cell/C = W
			cell = C
			qdel(C)
			visible_message("[user] puts a new power cell in the [src].")
			to_chat(user, "You put a new cell in the [src] containing [cell.charge] charge.")
			playsound(src,'sound/machines/click.ogg', 25, 1)
		else
			to_chat(user, "There already is a power cell in the [src].")
	else
		return ..()

/obj/vehicle/powerloader/examine(mob/user)
	. = ..()
	if(cell)
		to_chat(user, "There is a [cell] in the [src] containing [cell.charge] charge.")
	else
		to_chat(user, "There is no power cell in the [src].")

/obj/vehicle/powerloader/afterbuckle(mob/M)
	. = ..()
	overlays.Cut()
	playsound(loc, 'sound/mecha/powerloader_buckle.ogg', 25)
	if(.)
		icon_state = "powerloader"
		overlays += image(icon_state= "powerloader_overlay", layer = MOB_LAYER + 0.1)
		if(M.mind && M.mind.cm_skills)
			move_delay = max(4, move_delay - M.mind.cm_skills.powerloader)
		var/clamp_equipped = 0
		for(var/obj/item/powerloader_clamp/PC in contents)
			if(!M.put_in_hands(PC)) 
				PC.forceMove(src)
			else 
				clamp_equipped++
		if(clamp_equipped != 2) unbuckle() //can't use the powerloader without both clamps equipped
	else
		move_delay = initial(move_delay)
		icon_state = "powerloader_open"
		M.drop_held_items() //drop the clamp when unbuckling

/obj/vehicle/powerloader/buckle_mob(mob/M, mob/user)
	if(M != user) 
		return
	if(!ishuman(M))	
		return
	var/mob/living/carbon/human/H = M
	if(H.r_hand || H.l_hand)
		to_chat(H, "<span class='warning'>You need your two hands to use [src].</span>")
		return
	. = ..()

/obj/vehicle/powerloader/verb/enter_powerloader(mob/M)
	set category = "Object"
	set name = "Enter Power Loader"
	set src in oview(1)

	buckle_mob(M, usr)

/obj/vehicle/powerloader/handle_rotation()
	if(buckled_mob)
		buckled_mob.dir = dir

/obj/vehicle/powerloader/explode()
	new /obj/structure/powerloader_wreckage(loc)
	playsound(loc, 'sound/effects/metal_crash.ogg', 75)
	..()

/obj/item/powerloader_clamp
	icon = 'icons/obj/powerloader.dmi'
	name = "\improper RPL-Y Cargo Loader Hydraulic Claw"
	icon_state = "loader_clamp"
	force = 20
	flags_item = ITEM_ABSTRACT //to prevent placing the item on a table/closet.
								//We're controlling the clamp but the item isn't really in our hand.
	var/obj/vehicle/powerloader/linked_powerloader
	var/obj/loaded

/obj/item/powerloader_clamp/dropped(mob/user)
	if(linked_powerloader)
		forceMove(linked_powerloader)
		if(linked_powerloader.buckled_mob && linked_powerloader.buckled_mob == user)
			linked_powerloader.unbuckle() //drop a clamp, you auto unbuckle from the powerloader.
	else qdel(src)


/obj/item/powerloader_clamp/attack(mob/living/M, mob/living/user, def_zone)
	if(M == linked_powerloader.buckled_mob)
		unbuckle() //if the pilot clicks themself with the clamp, it unbuckles them.
		return 1
	else if(isXeno(M) && user.a_intent == "help")
		var/mob/living/carbon/Xenomorph/X = M
		if(X.stat == DEAD)
			if(!X.anchored)
				if(linked_powerloader)
					X.forceMove(linked_powerloader)
					loaded = X
					playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
					update_icon()
					user.visible_message("<span class='notice'>[user] grabs [loaded] with [src].</span>",
					"<span class='notice'>You grab [loaded] with [src].</span>")
	else
		return ..()

/obj/item/powerloader_clamp/afterattack(atom/target, mob/user, proximity)

	if(!proximity) return

	if(loaded)
		if(isturf(target))
			var/turf/T = target
			if(!T.density)
				for(var/atom/movable/AM in T.contents)
					if(AM.density)
						to_chat(user, "<span class='warning'>You can't drop [loaded] here, [AM] blocks the way.</span>")
						return
				if(loaded.bound_height > 32)
					var/turf/next_turf = get_step(T, NORTH)
					if(next_turf.density)
						to_chat(user, "<span class='warning'>You can't drop [loaded] here, something blocks the way.</span>")
						return
					for(var/atom/movable/AM in next_turf.contents)
						if(AM.density)
							to_chat(user, "<span class='warning'>You can't drop [loaded] here, [AM] blocks the way.</span>")
							return
				if(loaded.bound_width > 32)
					var/turf/next_turf = get_step(T, EAST)
					if(next_turf.density)
						to_chat(user, "<span class='warning'>You can't drop [loaded] here, something blocks the way.</span>")
						return
					for(var/atom/movable/AM in next_turf.contents)
						if(AM.density)
							to_chat(user, "<span class='warning'>You can't drop [loaded] here, [AM] blocks the way.</span>")
							return
				user.visible_message("<span class='notice'>[user] drops [loaded] on [T] with [src].</span>",
				"<span class='notice'>You drop [loaded] on [T] with [src].</span>")
				loaded.forceMove(T)
				loaded = null
				playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
				update_icon()

	else if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = target
		if(!C.anchored && !C.store_mobs)
			for(var/X in C)
				if(ismob(X)) //just in case.
					to_chat(user, "<span class='warning'>Can't grab [loaded], it has a creature inside!</span>")
					return
			if(linked_powerloader)
				C.forceMove(linked_powerloader)
				loaded = C
				playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
				update_icon()
				user.visible_message("<span class='notice'>[user] grabs [loaded] with [src].</span>",
				"<span class='notice'>You grab [loaded] with [src].</span>")
		else
			to_chat(user, "<span class='warning'>Can't grab [loaded].</span>")

	else if(istype(target, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = target
		if(!LC.anchored)
			if(linked_powerloader)
				LC.forceMove(linked_powerloader)
				loaded = LC
				playsound(src, 'sound/machines/hydraulics_2.ogg', 40, 1)
				update_icon()
				user.visible_message("<span class='notice'>[user] grabs [loaded] with [src].</span>",
				"<span class='notice'>You grab [loaded] with [src].</span>")
		else
			to_chat(user, "<span class='warning'>Can't grab [loaded].</span>")

/obj/item/powerloader_clamp/update_icon()
	if(loaded) 
		icon_state = "loader_clamp_full"
	else 
		icon_state = "loader_clamp"

/obj/item/powerloader_clamp/attack_self(mob/user)
	if(linked_powerloader)
		linked_powerloader.unbuckle()

/obj/structure/powerloader_wreckage
	name = "\improper RPL-Y Cargo Loader wreckage"
	desc = "Remains of some unfortunate Cargo Loader. Completely unrepairable."
	icon = 'icons/obj/powerloader.dmi'
	icon_state = "wreck"
	density = 1
	anchored = 0
	opacity = 0