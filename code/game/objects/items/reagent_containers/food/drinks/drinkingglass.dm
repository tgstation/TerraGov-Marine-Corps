

/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50
	center_of_mass = list("x"=16, "y"=10)

	on_reagent_change()
		/*if(reagents.reagent_list.len > 1 )
			icon_state = "glass_brown"
			name = "Glass of Hooch"
			desc = "Two or more drinks, mixed together."*/
		/*else if(reagents.reagent_list.len == 1)
			for(var/datum/reagent/R in reagents.reagent_list)
				switch(R.id)*/
		if (reagents.reagent_list.len > 0)
			//mrid = R.get_master_reagent_id()
			switch(reagents.get_master_reagent_id())
				if(/datum/reagent/consumable/ethanol/beer)
					icon_state = "beerglass"
					name = "Beer glass"
					desc = "A freezing pint of beer"
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/ale)
					icon_state = "aleglass"
					name = "Ale glass"
					desc = "A freezing pint of delicious Ale"
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/drink/milk)
					icon_state = "glass_white"
					name = "Glass of milk"
					desc = "White and nutritious goodness!"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/milk/cream)
					icon_state  = "glass_white"
					name = "Glass of cream"
					desc = "Ewwww..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/hot_coco)
					icon_state  = "chocolateglass"
					name = "Glass of chocolate"
					desc = "Tasty"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/lemonjuice)
					icon_state  = "lemonglass"
					name = "Glass of lemonjuice"
					desc = "Sour..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/space_cola)
					icon_state  = "glass_brown"
					name = "Glass of Space Cola"
					desc = "A glass of refreshing Space Cola"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/nuka_cola)
					icon_state = "nuka_colaglass"
					name = "Nuka Cola"
					desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland"
					center_of_mass = list("x"=16, "y"=6)
				if(/datum/reagent/consumable/drink/orangejuice)
					icon_state = "glass_orange"
					name = "Glass of Orange juice"
					desc = "Vitamins! Yay!"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/tomatojuice)
					icon_state = "glass_red"
					name = "Glass of Tomato juice"
					desc = "Are you sure this is tomato juice?"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/blood)
					icon_state = "glass_red"
					name = "Glass of Tomato juice"
					desc = "Are you sure this is tomato juice?"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/limejuice)
					icon_state = "glass_green"
					name = "Glass of Lime juice"
					desc = "A glass of sweet-sour lime juice."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/whiskey)
					icon_state = "whiskeyglass"
					name = "Glass of whiskey"
					desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/whiskey)
					icon_state = "ginvodkaglass"
					name = "Glass of gin"
					desc = "A crystal clear glass of Griffeater gin."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/sake)
					icon_state = "ginvodkaglass"
					name = "Glass of sake"
					desc = "A glass of warm Nanotrasen brand sake."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/vodka)
					icon_state = "ginvodkaglass"
					name = "Glass of vodka"
					desc = "The glass contain wodka. Xynta."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/sake)
					icon_state = "ginvodkaglass"
					name = "Glass of Sake"
					desc = "A glass of Sake."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/goldschlager)
					icon_state = "ginvodkaglass"
					name = "Glass of goldschlager"
					desc = "100 proof that teen girls will drink anything with gold in it."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/wine)
					icon_state = "wineglass"
					name = "Glass of wine"
					desc = "A very classy looking drink."
					center_of_mass = list("x"=15, "y"=7)
				if(/datum/reagent/consumable/ethanol/cognac)
					icon_state = "cognacglass"
					name = "Glass of cognac"
					desc = "Damn, you feel like some kind of French aristocrat just by holding this."
					center_of_mass = list("x"=16, "y"=6)
				if (/datum/reagent/consumable/ethanol/kahlua)
					icon_state = "kahluaglass"
					name = "Glass of RR coffee Liquor"
					desc = "DAMN, THIS THING LOOKS ROBUST"
					center_of_mass = list("x"=15, "y"=7)
				if(/datum/reagent/consumable/ethanol/vermouth)
					icon_state = "vermouthglass"
					name = "Glass of Vermouth"
					desc = "You wonder why you're even drinking this straight."
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/tequila)
					icon_state = "tequilaglass"
					name = "Glass of Tequila"
					desc = "Now all that's missing is the weird colored shades!"
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/patron)
					icon_state = "patronglass"
					name = "Glass of Patron"
					desc = "Drinking patron in the bar, with all the subpar ladies."
					center_of_mass = list("x"=7, "y"=8)
				if(/datum/reagent/consumable/ethanol/rum)
					icon_state = "rumglass"
					name = "Glass of Rum"
					desc = "Now you want to Pray for a pirate suit, don't you?"
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/ethanol/gintonic)
					icon_state = "gintonicglass"
					name = "Gin and Tonic"
					desc = "A mild but still great cocktail. Drink up, like a true Englishman."
					center_of_mass = list("x"=16, "y"=7)
				if(/datum/reagent/consumable/ethanol/whiskey_cola)
					icon_state = "whiskeycolaglass"
					name = "Whiskey Cola"
					desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/white_russian)
					icon_state = "whiterussianglass"
					name = "White Russian"
					desc = "A very nice looking drink. But that's just, like, your opinion, man."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/screwdrivercocktail)
					icon_state = "screwdriverglass"
					name = "Screwdriver"
					desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
					center_of_mass = list("x"=15, "y"=10)
				if(/datum/reagent/consumable/ethanol/bloody_mary)
					icon_state = "bloodymaryglass"
					name = "Bloody Mary"
					desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/martini)
					icon_state = "martiniglass"
					name = "Classic Martini"
					desc = "Damn, the bartender even stirred it, not shook it."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/vodkamartini)
					icon_state = "martiniglass"
					name = "Vodka martini"
					desc ="A bastardisation of the classic martini. Still great."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/drink/gargle_blaster)
					icon_state = "gargleblasterglass"
					name = "Pan-Galactic Gargle Blaster"
					desc = "Does... does this mean that Arthur and Ford are on the station? Oh joy."
					center_of_mass = list("x"=17, "y"=6)
				if(/datum/reagent/consumable/ethanol/brave_bull)
					icon_state = "bravebullglass"
					name = "Brave Bull"
					desc = "Tequila and Coffee liquor, brought together in a mouthwatering mixture. Drink up."
					center_of_mass = list("x"=15, "y"=8)
				if(/datum/reagent/consumable/ethanol/tequila_sunrise)
					icon_state = "tequilasunriseglass"
					name = "Tequila Sunrise"
					desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/toxins_special)
					icon_state = "toxinsspecialglass"
					name = "Toxins Special"
					desc = "Whoah, this thing is on FIRE"
				if(/datum/reagent/consumable/ethanol/beepsky_smash)
					icon_state = "beepskysmashglass"
					name = "Beepsky Smash"
					desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
					center_of_mass = list("x"=18, "y"=10)
				if(/datum/reagent/consumable/drink/doctor_delight)
					icon_state = "doctorsdelightglass"
					name = "Doctor's Delight"
					desc = "A healthy mixture of juices, guaranteed to keep you healthy until the next toolboxing takes place."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/manly_dorf)
					icon_state = "manlydorfglass"
					name = "The Manly Dorf"
					desc = "A manly concotion made from Ale and Beer. Intended for true men only."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/irish_cream)
					icon_state = "irishcreamglass"
					name = "Irish Cream"
					desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/cuba_libre)
					icon_state = "cubalibreglass"
					name = "Cuba Libre"
					desc = "A classic mix of rum and cola."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/b52)
					icon_state = "b52glass"
					name = "B-52"
					desc = "Kahlua, Irish Cream, and congac. You will get bombed."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/atomicbomb)
					icon_state = "atomicbombglass"
					name = "Atomic Bomb"
					desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."
					center_of_mass = list("x"=15, "y"=7)
				if(/datum/reagent/consumable/ethanol/longislandicedtea)
					icon_state = "longislandicedteaglass"
					name = "Long Island Iced Tea"
					desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/threemileisland)
					icon_state = "threemileislandglass"
					name = "Three Mile Island Ice Tea"
					desc = "A glass of this is sure to prevent a meltdown."
					center_of_mass = list("x"=16, "y"=2)
				if(/datum/reagent/consumable/ethanol/margarita)
					icon_state = "margaritaglass"
					name = "Margarita"
					desc = "On the rocks with salt on the rim. Arriba~!"
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/black_russian)
					icon_state = "blackrussianglass"
					name = "Black Russian"
					desc = "For the lactose-intolerant. Still as classy as a White Russian."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/vodkatonic)
					icon_state = "vodkatonicglass"
					name = "Vodka and Tonic"
					desc = "For when a gin and tonic isn't russian enough."
					center_of_mass = list("x"=16, "y"=7)
				if(/datum/reagent/consumable/ethanol/manhattan)
					icon_state = "manhattanglass"
					name = "Manhattan"
					desc = "The Detective's undercover drink of choice. He never could stomach gin..."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/manhattan_proj)
					icon_state = "proj_manhattanglass"
					name = "Manhattan Project"
					desc = "A scienitst drink of choice, for thinking how to blow up the station."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/ginfizz)
					icon_state = "ginfizzglass"
					name = "Gin Fizz"
					desc = "Refreshingly lemony, deliciously dry."
					center_of_mass = list("x"=16, "y"=7)
				if(/datum/reagent/consumable/ethanol/irishcoffee)
					icon_state = "irishcoffeeglass"
					name = "Irish Coffee"
					desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
					center_of_mass = list("x"=15, "y"=10)
				if(/datum/reagent/consumable/ethanol/hooch)
					icon_state = "glass_brown2"
					name = "Hooch"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/whiskeysoda)
					icon_state = "whiskeysodaglass2"
					name = "Whiskey Soda"
					desc = "Ultimate refreshment."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/drink/cold/tonic)
					icon_state = "glass_clear"
					name = "Glass of Tonic Water"
					desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/sodawater)
					icon_state = "glass_clear"
					name = "Glass of Soda Water"
					desc = "Soda water. Why not make a scotch and soda?"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/water)
					icon_state = "glass_clear"
					name = "Glass of Water"
					desc = "The father of all refreshments."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/spacemountainwind)
					icon_state = "Space_mountain_wind_glass"
					name = "Glass of Space Mountain Wind"
					desc = "Space Mountain Wind. As you know, there are no mountains in space, only wind."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/thirteenloko)
					icon_state = "thirteen_loko_glass"
					name = "Glass of Thirteen Loko"
					desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/dr_gibb)
					icon_state = "dr_gibb_glass"
					name = "Glass of Dr. Gibb"
					desc = "Dr. Gibb. Not as dangerous as the name might imply."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/space_up)
					icon_state = "space-up_glass"
					name = "Glass of Space-up"
					desc = "Space-up. It helps keep your cool."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/moonshine)
					icon_state = "glass_clear"
					name = "Moonshine"
					desc = "You've really hit rock bottom now... your liver packed its bags and left last night."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/milk/soymilk)
					icon_state = "glass_white"
					name = "Glass of soy milk"
					desc = "White and nutritious soy goodness!"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/berryjuice)
					icon_state = "berryjuice"
					name = "Glass of berry juice"
					desc = "Berry juice. Or maybe its jam. Who cares?"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/poisonberryjuice)
					icon_state = "poisonberryjuice"
					name = "Glass of poison berry juice"
					desc = "A glass of deadly juice."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/carrotjuice)
					icon_state = "carrotjuice"
					name = "Glass of  carrot juice"
					desc = "It is just like a carrot but without crunching."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/banana)
					icon_state = "banana"
					name = "Glass of banana juice"
					desc = "The raw essence of a banana. HONK"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/bahama_mama)
					icon_state = "bahama_mama"
					name = "Bahama Mama"
					desc = "Tropic cocktail"
					center_of_mass = list("x"=16, "y"=5)
				if(/datum/reagent/consumable/ethanol/singulo)
					icon_state = "singulo"
					name = "Singulo"
					desc = "A blue-space beverage."
					center_of_mass = list("x"=17, "y"=4)
				if(/datum/reagent/consumable/ethanol/alliescocktail)
					icon_state = "alliescocktail"
					name = "Allies cocktail"
					desc = "A drink made from your allies."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/antifreeze)
					icon_state = "antifreeze"
					name = "Anti-freeze"
					desc = "The ultimate refreshment."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/barefoot)
					icon_state = "b&p"
					name = "Barefoot"
					desc = "Barefoot and pregnant"
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/demonsblood)
					icon_state = "demonsblood"
					name = "Demons Blood"
					desc = "Just looking at this thing makes the hair at the back of your neck stand up."
					center_of_mass = list("x"=16, "y"=2)
				if(/datum/reagent/consumable/ethanol/booger)
					icon_state = "booger"
					name = "Booger"
					desc = "Ewww..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/snowwhite)
					icon_state = "snowwhite"
					name = "Snow White"
					desc = "A cold refreshment."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/aloe)
					icon_state = "aloe"
					name = "Aloe"
					desc = "Very, very, very good."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/andalusia)
					icon_state = "andalusia"
					name = "Andalusia"
					desc = "A nice, strange named drink."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/sbiten)
					icon_state = "sbitenglass"
					name = "Sbiten"
					desc = "A spicy mix of Vodka and Spice. Very hot."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/ethanol/red_mead)
					icon_state = "red_meadglass"
					name = "Red Mead"
					desc = "A True Vikings Beverage, though its color is strange."
					center_of_mass = list("x"=17, "y"=10)
				if(/datum/reagent/consumable/ethanol/mead)
					icon_state = "meadglass"
					name = "Mead"
					desc = "A Vikings Beverage, though a cheap one."
					center_of_mass = list("x"=17, "y"=10)
				if(/datum/reagent/consumable/ethanol/iced_beer)
					icon_state = "iced_beerglass"
					name = "Iced Beer"
					desc = "A beer so frosty, the air around it freezes."
					center_of_mass = list("x"=16, "y"=7)
				if(/datum/reagent/consumable/ethanol/grog)
					icon_state = "grogglass"
					name = "Grog"
					desc = "A fine and cepa drink for Space."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/coffee/soy_latte)
					icon_state = "soy_latte"
					name = "Soy Latte"
					desc = "A nice and refrshing beverage while you are reading."
					center_of_mass = list("x"=15, "y"=9)
				if(/datum/reagent/consumable/drink/coffee/cafe_latte)
					icon_state = "cafe_latte"
					name = "Cafe Latte"
					desc = "A nice, strong and refreshing beverage while you are reading."
					center_of_mass = list("x"=15, "y"=9)
				if(/datum/reagent/consumable/ethanol/acid_spit)
					icon_state = "acidspitglass"
					name = "Acid Spit"
					desc = "A drink from Nanotrasen. Made from live aliens."
					center_of_mass = list("x"=16, "y"=7)
				if(/datum/reagent/consumable/ethanol/amasec)
					icon_state = "amasecglass"
					name = "Amasec"
					desc = "Always handy before COMBAT!!!"
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/drink/neurotoxin)
					icon_state = "neurotoxinglass"
					name = "Neurotoxin"
					desc = "A drink that is guaranteed to knock you silly."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/drink/hippies_delight)
					icon_state = "hippiesdelightglass"
					name = "Hippie's Delight"
					desc = "A drink enjoyed by people during the 1960's."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/bananahonk)
					icon_state = "bananahonkglass"
					name = "Banana Honk"
					desc = "A drink from Banana Heaven."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/silencer)
					icon_state = "silencerglass"
					name = "Silencer"
					desc = "A drink from mime Heaven."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/drink/nothing)
					icon_state = "nothing"
					name = "Nothing"
					desc = "Absolutely nothing."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/devilskiss)
					icon_state = "devilskiss"
					name = "Devils Kiss"
					desc = "Creepy time!"
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/changelingsting)
					icon_state = "changelingsting"
					name = "Changeling Sting"
					desc = "A stingy drink."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/irishcarbomb)
					icon_state = "irishcarbomb"
					name = "Irish Car Bomb"
					desc = "An irish car bomb."
					center_of_mass = list("x"=16, "y"=8)
				if(/datum/reagent/consumable/ethanol/syndicatebomb)
					icon_state = "syndicatebomb"
					name = "Syndicate Bomb"
					desc = "A syndicate bomb."
					center_of_mass = list("x"=16, "y"=4)
				if(/datum/reagent/consumable/ethanol/erikasurprise)
					icon_state = "erikasurprise"
					name = "Erika Surprise"
					desc = "The surprise is, it's green!"
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/driestmartini)
					icon_state = "driestmartiniglass"
					name = "Driest Martini"
					desc = "Only for the experienced. You think you see sand floating in the glass."
					center_of_mass = list("x"=17, "y"=8)
				if(/datum/reagent/consumable/drink/cold/ice)
					icon_state = "iceglass"
					name = "Glass of ice"
					desc = "Generally, you're supposed to put something else in there too..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/coffee/icecoffee)
					icon_state = "icedcoffeeglass"
					name = "Iced Coffee"
					desc = "A drink to perk you up and refresh you!"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/coffee)
					icon_state = "glass_brown"
					name = "Glass of coffee"
					desc = "Don't drop it, or you'll send scalding liquid and glass shards everywhere."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/ethanol/bilk)
					icon_state = "glass_brown"
					name = "Glass of bilk"
					desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/fuel)
					icon_state = "dr_gibb_glass"
					name = "Glass of welder fuel"
					desc = "Unless you are an industrial tool, this is probably not safe for consumption."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/brownstar)
					icon_state = "brownstar"
					name = "Brown Star"
					desc = "It's not what it sounds like..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/grapejuice)
					icon_state = "grapejuice"
					name = "Glass of grape juice"
					desc = "It's grrrrrape!"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/grapesoda)
					icon_state = "grapesoda"
					name = "Can of Grape Soda"
					desc = "Looks like a delicious drank!"
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/tea/icetea)
					icon_state = "icedteaglass"
					name = "Iced Tea"
					desc = "No relation to a certain rap artist/ actor."
					center_of_mass = list("x"=15, "y"=10)
				if(/datum/reagent/consumable/drink/grenadine)
					icon_state = "grenadineglass"
					name = "Glass of grenadine syrup"
					desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
					center_of_mass = list("x"=17, "y"=6)
				if(/datum/reagent/consumable/drink/cold/milkshake)
					icon_state = "milkshake"
					name = "Milkshake"
					desc = "Glorious brainfreezing mixture."
					center_of_mass = list("x"=16, "y"=7)
				if(/datum/reagent/consumable/drink/cold/lemonade)
					icon_state = "lemonadeglass"
					name = "Lemonade"
					desc = "Oh the nostalgia..."
					center_of_mass = list("x"=16, "y"=10)
				if(/datum/reagent/consumable/drink/cold/kiraspecial)
					icon_state = "kiraspecial"
					name = "Kira Special"
					desc = "Long live the guy who everyone had mistaken for a girl. Baka!"
					center_of_mass = list("x"=16, "y"=12)
				if(/datum/reagent/consumable/drink/cold/rewriter)
					icon_state = "rewriter"
					name = "Rewriter"
					desc = "The secret of the sanctuary of the Libarian..."
					center_of_mass = list("x"=16, "y"=9)
				if(/datum/reagent/consumable/ethanol/suidream)
					icon_state = "sdreamglass"
					name = "Sui Dream"
					desc = "A froofy, fruity, and sweet mixed drink. Understanding the name only brings shame."
					center_of_mass = list("x"=16, "y"=5)
				if(/datum/reagent/consumable/ethanol/melonliquor)
					icon_state = "emeraldglass"
					name = "Glass of Melon Liquor"
					desc = "A relatively sweet and fruity 46 proof liquor."
					center_of_mass = list("x"=16, "y"=5)
				if(/datum/reagent/consumable/ethanol/bluecuracao)
					icon_state = "curacaoglass"
					name = "Glass of Blue Curacao"
					desc = "Exotically blue, fruity drink, distilled from oranges."
					center_of_mass = list("x"=16, "y"=5)
				if(/datum/reagent/consumable/ethanol/absinthe)
					icon_state = "absintheglass"
					name = "Glass of Absinthe"
					desc = "Wormwood, anise, oh my."
					center_of_mass = list("x"=16, "y"=5)
				if(/datum/reagent/consumable/ethanol/pwine)
					icon_state = "pwineglass"
					name = "Glass of ???"
					desc = "A black ichor with an oily purple sheer on top. Are you sure you should drink this?"
					center_of_mass = list("x"=16, "y"=5)
				else
					icon_state ="glass_brown"
					name = "Glass of ..what?"
					desc = "You can't really tell what this is."
					center_of_mass = list("x"=16, "y"=10)
		else
			icon_state = "glass_empty"
			name = "glass"
			desc = "Your standard drinking glass."
			center_of_mass = list("x"=16, "y"=10)
			return

/obj/item/reagent_containers/food/drinks/drinkingglass/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(X)

// for /obj/machinery/vending/sovietsoda
/obj/item/reagent_containers/food/drinks/drinkingglass/soda
	name = "soda glass"
	desc = "A drinking glass for soda."
	list_reagents = list(/datum/reagent/consumable/drink/cold/sodawater = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/soda/Initialize()
	. = ..()
	on_reagent_change()

/obj/item/reagent_containers/food/drinks/drinkingglass/cola
	name = "cola glass"
	desc = "A drinking glass for cola."
	list_reagents = list(/datum/reagent/consumable/drink/cold/space_cola = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/cola/Initialize()
	. = ..()
	on_reagent_change()
