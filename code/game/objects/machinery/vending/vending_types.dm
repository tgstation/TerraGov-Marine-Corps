
/*
* Vending machine types
*/

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	premium = list()

*/

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/tank/oxygen;/obj/item/tank/phoron;/obj/item/tank/emergency_oxygen;/obj/item/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	icon_vend = "boozeomat-vend"
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	products = list(
		/obj/item/reagent_containers/food/drinks/bottle/gin = -1,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = -1,
		/obj/item/reagent_containers/food/drinks/bottle/tequila = -1,
		/obj/item/reagent_containers/food/drinks/bottle/vodka = -1,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth = -1,
		/obj/item/reagent_containers/food/drinks/bottle/rum = -1,
		/obj/item/reagent_containers/food/drinks/bottle/wine = -1,
		/obj/item/reagent_containers/food/drinks/bottle/cognac = -1,
		/obj/item/reagent_containers/food/drinks/bottle/kahlua = -1,
		/obj/item/reagent_containers/food/drinks/cans/beer = -1,
		/obj/item/reagent_containers/food/drinks/cans/ale = -1,
		/obj/item/reagent_containers/food/drinks/bottle/orangejuice = -1,
		/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = -1,
		/obj/item/reagent_containers/food/drinks/bottle/limejuice = -1,
		/obj/item/reagent_containers/food/drinks/bottle/cream = -1,
		/obj/item/reagent_containers/food/drinks/cans/tonic = -1,
		/obj/item/reagent_containers/food/drinks/cans/cola = -1,
		/obj/item/reagent_containers/food/drinks/cans/sodawater = -1,
		/obj/item/reagent_containers/food/drinks/flask/barflask = -1,
		/obj/item/reagent_containers/food/drinks/flask/vacuumflask = -1,
		/obj/item/reagent_containers/food/drinks/drinkingglass = -1,
		/obj/item/reagent_containers/food/drinks/ice = -1,
		/obj/item/reagent_containers/food/drinks/bottle/melonliquor = -1,
		/obj/item/reagent_containers/food/drinks/bottle/bluecuracao = -1,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe = -1,
		/obj/item/reagent_containers/food/drinks/bottle/grenadine = -1,
		/obj/item/reagent_containers/food/drinks/cans/aspen = -1,
		/obj/item/reagent_containers/food/drinks/bottle/davenport = -1,
		/obj/item/reagent_containers/food/drinks/tea = -1,
	)
	idle_power_usage = 211

/obj/machinery/vending/assist
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	icon_vend = "generic-vend"
	icon_deny = "generic-deny"
	products = list(
		/obj/item/assembly/prox_sensor = 5,
		/obj/item/assembly/igniter = 3,
		/obj/item/assembly/signaler = 4,
		/obj/item/tool/wirecutters = 1,
		/obj/item/flashlight = 5,
		/obj/item/assembly/timer = 2,
	)

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	//product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	icon_deny = "coffee-deny"
	vending_sound = 'sound/machines/vending_coffee.ogg'
	vend_delay = 34
	products = list(
		/obj/item/reagent_containers/food/drinks/coffee = -1,
		/obj/item/reagent_containers/food/drinks/coffee/cafe_latte = -1,
		/obj/item/reagent_containers/food/drinks/tea = -1,
		/obj/item/reagent_containers/food/drinks/h_chocolate = -1,
		/obj/item/reagent_containers/food/drinks/ice = -1,
	)

/obj/machinery/vending/snack
	name = "Hot Foods Machine"
	desc = "A vending machine full of ready to cook meals, mhmmmm taste the nutritional goodness!"
	product_slogans = "Kepler Crisps! Try a snack that's out of this world!;Eat an EAT!;Eat a Nanotrasen brand packaged hamburger.;Eat a Nanotrasen brand packaged hot dog.;Eat a Nanotrasen brand packaged burrito.;"
	icon_state = "snack"
	icon_vend = "snack-vend"
	icon_deny = "snack-deny"
	products = list(
		/obj/item/reagent_containers/food/snacks/burger/packaged_burger = -1,
		/obj/item/reagent_containers/food/snacks/packaged_burrito = -1,
		/obj/item/reagent_containers/food/snacks/packaged_hdogs = -1,
		/obj/item/reagent_containers/food/snacks/kepler_crisps = -1,
		/obj/item/reagent_containers/food/snacks/enrg_bar = -1,
		/obj/item/reagent_containers/food/snacks/wrapped/booniebars = -1,
		/obj/item/reagent_containers/food/snacks/wrapped/chunk = -1,
		/obj/item/reagent_containers/food/snacks/wrapped/barcardine = -1,
		/obj/item/reagent_containers/food/snacks/lollipop = -1,
		/obj/item/reagent_containers/food/snacks/wrapped/berrybar = -1,
	)

/obj/machinery/vending/cola
	name = "Souto Softdrinks"
	desc = "A softdrink vendor provided by Souto Soda Company, Havana."
	icon_state = "Cola_Machine"
	product_slogans = "Souto Soda: Have a Souto and be taken away to a tropical paradise!;Souto Classic. You can't beat that tangerine goodness!;Souto Cherry. The sweet flavor of a cool winter morning!;Souto Lime. For that sweet and sour flavor that you know and love!;Souto Grape. There's nothing better than a grape soda.;Nanotrasen Fruit Beer. Nothing came from that lawsuit!;Nanotrasen Spring Water. It came from a spring!"
	icon_deny = "Cola_Machine-deny"
	icon_vend = "Cola_Machine-vend"
	products = list(
		/obj/item/reagent_containers/food/drinks/cans/souto = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/diet = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/cherry = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/lime = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/grape = -1,
		/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet = -1,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = -1,
		/obj/item/reagent_containers/food/drinks/cans/cola = -1,
	)

	prices = list(
		/obj/item/reagent_containers/food/drinks/cans/souto = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/diet = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/cherry = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/lime = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/grape = 5,
		/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet = 5,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 2,
		/obj/item/reagent_containers/food/drinks/cans/cola = 10,
	)
	idle_power_usage = 200

/obj/machinery/vending/medical
	name = "NanotrasenMed Plus"
	desc = "Medical Pharmaceutical dispenser.  Provided by Nanotrasen Pharmaceuticals Division(TM)."
	icon_state = "med"
	icon_deny = "med-deny"
	icon_vend = "med-vend"
	//product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY) //only doctors and researchers can access these
	products = list(
		"Pill Bottle" = list(
			/obj/item/storage/pill_bottle/bicaridine = 15,
			/obj/item/storage/pill_bottle/kelotane = 15,
			/obj/item/storage/pill_bottle/tramadol = 15,
			/obj/item/storage/pill_bottle/tricordrazine = 15,
			/obj/item/storage/pill_bottle/dylovene = 15,
			/obj/item/storage/pill_bottle/inaprovaline = 15,
			/obj/item/storage/pill_bottle/isotonic = 15,
			/obj/item/storage/pill_bottle/paracetamol = 6,
			/obj/item/storage/pill_bottle/dexalin = 6,
			/obj/item/storage/pill_bottle/spaceacillin = 6,
			/obj/item/storage/pill_bottle/alkysine = 6,
			/obj/item/storage/pill_bottle/imidazoline = 6,
			/obj/item/storage/pill_bottle/quickclot = 6,
			/obj/item/storage/pill_bottle/hypervene = 6,
		),
		"Hypospray" = list (
			/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin = 10,
			/obj/item/reagent_containers/hypospray/advanced = 5,
			/obj/item/reagent_containers/hypospray/advanced/bicaridine = 5,
			/obj/item/reagent_containers/hypospray/advanced/kelotane = 5,
			/obj/item/reagent_containers/hypospray/advanced/tramadol = 5,
			/obj/item/reagent_containers/hypospray/advanced/tricordrazine = 5,
			/obj/item/reagent_containers/hypospray/advanced/dylovene = 5,
		),
		"Reagent Bottle" = list(
			/obj/item/reagent_containers/glass/bottle/bicaridine = 6,
			/obj/item/reagent_containers/glass/bottle/kelotane = 6,
			/obj/item/reagent_containers/glass/bottle/tramadol = 6,
			/obj/item/reagent_containers/glass/bottle/tricordrazine = 6,
			/obj/item/reagent_containers/glass/bottle/dylovene = 6,
			/obj/item/reagent_containers/glass/bottle/inaprovaline = 6,
			/obj/item/reagent_containers/glass/bottle/paracetamol = 6,
			/obj/item/reagent_containers/glass/bottle/isotonic = 6,
			/obj/item/reagent_containers/glass/bottle/dexalin = 6,
			/obj/item/reagent_containers/glass/bottle/spaceacillin = 6,
			/obj/item/reagent_containers/glass/bottle/oxycodone = 6,
			/obj/item/reagent_containers/glass/bottle/sleeptoxin = 6,
			/obj/item/reagent_containers/glass/bottle/polyhexanide = 6,
		),
		"Chemistry Equipment" = list(
			/obj/item/reagent_containers/syringe = -1,
			/obj/item/storage/syringe_case/empty = -1,
			/obj/item/reagent_containers/glass/beaker = -1,
			/obj/item/reagent_containers/glass/beaker/large = -1,
			/obj/item/reagent_containers/glass/beaker/vial = -1,
			/obj/item/reagent_containers/dropper = -1,
			/obj/item/storage/reagent_tank = 5,
			/obj/item/storage/reagent_tank/bicaridine = 1,
			/obj/item/storage/reagent_tank/kelotane = 1,
			/obj/item/storage/reagent_tank/tramadol = 1,
			/obj/item/storage/reagent_tank/tricordrazine = 1,
			/obj/item/storage/reagent_tank/bktt = 1,
		),
		"Misc" = list(
			/obj/item/tool/research/xeno_analyzer = -1,
			/obj/item/tool/research/excavation_tool = -1,
			/obj/item/storage/pouch/surgery = -1,
			/obj/item/armor_module/storage/uniform/surgery_webbing = -1,
			/obj/item/reagent_containers/spray/surgery = -1,
			/obj/item/tool/soap = 3,
			/obj/item/clothing/glasses/hud/health = 6,
			/obj/item/roller = 6,
		),
	)
	idle_power_usage = 211

/obj/machinery/vending/medical/shipside
	isshared = TRUE
	wrenchable = FALSE

/obj/machinery/vending/medical/valhalla
	use_power = NO_POWER_USE
	req_access = list()
	resistance_flags = INDESTRUCTIBLE
	products = list(
		"Hypospray" = list (
			/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin = -1,
			/obj/item/reagent_containers/hypospray/advanced = -1,
			/obj/item/reagent_containers/hypospray/advanced/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/advanced/kelotane = -1,
			/obj/item/reagent_containers/hypospray/advanced/tramadol = -1,
			/obj/item/reagent_containers/hypospray/advanced/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/advanced/dylovene = -1,
		),
		"Reagent Bottle" = list(
			/obj/item/reagent_containers/glass/bottle/bicaridine = -1,
			/obj/item/reagent_containers/glass/bottle/kelotane = -1,
			/obj/item/reagent_containers/glass/bottle/tramadol = -1,
			/obj/item/reagent_containers/glass/bottle/tricordrazine = -1,
			/obj/item/reagent_containers/glass/bottle/dylovene = -1,
			/obj/item/reagent_containers/glass/bottle/inaprovaline = -1,
			/obj/item/reagent_containers/glass/bottle/paracetamol = -1,
			/obj/item/reagent_containers/glass/bottle/isotonic = -1,
			/obj/item/reagent_containers/glass/bottle/sleeptoxin = -1,
			/obj/item/reagent_containers/glass/bottle/spaceacillin = -1,
			/obj/item/reagent_containers/glass/bottle/dexalin = -1,
			/obj/item/reagent_containers/glass/bottle/oxycodone = -1,
			/obj/item/reagent_containers/glass/bottle/polyhexanide = -1,
			/obj/item/reagent_containers/glass/bottle/adminordrazine = -1,
			/obj/item/reagent_containers/glass/bottle/lemoline = -1,
			/obj/item/reagent_containers/glass/bottle/nanoblood = -1,
			/obj/item/reagent_containers/glass/bottle/doctor_delight = -1,
		),
		"Pill Bottle" = list(
			/obj/item/storage/pill_bottle/bicaridine = -1,
			/obj/item/storage/pill_bottle/kelotane = -1,
			/obj/item/storage/pill_bottle/tramadol = -1,
			/obj/item/storage/pill_bottle/tricordrazine = -1,
			/obj/item/storage/pill_bottle/dylovene = -1,
			/obj/item/storage/pill_bottle/inaprovaline = -1,
			/obj/item/storage/pill_bottle/isotonic = -1,
			/obj/item/storage/pill_bottle/paracetamol = -1,
			/obj/item/storage/pill_bottle/dexalin = -1,
			/obj/item/storage/pill_bottle/spaceacillin = -1,
			/obj/item/storage/pill_bottle/alkysine = -1,
			/obj/item/storage/pill_bottle/imidazoline = -1,
			/obj/item/storage/pill_bottle/quickclot = -1,
			/obj/item/storage/pill_bottle/hypervene = -1,
			/obj/item/storage/pill_bottle/russian_red = -1,
		),
		"Heal Pack" = list(
			/obj/item/stack/medical/heal_pack/advanced/bruise_pack = -1,
			/obj/item/stack/medical/heal_pack/advanced/burn_pack = -1,
			/obj/item/stack/medical/heal_pack/ointment = -1,
			/obj/item/stack/medical/heal_pack/gauze = -1,
			/obj/item/stack/medical/splint = -1,
		),
		"Misc" = list(
			/obj/item/tool/research/xeno_analyzer = -1,
			/obj/item/tool/research/excavation_tool = -1,
			/obj/item/storage/pouch/surgery = -1,
			/obj/item/armor_module/storage/uniform/surgery_webbing = -1,
			/obj/item/reagent_containers/spray/surgery = -1,
			/obj/item/tool/soap = -1,
			/obj/item/clothing/glasses/hud/health = -1,
			/obj/item/roller = -1,
		),
		"Chemistry Equipment" = list(
			/obj/item/reagent_containers/syringe = -1,
			/obj/item/storage/syringe_case/empty = -1,
			/obj/item/reagent_containers/glass/beaker/bluespace = -1,
			/obj/item/reagent_containers/glass/beaker = -1,
			/obj/item/reagent_containers/glass/beaker/large = -1,
			/obj/item/reagent_containers/glass/beaker/vial = -1,
			/obj/item/reagent_containers/dropper = -1,
			/obj/item/storage/reagent_tank = -1,
			/obj/item/storage/reagent_tank/bicaridine = -1,
			/obj/item/storage/reagent_tank/kelotane = -1,
			/obj/item/storage/reagent_tank/tramadol = -1,
			/obj/item/storage/reagent_tank/tricordrazine = -1,
			/obj/item/storage/reagent_tank/bktt = -1,
		),
		"Valhalla" = list(
			/obj/item/reagent_containers/glass/beaker/bluespace = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/rezadone = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/virilyth = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/roulettium = -1,
			/obj/item/reagent_containers/glass/bottle/toxin = -1,
		),
	)


//This one's from bay12
/obj/machinery/vending/phoronresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	icon_vend = "generic-vend"
	icon_deny = "generic-deny"
	products = list(
		/obj/item/clothing/under/rank/scientist = 6,
		/obj/item/clothing/suit/bio_suit = 6,
		/obj/item/clothing/head/bio_hood = 6,
		/obj/item/transfer_valve = 6,
		/obj/item/assembly/timer = 6,
		/obj/item/assembly/signaler = 6,
		/obj/item/assembly/prox_sensor = 6,
		/obj/item/assembly/igniter = 6,
	)

/obj/machinery/vending/nanomed
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	icon_vend = "wallmed-vend"
	density = FALSE
	wrenchable = FALSE
	products = list(
		/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/kelotane = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/tramadol = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 1,
		/obj/item/stack/medical/heal_pack/gauze = 2,
		/obj/item/stack/medical/heal_pack/ointment = 2,
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/splint = 1,
	)

/obj/machinery/vending/nanomed/Initialize(mapload, ...)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = -14
		if(SOUTH)
			pixel_y = 26
		if(EAST)
			pixel_x = -19
		if(WEST)
			pixel_x = 21

/obj/machinery/vending/nanomed/tadpolemed
	name = "Flight surgeon medical equipment dispenser"
	desc = "Dedicated for the surgeon with wings, this humble box contains a lot for its size."
	products = list(
		"Autoinjectors" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin = 2,
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 1,
			/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 1,
		),
		"Reagent Bottles" = list(
			/obj/item/reagent_containers/syringe = 10,
			/obj/item/reagent_containers/glass/bottle/dylovene = 1,
			/obj/item/reagent_containers/glass/bottle/bicaridine = 1,
			/obj/item/reagent_containers/glass/bottle/inaprovaline = 1,
			/obj/item/reagent_containers/glass/bottle/spaceacillin = 1,
			/obj/item/reagent_containers/glass/bottle/kelotane = 1,
			/obj/item/reagent_containers/glass/bottle/dexalin = 1,
			/obj/item/reagent_containers/glass/bottle/tramadol = 1,
			/obj/item/reagent_containers/glass/bottle/oxycodone = 1,
			/obj/item/reagent_containers/glass/bottle/polyhexanide = 1,
		),
		"Heal Pack" = list(
			/obj/item/stack/medical/heal_pack/gauze = 2,
			/obj/item/stack/medical/heal_pack/ointment = 2,
			/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 5,
			/obj/item/stack/medical/heal_pack/advanced/burn_pack = 5,
			/obj/item/healthanalyzer = 1,
			/obj/item/stack/medical/splint = 1,
		),
	)

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	icon_vend = "sec-vend"
	req_access = list(ACCESS_MARINE_BRIG)
	products = list(
		/obj/item/restraints/handcuffs = 8,
		/obj/item/restraints/handcuffs/zip = 10,
		/obj/item/flash = 5,
		/obj/item/reagent_containers/food/snacks/donut/normal = 12,
		/obj/item/storage/box/evidence = 6,
		/obj/item/clothing/glasses/sunglasses/sechud = 3,
		/obj/item/radio/headset = 6,
		/obj/item/clothing/glasses/sunglasses = 2,
		/obj/item/storage/donut_box = 2,
	)

/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	//product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	//product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	icon_vend = "nutri-vend"
	products = list(
		/obj/item/reagent_containers/glass/fertilizer/ez = 35,
		/obj/item/reagent_containers/glass/fertilizer/l4z = 25,
		/obj/item/reagent_containers/glass/fertilizer/rh = 15,
		/obj/item/tool/plantspray/pests = 20,
		/obj/item/reagent_containers/syringe = 5,
		/obj/item/storage/bag/plants = 5,
		/obj/item/reagent_containers/glass/bottle/ammonia = 10,
		/obj/item/reagent_containers/glass/bottle/diethylamine = 5,
	)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	//product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	//product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	icon_deny = "seeds-deny"
	icon_vend = "seeds-vend"

	products = list(
		/obj/item/seeds/bananaseed = 10,
		/obj/item/seeds/berryseed = 10,
		/obj/item/seeds/carrotseed = 10,
		/obj/item/seeds/chantermycelium = 10,
		/obj/item/seeds/chiliseed = 10,
		/obj/item/seeds/cornseed = 10,
		/obj/item/seeds/eggplantseed = 10,
		/obj/item/seeds/potatoseed = 10,
		/obj/item/seeds/soyaseed = 10,
		/obj/item/seeds/sunflowerseed = 10,
		/obj/item/seeds/tomatoseed = 10,
		/obj/item/seeds/towermycelium = 10,
		/obj/item/seeds/wheatseed = 10,
		/obj/item/seeds/appleseed = 10,
		/obj/item/seeds/poppyseed = 10,
		/obj/item/seeds/sugarcaneseed = 10,
		/obj/item/seeds/ambrosiavulgarisseed = 10,
		/obj/item/seeds/peanutseed = 10,
		/obj/item/seeds/whitebeetseed = 10,
		/obj/item/seeds/watermelonseed = 10,
		/obj/item/seeds/limeseed = 10,
		/obj/item/seeds/lemonseed = 10,
		/obj/item/seeds/orangeseed = 10,
		/obj/item/seeds/grassseed = 10,
		/obj/item/seeds/cocoapodseed = 10,
		/obj/item/seeds/plumpmycelium = 10,
		/obj/item/seeds/cabbageseed = 10,
		/obj/item/seeds/grapeseed = 10,
		/obj/item/seeds/pumpkinseed = 10,
		/obj/item/seeds/cherryseed = 10,
		/obj/item/seeds/plastiseed = 10,
		/obj/item/seeds/riceseed = 10,
		/obj/item/seeds/amanitamycelium = 10,
		/obj/item/seeds/glowshroom = 10,
		/obj/item/seeds/libertymycelium = 10,
		/obj/item/seeds/nettleseed = 10,
		/obj/item/seeds/reishimycelium = 10,
		/obj/item/seeds/reishimycelium = 10,
		/obj/item/toy/waterflower = 10,
	)

/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	//product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(
		/obj/item/clothing/head/wizard = 1,
		/obj/item/clothing/suit/wizrobe = 1,
		/obj/item/clothing/head/wizard/red = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/staff = 2,
	)

/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	icon_vend = "dinnerware-vend"
	icon_deny = "dinnerware-deny"
	products = list(
		/obj/item/tool/kitchen/tray = 8,
		/obj/item/tool/kitchen/utensil/fork = 6,
		/obj/item/tool/kitchen/knife = 3,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 8,
		/obj/item/clothing/suit/chef/classic = 2,
		/obj/item/tool/kitchen/utensil/spoon = 2,
		/obj/item/tool/kitchen/utensil/knife = 2,
		/obj/item/tool/kitchen/rollingpin = 2,
		/obj/item/tool/kitchen/knife/butcher = 2,
		/obj/item/tool/kitchen/knife = -1,
	)

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old sweet water vending machine,how did this end up here?"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(
		/obj/item/reagent_containers/food/drinks/drinkingglass/soda = 30,
		/obj/item/reagent_containers/food/drinks/drinkingglass/cola = 20,
	)
	idle_power_usage = 211

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare engineer vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_vend = "engivend-vend"
	icon_deny = "engivend-deny"
	products = list(
		/obj/item/tool/multitool = -1,
		/obj/item/tool/analyzer = -1,
		/obj/item/t_scanner = -1,
		/obj/item/circuitboard/apc = -1,
		/obj/item/circuitboard/airlock = -1,
		/obj/item/cell/high = 10,
		/obj/item/clothing/head/hardhat = 4,
		/obj/item/clothing/head/welding = 4,
		/obj/item/clothing/glasses/welding = 4,
		/obj/item/radio = -1,
		/obj/item/taperecorder = -1,
		/obj/item/assembly/igniter = -1,
		/obj/item/assembly/signaler = -1,
		/obj/item/assembly/infra = -1,
		/obj/item/assembly/timer = -1,
		/obj/item/assembly/prox_sensor = -1,
		/obj/item/light_bulb/tube = -1,
		/obj/item/light_bulb/bulb = -1,
		/obj/item/ashtray/glass = -1,
		/obj/item/frame/camera = -1,
		/obj/item/reagent_containers/glass/bucket = -1,
	)

/obj/machinery/vending/engivend/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/engivend/nopower/valhalla
	resistance_flags = INDESTRUCTIBLE

//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	icon_vend = "robotics-vend"
	req_access = list(ACCESS_MARINE_RESEARCH)
	products = list(
		/obj/item/clothing/suit/storage/labcoat = 4,
		/obj/item/clothing/under/rank/roboticist = 4,
		/obj/item/stack/cable_coil = 4,
		/obj/item/flash = 4,
		/obj/item/cell/high = 12,
		/obj/item/assembly/prox_sensor = 3,
		/obj/item/assembly/signaler = 3,
		/obj/item/healthanalyzer = 3,
		/obj/item/tool/surgery/scalpel = 2,
		/obj/item/tool/surgery/circular_saw = 2,
		/obj/item/tank/anesthetic = 2,
		/obj/item/clothing/mask/breath/medical = 5,
		/obj/item/tool/screwdriver = 5,
		/obj/item/tool/crowbar = 5,
	)


// All instances of this vendor will share a single inventory for items in the shared list.
// Meaning, if an item is taken from one vendor, it will not be available in any others as well.
/obj/machinery/vending/shared_vending
	isshared = TRUE

/obj/machinery/vending/boozeomat/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/assist/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/coffee/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/snack/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/cola/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/medical/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/nanomed/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/security/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/hydronutrients/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/hydroseeds/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/dinnerware/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/sovietsoda/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/engineering/nopower
	use_power = NO_POWER_USE
