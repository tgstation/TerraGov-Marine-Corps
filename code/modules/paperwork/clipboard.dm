/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 10
	var/obj/item/tool/pen/haspen		//The stored pen.
	var/obj/item/toppaper	//The topmost piece of paper.
	flags_equip_slot = SLOT_WAIST

/obj/item/clipboard/New()
	update_icon()

/obj/item/clipboard/MouseDrop(obj/over_object as obj) //Quick clipboard fix. -Agouri
	if(ishuman(usr))
		var/mob/M = usr
		if(!(istype(over_object, /obj/screen) ))
			return ..()

		if(!M.is_mob_restrained() && !M.stat)
			switch(over_object.name)
				if("r_hand")
					M.drop_inv_item_on_ground(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.drop_inv_item_on_ground(src)
					M.put_in_l_hand(src)

			add_fingerprint(usr)
			return

/obj/item/clipboard/update_icon()
	overlays.Cut()
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	if(haspen)
		overlays += "clipboard_pen"
	overlays += "clipboard_over"
	return

/obj/item/clipboard/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo))
		user.drop_held_item()
		W.forceMove(src)
		if(istype(W, /obj/item/paper))
			toppaper = W
		user << "<span class='notice'>You clip the [W] onto \the [src].</span>"
		update_icon()

	else if(istype(toppaper) && istype(W, /obj/item/tool/pen))
		toppaper.attackby(W, usr)
		update_icon()

	return

/obj/item/clipboard/attack_self(mob/user as mob)
	var/dat = "<title>Clipboard</title>"
	if(haspen)
		dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. I don't think there's any way to organise contents in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/paper/P = toppaper
		dat += "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR><HR>"

	for(var/obj/item/paper/P in src)
		if(P==toppaper)
			continue
		dat += "<A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/photo/Ph in src)
		dat += "<A href='?src=\ref[src];remove=\ref[Ph]'>Remove</A> - <A href='?src=\ref[src];look=\ref[Ph]'>[Ph.name]</A><BR>"

	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	add_fingerprint(usr)
	return

/obj/item/clipboard/Topic(href, href_list)
	..()
	if((usr.stat || usr.is_mob_restrained()))
		return

	if(src.loc == usr)

		if(href_list["pen"])
			if(istype(haspen) && (haspen.loc == src))
				haspen.loc = usr.loc
				usr.put_in_hands(haspen)
				haspen = null

		else if(href_list["addpen"])
			if(!haspen)
				var/obj/item/tool/pen/W = usr.get_active_hand()
				if(istype(W, /obj/item/tool/pen))
					if(usr.drop_held_item())
						W.forceMove(src)
						haspen = W
						usr << "<span class='notice'>You slot the pen into \the [src].</span>"

		else if(href_list["write"])
			var/obj/item/P = locate(href_list["write"])

			if(P && (P.loc == src) && istype(P, /obj/item/paper) && (P == toppaper) )

				var/obj/item/I = usr.get_active_hand()

				if(istype(I, /obj/item/tool/pen))

					P.attackby(I, usr)

		else if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])

			if(P && (P.loc == src) && (istype(P, /obj/item/paper) || istype(P, /obj/item/photo)) )

				P.loc = usr.loc
				usr.put_in_hands(P)
				if(P == toppaper)
					toppaper = null
					var/obj/item/paper/newtop = locate(/obj/item/paper) in src
					if(newtop && (newtop != P))
						toppaper = newtop
					else
						toppaper = null

		else if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])

			if(P && (P.loc == src) && istype(P, /obj/item/paper) )

				if(!(istype(usr, /mob/living/carbon/human) || istype(usr, /mob/dead/observer) || istype(usr, /mob/living/silicon)))
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")

		else if(href_list["look"])
			var/obj/item/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P, /obj/item/photo) )
				P.show(usr)

		else if(href_list["top"]) // currently unused
			var/obj/item/P = locate(href_list["top"])
			if(P && (P.loc == src) && istype(P, /obj/item/paper) )
				toppaper = P
				usr << "<span class='notice'>You move [P.name] to the top.</span>"

		//Update everything
		attack_self(usr)
		update_icon()
	return
