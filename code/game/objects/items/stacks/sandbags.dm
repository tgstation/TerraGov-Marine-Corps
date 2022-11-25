

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
	. = ..()
	var/building_time = LERP(2 SECONDS, 1 SECONDS, user.skills.getPercent("construction", SKILL_ENGINEER_MASTER))
	create_object(user, new/datum/stack_recipe("sandbag barricade", /obj/structure/barricade/sandbags, 5, time = building_time, max_per_turf = STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE, on_floor = TRUE), 1)
