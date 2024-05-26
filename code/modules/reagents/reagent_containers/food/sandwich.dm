/obj/item/reagent_containers/food/snacks/sandwiches
	icon = 'icons/obj/items/food/bread.dmi'

/obj/item/reagent_containers/food/snacks/sandwiches/breadslice/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/shard) || istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/S = new(loc)
		S.attackby(I, user, params)
		qdel(src)

/obj/item/reagent_containers/food/snacks/sandwiches/grilled_cheese_sandwich
	name = "grilled cheese sandwich"
	desc = "A warm, melty sandwich that goes perfectly with tomato soup."
	icon_state = "toastedsandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/carbon = 4)
	tastes = list("toast" = 2, "cheese" = 3, "butter" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/cheese_sandwich
	name = "cheese sandwich"
	desc = "A light snack for a warm day. ...but what if you grilled it?"
	icon_state = "sandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bread" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	tastes = list("bread" = 1, "jelly" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich/cherry
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("nothing suspicious" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/jelliedtoast
	name = "jellied toast"
	desc = "A slice of toast covered with delicious jam."
	icon_state = "jellytoast"
	tastes = list("toast" = 1, "jelly" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/blt
	name = "\improper BLT"
	desc = "A classic bacon, lettuce, and tomato sandwich."
	icon_state = "blt"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("bacon" = 3, "lettuce" = 2, "tomato" = 2, "bread" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/twobread
	name = "two bread"
	desc = "This seems awfully bitter."
	icon_state = "twobread"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("bread" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/jelliedtoast/cherry
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/butteredtoast
	name = "buttered toast"
	desc = "Butter lightly spread over a piece of toast."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "butteredtoast"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter" = 1, "toast" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."

	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

	var/list/ingredients = list()

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	var/sandwich_limit = 4
	for(var/obj/item/reagent_containers/food/snacks/sandwiches/breadslice/B in ingredients)
		sandwich_limit += 4

	if(length(contents) > sandwich_limit)
		to_chat(user, span_warning("If you put anything else on \the [src] it's going to collapse."))

	else if(istype(I, /obj/item/shard))
		to_chat(user, span_notice("You hide [I] in \the [src]."))
		user.transferItemToLoc(I, src)
		update()

	else if(istype(I, /obj/item/reagent_containers/food/snacks))
		to_chat(user, span_notice("You layer [I] over \the [src]."))
		var/obj/item/reagent_containers/F = I
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.transferItemToLoc(I, src)
		ingredients += I
		update()

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/proc/update()
	var/fullname = "" //We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/reagent_containers/food/snacks/sandwiches/O in ingredients)

		i++
		if(i == 1)
			fullname += "[O.name]"
		else if(i == length(ingredients))
			fullname += " and [O.name]"
		else
			fullname += ", [O.name]"

		var/image/I = new(src.icon, "breadslice_filling")
		I.color = O.filling_color
		I.pixel_x = pick(list(-1,0,1))
		I.pixel_y = (i*2)+1
		overlays += I

	var/image/T = new(src.icon, "breadslice")
	T.pixel_x = pick(list(-1,0,1))
	T.pixel_y = (length(ingredients) * 2)+1
	overlays += T

	name = lowertext("[fullname] sandwich")
	if(length(name) > 80) name = "[pick(list("absurd","colossal","enormous","ridiculous"))] sandwich"
	w_class = CEILING(clamp((length(ingredients)/2),1,3),1)

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/Destroy()
	for(var/obj/item/O in ingredients)
		qdel(O)
	. = ..()

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/examine(mob/user)
	. = ..()
	var/obj/item/O = pick(contents)
	. += span_notice("You think you can see [O] in there.")

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/attack(mob/M as mob, mob/user as mob, def_zone)

	var/obj/item/shard
	for(var/obj/item/O in contents)
		if(istype(O,/obj/item/shard))
			shard = O
			break

	var/mob/living/H
	if(istype(M,/mob/living))
		H = M

	if(H && shard && M == user) //This needs a check for feeding the food to other people, but that could be abusable.
		to_chat(H, span_warning("You lacerate your mouth on a [shard.name] in the sandwich!"))
		H.adjustBruteLoss(5) //TODO: Target head if human.
	..()

/obj/item/reagent_containers/food/snacks/sandwiches/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bitesize = 2
	tastes = list("meat" = 2, "cheese" = 1, "bread" = 2, "lettuce" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/carbon = 2)
	bitesize = 2
	tastes = list("toast" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/carbon = 2)
	bitesize = 2
	tastes = list("toast" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/plain
	name = "plain burger"
	icon = 'icons/obj/items/food/burgers.dmi'
	icon_state = "hburger"
	desc = "The cornerstone of every nutritious breakfast."
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/rib
	name = "mcrib"
	desc = "An elusive rib shaped burger with limited availablity across the galaxy. Not as good as you remember it."
	icon = 'icons/obj/items/food/burgers.dmi'
	icon_state = "mcrib"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("bun" = 2, "pork patty" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/mcguffin
	name = "mcguffin"
	desc = "A cheap and greasy imitation of an eggs benedict."
	icon = 'icons/obj/items/food/burgers.dmi'
	icon_state = "mcguffin"
	tastes = list("muffin" = 2, "bacon" = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/bread
	name = "Bread"
	desc = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/breadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	filling_color = "#FFE396"
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/breadslice
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	bitesize = 2
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/creamcheesebread
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/creamcheesebreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#FFF896"
	tastes = list("bread" = 10, "cheese" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/creamcheesebreadslice
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFF896"
	bitesize = 2
	tastes = list("bread" = 10, "cheese" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/marinebread //meme bread for breadify smite
	name = "Bread"
	desc = "Some plain old Earthen bread. An air of penance surrounds it."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "breadtg"
	list_reagents = list(/datum/reagent/consumable/nutriment = 60)
	filling_color = "#FFF896"
	bitesize = 2
	tastes = list("guilt" = 1, "salt" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/Destroy() //delete the marine trapped inside, tasty!
	for(var/i in contents)
		qdel(i)
	return ..()

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/xenomeatbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	filling_color = "#8AFF75"
	tastes = list("bread" = 10, "acid" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#8AFF75"
	bitesize = 2
	tastes = list("bread" = 10, "acid" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/bananabread
	name = "Banana-nut bread"
	desc = "A heavenly and filling treat."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/bananabreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/banana = 20)
	filling_color = "#EDE5AD"
	tastes = list("bread" = 10) // bananjuice will also flavour

/obj/item/reagent_containers/food/snacks/sandwiches/bananabreadslice
	name = "Banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#EDE5AD"
	bitesize = 2
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/meatbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	filling_color = "#FF7575"
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FF7575"
	bitesize = 2
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/tofubread
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/tofubreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	filling_color = "#F7FFE0"
	tastes = list("bread" = 10, "tofu" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/tofubreadslice
	name = "Tofubread slice"
	desc = "A slice of delicious tofubread."
	icon = 'icons/obj/items/food/bread.dmi'
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#F7FFE0"
	bitesize = 2
	tastes = list("bread" = 10, "tofu" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/emperor_roll
	name = "emperor roll"
	desc = "A popular sandwich on Imperial core worlds, usually served in honor of royalty."
	icon_state = "emperor_roll"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bread" = 1, "cheese" = 1, "liver" = 1, "caviar" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/honey_roll
	name = "honey sweetroll"
	desc = "A sweetened rootroll with sliced fruit."
	icon_state = "honey_roll"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 8, /datum/reagent/consumable/honey = 2)
	tastes = list("bread" = 1, "honey" = 1, "fruit" = 1)

//Bread
/obj/item/reagent_containers/food/snacks/sandwiches/corn
	name = "cornbread"
	desc = "Some good down-home country-style, rootin'-tootin', revolver-shootin', dad-gum yeehaw cornbread."
	icon_state = "cornbread"
	list_reagents = list(/datum/reagent/consumable/nutriment = 18)
	tastes = list("cornbread" = 10)
	w_class = WEIGHT_CLASS_SMALL
	bitesize = 2

/obj/item/reagent_containers/food/snacks/sandwiches/corn
	name = "cornbread slice"
	desc = "A chunk of crispy, cowboy-style cornbread. Consume contentedly."
	icon_state = "cornbread_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
