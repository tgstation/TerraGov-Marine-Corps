// Tobacco
/obj/item/seeds/tobacco
	name = "pack of tobacco seeds"
	desc = ""
	icon_state = "seed"
	species = "tobacco"
	plantname = "Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco
	lifespan = 20
	maturation = 5
	production = 5
	yield = 10
	growthstages = 3
	icon_dead = "tobacco-dead"
	mutatelist = list(/obj/item/seeds/tobacco/space)
	reagents_add = list(/datum/reagent/drug/nicotine = 0.03, /datum/reagent/consumable/nutriment = 0.03)

/obj/item/reagent_containers/food/snacks/grown/tobacco
	seed = /obj/item/seeds/tobacco
	name = "tobacco leaves"
	desc = ""
	icon_state = "tobacco_leaves"
	filling_color = "#008000"
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_menthe //Menthol, I guess.

// Space Tobacco
/obj/item/seeds/tobacco/space
	name = "pack of space tobacco seeds"
	desc = ""
	icon_state = "seed"
	species = "stobacco"
	plantname = "Space Tobacco Plant"
	product = /obj/item/reagent_containers/food/snacks/grown/tobacco/space
	mutatelist = list()
	reagents_add = list(/datum/reagent/medicine/salbutamol = 0.05, /datum/reagent/drug/nicotine = 0.08, /datum/reagent/consumable/nutriment = 0.03)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/tobacco/space
	seed = /obj/item/seeds/tobacco/space
	name = "space tobacco leaves"
	desc = ""
	icon_state = "stobacco_leaves"
	distill_reagent = null
	wine_power = 50
