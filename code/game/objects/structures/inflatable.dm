/obj/item/inflatable
	name = "generic inflatable"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/inflatable.dmi'
	hit_sound = 'sound/effects/Glasshit_old.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	///The type of structure we make upon inflation
	var/inflatable_type


/obj/item/inflatable/attack_self(mob/user)
	. = ..()
	balloon_alert(user, "Inflating...")
	if(!do_after(user, 3 SECONDS, NONE, src))
		balloon_alert(user, "Interrupted!")
		return
	playsound(loc, 'sound/items/zip.ogg', 25, 1)
	to_chat(user, span_notice("You inflate [src]."))
	new inflatable_type(get_turf(user))
	qdel(src)


/obj/item/inflatable/wall
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon_state = "folded_wall"
	inflatable_type = /obj/structure/inflatable/wall


/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon_state = "folded_door"
	inflatable_type = /obj/structure/inflatable/door


/obj/structure/inflatable
	name = "generic inflatable"
	desc = "You shouldn't be seeing this."
	density = TRUE
	allow_pass_flags = NONE
	icon = 'icons/obj/inflatable.dmi'
	max_integrity = 50
	resistance_flags = XENO_DAMAGEABLE

	///Are we deflated?
	var/deflated = FALSE
	///The type of item we get back upon deflation
	var/inflatable_item
	///The popped variant of this type
	var/popped_variant


/obj/structure/inflatable/deconstruct(disassembled = TRUE)
	if(!deflated)
		deflate(!disassembled)
	return ..()

/obj/structure/inflatable/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			deflate(TRUE)

		if(EXPLODE_LIGHT)
			if(prob(50))
				deflate(TRUE)
		if(EXPLODE_WEAK)
			if(prob(20))
				deflate(TRUE)


/obj/structure/inflatable/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(can_puncture(I))
		visible_message(span_danger("[user] pierces [src] with [I]!"))
		deflate(TRUE)

///Handles the structure deflating
/obj/structure/inflatable/proc/deflate(violent = FALSE)
	set waitfor = 0
	if(deflated)
		return
	deflated = TRUE
	playsound(loc, 'sound/machines/hiss.ogg', 25, 1)
	visible_message("[src] [violent ? "rapidly" : "slowly"] deflates!")
	flick("wall_[violent ? "popping" : "deflating"]", src)
	addtimer(CALLBACK(src, PROC_REF(post_deflate), violent), violent ? 1 SECONDS : 5 SECONDS)

///Creates the appropriate item after deflation
/obj/structure/inflatable/proc/post_deflate(violent = FALSE)
	if(violent)
		new popped_variant(get_turf(src))
	else
		new inflatable_item(get_turf(src))
	qdel(src)


/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(!ishuman(usr))
		return

	if(!deflated)
		balloon_alert(usr, "Deflating...")
		deflate(FALSE)
	else
		balloon_alert(usr, "Already deflated.")


/obj/structure/inflatable/wall
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	icon_state = "wall"
	inflatable_item = /obj/item/inflatable/wall
	popped_variant = /obj/structure/inflatable/popped

/obj/structure/inflatable/popped
	name = "popped inflatable wall"
	desc = "It used to be an inflatable wall, now it's just a mess of plastic."
	density = FALSE
	anchored = TRUE
	deflated = TRUE
	icon_state = "wall_popped"


/obj/structure/inflatable/popped/door
	name = "popped inflatable door"
	desc = "This used to be an inflatable door, now it's just a mess of plastic."
	icon_state = "door_popped"


//TODO make this not copypasta. A simple door component maybe.
/obj/structure/inflatable/door
	name = "inflatable door"
	icon_state = "door_closed"
	inflatable_item = /obj/item/inflatable/door
	popped_variant = /obj/structure/inflatable/popped/door
	///Are we open?
	var/open = FALSE
	///Are we currently busy opening/closing?
	var/switching_states = FALSE

/obj/structure/inflatable/door/Initialize(mapload)
	. = ..()
	if((locate(/mob/living) in loc) && !open)
		toggle_state()

/obj/structure/inflatable/door/Bumped(atom/user)
	. = ..()
	if(!open)
		return try_toggle_state(user)

/obj/structure/inflatable/door/update_icon()
	. = ..()
	if(open)
		icon_state = "door_open"
	else
		icon_state = "door_closed"

/obj/structure/inflatable/door/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return try_toggle_state(user)

/obj/structure/inflatable/door/CanAllowThrough(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group)
		return open
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return ..()

/*
 * Checks all the requirements for opening/closing a door before opening/closing it. Copypasta. TODO: un-copypasta this
 *
 * atom/user - the mob trying to open/close this door
*/
/obj/structure/inflatable/door/proc/try_toggle_state(atom/user)
	if(switching_states || !ismob(user) || locate(/mob/living) in get_turf(src))
		return
	var/mob/M = user
	if(!M.client)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.handcuffed)
			return
	toggle_state()


///The proc that actually does the door closing. Plays the animation, etc. Copypasta. TODO: un-copypasta this
/obj/structure/inflatable/door/proc/toggle_state()
	switching_states = TRUE
	open = !open
	flick("door_[open ? "opening" : "closing"]", src)
	density = !density
	update_icon()
	addtimer(VARSET_CALLBACK(src, switching_states, FALSE), 1 SECONDS)

/obj/item/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "syringe_kit"
	max_storage_space = 21

/obj/item/storage/briefcase/inflatable/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/inflatable/door(src)
	for(var/i in 1 to 4)
		new /obj/item/inflatable/wall(src)
