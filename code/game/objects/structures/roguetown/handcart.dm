/obj/structure/handcart
	name = "cart"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "cart-empty"
	density = TRUE
	max_integrity = 600
	anchored = FALSE
	climbable = TRUE
	var/list/stuff_shit = list()
	var/total_capacity
	facepull = FALSE
	throw_range = 1

/obj/structure/handcart/container_resist(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in stuff_shit)
		if(AM == user)
			AM.forceMove(T)
			stuff_shit -= AM
			total_capacity = max(total_capacity-10, 0)
			break

/obj/structure/handcart/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		for(var/atom/movable/AM in stuff_shit)
			AM.forceMove(T)
	stuff_shit = list()
	return ..()

/obj/structure/handcart/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(isturf(O.loc))
		if(!insertion_allowed(O))
			return
		if(!O.Adjacent(src))
			return
		put_in(O)
		playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
		return

/obj/structure/handcart/attackby(obj/item/P, mob/user, params)
	if(!user.cmode)
		if(!insertion_allowed(P))
			return
		put_in(P)
		playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
		return
	..()
/obj/structure/handcart/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(isturf(user.loc))
		var/turf/T = user.loc
		user.changeNext_move(CLICK_CD_MELEE)
		var/fou
		for(var/obj/item/I in T)
			if(!insertion_allowed(I))
				continue
			put_in(I)
			fou = TRUE
		if(fou)
			playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)

/obj/structure/handcart/proc/put_in(atom/movable/O)
	if(isitem(O))
		var/obj/item/I = O
		if((total_capacity + I.w_class) > 60)
			return FALSE
		total_capacity += I.w_class
		O.forceMove(src)
		stuff_shit += O
	if(isliving(O))
		var/mob/living/L = O
		if((total_capacity + 10) > 60)
			return FALSE
		total_capacity += 10
		L.forceMove(src)
		stuff_shit += L
	update_icon()
	return TRUE

/obj/structure/handcart/Initialize(mapload)
	if(mapload)		// if closed, any item at the crate's loc is put in the contents
		addtimer(CALLBACK(src, .proc/take_contents), 0)
	. = ..()
	update_icon()

/obj/structure/handcart/proc/take_contents()
	var/turf/T = get_turf(src)
	if(T)
		for(var/atom/movable/AM in T)
			if(AM != src && put_in(AM)) // limit reached
				break

/obj/structure/handcart/update_icon()
	. = ..()
	if(stuff_shit.len)
		icon_state = "cart-full"
	else
		icon_state = "cart-empty"

/obj/structure/handcart/attack_right(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/turf/T = get_turf(src)
	if(T)
		for(var/atom/movable/AM in stuff_shit)
			AM.forceMove(T)
		stuff_shit = list()
		total_capacity = 0
		visible_message("<span class='info'>[user] dumps out [src]!</span>")
		playsound(loc, 'sound/foley/cartdump.ogg', 100, FALSE, -1)
	update_icon()

/obj/structure/handcart/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || (L.buckled && L.buckled != src) || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(L.density)
				return FALSE
		L.stop_pulling()

	else if(isobj(AM))
		if((AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else
			if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
				return TRUE
	else
		return FALSE

	return TRUE