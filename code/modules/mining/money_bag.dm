/*****************************Money bag********************************/

/obj/item/moneybag
	icon = 'icons/obj/items/storage/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	force = 10.0
	throwforce = 2.0
	w_class = WEIGHT_CLASS_BULKY

/obj/item/moneybag/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_phoron = 0
	var/amt_uranium = 0

	for (var/obj/item/coin/C in contents)
		if (istype(C,/obj/item/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/coin/phoron))
			amt_phoron++;
		if (istype(C,/obj/item/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/coin/uranium))
			amt_uranium++;

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='?src=\ref[src];remove=silver'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='?src=\ref[src];remove=diamond'>Remove one</A><br>")
	if (amt_phoron)
		dat += text("Phoron coins: [amt_phoron] <A href='?src=\ref[src];remove=phoron'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='?src=\ref[src];remove=uranium'>Remove one</A><br>")
	user << browse("[dat]", "window=moneybag")

/obj/item/moneybag/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/coin))
		var/obj/item/coin/C = I
		to_chat(user, "<span class='notice'>You add the [C.name] into the bag.</span>")
		user.drop_held_item()
		C.forceMove(src)

	else if(istype(I, /obj/item/moneybag))
		var/obj/item/moneybag/C = I
		for(var/obj/O in C.contents)
			O.forceMove(src)
		to_chat(user, "<span class='notice'>You empty the [C.name] into the bag.</span>")

/obj/item/moneybag/Topic(href, href_list)
	. = ..()
	if(.)
		return
	usr.set_interaction(src)
	if(href_list["remove"])
		var/obj/item/coin/COIN
		switch(href_list["remove"])
			if("gold")
				COIN = locate(/obj/item/coin/gold,src.contents)
			if("silver")
				COIN = locate(/obj/item/coin/silver,src.contents)
			if("iron")
				COIN = locate(/obj/item/coin/iron,src.contents)
			if("diamond")
				COIN = locate(/obj/item/coin/diamond,src.contents)
			if("phoron")
				COIN = locate(/obj/item/coin/phoron,src.contents)
			if("uranium")
				COIN = locate(/obj/item/coin/uranium,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



/obj/item/moneybag/vault

/obj/item/moneybag/vault/Initialize(mapload, ...)
	. = ..()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
