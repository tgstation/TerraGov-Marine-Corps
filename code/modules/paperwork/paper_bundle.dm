/obj/item/paper_bundle
	name = "paper bundle"
	gender = PLURAL
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/civilian_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/civilian_right.dmi',
	)
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 2
	throw_speed = 1
	layer = MOB_LAYER
	attack_verb = list("bapped")
	var/amount = 0 //Amount of items clipped to the paper
	var/page = 1
	var/screen = 0

/obj/item/paper_bundle/attackby(obj/item/I, mob/user, params)
	. = ..()


	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I

		if(istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if(!C.iscopy && !C.copied)
				to_chat(user, span_notice("Take off the carbon copy first."))
				return

		if(loc != user)
			return

		user.dropItemToGround(P)
		attach_doc(P, user)

	else if(istype(I, /obj/item/photo))
		if(loc != user)
			return

		user.dropItemToGround(I)
		attach_doc(I, user)

	else if(I.heat >= 400)
		burnpaper(I, user)

	else if(istype(I, /obj/item/paper_bundle))
		if(loc != user)
			return

		user.dropItemToGround(I)
		for(var/obj/O in I)
			attach_doc(O, user, TRUE)
		to_chat(user, span_notice("You add \the [I] to [src]."))
		qdel(I)

	else if(istype(I, /obj/item/tool/pen) || istype(I, /obj/item/toy/crayon))
		user << browse(null, "window=[name]") //Closes the dialog

	update_icon()
	attack_self(user) //Update the browsed page.


/obj/item/paper_bundle/proc/burnpaper(obj/item/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.heat >= 400 && !user.restrained())
		if(istype(P, /obj/item/tool/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like [user.p_theyre()] trying to burn it!</span>", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_held_item() == P && P.heat)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

				if(user.get_inactive_held_item() == src)
					user.dropItemToGround(src)

				new /obj/effect/decal/cleanable/ash(src.loc)
				qdel(src)

			else
				to_chat(user, span_warning("You must hold \the [P] steady to burn \the [src]."))

/obj/item/paper_bundle/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		attack_self(user)
	else
		. += span_notice("It is too far away to read.")

/obj/item/paper_bundle/attack_self(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		switch(screen)
			if(0)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[text_ref(src)];remove=1'>Remove [(istype(src[page], /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=[text_ref(src)];next_page=1'>Next Page</A></DIV><BR><HR>"
			if(1)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=[text_ref(src)];prev_page=1'>Previous Page</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[text_ref(src)];remove=1'>Remove [(istype(src[page], /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=[text_ref(src)];next_page=1'>Next Page</A></DIV><BR><HR>"
			if(2)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=[text_ref(src)];prev_page=1'>Previous Page</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[text_ref(src)];remove=1'>Remove [(istype(src[page], /obj/item/paper)) ? "paper" : "photo"]</A></DIV><BR><HR>"
				dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'></DIV>"
		if(istype(src[page], /obj/item/paper))
			var/obj/item/paper/P = src[page]
			if(!(ishuman(usr) || isobserver(usr) || issilicon(usr)))
				dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>"
			else
				dat+= "<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>"
			human_user << browse(dat, "window=[name]")
		else if(istype(src[page], /obj/item/photo))
			var/obj/item/photo/P = src[page]
			human_user << browse_rsc(P.picture.picture_icon, "tmp_photo.png")
			human_user << browse(dat + "<html><head><title>[P.name]</title></head>" \
			+ "<body style='overflow:hidden'>" \
			+ "<div> <img src='tmp_photo.png' width = '180'" \
			+ "[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : ""]"\
			+ "</body></html>", "window=[name]")
		update_icon()


/obj/item/paper_bundle/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if((src in usr.contents) || (istype(src.loc, /obj/item/folder) && (src.loc in usr.contents)))
		if(href_list["next_page"])
			if(page == amount-1)
				screen = 2
			else if(page == 1)
				screen = 1
			else if(page == amount)
				return
			page++
			playsound(src.loc, "pageturn", 15, 1)
		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount)
				screen = 1
			page--
			playsound(src.loc, "pageturn", 15, 1)
		if(href_list["remove"])
			var/obj/item/W = contents[page]
			usr.put_in_hands(W)
			to_chat(usr, span_notice("You remove the [W.name] from the bundle."))
			amount--
			if(amount == 1)
				var/obj/item/paper/P = contents[1]
				P.loc = usr.loc
				usr.dropItemToGround(src)
				qdel(src)
				usr.put_in_hands(P)
				return
			else if(page >= amount)
				screen = 2
				if(page > amount)
					page--

			update_icon()

		src.attack_self(src.loc)
		updateUsrDialog()
	else
		to_chat(usr, span_notice("You need to hold it in hands!"))

/obj/item/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	var/n_name = stripped_input(usr, "What would you like to label the bundle?", "Bundle Labelling")
	if((loc == usr && usr.stat == 0))
		name = "[(n_name ? "[n_name]" : "paper")]"

/obj/item/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	to_chat(usr, span_notice("You loosen the bundle."))
	for(var/obj/O in src)
		O.forceMove(usr.loc)
	usr.dropItemToGround(src)
	qdel(src)

/obj/item/paper_bundle/update_icon()
	if(length(contents))
		var/obj/item/I = contents[1]
		icon_state = I.icon_state
		overlays = I.overlays
	underlays = 0
	var/i = 0
	var/photo
	for(var/obj/O in src)
		var/image/IMG = image('icons/obj/items/paper.dmi')
		if(istype(O, /obj/item/paper))
			IMG.icon_state = O.icon_state
			IMG.pixel_x -= min(1*i, 2)
			IMG.pixel_y -= min(1*i, 2)
			pixel_x = min(0.5*i, 1)
			pixel_y = min(  1*i, 2)
			underlays += IMG
			i++
		else if(istype(O, /obj/item/photo))
			var/obj/item/photo/PH = O
			IMG = PH.picture.picture_icon
			photo = 1
			overlays += IMG
	if(i>1)
		desc = "[i] papers clipped to each other."
	else
		desc = "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	overlays += image('icons/obj/items/paper.dmi', "clip")

/obj/item/paper_bundle/proc/attach_doc(obj/item/I, mob/living/user, no_message)
	if(I.loc == user)
		user.dropItemToGround(I)
	I.forceMove(src)
	amount++
	if(!no_message)
		to_chat(user, span_notice("You add [I] to [src]."))
	if(screen == 2)
		screen = 1
	update_icon()
