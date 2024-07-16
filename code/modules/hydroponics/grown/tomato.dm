// Tomato
/obj/item/seeds/tomato
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	species = "tomato"
	plantname = "Tomato Plants"
	product = /obj/item/food/grown/tomato
	maturation = 8
	instability = 25
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "tomato-grow"
	icon_dead = "tomato-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/tomato/blue, /obj/item/seeds/tomato/blood)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/tomato
	seed = /obj/item/seeds/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/ketchup = 0)
	juice_typepath = /datum/reagent/consumable/tomatojuice
	distill_reagent = /datum/reagent/consumable/enzyme

// Blood Tomato
/obj/item/seeds/tomato/blood
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product = /obj/item/food/grown/tomato/blood
	mutatelist = null
	reagents_add = list(/datum/reagent/blood = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = PLANT_MODERATELY_RARE

/obj/item/food/grown/tomato/blood
	seed = /obj/item/seeds/tomato/blood
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	bite_consumption_mod = 3
	foodtypes = FRUIT | GORE
	grind_results = list(/datum/reagent/consumable/ketchup = 0, /datum/reagent/blood = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/bloody_mary

// Blue Tomato
/obj/item/seeds/tomato/blue
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product = /obj/item/food/grown/tomato/blue
	yield = 2
	icon_grow = "bluetomato-grow"
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/lube = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = PLANT_MODERATELY_RARE
	graft_gene = /datum/plant_gene/trait/slip

/obj/item/food/grown/tomato/blue
	seed = /obj/item/seeds/tomato/blue
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	bite_consumption_mod = 2
	distill_reagent = /datum/reagent/consumable/laughter
