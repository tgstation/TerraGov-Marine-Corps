/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "The ultimate in janitorial carts! Has space for water, mops, signs, trash bags, and more!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	drag_delay = 1
	coverage = 20
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 100
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag
	var/obj/item/tool/mop/mymop
	var/obj/item/reagent_containers/spray/myspray
	var/obj/item/lightreplacer/myreplacer
	var/obj/item/reagent_containers/glass/bucket/janibucket/mybucket
	var/signs = 0	//maximum capacity hardcoded below


/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	mybucket = new(src)
	update_icon()

/obj/structure/janitorialcart/examine(mob/user)
	. = ..()
	if(mybucket)
		. += "Its bucket contains [mybucket.reagents.total_volume] unit\s of liquid."
	else
		. += "It has no bucket."


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/storage/bag/trash) && !mybag)
		user.drop_held_item()
		mybag = I
		I.forceMove(src)
		update_icon()
		updateUsrDialog()
		to_chat(user, span_notice("You put [I] into [src]."))

	else if(istype(I, /obj/item/tool/mop))
		if(I.reagents.total_volume < I.reagents.maximum_volume && mybucket)	//if it's not completely soaked we assume they want to wet it, otherwise store it
			if(mybucket.reagents.total_volume < 1)
				to_chat(user, "[mybucket] is out of water!</span>")
				return

			mybucket.reagents.trans_to(I, 5)	//
			to_chat(user, span_notice("You wet [I] in [mybucket]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

		else if(!mymop)
			user.drop_held_item()
			mymop = I
			I.forceMove(src)
			update_icon()
			updateUsrDialog()
			to_chat(user, span_notice("You put [I] into [src]."))

	else if(istype(I, /obj/item/reagent_containers/spray) && !myspray)
		user.drop_held_item()
		myspray = I
		I.forceMove(src)
		update_icon()
		updateUsrDialog()
		to_chat(user, span_notice("You put [I] into [src]."))

	else if(istype(I, /obj/item/lightreplacer) && !myreplacer)
		user.drop_held_item()
		myreplacer = I
		I.forceMove(src)
		update_icon()
		updateUsrDialog()
		to_chat(user, span_notice("You put [I] into [src]."))

	else if(istype(I, /obj/item/tool/wet_sign))
		if(signs >= 4)
			to_chat(user, span_notice("[src] can't hold any more signs."))
			return

		user.drop_held_item()
		I.forceMove(src)
		signs++
		update_icon()
		updateUsrDialog()
		to_chat(user, span_notice("You put [I] into [src]."))

	else if(istype(I, /obj/item/reagent_containers/glass/bucket/janibucket))
		user.drop_held_item()
		mybucket = I
		I.forceMove(src)
		update_icon()
		updateUsrDialog()
		to_chat(user, span_notice("You put [I] into [src]."))
		return TRUE

	else if(mybag)
		mybag.attackby(I, user, params)





/obj/structure/janitorialcart/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat
	if(mybag)
		dat += "<a href='?src=[text_ref(src)];garbage=1'>[mybag.name]</a><br>"
	if(mymop)
		dat += "<a href='?src=[text_ref(src)];mop=1'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='?src=[text_ref(src)];spray=1'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='?src=[text_ref(src)];replacer=1'>[myreplacer.name]</a><br>"
	if(mybucket)
		dat += "<a href='?src=[text_ref(src)];bucket=1'>[mybucket.name]</a><br>"
	if(signs)
		dat += "<a href='?src=[text_ref(src)];sign=1'>[signs] sign\s</a><br>"
	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()


/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["garbage"])
		if(mybag)
			user.put_in_hands(mybag)
			to_chat(user, span_notice("You take [mybag] from [src]."))
			mybag = null
	if(href_list["mop"])
		if(mymop)
			user.put_in_hands(mymop)
			to_chat(user, span_notice("You take [mymop] from [src]."))
			mymop = null
	if(href_list["spray"])
		if(myspray)
			user.put_in_hands(myspray)
			to_chat(user, span_notice("You take [myspray] from [src]."))
			myspray = null
	if(href_list["replacer"])
		if(myreplacer)
			user.put_in_hands(myreplacer)
			to_chat(user, span_notice("You take [myreplacer] from [src]."))
			myreplacer = null
	if(href_list["bucket"])
		if(mybucket)
			user.put_in_hands(mybucket)
			to_chat(user, span_notice("You take [mybucket] from [src]."))
			mybucket = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/tool/wet_sign/Sign = locate() in src
			if(Sign)
				user.put_in_hands(Sign)
				to_chat(user, span_notice("You take \a [Sign] from [src]."))
				signs--
			else
				warning("[src] signs ([signs]) didn't match contents")
				signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(mybag)
		. += "cart_garbage"
	if(mymop)
		. += "cart_mop"
	if(myspray)
		. += "cart_spray"
	if(myreplacer)
		. += "cart_replacer"
	if(mybucket)
		. += "cart_bucket"
	if(signs)
		. += "cart_sign[signs]"
