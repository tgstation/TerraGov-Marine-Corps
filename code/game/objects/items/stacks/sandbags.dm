

//Empty sandbags
/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best to fill them up with an entrenching tool if you want to use them."
	singular_name = "sandbag"
	icon_state = "sandbag_stack"
	worn_icon_state = "sandbag_stack"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/stacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/stacks_right.dmi',
	)
	w_class = WEIGHT_CLASS_NORMAL
	force = 2
	throw_speed = 5
	throw_range = 20
	max_amount = 50
	attack_verb = list("hits", "bludgeons", "whacks")
	number_of_extra_variants = 3


/obj/item/stack/sandbags_empty/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

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
		playsound(user.loc, SFX_RUSTLE, 30, 1, 6)
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
	worn_icon_state = "sandbag_pile"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/stacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/stacks_right.dmi',
	)
	w_class = WEIGHT_CLASS_NORMAL
	force = 9
	throwforce = 15
	throw_speed = 5
	throw_range = 20
	max_amount = 25
	attack_verb = list("hits", "bludgeons", "whacks")
	merge_type = /obj/item/stack/sandbags


/obj/item/stack/sandbags/examine(mob/user)
	. = ..()
	. += span_notice("Right click while selected to empty [src].")

/obj/item/stack/sandbags/large_stack
	amount = 25

/obj/item/stack/sandbags/attack_self(mob/living/user)
	. = ..()
	var/building_time = LERP(2 SECONDS, 1 SECONDS, user.skills.getPercent(SKILL_CONSTRUCTION, SKILL_ENGINEER_EXPERT))
	create_object(user, new/datum/stack_recipe("sandbag barricade", /obj/structure/barricade/sandbags, 5, time = building_time, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_CHECK_DIRECTION | CRAFT_ON_SOLID_GROUND), 1)

/obj/item/stack/sandbags/attack_self_alternate(mob/user)
	. = ..()
	if(get_amount() < 1)
		return
	if(LAZYLEN(user.do_actions))
		user.balloon_alert(user, "busy!")
		return

	user.balloon_alert(user, "emptying...")
	while(get_amount() > 0)
		if(!do_after(user, 0.5 SECONDS, IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE, user))
			user.balloon_alert(user, "stopped")
			break
		// check if we can stuff it into the user's hands
		if(!use(1))
			break
		if(amount < 1)
			user.balloon_alert(user, "finished")
		var/obj/item/stack/sandbag = user.get_inactive_held_item()
		if(istype(sandbag, /obj/item/stack/sandbags_empty) && sandbag.add(1))
			continue
		var/obj/item/stack/sandbags_empty/E = new(get_turf(user))
		if(!sandbag && user.put_in_hands(E))
			continue
		E.add_to_stacks(user)
