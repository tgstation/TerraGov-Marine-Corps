/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_NORMAL
	force = 9
	throwforce = 15
	throw_speed = 5
	throw_range = 20
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")


/obj/item/stack/rods/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if(istype(W, /obj/item/stack/barbed_wire)) // making razorwire obstacles
		var/obj/item/stack/barbed_wire/B = W
		if(amount < 8)
			to_chat(user, span_warning("You need at least [8 - amount] more [src] to make razorwire obstacles!"))
			return
		if(B.amount < 2)
			to_chat(user, span_warning("You need [2 - B.amount] more [B] to make a razor wire obstacle!"))
			return
		use(8)
		B.use(2)
		var/obj/structure/razorwire/M = new /obj/item/stack/razorwire(user.loc, 2)
		to_chat(user, span_notice("You combine the rods and barbed wire into [M]!"))
		return
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
				G.repair_damage(10, user)
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
		if (!do_after(usr, 20, NONE, src, BUSY_ICON_BUILD))
			DISABLE_BITFIELD(obj_flags, IN_USE)
			return
		new /obj/structure/grille/ ( usr.loc )
		to_chat(usr, span_notice("You assemble a grille"))
		DISABLE_BITFIELD(obj_flags, IN_USE)
		use(4)

/obj/item/stack/rods/attack_turf(turf/T, mob/living/user)
	if(!istype(T, /turf/open/floor/plating))
		to_chat(user, span_warning("You must remove the plating first."))
		return
	if(get_amount() < 2)
		to_chat(user, span_warning("You need more rods."))
		return

	to_chat(user, span_notice("Reinforcing the floor."))
	if(!do_after(user, 30, NONE, src, BUSY_ICON_BUILD) || !istype(T, /turf/open/floor/plating))
		return
	if(!use(2))
		to_chat(user, span_warning("You need more rods."))
		return
	T.ChangeTurf(/turf/open/floor/engine)
	playsound(src, 'sound/items/deconstruct.ogg', 25, 1)
