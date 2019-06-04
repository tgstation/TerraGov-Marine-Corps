

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/reagent_container/food/snacks/tofu(location)


/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/reagent_container/food/snacks/chocolatebar(location)


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/reagent_container/food/snacks/chocolatebar(location)


/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = /datum/reagent/consumable/drink/hot_coco
	results = list(/datum/reagent/consumable/drink/hot_coco = 5)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/coco = 1)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = /datum/reagent/consumable/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = /datum/reagent/consumable/capsaicin/condensed
	results = list(/datum/reagent/consumable/capsaicin/condensed = 1)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 2)
	required_catalysts = list(/datum/reagent/toxin/phoron = 5)

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = /datum/reagent/consumable/sodiumchloride
	results = list(/datum/reagent/consumable/sodiumchloride = 2)
	required_reagents = list(/datum/reagent/sodium = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	results = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/reagent_container/food/snacks/sliceable/cheesewheel(location)


/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	results = null
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/clonexadone = 1)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/reagent_container/food/snacks/meat/syntiflesh(location)


/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = /datum/reagent/consumable/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = /datum/reagent/consumable/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)


////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = /datum/reagent/consumable/ethanol/goldschlager
	results = list(/datum/reagent/consumable/ethanol/goldschlager = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/gold = 1)

/datum/chemical_reaction/patron
	name = "Patron"
	id = /datum/reagent/consumable/ethanol/patron
	results = list(/datum/reagent/consumable/ethanol/patron = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 10, /datum/reagent/silver = 1)

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = /datum/reagent/consumable/ethanol/bilk
	results = list(/datum/reagent/consumable/ethanol/bilk = 2)
	required_reagents = list(/datum/reagent/consumable/drink/milk = 1, /datum/reagent/consumable/ethanol/beer = 1)

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = /datum/reagent/consumable/drink/tea/icetea
	results = list(/datum/reagent/consumable/drink/tea/icetea = 4)
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/tea = 3)

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = /datum/reagent/consumable/drink/coffee/icecoffee
	results = list(/datum/reagent/consumable/drink/coffee/icecoffee = 4)
	required_reagents = list(/datum/reagent/consumable/drink/cold/ice = 1, /datum/reagent/consumable/drink/coffee = 3)

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = /datum/reagent/consumable/drink/cold/nuka_cola
	results = list(/datum/reagent/consumable/drink/cold/nuka_cola = 6)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/consumable/drink/cold/space_cola = 6)

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = /datum/reagent/consumable/ethanol/moonshine
	results = list(/datum/reagent/consumable/ethanol/moonshine = 10)
	required_reagents = list(/datum/reagent/consumable/nutriment = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/grenadine
	name = "Grenadine Syrup"
	id = /datum/reagent/consumable/drink/grenadine
	results = list(/datum/reagent/consumable/drink/grenadine = 10)
	required_reagents = list(/datum/reagent/consumable/drink/berryjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/wine
	name = "Wine"
	id = /datum/reagent/consumable/ethanol/wine
	results = list(/datum/reagent/consumable/ethanol/wine = 10)
	required_reagents = list(/datum/reagent/consumable/drink/grapejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/pwine
	name = "Poison Wine"
	id = /datum/reagent/consumable/ethanol/pwine
	results = list(/datum/reagent/consumable/ethanol/pwine = 10)
	required_reagents = list(/datum/reagent/consumable/drink/poisonberryjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/melonliquor
	name = "Melon Liquor"
	id = /datum/reagent/consumable/ethanol/melonliquor
	results = list(/datum/reagent/consumable/ethanol/melonliquor = 10)
	required_reagents = list(/datum/reagent/consumable/drink/watermelonjuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/bluecuracao
	name = "Blue Curacao"
	id = /datum/reagent/consumable/ethanol/bluecuracao
	results = list(/datum/reagent/consumable/ethanol/bluecuracao = 10)
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = /datum/reagent/consumable/ethanol/beer
	results = list(/datum/reagent/consumable/ethanol/beer = 10)
	required_reagents = list(/datum/reagent/consumable/cornoil = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = /datum/reagent/consumable/ethanol/vodka
	results = list(/datum/reagent/consumable/ethanol/vodka = 10)
	required_reagents = list(/datum/reagent/consumable/drink/potato_juice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/sake
	name = "Sake"
	id = /datum/reagent/consumable/ethanol/sake
	results = list(/datum/reagent/consumable/ethanol/sake = 10)
	required_reagents = list(/datum/reagent/consumable/rice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = /datum/reagent/consumable/ethanol/kahlua
	results = list(/datum/reagent/consumable/ethanol/kahlua = 10)
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = /datum/reagent/consumable/ethanol/gintonic
	results = list(/datum/reagent/consumable/ethanol/gintonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/drink/cold/tonic = 1)

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = /datum/reagent/consumable/ethanol/cuba_libre
	results = list(/datum/reagent/consumable/ethanol/cuba_libre = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = /datum/reagent/consumable/ethanol/martini
	results = list(/datum/reagent/consumable/ethanol/martini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = /datum/reagent/consumable/ethanol/vodkamartini
	results = list(/datum/reagent/consumable/ethanol/vodkamartini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = /datum/reagent/consumable/ethanol/white_russian
	results = list(/datum/reagent/consumable/ethanol/white_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 3, /datum/reagent/consumable/drink/milk/cream = 2)

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = /datum/reagent/consumable/ethanol/whiskey_cola
	results = list(/datum/reagent/consumable/ethanol/whiskey_cola = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = /datum/reagent/consumable/ethanol/screwdrivercocktail
	results = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/orangejuice = 1)

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = /datum/reagent/consumable/ethanol/bloody_mary
	results = list(/datum/reagent/consumable/ethanol/bloody_mary = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = /datum/reagent/consumable/drink/gargle_blaster
	results = list(/datum/reagent/consumable/drink/gargle_blaster = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = /datum/reagent/consumable/ethanol/brave_bull
	results = list(/datum/reagent/consumable/ethanol/brave_bull = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/ethanol/kahlua = 1)

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	id = /datum/reagent/consumable/ethanol/tequila_sunrise
	results = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/drink/orangejuice = 1)

/datum/chemical_reaction/phoron_special
	name = "Toxins Special"
	id = /datum/reagent/consumable/ethanol/toxins_special
	results = list(/datum/reagent/consumable/ethanol/toxins_special = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/toxin/phoron = 2)

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = /datum/reagent/consumable/ethanol/beepsky_smash
	results = list(/datum/reagent/consumable/ethanol/beepsky_smash = 4)
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 2, /datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/iron = 1)

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = /datum/reagent/consumable/drink/doctor_delight
	results = list(/datum/reagent/consumable/drink/doctor_delight = 5)
	required_reagents = list(/datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/tomatojuice = 1, /datum/reagent/consumable/drink/orangejuice = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/medicine/tricordrazine = 1)

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = /datum/reagent/consumable/ethanol/irish_cream
	results = list(/datum/reagent/consumable/ethanol/irish_cream = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/milk/cream = 1)

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = /datum/reagent/consumable/ethanol/manly_dorf
	results = list(/datum/reagent/consumable/ethanol/manly_dorf = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/ale = 2)

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = /datum/reagent/consumable/ethanol/hooch
	results = list(/datum/reagent/consumable/ethanol/hooch = 3)
	required_reagents = list (/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ethanol = 2, /datum/reagent/fuel = 1)

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = /datum/reagent/consumable/ethanol/irishcoffee
	results = list(/datum/reagent/consumable/ethanol/irishcoffee = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/drink/coffee = 1)

/datum/chemical_reaction/b52
	name = "B-52"
	id = /datum/reagent/consumable/ethanol/b52
	results = list(/datum/reagent/consumable/ethanol/b52 = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/cognac = 1)

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = /datum/reagent/consumable/drink/atomicbomb
	results = list(/datum/reagent/consumable/drink/atomicbomb = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/b52 = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = /datum/reagent/consumable/ethanol/margarita
	results = list(/datum/reagent/consumable/ethanol/margarita = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = /datum/reagent/consumable/ethanol/longislandicedtea
	results = list(/datum/reagent/consumable/ethanol/longislandicedtea = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/cuba_libre = 1)

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = /datum/reagent/consumable/ethanol/threemileisland
	results = list(/datum/reagent/consumable/ethanol/threemileisland = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = /datum/reagent/consumable/ethanol/whiskeysoda
	results = list(/datum/reagent/consumable/ethanol/whiskeysoda = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/drink/cold/sodawater = 1)

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = /datum/reagent/consumable/ethanol/black_russian
	results = list(/datum/reagent/consumable/ethanol/black_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 3, /datum/reagent/consumable/ethanol/kahlua = 2)

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = /datum/reagent/consumable/ethanol/manhattan
	results = list(/datum/reagent/consumable/ethanol/manhattan = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = /datum/reagent/consumable/ethanol/manhattan_proj
	results = list(/datum/reagent/consumable/ethanol/manhattan_proj = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = /datum/reagent/consumable/ethanol/vodkatonic
	results = list(/datum/reagent/consumable/ethanol/vodkatonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/cold/tonic = 1)

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = /datum/reagent/consumable/ethanol/ginfizz
	results = list(/datum/reagent/consumable/ethanol/ginfizz = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/drink/cold/sodawater = 1, /datum/reagent/consumable/drink/limejuice = 1)

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = /datum/reagent/consumable/ethanol/bahama_mama
	results = list(/datum/reagent/consumable/ethanol/bahama_mama = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/drink/orangejuice = 2, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/ice = 1)

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = /datum/reagent/consumable/ethanol/singulo
	results = list(/datum/reagent/consumable/ethanol/singulo = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/radium = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = /datum/reagent/consumable/ethanol/alliescocktail
	results = list(/datum/reagent/consumable/ethanol/alliescocktail = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = /datum/reagent/consumable/ethanol/demonsblood
	results = list(/datum/reagent/consumable/ethanol/demonsblood = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/drink/cold/spacemountainwind = 1, /datum/reagent/blood = 1, /datum/reagent/consumable/drink/cold/dr_gibb = 1)

/datum/chemical_reaction/booger
	name = "Booger"
	id = /datum/reagent/consumable/ethanol/booger
	results = list(/datum/reagent/consumable/ethanol/booger = 4)
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/drink/watermelonjuice = 1)

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = /datum/reagent/consumable/ethanol/antifreeze
	results = list(/datum/reagent/consumable/ethanol/antifreeze = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/cold/ice = 1)

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = /datum/reagent/consumable/ethanol/barefoot
	results = list(/datum/reagent/consumable/ethanol/barefoot = 3)
	required_reagents = list(/datum/reagent/consumable/drink/berryjuice = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/grapesoda
	name = "Grape Soda"
	id = /datum/reagent/consumable/drink/grapesoda
	results = list(/datum/reagent/consumable/drink/grapesoda = 3)
	required_reagents = list(/datum/reagent/consumable/drink/grapejuice = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)



////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = /datum/reagent/consumable/ethanol/sbiten
	results = list(/datum/reagent/consumable/ethanol/sbiten = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/consumable/capsaicin = 1)

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = /datum/reagent/consumable/ethanol/red_mead
	results = list(/datum/reagent/consumable/ethanol/red_mead = 2)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/mead = 1)

/datum/chemical_reaction/mead
	name = "Mead"
	id = /datum/reagent/consumable/ethanol/mead
	results = list(/datum/reagent/consumable/ethanol/mead = 2)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = /datum/reagent/consumable/ethanol/iced_beer
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/consumable/frostoil = 1)

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = "iced_beer2"
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 5, /datum/reagent/consumable/drink/cold/ice = 1)

/datum/chemical_reaction/grog
	name = "Grog"
	id = /datum/reagent/consumable/ethanol/grog
	results = list(/datum/reagent/consumable/ethanol/grog = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = /datum/reagent/consumable/drink/coffee/soy_latte
	results = list(/datum/reagent/consumable/drink/coffee/soy_latte = 2)
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 1, /datum/reagent/consumable/drink/milk/soymilk = 1)

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = /datum/reagent/consumable/drink/coffee/cafe_latte
	results = list(/datum/reagent/consumable/drink/coffee/cafe_latte = 2)
	required_reagents = list(/datum/reagent/consumable/drink/coffee = 1, /datum/reagent/consumable/drink/milk = 1)

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = /datum/reagent/consumable/ethanol/acid_spit
	results = list(/datum/reagent/consumable/ethanol/acid_spit = 6)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = /datum/reagent/consumable/ethanol/amasec
	results = list(/datum/reagent/consumable/ethanol/amasec = 10)
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/vodka = 5)

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = /datum/reagent/consumable/ethanol/changelingsting
	results = list(/datum/reagent/consumable/ethanol/changelingsting = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/lemonjuice = 1)

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = /datum/reagent/consumable/ethanol/aloe
	results = list(/datum/reagent/consumable/ethanol/aloe = 2)
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/watermelonjuice = 1)

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = /datum/reagent/consumable/ethanol/andalusia
	results = list(/datum/reagent/consumable/ethanol/andalusia = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/lemonjuice = 1)

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = /datum/reagent/consumable/drink/neurotoxin
	results = list(/datum/reagent/consumable/drink/neurotoxin = 2)
	required_reagents = list(/datum/reagent/consumable/drink/gargle_blaster = 1, /datum/reagent/toxin/sleeptoxin = 1)

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = /datum/reagent/consumable/ethanol/snowwhite
	results = list(/datum/reagent/consumable/ethanol/snowwhite = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/drink/cold/lemon_lime = 1)

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = /datum/reagent/consumable/ethanol/irishcarbomb
	results = list(/datum/reagent/consumable/ethanol/irishcarbomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/ethanol/irish_cream = 1)

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = /datum/reagent/consumable/ethanol/syndicatebomb
	results = list(/datum/reagent/consumable/ethanol/syndicatebomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/whiskey_cola = 1)

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = /datum/reagent/consumable/ethanol/erikasurprise
	results = list(/datum/reagent/consumable/ethanol/erikasurprise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/drink/cold/ice = 1)


/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = /datum/reagent/consumable/ethanol/devilskiss
	results = list(/datum/reagent/consumable/ethanol/devilskiss = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 1)

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = /datum/reagent/consumable/drink/hippies_delight
	results = list(/datum/reagent/consumable/drink/hippies_delight = 2)
	required_reagents = list(/datum/reagent/consumable/psilocybin = 1, /datum/reagent/consumable/drink/gargle_blaster = 1)

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = /datum/reagent/consumable/ethanol/bananahonk
	results = list(/datum/reagent/consumable/ethanol/bananahonk = 3)
	required_reagents = list(/datum/reagent/consumable/drink/banana = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = /datum/reagent/consumable/ethanol/silencer
	results = list(/datum/reagent/consumable/ethanol/silencer = 3)
	required_reagents = list(/datum/reagent/consumable/drink/nothing = 1, /datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = /datum/reagent/consumable/ethanol/driestmartini
	results = list(/datum/reagent/consumable/ethanol/driestmartini = 2)
	required_reagents = list(/datum/reagent/consumable/drink/nothing = 1, /datum/reagent/consumable/ethanol/gin = 1)

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = /datum/reagent/consumable/drink/cold/lemonade
	results = list(/datum/reagent/consumable/drink/cold/lemonade = 3)
	required_reagents = list(/datum/reagent/consumable/drink/lemonjuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = /datum/reagent/consumable/drink/cold/kiraspecial
	results = list(/datum/reagent/consumable/drink/cold/kiraspecial = 2)
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 1, /datum/reagent/consumable/drink/limejuice = 1, /datum/reagent/consumable/drink/cold/sodawater = 1)

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = /datum/reagent/consumable/drink/cold/brownstar
	results = list(/datum/reagent/consumable/drink/cold/brownstar = 2)
	required_reagents = list(/datum/reagent/consumable/drink/orangejuice = 2, /datum/reagent/consumable/drink/cold/space_cola = 1)

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = /datum/reagent/consumable/drink/cold/milkshake
	results = list(/datum/reagent/consumable/drink/cold/milkshake = 5)
	required_reagents = list(/datum/reagent/consumable/drink/milk/cream = 1, /datum/reagent/consumable/drink/cold/ice = 2, /datum/reagent/consumable/drink/milk = 2)

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = /datum/reagent/consumable/drink/cold/rewriter
	results = list(/datum/reagent/consumable/drink/cold/rewriter = 2)
	required_reagents = list(/datum/reagent/consumable/drink/cold/spacemountainwind = 1, /datum/reagent/consumable/drink/coffee = 1)

/datum/chemical_reaction/suidream
	name = "Sui Dream"
	id = /datum/reagent/consumable/ethanol/suidream
	results = list(/datum/reagent/consumable/ethanol/suidream = 4)
	required_reagents = list(/datum/reagent/consumable/drink/cold/space_up = 2, /datum/reagent/consumable/ethanol/bluecuracao = 1, /datum/reagent/consumable/ethanol/melonliquor = 1)
