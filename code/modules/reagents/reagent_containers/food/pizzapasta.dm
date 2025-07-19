/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/pizzapasta
	icon = 'icons/obj/items/food/pizzaspaghetti.dmi'
	slices_num = 6
	bitesize = 1
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta
	icon = 'icons/obj/items/food/pizzaspaghetti.dmi'
	bitesize = 1
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/margherita
	name = "Margherita"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/margheritaslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 40, /datum/reagent/consumable/tomatojuice = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/margheritaslice
	name = "Margherita slice"
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/meatpizza
	name = "Meatpizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/meatpizzaslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 50, /datum/reagent/consumable/tomatojuice = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/meatpizzaslice
	name = "Meatpizza slice"
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/mushroompizzaslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 35)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/mushroompizzaslice
	name = "Mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/vegetablepizza
	name = "Vegetable pizza"
	desc = "No Tomato Sapiens were harmed during making of this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/vegetablepizzaslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/imidazoline = 12)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/vegetablepizzaslice
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"
	filling_color = "#BAA14C"
	bitesize = 2
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/tricordrazine = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/donkpocket

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/donkpocket/raw
	name = "raw donkpocket pizza"
	icon_state = "donkpocketpizza_raw"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/donkpocket

/obj/item/reagent_containers/food/snacks/pizzapasta/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/doctor_delight = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/dank

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/dank/raw
	name = "raw dank pizza"
	icon_state = "dankpizza_raw"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/dank

/obj/item/reagent_containers/food/snacks/pizzapasta/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/sassysage
	name = "sassysage pizza"
	desc = "You can almost taste the sassiness."
	icon_state = "sassysagepizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/sassysage

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/sassysage/raw
	name = "raw sassysage pizza"
	icon_state = "sassysagepizza_raw"

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/pineapple
	name = "\improper Hawaiian pizza"
	desc = "The pizza equivalent of Einstein's riddle."
	icon_state = "pineapplepizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/pineapple

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/pineapple/raw
	name = "raw Hawaiian pizza"
	icon_state = "pineapplepizza_raw"
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizzapasta/pineapple
	name = "\improper Hawaiian pizza slice"
	desc = "A slice of delicious controversy."
	icon_state = "pineapplepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/ants
	name = "\improper Ant Party pizza"
	desc = "/// Filled with bugs, remember to fix"
	icon_state = "antpizza"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)
	slice_path = /obj/item/reagent_containers/food/snacks/pizzapasta/ants

/obj/item/reagent_containers/food/snacks/pizzapasta/ants
	name = "\improper Ant Party pizza slice"
	desc = "The key to a perfect slice of pizza is not to overdo it with the ants."
	icon_state = "antpizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "insects" = 1)

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/items/food/pizzaspaghetti.dmi'
	icon_state = "pizzabox1"

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/update_desc(updates)
	. = ..()
	if(open && pizza)
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if(boxes.len > 0)
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if(toptag != "")
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if(boxtag != "")
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

/obj/item/pizzabox/update_icon_state()
	. = ..()
	if(open)
		if(ismessy)
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"
		return

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/update_overlays()
	. = ..()
	if(open && pizza)
		var/image/pizzaimg = image("pizzaspaghetti.dmi", icon_state = pizza.icon_state)
		pizzaimg.pixel_z = -3
		. += pizzaimg
		return
	// Stupid code because byondcode sucks - imagine blaming the engine for you being bad at coding. TODO: clean this up
	var/doimgtag = 0
	if(boxes.len > 0)
		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		if(topbox.boxtag != "")
			doimgtag = 1
	else
		if(boxtag != "")
			doimgtag = 1

	if(doimgtag)
		var/image/tagimg = image("pizzaspaghetti.dmi", icon_state = "pizzabox_tag")
		tagimg.pixel_z = boxes.len * 3
		. += tagimg

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/pizzabox/attack_hand(mob/living/user)
	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, span_warning("You take the [src.pizza] out of the [src]."))
		src.pizza = null
		update_icon()
		return

	else if( boxes.len > 0 )
		if( user.get_inactive_held_item() != src )
			return ..()

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, span_warning("You remove the topmost [src] from your hand."))
		box.update_icon()
		update_icon()

	else
		return ..()

/obj/item/pizzabox/attack_self( mob/user as mob )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/pizzabox))
		var/obj/item/pizzabox/box = I

		if(box.open || open)
			to_chat(user, span_warning("Close the [box] first!"))
			return

		// Make a list of all boxes to be added
		var/list/boxestoadd = list()
		boxestoadd += box
		for(var/obj/item/pizzabox/i in box.boxes)
			boxestoadd += i

		if((length(boxes) + 1) + length(boxestoadd) > 5)
			to_chat(user, span_warning("The stack is too high!"))
			return

		user.transferItemToLoc(box, src)
		box.boxes = list()
		boxes.Add(boxestoadd)

		box.update_icon()
		update_icon()

		to_chat(user, span_warning("You put the [box] ontop of the [src]!"))

	else if(istype(I, /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta))
		if(!open)
			to_chat(user, span_warning("You try to push the [I] through the lid but it doesn't work!"))
			return

		user.transferItemToLoc(I, src)
		pizza = I

		update_icon()

		to_chat(user, span_warning("You put the [I] in the [src]!"))

	else if(istype(I, /obj/item/tool/pen))
		if(open)
			return

		var/t = stripped_input(user, "Enter what you want to add to the tag:", "Write", "", 30)

		boxtag = "[boxtag][t]"

		update_icon()


/obj/item/pizzabox/margherita/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/margherita(src)
	boxtag = "Margherita Deluxe"


/obj/item/pizzabox/mushroom/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/mushroompizza(src)
	boxtag = "Mushroom Special"


/obj/item/pizzabox/meat/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/meatpizza(src)
	boxtag = "Meatlover's Supreme"

/obj/item/pizzabox/donkpocket/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/donkpocket(src)
	boxtag = "Bangin' Donk"

/obj/item/pizzabox/ants/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/ants(src)
	boxtag = "Anthill Deluxe"

/obj/item/pizzabox/dank/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/dank(src)
	boxtag = "Fresh Herbs"

/obj/item/pizzabox/vegetable/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/vegetablepizza(src)
	boxtag = "Gourmet Vegetable"

/obj/item/pizzabox/sassysage/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/sassysage(src)
	boxtag = "Sausage Lovers"

/obj/item/pizzabox/pineapple/Initialize(mapload)
	. = ..()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/pineapple(src)
	boxtag = "Honolulu Chew"

///spaghetti prototype used by all subtypes
/obj/item/reagent_containers/food/snacks/pizzapasta
	icon = 'icons/obj/items/food/pizzaspaghetti.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/raw
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	tastes = list("pasta" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon = 'icons/obj/items/food/pizzaspaghetti.dmi'
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#FCEE81"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 2
	tastes = list("pasta" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	bitesize = 4
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pasta" = 1, "tomato" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	bitesize = 4
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/tomatojuice = 20, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("pasta" = 1, "tomato" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 2)
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 3
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 20, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pasta" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/chowmein
	name = "chow mein"
	desc = "A nice mix of noodles and fried vegetables."
	icon_state = "chowmein"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("noodle" = 1, "tomato" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/beefnoodle
	name = "beef noodle"
	desc = "Nutritious, beefy and noodly."
	icon_state = "beefnoodle"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("noodle" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/butternoodles
	name = "butter noodles"
	desc = "Noodles covered in savory butter. Simple and slippery, but delicious."
	icon_state = "butternoodles"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("noodle" = 1, "butter" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/mac_n_cheese
	name = "mac n' cheese"
	desc = "Made the proper way with only the finest cheese and breadcrumbs. And yet, it can't scratch the same itch as Ready-Donk."
	icon_state = "mac_n_cheese"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cheese" = 1, "breadcrumbs" = 1, "pasta" = 1)

/obj/item/pizzabox/random
	var/list/pizza_choices = list(
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/margherita,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/vegetablepizza,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/mushroompizza,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/meatpizza,
	)

/obj/item/pizzabox/random/Initialize(mapload)
	. = .. ()
	var/pizza_type = pick(pizza_choices)
	pizza = new pizza_type(src)
	boxtag = "Pizza Time"

/obj/item/reagent_containers/food/snacks/pizzapasta/spagetti
	name = "Spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#EDDD00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bitesize = 1
	tastes = list("raw pasta" = 1)

/obj/item/reagent_containers/food/snacks/pizzapasta/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
