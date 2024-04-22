// Eggplant
/obj/item/seeds/eggplant
	name = "pack of eggplant seeds"
	desc = ""
	icon_state = "seed"
	species = "eggplant"
	plantname = "Eggplants"
	product = /obj/item/reagent_containers/food/snacks/grown/eggplant
	yield = 2
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "eggplant-grow"
	icon_dead = "eggplant-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/eggplant/eggy)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/eggplant
	seed = /obj/item/seeds/eggplant
	name = "eggplant"
	desc = ""
	icon_state = "eggplant"
	filling_color = "#800080"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 20

// Egg-Plant
/obj/item/seeds/eggplant/eggy
	name = "pack of egg-plant seeds"
	desc = ""
	icon_state = "seed"
	species = "eggy"
	plantname = "Egg-Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/shell/eggy
	lifespan = 75
	production = 12
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/shell/eggy
	seed = /obj/item/seeds/eggplant/eggy
	name = "egg-plant"
	desc = ""
	icon_state = "eggyplant"
	trash = /obj/item/reagent_containers/food/snacks/egg
	filling_color = "#F8F8FF"
	bitesize_mod = 2
	foodtype = MEAT
	distill_reagent = /datum/reagent/consumable/ethanol/eggnog
