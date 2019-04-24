/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags_atom = CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	matter = list("metal" = 1875)
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")


/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/barbed_wire)) //making razorwire obstacles
		var/obj/item/stack/barbed_wire/B = W
		if(amount < 4)
			to_chat(user, "<span class='warning'>You need [4 - amount] more [src] to make a razor wire obstacle!</span>")
			return
		use(4)
		B.use(1)
		var/obj/structure/razorwire/M = new/obj/item/stack/razorwire(user.loc, 1)
		to_chat(user, "<span class='notice'>You combine the rods and barbed wire into [M]!</span>")

	if (iswelder(W))
		var/obj/item/tool/weldingtool/WT = W

		if(amount < 4)
			to_chat(user, "<span class='warning'>You need at least four rods to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("<span class='warning'> [src] is shaped into metal by [user.name] with the weldingtool.</span>", 3, "<span class='warning'> You hear welding.</span>", 2)
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_held_item()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(usr.loc),/area/sulaco/hangar))  //HANGER BUILDING
		to_chat(usr, "<span class='warning'>No. This area is needed for the dropships and personnel.</span>")
		return

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				use(1)
			else
				return 1

	else if(!CHECK_BITFIELD(obj_flags, IN_USE))
		if(amount < 4)
			to_chat(user, "<span class='notice'>You need at least four rods to do this.</span>")
			return
		to_chat(usr, "<span class='notice'>Assembling grille...</span>")
		ENABLE_BITFIELD(obj_flags, IN_USE)
		if (!do_after(usr, 20, TRUE, 5, BUSY_ICON_BUILD))
			DISABLE_BITFIELD(obj_flags, IN_USE)
			return
		var/obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		to_chat(usr, "<span class='notice'>You assemble a grille</span>")
		DISABLE_BITFIELD(obj_flags, IN_USE)
		F.add_fingerprint(usr)
		use(4)
	return
