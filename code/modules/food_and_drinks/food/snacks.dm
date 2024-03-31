/** # Snacks

Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units. Generally speaking, you don't want to go over 40
total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use omnizine). On use
effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
the bites. No more contained reagents = no more bites.

Here is an example of the new formatting for anyone who wants to add more food items.
```
/obj/item/reagent_containers/food/snacks/xenoburger			//Identification path for the object.
	name = "Xenoburger"													//Name that displays in the UI.
	desc = ""						//Duh
	icon_state = "xburger"												//Refers to an icon in food.dmi
/obj/item/reagent_containers/food/snacks/xenoburger/Initialize()		//Don't mess with this. | nO I WILL MESS WITH THIS
	. = ..()														//Same here.
	reagents.add_reagent(/datum/reagent/xenomicrobes, 10)						//This is what is in the food item. you may copy/paste
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 2)							//this line of code for all the contents.
	bitesize = 3													//This is the amount each bite consumes.
```

All foods are distributed among various categories. Use common sense.
*/
/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = ""
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	grind_results = list() //To let them be ground up to transfer their reagents
	possible_item_intents = list(/datum/intent/food)
	var/bitesize = 3
	var/bitecount = 0
	var/trash = null
	var/slice_path    // for sliceable food. path of the item resulting from the slicing
	var/slice_bclass = BCLASS_CUT
	var/slices_num
	var/slice_batch = TRUE
	var/eatverb
	var/dried_type = null
	var/dry = 0
	var/dunkable = FALSE // for dunkable food, make true
	var/dunk_amount = 10 // how much reagent is transferred per dunk
	var/cooked_type = null  //for overn cooking
	var/fried_type = null	//instead of becoming
	var/filling_color = "#FFFFFF" //color to use when added to custom food.
	var/custom_food_type = null  //for food customizing. path of the custom food to create
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/list/bonus_reagents //the amount of reagents (usually nutriment and vitamin) added to crafted/cooked snacks, on top of the ingredients reagents.
	var/customfoodfilling = 1 // whether it can be used as filling in custom food
	var/list/tastes  // for example list("crisps" = 2, "salt" = 1)

	var/cooking = 0
	var/cooktime = 0
	var/burning = 0
	var/burntime = 5 MINUTES
	var/warming = 5 MINUTES		//if greater than 0, have a brief period where the food buff applies while its still hot

	var/cooked_color = "#91665c"
	var/burned_color = "#302d2d"

	var/ingredient_size = 1
	var/eat_effect
	var/rotprocess = FALSE
	var/become_rot_type = null

	var/mill_result = null

	var/fertamount = 50

	drop_sound = 'sound/foley/dropsound/food_drop.ogg'
	smeltresult = /obj/item/ash
	//Placeholder for effect that trigger on eating that aren't tied to reagents.

/datum/intent/food
	name = "feed"
	noaa = TRUE
	icon_state = "infeed"
	rmb_ranged = TRUE
	no_attack = TRUE

/datum/intent/food/rmb_ranged(atom/target, mob/user)
	if(ismob(target))
		var/mob/M = target
		var/list/targetl = list(target)
		user.visible_message("<span class='green'>[user] beckons [M] with [masteritem].</span>", "<span class='green'>I beckon [M] with [masteritem].</span>", ignored_mobs = targetl)
		if(M.client)
			if(M.can_see_cone(user))
				to_chat(M, "<span class='green'>[user] beckons me with [masteritem].</span>")
		M.food_tempted(masteritem, user)
	return

/obj/item/reagent_containers/food/snacks/fire_act(added, maxstacks)
	burning(1 MINUTES)

/obj/item/reagent_containers/food/snacks/Initialize()
	if(rotprocess)
		SSticker.OnRoundstart(CALLBACK(src, .proc/begin_rotting))
	if(cooked_type || fried_type)
		cooktime = 30 SECONDS
	..()

/obj/item/reagent_containers/food/snacks/proc/begin_rotting()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/process()
	..()
	if(rotprocess)
		if(!istype(loc, /obj/structure/closet/crate/chest))
			warming -= 20 //ssobj processing has a wait of 20
			if(warming < (-1*rotprocess))
				if(become_rotten())
					STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/can_craft_with()
	if(eat_effect == /datum/status_effect/debuff/rotfood)
		return FALSE
	return ..()

/obj/item/reagent_containers/food/snacks/proc/become_rotten()
	if(become_rot_type)
		if(ismob(loc))
			return FALSE
		else
			var/obj/item/reagent_containers/NU = new become_rot_type(loc)
			NU.reagents.clear_reagents()
			reagents.trans_to(NU.reagents, reagents.maximum_volume)
			qdel(src)
			return TRUE
	else
		color = "#6c6897"
		var/mutable_appearance/rotflies = mutable_appearance('icons/roguetown/mob/rotten.dmi', "rotten")
		add_overlay(rotflies)
		name = "rotten [initial(name)]"
		eat_effect = /datum/status_effect/debuff/rotfood
		slices_num = 0
		slice_path = null
		cooktime = 0
		return TRUE


/obj/item/proc/cooking(input as num)
	return

/obj/item/reagent_containers/food/snacks/cooking(input as num, atom/A)
	if(!input)
		return
	if(cooktime)
		if(cooking < cooktime)
			cooking = cooking + input
			if(cooking >= cooktime)
				return microwave_act(A)
			warming = 5 MINUTES
			return
	burning(input)

/obj/item/reagent_containers/food/snacks/microwave_act(atom/A)
	if(istype(A,/obj/machinery/light/rogue/oven))
		var/obj/item/result
		if(cooked_type)
			result = new cooked_type(A)
		else
			result = new /obj/item/reagent_containers/food/snacks/badrecipe(A)
		initialize_cooked_food(result, 1)
		return result
	if(istype(A,/obj/machinery/light/rogue/hearth) || istype(A,/obj/machinery/light/rogue/firebowl))
		var/obj/item/result
		if(fried_type)
			result = new fried_type(A)
		else
			result = new /obj/item/reagent_containers/food/snacks/badrecipe(A)
		initialize_cooked_food(result, 1)
		return result
	var/obj/item/result = new /obj/item/reagent_containers/food/snacks/badrecipe(A)
	initialize_cooked_food(result, 1)
	return result

/obj/item/proc/burning(input as num)
	return

/obj/item/reagent_containers/food/snacks/burning(input as num) //used for pans without oil, skips the cooking stage
	if(!input)
		return
	warming = 5 MINUTES
	if(burntime)
		burning = burning + input
		if(eat_effect != /datum/status_effect/debuff/burnedfood)
			if(burning >= burntime)
				color = burned_color
				name = "burned [name]"
				slice_path = null
				eat_effect = /datum/status_effect/debuff/burnedfood
		if(burning > (burntime * 2))
			burn()

/obj/item/reagent_containers/food/snacks/add_initial_reagents()
	create_reagents(volume)
	if(tastes && tastes.len)
		if(list_reagents)
			for(var/rid in list_reagents)
				var/amount = list_reagents[rid]
				if(rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin)
					reagents.add_reagent(rid, amount, tastes.Copy())
				else
					reagents.add_reagent(rid, amount)
	else
		..()

/obj/item/reagent_containers/food/snacks/proc/On_Consume(mob/living/eater)
	if(!eater)
		return

	if(eat_effect)
		eater.apply_status_effect(eat_effect)
	eater.taste(reagents)

	if(!reagents.total_volume)
		var/mob/living/location = loc
		var/obj/item/trash_item = generate_trash(location)
		qdel(src)
		if(istype(location))
			location.put_in_hands(trash_item)

/obj/item/reagent_containers/food/snacks/attack_self(mob/user)
	return


/obj/item/reagent_containers/food/snacks/attack(mob/living/M, mob/living/user, def_zone)
	if(user.used_intent.type == INTENT_HARM)
		return ..()
	if(!eatverb)
		eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	if(iscarbon(M))
		if(!canconsume(M, user))
			return FALSE

		var/fullness = M.nutrition + 10
		for(var/datum/reagent/consumable/C in M.reagents.reagent_list) //we add the nutrition value of what we're currently digesting
			fullness += C.nutriment_factor * C.volume / C.metabolization_rate

		if(M == user)								//If you're eating it myself.
/*			if(junkiness && M.satiety < -150 && M.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(user, TRAIT_VORACIOUS))
				to_chat(M, "<span class='warning'>I don't feel like eating any more junk food at the moment!</span>")
				return FALSE
			else if(fullness <= 50)
				user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src], gobbling it down!</span>", "<span class='notice'>I hungrily [eatverb] \the [src], gobbling it down!</span>")
			else if(fullness > 50 && fullness < 150)
				user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src].</span>", "<span class='notice'>I hungrily [eatverb] \the [src].</span>")
			else if(fullness > 150 && fullness < 500)
				user.visible_message("<span class='notice'>[user] [eatverb]s \the [src].</span>", "<span class='notice'>I [eatverb] \the [src].</span>")
			else if(fullness > 500 && fullness < 600)
				user.visible_message("<span class='notice'>[user] unwillingly [eatverb]s a bit of \the [src].</span>", "<span class='notice'>I unwillingly [eatverb] a bit of \the [src].</span>")
			else if(fullness > (600 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				user.visible_message("<span class='warning'>[user] cannot force any more of \the [src] to go down [user.p_their()] throat!</span>", "<span class='warning'>I cannot force any more of \the [src] to go down your throat!</span>")
				return FALSE
			if(HAS_TRAIT(M, TRAIT_VORACIOUS))
				M.changeNext_move(CLICK_CD_MELEE * 0.5)*/
			switch(M.nutrition)
				if(NUTRITION_LEVEL_FAT to INFINITY)
					user.visible_message("<span class='notice'>[user] forces [M.p_them()]self to eat \the [src].</span>", "<span class='notice'>I force myself to eat \the [src].</span>")
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FAT)
					user.visible_message("<span class='notice'>[user] [eatverb]s \the [src].</span>", "<span class='notice'>I [eatverb] \the [src].</span>")
				if(0 to NUTRITION_LEVEL_STARVING)
					user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src], gobbling it down!</span>", "<span class='notice'>I hungrily [eatverb] \the [src], gobbling it down!</span>")
					M.changeNext_move(CLICK_CD_MELEE * 0.5)
/*			if(M.rogstam <= 50)
				user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src], gobbling it down!</span>", "<span class='notice'>I hungrily [eatverb] \the [src], gobbling it down!</span>")
			else if(M.rogstam > 50 && M.rogstam < 500)
				user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src].</span>", "<span class='notice'>I hungrily [eatverb] \the [src].</span>")
			else if(M.rogstam > 500 && M.rogstam < 1000)
				user.visible_message("<span class='notice'>[user] [eatverb]s \the [src].</span>", "<span class='notice'>I [eatverb] \the [src].</span>")
			if(HAS_TRAIT(M, TRAIT_VORACIOUS))
			M.changeNext_move(CLICK_CD_MELEE * 0.5) nom nom nom*/
		else
			if(!isbrain(M))		//If you're feeding it to someone else.
//				if(fullness <= (600 * (1 + M.overeatduration / 1000)))
				if(M.nutrition in NUTRITION_LEVEL_FAT to INFINITY)
					M.visible_message("<span class='warning'>[user] cannot force any more of [src] down [M]'s throat!</span>", \
										"<span class='warning'>[user] cannot force any more of [src] down your throat!</span>")
					return FALSE
				else
					M.visible_message("<span class='danger'>[user] tries to feed [M] [src].</span>", \
										"<span class='danger'>[user] tries to feed me [src].</span>")
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					var/obj/item/bodypart/CH = C.get_bodypart(BODY_ZONE_HEAD)
					if(C.cmode)
						if(!CH.grabbedby)
							to_chat(user, "<span class='info'>[C.p_they(TRUE)] steals [C.p_their()] face from it.</span>")
							return FALSE
				if(!do_mob(user, M))
					return
				log_combat(user, M, "fed", reagents.log_list())
//				M.visible_message("<span class='danger'>[user] forces [M] to eat [src]!</span>", \
//									"<span class='danger'>[user] forces you to eat [src]!</span>")

			else
				to_chat(user, "<span class='warning'>[M] doesn't seem to have a mouth!</span>")
				return

		if(reagents)								//Handle ingestion of the reagent.
			if(M.satiety > -200)
				M.satiety -= junkiness
			playsound(M.loc,'sound/misc/eat.ogg', rand(30,60), TRUE)
			if(reagents.total_volume)
				SEND_SIGNAL(src, COMSIG_FOOD_EATEN, M, user)
				var/fraction = min(bitesize / reagents.total_volume, 1)
				var/amt2take = reagents.total_volume / (bitesize - bitecount)
				if((bitecount >= bitesize) || (bitesize == 1))
					amt2take = reagents.total_volume
				reagents.trans_to(M, amt2take, transfered_by = user, method = INGEST)
				bitecount++
				On_Consume(M)
				checkLiked(fraction, M)
				if(bitecount >= bitesize)
					qdel(src)
				return TRUE
		playsound(M.loc,'sound/misc/eat.ogg', rand(30,60), TRUE)
		qdel(src)
		return FALSE

	return 0

/obj/item/reagent_containers/food/snacks/examine(mob/user)
	. = ..()
	if(!in_container)
		switch (bitecount)
			if (0)
				return
			if(1)
				. += "[src] was bitten by someone!"
			if(2,3)
				. += "[src] was bitten [bitecount] times!"
			else
				. += "[src] was bitten multiple times!"

/obj/item/reagent_containers/food/snacks/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage))
		..() // -> item/attackby()
		return 0
/*	if(istype(W, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = W
		if(custom_food_type && ispath(custom_food_type))
			if(S.w_class > WEIGHT_CLASS_SMALL)
				to_chat(user, "<span class='warning'>[S] is too big for [src]!</span>")
				return 0
			if(!S.customfoodfilling || istype(W, /obj/item/reagent_containers/food/snacks/customizable) || istype(W, /obj/item/reagent_containers/food/snacks/pizzaslice/custom) || istype(W, /obj/item/reagent_containers/food/snacks/cakeslice/custom))
				to_chat(user, "<span class='warning'>[src] can't be filled with [S]!</span>")
				return 0
			if(contents.len >= 20)
				to_chat(user, "<span class='warning'>I can't add more ingredients to [src]!</span>")
				return 0
			var/obj/item/reagent_containers/food/snacks/customizable/C = new custom_food_type(get_turf(src))
			C.initialize_custom_food(src, S, user)
			return 0*/
	if(user.used_intent.blade_class == slice_bclass && W.wlength == WLENGTH_SHORT)
		if(slice_bclass == BCLASS_CHOP)
			//	RTD meat chopping noise
			if(prob(66))
				user.visible_message("<span class='warning'>[user] chops [src]!</span>")
				return 0
			else
				user.visible_message("<span class='notice'>[user] chops [src]!</span>")
				slice(W, user)
				return 1
		else if(slice(W, user))
			return 1
	..()
//Called when you finish tablecrafting a snack.
/obj/item/reagent_containers/food/snacks/CheckParts(list/parts_list, datum/crafting_recipe/food/R)
	..()
//	reagents.clear_reagents()
	for(var/obj/item/reagent_containers/RC in contents)
		RC.reagents.trans_to(reagents, RC.reagents.maximum_volume)
	if(istype(R))
		contents_loop:
			for(var/A in contents)
				for(var/B in R.real_parts)
					if(istype(A, B))
						continue contents_loop
				qdel(A)
	SSblackbox.record_feedback("tally", "food_made", 1, type)

	if(bonus_reagents && bonus_reagents.len)
		for(var/r_id in bonus_reagents)
			var/amount = bonus_reagents[r_id]
			if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
				reagents.add_reagent(r_id, amount, tastes)
			else
				reagents.add_reagent(r_id, amount)

/obj/item/reagent_containers/food/snacks/proc/slice(obj/item/W, mob/user)
	if((slices_num <= 0 || !slices_num) || !slice_path) //is the food sliceable?
		return FALSE

	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/structure/table/optable) in src.loc) && \
			!(locate(/obj/item/storage/bag/tray) in src.loc) \
		)
		to_chat(user, "<span class='warning'>I need to use a table.</span>")
		return FALSE

	if(slice_batch)
		if(!do_after(user, 30, target = src))
			return FALSE
		var/reagents_per_slice = reagents.total_volume/slices_num
		for(var/i in 1 to slices_num)
			var/obj/item/reagent_containers/food/snacks/slice = new slice_path(loc)
			slice.filling_color = filling_color
			initialize_slice(slice, reagents_per_slice)
		qdel(src)
	else
		var/reagents_per_slice = reagents.total_volume/slices_num
		var/obj/item/reagent_containers/food/snacks/slice = new slice_path(loc)
		slice.filling_color = filling_color
		initialize_slice(slice, reagents_per_slice)
		slices_num--
		if(slices_num == 1)
			slice = new slice_path(loc)
			slice.filling_color = filling_color
			initialize_slice(slice, reagents_per_slice)
			qdel(src)
			return TRUE
		if(slices_num <= 0)
			qdel(src)
			return TRUE
		update_icon()
	return TRUE

/obj/item/reagent_containers/food/snacks/proc/initialize_slice(obj/item/reagent_containers/food/snacks/slice, reagents_per_slice)
	slice.create_reagents(slice.volume)
	reagents.trans_to(slice,reagents_per_slice)
	slice.filling_color = filling_color
	slice.update_snack_overlays(src)
//	if(name != initial(name))
//		slice.name = "slice of [name]"
//	if(desc != initial(desc))
//		slice.desc = ""
//	if(foodtype != initial(foodtype))
//		slice.foodtype = foodtype //if something happens that overrode our food type, make sure the slice carries that over

/obj/item/reagent_containers/food/snacks/proc/generate_trash(atom/location)
	if(trash)
		if(ispath(trash, /obj/item))
			. = new trash(location)
			trash = null
			return
		else if(isitem(trash))
			var/obj/item/trash_item = trash
			trash_item.forceMove(location)
			. = trash
			trash = null
			return

/obj/item/reagent_containers/food/snacks/proc/update_snack_overlays(obj/item/reagent_containers/food/snacks/S)
	cut_overlays()
	var/mutable_appearance/filling = mutable_appearance(icon, "[initial(icon_state)]_filling")
	filling.color = filling_color

	add_overlay(filling)

// initialize_cooked_food() is called when microwaving the food
/obj/item/reagent_containers/food/snacks/proc/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency = 1)
	if(reagents)
		reagents.trans_to(S, reagents.total_volume)
	if(S.bonus_reagents && S.bonus_reagents.len)
		for(var/r_id in S.bonus_reagents)
			var/amount = S.bonus_reagents[r_id] * cooking_efficiency
			if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
				S.reagents.add_reagent(r_id, amount)
			else
				S.reagents.add_reagent(r_id, amount)
	S.filling_color = filling_color
	S.update_snack_overlays(src)
/*
/obj/item/reagent_containers/food/snacks/microwave_act(obj/machinery/microwave/M)
	var/turf/T = get_turf(src)
	var/obj/item/result

	if(cooked_type)
		result = new cooked_type(T)
		if(istype(M))
			initialize_cooked_food(result, M.efficiency)
		else
			initialize_cooked_food(result, 1)
		SSblackbox.record_feedback("tally", "food_made", 1, result.type)
	else
		result = new /obj/item/reagent_containers/food/snacks/badrecipe(T)
		if(istype(M) && M.dirty < 100)
			M.dirty++
	qdel(src)

	return result*/

/obj/item/reagent_containers/food/snacks/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(contents)
		for(var/atom/movable/something in contents)
			something.forceMove(drop_location())
	return ..()

/obj/item/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(isdog(M))
			var/mob/living/L = M
			if(bitecount == 0 || prob(50))
				M.emote("me", 1, "nibbles away at \the [src]")
			bitecount++
			L.taste(reagents) // why should carbons get all the fun?
			if(bitecount >= 5)
				var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [src] was")
				if(sattisfaction_text)
					M.emote("me", 1, "[sattisfaction_text]")
				qdel(src)

/obj/item/reagent_containers/food/snacks/afterattack(obj/item/reagent_containers/M, mob/user, proximity)
	. = ..()
	if(!dunkable || !proximity)
		return
	if(istype(M, /obj/item/reagent_containers/glass) || istype(M, /obj/item/reagent_containers/food/drinks))	//you can dunk dunkable snacks into beakers or drinks
		if(!M.is_drainable())
			to_chat(user, "<span class='warning'>[M] is unable to be dunked in!</span>")
			return
		if(M.reagents.trans_to(src, dunk_amount, transfered_by = user))	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>I dunk \the [src] into \the [M].</span>")
			return
		if(!M.reagents.total_volume)
			to_chat(user, "<span class='warning'>[M] is empty!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is full!</span>")

// //////////////////////////////////////////////Store////////////////////////////////////////
/// All the food items that can store an item inside itself, like bread or cake.
/obj/item/reagent_containers/food/snacks/store
	w_class = WEIGHT_CLASS_NORMAL
	var/stored_item = 0

/obj/item/reagent_containers/food/snacks/store/attackby(obj/item/W, mob/user, params)
	..()
	if(W.w_class <= WEIGHT_CLASS_SMALL & !istype(W, /obj/item/reagent_containers/food/snacks)) //can't slip snacks inside, they're used for custom foods.
		if(W.get_sharpness())
			return 0
		if(stored_item)
			return 0
		if(!iscarbon(user))
			return 0
		if(contents.len >= 20)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return 0
		to_chat(user, "<span class='notice'>I slip [W] inside [src].</span>")
		user.transferItemToLoc(W, src)
		add_fingerprint(user)
		contents += W
		stored_item = 1
		return 1 // no afterattack here

/obj/item/reagent_containers/food/snacks/MouseDrop(atom/over)
	var/turf/T = get_turf(src)
	var/obj/structure/table/TB = locate(/obj/structure/table) in T
	if(TB)
		TB.MouseDrop(over)
	else
		return ..()

