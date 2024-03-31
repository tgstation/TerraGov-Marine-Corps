

/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	desc = ""
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/blank.ogg'
	pickup_sound =  'sound/blank.ogg'
	var/dat				//Actual page content
	var/due_date = 0	//Game time in 1/10th seconds
	var/author			//Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0		//0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title			//The real name of the book.
	var/window_size = null // Specific window size for the book, i.e: "1920x1080", Size x Width

	var/list/pages = list()
	var/bookfile
	var/curpage = 1
	var/textper = 100
	var/our_font = "Rosemary Roman"

/obj/item/book/attack_self(mob/user)
	if(!user.can_read(src))
		return
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	read(user)


/obj/item/book/examine(mob/user)
	. = ..()
	. += "<a href='?src=[REF(src)];read=1'>Read</a>"

/obj/item/book/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["close"])
		var/mob/user = usr
		if(user?.client && user.hud_used)
			if(user.hud_used.reads)
				user.hud_used.reads.destroy_read()
			user << browse(null, "window=reading")

	var/literate = usr.is_literate()
	if(!usr.canUseTopic(src, BE_CLOSE, literate))
		return

	if(href_list["read"])
		read(usr)

	if(href_list["turnpage"])
		if(pages.len >= curpage+2)
			curpage += 2
		else
			curpage = 1
		playsound(loc, 'sound/items/book_page.ogg', 100, TRUE, -1)
		read(usr)

/obj/item/book/proc/read(mob/user)
	user << browse_rsc('html/book.png')
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		return
	if(in_range(user, src) || isobserver(user))
		if(!pages.len)
			pages = SSlibrarian.get_book(bookfile)
		if(!pages.len)
			to_chat(user, "<span class='warning'>This book is completely blank.</span>")
		if(curpage > pages.len)
			curpage = 1
//		var/curdat = pages[curpage]
		user.hud_used.reads.icon_state = "book"
		user.hud_used.reads.show()
		var/dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
					<html><head><style type=\"text/css\">
					body { background-image:url('book.png');background-repeat: repeat; }</style></head><body scroll=yes>"}
		for(var/A in pages)
			dat += A
			dat += "<br>"
		dat += "<a href='?src=[REF(src)];close=1' style='position:absolute;right:50px'>Close</a>"
		dat += "</body></html>"
		user << browse(dat, "window=reading;size=460x300;can_close=0;can_minimize=0;can_maximize=0;can_resize=1;titlebar=0")
		onclose(user, "reading", src)
	else
		return "<span class='warning'>You're too far away to read it.</span>"
