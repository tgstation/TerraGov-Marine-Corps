/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_NORMAL
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	materials = list(/datum/material/metal = 1000)
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")


/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/barbed_wire)) //making razorwire obstacles
		var/obj/item/stack/barbed_wire/B = W
		if(amount < 4)
			to_chat(user, span_warning("You need [4 - amount] more [src] to make a razor wire obstacle!"))
			return
		use(4)
		B.use(1)
		var/obj/structure/razorwire/M = new/obj/item/stack/razorwire(user.loc, 1)
		to_chat(user, span_notice("You combine the rods and barbed wire into [M]!"))

	if (iswelder(W))
		var/obj/item/tool/weldingtool/WT = W

		if(amount < 4)
			to_chat(user, span_warning("You need at least four rods to do this."))
			return

		if(WT.remove_fuel(0,user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			visible_message(span_warning("[src] is shaped into metal by [user] with the weldingtool."), null, span_warning(" You hear welding."))
			var/obj/item/stack/rods/R = src
			var/replace = (user.get_inactive_held_item()==R)
			R.use(4)
			if (!R && replace)
				user.put_in_hands(new_item)
		return
	..()


/obj/item/stack/rods/attack_self(mob/user as mob)

	if(!istype(user.loc,/turf)) return 0

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.obj_integrity <= G.integrity_failure)
				G.repair_damage(10)
				G.density = TRUE
				G.icon_state = "grille"
				use(1)
			else
				return 1

	else if(!CHECK_BITFIELD(obj_flags, IN_USE))
		if(amount < 4)
			to_chat(user, span_notice("You need at least four rods to do this."))
			return
		to_chat(usr, span_notice("Assembling grille..."))
		ENABLE_BITFIELD(obj_flags, IN_USE)
		if (!do_after(usr, 20, TRUE, src, BUSY_ICON_BUILD))
			DISABLE_BITFIELD(obj_flags, IN_USE)
			return
		new /obj/structure/grille/ ( usr.loc )
		to_chat(usr, span_notice("You assemble a grille"))
		DISABLE_BITFIELD(obj_flags, IN_USE)
		use(4)

