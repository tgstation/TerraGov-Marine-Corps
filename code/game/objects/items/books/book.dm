/*
* Book
*/
/obj/item/book
	name = "book"
	icon = 'icons/obj/items/books.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 3		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/obj/item/store	//What's in the book?

/obj/item/book/attack_self(mob/user as mob)
	if(carved)
		if(store)
			to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
			store.loc = get_turf(src.loc)
			store = null
			return
		else
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
			return
	if(src.dat)
		user << browse("<TT><I>Owner: [author].</I></TT> <BR>" + "[dat]", "window=book;size=800x600")
		user.visible_message("[user] opens \"[src.title]\".")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/book/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
		
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
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
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return

		if(I.w_class >= 3)
			to_chat(user, "<span class='notice'>[I] won't fit in [title].</span>")
			return

		user.drop_held_item()
		I.forceMove(src)
		store = I
		to_chat(user, "<span class='notice'>You put [I] in [title].</span>")

	else if(istype(I, /obj/item/tool/kitchen/knife) || iswirecutter(I))
		if(carved)	
			return

		to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
		
		if(!do_after(user, 30, TRUE, src))
			return

		to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
		carved = TRUE

/obj/item/book/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_selected == "eyes")
		user.visible_message("<span class='notice'>You open up the book and show it to [M]. </span>", \
			"<span class='notice'> [user] opens up a book and shows it to [M]. </span>")
		M << browse("<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]", "window=book")



/obj/item/book/codebook
	name = "Theseus Code Book"
	unique = TRUE
	dat = ""


/obj/item/book/codebook/Initialize(mapload, ...)
	var/letters = list("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",\
		"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	var/number
	var/letter
	dat = "<table><tr><th>Call</th><th>Response<th></tr>"
	for(var/i in 1 to 10)
		letter = pick(letters)
		number = rand(100, 999)
		dat += "<tr><td>[letter]-[number]</td>"
		letter = pick(letters)
		number = rand(100, 999)
		dat += "<td>[letter]-[number]</td></tr>"

	dat += "</table>"