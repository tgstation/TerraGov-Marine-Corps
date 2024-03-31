/obj/item/reagent_containers/food/snacks/rogue/peppersteak
	icon = 'icons/roguetown/items/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 25)
	tastes = list("steak" = 1, "pepper" = 1)
	name = "peppersteak"
	desc = ""
	icon_state = "peppersteak"
	foodtype = MEAT
	warming = 5 MINUTES
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'

/datum/crafting_recipe/roguetown/cooking/peppersteak
	name = "peppersteak"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/steak/fried = 1,
		/datum/reagent/consumable/blackpepper = 1
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/peppersteak
	skillcraft = null

/obj/item/reagent_containers/food/snacks/rogue/spicedeggs
	icon = 'icons/roguetown/items/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("steak" = 1, "pepper" = 1)
	name = "spiced eggs"
	desc = ""
	icon_state = "spicedeggs"
	foodtype = MEAT
	warming = 5 MINUTES
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'

/datum/crafting_recipe/roguetown/cooking/spicedeggs
	name = "spiced eggs"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/friedegg = 2,
		/datum/reagent/consumable/blackpepper = 1
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/spicedeggs
	skillcraft = 0
	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/eggtoast
	icon = 'icons/roguetown/items/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	tastes = list("toast" = 1, "eggs" = 1)
	name = "eggtoast"
	desc = ""
	icon_state = "eggtoast"
	foodtype = MEAT
	warming = 5 MINUTES
	rotprocess = 30 MINUTES
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'

/datum/crafting_recipe/roguetown/cooking/eggtoast
	name = "eggtoast"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/friedegg = 1,
		/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast = 1
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/eggtoast
	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/eggcheese
	icon = 'icons/roguetown/items/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("steak" = 1, "pepper" = 1)
	name = "eggcheese"
	desc = ""
	icon_state = "eggcheese"
	foodtype = MEAT
	warming = 5 MINUTES
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff

/datum/crafting_recipe/roguetown/cooking/eggcheese
	name = "eggcheese"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/friedegg = 2,
		/obj/item/reagent_containers/food/snacks/rogue/cheddarslice = 2
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/eggcheese

	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/dogroll
	icon = 'icons/roguetown/items/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("sausage" = 1, "bun" = 1)
	name = "dogroll"
	desc = ""
	icon_state = "hotdog"
	foodtype = MEAT
	warming = 5 MINUTES
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff

/datum/crafting_recipe/roguetown/cooking/dogroll
	name = "dogroll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked = 1,
		/obj/item/reagent_containers/food/snacks/rogue/bun = 1
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/dogroll
	skillcraft = null
	subtype_reqs = FALSE

/obj/item/reagent_containers/food/snacks/rogue/sandwich
	icon = 'icons/roguetown/items/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	tastes = list("salami" = 1,"cheese" = 1, "bread" = 1)
	name = "sandwich"
	desc = ""
	icon_state = "sandwich"
	foodtype = MEAT
	warming = 5 MINUTES
	rotprocess = 30 MINUTES
	eat_effect = /datum/status_effect/buff/foodbuff

/datum/crafting_recipe/roguetown/cooking/sandwich
	name = "sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/breadslice = 2,
		/obj/item/reagent_containers/food/snacks/rogue/cheddarslice = 1,
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice = 2
	)
	result = /obj/item/reagent_containers/food/snacks/rogue/sandwich
	craftdiff = 0
	subtype_reqs = TRUE