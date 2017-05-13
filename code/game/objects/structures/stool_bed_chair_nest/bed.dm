/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/stool/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	can_buckle = TRUE
	buckle_lying = TRUE
	is_stool = FALSE
	var/buckling_y = 0 //pixel y shift to give to the buckled mob.

/obj/structure/stool/bed/afterbuckle(mob/M)
	. = ..()
	if(. && buckled_mob == M)
		M.pixel_y = buckling_y
		M.old_y = buckling_y
	else
		M.pixel_y = initial(buckled_mob.pixel_y)
		M.old_y = initial(buckled_mob.pixel_y)


/obj/structure/stool/bed/psych
	name = "psychiatrists couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"

/obj/structure/stool/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon_state = "abed"


/*
 * Roller beds
 */
/obj/structure/stool/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	drag_delay = 0 //pulling something on wheels is easy
	buckling_y = 6

/obj/structure/stool/bed/roller/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/roller_holder))
		if(buckled_mob)
			manual_unbuckle()
		else
			visible_message("<span class='notice'>[user] collapses [name].</span>")
			new/obj/item/roller(get_turf(src))
			cdel(src)
		return
	. = ..()

/obj/structure/stool/bed/roller/afterbuckle(mob/M)
	. = ..()
	if(.)
		density = 1
		icon_state = "up"
	else
		density = 0
		icon_state = "down"

/obj/structure/stool/bed/roller/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr))	return
		if(buckled_mob)	return 0
		visible_message("<span class='notice'>[usr] collapses [name].</span>")
		var/obj/structure/stool/bed/roller/RB = new/obj/item/roller(get_turf(src))
		usr.put_in_hands(RB)
		cdel(src)



/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 3 //fits in a backpack
	drag_delay = 0 //pulling something on wheels is easy

	attack_self(mob/user)
		deploy_roller(user, user.loc)

	afterattack(obj/target, mob/user , proximity)
		if(!proximity) return
		if(isturf(target))
			var/turf/T = target
			if(!T.density)
				deploy_roller(user, target)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/roller_holder))
			var/obj/item/roller_holder/RH = W
			if(!RH.held)
				user << "<span class='notice'>You collect the roller bed.</span>"
				loc = RH
				RH.held = src
				return
		. = ..()

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/stool/bed/roller/R = new /obj/structure/stool/bed/roller(location)
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
	var/obj/structure/stool/bed/roller/R = new /obj/structure/stool/bed/roller(user.loc)
	R.add_fingerprint(user)
	cdel(held)
	held = null
