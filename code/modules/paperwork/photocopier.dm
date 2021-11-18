/obj/machinery/photocopier
	name = "photocopier"
	desc = "Used to copy important documents and anatomy studies."
	icon = 'icons/obj/machines/library.dmi'
	icon_state = "bigscanner"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	max_integrity = 300
	var/obj/item/paper/copy
	var/obj/item/photo/photocopy
	var/copies = 1
	var/toner = 40
	var/maxcopies = 10
	var/greytoggle = "Greyscale"
	var/busy = FALSE


/obj/machinery/photocopier/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = "Photocopier<BR><BR>"
	if(copy || photocopy)
		dat += "<a href='byond://?src=[REF(src)];remove=1'>Remove Paper</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=[REF(src)];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=[REF(src)];min=1'>-</a> "
			dat += "<a href='byond://?src=[REF(src)];add=1'>+</a><BR><BR>"
			if(photocopy)
				dat += "Printing in <a href='byond://?src=[REF(src)];colortoggle=1'>[greytoggle]</a><BR><BR>"
	else if(toner)
		dat += "Please insert paper to copy.<BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"

	var/datum/browser/browser = new(user, "copier")
	browser.set_content(dat)
	browser.open()


/obj/machinery/photocopier/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["copy"])
		if(copy)
			for(var/i = 0, i < copies, i++)
				if(toner <= 0 || busy || !copy)
					break

				var/obj/item/paper/c = new /obj/item/paper (loc)
				if(!length(copy.info))
					break

				if(toner > 10)	//lots of toner, make it dark
					c.info = "<font color = #101010>"
				else			//no toner? shitty copies for you!
					c.info = "<font color = #808080>"
				var/copied = copy.info
				copied = replacetext_char(copied, "<font face='Verdana' color=", "<font face='Verdana' nocolor=")	//state of the art techniques in action
				copied = replacetext_char(copied, "<font face='Comic Sans MS' color=", "<font face='Comic Sans MS' nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
				c.info += copied
				c.info += "</font>"
				c.name = copy.name
				c.fields = copy.fields
				c.update_icon()
				c.updateinfolinks()
				c.stamps = copy.stamps
				if(copy.stamped)
					c.stamped = copy.stamped.Copy()
				c.copy_overlays(copy, TRUE)
				toner--
				busy = TRUE
				sleep(15)
				busy = FALSE

		if(photocopy)
			for(var/i = 0, i < copies, i++)
				if(toner < 5 || busy || !photocopy)
					break

				new /obj/item/photo (loc, photocopy.picture.Copy(greytoggle == "Greyscale"? TRUE : FALSE))
				busy = TRUE
				sleep(15)
				busy = FALSE

	else if(href_list["remove"])
		if(copy)
			remove_photocopy(copy, usr)
			copy = null
		else if(photocopy)
			remove_photocopy(photocopy, usr)
			photocopy = null

	else if(href_list["min"])
		if(copies > 1)
			copies--

	else if(href_list["add"])
		if(copies < maxcopies)
			copies++

	else if(href_list["colortoggle"])
		if(greytoggle == "Greyscale")
			greytoggle = "Color"
		else
			greytoggle = "Greyscale"

	updateUsrDialog()


/obj/machinery/photocopier/proc/do_insertion(obj/item/O, mob/user)
	O.forceMove(src)
	to_chat(user, "<span class ='notice'>You insert [O] into [src].</span>")
	flick("bigscanner1", src)
	updateUsrDialog()


/obj/machinery/photocopier/proc/remove_photocopy(obj/item/O, mob/user)
	if(!issilicon(user)) //surprised this check didn't exist before, putting stuff in AI's hand is bad
		O.forceMove(user.loc)
		user.put_in_hands(O)
	else
		O.forceMove(drop_location())
	to_chat(user, span_notice("You take [O] out of [src]."))


/obj/machinery/photocopier/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper))
		if(!copier_empty())
			to_chat(user, span_warning("There is already something in [src]!"))
			return

		if(!user.temporarilyRemoveItemFromInventory(I))
			return

		copy = I
		do_insertion(I, user)

	else if(istype(I, /obj/item/photo))
		if(!copier_empty())
			to_chat(user, span_warning("There is already something in [src]!"))
			return

		if(!user.temporarilyRemoveItemFromInventory(I))
			return

		photocopy = I
		do_insertion(I, user)

	else if(istype(I, /obj/item/toner))
		if(toner > 0)
			to_chat(user, span_warning("This cartridge is not yet ready for replacement! Use up the rest of the toner."))

		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		qdel(I)
		toner = 40
		to_chat(user, span_notice("You insert [I] into [src]."))
		updateUsrDialog()


/obj/machinery/photocopier/proc/copier_empty()
	if(copy || photocopy)
		return FALSE
	else
		return TRUE


/obj/item/toner
	name = "toner cartridge"
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	var/charges = 5
	var/max_charges = 5
