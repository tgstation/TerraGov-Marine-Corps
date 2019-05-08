/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/structures/closet.dmi'
	icon_state = "closed"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/overlay_welded = "welded"
	var/opened = FALSE
	var/welded = FALSE
	var/wall_mounted = FALSE //never solid (You can always pass over it)
	max_integrity = 100
	var/lastbang = FALSE
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.
	var/open_sound = 'sound/machines/click.ogg'
	var/close_sound = 'sound/machines/click.ogg'

	var/store_items = TRUE
	var/store_mobs = TRUE

	var/closet_stun_delay = 1

	anchored = TRUE

	var/const/mob_size = 15

/obj/structure/closet/open
	icon_state = "open"
	density = FALSE
	opened = TRUE

/obj/structure/closet/Initialize()
	. = ..()
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		for(var/obj/item/I in loc)
			if(I.density || I.anchored || I == src)
				continue
			I.loc = src

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target)
	if(wall_mounted)
		return TRUE
	else
		return !density

/obj/structure/closet/proc/can_open()
	if(src.welded)
		return FALSE
	return TRUE

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && !closet.wall_mounted)
			return FALSE
	for(var/mob/living/carbon/Xenomorph/Xeno in get_turf(src))
		return FALSE
	return TRUE

/obj/structure/closet/proc/dump_contents()

	for(var/obj/I in src)
		I.forceMove(loc)

	for(var/mob/M in src)
		M.forceMove(loc)
		M.Stun(closet_stun_delay)//Action delay when going out of a closet
		if(!M.lying && M.stunned)
			M.visible_message("<span class='warning'>[M] suddenly gets out of [src]!",
			"<span class='warning'>You get out of [src] and get your bearings!")

/obj/structure/closet/proc/open()
	if(opened)
		return FALSE

	if(!can_open())
		return FALSE

	dump_contents()

	opened = TRUE
	update_icon()
	playsound(loc, open_sound, 15, 1)
	density = FALSE
	return TRUE

/obj/structure/closet/proc/close()
	if(!src.opened)
		return FALSE
	if(!src.can_close())
		return FALSE

	var/stored_units = 0
	if(store_items)
		stored_units = store_items(stored_units)
	if(store_mobs)
		stored_units = store_mobs(stored_units)

	opened = FALSE
	update_icon()

	playsound(loc, close_sound, 15, 1)
	density = TRUE
	return TRUE

/obj/structure/closet/proc/store_items(var/stored_units)
	for(var/obj/item/I in loc)
		var/item_size = CEILING(I.w_class / 2, 1)
		if(stored_units + item_size > storage_capacity)
			continue
		if(!I.anchored)
			I.loc = src
			stored_units += item_size
	return stored_units

/obj/structure/closet/proc/store_mobs(var/stored_units)
	for(var/mob/M in loc)
		if(stored_units + mob_size > storage_capacity)
			break
		if(isobserver(M))
			continue
		if(M.buckled)
			continue
		var/mob/living/L = M
		L.smokecloak_off()

		M.forceMove(src)
		stored_units += mob_size
	return stored_units

/obj/structure/closet/proc/toggle(mob/living/user)
	user.next_move = world.time + 5
	if(!(src.opened ? src.close() : src.open()))
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		return FALSE
	return TRUE

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A as mob|obj in src)//pulls everything out of the locker and hits it with an explosion
				A.loc = loc
				A.ex_act(severity++)
			qdel(src)
		if(2)
			if(prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.loc = loc
					A.ex_act(severity++)
				qdel(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = loc
					A.ex_act(severity++)
				qdel(src)

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	if(obj_integrity > 999)
		return TRUE
	obj_integrity -= round(Proj.damage*0.3)
	if(prob(30)) playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
	if(obj_integrity <= 0)
		for(var/atom/movable/A as mob|obj in src)
			A.loc = loc
		spawn(1)
			playsound(loc, 'sound/effects/meteorimpact.ogg', 25, 1)
			qdel(src)

	return TRUE

/obj/structure/closet/attack_animal(mob/living/user)
	if(user.wall_smash)
		visible_message("<span class='warning'> [user] destroys the [src]. </span>")
		for(var/atom/movable/A as mob|obj in src)
			A.loc = loc
		qdel(src)

/obj/structure/closet/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == INTENT_HARM && !CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		M.animation_attack_on(src)
		if(!opened && prob(70))
			break_open()
			M.visible_message("<span class='danger'>\The [M] smashes \the [src] open!</span>", \
			"<span class='danger'>You smash \the [src] open!</span>", null, 5)
		else
			M.visible_message("<span class='danger'>\The [M] smashes \the [src]!</span>", \
			"<span class='danger'>You smash \the [src]!</span>", null, 5)
		if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
			M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)
	else if(!opened)
		return attack_paw(M)

/obj/structure/closet/attackby(obj/item/W, mob/living/user)
	if(src.opened)
		if(istype(W, /obj/item/grab))
			if(isxeno(user))
				return
			var/obj/item/grab/G = W
			if(G.grabbed_thing)
				src.MouseDrop_T(G.grabbed_thing, user)      //act like they were dragged onto the closet
			return
		if(W.flags_item & ITEM_ABSTRACT)
			return FALSE
		if(iswelder(W))
			var/obj/item/tool/weldingtool/WT = W
			if(!WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return
			new /obj/item/stack/sheet/metal(loc)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with [WT].</span>", 3, "You hear welding.", 2)
			qdel(src)
			return
		if(istype(W, /obj/item/tool/pickaxe/plasmacutter))
			var/obj/item/tool/pickaxe/plasmacutter/P = W
			if(!P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD, null, null, SFX = FALSE))
				return
			P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Window frames require half the normal power
			P.debris(loc, 1, 0) //Generate some metal
			qdel(src)
			return

		user.transferItemToLoc(W,loc)

	else if(istype(W, /obj/item/packageWrap))
		return
	else if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(!WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		welded = !welded
		update_icon()
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>", 3, "You hear welding.", 2)
	else
		src.attack_hand(user)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/user)
	if(!opened)
		return
	if(!isturf(O.loc))
		return
	if(user.incapacitated())
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1)
		return
	if(!isturf(user.loc))
		return
	if(ismob(O))
		var/mob/M = O
		if(M.buckled)
			return
	else if(!istype(O, /obj/item))
		return

	add_fingerprint(user)
	if(user == O)
		if(climbable)
			do_climb(user)
		return
	else
		step_towards(O, loc)
		user.visible_message("<span class='danger'>[user] stuffs [O] into [src]!</span>")



/obj/structure/closet/relaymove(mob/user)
	if(!isturf(loc))
		return
	if(user.incapacitated(TRUE))
		return
	user.next_move = world.time + 5

	if(!src.open())
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		if(!lastbang)
			lastbang = TRUE
			for (var/mob/M in hearers(src, null))
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = FALSE


/obj/structure/closet/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/closet/attack_hand(mob/living/user)
	add_fingerprint(user)
	return toggle(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user as mob)
	src.add_fingerprint(user)
	if(!src.toggle())
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += image(icon, overlay_welded)
	else
		icon_state = icon_opened


/obj/structure/closet/proc/break_open()
	if(!opened)
		dump_contents()
		opened = TRUE
		playsound(loc, open_sound, 15, 1) //Could use a more telltale sound for "being smashed open"
		density = FALSE
		welded = FALSE
		update_icon()
