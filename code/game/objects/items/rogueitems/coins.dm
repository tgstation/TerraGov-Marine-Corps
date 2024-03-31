n

#define CTYPE_GOLD 1
#define CTYPE_SILV 2
#define CTYPE_COPP 3

/obj/item/roguecoin
	name = ""
	icon_state = ""
	icon = 'icons/roguetown/items/valuable.dmi'
	desc = ""
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	desc = ""
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_MOUTH
	var/list/held = list()
	dropshrink = 0.2
	drop_sound = 'sound/foley/coinphy (1).ogg'
	sellprice = 0
	static_price = TRUE
	simpleton_price = TRUE
	var/flintcd
	var/headstails = 1
	var/base_type //used for compares

/obj/item/roguecoin/getonmobprop(tag)
	. = ..()
	if(tag)
		if(held.len)
			if(tag == "gen")
				return list("shrink" = 0.10,"sx" = -6,"sy" = 6,"nx" = 6,"ny" = 7,"wx" = 0,"wy" = 5,"ex" = -1,"ey" = 7,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -50,"sturn" = 40,"wturn" = 50,"eturn" = -50,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
		else
			if(tag == "gen")
				return list("shrink" = 0.10,"sx" = -6,"sy" = 6,"nx" = 6,"ny" = 7,"wx" = 0,"wy" = 5,"ex" = -1,"ey" = 7,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -50,"sturn" = 40,"wturn" = 50,"eturn" = -50,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)


/*
/obj/structure/coinpile
	name = "pile of coins"
	desc = ""
	max_integrity = 0
	var/list/held = list()*/

/obj/item/roguecoin/dropped()
//	scatter(get_turf(src))
	..()

/obj/item/roguecoin/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	playsound(loc, 'sound/foley/coins1.ogg', 100, TRUE, -2)
	scatter(get_turf(src))
	..()

/obj/item/roguecoin/proc/scatter(turf/T)
	pixel_x = rand(-8,8)
	pixel_y = rand(-5,5)
	if(T)
		var/turf/HT = T
		if(held.len)
			var/obj/structure/table/TA = locate() in HT
			if(!TA) //no table
				for(var/obj/item/roguecoin/C in held)
					held -= C
					C.forceMove(HT)
					C.scatter()
//	dropped()
	update_icon()
	update_transform()
/*
/obj/item/roguecoin/proc/mergeground(turf/T)
	if(T)
		var/turf/HT = T
		if(held.len)
			var/obj/structure/coinpile/CP = locate() in HT
			if(CP) //no table
				for(var/obj/item/roguegem/C in held)
					held -= C
					C.forceMove(CP)
					CP.held += C
				src.forceMove(CP)
				CP.held += src
				CP.update_icon()
	update_icon()
*/
/obj/item/roguecoin/get_real_price()
	var/SP = sellprice
	for(var/obj/item/O in held)
		SP += O.sellprice
	return SP

/obj/item/roguecoin/pre_sell()
	if(held.len)
		scatter(get_turf(loc))
	update_icon()
	..()

/obj/item/roguecoin/examine(mob/user)
	. = ..()
	if(held.len)
		. += "<span class='info'>\Roman [held.len + 1] coins.</span>"

/obj/item/roguecoin/proc/merge(obj/item/roguecoin/G, mob/user)
	if(!G)
		return
	if(G.base_type != base_type)
		return
	if(user)
		if((user.get_inactive_held_item() != G) && !isturf(G.loc))
			return
	if(G.held.len)
		for(var/obj/item/roguecoin/H in G.held)
			if(held.len < 19)
				H.forceMove(src)
				held += H
				G.held -= H
		G.update_icon()
		update_icon()
	if(!G.held.len && held.len < 19)
		G.forceMove(src)
		held += G
	update_icon()
	user.update_inv_hands()


/obj/item/roguecoin/attack_hand(mob/user)
	if((user.get_inactive_held_item() == src) && held.len)
		var/list/based = held.Copy()
		based += src
		var/numbers = list()
		for(var/i = 1, i < based.len, i++)
			numbers += i
		var/amount = input(user,"How many?") as null|anything in sortList(numbers)
		if(!amount)
			return
		if(amount == based.len)
			return ..()
		for(var/obj/item/roguecoin/Parent in based) //find a coin to take
			if(Parent == src)
				continue
			based -= Parent
			held -= Parent
			amount--
			if(amount > 0) //take more if that's what we chose to do
				for(var/x in 1 to amount)
					for(var/obj/item/roguecoin/G in based)
						if(G == src) //we don't want to take the parent coin
							continue
						Parent.held += G
						held -= G
						based -= G
						G.loc = Parent
						break
			user.put_in_hands(Parent)
			Parent.update_icon()
			update_icon()
			return
	..()

/obj/item/roguecoin/Initialize()
	. = ..()
	headstails = prob(50)
	update_icon()

/obj/item/roguecoin/update_icon()
	..()
	if(held.len)
		drop_sound = 'sound/foley/coins1.ogg'
	else
		drop_sound = 'sound/foley/coinphy (1).ogg'
	if(held.len > 1)
		dropshrink = 1
	else
		dropshrink = 0.2


/obj/item/roguecoin/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/roguecoin))
		var/obj/item/roguecoin/G = I
		G.merge(src, user)
	else
		return ..()

//GOLD

/obj/item/roguecoin/gold
	name = "zenar"
	desc = "A gold coin bearing the symbol of the Taurus and the pre-kingdom psycross. These were in the best condition of the provincial gold mints, the rest were melted down."
	icon_state = "g1"
	sellprice = 10
	base_type = CTYPE_GOLD

/obj/item/roguecoin/gold/attack_self(mob/living/user)
	if(held.len)
		return
	if(world.time < flintcd + 30)
		return
	flintcd = world.time
	playsound(user, 'sound/foley/coinphy (1).ogg', 100, FALSE)
	if(prob(50))
		icon_state = "g1"
		user.visible_message("<span class='info'>[user] flips the coin. Heads!</span>")
	else
		icon_state = "g0"
		user.visible_message("<span class='info'>[user] flips the coin. Tails!</span>")

/obj/item/roguecoin/gold/update_icon()
	..()
	if(held.len)
		name = "zenarii"
		desc = ""
		switch(held.len)
			if(1)
				icon_state = "gm"
				for(var/obj/item/I in held)
					if(I.icon_state == icon_state)
						icon_state = "g[headstails]1"
			if(2)
				icon_state = "g2"
			if(3 to 4)
				icon_state = "g3"
			if(5 to 9)
				icon_state = "g5"
			if(10 to 14)
				icon_state = "g10"
			if(15 to 18)
				icon_state = "g15"
			if(19)
				icon_state = "g15"

	else
		icon_state = "g[headstails]"
		name = initial(name)
		desc = initial(desc)



// SILVER


/obj/item/roguecoin/silver
	name = "ziliqua"
	desc = "An ancient silver coin still in use due to their remarkable ability to last the ages."
	icon_state = "s1"
	sellprice = 5
	base_type = CTYPE_SILV

/obj/item/roguecoin/silver/attack_self(mob/living/user)
	if(held.len)
		return
	if(world.time < flintcd + 30)
		return
	flintcd = world.time
	playsound(user, 'sound/foley/coinphy (1).ogg', 100, FALSE)
	if(prob(50))
		icon_state = "s1"
		user.visible_message("<span class='info'>[user] flips the coin. Heads!</span>")
	else
		icon_state = "s0"
		user.visible_message("<span class='info'>[user] flips the coin. Tails!</span>")

/obj/item/roguecoin/silver/update_icon()
	..()
	if(held.len)
		name = "ziliquae"
		desc = ""
		switch(held.len)
			if(1)
				icon_state = "sm"
				for(var/obj/item/I in held)
					if(I.icon_state == icon_state)
						icon_state = "s[headstails]1"
			if(2)
				icon_state = "s2"
			if(3 to 4)
				icon_state = "s3"
			if(5 to 9)
				icon_state = "s5"
			if(10 to 14)
				icon_state = "s10"
			if(15 to 18)
				icon_state = "s15"
			if(19)
				icon_state = "s15"

	else
		icon_state = "s[headstails]"
		name = initial(name)
		desc = initial(desc)


// COPPER


/obj/item/roguecoin/copper
	name = "zenny"
	desc = "A brand-new bronze coin minted by the capital in an effort to be rid of the financial use of silver."
	icon_state = "c1"
	sellprice = 1
	base_type = CTYPE_COPP

/obj/item/roguecoin/copper/attack_self(mob/living/user)
	if(held.len)
		return
	if(world.time < flintcd + 30)
		return
	flintcd = world.time
	playsound(user, 'sound/foley/coinphy (1).ogg', 100, FALSE)
	if(prob(50))
		icon_state = "c1"
		user.visible_message("<span class='info'>[user] flips the coin. Heads!</span>")
	else
		icon_state = "c0"
		user.visible_message("<span class='info'>[user] flips the coin. Tails!</span>")

/obj/item/roguecoin/copper/update_icon()
	..()
	if(held.len)
		name = "zennies"
		desc = ""
		switch(held.len)
			if(1)
				icon_state = "cm"
				for(var/obj/item/I in held)
					if(I.icon_state == icon_state)
						icon_state = "c[headstails]1"
			if(2)
				icon_state = "c2"
			if(3 to 4)
				icon_state = "c3"
			if(5 to 9)
				icon_state = "c5"
			if(10 to 14)
				icon_state = "c10"
			if(15 to 18)
				icon_state = "c15"
			if(19)
				icon_state = "c15"

	else
		icon_state = "c[headstails]"
		name = initial(name)
		desc = initial(desc)


///SPAWNING


/obj/item/roguecoin/copper/pile/Initialize()
	. = ..()
	var/amt = rand(3,18)
	for(var/i in 1 to amt)
		var/obj/item/roguecoin/copper/G = new (src)
		held += G
	update_icon()

/obj/item/roguecoin/silver/pile/Initialize()
	. = ..()
	var/amt = rand(3,18)
	for(var/i in 1 to amt)
		var/obj/item/roguecoin/silver/G = new (src)
		held += G
	update_icon()

/obj/item/roguecoin/gold/pile/Initialize()
	. = ..()
	var/amt = rand(3,18)
	for(var/i in 1 to amt)
		var/obj/item/roguecoin/gold/G = new (src)
		held += G
	update_icon()

#undef CTYPE_GOLD
#undef CTYPE_SILV
#undef CTYPE_COPP
