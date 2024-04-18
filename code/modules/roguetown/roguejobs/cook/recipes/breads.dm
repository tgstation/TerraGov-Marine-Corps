/datum/crafting_recipe/roguetown/cooking/dough
	name = "dough"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/powder/flour= 2)
	result = /obj/item/reagent_containers/food/snacks/rogue/dough
	subtype_reqs = FALSE
	craftdiff = 0

/datum/crafting_recipe/roguetown/cooking/doughslice
	name = "smalldough"
	reqs = list(
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/powder/flour= 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/doughslice
	subtype_reqs = FALSE
	craftdiff = 0

/datum/crafting_recipe/roguetown/cooking/comdough
	name = "combine dough"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/doughslice=2)
	result = /obj/item/reagent_containers/food/snacks/rogue/dough
	subtype_reqs = FALSE
	skillcraft = null

/datum/crafting_recipe/roguetown/cooking/spldough
	name = "split dough"
	reqs = list(/obj/item/reagent_containers/food/snacks/rogue/dough=1)
	result = list(/obj/item/reagent_containers/food/snacks/rogue/doughslice=2)
	subtype_reqs = FALSE
	craftdiff = 0
	skillcraft = null

/datum/crafting_recipe/roguetown/cooking/crackers
	name = "crackers"
	reqs = list(
		/obj/item/reagent_containers/powder/flour/salt = 1,
		/obj/item/reagent_containers/food/snacks/rogue/doughslice= 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/crackers
	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/dough
	name = "dough"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "dough"
	slices_num = 2
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/doughslice
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bread
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/doughslice
	name = "smalldough"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "doughslice"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/bun
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/crackers
	name = "crackers"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "crackercook"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/crackerscooked
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/crackerscooked
	name = "crackers"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cracker6"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 12)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	foodtype = GRAIN
	bitesize = 6
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/crackerscooked/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "cracker5"
	if(bitecount == 2)
		icon_state = "cracker4"
	if(bitecount == 3)
		icon_state = "cracker3"
	if(bitecount == 4)
		icon_state = "cracker2"
	if(bitecount == 5)
		icon_state = "cracker1"


/datum/crafting_recipe/roguetown/cooking/cheeseegg
	name = "cheeseegg"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/egg = 1,
		/obj/item/reagent_containers/food/snacks/rogue/cheddarslice = 3,
		/obj/item/reagent_containers/food/snacks/rogue/doughslice = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/cheeseegg
	craftdiff = 1
	subtype_reqs = TRUE

/obj/item/reagent_containers/food/snacks/rogue/cheeseegg
	name = "cheeseegg"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheeseegg"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/cheeseeggcooked
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/cheeseeggcooked
	name = "cheeseegg"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheeseeggfinish"
	bitesize = 4
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/cheeseeggcooked
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("eggs" = 1,"cheese" = 1,"butter" = 1)
	foodtype = GRAIN
	eat_effect = null
	rotprocess = 30 MINUTES


/obj/item/reagent_containers/food/snacks/rogue/bread
	name = "bread"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "loaf6"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	foodtype = GRAIN
	slice_batch = FALSE
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/bread/update_icon()
	if(slices_num)
		icon_state = "loaf[slices_num]"
	else
		icon_state = "loaf_slice"

/obj/item/reagent_containers/food/snacks/rogue/bread/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 5
		if(bitecount == 2)
			slices_num = 4
		if(bitecount == 3)
			slices_num = 3
		if(bitecount == 4)
			slices_num = 2
		if(bitecount == 5)
			changefood(slice_path, eater)


/obj/item/reagent_containers/food/snacks/rogue/breadslice
	name = "sliced bread"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "loaf_slice"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	w_class = WEIGHT_CLASS_NORMAL
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	tastes = list("spelt" = 1)
	foodtype = GRAIN
	bitesize = 1
//this is a child so we can be used in sammies
/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	name = "toast"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "toast"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	cooked_type = null
	foodtype = GRAIN
	bitesize = 1
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/bun
	name = "bun"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "bun"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	foodtype = GRAIN
	bitesize = 2
	rotprocess = 30 MINUTES

/datum/crafting_recipe/roguetown/cooking/butterbiscuit
	name = "butter bun"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/biscuitcooked = 1,
		/obj/item/reagent_containers/food/snacks/butterslice= 1
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/bun
	subtype_reqs = FALSE
	craftdiff = 0

/obj/item/reagent_containers/food/snacks/rogue/biscuitcooked/butter
	name = "biscuit of butter"
	desc = ""
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterbiscuit"
	filling_color = "#F0E68C"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("butter" = 1, "biscuit" = 1)
	foodtype = GRAIN
	bitesize = 3
	rotprocess = 60 MINUTES

/datum/crafting_recipe/roguetown/cooking/honeybun
	name = "honey bun"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/bun = 1,
		/obj/item/reagent_containers/food/snacks/rogue/honey = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/bun/honey
	subtype_reqs = FALSE
	craftdiff = 0

/obj/item/reagent_containers/food/snacks/rogue/bun/honey
	name = "bun of honey"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "honeybun"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 13)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("sweetness and light" = 1)
	foodtype = GRAIN
	bitesize = 2
	rotprocess = 30 MINUTES

/datum/crafting_recipe/roguetown/cooking/btoast
	name = "buttered toast"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toastbuttered
	craftdiff = 0
	skillcraft = null
	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/breadslice/toastbuttered
	name = "toast that is buttered"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "toastb"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	foodtype = GRAIN
	bitesize = 2


/datum/crafting_recipe/roguetown/cooking/raisinloaf
	name = "raisin loaf"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/dough = 1,
		/obj/item/reagent_containers/food/snacks/rogue/raisins = 2)
	craftdiff = 1
	result = /obj/item/reagent_containers/food/snacks/rogue/rbreaduncooked

	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/rbreaduncooked
	name = "loaf of raisins"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "raisinbreaduncooked"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/raisinbread
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/raisinbread
	name = "raisin loaf"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "raisinbread6"
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/raisinbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("bread" = 1,"dried fruit" = 1)
	foodtype = GRAIN
	slice_batch = FALSE
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff

/obj/item/reagent_containers/food/snacks/rogue/raisinbread/update_icon()
	if(slices_num)
		icon_state = "raisinbread[slices_num]"
	else
		icon_state = "raisinbread_slice"

/obj/item/reagent_containers/food/snacks/rogue/raisinbread/On_Consume(mob/living/eater)
	..()
	if(slices_num)
		if(bitecount == 1)
			slices_num = 5
		if(bitecount == 2)
			slices_num = 4
		if(bitecount == 3)
			slices_num = 3
		if(bitecount == 4)
			slices_num = 2
		if(bitecount == 5)
			changefood(slice_path, eater)

/obj/item/reagent_containers/food/snacks/rogue/raisinbreadslice
	name = "raisin loaf slice"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "raisinbread_slice"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	w_class = WEIGHT_CLASS_NORMAL
	cooked_type = null
	tastes = list("spelt" = 1,"dried fruit" = 1)
	foodtype = GRAIN
	bitesize = 2
	eat_effect = /datum/status_effect/buff/foodbuff


/datum/crafting_recipe/roguetown/cooking/biscuit
	name = "biscuit"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/doughslice = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/biscuituncooked
	craftdiff = 0

	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/biscuituncooked
	name = "biscuit"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "uncookbiscuit"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/biscuitcooked
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/biscuitcooked
	name = "biscuit"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "biscuit"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("spelt" = 1)
	foodtype = GRAIN
	bitesize = 3
	rotprocess = 60 MINUTES

//=-=================================================================

/datum/crafting_recipe/roguetown/cooking/cheesecake
	name = "cheesecake"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/dough = 1,
		/obj/item/reagent_containers/food/snacks/egg = 1,
		/obj/item/reagent_containers/food/snacks/rogue/cheese = 2)
	result = /obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked
	craftdiff = 1
	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked
	name = "cake of cheese"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheesecakeuncook"
	slices_num = 0
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/ccake
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("dough" = 1)
	foodtype = GRAIN
	eat_effect = /datum/status_effect/debuff/uncookedfood
	rotprocess = 30 MINUTES

/obj/item/reagent_containers/food/snacks/rogue/ccake
	name = "cheesecake"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheesecake"
	slices_num = 8
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/ccakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 48)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("sweet cheese"=1)
	foodtype = GRAIN
	slice_batch = TRUE
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff
	bitesize = 16

/obj/item/reagent_containers/food/snacks/rogue/ccakeslice
	name = "cheesecake slice"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheesecake_slice"
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	w_class = WEIGHT_CLASS_NORMAL
	cooked_type = null
	tastes = list("sweet cheese"=1)
	foodtype = GRAIN
	bitesize = 2
	eat_effect = /datum/status_effect/buff/foodbuff
	rotprocess = 20 MINUTES
