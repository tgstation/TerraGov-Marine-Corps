//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)


/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)


/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	results = list(/datum/reagent/consumable/drink/hot_coco = 5)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/coco = 1)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	results = list(/datum/reagent/consumable/capsaicin/condensed = 1)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 2)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	results = list(/datum/reagent/consumable/sodiumchloride = 2)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	new /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel(location)


/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	results = null
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/clonexadone = 1)

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.get_holder())
	new /obj/item/reagent_containers/food/snacks/meat/syntiflesh(location)


/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)


////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	results = list(/datum/reagent/consumable/ethanol/goldschlager = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/gold = 1)

/datum/chemical_reaction/patron
	name = "Patron"
	results = list(/datum/reagent/consumable/ethanol/patron = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 10, /datum/reagent/silver = 1)

/datum/chemical_reaction/bilk
	name = "Bilk"
	results = list(/datum/reagent/consumable/ethanol/bilk = 2)
	required_reagents = list(/datum/reagent/consumable/drink/milk = 1, /datum/reagent/consumable/ethanol/beer = 1)

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	results = list(/datum/reagent/consumable/drink/tea/icetea = 4)
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/tea = 3)

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	results = list(/datum/reagent/consumable/drink/coffee/icecoffee = 4)
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/coffee = 3)

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	results = list(/datum/reagent/consumable/drink/cold/nuka_cola = 6)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/consumable/drink/cold/space_cola = 6)

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	results = list(/datum/reagent/consumable/ethanol/moonshine = 15)
	required_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/grenadine
	name = "Grenadine Syrup"
	results = list(/datum/reagent/consumable/drink/grenadine = 10)
	required_reagents = list(/datum/reagent/consumable/drink/berryjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/wine
	name = "Wine"
	results = list(/datum/reagent/consumable/ethanol/wine = 10)
	required_reagents = list(/datum/reagent/consumable/drink/grapejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/pwine
	name = "Poison Wine"
	results = list(/datum/reagent/consumable/ethanol/pwine = 10)
	required_reagents = list(/datum/reagent/consumable/drink/poisonberryjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/melonliquor
	name = "Melon Liquor"
	results = list(/datum/reagent/consumable/ethanol/melonliquor = 10)
	required_reagents = list(/datum/reagent/consumable/drink/watermelonjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/bluecuracao
	name = "Blue Curacao"
	results = list(/datum/reagent/consumable/ethanol/bluecuracao = 10)
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	results = list(/datum/reagent/consumable/ethanol/beer = 10)
	required_reagents = list(/datum/reagent/consumable/cornoil = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/vodka
	name = "Vodka"
	results = list(/datum/reagent/consumable/ethanol/vodka = 10)
	required_reagents = list(/datum/reagent/consumable/nutriment = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/sake
	name = "Sake"
	results = list(/datum/reagent/consumable/ethanol/sake = 10)
	required_reagents = list(/datum/reagent/consumable/rice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	results = list(/datum/reagent/consumable/ethanol/kahlua = 10)
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	results = list(/datum/reagent/consumable/ethanol/gintonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/drink/cold/tonic = 1)

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	results = list(/datum/reagent/consumable/ethanol/cuba_libre = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)

/datum/chemical_reaction/martini
	name = "Classic Martini"
	results = list(/datum/reagent/consumable/ethanol/martini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	results = list(/datum/reagent/consumable/ethanol/vodkamartini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/white_russian
	name = "White Russian"
	results = list(/datum/reagent/consumable/ethanol/white_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 3, /datum/reagent/consumable/drink/milk/cream = 2)

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	results = list(/datum/reagent/consumable/ethanol/whiskey_cola = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	results = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/orangejuice = 1)

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	results = list(/datum/reagent/consumable/ethanol/bloody_mary = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	results = list(/datum/reagent/consumable/drink/gargle_blaster = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	results = list(/datum/reagent/consumable/ethanol/brave_bull = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/ethanol/kahlua = 1)

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	results = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/drink/orangejuice = 1)

/datum/chemical_reaction/phoron_special
	name = "Toxins Special"
	results = list(/datum/reagent/consumable/ethanol/toxins_special = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/toxin/phoron = 2)

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	results = list(/datum/reagent/consumable/ethanol/beepsky_smash = 4)
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 2, /datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/iron = 1)

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	results = list(/datum/reagent/consumable/drink/doctor_delight = 5)
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/tomatojuice = 1, /datum/reagent/consumable/drink/orangejuice = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/medicine/tricordrazine = 1)

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	results = list(/datum/reagent/consumable/ethanol/irish_cream = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/milk/cream = 1)

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	results = list(/datum/reagent/consumable/ethanol/manly_dorf = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/ale = 2)

/datum/chemical_reaction/hooch
	name = "Hooch"
	results = list(/datum/reagent/consumable/ethanol/hooch = 3)
	required_reagents = list (/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ethanol = 2, /datum/reagent/fuel = 1)

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	results = list(/datum/reagent/consumable/ethanol/irishcoffee = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/drink/coffee = 1)

/datum/chemical_reaction/b52
	name = "B-52"
	results = list(/datum/reagent/consumable/ethanol/b52 = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/cognac = 1)

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	results = list(/datum/reagent/consumable/drink/atomicbomb = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/b52 = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/margarita
	name = "Margarita"
	results = list(/datum/reagent/consumable/ethanol/margarita = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	results = list(/datum/reagent/consumable/ethanol/longislandicedtea = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/cuba_libre = 1)

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	results = list(/datum/reagent/consumable/ethanol/threemileisland = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	results = list(/datum/reagent/consumable/ethanol/whiskeysoda = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/cold/sodawater = 1)

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	results = list(/datum/reagent/consumable/ethanol/black_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 3, /datum/reagent/consumable/ethanol/kahlua = 2)

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	results = list(/datum/reagent/consumable/ethanol/manhattan = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	results = list(/datum/reagent/consumable/ethanol/manhattan_proj = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	results = list(/datum/reagent/consumable/ethanol/vodkatonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/cold/tonic = 1)

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	results = list(/datum/reagent/consumable/ethanol/ginfizz = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/drink/cold/sodawater = 1, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	results = list(/datum/reagent/consumable/ethanol/bahama_mama = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/orangejuice = 2, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/ice = 1)

/datum/chemical_reaction/singulo
	name = "Singulo"
	results = list(/datum/reagent/consumable/ethanol/singulo = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/radium = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	results = list(/datum/reagent/consumable/ethanol/alliescocktail = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	results = list(/datum/reagent/consumable/ethanol/demonsblood = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/drink/cold/spacemountainwind = 1, /datum/reagent/blood = 1, /datum/reagent/consumable/drink/cold/dr_gibb = 1)

/datum/chemical_reaction/booger
	name = "Booger"
	results = list(/datum/reagent/consumable/ethanol/booger = 4)
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/drink/watermelonjuice = 1)

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	results = list(/datum/reagent/consumable/ethanol/antifreeze = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/cold/ice = 1)

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	results = list(/datum/reagent/consumable/ethanol/barefoot = 3)
	required_reagents = list(/datum/reagent/consumable/drink/berryjuice = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/grapesoda
	name = "Grape Soda"
	results = list(/datum/reagent/consumable/drink/grapesoda = 3)
	required_reagents = list(/datum/reagent/consumable/drink/grapejuice = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)



////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	results = list(/datum/reagent/consumable/ethanol/sbiten = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/consumable/capsaicin = 1)

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	results = list(/datum/reagent/consumable/ethanol/red_mead = 2)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/mead = 1)

/datum/chemical_reaction/mead
	name = "Mead"
	results = list(/datum/reagent/consumable/ethanol/mead = 2)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/consumable/frostoil = 1)

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 5, /datum/reagent/consumable/drink/cold/ice = 1)

/datum/chemical_reaction/grog
	name = "Grog"
	results = list(/datum/reagent/consumable/ethanol/grog = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	results = list(/datum/reagent/consumable/drink/coffee/soy_latte = 2)
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 1, /datum/reagent/consumable/drink/milk/soymilk = 1)

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	results = list(/datum/reagent/consumable/drink/coffee/cafe_latte = 2)
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 1, /datum/reagent/consumable/drink/milk = 1)

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	results = list(/datum/reagent/consumable/ethanol/acid_spit = 6)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/amasec
	name = "Amasec"
	results = list(/datum/reagent/consumable/ethanol/amasec = 10)
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/vodka = 5)

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	results = list(/datum/reagent/consumable/ethanol/changelingsting = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/lemonjuice = 1)

/datum/chemical_reaction/aloe
	name = "Aloe"
	results = list(/datum/reagent/consumable/ethanol/aloe = 2)
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/watermelonjuice = 1)

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	results = list(/datum/reagent/consumable/ethanol/andalusia = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/lemonjuice = 1)

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	results = list(/datum/reagent/consumable/drink/neurotoxin = 2)
	required_reagents = list(/datum/reagent/consumable/drink/gargle_blaster = 1, /datum/reagent/toxin/sleeptoxin = 1)

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	results = list(/datum/reagent/consumable/ethanol/snowwhite = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/drink/cold/lemon_lime = 1)

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	results = list(/datum/reagent/consumable/ethanol/irishcarbomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/ethanol/irish_cream = 1)

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	results = list(/datum/reagent/consumable/ethanol/syndicatebomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/whiskey_cola = 1)

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	results = list(/datum/reagent/consumable/ethanol/erikasurprise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/drink/cold/ice = 1)


/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	results = list(/datum/reagent/consumable/ethanol/devilskiss = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 1)

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	results = list(/datum/reagent/consumable/drink/hippies_delight = 2)
	required_reagents = list(/datum/reagent/consumable/psilocybin = 1, /datum/reagent/consumable/drink/gargle_blaster = 1)

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	results = list(/datum/reagent/consumable/ethanol/bananahonk = 3)
	required_reagents = list(/datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/silencer
	name = "Silencer"
	results = list(/datum/reagent/consumable/ethanol/silencer = 3)
	required_reagents = list(/datum/reagent/consumable/drink/nothing = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	results = list(/datum/reagent/consumable/ethanol/driestmartini = 2)
	required_reagents = list(/datum/reagent/consumable/drink/nothing = 1, /datum/reagent/consumable/ethanol/gin = 1)

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	results = list(/datum/reagent/consumable/drink/cold/lemonade = 3)
	required_reagents = list(/datum/reagent/consumable/drink/lemonjuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	results = list(/datum/reagent/consumable/drink/cold/kiraspecial = 2)
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/sodawater = 1)

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	results = list(/datum/reagent/consumable/drink/cold/brownstar = 2)
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	results = list(/datum/reagent/consumable/drink/cold/milkshake = 5)
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/cold/ice = 2, /datum/reagent/consumable/drink/milk = 2)

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	results = list(/datum/reagent/consumable/drink/cold/rewriter = 2)
	required_reagents = list(/datum/reagent/consumable/drink/cold/spacemountainwind = 1, /datum/reagent/consumable/drink/coffee = 1)

/datum/chemical_reaction/suidream
	name = "Sui Dream"
	results = list(/datum/reagent/consumable/ethanol/suidream = 4)
	required_reagents = list(/datum/reagent/consumable/drink/cold/space_up = 2, /datum/reagent/consumable/ethanol/bluecuracao = 1, /datum/reagent/consumable/ethanol/melonliquor = 1)
