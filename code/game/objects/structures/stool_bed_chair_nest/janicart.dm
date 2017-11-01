

//old style retardo-cart
/obj/structure/bed/chair/janicart
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = 0
	density = 1
	flags_atom = OPENCONTAINER
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag	= null
	var/callme = "pimpin' ride"	//how do people refer to it?
	var/move_delay = 2

/obj/structure/bed/chair/janicart/New()
	handle_rotation()
	create_reagents(100)


/obj/structure/bed/chair/janicart/examine(mob/user)
	user << "\icon[src] This [callme] contains [reagents.total_volume] unit\s of water!"
	if(mybag)
		user << "\A [mybag] is hanging on the [callme]."


/obj/structure/bed/chair/janicart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume > 1)
			reagents.trans_to(I, 2)
			user << "<span class='notice'>You wet [I] in the [callme].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		else
			user << "<span class='notice'>This [callme] is out of water!</span>"
	else if(istype(I, /obj/item/key))
		user << "Hold [I] in one of your hands while you drive this [callme]."
	else if(istype(I, /obj/item/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the [callme].</span>"
		user.drop_held_item()
		I.loc = src
		mybag = I
	else
		. = ..()


/obj/structure/bed/chair/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()


/obj/structure/bed/chair/janicart/relaymove(mob/user, direction)
	if(world.time <= l_move_time + move_delay)
		return
	if(user.is_mob_incapacitated(TRUE))
		unbuckle()
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive this [callme].</span>"


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
		buckled_mob.dir = dir
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


/obj/structure/bed/chair/janicart/bullet_act(var/obj/item/projectile/Proj)
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
	w_class = 1