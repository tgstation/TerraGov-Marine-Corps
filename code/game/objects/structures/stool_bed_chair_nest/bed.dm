/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/objects.dmi'
	can_buckle = TRUE
	buckle_lying = TRUE
	throwpass = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/foldabletype //to fold into an item (e.g. roller bed item)
	var/buckling_y = 0 //pixel y shift to give to the buckled mob.

/obj/structure/bed/afterbuckle(mob/M)
	. = ..()
	if(. && buckled_mob == M)
		M.pixel_y = buckling_y
		M.old_y = buckling_y
	else
		M.pixel_y = initial(buckled_mob.pixel_y)
		M.old_y = initial(buckled_mob.pixel_y)


/obj/structure/bed/MouseDrop(atom/over_object)
	. = ..()
	if(foldabletype && !buckled_mob)
		if (istype(over_object, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = over_object
			if (H==usr && !H.is_mob_incapacitated() && Adjacent(H) && in_range(src, over_object))
				var/obj/item/I = new foldabletype(get_turf(src))
				H.put_in_hands(I)
				H.visible_message("\red [H] grabs [src] from the floor!", "\red You grab [src] from the floor!")
				cdel(src)


/obj/structure/bed/ex_act(severity)
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if (prob(50))
				if(buildstacktype)
					new buildstacktype (loc, buildstackamount)
				cdel(src)
		if(3)
			if (prob(5))
				if(buildstacktype)
					new buildstacktype (loc, buildstackamount)
				cdel(src)


/obj/structure/bed/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/wrench))
		if(buildstacktype)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			new buildstacktype(src.loc, buildstackamount)
			cdel(src)
	else
		. = ..()



/obj/structure/bed/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	. = ..()




/obj/structure/bed/psych
	name = "psychiatrists couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"


/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	drag_delay = 0 //pulling something on wheels is easy
	buckling_y = 6
	foldabletype = /obj/item/roller

/obj/structure/bed/roller/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/roller_holder))
		if(buckled_mob)
			manual_unbuckle()
		else
			visible_message("<span class='notice'>[user] collapses [name].</span>")
			new/obj/item/roller(get_turf(src))
			cdel(src)
		return
	. = ..()

/obj/structure/bed/roller/afterbuckle(mob/M)
	. = ..()
	if(.)
		density = 1
		icon_state = "up"
	else
		density = 0
		icon_state = "down"




/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 3 //fits in a backpack
	drag_delay = 1 //pulling something on wheels is easy

	attack_self(mob/user)
		deploy_roller(user, user.loc)

	afterattack(obj/target, mob/user , proximity)
		if(!proximity) return
		if(isturf(target))
			var/turf/T = target
			if(!T.density)
				deploy_roller(user, target)

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/roller_holder))
			var/obj/item/roller_holder/RH = W
			if(!RH.held)
				user << "<span class='notice'>You collect the roller bed.</span>"
				loc = RH
				RH.held = src
				return
		. = ..()

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(location)
	R.add_fingerprint(user)
	user.temp_drop_inv_item(src)
	cdel(src)


/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self(mob/user as mob)

	if(!held)
		user << "<span class='warning'>The rack is empty.</span>"
		return

	user << "<span class='notice'>You deploy the roller bed.</span>"
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(user.loc)
	R.add_fingerprint(user)
	cdel(held)
	held = null
