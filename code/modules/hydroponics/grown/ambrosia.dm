// Ambrosia - base type
/obj/item/reagent_containers/food/snacks/grown/ambrosia
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia branch"
	desc = ""
	icon_state = "ambrosiavulgaris"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#008000"
	bitesize_mod = 2
	foodtype = VEGETABLES
	tastes = list("ambrosia" = 1)

// Ambrosia Vulgaris
/obj/item/seeds/ambrosia
	name = "pack of ambrosia vulgaris seeds"
	desc = ""
	icon_state = "seed"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	lifespan = 60
	endurance = 25
	yield = 6
	potency = 5
	icon_dead = "ambrosia-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/ambrosia/deus)
	reagents_add = list(/datum/reagent/medicine/C2/aiuri = 0.1, /datum/reagent/medicine/C2/libital = 0.1 ,/datum/reagent/drug/space_drugs = 0.15, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/toxin = 0.1)

/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia vulgaris branch"
	desc = ""
	wine_power = 30

// Ambrosia Deus
/obj/item/seeds/ambrosia/deus
	name = "pack of ambrosia deus seeds"
	desc = ""
	icon_state = "seed"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/deus
	mutatelist = list(/obj/item/seeds/ambrosia/gaia)
	reagents_add = list(/datum/reagent/medicine/omnizine = 0.15, /datum/reagent/medicine/synaptizine = 0.15, /datum/reagent/drug/space_drugs = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)
	rarity = 40

/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosia/deus
	name = "ambrosia deus branch"
	desc = ""
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"
	wine_power = 50

//Ambrosia Gaia
/obj/item/seeds/ambrosia/gaia
	name = "pack of ambrosia gaia seeds"
	desc = ""
	icon_state = "seed"
	species = "ambrosia_gaia"
	plantname = "Ambrosia Gaia"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia
	mutatelist = list(/obj/item/seeds/ambrosia/deus)
	reagents_add = list(/datum/reagent/medicine/earthsblood = 0.05, /datum/reagent/consumable/nutriment = 0.06, /datum/reagent/consumable/nutriment/vitamin = 0.05)
	rarity = 30 //These are some pretty good plants right here
	genes = list()
	weed_rate = 4
	weed_chance = 100

/obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia
	name = "ambrosia gaia branch"
	desc = ""
	icon_state = "ambrosia_gaia"
	filling_color = rgb(255, 175, 0)
	light_range = 3
	seed = /obj/item/seeds/ambrosia/gaia
	wine_power = 70
	wine_flavor = "the earthmother's blessing"
