/*
* Book
*/
/obj/item/book
	name = "book"
	icon = 'icons/obj/items/books.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	//What's in the book?

/obj/item/book/Destroy()
	store = null
	return ..()

/obj/item/book/interact(mob/user)
	. = ..()
	if(.)
		return

	if(carved)
		if(!store)
			visible_message(span_notice("The pages of [title] have been cut out!"))
		else
			visible_message(span_notice("[store] falls out of [title]!"))
			store.forceMove(get_turf(loc))
			store = null
		return

	if(isliving(user))
		user.visible_message("[user] opens \"[title]\".")

	var/datum/browser/popup = new(user, "book", "<div align='center'>Owner: [author]</div>", 800, 600)
	popup.set_content(dat)
	popup.open()


/obj/item/book/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return

		var/choice = tgui_input_list(user, "What would you like to change?", null, list("Title", "Contents", "Author", "Cancel"))
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(user, "Write a new title:"))
				if(!newtitle)
					to_chat(user, "The title is invalid.")
					return

				name = newtitle
				title = newtitle

			if("Contents")
				var/content = strip_html(input(usr, "Write your book's contents:") as message|null, 8192)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return

				dat += content

			if("Author")
				var/newauthor = stripped_input(user, "Write the author's name:")
				if(!newauthor)
					to_chat(user, "The name is invalid.")
					return
				else
					author = newauthor

	else if(carved)
		if(store)
			to_chat(user, span_notice("There's already something in [title]!"))
			return

		if(I.w_class >= 3)
			to_chat(user, span_notice("[I] won't fit in [title]."))
			return

		user.drop_held_item()
		I.forceMove(src)
		store = I
		to_chat(user, span_notice("You put [I] in [title]."))

	else if(istype(I, /obj/item/tool/kitchen/knife) || iswirecutter(I))
		if(carved)
			return

		to_chat(user, span_notice("You begin to carve out [title]."))

		if(!do_after(user, 30, NONE, src))
			return

		to_chat(user, span_notice("You carve out the pages from [title]! You didn't want to read it anyway."))
		carved = TRUE

/obj/item/book/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_selected == "eyes")
		user.visible_message(span_notice("You open up the book and show it to [M]. "), \
			span_notice(" [user] opens up a book and shows it to [M]. "))
		M << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")



/obj/item/book/codebook
	name = "Ship Code Book"
	unique = TRUE
	dat = ""


/obj/item/book/codebook/Initialize(mapload)
	. = ..()
	var/number
	var/letter
	dat = "<table><tr><th>Call</th><th>Response<th></tr>"
	for(var/i in 1 to 10)
		letter = pick(SSstrings.get_list_from_file("greek_letters"))
		number = rand(100, 999)
		dat += "<tr><td>[letter]-[number]</td>"
		letter = pick(SSstrings.get_list_from_file("greek_letters"))
		number = rand(100, 999)
		dat += "<td>[letter]-[number]</td></tr>"

	dat += "</table>"
