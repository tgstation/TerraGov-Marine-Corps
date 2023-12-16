
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/items/food/condiment.dmi'
	icon_state = "emptycondiment"
	init_reagent_flags = OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	center_of_mass = list("x"=16, "y"=6)
	volume = 50

/obj/item/reagent_containers/food/condiment/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)
	var/datum/reagents/R = reagents

	if(!R || !R.total_volume)
		to_chat(user, span_warning("The [src.name] is empty!"))
		return 0

	if(iscarbon(M))
		var/mob/living/carbon/H = M
		if(M == user)
			if(ishuman(H) && (H.species.species_flags & ROBOTIC_LIMBS))
				to_chat(H, span_warning("You have a monitor for a head, where do you think you're going to put that?"))
				return
			to_chat(H, span_notice("You swallow some of contents of the [src]."))
			if(reagents.total_volume)
				record_reagent_consumption(min(10, reagents.total_volume), reagents.reagent_list, user)
				reagents.trans_to(H, 10)
			playsound(H.loc,'sound/items/drink.ogg', 15, 1)
			return 1
		else
			if(ishuman(H) && (H.species.species_flags & ROBOTIC_LIMBS))
				to_chat(user, span_warning("They have a monitor for a head, where do you think you're going to put that?"))
				return
			M.visible_message(span_warning("[user] attempts to feed [M] [src]."))
			if(!do_after(user, 3 SECONDS, NONE, M, BUSY_ICON_FRIENDLY))
				return
			M.visible_message(span_warning("[user] feeds [M] [src]."))
			var/rgt_list_text = get_reagent_list_text()
			log_combat(user, M, "fed", src, "Reagents: [rgt_list_text]")
			if(reagents.total_volume)
				record_reagent_consumption(min(10, reagents.total_volume), reagents.reagent_list, user, M)
				reagents.reaction(M, INGEST)
				reagents.trans_to(M, 10)
			playsound(M.loc,'sound/items/drink.ogg', 15, 1)
			return 1
	return 0

/obj/item/reagent_containers/food/condiment/attackby(obj/item/I, mob/user)
	return

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user , flag)
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty."))
			return

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, span_notice("You fill [src] with [trans] units of the contents of [target]."))

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_injectable() && !isliving(target))
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty."))
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("you can't add anymore to [target]."))
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, span_notice("You transfer [trans] units of the condiment to [target]."))

/obj/item/reagent_containers/food/condiment/on_reagent_change()
	if(icon_state == "saltshakersmall" || icon_state == "peppermillsmall")
		return
	if(length(reagents.reagent_list) > 0)
		switch(reagents.get_master_reagent_id())
			if(/datum/reagent/consumable/ketchup)
				name = "Ketchup"
				desc = "You feel more American already."
				icon_state = "ketchup"
				center_of_mass = list("x"=16, "y"=6)
			if(/datum/reagent/consumable/capsaicin)
				name = "Hotsauce"
				desc = "You can almost TASTE the stomach ulcers now!"
				icon_state = "hotsauce"
				center_of_mass = list("x"=16, "y"=6)
			if(/datum/reagent/consumable/enzyme)
				name = "Universal Enzyme"
				desc = "Used in cooking various dishes."
				icon_state = "enzyme"
				center_of_mass = list("x"=16, "y"=6)
			if(/datum/reagent/consumable/soysauce)
				name = "Soy Sauce"
				desc = "A salty soy-based flavoring."
				icon_state = "soysauce"
				center_of_mass = list("x"=16, "y"=6)
			if(/datum/reagent/consumable/frostoil)
				name = "Coldsauce"
				desc = "Leaves the tongue numb in its passage."
				icon_state = "coldsauce"
				center_of_mass = list("x"=16, "y"=6)
			if(/datum/reagent/consumable/sodiumchloride)
				name = "Salt Shaker"
				desc = "Salt. From space oceans, presumably."
				icon_state = "saltshaker"
				center_of_mass = list("x"=16, "y"=10)
			if(/datum/reagent/consumable/blackpepper)
				name = "Pepper Mill"
				desc = "Often used to flavor food or make people sneeze."
				icon_state = "peppermillsmall"
				center_of_mass = list("x"=16, "y"=10)
			if(/datum/reagent/consumable/cornoil)
				name = "Corn Oil"
				desc = "A delicious oil used in cooking. Made from corn."
				icon_state = "oliveoil"
				center_of_mass = list("x"=16, "y"=6)
			if(/datum/reagent/consumable/sugar)
				name = "Sugar"
				desc = "Tastey space sugar!"
				center_of_mass = list("x"=16, "y"=6)
			else
				name = "Misc Condiment Bottle"
				if (length(reagents.reagent_list) == 1)
					desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."
					icon_state = "mixedcondiments"
					center_of_mass = list("x"=16, "y"=6)
	else
		icon_state = "emptycondiment"
		name = "Condiment Bottle"
		desc = "An empty condiment bottle."
		center_of_mass = list("x"=16, "y"=6)
		return

/obj/item/reagent_containers/food/condiment/enzyme
	name = "Universal Enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list(/datum/reagent/consumable/enzyme = 50)

/obj/item/reagent_containers/food/condiment/sugar
	list_reagents = list(/datum/reagent/consumable/sugar = 50)

/obj/item/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "Salt Shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/sodiumchloride = 20)

/obj/item/reagent_containers/food/condiment/peppermill
	name = "Pepper Mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/blackpepper = 20)
