// Carrot
/obj/item/seeds/carrot
	name = "pack of carrot seeds"
	desc = ""
	icon_state = "seed"
	species = "carrot"
	plantname = "Carrots"
	product = /obj/item/reagent_containers/food/snacks/grown/carrot
	maturation = 10
	production = 1
	yield = 5
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	mutatelist = list(/obj/item/seeds/carrot/parsnip)
	reagents_add = list(/datum/reagent/medicine/oculine = 0.25, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/carrot
	seed = /obj/item/seeds/carrot
	name = "carrot"
	desc = ""
	icon_state = "carrot"
	filling_color = "#FFA500"
	bitesize_mod = 2
	foodtype = VEGETABLES
	juice_results = list(/datum/reagent/consumable/carrotjuice = 0)
	wine_power = 30

/obj/item/reagent_containers/food/snacks/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(I.get_sharpness())
		to_chat(user, "<span class='notice'>I sharpen the carrot into a shiv with [I].</span>")
		var/obj/item/kitchen/knife/carrotshiv/Shiv = new /obj/item/kitchen/knife/carrotshiv
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Shiv)
	else
		return ..()

// Parsnip
/obj/item/seeds/carrot/parsnip
	name = "pack of parsnip seeds"
	desc = ""
	icon_state = "seed"
	species = "parsnip"
	plantname = "Parsnip"
	product = /obj/item/reagent_containers/food/snacks/grown/parsnip
	icon_dead = "carrot-dead"
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/parsnip
	seed = /obj/item/seeds/carrot/parsnip
	name = "parsnip"
	desc = ""
	icon_state = "parsnip"
	bitesize_mod = 2
	foodtype = VEGETABLES
	juice_results = list(/datum/reagent/consumable/parsnipjuice = 0)
	wine_power = 35


// White-Beet
/obj/item/seeds/whitebeet
	name = "pack of white-beet seeds"
	desc = ""
	icon_state = "seed"
	species = "whitebeet"
	plantname = "White-Beet Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/whitebeet
	lifespan = 60
	endurance = 50
	yield = 6
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	mutatelist = list(/obj/item/seeds/redbeet)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/sugar = 0.2, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/whitebeet
	seed = /obj/item/seeds/whitebeet
	name = "white-beet"
	desc = ""
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 40

// Red Beet
/obj/item/seeds/redbeet
	name = "pack of redbeet seeds"
	desc = ""
	icon_state = "seed"
	species = "redbeet"
	plantname = "Red-Beet Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/redbeet
	lifespan = 60
	endurance = 50
	yield = 6
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_dead = "whitebeet-dead"
	genes = list(/datum/plant_gene/trait/maxchem)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/reagent_containers/food/snacks/grown/redbeet
	seed = /obj/item/seeds/redbeet
	name = "red beet"
	desc = ""
	icon_state = "redbeet"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 60
