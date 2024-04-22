
/obj/item/reagent_containers/food/snacks/rogue/raisins
	name = "raisins"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "raisins5"
	bitesize = 5
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("dried fruit" = 1)
	foodtype = GRAIN
	eat_effect = null
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/raisins/On_Consume(mob/living/eater)
	..()
	if(bitecount == 1)
		icon_state = "raisins4"
	if(bitecount == 2)
		icon_state = "raisins3"
	if(bitecount == 3)
		icon_state = "raisins2"
	if(bitecount == 4)
		icon_state = "raisins1"

/obj/item/reagent_containers/food/snacks/rogue/raisins/CheckParts(list/parts_list, datum/crafting_recipe/R)
	..()
	for(var/obj/item/reagent_containers/food/snacks/M in parts_list)
		color = M.filling_color
		if(M.reagents)
			M.reagents.remove_reagent(/datum/reagent/consumable/nutriment, M.reagents.total_volume)
			M.reagents.trans_to(src, M.reagents.total_volume)
		qdel(M)


/obj/item/reagent_containers/food/snacks/rogue/cheese
	name = "cheese"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "freshcheese"
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("cheese" = 1)
	foodtype = GRAIN
	eat_effect = null
	rotprocess = 15 MINUTES
	become_rot_type = null
	slice_path = null

/obj/item/reagent_containers/food/snacks/rogue/cheddar
	name = "wheel of cheese"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheesewheel"
	bitesize = 6
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("cheese" = 1)
	eat_effect = null
	rotprocess = 20 MINUTES
	slices_num = 6
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/cheddar/aged

/obj/item/reagent_containers/food/snacks/rogue/cheddar/aged
	name = "wheel of aged cheese"
	icon_state = "blue_cheese"
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	become_rot_type = null
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	name = "wedge of cheese"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheese_wedge"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("cheese" = 1)
	eat_effect = null
	rotprocess = 15 MINUTES
	slices_num = 3
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	become_rot_type = /obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	baitchance = 100
	fishloot = list(/obj/item/reagent_containers/food/snacks/fish/carp = 10,
					/obj/item/reagent_containers/food/snacks/fish/eel = 5,
					/obj/item/reagent_containers/food/snacks/fish/angler = 1)

/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge/aged
	name = "wedge of aged cheese"
	icon_state = "blue_cheese_wedge"
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/cheddarslice/aged
	become_rot_type = null
	rotprocess = null

/obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	name = "slice of cheese"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "cheese_slice"
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("cheese" = 1)
	eat_effect = null
	rotprocess = 15 MINUTES
	slices_num = null
	slice_path = null
	become_rot_type = null
	baitchance = 100
	fishloot = list(/obj/item/reagent_containers/food/snacks/fish/carp = 10,
					/obj/item/reagent_containers/food/snacks/fish/eel = 5)

/obj/item/reagent_containers/food/snacks/rogue/cheddarslice/aged
	name = "slice of aged cheese"
	icon_state = "blue_cheese_slice"
	become_rot_type = null
	rotprocess = null


/obj/item/reagent_containers/food/snacks/rogue/honey
	name = "honey"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "honey"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("sweetness and light" = 1)
	eat_effect = null
	rotprocess = null
