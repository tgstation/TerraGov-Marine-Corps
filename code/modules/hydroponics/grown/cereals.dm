// Wheat
/obj/item/seeds/wheat
	desc = ""
	species = "wheat"
	plantname = "wheat stalks"
	product = /obj/item/natural/chaff/wheat
	production = 1
	yield = 2
	potency = 1
	icon_dead = "wheat-dead"
//	mutatelist = list(/obj/item/seeds/wheat/oat, /obj/item/seeds/wheat/meat)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.04)

/obj/item/seeds/wheat/New()
	. = ..()
	yield = rand(1,4)


/obj/item/natural/chaff/wheat
	icon_state = "wheatchaff"
	name = "wheat stalks"
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/wheat

/obj/item/reagent_containers/food/snacks/grown/wheat
	seed = /obj/item/seeds/wheat
	name = "grain"
	desc = ""
	gender = PLURAL
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "wheat"
	filling_color = "#F0E68C"
	bitesize_mod = 2
	foodtype = GRAIN
	grind_results = list(/datum/reagent/consumable/flour = 0)
	tastes = list("wheat" = 1)
	mill_result = /obj/item/reagent_containers/powder/flour
	can_distill = TRUE
	distill_reagent = /datum/reagent/consumable/ethanol/beer
	distill_amt = 24
// Oat
/obj/item/seeds/wheat/oat
	desc = ""
	species = "oat"
	plantname = "oat stalks"
	product = /obj/item/natural/chaff/oat
	mutatelist = list()

/obj/item/natural/chaff/oat
	name = "oat stalks"
	icon_state = "oatchaff"
	chafftype = 2
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/oat

/obj/item/reagent_containers/food/snacks/grown/oat
	seed = /obj/item/seeds/wheat/oat
	name = "grain"
	desc = ""
	gender = PLURAL
	icon_state = "oat"
	filling_color = "#556B2F"
	icon = 'icons/roguetown/items/produce.dmi'
	bitesize_mod = 2
	foodtype = GRAIN
	grind_results = list(/datum/reagent/consumable/flour = 0)
	mill_result = /obj/item/reagent_containers/powder/flour
	tastes = list("oat" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/ale

// Rice
/obj/item/seeds/wheat/rice
	desc = ""
	species = "rice"
	plantname = "rice stalks"
	product = /obj/item/natural/chaff/rice
	mutatelist = list()
	growthstages = 3

/obj/item/natural/chaff/rice
	icon_state = "ricechaff"
	name = "rice stalks"
	chafftype = 2
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/rice

/obj/item/reagent_containers/food/snacks/grown/rice
	seed = /obj/item/seeds/wheat/rice
	name = "rice"
	desc = ""
	gender = PLURAL
	icon_state = "rice"
	filling_color = "#FAFAD2"
	icon = 'icons/roguetown/items/produce.dmi'
	bitesize_mod = 2
	foodtype = GRAIN
	grind_results = list(/datum/reagent/consumable/rice = 0)
	tastes = list("rice" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/sake

//Meatwheat - grows into synthetic meat
/obj/item/seeds/wheat/meat
	name = "pack of meatwheat seeds"
	desc = ""
	icon_state = "seed"
	species = "meatwheat"
	plantname = "Meatwheat"
	product = /obj/item/reagent_containers/food/snacks/grown/meatwheat
	mutatelist = list()

/obj/item/reagent_containers/food/snacks/grown/meatwheat
	name = "meatwheat"
	desc = ""
	icon_state = "meatwheat"
	gender = PLURAL
	filling_color = rgb(150, 0, 0)
	bitesize_mod = 2
	seed = /obj/item/seeds/wheat/meat
	foodtype = MEAT | GRAIN
	grind_results = list(/datum/reagent/consumable/flour = 0, /datum/reagent/blood = 0)
	tastes = list("meatwheat" = 1)
	can_distill = FALSE

/obj/item/reagent_containers/food/snacks/grown/meatwheat/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] crushes [src] into meat.</span>", "<span class='notice'>I crush [src] into something that resembles meat.</span>")
	playsound(user, 'sound/blank.ogg', 50, TRUE)
	var/obj/item/reagent_containers/food/snacks/meat/slab/meatwheat/M = new
	qdel(src)
	user.put_in_hands(M)
	return 1
