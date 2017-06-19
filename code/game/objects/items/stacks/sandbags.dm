

//Empty sandbags
/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best to fill them up if you want to use them."
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_stack"
	flags_atom = FPRINT
	w_class = 3.0
	force = 2
	throwforce = 0
	throw_speed = 5
	throw_range = 20
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sandbags_empty/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/etool))
		var/obj/item/weapon/etool/ET = W
		if(ET.has_dirt)
			var/obj/item/stack/sandbags/new_bags = new(user.loc)
			new_bags.add_to_stacks(user)
			var/obj/item/stack/sandbags_empty/E = src
			src = null
			var/replace = (user.get_inactive_hand() == E)
			E.use(1)
			ET.has_dirt = 0
			ET.update_icon()
			if(!E && replace)
				user.put_in_hands(new_bags)
		return
	..()

//Full sandbags
/obj/item/stack/sandbags
	name = "sandbags"
	desc = "Some bags filled with sand. For now, just cumbersome, but soon to be used for fortifications."
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_pile"
	flags_atom = FPRINT
	w_class = 4.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	max_amount = 25
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sandbags/attack_self(mob/user)
	add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(usr.loc),/area/sulaco/hangar))  //HANGAR BUILDING
		user << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
		return


	//Using same safeties as other constructions
	for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
		if(O.density && !istype(O, /obj/structure/barricade/sandbags) && !(O.flags_atom & ON_BORDER))
			usr << "<span class='warning'>You need a clear, open area to build the sandbag barricade!</span>"
			return
		if((O.flags_atom & ON_BORDER) && O.dir == user.dir)
			usr << "<span class='warning'>There is already \a [O.name] in this direction!</span>"
			return

	if(!in_use)
		if(amount < 5)
			user << "<span class='warning'>You need at least five [name] to do this.</span>"
			return
		user.visible_message("<span class='notice'>[user] starts assembling a sandbag barricade.</span>",
		"<span class='notice'>You start assembling a sandbag barricade.</span>")
		in_use = 1
		if(!do_after(usr, 20, TRUE, 5, BUSY_ICON_CLOCK))
			in_use = 0
			return
		for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
			if(O.density && !istype(O, /obj/structure/barricade/sandbags) && !(O.flags_atom & ON_BORDER))
				usr << "<span class='warning'>You need a clear, open area to build the sandbag barricade!</span>"
				return
			if((O.flags_atom & ON_BORDER) && O.dir == user.dir)
				usr << "<span class='warning'>There is already \a [O.name] in this direction!</span>"
				return
		var/obj/structure/barricade/sandbags/SB = new(user.loc, user.dir)
		user.visible_message("<span class='notice'>[user] assembles a sandbag barricade.</span>",
		"<span class='notice'>You assemble a sandbag barricade.</span>")
		SB.dir = usr.dir
		in_use = 0
		SB.add_fingerprint(usr)
		use(5)
	return