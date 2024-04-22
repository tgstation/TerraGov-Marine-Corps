/obj/structure/roguemachine/stockpile
	name = "stockpile"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "stockpile_vendor"
	density = FALSE
	blade_dulling = DULLING_BASH
	pixel_y = 32
	var/budget = 0

/proc/stock_announce(message)
	for(var/obj/structure/roguemachine/stockpile/S in SSroguemachine.stock_machines)
		S.say(message, spans = list("info"))

/obj/structure/roguemachine/stockpile/Initialize()
	. = ..()
	SSroguemachine.stock_machines += src

/obj/structure/roguemachine/stockpile/Destroy()
	SSroguemachine.stock_machines -= src
	return ..()

/obj/structure/roguemachine/stockpile/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguecoin))
		budget += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		return attack_hand(user)
	..()

/obj/structure/roguemachine/stockpile/Topic(href, href_list)
	. = ..()
	if(!usr.canUseTopic(src, BE_CLOSE))
		return
	if(href_list["withdraw"])
		var/datum/roguestock/D = locate(href_list["withdraw"]) in SStreasury.stockpile_datums
		if(!D)
			return
		if(D.withdraw_disabled)
			return
		if(D.held_items <= 0)
			say("Insufficient stock.")
			return
		if(D.withdraw_price > budget)
			say("Insufficient mammon.")
		else
			D.held_items--
			budget -= D.withdraw_price
			SStreasury.give_money_treasury(D.withdraw_price, "stockpile withdraw")
			var/obj/item/I = new D.item_type(loc)
			var/mob/user = usr
			if(!user.put_in_hands(I))
				I.forceMove(get_turf(user))
			playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	if(href_list["change"])
		if(!usr.canUseTopic(src, BE_CLOSE))
			return
		if(ishuman(usr))
			if(budget > 0)
				budget2change(budget, usr)
				budget = 0
	return attack_hand(usr)

/obj/structure/roguemachine/stockpile/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)
	var/canread = user.can_read(src, TRUE)
	var/contents
	contents += "<center>TOWN STOCKPILE<BR>"
	contents += "--------------<BR>"
	contents += "<a href='?src=[REF(src)];change=1'>Stored Mammon: [budget]</a></center><BR>"
	for(var/datum/roguestock/stockpile/A in SStreasury.stockpile_datums)
		contents += "[A.name]<BR>"
		contents += "[A.desc]<BR>"
		contents += "Stockpiled Amount: [A.held_items]<BR>"
		if(!A.withdraw_disabled)
			contents += "<a href='?src=[REF(src)];withdraw=[REF(A)]'>\[Withdraw ([A.withdraw_price])\]</a><BR><BR>"
		else
			contents += "Withdrawing Disabled...<BR><BR>"
	if(!canread)
		contents = stars(contents)
	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 220)
	popup.set_content(contents)
	popup.open()
