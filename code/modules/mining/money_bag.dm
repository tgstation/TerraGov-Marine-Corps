/obj/item/moneybag
	icon = 'icons/obj/items/storage/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	force = 10
	throwforce = 2
	w_class = WEIGHT_CLASS_BULKY


/obj/item/moneybag/interact(mob/user)
	. = ..()
	if(.)
		return

	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_phoron = 0
	var/amt_uranium = 0

	for(var/obj/item/coin/C in contents)
		if(istype(C,/obj/item/coin/diamond))
			amt_diamond++
		if(istype(C,/obj/item/coin/phoron))
			amt_phoron++
		if(istype(C,/obj/item/coin/iron))
			amt_iron++
		if(istype(C,/obj/item/coin/silver))
			amt_silver++
		if(istype(C,/obj/item/coin/gold))
			amt_gold++
		if(istype(C,/obj/item/coin/uranium))
			amt_uranium++

	var/dat = "<b>The contents of the moneybag reveal...</b><br>"
	if(amt_gold)
		dat += "Gold coins: [amt_gold] <A href='?src=[text_ref(src)];remove=gold'>Remove one</A><br>"
	if(amt_silver)
		dat += "Silver coins: [amt_silver] <A href='?src=[text_ref(src)];remove=silver'>Remove one</A><br>"
	if(amt_iron)
		dat += "Metal coins: [amt_iron] <A href='?src=[text_ref(src)];remove=iron'>Remove one</A><br>"
	if(amt_diamond)
		dat += "Diamond coins: [amt_diamond] <A href='?src=[text_ref(src)];remove=diamond'>Remove one</A><br>"
	if(amt_phoron)
		dat += "Phoron coins: [amt_phoron] <A href='?src=[text_ref(src)];remove=phoron'>Remove one</A><br>"
	if(amt_uranium)
		dat += "Uranium coins: [amt_uranium] <A href='?src=[text_ref(src)];remove=uranium'>Remove one</A><br>"

	var/datum/browser/popup = new(user, "moneybag")
	popup.set_content(dat)
	popup.open()


/obj/item/moneybag/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/coin))
		var/obj/item/coin/C = I
		to_chat(user, span_notice("You add the [C] into the bag."))
		user.drop_held_item()
		C.forceMove(src)

	else if(istype(I, /obj/item/moneybag))
		var/obj/item/moneybag/C = I
		for(var/obj/O in C.contents)
			O.forceMove(src)
		to_chat(user, span_notice("You empty the [C] into the bag."))


/obj/item/moneybag/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["remove"])
		var/obj/item/coin/C
		switch(href_list["remove"])
			if("gold")
				C = locate(/obj/item/coin/gold, src)
			if("silver")
				C = locate(/obj/item/coin/silver, src)
			if("iron")
				C = locate(/obj/item/coin/iron, src)
			if("diamond")
				C = locate(/obj/item/coin/diamond, src)
			if("phoron")
				C = locate(/obj/item/coin/phoron, src)
			if("uranium")
				C = locate(/obj/item/coin/uranium, src)
		if(!C)
			return
		C.forceMove(loc)


/obj/item/moneybag/vault/Initialize(mapload)
	. = ..()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
