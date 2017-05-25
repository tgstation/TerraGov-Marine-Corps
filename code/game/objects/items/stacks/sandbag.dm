
// Empty sandbags.

/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best fill them up."
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
			var/obj/item/stack/sandbags/new_bags = new(usr.loc)
			new_bags.add_to_stacks(usr)
			var/obj/item/stack/sandbags_empty/E = src
			src = null
			var/replace = (user.get_inactive_hand()==E)
			E.use(1)
			ET.has_dirt = 0
			ET.update_icon()
			if (!E && replace)
				user.put_in_hands(new_bags)
		return
	..()

//Full sandbags.

/obj/item/stack/sandbags
	name = "sandbags"
	desc = "Some bags, filled often for extra protection"
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
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(usr.loc),/area/sulaco/hangar))  //HANGAR BUILDING
		user << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
		return

	for(var/obj/structure/barricade/B in user.loc)
		if(!(B.flags_atom & ON_BORDER) || user.dir == B.dir)
			user << "<span class='warning'>You can't place more sandbags where a barricade is!</span>"
			return

	if(locate(/obj/structure/table, user.loc) || locate(/obj/structure/rack, user.loc))
		user << "<span class='warning'>You can't place sandbags where other structures are!</span>"
		return

	if(!in_use)
		if(amount < 5)
			user << "<span class='warning'>You need at least five sandbags to do this.</span>"
			return
		user << "<span class='notice'>Assembling sandbag barricade...</span>"
		in_use = 1
		if (!do_after(usr, 20, TRUE, 5, BUSY_ICON_CLOCK))
			in_use = 0
			return
		var/obj/structure/barricade/sandbags/SB = new ( usr.loc )
		user << "<span class='notice'>You assemble a sandbag barricade!</span>"
		SB.dir = usr.dir
		SB.update_icon()
		in_use = 0
		SB.add_fingerprint(usr)
		use(5)
	return