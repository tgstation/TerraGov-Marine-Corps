//stack recipe placement check types
/// Checks if there is an object of the result type in any of the cardinal directions
#define STACK_CHECK_CARDINALS (1<<0)
/// Checks if there is an object of the result type within one tile
#define STACK_CHECK_ADJACENT (1<<1)

/* Stack type objects!
* Contains:
* 		Stacks
* 		Recipe datum
* 		Recipe list datum
*/

/*
* Stacks
*/
/obj/item/stack
	icon = 'icons/obj/stack_objects.dmi'
	gender = PLURAL
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/stack_name = "stack"
	var/amount = 1
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/merge_type // This path and its children should merge with this stack, defaults to src.type
	var/number_of_extra_variants = 0 //Determines whether the item should update it's sprites based on amount.

/obj/item/stack/Initialize(mapload, new_amount)
	. = ..()
	if(new_amount)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount)
	if(!merge_type)
		merge_type = type
	recipes = get_main_recipes().Copy()
	update_weight()
	update_icon()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

///Use this proc to assign the appropriate global list to our var/recipes
/obj/item/stack/proc/get_main_recipes()
	RETURN_TYPE(/list)
	SHOULD_CALL_PARENT(TRUE)

	return list() //empty list

/obj/item/stack/proc/update_weight()
	var/percent = round((amount * 100) / max_amount)
	var/full_w_class = initial(w_class)
	var/new_w_class
	switch(percent) //Currently 3 steps as defined by STACK_WEIGHT_STEPS
		if(0 to 33)
			new_w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
		if(34 to 66)
			new_w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
		if(67 to 100)
			new_w_class = full_w_class
		else
			stack_trace("[src] tried to update_weight() with [amount] amount and [max_amount] max_amount.")
	if(new_w_class != w_class)
		w_class = new_w_class
		loc?.recalculate_storage_space() //No need to do icon updates if there are no changes.


/obj/item/stack/update_icon_state()
	. = ..()
	if(!number_of_extra_variants)
		return
	var/ratio = round((amount * (number_of_extra_variants + 1)) / max_amount)
	if(ratio < 1)
		icon_state = initial(icon_state)
		return
	ratio = min(ratio + 1, number_of_extra_variants + 1)
	icon_state = "[initial(icon_state)]_[ratio]"

/obj/item/stack/update_overlays()
	. = ..()
	if(isturf(loc))
		return
	var/mutable_appearance/number = mutable_appearance()
	number.maptext = MAPTEXT(amount)
	. += number

/obj/item/stack/Destroy()
	if(usr && usr.interactee == src)
		usr << browse(null, "window=stack")
	return ..()

/obj/item/stack/examine(mob/user)
	. = ..()
	if(amount > 1)
		. += EXAMINE_SECTION_BREAK
		. += "There are [amount] [singular_name]\s in the [stack_name]."

/obj/item/stack/equipped(mob/user, slot)
	. = ..()
	update_icon()

/obj/item/stack/removed_from_inventory(mob/user)
	. = ..()
	update_icon()

/obj/item/stack/interact(mob/user, recipes_sublist)
	. = ..()

	//We need to open the menu only if radial stacks are disabled, or if select_radial tells us to by returning TRUE
	if(!(!(user.client.prefs.toggles_gameplay & RADIAL_STACKS) || select_radial(user)))
		return

	if(.)
		return

	if(!recipes || recipes?.len <= 1)
		return

	if(QDELETED(src) || get_amount() <= 0)
		DIRECT_OUTPUT(user, browse(null, "window=stack"))

	var/list/recipe_list = recipes
	if(recipes_sublist && recipe_list[recipes_sublist] && istype(recipe_list[recipes_sublist], /datum/stack_recipe_list))
		var/datum/stack_recipe_list/srl = recipe_list[recipes_sublist]
		recipe_list = srl.recipes
	var/t1 = "Amount Left: [get_amount()]<br>"
	for(var/i in 1 to length(recipe_list))
		var/E = recipe_list[i]
		if(isnull(E))
			t1 += "<hr>"
			continue
		if(i > 1 && !isnull(recipe_list[i-1]))
			t1+="<br>"

		if(istype(E, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/srl = E
			t1 += "<a href='byond://?src=[REF(src)];sublist=[i]'>[srl.title]</a>"

		if(istype(E, /datum/stack_recipe))
			var/datum/stack_recipe/R = E
			var/max_multiplier = round(get_amount() / R.req_amount)
			var/title
			var/can_build = TRUE
			can_build = can_build && (max_multiplier > 0)

			if(R.res_amount > 1)
				title += "[R.res_amount]x [R.title]\s"
			else
				title += "[R.title]"
			title += " ([R.req_amount] [singular_name]\s)"
			if(can_build)
				t1 += "<A href='byond://?src=[REF(src)];sublist=[recipes_sublist];make=[i];multiplier=1'>[title]</A>  "
			else
				t1 += "[title]"
				continue
			if(R.max_res_amount > 1 && max_multiplier > 1)
				max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
				t1 += " |"
				var/list/multipliers = list(5,10,25)
				for(var/n in multipliers)
					if(max_multiplier >= n)
						t1 += " <A href='byond://?src=[REF(src)];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
				if(!(max_multiplier in multipliers))
					t1 += " <A href='byond://?src=[REF(src)];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	var/datum/browser/popup = new(user, "stack", name, 400, 400)
	popup.set_content(t1)
	popup.open()


/obj/item/stack/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(usr.get_active_held_item() != src)
		return
	if(href_list["sublist"] && !href_list["make"])
		interact(usr, text2num(href_list["sublist"]))
	if(href_list["make"])
		if(zero_amount())
			return
		var/list/recipes_list = recipes
		if(href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		var/max_multiplier = round(max_amount / R.req_amount)
		if(multiplier <= 0 || multiplier > max_multiplier) //href protection
			log_admin_private("[key_name(usr)] attempted to create a ([src]) stack ([R]) recipe with multiplier [multiplier] at [AREACOORD(usr.loc)].")
			message_admins("[ADMIN_TPMONTY(usr)] attempted to create a ([src]) stack ([R]) recipe with multiplier [multiplier]. Possible HREF exploit.")
			return

		create_object(usr, R, multiplier)


/// Creates multiplier amount of objects based off of stack recipe recipe. Most creation variables are changed through stack recipe datum's variables
/obj/item/stack/proc/create_object(mob/user, datum/stack_recipe/recipe, multiplier, turf/build_loc, build_dir, ignore_stack_loc = FALSE)
	if(!ignore_stack_loc && user.get_active_held_item() != src)
		return
	if(!can_interact(user))
		return //TRUE
	if(!building_checks(user, recipe, multiplier, build_loc, build_dir))
		return
	if(user.do_actions)
		return
	var/building_time = recipe.time
	if(recipe.skill_req && user.skills.getRating(SKILL_CONSTRUCTION) < recipe.skill_req)
		building_time += recipe.time * ( recipe.skill_req - user.skills.getRating(SKILL_CONSTRUCTION) ) * 0.5 // +50% time each skill point lacking.
	if(recipe.skill_req && user.skills.getRating(SKILL_CONSTRUCTION) > recipe.skill_req)
		building_time -= clamp(recipe.time * ( user.skills.getRating(SKILL_CONSTRUCTION) - recipe.skill_req ) * 0.40, 0 , 0.85 * building_time) // -40% time each extra skill point
	if(building_time)
		balloon_alert_to_viewers("building [recipe.title]")
		if(!do_after(user, building_time, NONE, src, (building_time > recipe.time ? BUSY_ICON_UNSKILLED : BUSY_ICON_BUILD)))
			return
		if(!building_checks(user, recipe, multiplier, build_loc, build_dir))
			return

	return do_create_object(user, recipe, multiplier, build_loc, build_dir)

///Actually creates and places the object
/obj/item/stack/proc/do_create_object(mob/user, datum/stack_recipe/recipe, multiplier, turf/build_loc, build_dir)
	var/obj/new_obj
	if(!build_loc)
		build_loc = get_turf(user)
	if(recipe.max_res_amount > 1) //Is it a stack?
		new_obj = new recipe.result_type(build_loc, recipe.res_amount * multiplier)
	else if(ispath(recipe.result_type, /turf))
		if(!isturf(build_loc))
			return
		build_loc.PlaceOnTop(recipe.result_type)
	else
		new_obj = new recipe.result_type(build_loc, user)
	if(new_obj)
		new_obj.setDir(build_dir ? build_dir : user.dir)
		new_obj.color = color
	use(recipe.req_amount * multiplier)

	if(isitemstack(new_obj))
		var/obj/item/stack/stack = new_obj
		stack.merge_with_stack_in_hands(user)

	if(QDELETED(new_obj))
		return //It's a stack and has already been merged

	if(isitem(new_obj))
		user.put_in_hands(new_obj)

	//BubbleWrap - so newly formed boxes are empty
	if(istype(new_obj, /obj/item/storage))
		for(var/obj/item/item in new_obj)
			qdel(item)
	//BubbleWrap END

	if(istype(new_obj, /obj/structure))
		user.record_structures_built()

	return TRUE

/obj/item/stack/proc/building_checks(mob/builder, datum/stack_recipe/recipe, multiplier, turf/dest_turf, build_dir)
	if (get_amount() < recipe.req_amount * multiplier)
		builder.balloon_alert(builder, "not enough material!")
		return FALSE
	if(!dest_turf)
		dest_turf =  get_turf(builder)
	if(!build_dir)
		build_dir = builder.dir

	if((recipe.crafting_flags & CRAFT_ONE_PER_TURF) && (locate(recipe.result_type) in dest_turf))
		builder.balloon_alert(builder, "already one here!")
		return FALSE

	if(recipe.crafting_flags & CRAFT_CHECK_DIRECTION)
		if(!valid_build_direction(dest_turf, build_dir, is_fulltile = (recipe.crafting_flags & CRAFT_IS_FULLTILE)))
			builder.balloon_alert(builder, "won't fit here!")
			return FALSE

	if(recipe.crafting_flags & CRAFT_ON_SOLID_GROUND)
		if(!isopenturf(dest_turf))
			builder.balloon_alert(builder, "can't be made on a wall!")
			return FALSE
		var/turf/open/open_turf = dest_turf
		if(!open_turf.allow_construction)
			builder.balloon_alert(builder, "can't build here!")
			return FALSE

	var/area/area = get_area(dest_turf)
	if(area.area_flags & NO_CONSTRUCTION)
		builder.balloon_alert(builder, "can't be made in this area!")
		return FALSE

	if(recipe.crafting_flags & CRAFT_CHECK_DENSITY)
		for(var/obj/object in dest_turf)
			if(object.density && !(object.obj_flags & IGNORE_DENSITY) || object.obj_flags & BLOCKS_CONSTRUCTION)
				builder.balloon_alert(builder, "something is in the way!")
				return FALSE

	if(recipe.placement_checks & STACK_CHECK_CARDINALS)
		var/turf/nearby_turf
		for(var/direction in GLOB.cardinals)
			nearby_turf = get_step(dest_turf, direction)
			if(locate(recipe.result_type) in nearby_turf)
				to_chat(builder, span_warning("\The [recipe.title] must not be built directly adjacent to another!"))
				builder.balloon_alert(builder, "can't be adjacent to another!")
				return FALSE

	if(recipe.placement_checks & STACK_CHECK_ADJACENT)
		if(locate(recipe.result_type) in range(1, dest_turf))
			builder.balloon_alert(builder, "can't be near another!")
			return FALSE

	return TRUE


/obj/item/stack/use(used)
	if(used > amount) //If it's larger than what we have, no go.
		return FALSE
	amount -= used
	if(zero_amount())
		return TRUE
	update_icon()
	update_weight()
	return TRUE


/obj/item/stack/proc/zero_amount()
	if(amount < 1)
		qdel(src)
		return TRUE
	return FALSE


/obj/item/stack/proc/add(extra)
	if(amount + extra > max_amount)
		return FALSE
	amount += extra
	update_icon()
	update_weight()
	return TRUE


/obj/item/stack/proc/get_amount()
	return amount


/obj/item/stack/proc/add_to_stacks(mob/user)
	for(var/obj/item/stack/S in get_turf(user))
		if(S.merge_type != merge_type)
			continue
		merge(S)
		if(QDELETED(src))
			return


/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/max_transfer = loc.max_stack_merging(S) //We don't want to bypass the max size the container allows.
	var/transfer = min(get_amount(), (max_transfer ? max_transfer : S.max_amount) - S.amount)
	S.add(transfer)
	use(transfer)
	return transfer


/obj/item/stack/proc/on_cross(datum/source, obj/item/stack/S, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(istype(S, merge_type) && !S.throwing)
		merge(S)


//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() == src)
		return change_stack(user, 1)
	return ..()


/obj/item/stack/AltClick(mob/user)
	if(isxeno(user))
		return ..()
	if(!can_interact(user))
		return ..() //Alt click on turf if not human or too far away.
	var/stackmaterial = tgui_input_number(user, "How many sheets do you wish to take out of this stack ?)", max_value = get_amount())
	stackmaterial = min(get_amount(), stackmaterial) //The amount could have changed since the input started.
	if(stackmaterial < 1 || !can_interact(user)) //In case we were transformed or moved away since the input started.
		return
	change_stack(user, stackmaterial)
	to_chat(user, span_notice("You take [stackmaterial] sheets out of the stack"))


/obj/item/stack/proc/change_stack(mob/user, new_amount)
	if(amount < 1 || amount < new_amount)
		stack_trace("[src] tried to change_stack() by [new_amount] amount for [user] user, while having [amount] amount itself.")
		return
	var/obj/item/stack/S = new type(user, new_amount)
	use(new_amount)
	user.put_in_hands(S)


/obj/item/stack/attackby(obj/item/I, mob/user)
	if(istype(I, merge_type))
		var/obj/item/stack/S = I
		if(merge(S))
			to_chat(user, span_notice("Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s."))
		return
	return ..()

/// Proc for special actions and radial menus on subtypes. Returning FALSE cancels the recipe menu for a stack.
/obj/item/stack/proc/select_radial(mob/user)
	return TRUE

/**
	Merges stack into the one that user is currently holding in their left or right hand.
	Returns TRUE if the stack was merged, FALSE otherwise.
*/
/obj/item/stack/proc/merge_with_stack_in_hands(mob/user)
	var/obj/item/stack/stack_in_hands = null
	if(istype(user.l_hand, merge_type))
		stack_in_hands = user.l_hand
	else if(istype(user.r_hand, merge_type))
		stack_in_hands = user.r_hand
	if(stack_in_hands && merge(stack_in_hands))
		return TRUE
	return FALSE


#undef STACK_CHECK_CARDINALS
#undef STACK_CHECK_ADJACENT
