// Corn
/obj/item/seeds/corn
	desc = ""
	species = "corn"
	plantname = "corn stalks"
	product = /obj/item/natural/chaff/corn
	maturation = 8
	production = 1
	yield = 1
	potency = 1
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "corn-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "corn-dead" // Same for the dead icon
	mutatelist = list(/obj/item/seeds/corn/snapcorn)
	reagents_add = list(/datum/reagent/consumable/cornoil = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/natural/chaff/corn
	icon_state = "cornchaff"
	name = "ear of corn"
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/corn
	canthresh = FALSE //gotta shuck these manually

/obj/item/reagent_containers/food/snacks/grown/corn
	seed = /obj/item/seeds/corn
	name = "ear of corn"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "corn"
	cooked_type = /obj/item/reagent_containers/food/snacks/popcorn
	filling_color = "#FFFF00"
	trash = /obj/item/grown/corncob
	bitesize_mod = 2
	foodtype = VEGETABLES
	juice_results = list(/datum/reagent/consumable/corn_starch = 0)
	tastes = list("corn" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/whiskey

/obj/item/grown/corncob
	name = "corn cob"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 1
	throw_range = 7
	grind_results = list(/datum/reagent/cellulose = 10) //really partially hemicellulose

/obj/item/grown/corncob/attackby(obj/item/grown/W, mob/user, params)
	if(W.get_sharpness())
		to_chat(user, "<span class='notice'>I use [W] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
	else
		return ..()

// Snapcorn
/obj/item/seeds/corn/snapcorn
	name = "pack of snapcorn seeds"
	desc = ""
	icon_state = "seed"
	species = "snapcorn"
	plantname = "Snapcorn Stalks"
	product = /obj/item/grown/snapcorn
	mutatelist = list()
	rarity = 10

/obj/item/grown/snapcorn
	seed = /obj/item/seeds/corn/snapcorn
	name = "snap corn"
	desc = ""
	icon_state = "snapcorn"
	item_state = "corncob"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 1
	throw_range = 7
	var/snap_pops = 1

/obj/item/grown/snapcorn/add_juice()
	..()
	snap_pops = max(round(seed.potency/8), 1)

/obj/item/grown/snapcorn/attack_self(mob/user)
	..()
	to_chat(user, "<span class='notice'>I pick a snap pop from the cob.</span>")
	var/obj/item/toy/snappop/S = new /obj/item/toy/snappop(user.loc)
	if(ishuman(user))
		user.put_in_hands(S)
	snap_pops -= 1
	if(!snap_pops)
		new /obj/item/grown/corncob(user.loc)
		qdel(src)
