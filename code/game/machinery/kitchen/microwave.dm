
/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	layer = ABOVE_TABLE_LAYER
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items // List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0


// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/microwave/New()
	..()
	create_reagents(100, OPENCONTAINER)
	if (!available_recipes)
		available_recipes = new
		for (var/type in subtypesof(/datum/recipe))
			available_recipes+= new type
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.items.len)

/*******************
*   Item Adding
********************/

/obj/machinery/microwave/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(broken == 2 && isscrewdriver(I))
		user.visible_message( "<span class='notice'>[user] starts to fix part of the microwave.</span>", \
			"<span class='notice'>You start to fix part of the microwave.</span>")

		if(!do_after(user,20, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

		user.visible_message("<span class='notice'>[user] fixes part of the microwave.</span>", \
			"<span class='notice'>You have fixed part of the microwave.</span>")
		broken = 1

	else if(broken == 1 && iswrench(I))
		user.visible_message("<span class='notice'>[user] starts to fix part of the microwave.</span>", \
			"<span class='notice'>You start to fix part of the microwave.</span>")

		if(!do_after(user,20, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

		user.visible_message( "<span class='notice'>[user] fixes the microwave.</span>", \
			"<span class='notice'>You have fixed the microwave.</span>")
		icon_state = "mw"
		broken = 0
		dirty = 0
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)

	else if(broken > 2)
		to_chat(user, "<span class='warning'>It's broken!</span>")
		return TRUE

	else if(dirty == 100)
		if(!istype(I, /obj/item/reagent_container/spray/cleaner))
			to_chat(user, "<span class='warning'>It's dirty!</span>")
			return TRUE

		user.visible_message("<span class='notice'>[user] starts to clean \the [src].</span>", \
			"<span class='notice'>You start to clean \the [src].</span>")

		if(!do_after(user,20, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

		user.visible_message("<span class='notice'>[user] has cleaned \the [src].</span>", \
			"<span class='notice'>You have cleaned \the [src].</span>")
		dirty = 0
		broken = 0
		icon_state = "mw"
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)

	else if(is_type_in_list(I, acceptable_items))
		if(length(contents) >= max_n_of_items)
			to_chat(user, "<span class='warning'>This [src] is full of ingredients, you cannot put more.</span>")
			return TRUE

		if(istype(I, /obj/item/stack) && I:get_amount() > 1) // This is bad, but I can't think of how to change it
			var/obj/item/stack/S = I
			new S.type(src)
			S.use(1)
			user.visible_message("<span class='notice'>[user] has added one of [I] to \the [src].</span>", \
				"<span class='notice'>You add one of [I] to \the [src].</span>")

		else if(user.drop_held_item())
			I.forceMove(src)
			user.visible_message("<span class='notice'>[user] has added \the [I] to \the [src].</span>", \
				"<span class='notice'>You add \the [I] to \the [src].</span>")

	else if(istype(I,/obj/item/reagent_container/glass) || \
	        istype(I,/obj/item/reagent_container/food/drinks) || \
	        istype(I,/obj/item/reagent_container/food/condiment))
	
		if(!I.reagents)
			return TRUE

		for(var/i in I.reagents.reagent_list)
			var/datum/reagent/R = i
			if(!(R.id in acceptable_reagents))
				to_chat(user, "<span class='warning'>Your [I] contains components unsuitable for cookery.</span>")
				return TRUE

	else if(istype(I, /obj/item/grab))
		return TRUE

	else
		to_chat(user, "<span class='warning'>You have no idea what you can cook with this [I].</span>")
		
	updateUsrDialog()
	return TRUE

/obj/machinery/microwave/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/microwave/attack_ai(mob/user as mob)
	return 0

/obj/machinery/microwave/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	user.set_interaction(src)
	interact(user)

/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/interact(mob/user as mob) // The microwave Menu
	var/dat = ""
	if(src.broken > 0)
		dat = {"<TT>Bzzzzttttt</TT>"}
	else if(src.operating)
		dat = {"<TT>Microwaving in progress!<BR>Please wait...!</TT>"}
	else if(src.dirty==100)
		dat = {"<TT>This microwave is dirty!<BR>Please clean it before use!</TT>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if (istype(O,/obj/item/reagent_container/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if (istype(O,/obj/item/reagent_container/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if (istype(O,/obj/item/reagent_container/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if (istype(O,/obj/item/reagent_container/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if (istype(O,/obj/item/reagent_container/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if (!(O in items_measures))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if (N==1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == "capsaicin")
				display_name = "Hotsauce"
			if (R.id == "frostoil")
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if (items_counts.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The microwave is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]"}
		dat += {"<HR><BR>
<a href='?src=\ref[src];action=cook'>Turn on!</a><br>
<a href='?src=\ref[src];action=dispose'>Eject ingredients!</a>
"}

	var/datum/browser/popup = new(user, "microwave", "<div align='center'>Microwave Controls</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "microwave")



/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/proc/cook()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if (!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	if (!recipe)
		dirty += 1
		if (prob(max(10,dirty*5)))
			if (!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			cooked = fail()
			cooked.loc = src.loc
			return
		else if (has_extra_item())
			if (!wzhzhzh(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.loc = src.loc
			return
		else
			if (!wzhzhzh(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.loc = src.loc
			return
	else
		var/halftime = round(recipe.time/10/2)
		if (!wzhzhzh(halftime))
			abort()
			return
		if (!wzhzhzh(halftime))
			abort()
			cooked = fail()
			cooked.loc = src.loc
			return
		cooked = recipe.make_food(src)
		stop()
		if(cooked)
			cooked.loc = src.loc
		return

/obj/machinery/microwave/proc/wzhzhzh(var/seconds as num)
	for (var/i=1 to seconds)
		if (machine_stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/microwave/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/reagent_container/food) && \
				!istype(O, /obj/item/grown) \
			)
			return 1
	return 0

/obj/machinery/microwave/proc/start()
	src.visible_message("<span class='notice'> The microwave turns on.</span>", "<span class='notice'> You hear a microwave.</span>")
	src.operating = 1
	src.icon_state = "mw1"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 25, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "mw"
	src.updateUsrDialog()

/obj/machinery/microwave/proc/destroy_contents()
	for (var/obj/O in contents)
		O.loc = src.loc
	if (src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of the microwave contents.</span>")
	src.updateUsrDialog()

/obj/machinery/microwave/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 25, 1) // Play a splat sound
	src.icon_state = "mwbloody1" // Make it look dirty!!

/obj/machinery/microwave/proc/muck_finish()
	playsound(src.loc, 'sound/machines/ding.ogg', 25, 1)
	visible_message("<span class='warning'> The microwave gets covered in muck!</span>")
	dirty = 100 // Make it dirty so it can't be used util cleaned
	DISABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER) //So you can't add condiments
	icon_state = "mwbloody" // Make it look dirty too
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()

/obj/machinery/microwave/proc/broke()
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	icon_state = "mwb" // Make it look all busted up and shit
	visible_message("<span class='warning'> The microwave breaks!</span>") //Let them know they're stupid
	broken = 2 // Make it broken so it can't be used util fixed
	DISABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER) //So you can't add condiments
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()

/obj/machinery/microwave/proc/fail()
	var/obj/item/reagent_container/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("toxin", amount/10)
	return ffuu

/obj/machinery/microwave/Topic(href, href_list)
	. = ..()
	if(.)
		return

	usr.set_interaction(src)
	if(src.operating)
		src.updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			destroy_contents()
	return
