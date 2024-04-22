/obj/structure/roguemachine/vendor
	name = "PEDDLER"
	desc = "The stomach of this thing can been stuffed with fun things for you to buy."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "streetvendor1"
	density = TRUE
	blade_dulling = DULLING_BASH
	integrity_failure = 0.1
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/list/held_items = list()
	var/locked = TRUE
	var/budget = 0
	var/wgain = 0
	var/keycontrol = "merchant"
	var/funynthing = FALSE

/obj/structure/roguemachine/vendor/attackby(obj/item/P, mob/user, params)

	if(istype(P, /obj/item/roguekey))
		var/obj/item/roguekey/K = P
		if(K.lockid == keycontrol)
			locked = !locked
			playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
			update_icon()
			return attack_hand(user)
		else
			to_chat(user, "<span class='warning'>Wrong key.</span>")
			return
	if(istype(P, /obj/item/keyring))
		var/obj/item/keyring/K = P
		for(var/obj/item/roguekey/KE in K.keys)
			if(KE.lockid == keycontrol)
				locked = !locked
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
				update_icon()
				return attack_hand(user)
	if(istype(P, /obj/item/roguecoin))
		budget += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		return attack_hand(user)
	if(!locked)
		if(P.w_class <= WEIGHT_CLASS_BULKY)
			testing("startadd")
			if(held_items.len < 15)
				held_items[P] = list()
				held_items[P]["NAME"] = P.name
				held_items[P]["PRICE"] = 0
				P.forceMove(src)
				playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
				return attack_hand(user)
			else
				to_chat(user, "<span class='warning'>Full.</span>")
				return
	..()


/obj/structure/roguemachine/vendor/Topic(href, href_list)
	. = ..()
	if(href_list["buy"])
		var/obj/item/O = locate(href_list["buy"]) in held_items
		if(!O || !istype(O))
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || !locked)
			return
		if(ishuman(usr))
			if(held_items[O]["PRICE"])
				if(budget >= held_items[O]["PRICE"])
					budget -= held_items[O]["PRICE"]
					wgain += held_items[O]["PRICE"]
				else
					say("NO MONEY NO HONEY!")
					return
			held_items -= O
			if(!usr.put_in_hands(O))
				O.forceMove(get_turf(src))
			update_icon()
	if(href_list["retrieve"])
		var/obj/item/O = locate(href_list["retrieve"]) in held_items
		if(!O || !istype(O))
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		if(ishuman(usr))
			held_items -= O
			if(!usr.put_in_hands(O))
				O.forceMove(get_turf(src))
			update_icon()
	if(href_list["change"])
		if(!usr.canUseTopic(src, BE_CLOSE) || !locked)
			return
		if(ishuman(usr))
			if(budget > 0)
				budget2change(budget, usr)
				budget = 0
	if(href_list["withdrawgain"])
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		if(ishuman(usr))
			if(wgain > 0)
				budget2change(wgain, usr)
				wgain = 0
	if(href_list["setname"])
		var/obj/item/O = locate(href_list["setname"]) in held_items
		if(!O || !istype(O))
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		if(ishuman(usr))
			var/prename
			if(held_items[O]["NAME"])
				prename = held_items[O]["NAME"]
			var/newname = input(usr, "SET A NEW NAME FOR THIS PRODUCT", src, prename)
			if(newname)
				held_items[O]["NAME"] = newname
	if(href_list["setprice"])
		var/obj/item/O = locate(href_list["setprice"]) in held_items
		if(!O || !istype(O))
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		if(ishuman(usr))
			var/preprice
			if(held_items[O]["PRICE"])
				preprice = held_items[O]["PRICE"]
			var/newprice = input(usr, "SET A NEW PRICE FOR THIS PRODUCT", src, preprice) as null|num
			if(newprice)
				if(findtext(num2text(newprice), "."))
					return attack_hand(usr)
				held_items[O]["PRICE"] = newprice
	return attack_hand(usr)

/obj/structure/roguemachine/vendor/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	var/canread = user.can_read(src, TRUE)
	var/contents
	if(canread)
		contents = "<center>THE PEDDLER, THIRD ITERATION<BR>"
		if(locked)
			contents += "<a href='?src=[REF(src)];change=1'>Stored Mammon:</a> [budget]<BR>"
		else
			contents += "<a href='?src=[REF(src)];withdrawgain=1'>Stored Profits:</a> [wgain]<BR>"
	else
		contents = "<center>[stars("THE PEDDLER, THIRD ITERATION")]<BR>"
		if(locked)
			contents += "<a href='?src=[REF(src)];change=1'>[stars("Stored Mammon:")]</a> [budget]<BR>"
		else
			contents += "<a href='?src=[REF(src)];withdrawgain=1'>[stars("Stored Profits:")]</a> [wgain]<BR>"

	contents += "</center>"

	for(var/I in held_items)
		var/price = held_items[I]["PRICE"]
		var/namer = held_items[I]["NAME"]
		if(!price)
			price = "0"
		if(!namer)
			held_items[I]["NAME"] = "thing"
			namer = "thing"
		if(locked)
			if(canread)
				contents += "[icon2html(I, user)] [namer] - [price] <a href='?src=[REF(src)];buy=[REF(I)]'>BUY</a>"
			else
				contents += "[icon2html(I, user)] [stars(namer)] - [price] <a href='?src=[REF(src)];buy=[REF(I)]'>[stars("BUY")]</a>"
		else
			if(canread)
				contents += "[icon2html(I, user)] <a href='?src=[REF(src)];setname=[REF(I)]'>[namer]</a> - <a href='?src=[REF(src)];setprice=[REF(I)]'>[price]</a> <a href='?src=[REF(src)];retrieve=[REF(I)]'>TAKE</a>"
			else
				contents += "[icon2html(I, user)] <a href='?src=[REF(src)];setname=[REF(I)]'>[stars(namer)]</a> - <a href='?src=[REF(src)];setprice=[REF(I)]'>[price]</a> <a href='?src=[REF(src)];retrieve=[REF(I)]'>[stars("TAKE")]</a>"
		contents += "<BR>"

	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 220)
	popup.set_content(contents)
	popup.open()

/obj/structure/roguemachine/vendor/obj_break(damage_flag)
	..()
	for(var/obj/item/I in held_items)
		I.forceMove(src.loc)
		held_items -= I
	budget2change(budget)
	set_light(0)
	update_icon()
	icon_state = "streetvendor0"

/obj/structure/roguemachine/vendor/Initialize()
	. = ..()
	update_icon()

/obj/structure/roguemachine/vendor/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	if(!locked)
		icon_state = "streetvendor0"
		return
	else
		icon_state = "streetvendor1"
	if(held_items.len)
		set_light(1, 1, "#1b7bf1")
		add_overlay(mutable_appearance(icon, "vendor-gen"))

/obj/structure/roguemachine/vendor/Destroy()
	for(var/obj/item/I in held_items)
		I.forceMove(src.loc)
		held_items -= I
	set_light(0)
	return ..()

/obj/structure/roguemachine/vendor/centcom
	name = "LANDLORD"
	desc = "Give this thing money, and you will immediately buy a neat property in the capital."
	max_integrity = 0
	icon_state = "streetvendor1"
	keycontrol = "dhjlashfdg"
	var/list/cachey = list()

/obj/structure/roguemachine/vendor/centcom/attack_hand(mob/living/user)
	return

/obj/structure/roguemachine/vendor/centcom/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguecoin))
		if(!cachey[user])
			cachey[user] = list()
		cachey[user]["moneydonate"] += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)

		if(cachey[user]["moneydonate"] > 99)
			if(!cachey[user]["trisawarded"])
				cachey[user]["trisawarded"] = 1
				user.adjust_triumphs(1)
				say("[user] has purchased a prole dwelling.")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
		if(cachey[user]["moneydonate"] > 499)
			if(cachey[user]["trisawarded"] < 2)
				cachey[user]["trisawarded"] = 2
				user.adjust_triumphs(1)
				say("[user] has been upgraded to a space in a serf apartment.")
				playsound(src, pick('sound/misc/machinetalk.ogg'), 100, FALSE, -1)
		if(cachey[user]["moneydonate"] > 999)
			if(cachey[user]["trisawarded"] < 3)
				cachey[user]["trisawarded"] = 3
				user.adjust_triumphs(1)
				say("[user] HAS BEEN UPGRADED TO A NOBLE BEDCHAMBER!")
				playsound(src, 'sound/misc/machinelong.ogg', 100, FALSE, -1)

/obj/structure/roguemachine/vendor/inn
	keycontrol = "tavern"

/obj/structure/roguemachine/vendor/inn/Initialize()
	. = ..()
	for(var/X in list(/obj/item/roguekey/roomi,/obj/item/roguekey/roomii,/obj/item/roguekey/roomiii,/obj/item/roguekey/roomiv,/obj/item/roguekey/roomv,/obj/item/roguekey/roomvi))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 10
	update_icon()
