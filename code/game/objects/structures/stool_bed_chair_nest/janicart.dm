

//old style retardo-cart
/obj/structure/bed/chair/janicart
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = FALSE
	density = TRUE
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag	= null
	var/callme = "pimpin' ride"	//how do people refer to it?
	var/move_delay = 2

/obj/structure/bed/chair/janicart/Initialize()
	. = ..()
	create_reagents(100, OPENCONTAINER)


/obj/structure/bed/chair/janicart/examine(mob/user)
	to_chat(user, "[icon2html(src, user)] This [callme] contains [reagents.total_volume] unit\s of water!")
	if(mybag)
		to_chat(user, "\A [mybag] is hanging on the [callme].")


/obj/structure/bed/chair/janicart/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume <= 1)
			to_chat(user, "<span class='notice'>This [callme] is out of water!</span>")
			return

		reagents.trans_to(I, 2)
		to_chat(user, "<span class='notice'>You wet [I] in the [callme].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

	else if(istype(I, /obj/item/key))
		to_chat(user, "Hold [I] in one of your hands while you drive this [callme].")

	else if(istype(I, /obj/item/storage/bag/trash))
		to_chat(user, "<span class='notice'>You hook the trashbag onto the [callme].</span>")
		user.drop_held_item()
		I.forceMove(src)
		mybag = I

/obj/structure/bed/chair/janicart/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null


/obj/structure/bed/chair/janicart/relaymove(mob/user, direction)
	if(world.time <= last_move_time + move_delay)
		return
	if(user.incapacitated(TRUE))
		unbuckle()
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
	else
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive this [callme].</span>")


/obj/structure/bed/chair/janicart/send_buckling_message(mob/M, mob/user)
	M.visible_message(\
		"<span class='notice'>[M] climbs onto the [callme]!</span>",\
		"<span class='notice'>You climb onto the [callme]!</span>")


/obj/structure/bed/chair/janicart/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	update_mob()


/obj/structure/bed/chair/janicart/proc/update_mob()
	if(buckled_mob)
		buckled_mob.setDir(dir)
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7


/obj/structure/bed/chair/janicart/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message("<span class='warning'>[Proj] ricochets off the [callme]!</span>")
	return 1

/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = WEIGHT_CLASS_TINY
