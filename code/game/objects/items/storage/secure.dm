/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	w_class = 3.0
	max_w_class = 2
	max_storage_space = 14

	examine(mob/user)
		..()
		to_chat(user, "The service panel is [src.open ? "open" : "closed"].")

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if(locked)
			if(istype(W, /obj/item/card/emag) && !emagged)
				emagged = 1
				src.overlays += image('icons/obj/items/storage/storage.dmi', icon_sparking)
				sleep(6)
				src.overlays = null
				overlays += image('icons/obj/items/storage/storage.dmi', icon_locking)
				locked = 0
				to_chat(user, "You short out the lock on [src].")
				return

			if (isscrewdriver(W))
				if (do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					src.open =! src.open
					user.show_message(text("<span class='notice'> You [] the service panel.</span>", (src.open ? "open" : "close")))
				return
			if (ismultitool(W) && (src.open == 1)&& (!src.l_hacking))
				user.show_message(text("<span class='warning'> Now attempting to reset internal memory, please hold.</span>"), 1)
				src.l_hacking = 1
				if (do_after(usr, 100, TRUE, 5, BUSY_ICON_BUILD))
					if (prob(40))
						src.l_setshort = 1
						src.l_set = 0
						user.show_message(text("<span class='warning'> Internal memory reset.  Please give it a few seconds to reinitialize.</span>"), 1)
						sleep(80)
						src.l_setshort = 0
						src.l_hacking = 0
					else
						user.show_message(text("<span class='warning'> Unable to reset internal memory.</span>"), 1)
						src.l_hacking = 0
				else	src.l_hacking = 0
				return
			//At this point you have exhausted all the special things to do when locked
			// ... but it's still locked.
			return

		// -> storage/attackby() what with handle insertion, etc
		..()


	MouseDrop(over_object, src_location, over_location)
		if (locked)
			src.add_fingerprint(usr)
			return
		..()


	attack_self(mob/user as mob)
		user.set_interaction(src)
		var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
		var/message = "Code"
		if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
			dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
		if (src.emagged)
			dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
		if (src.l_setshort)
			dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
		message = text("[]", src.code)
		if (!src.locked)
			message = "*****"
		dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
		user << browse(dat, "window=caselock;size=300x280")

	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
			return
		if (href_list["type"])
			if (href_list["type"] == "E")
				if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
					src.l_code = src.code
					src.l_set = 1
				else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
					src.locked = 0
					src.overlays = null
					overlays += image('icons/obj/items/storage/storage.dmi', icon_opened)
					src.code = null
				else
					src.code = "ERROR"
			else
				if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
					src.locked = 1
					src.overlays = null
					src.code = null
					src.close(usr)
				else
					src.code += text("[]", href_list["type"])
					if (length(src.code) > 5)
						src.code = "ERROR"
			src.add_fingerprint(usr)
			for(var/mob/M in viewers(1, src.loc))
				if ((M.client && M.interactee == src))
					src.attack_self(M)
				return
		return

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0

	New()
		..()
		new /obj/item/paper(src)
		new /obj/item/tool/pen(src)

	attack_hand(mob/user as mob)
		if ((src.loc == user) && (src.locked == 1))
			to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
		else if ((src.loc == user) && (!src.locked))
			src.open(usr)
		else
			..()
			for(var/mob/M in range(1))
				if (M.s_active == src)
					src.close(M)
		src.add_fingerprint(user)
		return

	//I consider this worthless but it isn't my code so whatever.  Remove or uncomment.
	/*attack(mob/M as mob, mob/living/user as mob)
		if ((CLUMSY in user.mutations) && prob(50))
			to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
			user.take_limb_damage(10)
			user.KnockOut(2)
			return

		log_combat(user, M, "attack", src, "(INTENT: [uppertext(user.a_intent)])")

		var/t = user:zone_selected
		if (t == "head")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
					if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
						to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
						return
					var/time = rand(2, 6)
					if (prob(75))
						H.KnockOut(time)
					else
						H.Stun(time)
					if(H.stat != 2)	H.stat = 1
					for(var/mob/O in viewers(H, null))
						O.show_message(text("<span class='danger'>[] has been knocked unconscious!</span>", H), 1, "<span class='warning'> You hear someone fall.</span>", 2)
				else
					to_chat(H, text("<span class='warning'> [] tried to knock you unconcious!</span>",user))
					H.adjust_blurriness(3)

		return*/

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	flags_atom = CONDUCT
	force = 8.0
	w_class = 8.0
	max_w_class = 8
	anchored = 1.0
	density = 0
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/Initialize(mapload, ...)
	. = ..()
	new /obj/item/paper(src)
	new /obj/item/tool/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/user as mob)
	return attack_self(user)
