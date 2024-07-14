/*!

This component makes it possible to make things edible. What this means is that you can take a bite or force someone to take a bite (in the case of items).
These items take a specific time to eat, and can do most of the things our original food items could.

Behavior that's still missing from this component that original food items had that should either be put into separate components or somewhere else:
	Components:
	Drying component (jerky etc)
	Processable component (Slicing and cooking behavior essentialy, making it go from item A to B when conditions are met.)

	Misc:
	Something for cakes (You can store things inside)

*/
/datum/component/edible
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	///Flags for food
	var/food_flags = NONE
	///Bitfield of the types of this food
	var/foodtypes = NONE
	///Amount of seconds it takes to eat this food
	var/eat_time = 30
	///Defines how much it lowers someones satiety (Need to eat, essentialy)
	var/junkiness = 0
	///Message to send when eating
	var/list/eatverbs
	///Callback to be ran for when you take a bite of something
	var/datum/callback/after_eat
	///Callback to be ran for when you finish eating something
	var/datum/callback/on_consume
	///Callback to be ran for when the code check if the food is liked, allowing for unique overrides for special foods like donuts with cops.
	var/datum/callback/check_liked
	///Last time we checked for food likes
	var/last_check_time
	///The initial volume of the foods reagents
	var/volume = 50
	///The flavortext for taste (haha get it flavor text)
	var/list/tastes

/datum/component/edible/Initialize(
	list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume = 50,
	eat_time = 1 SECONDS,
	list/tastes,
	list/eatverbs = list("bite", "chew", "nibble", "gnaw", "gobble", "chomp"),
	bite_consumption = 2,
	junkiness,
	datum/callback/after_eat,
	datum/callback/on_consume,
	datum/callback/check_liked,
	reagent_purity = 0.5,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.volume = volume
	src.eat_time = eat_time
	src.eatverbs = string_list(eatverbs)
	src.junkiness = junkiness
	src.after_eat = after_eat
	src.on_consume = on_consume
	src.tastes = string_assoc_list(tastes)
	src.check_liked = check_liked

	setup_initial_reagents(initial_reagents, reagent_purity)

/datum/component/edible/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_CHECKPARTS, PROC_REF(OnCraft))
	RegisterSignal(parent, COMSIG_ATOM_CREATEDBY_PROCESSING, PROC_REF(OnProcessed))
	RegisterSignal(parent, COMSIG_FOOD_INGREDIENT_ADDED, PROC_REF(edible_ingredient_added))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(UseFromHand))
		RegisterSignal(parent, COMSIG_ITEM_USED_AS_INGREDIENT, PROC_REF(used_to_customize))

		var/obj/item/item = parent
		if(!item.grind_results)
			item.grind_results = list() //If this doesn't already exist, add it as an empty list. This is needed for the grinder to accept it.

	else if(isturf(parent) || isstructure(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(TryToEatIt))

/datum/component/edible/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_CHECKPARTS,
		COMSIG_ATOM_CREATEDBY_PROCESSING,
		COMSIG_ATOM_ENTERED,
		COMSIG_FOOD_INGREDIENT_ADDED,
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_USED_AS_INGREDIENT,
		COMSIG_ATOM_EXAMINE,
	))

	qdel(GetComponent(/datum/component/connect_loc_behalf))

/datum/component/edible/InheritComponent(
	datum/component/edible/old_comp,
	i_am_original,
	list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume,
	eat_time,
	list/tastes,
	list/eatverbs,
	bite_consumption,
	junkiness,
	datum/callback/after_eat,
	datum/callback/on_consume,
	datum/callback/check_liked,
)

	// If we got passed an old comp, take only the values that will not override our current ones
	if(old_comp)
		food_flags = old_comp.food_flags
		foodtypes = old_comp.foodtypes
		tastes = old_comp.tastes
		eatverbs = old_comp.eatverbs

	// only edit if we're OG
	if(!i_am_original)
		return

	// add food flags and types
	src.food_flags |= food_flags
	src.foodtypes |= foodtypes

	// add all new eatverbs to the list
	if(islist(eatverbs))
		var/list/cached_verbs = src.eatverbs
		if(islist(cached_verbs))
			// eatverbs becomes a combination of existing verbs and new ones
			src.eatverbs = string_list(cached_verbs | eatverbs)
		else
			src.eatverbs = string_list(eatverbs)

	// add all new tastes to the tastes
	if(islist(tastes))
		var/list/cached_tastes = src.tastes
		if(islist(cached_tastes))
			// tastes becomes a combination of existing tastes and new ones
			var/list/mixed_tastes = cached_tastes.Copy()
			for(var/new_taste in tastes)
				mixed_tastes[new_taste] += tastes[new_taste]

			src.tastes = string_assoc_list(mixed_tastes)
		else
			src.tastes = string_assoc_list(tastes)

	// just set these directly
	if(!isnull(bite_consumption))
		src.bite_consumption = bite_consumption
	if(!isnull(volume))
		src.volume = volume
	if(!isnull(eat_time))
		src.eat_time = eat_time
	if(!isnull(junkiness))
		src.junkiness = junkiness
	if(!isnull(after_eat))
		src.after_eat = after_eat
	if(!isnull(on_consume))
		src.on_consume = on_consume
	if(!isnull(check_liked))
		src.check_liked = check_liked

	// add newly passed in reagents
	setup_initial_reagents(initial_reagents)

/datum/component/edible/Destroy(force)
	after_eat = null
	on_consume = null
	check_liked = null
	return ..()

/// Sets up the initial reagents of the food.
/datum/component/edible/proc/setup_initial_reagents(list/reagents, reagent_purity)
	var/atom/owner = parent
	if(owner.reagents)
		owner.reagents.maximum_volume = volume
	else
		owner.create_reagents(volume, INJECTABLE)

	for(var/rid in reagents)
		var/amount = reagents[rid]
		if(length(tastes) && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
			owner.reagents.add_reagent(rid, amount)
		else
			owner.reagents.add_reagent(rid, amount)

/datum/component/edible/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/atom/owner = parent

	if(foodtypes)
		var/list/types = bitfield_to_list(foodtypes, FOOD_FLAGS)
		examine_list += span_notice("It is [LOWER_TEXT(english_list(types))].")

	var/quality = get_perceived_food_quality(user)
	if(quality > 0)
		var/quality_label = GLOB.food_quality_description[quality]
		examine_list += span_green("You find this meal [quality_label].")
	else if (quality == 0)
		examine_list += span_notice("You find this meal edible.")
	else
		examine_list += span_warning("You find this meal inedible.")

	var/datum/mind/mind = user.mind
	if(mind && HAS_TRAIT_FROM(owner, TRAIT_FOOD_CHEF_MADE, REF(mind)))
		examine_list += span_green("[owner] was made by you!")

	if(!(food_flags & FOOD_IN_CONTAINER))
		switch(bitecount)
			if(0)
				pass()
			if(1)
				examine_list += span_notice("[owner] was bitten by someone!")
			if(2, 3)
				examine_list += span_notice("[owner] was bitten [bitecount] times!")
			else
				examine_list += span_notice("[owner] was bitten multiple times!")

	//var/fraction = min(bite_consumption / owner.reagents.total_volume, 1) //Defined but no used? Scared of deleting it. Maybe I fucked something up -LDip999
	if (!owner.reagents.get_reagent_amount(/datum/reagent/consumable/salt))
		examine_list += span_notice("It could use a little more Sodium Chloride...")
	if (isliving(user))
		var/mob/living/living_user = user
		living_user.taste(owner.reagents)

/datum/component/edible/proc/UseFromHand(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	return TryToEat(M, user)

/datum/component/edible/proc/TryToEatIt(datum/source, mob/user)
	SIGNAL_HANDLER

	if (!in_range(source, user))
		return
	return TryToEat(user, user)

///Called when food is created through processing (Usually this means it was sliced). We use this to pass the OG items reagents.
/datum/component/edible/proc/OnProcessed(datum/source, atom/original_atom, list/chosen_processing_option)
	SIGNAL_HANDLER

	if(!original_atom.reagents)
		return

	var/atom/this_food = parent

	//Make sure we have a reagent container large enough to fit the original atom's reagents.
	volume = max(volume, ROUND_UP(original_atom.reagents.maximum_volume / chosen_processing_option[TOOL_PROCESSING_AMOUNT]))

	this_food.create_reagents(volume)
	original_atom.reagents.copy_to(this_food, original_atom.reagents.total_volume / chosen_processing_option[TOOL_PROCESSING_AMOUNT], 1)

	if(original_atom.name != initial(original_atom.name))
		this_food.name = "slice of [original_atom.name]"
	if(original_atom.desc != initial(original_atom.desc))
		this_food.desc = "[original_atom.desc]"

///Called when food is crafted through a crafting recipe datum.
/datum/component/edible/proc/OnCraft(datum/source, list/parts_list, datum/crafting_recipe/food/recipe)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	for(var/obj/item/food/crafted_part in parts_list)
		if(!crafted_part.reagents)
			continue
		this_food.reagents.maximum_volume += crafted_part.reagents.maximum_volume
		crafted_part.reagents.trans_to(this_food.reagents, crafted_part.reagents.maximum_volume)

	this_food.reagents.maximum_volume = ROUND_UP(this_food.reagents.maximum_volume) // Just because I like whole numbers for this.

///Makes sure the thing hasn't been destroyed or fully eaten to prevent eating phantom edibles
/datum/component/edible/proc/IsFoodGone(atom/owner, mob/living/feeder)
	if(QDELETED(owner) || !(IS_EDIBLE(owner)))
		return TRUE
	if(owner.reagents.total_volume)
		return FALSE
	return TRUE

/// Normal time to forcefeed someone something
#define EAT_TIME_FORCE_FEED (3 SECONDS)
/// Multiplier for eat time if the eater has TRAIT_VORACIOUS

///All the checks for the act of eating itself and
/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder)

	set waitfor = FALSE

	var/atom/owner = parent


	if(IsFoodGone(owner, feeder))
		return

	if(!CanConsume(eater, feeder))
		return
	if(!iscarbon(eater))
		return
	var/mob/living/carbon/eaterc = eater
	var/fullness = eaterc.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this
	var/time_to_eat = (eaterc == feeder) ? eat_time : EAT_TIME_FORCE_FEED
	time_to_eat *= (fullness / NUTRITION_OVERFED) // takes longer to eat the more well fed you are
	if(eater == feeder)//If you're eating it yourself.
		if(eat_time > 0 && !do_after(feeder, time_to_eat, eater, timed_action_flags = food_flags & FOOD_FINGER_FOOD ? IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE : NONE)) //Gotta pass the minimal eat time
			return
		if(IsFoodGone(owner, feeder))
			return
		var/eatverb = pick(eatverbs)
		var/message_to_nearby_audience = ""
		var/message_to_consumer = ""
		if(junkiness && eaterc.nutrition < -150 && eaterc.nutrition > NUTRITION_STARVING + 50)
			to_chat(eater, span_warning("You don't feel like eating any more junk food at the moment!"))
			return
		else if(fullness > NUTRITION_OVERFED)
			message_to_nearby_audience = span_warning("[eater] cannot force any more of \the [parent] to go down [eater.p_their()] throat!")
			message_to_consumer = span_warning("You cannot force any more of \the [parent] to go down your throat!")
			eater.show_message(message_to_consumer)
			eater.visible_message(message_to_nearby_audience, ignored_mob = eater)
			//if we're too full, return because we can't eat whatever it is we're trying to eat
			return
		else if(fullness > NUTRITION_WELLFED)
			message_to_nearby_audience = span_notice("[eater] unwillingly [eatverb]s a bit of \the [parent].")
			message_to_consumer = span_notice("You unwillingly [eatverb] a bit of \the [parent].")
		else if(fullness > NUTRITION_HUNGRY)
			message_to_nearby_audience = span_notice("[eater] [eatverb]s \the [parent].")
			message_to_consumer = span_notice("You [eatverb] \the [parent].")
		else if(fullness > NUTRITION_STARVING)
			message_to_nearby_audience = span_notice("[eater] hungrily [eatverb]s \the [parent].")
			message_to_consumer = span_notice("You hungrily [eatverb] \the [parent].")
		else
			message_to_nearby_audience = span_notice("[eater] hungrily [eatverb]s \the [parent], gobbling it down!")
			message_to_consumer = span_notice("You hungrily [eatverb] \the [parent], gobbling it down!")
		eater.show_message(message_to_consumer)
		eater.visible_message(message_to_nearby_audience, ignored_mob = eater)

	else //If you're feeding it to someone else.
		if(fullness <= NUTRITION_OVERFED)
			eater.visible_message(
				span_danger("[feeder] attempts to [eater.get_bodypart(BODY_ZONE_HEAD) ? "feed [eater] [parent]." : "stuff [parent] down [eater]'s throat hole! Gross."]"),
				span_userdanger("[feeder] attempts to [eater.get_bodypart(BODY_ZONE_HEAD) ? "feed you [parent]." : "stuff [parent] down your throat hole! Gross."]")
			)
		else
			eater.visible_message(
				span_danger("[feeder] cannot force any more of [parent] down [eater]'s [eater.get_bodypart(BODY_ZONE_HEAD) ? "throat!" : "throat hole! Eugh."]"),
				span_userdanger("[feeder] cannot force any more of [parent] down your [eater.get_bodypart(BODY_ZONE_HEAD) ? "throat!" : "throat hole! Eugh."]")
			)
			return
		if(!do_after(feeder, delay = time_to_eat, target = eater)) //Wait 3-ish seconds before you can feed
			return
		if(IsFoodGone(owner, feeder))
			return
		eater.visible_message(
			span_danger("[feeder] forces [eater] to eat [parent]!"),
			span_userdanger("[feeder] forces you to eat [parent]!")
		)

	TakeBite(eater, feeder)

	//If we're not force-feeding and there's an eat delay, try take another bite
	if(eater == feeder && eat_time > 0)
		INVOKE_ASYNC(src, PROC_REF(TryToEat), eater, feeder)

#undef EAT_TIME_FORCE_FEED

///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/TakeBite(mob/living/carbon/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		stack_trace("[eater] failed to bite [owner], because [owner] had no reagents.")
		return FALSE
	if(eater.nutrition > -200)
		eater.nutrition -= junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(!owner.reagents.total_volume)
		return
	var/sig_return = SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder, bitecount, bite_consumption)
	if(sig_return & DESTROY_FOOD)
		qdel(owner)
		return

	//Give a buff when the dish is hand-crafted and unbitten
	if(bitecount == 0)
		apply_buff(eater)

	var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
	owner.reagents.trans_to(eater, bite_consumption)
	bitecount++

	checkLiked(fraction, eater)

	if(!owner.reagents.total_volume)
		On_Consume(eater, feeder)

	//Invoke our after eat callback if it is valid
	if(after_eat)
		after_eat.Invoke(eater, feeder, bitecount)
	return TRUE

///Checks whether or not the eater can actually consume the food
/datum/component/edible/proc/CanConsume(mob/living/carbon/eater, mob/living/feeder)
	if(!iscarbon(eater))
		return FALSE
	if(eater.is_mouth_covered())
		eater.balloon_alert(feeder, "mouth is covered!")
		return FALSE

	var/atom/food = parent

	if(SEND_SIGNAL(eater, COMSIG_CARBON_ATTEMPT_EAT, food) & COMSIG_CARBON_BLOCK_EAT)
		return
	return TRUE

///Applies food buffs according to the crafting complexity
/datum/component/edible/proc/apply_buff(mob/eater)
	var/buff
	var/recipe_complexity = get_recipe_complexity()
	if(recipe_complexity == 0)
		return
	var/obj/item/food/food = parent
	if(!isnull(food.crafted_food_buff))
		buff = food.crafted_food_buff
	else
		buff = pick_weight(GLOB.food_buffs[recipe_complexity])
	if(!isnull(buff))
		var/mob/living/living_eater = eater
		var/timeout_mod = 1 // buff duration is 100% at average purity of 50%
		var/strength = recipe_complexity
		living_eater.apply_status_effect(buff, timeout_mod, strength)

///Check foodtypes to see if we should send a moodlet
/datum/component/edible/proc/checkLiked(fraction, mob/eater)
	if(last_check_time + 50 > world.time)
		return FALSE
	if(!ishuman(eater))
		return FALSE
	var/mob/living/carbon/human/gourmand = eater


	var/food_quality = get_perceived_food_quality(gourmand)
	if(food_quality < 0)
		to_chat(gourmand,span_notice("That didn't taste very good..."))
		return

	if(food_quality == 0)
		return // meh

	food_quality = min(food_quality, FOOD_QUALITY_TOP)
	var/quality_label = GLOB.food_quality_description[food_quality]
	to_chat(gourmand, span_notice("That's \an [quality_label] meal."))

/// Get the complexity of the crafted food
/datum/component/edible/proc/get_recipe_complexity()
	if(!HAS_TRAIT(parent, TRAIT_FOOD_CHEF_MADE) || !istype(parent, /obj/item/food))
		return 0 // It is factory made. Soulless.
	var/obj/item/food/food = parent
	return food.crafting_complexity

/// Get food quality adjusted according to eater's preferences
/datum/component/edible/proc/get_perceived_food_quality(mob/living/carbon/human/eater)
	var/food_quality = get_recipe_complexity()
	return food_quality

/// Get the number of matching food types in provided bitfields
/datum/component/edible/proc/count_matching_foodtypes(bitfield_one, bitfield_two)
	var/count = 0
	var/matching_bits = bitfield_one & bitfield_two
	while (matching_bits > 0)
		if (matching_bits & 1)
			count++
		matching_bits >>= 1
	return count

///Delete the item when it is fully eaten
/datum/component/edible/proc/On_Consume(mob/living/eater, mob/living/feeder)
	SEND_SIGNAL(parent, COMSIG_FOOD_CONSUMED, eater, feeder)

	on_consume?.Invoke(eater, feeder)
	if (QDELETED(parent)) // might be destroyed by the callback
		to_chat(feeder, span_warning("There is nothing left of [parent], oh no!"))
		return
	qdel(parent)
	to_chat(feeder, span_warning("There is nothing left of [parent], oh no!"))


///Response to being used to customize something
/datum/component/edible/proc/used_to_customize(datum/source, atom/customized)
	SIGNAL_HANDLER

	SEND_SIGNAL(customized, COMSIG_FOOD_INGREDIENT_ADDED, src)

///Response to an edible ingredient being added to parent.
/datum/component/edible/proc/edible_ingredient_added(datum/source, datum/component/edible/ingredient)
	SIGNAL_HANDLER

	InheritComponent(ingredient, TRUE)
