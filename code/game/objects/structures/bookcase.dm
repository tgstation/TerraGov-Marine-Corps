
/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "book-0"
	anchored = 1
	density = 1
	opacity = 1

/obj/structure/bookcase/initialize()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/book))
			I.loc = src
	update_icon()

/obj/structure/bookcase/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/book))
		user.drop_held_item()
		O.loc = src
		update_icon()
	else if(istype(O, /obj/item/tool/pen))
		var/newname = stripped_input(usr, "What would you like to title this bookshelf?")
		if(!newname)
			return
		else
			name = ("bookcase ([sanitize(newname)])")
	else
		..()

/obj/structure/bookcase/attack_hand(var/mob/user as mob)
	if(contents.len)
		var/obj/item/book/choice = input("Which book would you like to remove from the shelf?") as null|obj in contents
		if(choice)
			if(!usr.canmove || usr.stat || usr.is_mob_restrained() || !in_range(loc, usr))
				return
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/book/b in contents)
				cdel(b)
			cdel(src)
			return
		if(2.0)
			for(var/obj/item/book/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else cdel(b)
			cdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/book/b in contents)
					b.loc = (get_turf(src))
				cdel(src)
			return
		else
	return

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

	New()
		..()
		new /obj/item/book/manual/medical_cloning(src)
		new /obj/item/book/manual/medical_diagnostics_manual(src)
		new /obj/item/book/manual/medical_diagnostics_manual(src)
		new /obj/item/book/manual/medical_diagnostics_manual(src)
		update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

	New()
		..()
		new /obj/item/book/manual/engineering_construction(src)
		new /obj/item/book/manual/engineering_particle_accelerator(src)
		new /obj/item/book/manual/engineering_hacking(src)
		new /obj/item/book/manual/engineering_guide(src)
		new /obj/item/book/manual/atmospipes(src)
		new /obj/item/book/manual/engineering_singularity_safety(src)
		new /obj/item/book/manual/evaguide(src)
		update_icon()

/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

	New()
		..()
		new /obj/item/book/manual/research_and_development(src)
		update_icon()
