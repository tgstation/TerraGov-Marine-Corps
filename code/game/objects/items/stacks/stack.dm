/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

#define STACK_WEIGHT_STEPS 3 //Currently weight updates in 3 intervals

/*
 * Stacks
 */
/obj/item/stack
	icon = 'icons/obj/stack_objects.dmi'
	gender = PLURAL
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/merge_type // This path and its children should merge with this stack, defaults to src.type
	var/number_of_extra_variants = 0 //Determines whether the item should update it's sprites based on amount.
	origin_tech = "materials=1"


/obj/item/stack/New(loc, new_amount)
	. = ..()
	if(new_amount)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount)
	if(!merge_type)
		merge_type = type
	update_weight()
	update_icon()


/obj/item/stack/proc/update_weight()
	var/percent = round((amount * 100) / max_amount)
	var/full_w_class = initial(w_class)
	var/new_w_class
	switch(percent) //Currently 3 steps as defined by STACK_WEIGHT_STEPS
		if(0 to 33)
			new_w_class = CLAMP(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
		if(34 to 66)
			new_w_class = CLAMP(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
		if(67 to 100)
			new_w_class = full_w_class
		else
			stack_trace("[src] tried to update_weight() with [amount] amount and [max_amount] max_amount.")
	if(new_w_class != w_class)
		w_class = new_w_class
		loc?.recalculate_storage_space() //No need to do icon updates if there are no changes.


/obj/item/stack/update_icon()
	if(!number_of_extra_variants)
		return
	var/ratio = round((amount * (number_of_extra_variants + 1)) / max_amount)
	if(ratio < 1)
		icon_state = initial(icon_state)
		return
	ratio = min(ratio + 1, number_of_extra_variants + 1)
	icon_state = "[initial(icon_state)]_[ratio]"


/obj/item/stack/Destroy()
	if(usr && usr.interactee == src)
		usr << browse(null, "window=stack")
	return ..()


/obj/item/stack/examine(mob/user)
	. = ..()
	to_chat(user, "There are [amount] [singular_name]\s in the stack.")


/obj/item/stack/attack_self(mob/user)
	interact(user)


/obj/item/stack/interact(mob/user, sublist)
	ui_interact(user, sublist)


/obj/item/stack/ui_interact(mob/user, recipes_sublist)
	. = ..()
	if(!recipes)
		return
	if(QDELETED(src) || get_amount() <= 0)
		user << browse(null, "window=stack")
	user.set_interaction(src) //for correct work of onclose
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
			t1 += "<a href='?src=[REF(src)];sublist=[i]'>[srl.title]</a>"

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
				t1 += text("<A href='?src=[REF(src)];sublist=[recipes_sublist];make=[i];multiplier=1'>[title]</A>  ")
			else
				t1 += text("[]", title)
				continue
			if(R.max_res_amount > 1 && max_multiplier > 1)
				max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
				t1 += " |"
				var/list/multipliers = list(5,10,25)
				for(var/n in multipliers)
					if(max_multiplier >= n)
						t1 += " <A href='?src=[REF(src)];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
				if(!(max_multiplier in multipliers))
					t1 += " <A href='?src=[REF(src)];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	var/datum/browser/popup = new(user, "stack", name, 400, 400)
	popup.set_content(t1)
	popup.open(FALSE)
	onclose(user, "stack")


/obj/item/stack/Topic(href, href_list)
	. = ..()
	if(usr.incapacitated() || usr.get_active_held_item() != src)
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
		if(multiplier <= 0) //href protection
			return
		if(!building_checks(R, multiplier))
			return
		if(usr.action_busy)
			return
		var/building_time = R.time
		if(R.skill_req && usr.mind?.cm_skills?.construction < R.skill_req)
			building_time += R.time * ( R.skill_req - usr.mind.cm_skills.construction ) * 0.5 // +50% time each skill point lacking.
		if(building_time)
			if(building_time > R.time)
				usr.visible_message("<span class='notice'>[usr] fumbles around figuring out how to build \a [R.title].</span>",
				"<span class='notice'>You fumble around figuring out how to build \a [R.title].</span>")
			else
				usr.visible_message("<span class='notice'>[usr] starts building \a [R.title].</span>",
				"<span class='notice'>You start building \a [R.title]...</span>")
			if(!do_after(usr, building_time, TRUE, src, BUSY_ICON_BUILD))
				return
			if(!building_checks(R, multiplier))
				return

		var/obj/O
		if(R.max_res_amount > 1) //Is it a stack?
			O = new R.result_type(get_turf(usr), R.res_amount * multiplier)
		else if(ispath(R.result_type, /turf))
			var/turf/T = get_turf(usr)
			if(!isturf(T))
				return
			T.PlaceOnTop(R.result_type)
		else
			O = new R.result_type(get_turf(usr))
		if(O)
			O.setDir(usr.dir)
		use(R.req_amount * multiplier)

		if(QDELETED(O))
			return //It's a stack and has already been merged

		if(isitem(O))
			usr.put_in_hands(O)
		O.add_fingerprint(usr)

		//BubbleWrap - so newly formed boxes are empty
		if(istype(O, /obj/item/storage))
			for(var/obj/item/I in O)
				qdel(I)
		//BubbleWrap END


/obj/item/stack/proc/building_checks(datum/stack_recipe/R, multiplier)
	if (get_amount() < R.req_amount*multiplier)
		if (R.req_amount*multiplier>1)
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>")
		else
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
		return FALSE
	var/turf/T = get_turf(usr)

	if(R.one_per_turf && (locate(R.result_type) in T))
		to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
		return FALSE
	if(R.on_floor)
		if(!isfloorturf(T))
			to_chat(usr, "<span class='warning'>\The [R.title] must be constructed on the floor!</span>")
			return FALSE
		for(var/obj/AM in T)
			if(istype(AM,/obj/structure/grille))
				continue
			if(istype(AM,/obj/structure/table))
				continue
			if(istype(AM,/obj/structure/window))
				var/obj/structure/window/W = AM
				if(!W.is_full_window() && W.dir != usr.dir)
					continue
			if(AM.density)
				to_chat(usr, "<span class='warning'>Theres a [AM.name] here. You cant make a [R.title] here!</span>")
				return FALSE
	return TRUE


/obj/item/stack/proc/use(used)
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
	transfer_fingerprints_to(S)
	S.add(transfer)
	use(transfer)
	return transfer


/obj/item/stack/Crossed(obj/item/stack/S)
	if(istype(S, merge_type) && !S.throwing)
		merge(S)
	return ..()


//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user)
	add_fingerprint(user)
	if(user.get_inactive_held_item() == src)
		return change_stack(user, 1)
	return ..()


/obj/item/stack/AltClick(mob/user)
	if(!user.canUseTopic(src))
		return ..() //Alt click on turf if not human or too far away.
	var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [get_amount()])") as null|num)
	stackmaterial = min(get_amount(), stackmaterial) //The amount could have changed since the input started.
	if(stackmaterial < 1 || !user.canUseTopic(src)) //In case we were transformed or moved away since the input started.
		return
	change_stack(user, stackmaterial)
	to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack</span>")


/obj/item/stack/proc/change_stack(mob/user, new_amount)
	if(amount < 1 || amount < new_amount)
		stack_trace("[src] tried to change_stack() by [new_amount] amount for [user] user, while having [amount] amount itself.")
		return
	var/obj/item/stack/S = new type(user, new_amount)
	transfer_fingerprints_to(S)
	use(new_amount)
	user.put_in_hands(S)


/obj/item/stack/attackby(obj/item/I, mob/user)
	if(istype(I, merge_type))
		var/obj/item/stack/S = I
		if(merge(S))
			to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
		return
	return ..()

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = FALSE
	var/on_floor = FALSE
	var/skill_req = FALSE //whether only people with sufficient construction skill can build this.


/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = FALSE, on_floor = FALSE, skill_req = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.skill_req = skill_req

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes
	var/req_amount = 1

/datum/stack_recipe_list/New(title, recipes, req_amount = 1)
	src.title = title
	src.recipes = recipes
	src.req_amount = req_amount