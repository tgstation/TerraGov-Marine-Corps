/datum/crafting_recipe/roguetown/cooking/sausage
	name = "sausage (mm)"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/mince = 2)
	result = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage

	req_table = TRUE
	subtype_reqs = TRUE

/datum/crafting_recipe/roguetown/cooking/sausage/mf
	name = "sausage (mf)"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/mince = 1,
		/obj/item/reagent_containers/food/snacks/fat = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage


/datum/crafting_recipe/roguetown/cooking/sausage/bb
	name = "sausage (bb)"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/bacon = 2)
	result = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage


/datum/crafting_recipe/roguetown/cooking/sausage/fb
	name = "sausage (fb)"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/bacon = 1,
		/obj/item/reagent_containers/food/snacks/fat = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/meat/sausage


/datum/crafting_recipe/roguetown/cooking/salami
	name = "salumoi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/sausage = 1,
		/obj/item/reagent_containers/powder/flour/salt = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/meat/salami
	req_table = FALSE
	structurecraft = /obj/structure/fluff/dryingrack
	craftdiff = 0

/datum/crafting_recipe/roguetown/cooking/coppiette
	name = "coppiette"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1,
		/obj/item/reagent_containers/powder/flour/salt = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/meat/coppiette
	req_table = FALSE
	craftdiff = 0
	structurecraft = /obj/structure/fluff/dryingrack


/datum/crafting_recipe/roguetown/cooking/salo
	name = "salo"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fat = 1,
		/obj/item/reagent_containers/powder/flour/salt = 1)
	result = /obj/item/reagent_containers/food/snacks/fat/salo
	craftdiff = 0
	structurecraft = /obj/structure/fluff/dryingrack
	req_table = FALSE

/datum/crafting_recipe/roguetown/cooking/saltfish
	name = "saltfish"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/fish = 1,
		/obj/item/reagent_containers/powder/flour/salt = 1)
	parts = list(
		/obj/item/reagent_containers/food/snacks/fish = 1)
	result = /obj/item/reagent_containers/food/snacks/rogue/saltfish
	req_table = FALSE
	craftdiff = 0
	subtype_reqs = TRUE
	structurecraft = /obj/structure/fluff/dryingrack
