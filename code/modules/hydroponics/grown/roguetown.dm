#define BERRYCOLORS		list("#6a6699", "#9b6464", "#58a75c", "#5658a9", "#669799")
GLOBAL_LIST_EMPTY(berrycolors)

// Apple
/obj/item/seeds/berryrogue
	name = "seeds"
	desc = ""
	icon_state = "seed"
	species = "berry"
	plantname = "berry bush"
	product = /obj/item/reagent_containers/food/snacks/grown/berries/rogue
	lifespan = 55
	endurance = 35
	color = "#524441"
	yield = 5
//	genes = list(/datum/plant_gene/trait/repeated_harvest)
//	mutatelist = list(/obj/item/seeds/apple/gold)
	delonharvest = FALSE

/obj/item/seeds/berryrogue/New()
	. = ..()
	yield = rand(1,5)

/obj/item/reagent_containers/food/snacks/grown/berries/rogue
	seed = /obj/item/seeds/berryrogue
	name = "jacksberries"
	desc = ""
	icon_state = "berries"
	tastes = list("berry" = 1)
	bitesize = 5
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	dropshrink = 0.75
	var/color_index = "good"
	can_distill = TRUE
	distill_reagent = /datum/reagent/consumable/ethanol/beer/wine
	rotprocess = 10 MINUTES

/obj/item/reagent_containers/food/snacks/grown/berries/rogue/Initialize()
	if(GLOB.berrycolors[color_index])
		filling_color = GLOB.berrycolors[color_index]
	else
		var/newcolor = pick(BERRYCOLORS)
		if(newcolor in GLOB.berrycolors)
			GLOB.berrycolors[color_index] = pick(BERRYCOLORS)
		else
			GLOB.berrycolors[color_index] = newcolor
		filling_color = GLOB.berrycolors[color_index]
	update_icon()
	..()

/obj/item/reagent_containers/food/snacks/grown/berries/rogue/On_Consume(mob/living/eater)
	..()
	update_icon()

/obj/item/reagent_containers/food/snacks/grown/berries/rogue/update_icon()
	cut_overlays()
	var/used_state = "berriesc5"
	if(bitecount == 1)
		used_state = "berriesc4"
	if(bitecount == 2)
		used_state = "berriesc3"
	if(bitecount == 3)
		used_state = "berriesc2"
	if(bitecount == 4)
		used_state = "berriesc1"
	var/image/item_overlay = image(used_state)
	item_overlay.color = filling_color
	add_overlay(item_overlay)

/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison
	seed = /obj/item/seeds/berryrogue/poison
	icon_state = "berries"
	tastes = list("berry" = 1)
	list_reagents = list(/datum/reagent/berrypoison = 5, /datum/reagent/consumable/nutriment = 3)
	color_index = "bad"

/obj/item/seeds/berryrogue/poison
	product = /obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison
