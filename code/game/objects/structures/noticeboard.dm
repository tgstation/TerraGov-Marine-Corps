/obj/structure/noticeboard
	name = "notice board"
	desc = "A board for pinning important notices upon."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	density = FALSE
	anchored = TRUE
	var/notices = 0

/obj/structure/noticeboard/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		if(notices > 4) break
		if(istype(I, /obj/item/paper))
			I.loc = src
			notices++
	icon_state = "nboard0[notices]"

//attaching papers!!
/obj/structure/noticeboard/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper))
		if(notices >= 5)
			to_chat(user, span_notice("You reach to pin your paper to the board but hesitate. You are certain your paper will not be seen among the many others already attached."))
			return

		user.drop_held_item()
		I.forceMove(src)
		notices++
		icon_state = "nboard0[notices]"	//update sprite
		to_chat(user, span_notice("You pin the paper to the noticeboard."))


/obj/structure/noticeboard/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	for(var/obj/item/paper/P in src)
		dat += "<A href='?src=[text_ref(src)];read=[text_ref(P)]'>[P.name]</A> <A href='?src=[text_ref(src)];write=[text_ref(P)]'>Write</A> <A href='?src=[text_ref(src)];remove=[text_ref(P)]'>Remove</A><BR>"

	var/datum/browser/popup = new(user, "noticeboard", "<div align='center'>Noticeboard</div>")
	popup.set_content(dat)
	popup.open()


/obj/structure/noticeboard/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["remove"])
		var/obj/item/P = locate(href_list["remove"])
		if((P?.loc == src))
			P.loc = get_turf(src)	//dump paper on the floor because you're a clumsy fuck
			notices--
			icon_state = "nboard0[notices]"

	if(href_list["write"])
		var/obj/item/P = locate(href_list["write"])

		if((P?.loc == src)) //ifthe paper's on the board
			if(istype(usr.r_hand, /obj/item/tool/pen)) //and you're holding a pen
				P.attackby(usr.r_hand, usr) //then do ittttt
			else
				if(istype(usr.l_hand, /obj/item/tool/pen)) //check other hand for pen
					P.attackby(usr.l_hand, usr)
				else
					to_chat(usr, span_notice("You'll need something to write with!"))

	if(href_list["read"])
		var/obj/item/paper/P = locate(href_list["read"])
		if((P?.loc == src))
			if(!( ishuman(usr) ))
				usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY><TT>[stars(P.info)]</TT></BODY></HTML>", "window=[P.name]")
				onclose(usr, "[P.name]")
			else
				usr << browse("<HTML><HEAD><TITLE>[P.name]</TITLE></HEAD><BODY><TT>[P.info]</TT></BODY></HTML>", "window=[P.name]")
				onclose(usr, "[P.name]")
