
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_container/food/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/items/food.dmi'
	icon_state = "emptycondiment"
	init_reagent_flags = OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	center_of_mass = list("x"=16, "y"=6)
	volume = 50

	attackby(obj/item/W as obj, mob/user as mob)

		return
	attack_self(mob/user as mob)
		return
	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents

		if(!R || !R.total_volume)
			to_chat(user, "<span class='warning'>The [src.name] is empty!</span>")
			return 0

		if(M == user)
			to_chat(M, "<span class='notice'>You swallow some of contents of the [src].</span>")
			if(reagents.total_volume)
				reagents.trans_to(M, 10)

			playsound(M.loc,'sound/items/drink.ogg', 15, 1)
			return 1
		else if( ishuman(M) )

			for(var/mob/O in viewers(world.view, user))
				O.show_message("<span class='warning'>[user] attempts to feed [M] [src].</span>", 1)
			if(!do_mob(user, M, 30, BUSY_ICON_FRIENDLY)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("<span class='warning'>[user] feeds [M] [src].</span>", 1)

			var/rgt_list_text = get_reagent_list_text()

			log_combat(user, M, "fed", src, "Reagents: [rgt_list_text]")
			msg_admin_attack("[ADMIN_TPMONTY(usr)] fed [ADMIN_TPMONTY(M)] with [src.name].")

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				reagents.trans_to(M, 10)

			playsound(M.loc,'sound/items/drink.ogg', 15, 1)
			return 1
		return 0

	attackby(obj/item/I as obj, mob/user as mob)

		return

	afterattack(obj/target, mob/user , flag)
		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				to_chat(user, "<span class='warning'>[target] is empty.</span>")
				return

			if(reagents.holder_full())
				to_chat(user, "<span class='warning'>[src] is full.</span>")
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

		//Something like a glass or a food item. Player probably wants to transfer TO it.
		else if(target.is_injectable())
			if(!reagents.total_volume)
				to_chat(user, "<span class='warning'>[src] is empty.</span>")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>you can't add anymore to [target].</span>")
				return
			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You transfer [trans] units of the condiment to [target].</span>")

	on_reagent_change()
		if(icon_state == "saltshakersmall" || icon_state == "peppermillsmall")
			return
		if(reagents.reagent_list.len > 0)
			switch(reagents.get_master_reagent_id())
				if("ketchup")
					name = "Ketchup"
					desc = "You feel more American already."
					icon_state = "ketchup"
					center_of_mass = list("x"=16, "y"=6)
				if("capsaicin")
					name = "Hotsauce"
					desc = "You can almost TASTE the stomach ulcers now!"
					icon_state = "hotsauce"
					center_of_mass = list("x"=16, "y"=6)
				if("enzyme")
					name = "Universal Enzyme"
					desc = "Used in cooking various dishes."
					icon_state = "enzyme"
					center_of_mass = list("x"=16, "y"=6)
				if("soysauce")
					name = "Soy Sauce"
					desc = "A salty soy-based flavoring."
					icon_state = "soysauce"
					center_of_mass = list("x"=16, "y"=6)
				if("frostoil")
					name = "Coldsauce"
					desc = "Leaves the tongue numb in its passage."
					icon_state = "coldsauce"
					center_of_mass = list("x"=16, "y"=6)
				if("sodiumchloride")
					name = "Salt Shaker"
					desc = "Salt. From space oceans, presumably."
					icon_state = "saltshaker"
					center_of_mass = list("x"=16, "y"=10)
				if("blackpepper")
					name = "Pepper Mill"
					desc = "Often used to flavor food or make people sneeze."
					icon_state = "peppermillsmall"
					center_of_mass = list("x"=16, "y"=10)
				if("cornoil")
					name = "Corn Oil"
					desc = "A delicious oil used in cooking. Made from corn."
					icon_state = "oliveoil"
					center_of_mass = list("x"=16, "y"=6)
				if("sugar")
					name = "Sugar"
					desc = "Tastey space sugar!"
					center_of_mass = list("x"=16, "y"=6)
				else
					name = "Misc Condiment Bottle"
					if (reagents.reagent_list.len==1)
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

/obj/item/reagent_container/food/condiment/enzyme
	name = "Universal Enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list("enzyme" = 50)

/obj/item/reagent_container/food/condiment/sugar
	list_reagents = list("sugar" = 50)

/obj/item/reagent_container/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "Salt Shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)

/obj/item/reagent_container/food/condiment/peppermill
	name = "Pepper Mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)