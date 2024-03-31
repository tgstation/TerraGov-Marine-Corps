/obj/item/reagent_containers/food/snacks/rogue/meat
	icon = 'icons/roguetown/items/food.dmi'
	eat_effect = /datum/status_effect/debuff/uncookedfood
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	name = "meat"
	icon_state = "meatslab"
	slice_batch = FALSE
	filling_color = "#8f433a"
	rotprocess = 15 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/meat/steak
	ingredient_size = 2
	name = "steak"
	icon_state = "meatcutlet"
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	slices_num = 1
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/beef

/obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried
	eat_effect = null
	slices_num = 0
	name = "frysteak"
	icon_state = "friedsteak"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 15)
	desc = ""

/obj/item/reagent_containers/food/snacks/rogue/meat/mince
	name = "mince"
	icon_state = "meatmince"
	ingredient_size = 2
	slice_path = null
	slices_num = 0
	filling_color = "#8a0000"

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/beef
	name = "mince"

/obj/item/reagent_containers/food/snacks/rogue/meat/fatty //pork
	slices_num = 4
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon


/obj/item/reagent_containers/food/snacks/rogue/meat/bacon
	name = "bacon"
	desc = ""
	icon_state = "bacon"
	slice_path = null
	slices_num = 0
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	filling_color = "#8a0000"

/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	eat_effect = null
	slices_num = 0
	name = "fried bacon"
	icon_state = "friedbacon"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5)

/obj/item/reagent_containers/food/snacks/rogue/meat/spider
	icon_state = "spidermeat"
	slices_num = 0

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry
	name = "bird meat"
	desc = ""
	icon_state = "halfchicken"
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	fried_type = null
	slices_num = 2
	ingredient_size = 4

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked
	eat_effect = null
	slices_num = 0
	name = "roast bird"
	icon_state = "roastchicken"
	cooked_type = null
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 20)

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet
	name = "bird meat"
	icon_state = "chickencutlet"
	ingredient_size = 2
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	slices_num = 1
	slice_bclass = BCLASS_CHOP
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/mince/poultry
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried

/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/cutlet/fried
	eat_effect = null
	slices_num = 0
	name = "frybird"
	icon_state = "friedchicken"
	desc = ""
	fried_type = null
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5)

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/poultry
	name = "mince"
	desc = ""
	slices_num = 0
	icon_state = "meatmince"
	cooked_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/mince/fish
	name = "mince"
	desc = ""
	slices_num = 0
	icon_state = "meatmince"
	cooked_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/sausage
	name = "wiener"
	icon_state = "rawsausage"
	ingredient_size = 1
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	slices_num = 0
	cooked_type = null

/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	eat_effect = null
	slices_num = 0
	name = "sausage"
	icon_state = "sausage"
	desc = ""
	fried_type = null
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5)

/obj/item/reagent_containers/food/snacks/rogue/meat/salami
	eat_effect = null
	name = "salumoi"
	icon_state = "salamistick5"
	desc = ""
	fried_type = null
	slices_num = 5
	bitesize = 5
	slice_batch = FALSE
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	tastes = list("salted meat" = 1)
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/meat/salami/update_icon()
	if(slices_num)
		icon_state = "salamistick[slices_num]"
	else
		icon_state = "salami_slice"

/obj/item/reagent_containers/food/snacks/rogue/meat/salami/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 4
		if(bitecount == 2)
			slices_num = 3
		if(bitecount == 3)
			slices_num = 2
		if(bitecount == 4)
			changefood(slice_path, eater)


/obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	eat_effect = null
	slices_num = 0
	name = "salumoi"
	icon_state = "salami_slice"
	desc = ""
	fried_type = null
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bitesize = 1
	tastes = list("salted meat" = 1)

/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette
	eat_effect = null
	name = "coppiette"
	icon_state = "jerk5"
	desc = "Dried meat sticks."
	fried_type = null
	slices_num = 0
	bitesize = 5
	slice_path = null
	tastes = list("salted meat" = 1)
	rotprocess = null
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)

/obj/item/reagent_containers/food/snacks/rogue/meat/coppiette/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "jerk4"
	if(bitecount == 2)
		icon_state = "jerk3"
	if(bitecount == 3)
		icon_state = "jerk2"
	if(bitecount == 4)
		icon_state = "jerk1"

/obj/item/reagent_containers/food/snacks/rogue/saltfish
	eat_effect = null
	icon = 'icons/roguetown/misc/fish.dmi'
	name = "saltfish"
	icon_state = ""
	desc = "Dried fish."
	fried_type = null
	slices_num = 0
	bitesize = 4
	slice_path = null
	tastes = list("salted meat" = 1)
	rotprocess = null
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	dropshrink = 0.6

/obj/item/reagent_containers/food/snacks/rogue/saltfish/CheckParts(list/parts_list, datum/crafting_recipe/R)
	for(var/obj/item/reagent_containers/food/snacks/M in parts_list)
		icon_state = "[initial(M.icon_state)]dried"
		qdel(M)
