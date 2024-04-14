
/obj/item/reagent_containers/food/snacks/store/bread
	icon = 'icons/obj/food/burgerbread.dmi'
	volume = 80
	slices_num = 5
	tastes = list("bread" = 10)
	foodtype = GRAIN
	dunkable = TRUE

/obj/item/reagent_containers/food/snacks/breadslice
	icon = 'icons/obj/food/burgerbread.dmi'
	bitesize = 2
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/sandwich
	filling_color = "#FFA500"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	slot_flags = ITEM_SLOT_HEAD
	customfoodfilling = 0 //to avoid infinite bread-ception
	foodtype = GRAIN
	dunkable = TRUE

/obj/item/reagent_containers/food/snacks/store/bread/plain
	name = "bread"
	desc = ""
	icon_state = "bread"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 7)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/bread
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/plain
	tastes = list("bread" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/breadslice/plain
	name = "bread slice"
	desc = ""
	icon_state = "breadslice"
	customfoodfilling = 1
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/store/bread/meat
	name = "meatbread loaf"
	desc = ""
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/meat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "meat" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/breadslice/meat
	name = "meatbread slice"
	desc = ""
	icon_state = "meatbreadslice"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/store/bread/xenomeat
	name = "xenomeatbread loaf"
	desc = ""
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/xenomeat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "acid" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/breadslice/xenomeat
	name = "xenomeatbread slice"
	desc = ""
	icon_state = "xenobreadslice"
	filling_color = "#32CD32"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/store/bread/spidermeat
	name = "spider meat loaf"
	desc = ""
	icon_state = "spidermeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/spidermeat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/toxin = 15, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "cobwebs" = 5)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/breadslice/spidermeat
	name = "spider meat bread slice"
	desc = ""
	icon_state = "xenobreadslice"
	filling_color = "#7CFC00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/store/bread/banana
	name = "banana-nut bread"
	desc = ""
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/banana
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/banana = 20)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/banana = 20)
	tastes = list("bread" = 10) // bananjuice will also flavour
	foodtype = GRAIN | FRUIT


/obj/item/reagent_containers/food/snacks/breadslice/banana
	name = "banana-nut bread slice"
	desc = ""
	icon_state = "bananabreadslice"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 4)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/store/bread/tofu
	name = "Tofubread"
	desc = ""
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/tofu
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "tofu" = 10)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/breadslice/tofu
	name = "tofubread slice"
	desc = ""
	icon_state = "tofubreadslice"
	filling_color = "#FF8C00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/store/bread/creamcheese
	name = "cream cheese bread"
	desc = ""
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/creamcheese
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = ""
	icon_state = "creamcheesebreadslice"
	filling_color = "#FF8C00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/store/bread/mimana
	name = "mimana bread"
	desc = ""
	icon_state = "mimanabread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/mimana
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/consumable/nothing = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "silence" = 10)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/breadslice/mimana
	name = "mimana bread slice"
	desc = ""
	icon_state = "mimanabreadslice"
	filling_color = "#C0C0C0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/breadslice/custom
	name = "bread slice"
	icon_state = "tofubreadslice"
	filling_color = "#FFFFFF"
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = ""
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	item_state = "baguette"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	bitesize = 3
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	tastes = list("bread" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/garlicbread
	name = "garlic bread"
	desc = ""
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "garlicbread"
	item_state = "garlicbread"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/garlic = 2)
	bitesize = 3
	tastes = list("bread" = 1, "garlic" = 1, "butter" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = ""
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bitesize = 2

/obj/item/reagent_containers/food/snacks/deepfryholder/Initialize(mapload, obj/item/fried)
	. = ..()
	name = fried.name //We'll determine the other stuff when it's actually removed
	appearance = fried.appearance
	layer = initial(layer)
	plane = initial(plane)
	lefthand_file = fried.lefthand_file
	righthand_file = fried.righthand_file
	item_state = fried.item_state
	desc = fried.desc
	w_class = fried.w_class
	slowdown = fried.slowdown
	equip_delay_self = fried.equip_delay_self
	equip_delay_other = fried.equip_delay_other
	strip_delay = fried.strip_delay
	species_exception = fried.species_exception
	item_flags = fried.item_flags
	obj_flags = fried.obj_flags
	inhand_x_dimension = fried.inhand_x_dimension
	inhand_y_dimension = fried.inhand_y_dimension

	if(istype(fried, /obj/item/reagent_containers/food/snacks))
		fried.reagents.trans_to(src, fried.reagents.total_volume)
		qdel(fried)
	else
		fried.forceMove(src)

/obj/item/reagent_containers/food/snacks/deepfryholder/Destroy()
	if(contents)
		QDEL_LIST(contents)
	. = ..()

/obj/item/reagent_containers/food/snacks/deepfryholder/On_Consume(mob/living/eater)
	if(contents)
		QDEL_LIST(contents)
	..()

/obj/item/reagent_containers/food/snacks/deepfryholder/proc/fry(cook_time = 30)
	switch(cook_time)
		if(0 to 15)
			add_atom_colour(rgb(166,103,54), FIXED_COLOUR_PRIORITY)
			name = "lightly-fried [name]"
			desc = ""
		if(16 to 49)
			add_atom_colour(rgb(103,63,24), FIXED_COLOUR_PRIORITY)
			name = "fried [name]"
			desc = ""
		if(50 to 59)
			add_atom_colour(rgb(63,23,4), FIXED_COLOUR_PRIORITY)
			name = "deep-fried [name]"
			desc = ""
		if(60 to INFINITY)
			add_atom_colour(rgb(33,19,9), FIXED_COLOUR_PRIORITY)
			name = "the physical manifestation of the very concept of fried foods"
			desc = ""
	filling_color = color
	foodtype |= FRIED


/obj/item/reagent_containers/food/snacks/butterdog
	name = "butterdog"
	desc = ""
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bitesize = 1
	filling_color = "#F1F49A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter", "exotic butter")
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/butterdog/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)
