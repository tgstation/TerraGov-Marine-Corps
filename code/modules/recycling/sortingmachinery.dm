GLOBAL_LIST_EMPTY(tagger_locations)

// todo replace me with tg code and uncamelcase me
/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycloset"
	var/obj/wrapped = null
	density = TRUE
	var/sortTag = null
	var/examtext = null
	var/nameset = 0
	var/label_y
	var/label_x
	var/tag_x

/obj/structure/bigDelivery/attack_hand(mob/user as mob)
	if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = (get_turf(src.loc))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = 0
	qdel(src)
	return

/obj/structure/bigDelivery/update_icon()
	overlays = new()
	if(nameset || examtext)
		var/image/I = new/image('icons/obj/items/storage/storage.dmi',"delivery_label")
		if(icon_state == "deliverycloset")
			I.pixel_x = 2
			if(label_y == null)
				label_y = rand(-6, 11)
			I.pixel_y = label_y
		else if(icon_state == "deliverycrate")
			if(label_x == null)
				label_x = rand(-8, 6)
			I.pixel_x = label_x
			I.pixel_y = -3
		overlays += I
	if(src.sortTag)
		var/image/I = new/image('icons/obj/items/storage/storage.dmi',"delivery_tag")
		if(icon_state == "deliverycloset")
			if(tag_x == null)
				tag_x = rand(-2, 3)
			I.pixel_x = tag_x
			I.pixel_y = 9
		else if(icon_state == "deliverycrate")
			if(tag_x == null)
				tag_x = rand(-8, 6)
			I.pixel_x = tag_x
			I.pixel_y = -3
		overlays += I

/obj/structure/bigDelivery/examine(mob/user)
	..()
	if(get_dist(src, user) <= 4)
		if(sortTag)
			to_chat(user, span_notice("It is labeled \"[sortTag]\""))
		if(examtext)
			to_chat(user, span_notice("It has a note attached which reads, \"[examtext]\""))
	return

/obj/structure/bigDelivery/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	attack_hand(X)

/obj/structure/bigDelivery/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I
		if(!O.currTag)
			to_chat(user, span_warning("You need to set a destination first!"))
			return

		if(sortTag == O.currTag)
			to_chat(user, span_warning("The package is already labeled for [O.currTag]."))
			return

		to_chat(user, span_notice("You have labeled the destination as [O.currTag]."))
		if(!sortTag)
			sortTag = O.currTag
			update_icon()
		else
			sortTag = O.currTag
		playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)

	else if(istype(I, /obj/item/tool/pen))
		switch(tgui_alert(user, "What would you like to alter?", "Label", list("Title", "Description", "Cancel")))
			if("Title")
				var/str = stripped_input(user, "Label text?", "Set label", max_length = MAX_NAME_LEN)
				if(!str)
					to_chat(user, span_warning("Invalid text."))
					return
				user.visible_message("\The [user] titles \the [src] with \a [I], marking down: \"[str]\"",\
				span_notice("You title \the [src]: \"[str]\""),\
				"You hear someone scribbling a note.")
				name = "[name] ([str])"
				if(!examtext && !nameset)
					nameset = TRUE
					update_icon()
				else
					nameset = TRUE
			if("Description")
				var/str = stripped_input(user, "Label text?", "Set label", max_length = MAX_NAME_LEN)
				if(!str)
					to_chat(user, span_warning("Invalid text."))
					return
				if(!examtext && !nameset)
					examtext = str
					update_icon()
				else
					examtext = str
				user.visible_message("\The [user] labels \the [src] with \a [I], scribbling down: \"[examtext]\"",\
				span_notice("You label \the [src]: \"[examtext]\""),\
				"You hear someone scribbling a note.")


/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "deliverycrate3"
	var/obj/item/wrapped = null
	var/sortTag = null
	var/examtext = null
	var/nameset = 0
	var/tag_x

/obj/item/smallDelivery/attack_self(mob/user as mob)
	if (src.wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = user.loc
		if(ishuman(user))
			user.put_in_hands(wrapped)
		else
			wrapped.loc = get_turf(src)

	qdel(src)
	return

/obj/item/smallDelivery/update_icon()
	overlays = new()
	if((nameset || examtext) && icon_state != "deliverycrate1")
		var/image/I = new/image('icons/obj/items/storage/storage.dmi',"delivery_label")
		if(icon_state == "deliverycrate5")
			I.pixel_y = -1
		overlays += I
	if(src.sortTag)
		var/image/I = new/image('icons/obj/items/storage/storage.dmi',"delivery_tag")
		switch(icon_state)
			if("deliverycrate1")
				I.pixel_y = -5
			if("deliverycrate2")
				I.pixel_y = -2
			if("deliverycrate3")
				I.pixel_y = 0
			if("deliverycrate4")
				if(tag_x == null)
					tag_x = rand(0,5)
				I.pixel_x = tag_x
				I.pixel_y = 3
			if("deliverycrate5")
				I.pixel_y = -3
		overlays += I

/obj/item/smallDelivery/examine(mob/user)
	..()
	if(get_dist(src, user) <= 4)
		if(sortTag)
			to_chat(user, span_notice("It is labeled \"[sortTag]\""))
		if(examtext)
			to_chat(user, span_notice("It has a note attached which reads, \"[examtext]\""))

/obj/item/smallDelivery/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I
		if(!O.currTag)
			to_chat(user, span_warning("You need to set a destination first!"))
			return

		if(sortTag == O.currTag)
			to_chat(user, span_warning("The package is already labeled for [O.currTag]."))
			return

		to_chat(user, span_notice("You have labeled the destination as [O.currTag]."))
		if(!sortTag)
			sortTag = O.currTag
			update_icon()
		else
			sortTag = O.currTag
		playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)

	else if(istype(I, /obj/item/tool/pen))
		switch(tgui_alert(user, "What would you like to alter?", "Label", list("Title", "Description", "Cancel")))
			if("Title")
				var/str = stripped_input(user, "Label text?", "Set label", max_length = MAX_NAME_LEN)
				if(!str)
					to_chat(user, span_warning("Invalid text."))
					return
				user.visible_message("\The [user] titles \the [src] with \a [I], marking down: \"[str]\"",\
				span_notice("You title \the [src]: \"[str]\""),\
				"You hear someone scribbling a note.")
				name = "[name] ([str])"
				if(!examtext && !nameset)
					nameset = TRUE
					update_icon()
				else
					nameset = TRUE
			if("Description")
				var/str = stripped_input(user, "Label text?", "Set label", max_length = MAX_NAME_LEN)
				if(!str)
					to_chat(user, span_warning("Invalid text."))
					return
				if(!examtext && !nameset)
					examtext = str
					update_icon()
				else
					examtext = str
				user.visible_message("\The [user] labels \the [src] with \a [I], scribbling down: \"[examtext]\"",\
				span_notice("You label \the [src]: \"[examtext]\""),\
				"You hear someone scribbling a note.")


/obj/item/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "deliveryPaper"
	w_class = WEIGHT_CLASS_NORMAL
	var/amount = 25


/obj/item/packageWrap/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
	|| istype(target, /obj/item/gift) || istype(target, /obj/item/evidencebag))
		return
	if(target.anchored)
		return
	if(target in user)
		return
	if(user in target) //no wrapping closets that you are inside - it's not physically possible
		return

	log_combat(user, target, "used", src)


	if (istype(target, /obj/item) && !(istype(target, /obj/item/storage) && !istype(target,/obj/item/storage/box)))
		var/obj/item/O = target
		if (src.amount > 1)
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
			if(!istype(O.loc, /turf))
				if(user.client)
					user.client.screen -= O
			P.wrapped = O
			O.loc = P
			var/i = round(O.w_class)
			if(i in list(1,2,3,4,5))
				P.icon_state = "deliverycrate[i]"
				switch(i)
					if(1) P.name = "tiny parcel"
					if(3) P.name = "normal-sized parcel"
					if(4) P.name = "large parcel"
					if(5) P.name = "huge parcel"
			if(i < 1)
				P.icon_state = "deliverycrate1"
				P.name = "tiny parcel"
			if(i > 5)
				P.icon_state = "deliverycrate5"
				P.name = "huge parcel"
			src.amount -= 1
			user.visible_message("\The [user] wraps \a [target] with \a [src].",\
			span_notice("You wrap \the [target], leaving [amount] units of paper on \the [src]."),\
			"You hear someone taping paper around a small object.")
	else if (istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/O = target
		if (src.amount > 3 && !O.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.icon_state = "deliverycrate"
			P.wrapped = O
			O.loc = P
			src.amount -= 3
			user.visible_message("\The [user] wraps \a [target] with \a [src].",\
			span_notice("You wrap \the [target], leaving [amount] units of paper on \the [src]."),\
			"You hear someone taping paper around a large object.")
		else if(src.amount < 3)
			to_chat(user, span_warning("You need more paper."))
	else if (istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if (src.amount > 3 && !O.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.wrapped = O
			O.welded = 1
			O.loc = P
			src.amount -= 3
			user.visible_message("\The [user] wraps \a [target] with \a [src].",\
			span_notice("You wrap \the [target], leaving [amount] units of paper on \the [src]."),\
			"You hear someone taping paper around a large object.")
		else if(src.amount < 3)
			to_chat(user, span_warning("You need more paper."))
	else
		to_chat(user, span_notice("The object you are trying to wrap is unsuitable for the sorting machinery!"))
	if (src.amount <= 0)
		new /obj/item/trash/c_tube( src.loc )
		qdel(src)
		return
	return

/obj/item/packageWrap/examine(mob/user)
	..()
	if(get_dist(src, user) < 2)
		to_chat(user, span_notice("There are [amount] units of package wrap left!"))


/obj/item/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger"
	var/currTag = 0

	w_class = WEIGHT_CLASS_SMALL
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	item_state = "electronic"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT

/obj/item/destTagger/proc/openwindow(mob/user as mob)
	var/dat

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for(var/i in 1 to length(GLOB.tagger_locations))
		dat += "<td><a href='?src=[text_ref(src)];nextTag=[GLOB.tagger_locations[i]]'>[GLOB.tagger_locations[i]]</a></td>"

		if (i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? currTag : "None"]"

	var/datum/browser/popup = new(user, "destTagScreen", "<div align='center'>TagMaster 2.3</div>", 450, 350)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "destTagScreen")

/obj/item/destTagger/attack_self(mob/user as mob)
	openwindow(user)
	return

/obj/item/destTagger/Topic(href, href_list)
	if(href_list["nextTag"] && (href_list["nextTag"] in GLOB.tagger_locations))
		src.currTag = href_list["nextTag"]
	openwindow(usr)

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"

	var/c_mode = 0

/obj/machinery/disposal/deliveryChute/Initialize(mapload)
	. = ..()
	set_trunk(locate(/obj/structure/disposalpipe/trunk) in loc)
	if(trunk)
		trunk.set_linked(src)	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/AM) //Go straight into the chute
	if(istype(AM, /obj/projectile) || istype(AM, /obj/effect))
		return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != loc.y+1) return
		if(EAST)
			if(AM.loc.x != loc.x+1) return
		if(SOUTH)
			if(AM.loc.y != loc.y-1) return
		if(WEST)
			if(AM.loc.x != loc.x-1) return

	if(istype(AM, /obj))
		var/obj/O = AM
		O.loc = src
	else if(istype(AM, /mob))
		var/mob/M = AM
		M.loc = src
	flush()

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.

	sleep(1 SECONDS)
	playsound(src, 'sound/machines/disposalflush.ogg', 25, 0)
	sleep(0.5 SECONDS) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return

/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		c_mode = !c_mode
		if(c_mode)
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, "You remove the screws around the power connection.")
		else
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, "You attach the screws around the power connection.")

	else if(istype(I, /obj/item/tool/weldingtool) && c_mode)
		var/obj/item/tool/weldingtool/W = I

		if(!W.remove_fuel(0, user))
			to_chat(user, "You need more welding fuel to complete this task.")
			return

		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		to_chat(user, "You start slicing the floorweld off the delivery chute.")

		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(W, /obj/item/tool/weldingtool/proc/isOn)))
			return

		to_chat(user, "You sliced the floorweld off the delivery chute.")
		var/obj/structure/disposalconstruct/C = new(loc)
		C.ptype = 8 // 8 = Delivery chute
		C.update()
		C.anchored = TRUE
		C.density = TRUE
		qdel(src)
