/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = 3.0

/obj/item/inflatable/attack_self(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 25, 1)
	to_chat(user, "<span class='notice'>You inflate [src].</span>")
	new /obj/structure/inflatable(user.loc)
	qdel(src)



/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door"

	attack_self(mob/user)
		playsound(loc, 'sound/items/zip.ogg', 25, 1)
		to_chat(user, "<span class='notice'>You inflate [src].</span>")
		new /obj/structure/inflatable/door(user.loc)
		qdel(src)





/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = 0

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"

	max_integrity = 50
	var/deflated = FALSE



/obj/structure/inflatable/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	return 0

/obj/structure/inflatable/bullet_act(var/obj/item/projectile/Proj)
	obj_integrity -= Proj.damage
	..()
	if(obj_integrity <= 0 && !deflated)
		deflate(1)
	return 1


/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			deflate(1)

		if(3)
			if(prob(50))
				deflate(1)


/obj/structure/inflatable/attack_paw(mob/user as mob)
	return attack_generic(user, 15)

/obj/structure/inflatable/attack_hand(mob/user as mob)
	return


/obj/structure/inflatable/proc/attack_generic(mob/living/user, damage = 0)	//used by attack_animal
	obj_integrity -= damage
	user.animation_attack_on(src)
	if(obj_integrity <= 0)
		user.visible_message("<span class='danger'>[user] tears open [src]!</span>")
		deflate(1)
	else	//for nicer text~
		user.visible_message("<span class='danger'>[user] tears at [src]!</span>")

/obj/structure/inflatable/attack_animal(mob/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/inflatable/attack_alien(mob/living/carbon/xenomorph/M)
	M.animation_attack_on(src)
	deflate(1)

/obj/structure/inflatable/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(can_puncture(I))
		visible_message("<span class='danger'>[user] pierces [src] with [I]!</span>")
		deflate(TRUE)

	if(I.damtype == BRUTE || I.damtype == BURN)
		hit(I.force)


/obj/structure/inflatable/proc/hit(var/damage, var/sound_effect = 1)
	obj_integrity = max(0, obj_integrity - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit_old.ogg', 25, 1)
	if(obj_integrity <= 0 && !deflated)
		deflate(1)


/obj/structure/inflatable/proc/deflate(var/violent=0)
	set waitfor = 0
	if(deflated)
		return
	deflated = TRUE
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		flick("wall_popping", src)
		sleep(10)
		new /obj/structure/inflatable/popped(loc)
		//var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
		qdel(src)
	else
		//to_chat(user, "<span class='notice'>You slowly deflate the inflatable wall.</span>")
		visible_message("[src] slowly deflates.")
		flick("wall_deflating", src)
		spawn(50)
			new /obj/item/inflatable(loc)
			qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(isobserver(usr)) //to stop ghosts from deflating
		return
	if(isxeno(usr))
		return

	if(!deflated)
		deflate()
	else
		to_chat(usr, "[src] is already deflated.")





/obj/structure/inflatable/popped
	name = "popped inflatable wall"
	desc = "It used to be an inflatable wall, now it's just a mess of plastic."
	density = 0
	anchored = TRUE
	deflated = TRUE

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall_popped"


/obj/structure/inflatable/popped/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	return 1


/obj/structure/inflatable/popped/door
	name = "popped inflatable door"
	desc = "This used to be an inflatable door, now it's just a mess of plastic."

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_popped"




/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	density = TRUE
	anchored = TRUE
	opacity = 0

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_closed"

	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0


/obj/structure/inflatable/door/attack_paw(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group)
		return state
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) return
	if(ismob(user))
		var/mob/M = user
		if(world.time - M.last_bumped <= 60) return //NOTE do we really need that?
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()


/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = 1
	//playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)
	flick("door_opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = 1
	//playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)
	flick("door_closing",src)
	sleep(10)
	density = TRUE
	opacity = 0
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/deflate(var/violent=0)
	set waitfor = 0
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	if(violent)
		visible_message("[src] rapidly deflates!")
		flick("door_popping",src)
		sleep(10)
		new /obj/structure/inflatable/popped/door(loc)
		//var/obj/item/inflatable/door/torn/R = new /obj/item/inflatable/door/torn(loc)
		qdel(src)
	else
		//to_chat(user, "<span class='notice'>You slowly deflate the inflatable wall.</span>")
		visible_message("[src] slowly deflates.")
		flick("door_deflating", src)
		spawn(50)
			new /obj/item/inflatable/door(loc)
			qdel(src)






/obj/item/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "syringe_kit"
	max_storage_space = 21

	New()
		..()
		new /obj/item/inflatable/door(src)
		new /obj/item/inflatable/door(src)
		new /obj/item/inflatable/door(src)
		new /obj/item/inflatable(src)
		new /obj/item/inflatable(src)
		new /obj/item/inflatable(src)
		new /obj/item/inflatable(src)
