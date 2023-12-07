/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "clipboard"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/civilian_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/civilian_right.dmi',
	)
	item_state = "clipboard"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10
	var/obj/item/tool/pen/haspen		//The stored pen.
	var/obj/item/toppaper	//The topmost piece of paper.
	flags_equip_slot = ITEM_SLOT_BELT

/obj/item/clipboard/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clipboard/MouseDrop(obj/over_object as obj) //Quick clipboard fix. -Agouri
	if(ishuman(usr))
		var/mob/M = usr
		if(!(istype(over_object, /atom/movable/screen) ))
			return ..()

		if(!M.restrained() && !M.stat)
			switch(over_object.name)
				if("r_hand")
					M.dropItemToGround(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.dropItemToGround(src)
					M.put_in_l_hand(src)

			return

/obj/item/clipboard/update_icon()
	overlays.Cut()
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	if(haspen)
		overlays += "clipboard_pen"
	overlays += "clipboard_over"


/obj/item/clipboard/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo))
		user.drop_held_item()
		I.forceMove(src)
		if(istype(I, /obj/item/paper))
			toppaper = I
		to_chat(user, span_notice("You clip the [I] onto \the [src]."))
		update_icon()

	else if(istype(toppaper) && istype(I, /obj/item/tool/pen))
		toppaper.attackby(I, user, params)
		update_icon()


/obj/item/clipboard/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if(haspen)
		dat += "<A href='?src=[text_ref(src)];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='?src=[text_ref(src)];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. I don't think there's any way to organise contents in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/paper/P = toppaper
		dat += "<A href='?src=[text_ref(src)];write=[text_ref(P)]'>Write</A> <A href='?src=[text_ref(src)];remove=[text_ref(P)]'>Remove</A> - <A href='?src=[text_ref(src)];read=[text_ref(P)]'>[P.name]</A><BR><HR>"

	for(var/obj/item/paper/P in src)
		if(P==toppaper)
			continue
		dat += "<A href='?src=[text_ref(src)];remove=[text_ref(P)]'>Remove</A> - <A href='?src=[text_ref(src)];read=[text_ref(P)]'>[P.name]</A><BR>"
	for(var/obj/item/photo/Ph in src)
		dat += "<A href='?src=[text_ref(src)];remove=[text_ref(Ph)]'>Remove</A> - <A href='?src=[text_ref(src)];look=[text_ref(Ph)]'>[Ph.name]</A><BR>"

	var/datum/browser/popup = new(user, "clipboard", "<div align='center'>Clipboard</div>")
	popup.set_content(dat)
	popup.open()


/obj/item/clipboard/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(src.loc == usr)

		if(href_list["pen"])
			if(istype(haspen) && (haspen.loc == src))
				haspen.loc = usr.loc
				usr.put_in_hands(haspen)
				haspen = null

		else if(href_list["addpen"])
			if(!haspen)
				var/obj/item/tool/pen/W = usr.get_active_held_item()
				if(istype(W, /obj/item/tool/pen))
					if(usr.drop_held_item())
						W.forceMove(src)
						haspen = W
						to_chat(usr, span_notice("You slot the pen into \the [src]."))

		else if(href_list["write"])
			var/obj/item/P = locate(href_list["write"])

			if(P && (P.loc == src) && istype(P, /obj/item/paper) && (P == toppaper) )

				var/obj/item/I = usr.get_active_held_item()

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

				if(!(ishuman(usr) || isobserver(usr) || issilicon(usr)))
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
				to_chat(usr, span_notice("You move [P.name] to the top."))

		//Update everything
		attack_self(usr)
		update_icon()

