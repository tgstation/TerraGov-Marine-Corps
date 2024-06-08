//Food vendor

/obj/machinery/vending/marineFood
	name = "\improper Marine Food and Drinks Vendor"
	desc = "Standard Issue Food and Drinks Vendor, containing standard military food and drinks."
	icon_state = "sustenance"
	icon_vend = "sustenance-vend"
	icon_deny = "sustenance-deny"
	wrenchable = FALSE
	isshared = TRUE
	product_ads = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it.;You should have joined the Air Force if you wanted better food.;1200 calories in just a few bites!;Get that tabaso sauce to make it tasty!;Try the cornbread.;Try the pizza.;Try the pasta.;Try the tofu, wimp.;Try the pork.; 9 Flavors of Protein!; You'll never guess the mystery flavor!"
	products = list(
		/obj/item/reagent_containers/food/snacks/protein_pack = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal1 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal2 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal3 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal4 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal5 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal6 = -1,
		/obj/item/storage/box/MRE = -1,
		/obj/item/reagent_containers/food/drinks/flask/marine = -1,
	)
//Christmas inventory
/*
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 25,
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 25,
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas3 = 25)*/

/obj/machinery/vending/marineFood/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

/obj/machinery/vending/marineFood/som
	name = "\improper SOM Food and Drinks Vendor"
	faction = FACTION_SOM
	products = list(
		/obj/item/reagent_containers/food/snacks/protein_pack/som = -1,
		/obj/item/storage/box/MRE/som = -1,
		/obj/item/reagent_containers/food/drinks/flask/marine = -1,
	)