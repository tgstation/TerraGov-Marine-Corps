/obj/item/paper/scroll
	name = "papyrus"
	icon_state = "scroll"
	var/open = FALSE
	slot_flags = null
	dropshrink = 0.6
	firefuel = 30 SECONDS
	sellprice = 2
	textper = 108
	maxlen = 2000
	throw_range = 3


/obj/item/paper/scroll/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/natural/thorn) || istype(P, /obj/item/natural/feather))
		if(!open)
			to_chat(user, "<span class='warning'>Open me.</span>")
			return
	..()

/obj/item/paper/scroll/getonmobprop(tag)
	. = ..()
	if(tag)
		if(open)
			switch(tag)
				if("gen")
					return list("shrink" = 0.3,"sx" = 0,"sy" = -1,"nx" = 13,"ny" = -1,"wx" = 4,"wy" = 0,"ex" = 7,"ey" = -1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 2,"sflip" = 0,"wflip" = 0,"eflip" = 8)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
		else
			switch(tag)
				if("gen")
					return list("shrink" = 0.4,"sx" = 0,"sy" = 0,"nx" = 13,"ny" = 1,"wx" = 0,"wy" = 2,"ex" = 5,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 63,"wturn" = -27,"eturn" = 63,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
				if("onbelt")
					return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/paper/scroll/attack_self(mob/user)
	if(mailer)
		user.visible_message("<span class='notice'>[user] opens the missive from [mailer].</span>")
		mailer = null
		mailedto = null
		update_icon()
		return
	if(!open)
		attack_right(user)
		return
	..()
	user.update_inv_hands()

/obj/item/paper/scroll/read(mob/user)
	if(!open)
		to_chat(user, "<span class='info'>Open me.</span>")
		return
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	/*font-size: 125%;*/
	if(in_range(user, src) || isobserver(user))
		user.hud_used.reads.icon_state = "scroll"
		user.hud_used.reads.show()
		var/dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
					<html><head><style type=\"text/css\">
					body { background-image:url('book.png');background-repeat: repeat; }</style></head><body scroll=yes>"}
		dat += "[info]<br>"
		dat += "<a href='?src=[REF(src)];close=1' style='position:absolute;right:50px'>Close</a>"
		dat += "</body></html>"
		user << browse(dat, "window=reading;size=460x300;can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0")
		onclose(user, "reading", src)
	else
		return "<span class='warning'>I'm too far away to read it.</span>"

/obj/item/paper/scroll/Initialize()
	open = FALSE
	update_icon_state()
	..()

/obj/item/paper/scroll/rmb_self(mob/user)
	attack_right(user)
	return

/obj/item/paper/scroll/attack_right(mob/user)
	if(open)
		slot_flags |= ITEM_SLOT_HIP
		open = FALSE
		playsound(src, 'sound/items/scroll_close.ogg', 100, FALSE)
	else
		slot_flags &= ~ITEM_SLOT_HIP
		open = TRUE
		playsound(src, 'sound/items/scroll_open.ogg', 100, FALSE)
	update_icon_state()
	user.update_inv_hands()

/obj/item/paper/scroll/update_icon_state()
	if(mailer)
		icon_state = "scroll_prep"
		open = FALSE
		name = "missive"
		slot_flags |= ITEM_SLOT_HIP
		throw_range = 7
		return
	throw_range = initial(throw_range)
	if(open)
		if(info)
			icon_state = "scrollwrite"
		else
			icon_state = "scroll"
		name = initial(name)
	else
		icon_state = "scroll_closed"
		name = "scroll"

/obj/item/paper/scroll/cargo
	name = "shipping order"
	icon_state = "contractunsigned"
	var/signedname
	var/signedjob
	var/list/orders = list()
	open = TRUE
	textper = 150

/obj/item/paper/scroll/cargo/Destroy()
	for(var/datum/supply_order/SO in orders)
		orders -= SO
	return ..()

/obj/item/paper/scroll/cargo/examine(mob/user)
	. = ..()
//	if(signedname)
//		. += "It was signed by [signedname] the [signedjob]."

	//for each order, add up total price and display orders

/obj/item/paper/scroll/cargo/update_icon_state()
	if(open)
		if(signedname)
			icon_state = "contractsigned"
		else
			icon_state = "contractunsigned"
		name = initial(name)
	else
		icon_state = "scroll_closed"
		name = "scroll"


/obj/item/paper/scroll/cargo/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/natural/feather))
		if(user.is_literate() && open)
			if(signedname)
				to_chat(user, "<span class='warning'>[signedname]</span>")
				return
			switch(alert("Sign your name?",,"Yes","No"))
				if("Yes")
					if(user.mind && user.mind.assigned_role)
						if(do_after(user, 20, target = src))
							signedname = user.real_name
							signedjob = user.mind.assigned_role
							icon_state = "contractsigned"
							user.visible_message("<span class='notice'>[user] signs the [src].</span>")
							update_icon_state()
							playsound(src, 'sound/items/write.ogg', 100, FALSE)
							rebuild_info()
				if("No")
					return

/obj/item/paper/scroll/cargo/proc/rebuild_info()
	info = null
	info += "<h2>Shipping Order</h2>"
	info += "<hr/>"

	if(orders.len)
		info += "Orders: <br/>"
		info += "<ul>"
		for(var/datum/supply_order/A in orders)
			info += "<li>[A.pack.name]</li><br/>"
		info += "</ul>"

	info += "<br/></font>"

	if(signedname)
		info += "SIGNED,<br/>"
		info += "<font face=\"[FOUNTAIN_PEN_FONT]\" color=#27293f>[signedname] the [signedjob] of Rockhill</font>"

/obj/item/paper/confession
	name = "confession"
	icon_state = "confession"
	info = "THE GUILTY PARTY ADMITS THEIR SIN AND THE WEAKENING OF PSYDON'S HOLY FLOCK. THEY WILL REPENT AND SUBMIT TO ANY PUNISHMENT THE CLERGY DEEMS APPROPRIATE, OR BE RELEASED IMMEDIATELY. LET THIS RECORD OF THEIR SIN WEIGH ON THE ANGEL GABRIEL'S JUDGEMENT AT THE MANY-SPIKED GATES OF HEAVEN.<br/><br/>SIGNED,"
	var/signed = FALSE
	textper = 150

/obj/item/paper/confession/update_icon_state()
	if(mailer)
		icon_state = "paper_prep"
		name = "letter"
		throw_range = 7
		return
	name = initial(name)
	throw_range = initial(throw_range)
	if(signed)
		icon_state = "confessionsigned"
		return
	icon_state = "confession"

/obj/item/paper/confession/attack(mob/living/carbon/human/M, mob/user)
	if(signed)
		return ..()
	if(!M.get_bleed_rate())
		to_chat(user, "<span class='warning'>No. The sinner must be bleeding.</span>")
		return
	if(!M.stat)
		to_chat(user, "<span class='info'>I courteously offer the confession to [M].</span>")
		if(alert(M, "Sign the confession with your blood?", "CONFESSION OF SIN", "Yes", "No") != "Yes")
			return
		if(M.stat)
			return
		if(signed)
			return
		if(M.has_flaw(/datum/charflaw/addiction/godfearing))
			M.add_stress(/datum/stressevent/confessedgood)
		else
			M.add_stress(/datum/stressevent/confessed)
		signed = M.real_name
		info = "THE GUILTY PARTY ADMITS THEIR SIN AND THE WEAKENING OF PSYDON'S HOLY FLOCK. THEY WILL REPENT AND SUBMIT TO ANY PUNISHMENT THE CLERGY DEEMS APPROPRIATE, OR BE RELEASED IMMEDIATELY. LET THIS RECORD OF THEIR SIN WEIGH ON THE ANGEL GABRIEL'S JUDGEMENT AT THE MANY-SPIKED GATES OF HEAVEN.<br/><br/>SIGNED,<br/><font color='red'>[signed]</font>"
