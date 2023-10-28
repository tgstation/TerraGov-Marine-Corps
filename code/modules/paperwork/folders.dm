/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	var/updateicon = 0//If they spawn with premade papers, update icon

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/grape
	desc = "A violet folder."
	icon_state = "folder_grape"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/folder/black
	desc = "A black folder."
	icon_state = "folder_black"

/obj/item/folder/black_random
	desc = "A black folder. It is decorated with stripes."
	icon_state = "folder_black_green"

/obj/item/folder/black_random/Initialize(mapload)
	. = ..()
	icon_state = "folder_black[pick("_red", "_green", "_blue", "_yellow", "_white")]"

/obj/item/folder/Initialize(mapload)
	. = ..()
	if(updateicon)
		update_icon()

/obj/item/folder/update_icon()
	overlays.Cut()
	if(length(contents))
		overlays += "folder_paper"
	return

/obj/item/folder/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
		if(!user.transferItemToLoc(I, src))
			return

		to_chat(user, span_notice("You put the [I] into \the [src]."))
		update_icon()

	else if(istype(I, /obj/item/tool/pen))
		var/n_name = stripped_input(user, "What would you like to label the folder?", "Folder Labelling")
		if(loc != user || user.stat != CONSCIOUS)
			return

		name = "folder[(n_name ? "- '[n_name]'" : "")]"

/obj/item/folder/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat

	for(var/obj/item/paper/P in src)
		dat += "<A href='?src=[text_ref(src)];remove=[text_ref(P)]'>Remove</A> - <A href='?src=[text_ref(src)];read=[text_ref(P)]'>[P.name]</A><BR>"
	for(var/obj/item/photo/Ph in src)
		dat += "<A href='?src=[text_ref(src)];remove=[text_ref(Ph)]'>Remove</A> - <A href='?src=[text_ref(src)];look=[text_ref(Ph)]'>[Ph.name]</A><BR>"
	for(var/obj/item/paper_bundle/Pb in src)
		dat += "<A href='?src=[text_ref(src)];remove=[text_ref(Pb)]'>Remove</A> - <A href='?src=[text_ref(src)];browse=[text_ref(Pb)]'>[Pb.name]</A><BR>"
	var/datum/browser/popup = new(user, "folder", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()

/obj/item/folder/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(src.loc == usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(P && (P.loc == src) && istype(P))
				P.loc = usr.loc
				usr.put_in_hands(P)

		else if(href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if(P && (P.loc == src) && istype(P))
				if(!(ishuman(usr) || isobserver(usr) || issilicon(usr)))
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[stars(P.info)][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
				else
					usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY>[P.info][P.stamps]</BODY></HTML>", "window=[P.name]")
					onclose(usr, "[P.name]")
		else if(href_list["look"])
			var/obj/item/photo/P = locate(href_list["look"])
			if(P && (P.loc == src) && istype(P))
				P.show(usr)
		else if(href_list["browse"])
			var/obj/item/paper_bundle/P = locate(href_list["browse"])
			if(P && (P.loc == src) && istype(P))
				P.attack_self(usr)
				onclose(usr, "[P.name]")

		//Update everything
		updateUsrDialog()
		update_icon()
