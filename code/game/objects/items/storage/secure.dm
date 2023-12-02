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
	var/open = 0
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_storage_space = 14

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	. += "The service panel is [open ? "open" : "closed"]."


/obj/item/storage/secure/MouseDrop(over_object, src_location, over_location)
	if (locked)
		return
	..()


/obj/item/storage/secure/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = "Lock Status: [locked ? "LOCKED" : "UNLOCKED"]"
	var/message = "Code"

	if(!l_set && !l_setshort)
		dat += "<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"

	if(l_setshort)
		dat += "<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>"

	message = "[code]"

	if(!locked)
		message = "*****"

	dat += "<HR>\n>[message]<BR>\n<A href='?src=[text_ref(src)];type=1'>1</A>-<A href='?src=[text_ref(src)];type=2'>2</A>-<A href='?src=[text_ref(src)];type=3'>3</A><BR>\n<A href='?src=[text_ref(src)];type=4'>4</A>-<A href='?src=[text_ref(src)];type=5'>5</A>-<A href='?src=[text_ref(src)];type=6'>6</A><BR>\n<A href='?src=[text_ref(src)];type=7'>7</A>-<A href='?src=[text_ref(src)];type=8'>8</A>-<A href='?src=[text_ref(src)];type=9'>9</A><BR>\n<A href='?src=[text_ref(src)];type=R'>R</A>-<A href='?src=[text_ref(src)];type=0'>0</A>-<A href='?src=[text_ref(src)];type=E'>E</A><BR>\n</TT>"


	var/datum/browser/popup = new(user, "caselock", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()
	return TRUE


/obj/item/storage/secure/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["type"] == "E")
		if(!l_set && length(code) == 5 && !l_setshort && code != "ERROR")
			l_code = code
			l_set = TRUE
		else if(code == l_code && l_set)
			locked = FALSE
			overlays = null
			overlays += image('icons/obj/items/storage/storage.dmi', icon_opened)
			code = null
		else
			code = "ERROR"
	else
		if(href_list["type"] == "R" && !l_setshort)
			locked = TRUE
			overlays = null
			code = null
			close(usr)
		else
			code += href_list["type"]
			if(length(code) > 5)
				code = "ERROR"

	updateUsrDialog()


/obj/item/storage/secure/attackby(obj/item/I, mob/user, params)
	if(!locked)
		return ..()

	else if(isscrewdriver(I))
		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
			return

		open = !open
		user.show_message(span_notice(" You [open ? "open" : "close"] the service panel."))

	else if(ismultitool(I) && open && !l_hacking)
		user.show_message(span_warning(" Now attempting to reset internal memory, please hold."))
		l_hacking = TRUE
		if(!do_after(user, 100, NONE, src, BUSY_ICON_BUILD))
			return

		if(!prob(40))
			user.show_message(span_warning(" Unable to reset internal memory."), 1)
			l_hacking = FALSE
			return


		l_setshort = TRUE
		l_set = FALSE
		user.show_message(span_warning(" Internal memory reset.  Please give it a few seconds to reinitialize."))
		sleep(8 SECONDS)
		l_setshort = FALSE
		l_hacking = FALSE


// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "secure"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/containers_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/containers_right.dmi',
	)
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	force = 8
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY


/obj/item/storage/secure/briefcase/Initialize(mapload)
	. = ..()
	new /obj/item/paper(src)
	new /obj/item/tool/pen(src)


/obj/item/storage/secure/briefcase/attack_hand(mob/user)
	if(loc == user && locked)
		to_chat(user, span_warning("[src] is locked and cannot be opened!"))
		return

	if(loc == user && !locked)
		open(user)
		return

	. = ..()
	for(var/mob/M in range(1))
		if(M.s_active == src)
			close(M)


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
	force = 8
	w_class = WEIGHT_CLASS_GIGANTIC
	max_w_class = WEIGHT_CLASS_GIGANTIC
	anchored = TRUE
	density = FALSE
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/Initialize(mapload, ...)
	. = ..()
	new /obj/item/paper(src)
	new /obj/item/tool/pen(src)

/obj/item/storage/secure/safe/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return attack_self(user)
