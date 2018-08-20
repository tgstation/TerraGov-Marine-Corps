/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "The ultimate in janitorial carts! Has space for water, mops, signs, trash bags, and more!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	drag_delay = 1
	throwpass = TRUE
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag
	var/obj/item/tool/mop/mymop
	var/obj/item/reagent_container/spray/myspray
	var/obj/item/device/lightreplacer/myreplacer
	var/obj/item/reagent_container/glass/bucket/janibucket/mybucket
	var/signs = 0	//maximum capacity hardcoded below


/obj/structure/janitorialcart/New()
	..()
	mybucket = new(src)
	update_icon()

/obj/structure/janitorialcart/examine(mob/user)
	..()
	if(mybucket)
		to_chat(user, "Its bucket contains [mybucket.reagents.total_volume] unit\s of liquid.")
	else
		to_chat(user, "It has no bucket.")


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/storage/bag/trash) && !mybag)
		user.drop_held_item()
		mybag = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/tool/mop))
		if(I.reagents.total_volume < I.reagents.maximum_volume && mybucket)	//if it's not completely soaked we assume they want to wet it, otherwise store it
			if(mybucket.reagents.total_volume < 1)
				to_chat(user, "[mybucket] is out of water!</span>")
			else
				mybucket.reagents.trans_to(I, 5)	//
				to_chat(user, "<span class='notice'>You wet [I] in [mybucket].</span>")
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			return
		if(!mymop)
			user.drop_held_item()
			mymop = I
			I.loc = src
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/reagent_container/spray) && !myspray)
		user.drop_held_item()
		myspray = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/device/lightreplacer) && !myreplacer)
		user.drop_held_item()
		myreplacer = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")

	else if(istype(I, /obj/item/tool/wet_sign))
		if(signs < 4)
			user.drop_held_item()
			I.loc = src
			signs++
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")

	else if(istype(I, /obj/item/reagent_container/glass/bucket/janibucket))
		user.drop_held_item()
		mybucket = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return TRUE //no afterattack

	else if(mybag)
		mybag.attackby(I, user)





/obj/structure/janitorialcart/attack_hand(mob/user)
	user.set_interaction(src)
	var/dat
	if(mybag)
		dat += "<a href='?src=\ref[src];garbage=1'>[mybag.name]</a><br>"
	if(mymop)
		dat += "<a href='?src=\ref[src];mop=1'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='?src=\ref[src];spray=1'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='?src=\ref[src];replacer=1'>[myreplacer.name]</a><br>"
	if(mybucket)
		dat += "<a href='?src=\ref[src];bucket=1'>[mybucket.name]</a><br>"
	if(signs)
		dat += "<a href='?src=\ref[src];sign=1'>[signs] sign\s</a><br>"
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
			to_chat(user, "<span class='notice'>You take [mybag] from [src].</span>")
			mybag = null
	if(href_list["mop"])
		if(mymop)
			user.put_in_hands(mymop)
			to_chat(user, "<span class='notice'>You take [mymop] from [src].</span>")
			mymop = null
	if(href_list["spray"])
		if(myspray)
			user.put_in_hands(myspray)
			to_chat(user, "<span class='notice'>You take [myspray] from [src].</span>")
			myspray = null
	if(href_list["replacer"])
		if(myreplacer)
			user.put_in_hands(myreplacer)
			to_chat(user, "<span class='notice'>You take [myreplacer] from [src].</span>")
			myreplacer = null
	if(href_list["bucket"])
		if(mybucket)
			user.put_in_hands(mybucket)
			to_chat(user, "<span class='notice'>You take [mybucket] from [src].</span>")
			mybucket = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/tool/wet_sign/Sign = locate() in src
			if(Sign)
				user.put_in_hands(Sign)
				to_chat(user, "<span class='notice'>You take \a [Sign] from [src].</span>")
				signs--
			else
				warning("[src] signs ([signs]) didn't match contents")
				signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/update_icon()
	overlays = null
	if(mybag)
		overlays += "cart_garbage"
	if(mymop)
		overlays += "cart_mop"
	if(myspray)
		overlays += "cart_spray"
	if(myreplacer)
		overlays += "cart_replacer"
	if(mybucket)
		overlays += "cart_bucket"
	if(signs)
		overlays += "cart_sign[signs]"
