/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	hit_sound = 'sound/effects/Glasshit_old.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/inflatable/attack_self(mob/user)
	playsound(loc, 'sound/items/zip.ogg', 25, 1)
	to_chat(user, span_notice("You inflate [src]."))
	new /obj/structure/inflatable(user.loc)
	qdel(src)



/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door"

	attack_self(mob/user)
		playsound(loc, 'sound/items/zip.ogg', 25, 1)
		to_chat(user, span_notice("You inflate [src]."))
		new /obj/structure/inflatable/door(user.loc)
		qdel(src)





/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	throwpass = FALSE

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"

	max_integrity = 50
	resistance_flags = XENO_DAMAGEABLE
	var/deflated = FALSE


/obj/structure/inflatable/deconstruct(disassembled = TRUE)
	if(!deflated)
		deflate(!disassembled)
	return ..()

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			deflate(1)

		if(EXPLODE_LIGHT)
			if(prob(50))
				deflate(1)


/obj/structure/inflatable/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(can_puncture(I))
		visible_message(span_danger("[user] pierces [src] with [I]!"))
		deflate(TRUE)


/obj/structure/inflatable/proc/deflate(violent=0)
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
		//to_chat(user, span_notice("You slowly deflate the inflatable wall."))
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
	density = FALSE
	anchored = TRUE
	deflated = TRUE

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall_popped"


/obj/structure/inflatable/popped/door
	name = "popped inflatable door"
	desc = "This used to be an inflatable door, now it's just a mess of plastic."

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_popped"




/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	density = TRUE
	anchored = TRUE
	opacity = FALSE

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_closed"

	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0

/obj/structure/inflatable/door/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return TryToSwitchState(user)

/obj/structure/inflatable/door/CanAllowThrough(atom/movable/mover, turf/target, height = 0, air_group = 0)
	. = ..()
	if(air_group)
		return state
	if(istype(mover, /obj/effect/beam))
		return !opacity

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates)
		return
	if(ismob(user))
		var/mob/M = user
		if(TIMER_COOLDOWN_CHECK(M, COOLDOWN_BUMP))
			return
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
			TIMER_COOLDOWN_START(M, COOLDOWN_BUMP, 6 SECONDS)

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
	density = FALSE
	opacity = FALSE
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = 1
	//playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 25, 1)
	flick("door_closing",src)
	sleep(10)
	density = TRUE
	opacity = FALSE
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/deflate(violent=0)
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
		//to_chat(user, span_notice("You slowly deflate the inflatable wall."))
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
