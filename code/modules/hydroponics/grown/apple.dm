// Apple
/obj/item/seeds/apple
	name = "seeds"
	desc = ""
	icon_state = "seed"
	species = "apple"
	plantname = "apple tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	color = "#524441"
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "apple-grow"
	icon_dead = "apple-dead"
//	genes = list(/datum/plant_gene/trait/repeated_harvest)
//	mutatelist = list(/obj/item/seeds/apple/gold)
	delonharvest = FALSE

/obj/item/seeds/apple/New()
	. = ..()
	yield = rand(3,5)

/obj/item/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/apple
	name = "apple"
	desc = ""
	icon_state = "apple"
	filling_color = "#FF4500"
	bitesize = 3
	foodtype = FRUIT
	juice_results = list(/datum/reagent/consumable/applejuice = 0)
	tastes = list("apple" = 1)
	trash = /obj/item/trash/applecore
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/64x64/head.dmi'
	slot_flags = ITEM_SLOT_HEAD
	worn_x_dimension = 64
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	worn_y_dimension = 64
	var/equippedloc = null
	rotprocess = 12 MINUTES
	can_distill = TRUE
	distill_reagent = /datum/reagent/consumable/ethanol/beer/cider
	var/list/bitten_names = list()

/obj/item/reagent_containers/food/snacks/grown/apple/On_Consume(mob/living/eater)
	..()
	if(ishuman(eater))
		var/mob/living/carbon/human/H = eater
		if(!(H.real_name in bitten_names))
			bitten_names += H.real_name

/obj/item/reagent_containers/food/snacks/grown/apple/blockproj(mob/living/carbon/human/H)
	testing("APPLEHITBEGIN")
	if(prob(98))
		H.visible_message("<span class='notice'>[H] is saved by the apple!</span>")
//		playsound(get_turf(owner),'sound/blank.ogg', 100, TRUE)
		H.dropItemToGround(H.head)
		return 1
	else
		H.dropItemToGround(H.head)
		return 0

/obj/item/reagent_containers/food/snacks/grown/apple/equipped(mob/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.head == src)
			testing("equipped applz")
			equippedloc = H.loc
			START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/grown/apple/process()
	. = ..()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.head == src)
			if(equippedloc != H.loc)
				H.dropItemToGround(H.head)

/obj/item/trash/applecore
	name = "apple core"
	icon_state = "applecore"
	icon = 'icons/roguetown/items/produce.dmi'
	baitchance = 75
	fishloot = list(/obj/item/reagent_containers/food/snacks/fish/carp = 10,
					/obj/item/reagent_containers/food/snacks/fish/eel = 5,
					/obj/item/reagent_containers/food/snacks/fish/angler = 1)

// Gold Apple
/obj/item/seeds/apple/gold
	name = "pack of golden apple seeds"
	desc = ""
	icon_state = "seed"
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/apple/gold
	maturation = 10
	production = 10
	mutatelist = list()
	reagents_add = list(/datum/reagent/gold = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 40 // Alchemy!

/obj/item/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/apple/gold
	name = "golden apple"
	desc = ""
	icon_state = "goldapple"
	filling_color = "#FFD700"
	distill_reagent = null
	wine_power = 50
