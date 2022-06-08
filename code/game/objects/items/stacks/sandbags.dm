

//Empty sandbags
/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best to fill them up with an entrenching tool if you want to use them."
	singular_name = "sandbag"
	icon_state = "sandbag_stack"
	w_class = WEIGHT_CLASS_NORMAL
	force = 2
	throw_speed = 5
	throw_range = 20
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	number_of_extra_variants = 3


/obj/item/stack/sandbags_empty/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/shovel))
		var/obj/item/tool/shovel/ET = I
		if(!ET.dirt_amt)
			return

		var/dirt_transfer = min(ET.dirt_amt,get_amount())
		if(!dirt_transfer)
			return

		ET.dirt_amt -= dirt_transfer
		ET.update_icon()
		use(dirt_transfer)
		var/obj/item/stack/sandbags/new_bags = new(user.loc)
		new_bags.add(max(0, dirt_transfer - 1))
		new_bags.add_to_stacks(user)
		var/obj/item/stack/sandbags_empty/E = src
		var/replace = (user.get_inactive_held_item() == E)
		playsound(user.loc, "rustle", 30, 1, 6)
		if(!E && replace)
			user.put_in_hands(new_bags)

	else if(istype(I, /obj/item/stack/snow))
		var/obj/item/stack/S = I
		var/obj/item/stack/sandbags/new_bags = new(user.loc)
		new_bags.add_to_stacks(user)
		S.use(1)
		use(1)


//half a max stack
/obj/item/stack/sandbags_empty/half
	amount = 25

//max stack
/obj/item/stack/sandbags_empty/full
	amount = 50

//Full sandbags
/obj/item/stack/sandbags
	name = "sandbags"
	desc = "Some bags filled with sand. For now, just cumbersome, but soon to be used for fortifications."
	singular_name = "sandbag"
	icon_state = "sandbag_pile"
	w_class = WEIGHT_CLASS_NORMAL
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	max_amount = 25
	attack_verb = list("hit", "bludgeoned", "whacked")
	merge_type = /obj/item/stack/sandbags


/obj/item/stack/sandbags/large_stack
	amount = 25

/obj/item/stack/sandbags/attack_self(mob/living/user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(user.loc),/area/sulaco/hangar))  //HANGAR BUILDING
		to_chat(user, span_warning("No. This area is needed for the dropships and personnel."))
		return

	if(!isopenturf(user.loc))
		var/turf/open/OT = user.loc
		if(!OT.allow_construction)
			to_chat(user, span_warning("The sandbag barricade must be constructed on a proper surface!"))
			return

	//Using same safeties as other constructions
	for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
		if(O.density)
			if(O.flags_atom & ON_BORDER)
				if(O.dir == user.dir)
					to_chat(user, span_warning("There is already \a [O.name] in this direction!"))
					return
			else
				to_chat(user, span_warning("You need a clear, open area to build the sandbag barricade!"))
				return

	if(user.do_actions)
		return
	if(amount < 5)
		to_chat(user, span_warning("You need at least five [name] to do this."))
		return
	user.visible_message(span_notice("[user] starts assembling a sandbag barricade."),
	span_notice("You start assembling a sandbag barricade."))
	var/building_time = LERP(2 SECONDS, 1 SECONDS, user.skills.getPercent("construction", SKILL_ENGINEER_MASTER))
	if(!do_after(user, building_time, TRUE, src, BUSY_ICON_BUILD))
		return
	for(var/obj/O in user.loc) //Objects, we don't care about mobs. Turfs are checked elsewhere
		if(O.density && (!(O.flags_atom & ON_BORDER) || O.dir == user.dir))
			return
	var/obj/structure/barricade/sandbags/SB = new(user.loc, user.dir)
	user.visible_message(span_notice("[user] assembles a sandbag barricade."),
	span_notice("You assemble a sandbag barricade."))
	SB.setDir(user.dir)
	use(5)
