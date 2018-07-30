
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
	contraband = list()
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
	products = list(/obj/item/reagent_container/food/drinks/bottle/gin = 5,/obj/item/reagent_container/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_container/food/drinks/bottle/tequilla = 5,/obj/item/reagent_container/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_container/food/drinks/bottle/vermouth = 5,/obj/item/reagent_container/food/drinks/bottle/rum = 5,
					/obj/item/reagent_container/food/drinks/bottle/wine = 5,/obj/item/reagent_container/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_container/food/drinks/bottle/kahlua = 5,/obj/item/reagent_container/food/drinks/cans/beer = 6,
					/obj/item/reagent_container/food/drinks/cans/ale = 6,/obj/item/reagent_container/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_container/food/drinks/bottle/tomatojuice = 4,/obj/item/reagent_container/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_container/food/drinks/bottle/cream = 4,/obj/item/reagent_container/food/drinks/cans/tonic = 8,
					/obj/item/reagent_container/food/drinks/cans/cola = 8, /obj/item/reagent_container/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_container/food/drinks/flask/barflask = 2, /obj/item/reagent_container/food/drinks/flask/vacuumflask = 2,
					/obj/item/reagent_container/food/drinks/drinkingglass = 30,/obj/item/reagent_container/food/drinks/ice = 9,
					/obj/item/reagent_container/food/drinks/bottle/melonliquor = 2,/obj/item/reagent_container/food/drinks/bottle/bluecuracao = 2,
					/obj/item/reagent_container/food/drinks/bottle/absinthe = 2,/obj/item/reagent_container/food/drinks/bottle/grenadine = 5,
					/obj/item/reagent_container/food/drinks/cans/aspen = 20,/obj/item/reagent_container/food/drinks/bottle/davenport = 3)
	contraband = list(/obj/item/reagent_container/food/drinks/tea = 10)
	vend_delay = 15
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	//product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	//product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"

/obj/machinery/vending/assist
	products = list(	/obj/item/device/assembly/prox_sensor = 5,/obj/item/device/assembly/igniter = 3,/obj/item/device/assembly/signaler = 4,
						/obj/item/tool/wirecutters = 1, /obj/item/cartridge/signal = 4)
	contraband = list(/obj/item/device/flashlight = 5,/obj/item/device/assembly/timer = 2)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	//product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	vend_delay = 34
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.
	vend_power_usage = 85000 //85 kJ to heat a 250 mL cup of coffee
	products = list(/obj/item/reagent_container/food/drinks/coffee = 25,/obj/item/reagent_container/food/drinks/tea = 25,/obj/item/reagent_container/food/drinks/h_chocolate = 25)
	contraband = list(/obj/item/reagent_container/food/drinks/ice = 10)
	prices = list()




/obj/machinery/vending/snack
	name = "Hot Foods Machine"
	desc = "A vending machine full of ready to cook meals, mhmmmm taste the nutritional goodness!"
	product_slogans = "Kepler Crisps! Try a snack that's out of this world!;Eat an EAT!;Eat a Weyland-Yutani brand packaged hamburger.;Eat a Weyland-Yutani brand packaged hot dog.;Eat a Weyland-Yutani brand packaged burrito.;"
	product_ads = "Kepler Crisps! Try a snack that's out of this world!;Eat an EAT!"
	icon_state = "snack"
	products = list(/obj/item/reagent_container/food/snacks/packaged_burger = 12,
					/obj/item/reagent_container/food/snacks/packaged_burrito = 12,
					/obj/item/reagent_container/food/snacks/packaged_hdogs =12,
					/obj/item/reagent_container/food/snacks/kepler_crisps = 12,
					/obj/item/reagent_container/food/snacks/eat_bar = 12,
					/obj/item/reagent_container/food/snacks/wrapped/booniebars = 6,
					/obj/item/reagent_container/food/snacks/wrapped/chunk = 6,
					/obj/item/reagent_container/food/snacks/wrapped/barcardine = 6)

	prices = list()



/obj/machinery/vending/cola
	name = "Souto Softdrinks"
	desc = "A softdrink vendor provided by Souto Soda Company, Havana."
	icon_state = "Cola_Machine"
	product_slogans = "Souto Soda: Have a Souto and be taken away to a tropical paradise!;Souto Classic. You can't beat that tangerine goodness!;Souto Cherry. The sweet flavor of a cool winter morning!;Souto Lime. For that sweet and sour flavor that you know and love!;Souto Grape. There's nothing better than a grape soda.;Weyland-Yutani Fruit Beer. Nothing came from that lawsuit!;Weyland-Yutani Spring Water. It came from a spring!"
	product_ads = "Souto Classic. You can't beat that tangerine goodness!;Souto Cherry. The sweet flavor of a cool winter morning!;Souto Lime. For that sweet and sour flavor that you know and love!;Souto Grape. There's nothing better than a grape soda.;Weyland-Yutani Fruit Beer. Nothing came from that lawsuit!;Weyland-Yutani Spring Water. It came from a spring!"
	products = list(/obj/item/reagent_container/food/drinks/cans/souto = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/diet = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/cherry = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/cherry/diet = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/lime = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/lime/diet = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/grape = 10,
					/obj/item/reagent_container/food/drinks/cans/souto/grape/diet = 10,
					/obj/item/reagent_container/food/drinks/cans/waterbottle = 10,
					/obj/item/reagent_container/food/drinks/cans/cola = 10)

	prices = list(/obj/item/reagent_container/food/drinks/cans/souto = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/diet = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/cherry = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/cherry/diet = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/lime = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/lime/diet = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/grape = 5,
					/obj/item/reagent_container/food/drinks/cans/souto/grape/diet = 5,
					/obj/item/reagent_container/food/drinks/cans/waterbottle = 2,
					/obj/item/reagent_container/food/drinks/cans/cola = 10)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

//This one's from bay12
/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDAs."
	//product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/cartridge/medical = 10,/obj/item/cartridge/engineering = 10,/obj/item/cartridge/security = 10,
					/obj/item/cartridge/janitor = 10,/obj/item/cartridge/signal/science = 10,/obj/item/device/pda/heads = 10,
					/obj/item/cartridge/captain = 3,/obj/item/cartridge/quartermaster = 10)


/obj/machinery/vending/cigarette
	name = "cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "If you want to get cancer, might as well do it in style!"
	product_slogans = "L.S./M.F.T.! Lucky Strikes Means Fine Tobacco.;For a classic style that lights up every time, there's always Zippo!;The FDA would like to remind you that tobacco products cause cancer and increased fatigue.;Real men smoke Lucky Strikes!;Serving the US Armed Forces for over two-hundred years!;Life's short, smoke a Lucky!;L.S./M.F.T.!;Lucky Strike is first again!;You just can't beat a Lucky Strike!;The preferred cigarette of Carlos Hathcock!;First again with tobacco-men!"
	product_ads = "Real men smoke Lucky Strikes!;Serving the US Armed Forces for over two-hundred years!;Life's short, smoke a Lucky!;L.S./M.F.T.!;Lucky Strike is first again!;You just can't beat a Lucky Strike!;The preferred cigarette of Carlos Hathcock!;First again with tobacco-men!"
	vend_delay = 14
	icon_state = "cigs"
	products = list(/obj/item/storage/fancy/cigarettes/lucky_strikes = 50,
					/obj/item/storage/box/matches = 15,
					/obj/item/tool/lighter/random = 25,
					/obj/item/tool/lighter/zippo = 10)

	premium = list(/obj/item/storage/fancy/cigar = 25)
	prices = list(/obj/item/storage/fancy/cigarettes/lucky_strikes = 15,
					/obj/item/storage/box/matches = 1,
					/obj/item/tool/lighter/random = 2,
					/obj/item/tool/lighter/zippo = 20)

/obj/machinery/vending/cigarette/colony
	product_slogans = "Koorlander Gold, for the refined palate.;Lady Fingers, for the dainty smoker.;Lady Fingers, treat your palete with pink!;The big blue K means a cool fresh day!;For the taste that cools your mood, look for the big blue K!;Refined smokers go for Gold!;Lady Fingers are preferred by women who appreciate a cool smoke.;Lady Fingers are the number one cigarette this side of Gateway!;The tobacco connoisseur prefers Koorlander Gold.;For the cool, filtered feel, Lady Finger Cigarettes provide the smoothest draw of any cigarette on the market.;For the man who knows his place is at the top, Koorlander Gold shows the world that you're the best and no-one can say otherwise.;The Colonial Administration Bureau would like to remind you that smoking kills."
	product_ads = "For the taste that cools your mood, look for the big blue K!;Refined smokers go for Gold!;Lady Fingers are preferred by women who appreciate a cool smoke.;Lady Fingers are the number one cigarette this side of Gateway!;The tobacco connoisseur prefers Koorlander Gold.;For the cool, filtered feel, Lady Finger Cigarettes provide the smoothest draw of any cigarette on the market.;For the man who knows his place is at the top, Koorlander Gold shows the world that you're the best and no-one can say otherwise.;The Colonial Administration Bureau would like to remind you that smoking kills."
	products = list(/obj/item/storage/fancy/cigarettes/kpack = 15,
					/obj/item/storage/fancy/cigarettes/lady_finger = 15,
					/obj/item/storage/box/matches = 10,
					/obj/item/tool/lighter/random = 20)
	prices = list(/obj/item/storage/fancy/cigarettes/kpack = 15,
					/obj/item/storage/fancy/cigarettes/lady_finger = 15,
					/obj/item/storage/box/matches = 1,
					/obj/item/tool/lighter/random = 2)

/obj/machinery/vending/medical
	name = "WeylandMed Plus"
	desc = "Medical Pharmaceutical dispenser.  Provided by Weyland-Yutani Pharmaceuticals Division(TM)"
	icon_state = "med"
	icon_deny = "med-deny"
	//product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY) //only doctors and researchers can access these
	products = list(/obj/item/device/healthanalyzer = 5,
					/obj/item/clothing/glasses/hud/health = 2,
					/obj/item/storage/belt/medical = 2,
					/obj/item/device/defibrillator = 2,
					/obj/item/reagent_container/hypospray/autoinjector/quickclot = 5,
					/obj/item/reagent_container/hypospray/autoinjector/dexP = 5,
					/obj/item/reagent_container/hypospray/autoinjector/chloralhydrate =3,
					/obj/item/reagent_container/hypospray/autoinjector/Inaprovaline = 5,
					/obj/item/reagent_container/hypospray/tricordrazine = 2,
					/obj/item/reagent_container/syringe = 20,
					/obj/item/reagent_container/glass/bottle/antitoxin = 4,
					/obj/item/reagent_container/glass/bottle/bicaridine = 4,
					/obj/item/reagent_container/glass/bottle/inaprovaline = 4,
					/obj/item/reagent_container/glass/bottle/stoxin = 2,
					/obj/item/reagent_container/glass/bottle/spaceacillin = 4,
					/obj/item/reagent_container/glass/bottle/peridaxon = 2,
					/obj/item/reagent_container/glass/bottle/kelotane = 4,
					/obj/item/reagent_container/glass/bottle/dexalin = 4,
					/obj/item/reagent_container/glass/bottle/tramadol = 4,
					/obj/item/reagent_container/glass/bottle/oxycodone = 4,
					/obj/item/storage/pill_bottle/peridaxon = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 5,
					/obj/item/stack/medical/advanced/ointment = 5,
					/obj/item/stack/medical/ointment = 10,
					/obj/item/stack/medical/bruise_pack = 10,
					/obj/item/stack/medical/splint = 5
					)

	contraband = list()

	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.


//This one's from bay12
/obj/machinery/vending/phoronresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6,/obj/item/clothing/suit/bio_suit = 6,/obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6,/obj/item/device/assembly/timer = 6,/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6,/obj/item/device/assembly/igniter = 6)

/obj/machinery/vending/wallmed1
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	wrenchable = FALSE
	products = list(/obj/item/reagent_container/hypospray/autoinjector/tricord/skillless = 1,
					/obj/item/reagent_container/hypospray/autoinjector/Tramadol/skillless = 1,
					/obj/item/stack/medical/bruise_pack = 2,
					/obj/item/stack/medical/ointment = 2,
					/obj/item/device/healthanalyzer = 1,
					/obj/item/stack/medical/splint = 1)
	contraband = list(/obj/item/reagent_container/syringe/antitoxin = 2,
						/obj/item/reagent_container/syringe/antiviral = 2)

/obj/machinery/vending/wallmed2
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	wrenchable = FALSE
	products = list(/obj/item/reagent_container/hypospray/autoinjector/tricord/skillless = 1,
					/obj/item/reagent_container/hypospray/autoinjector/Tramadol/skillless = 1,
					/obj/item/reagent_container/syringe/antitoxin = 3,
					/obj/item/stack/medical/bruise_pack = 3,
					/obj/item/stack/medical/ointment =3,
					/obj/item/device/healthanalyzer = 3,
					/obj/item/stack/medical/splint = 1)
	contraband = list(/obj/item/reagent_container/pill/tox = 3)

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "3"
	products = list(/obj/item/handcuffs = 8,
					/obj/item/handcuffs/zip = 10,
					/obj/item/explosive/grenade/flashbang = 4,
					/obj/item/device/flash = 5,
					/obj/item/reagent_container/food/snacks/donut/normal = 12,
					/obj/item/storage/box/evidence = 6,
					/obj/item/clothing/glasses/sunglasses/sechud = 3,
					/obj/item/device/radio/headset = 6)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/donut_box = 2)

/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	//product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	//product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	products = list(/obj/item/reagent_container/glass/fertilizer/ez = 35,/obj/item/reagent_container/glass/fertilizer/l4z = 25,/obj/item/reagent_container/glass/fertilizer/rh = 15,/obj/item/tool/plantspray/pests = 20,
					/obj/item/reagent_container/syringe = 5,/obj/item/storage/bag/plants = 5)
	premium = list(/obj/item/reagent_container/glass/bottle/ammonia = 10,/obj/item/reagent_container/glass/bottle/diethylamine = 5)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	//product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	//product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	delay_product_spawn = 1

	products = list(/obj/item/seeds/bananaseed = 3,/obj/item/seeds/berryseed = 3,/obj/item/seeds/carrotseed = 3,/obj/item/seeds/chantermycelium = 3,/obj/item/seeds/chiliseed = 3,
					/obj/item/seeds/cornseed = 3, /obj/item/seeds/eggplantseed = 3, /obj/item/seeds/potatoseed = 3,/obj/item/seeds/soyaseed = 3,
					/obj/item/seeds/sunflowerseed = 3,/obj/item/seeds/tomatoseed = 3,/obj/item/seeds/towermycelium = 3,/obj/item/seeds/wheatseed = 3,/obj/item/seeds/appleseed = 3,
					/obj/item/seeds/poppyseed = 3,/obj/item/seeds/sugarcaneseed = 3,/obj/item/seeds/ambrosiavulgarisseed = 3,/obj/item/seeds/peanutseed = 3,/obj/item/seeds/whitebeetseed = 3,/obj/item/seeds/watermelonseed = 3,/obj/item/seeds/limeseed = 3,
					/obj/item/seeds/lemonseed = 3,/obj/item/seeds/orangeseed = 3,/obj/item/seeds/grassseed = 3,/obj/item/seeds/cocoapodseed = 3,/obj/item/seeds/plumpmycelium = 2,
					/obj/item/seeds/cabbageseed = 3,/obj/item/seeds/grapeseed = 3,/obj/item/seeds/pumpkinseed = 3,/obj/item/seeds/cherryseed = 3,/obj/item/seeds/plastiseed = 3,/obj/item/seeds/riceseed = 3)
	contraband = list(/obj/item/seeds/amanitamycelium = 2,/obj/item/seeds/glowshroom = 2,/obj/item/seeds/libertymycelium = 2,/obj/item/seeds/mtearseed = 2,
					  /obj/item/seeds/nettleseed = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/shandseed = 2,)
	premium = list(/obj/item/toy/waterflower = 1)


/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	//product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(/obj/item/clothing/head/wizard = 1,/obj/item/clothing/suit/wizrobe = 1,/obj/item/clothing/head/wizard/red = 1,/obj/item/clothing/suit/wizrobe/red = 1,/obj/item/clothing/shoes/sandal = 1,/obj/item/staff = 2)
	contraband = list(/obj/item/reagent_container/glass/bottle/wizarditis = 1)	//No one can get to the machine to hack it anyways; for the lulz - Microwave

/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/tool/kitchen/tray = 8,/obj/item/tool/kitchen/utensil/fork = 6,/obj/item/tool/kitchen/knife = 3,/obj/item/reagent_container/food/drinks/drinkingglass = 8,/obj/item/clothing/suit/chef/classic = 2)
	contraband = list(/obj/item/tool/kitchen/utensil/spoon = 2,/obj/item/tool/kitchen/utensil/knife = 2,/obj/item/tool/kitchen/rollingpin = 2, /obj/item/tool/kitchen/knife/butcher = 2)

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old sweet water vending machine,how did this end up here?"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/reagent_container/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/reagent_container/food/drinks/drinkingglass/cola = 20)
	idle_power_usage = 211 //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/tool/crowbar = 5,/obj/item/tool/weldingtool = 3,/obj/item/tool/wirecutters = 5,
					/obj/item/tool/wrench = 5,/obj/item/device/analyzer = 5,/obj/item/device/t_scanner = 5,/obj/item/tool/screwdriver = 5)
	contraband = list(/obj/item/tool/weldingtool/hugetank = 2,/obj/item/clothing/gloves/fyellow = 2)
	premium = list(/obj/item/clothing/gloves/yellow = 1)

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
	req_access_txt = "7" //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/device/multitool = 4,/obj/item/circuitboard/airlock = 10,/obj/item/circuitboard/apc = 10,/obj/item/circuitboard/airalarm = 10,/obj/item/cell/high = 10)
	contraband = list(/obj/item/cell/potato = 3)
	premium = list(/obj/item/storage/belt/utility = 3)

//This one's from bay12
/obj/machinery/vending/engineering
	name = "Tool Storage Machine"
	desc = "A large storage machine containing various tools and devices for general repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access_txt = "7"
	products = list(/obj/item/clothing/head/hardhat = 4,/obj/item/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/yellow = 4,
					/obj/item/tool/screwdriver = 12,/obj/item/tool/crowbar = 12,/obj/item/tool/wirecutters = 12,/obj/item/device/multitool = 12,/obj/item/tool/wrench = 12,
					/obj/item/device/t_scanner = 12,/obj/item/stack/cable_coil/heavyduty = 8, /obj/item/cell = 8, /obj/item/tool/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/light_bulb/tube = 10, /obj/item/stock_parts/scanning_module = 5,/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,/obj/item/stock_parts/manipulator = 5,/obj/item/stock_parts/console_screen = 5)
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu

//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "14"
	products = list(/obj/item/clothing/suit/storage/labcoat = 4,/obj/item/clothing/under/rank/roboticist = 4,/obj/item/stack/cable_coil = 4,/obj/item/device/flash = 4,
					/obj/item/cell/high = 12, /obj/item/device/assembly/prox_sensor = 3,/obj/item/device/assembly/signaler = 3,/obj/item/device/healthanalyzer = 3,
					/obj/item/tool/surgery/scalpel = 2,/obj/item/tool/surgery/circular_saw = 2,/obj/item/tank/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/tool/screwdriver = 5,/obj/item/tool/crowbar = 5)
	//everything after the power cell had no amounts, I improvised.  -Sayu





// All instances of this vendor will share a single inventory for items in the shared list.
// Meaning, if an item is taken from one vendor, it will not be available in any others as well.
/obj/machinery/vending/shared_vending
	var/list/shared = list()
	var/static/list/shared_products = list()

/obj/machinery/vending/shared_vending/New()
	..()

	build_shared_inventory(shared,0,1)

/obj/machinery/vending/shared_vending/proc/build_shared_inventory(var/list/productlist,hidden=0,req_coin=0)

	if(delay_product_spawn)
		sleep(15) //Make ABSOLUTELY SURE the seed datum is properly populated.

	var/i = 1

	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		var/price = prices[typepath]
		if(isnull(amount)) amount = 1

		var/obj/item/temp_path = typepath
		var/datum/data/vending_product/R = shared_products[i]

		if(!R.product_path)
			R.product_path = typepath
			R.amount = amount
			R.price = price

			if(ispath(typepath,/obj/item/weapon/gun) || ispath(typepath,/obj/item/ammo_magazine) || ispath(typepath,/obj/item/explosive/grenade) || ispath(typepath,/obj/item/weapon/gun/flamer) || ispath(typepath,/obj/item/storage) )
				R.display_color = "black"
//			else if(ispath(typepath,/obj/item/clothing) || ispath(typepath,/obj/item/storage))
//				R.display_color = "green"
//			else if(ispath(typepath,/obj/item/reagent_container) || ispath(typepath,/obj/item/stack/medical))
//				R.display_color = "blue"
			else
				R.display_color = "white"

		if(hidden)
			R.category=CAT_HIDDEN
			hidden_records += R
		else if(req_coin)
			R.category=CAT_COIN
			coin_records += R
		else
			R.category=CAT_NORMAL
			product_records += R

		if(delay_product_spawn)
			sleep(5) //sleep(1) did not seem to cut it, so here we are.

		R.product_name = initial(temp_path.name)

		i++;

//		world << "Added: [R.product_name]] - [R.amount] - [R.product_path]"
	return
