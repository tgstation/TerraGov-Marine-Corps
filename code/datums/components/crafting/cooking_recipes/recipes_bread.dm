////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/crafting_recipe/food/xenomeatbread
	name = "Xenomeat bread"
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/xeno = 3,
		/obj/item/food/cheese/wedge = 3
	)
	result = /obj/item/food/bread/xenomeat
	category = CAT_BREAD

/datum/crafting_recipe/food/jelly_burger
	name = "Jelly burger"
	reqs = list(/obj/item/food/bread = 1)
	result = /obj/item/reagent_containers/food/snacks/burger/jelly/slime
	category = CAT_BREAD

//debug
/obj/item/food/bread/plain
/obj/item/food/meat/cutlet/xeno
/obj/item/food/cheese/wedge
/obj/item/food/bread/xenomeat
