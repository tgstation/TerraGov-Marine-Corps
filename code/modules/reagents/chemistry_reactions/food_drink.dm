

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	results = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/reagent_container/food/snacks/tofu(location)


/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	results = null
	required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/reagent_container/food/snacks/chocolatebar(location)


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	results = null
	required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/reagent_container/food/snacks/chocolatebar(location)


/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	results = list("hot_coco" = 5)
	required_reagents = list("water" = 5, "coco" = 1)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	results = list("soysauce" = 5)
	required_reagents = list("soymilk" = 4, "sacid" = 1)

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	results = list("condensedcapsaicin" = 1)
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("phoron" = 5)

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	results = list("sodiumchloride" = 2)
	required_reagents = list("sodium" = 1, "chlorine" = 1)

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	results = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/reagent_container/food/snacks/sliceable/cheesewheel(location)


/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	results = null
	required_reagents = list("blood" = 5, "clonexadone" = 1)

	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/reagent_container/food/snacks/meat/syntiflesh(location)


/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	results = list("hot_ramen" = 3)
	required_reagents = list("water" = 1, "dry_ramen" = 3)

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	results = list("hell_ramen" = 6)
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)


////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	results = list("goldschlager" = 10)
	required_reagents = list("vodka" = 10, "gold" = 1)

/datum/chemical_reaction/patron
	name = "Patron"
	id = "patron"
	results = list("patron" = 10)
	required_reagents = list("tequilla" = 10, "silver" = 1)

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = "bilk"
	results = list("bilk" = 2)
	required_reagents = list("milk" = 1, "beer" = 1)

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = "icetea"
	results = list("icetea" = 4)
	required_reagents = list("ice" = 1, "tea" = 3)

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	results = list("icecoffee" = 4)
	required_reagents = list("ice" = 1, "coffee" = 3)

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	results = list("nuka_cola" = 6)
	required_reagents = list("uranium" = 1, "cola" = 6)

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = "moonshine"
	results = list("moonshine" = 10)
	required_reagents = list("nutriment" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/grenadine
	name = "Grenadine Syrup"
	id = "grenadine"
	results = list("grenadine" = 10)
	required_reagents = list("berryjuice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/wine
	name = "Wine"
	id = "wine"
	results = list("wine" = 10)
	required_reagents = list("grapejuice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/pwine
	name = "Poison Wine"
	id = "pwine"
	results = list("pwine" = 10)
	required_reagents = list("poisonberryjuice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/melonliquor
	name = "Melon Liquor"
	id = "melonliquor"
	results = list("melonliquor" = 10)
	required_reagents = list("watermelonjuice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	results = list("bluecuracao" = 10)
	required_reagents = list("orangejuice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	results = list("beer" = 10)
	required_reagents = list("cornoil" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = "vodka"
	results = list("vodka" = 10)
	required_reagents = list("potato" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/sake
	name = "Sake"
	id = "sake"
	results = list("sake" = 10)
	required_reagents = list("rice" = 10)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = "kahlua"
	results = list("kahlua" = 10)
	required_reagents = list("coffee" = 5, "sugar" = 5)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = "gintonic"
	results = list("gintonic" = 3)
	required_reagents = list("gin" = 2, "tonic" = 1)

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	results = list("cubalibre" = 3)
	required_reagents = list("rum" = 2, "cola" = 1)

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = "martini"
	results = list("martini" = 3)
	required_reagents = list("gin" = 2, "vermouth" = 1)

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	results = list("vodkamartini" = 3)
	required_reagents = list("vodka" = 2, "vermouth" = 1)

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = "whiterussian"
	results = list("whiterussian" = 5)
	required_reagents = list("blackrussian" = 3, "cream" = 2)

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	results = list("whiskeycola" = 3)
	required_reagents = list("whiskey" = 2, "cola" = 1)

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = "screwdrivercocktail"
	results = list("screwdrivercocktail" = 3)
	required_reagents = list("vodka" = 2, "orangejuice" = 1)

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	results = list("bloodymary" = 4)
	required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	results = list("gargleblaster" = 5)
	required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "limejuice" = 1)

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	results = list("bravebull" = 3)
	required_reagents = list("tequilla" = 2, "kahlua" = 1)

/datum/chemical_reaction/tequilla_sunrise
	name = "Tequilla Sunrise"
	id = "tequillasunrise"
	results = list("tequillasunrise" = 3)
	required_reagents = list("tequilla" = 2, "orangejuice" = 1)

/datum/chemical_reaction/phoron_special
	name = "Toxins Special"
	id = "phoronspecial"
	results = list("phoronspecial" = 5)
	required_reagents = list("rum" = 2, "vermouth" = 1, "phoron" = 2)

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	results = list("beepskysmash" = 4)
	required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	results = list("doctorsdelight" = 5)
	required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1, "tricordrazine" = 1)

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	results = "irishcream"
	required_reagents = list("whiskey" = 2, "cream" = 1)

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	results = list("manlydorf" = 3)
	required_reagents = list ("beer" = 1, "ale" = 2)

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = "hooch"
	results = list("hooch" = 3)
	required_reagents = list ("sugar" = 1, "ethanol" = 2, "fuel" = 1)

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = "irishcoffee"
	results = list("irishcoffee" = 2)
	required_reagents = list("irishcream" = 1, "coffee" = 1)

/datum/chemical_reaction/b52
	name = "B-52"
	id = "b52"
	results = list("b52" = 3)
	required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	results = list("atomicbomb" = 10)
	required_reagents = list("b52" = 10, "uranium" = 1)

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = "margarita"
	results = list("margarita" = 3)
	required_reagents = list("tequilla" = 2, "limejuice" = 1)

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	results = list("longislandicedtea" = 4)
	required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)

/datum/chemical_reaction/icedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	results = list("longislandicedtea" = 4)
	required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	results = list("threemileisland" = 10)
	required_reagents = list("longislandicedtea" = 10, "uranium" = 1)

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	results = list("whiskeysoda" = 10)
	required_reagents = list("whiskey" = 2, "sodawater" = 1)

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = "blackrussian"
	results = list("blackrussian" = 5)
	required_reagents = list("vodka" = 3, "kahlua" = 2)

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = "manhattan"
	results = list("manhattan" = 3)
	required_reagents = list("whiskey" = 2, "vermouth" = 1)

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	results = list("manhattan_proj" = 10)
	required_reagents = list("manhattan" = 10, "uranium" = 1)

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	results = list("vodkatonic" = 3)
	required_reagents = list("vodka" = 2, "tonic" = 1)

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = "ginfizz"
	results = list("ginfizz" = 4)
	required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	results = list("bahama_mama" = 6)
	required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = "singulo"
	results = list("singulo" = 10)
	required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	results = list("alliescocktail" = 2)
	required_reagents = list("martini" = 1, "vodka" = 1)

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	results = list("demonsblood" = 4)
	required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)

/datum/chemical_reaction/booger
	name = "Booger"
	id = "booger"
	results = list("booger" = 4)
	required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	results = list("antifreeze" = 4)
	required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = "barefoot"
	results = list("barefoot" = 3)
	required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)

/datum/chemical_reaction/grapesoda
	name = "Grape Soda"
	id = "grapesoda"
	results = list("grapesoda" = 3)
	required_reagents = list("grapejuice" = 2, "cola" = 1)



////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = "sbiten"
	results = list("sbiten" = 10)
	required_reagents = list("vodka" = 10, "capsaicin" = 1)

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = "red_mead"
	results = list("red_mead" = 2)
	required_reagents = list("blood" = 1, "mead" = 1)

/datum/chemical_reaction/mead
	name = "Mead"
	id = "mead"
	results = list("mead" = 2)
	required_reagents = list("sugar" = 1, "water" = 1)
	required_catalysts = list("enzyme" = 5)

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	results = list("iced_beer" = 10)
	required_reagents = list("beer" = 10, "frostoil" = 1)

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = "iced_beer"
	results = list("iced_beer" = 6)
	required_reagents = list("beer" = 5, "ice" = 1)

/datum/chemical_reaction/grog
	name = "Grog"
	id = "grog"
	results = list("grog" = 2)
	required_reagents = list("rum" = 1, "water" = 1)

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	results = list("soy_latte" = 2)
	required_reagents = list("coffee" = 1, "soymilk" = 1)

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	results = list("cafe_latte" = 2)
	required_reagents = list("coffee" = 1, "milk" = 1)

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = "acidspit"
	results = list("acidspit" = 6)
	required_reagents = list("sacid" = 1, "wine" = 5)

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = "amasec"
	results = list("amasec" = 10)
	required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	results = list("changelingsting" = 5)
	required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = "aloe"
	results = list("aloe" = 2)
	required_reagents = list("cream" = 1, "whiskey" = 1, "watermelonjuice" = 1)

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = "andalusia"
	results = list("andalusia" = 3)
	required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	results = list("neurotoxin" = 2)
	required_reagents = list("gargleblaster" = 1, "stoxin" = 1)

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = "snowwhite"
	results = list("snowwhite" = 2)
	required_reagents = list("beer" = 1, "lemon_lime" = 1)

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	results = list("irishcarbomb" = 2)
	required_reagents = list("ale" = 1, "irishcream" = 1)

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	results = list("syndicatebomb" = 2)
	required_reagents = list("beer" = 1, "whiskeycola" = 1)

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	results = list("erikasurprise" = 5)
	required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)


/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	results = list("devilskiss" = 3)
	required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = "hippiesdelight"
	results = list("hippiesdelight" = 2)
	required_reagents = list("psilocybin" = 1, "gargleblaster" = 1)

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	results = list("bananahonk" = 3)
	required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = "silencer"
	results = list("silencer" = 3)
	required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	results = list("driestmartini" = 2)
	required_reagents = list("nothing" = 1, "gin" = 1)

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = "lemonade"
	results = list("lemonade" = 3)
	required_reagents = list("lemonjuice" = 1, "sugar" = 1, "water" = 1)

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = "kiraspecial"
	results = list("kiraspecial" = 2)
	required_reagents = list("orangejuice" = 1, "limejuice" = 1, "sodawater" = 1)

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = "brownstar"
	results = list("brownstar" = 2)
	required_reagents = list("orangejuice" = 2, "cola" = 1)

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = "milkshake"
	results = list("milkshake" = 5)
	required_reagents = list("cream" = 1, "ice" = 2, "milk" = 2)

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = "rewriter"
	results = list("rewriter" = 2)
	required_reagents = list("spacemountainwind" = 1, "coffee" = 1)

/datum/chemical_reaction/suidream
	name = "Sui Dream"
	id = "suidream"
	results = list("suidream" = 4)
	required_reagents = list("space_up" = 2, "bluecuracao" = 1, "melonliquor" = 1)
