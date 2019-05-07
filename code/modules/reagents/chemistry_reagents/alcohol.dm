#define ALCOHOL_THRESHOLD_MODIFIER 0.05 //Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_RATE 0.004 //The rate at which alcohol affects you
#define ALCOHOL_EXPONENT 1.6 //The exponent applied to boozepwr to make higher volume alcohol atleast a little bit damaging.

/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "alcohol"
	var/boozepwr = 65 //Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning.

	var/druggy = 0
	var/halluci = 0

/*
Boozepwr Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance
0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - toxin damage, passing out
91-100: Dangerously toxic - brain damage, probable liver failure.
101 and beyond: Lethally toxic - Swift death.
*/

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/L, metabolism)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
			C.drunkenness = max((C.drunkenness + (sqrt(volume) * boozepwr * ALCOHOL_RATE)), 0) //Volume, power, and server alcohol rate effect how quickly one gets drunk.
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			var/datum/internal_organ/liver/O = H.internal_organs_by_name["liver"]
			if (istype(O))
				O.take_damage(((max(sqrt(volume) * (boozepwr ** ALCOHOL_EXPONENT) * O.alcohol_tolerance, 0)) * 0.002), TRUE)

	if(druggy != 0)
		L.set_drugginess(druggy)

	if(halluci)
		L.hallucination += halluci

	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "<span class='warning'>The [name] dissolves the ink on the paper.</span>")
	if(istype(O,/obj/item/book))
		if(volume > 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			to_chat(usr, "<span class='warning'>The [name] dissolves the ink on the book.</span>")
		else
			to_chat(usr, "<span class='warning'>[O]'s ink is smeared by [name], but doesn't wash away!</span>")

/datum/reagent/consumbale/ethanol/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(method in list(TOUCH, VAPOR, PATCH))
		L.adjust_fire_stacks(round(volume * 0.65))

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25
	taste_description = "piss water"

/datum/reagent/consumable/ethanol/wy_beer
	name = "Aspen Beer"
	id = "aspen"
	description = "Pretty good when you get past the fact that it tastes like piss. Canned by the Nanotrasen Corporation."
	color = "#ffcc66"
	boozepwr = 5 //Space Europeans hate it
	taste_description = "dish water"

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "spiked latte"
	boozepwr = 45

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/L, metabolism)
	L.Dizzy(-4)
	L.drowsyness = max(L.drowsyness-2, 0)
	L.AdjustSleeping(-3)
	L.Jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67,
	taste_description = "molasses"
	boozepwr = 75

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 80
	taste_description = "exquisite amber"

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "A potent rice-wine."
	color = "#0064C8" // rgb: 102, 67, 0
	taste_description = "sweet rice wine"
	boozepwr = 70

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	boozepwr = 80
	nutriment_factor = 1 * FOOD_METABOLISM
	taste_description = "jitters and death"
	adj_temp = 5
	targ_temp = 305

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/L, metabolism)
	L.drowsyness = max(0,L.drowsyness-7)
	L.AdjustSleeping(-40)
	L.Jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "grain alcohol"
	boozepwr = 65

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/L, metabolism)
	L.radiation = max(L.radiation-1,0)
	return ..()

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	boozepwr = 15
	nutriment_factor = 2 * FOOD_METABOLISM
	taste_description = "desperation and lactate"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	taste_description = "dryness"
	boozepwr = 10
	druggy = 50

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "an alcoholic christmas tree"
	boozepwr = 45

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Yohoho and all that."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "spiked butterscotch"
	boozepwr = 60

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	id = "tequila"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 70
	taste_description = "paint stripper"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	taste_description = "dry alcohol"
	boozepwr = 45

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 35
	taste_description = "bitter sweetness"

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	taste_description = "angry and irish"
	boozepwr = 75

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "pure resignation"
	boozepwr = 100

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "hearty barley ale"
	boozepwr = 65

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33EE00" // rgb: 51, 238, 0
	taste_description = "death and licorice"
	boozepwr = 80

/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/L, metabolism)
	if(prob(10))
		L.hallucination += 4 //Reference to the urban myth
	return ..()

/datum/reagent/consumable/ethanol/pwine
	name = "Poison Wine"
	id = "pwine"
	description = "A potent wine with hallucinogenic properties, popular among high personalities and villains."
	color = "#000000" // rgb: 0, 0, 0 SHOCKER
	taste_description = "evil velvet"
	boozepwr = 40

/datum/reagent/consumable/ethanol/pwine/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 19)
			L.Jitter(2)
			L.hallucination = max(L.hallucination, 3)
			if(prob(1))
				L.emote(pick("twitch","giggle"))
		if(20 to 59)
			L.stuttering = max(L.stuttering, 2)
			L.hallucination = max(L.hallucination, 10)
			L.Jitter(3)
			L.Dizzy(2)
			L.set_drugginess(10)
			if(prob(5))
				L.emote(pick("twitch","giggle"))
		if(60 to 119)
			L.stuttering = max(L.stuttering, 2)
			L.hallucination = max(L.hallucination, 60)
			L.Jitter(4)
			L.Dizzy(4)
			L.set_drugginess(30)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
			if(prob(30))
				L.adjustToxLoss(0.5)
		if(120 to 199)
			L.stuttering = max(L.stuttering, 2)
			L.hallucination = max(L.hallucination, 60)
			L.Jitter(4)
			L.Dizzy(4)
			L.druggy = max(L.druggy, 60)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
			if(prob(30))
				L.adjustToxLoss(1)
			if(prob(5))
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
					if(istype(E))
						E.take_damage(2)
		if(200 to INFINITY)
			L.stuttering += 1
			L.adjustToxLoss(1)
			L.hallucination = max(L.hallucination, 60)
			L.Jitter(4)
			L.Dizzy(4)
			L.druggy = max(L.druggy, 60)
			if(ishuman(L) && prob(10))
				var/mob/living/carbon/human/H = L
				var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
				if(istype(E))
					if(H.species.species_flags ~! NO_PAIN)
						to_chat(H, "<span class='danger'>You clutch for a moment as you feel a scorching pain covering your abdomen!</span>")
						H.Stun(3)
					E.take_damage(20)
	return ..()

/datum/reagent/consumable/ethanol/deadrum
	name = "Deadrum"
	id = "rum"
	description = "Popular with the sailors. Not very popular with everyone else."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35
	taste_description = "salty sea water"

/datum/reagent/consumable/ethanol/deadrum/on_mob_life(mob/living/L, metabolism)
	L.Dizzy(5)
	return ..()

/datum/reagent/consumable/ethanol/davenport
	name = "Davenport Rye"
	id = "davenport"
	description = "An expensive alcohol with a distinct flavor"
	color = "#ffcc66"
	taste_description = "oil, whiskey, salt, rosemary mixed togheter" // Insert reference here.
	boozepwr = 50

/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////


/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100% proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "burning cinnamon"
	boozepwr = 25

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	taste_description = "metallic and expensive"
	boozepwr = 60

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "mild and tart"
	boozepwr = 25

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Viva la revolucion! Viva Cuba Libre!"
	color = "#3E1B00" // rgb: 62, 27, 0
	taste_description = "a refreshing marriage of citrus and rum"
	boozepwr = 50

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	taste_description = "cola"
	boozepwr = 70

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "dry class"
	boozepwr = 60

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "shaken, not stirred"
	boozepwr = 65

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	taste_description = "bitter cream"
	boozepwr = 50

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	taste_description = "oranges"
	boozepwr = 55

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	taste_description = "sweet 'n creamy"
	boozepwr = 45

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "tomatoes with a hint of lime"
	boozepwr = 55


/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/L, metabolism)
	if(L.blood_volume < BLOOD_VOLUME_NORMAL)
		L.blood_volume += 0.3 //Bloody Mary slowly restores blood loss.
	return ..()

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "It's just as effective as Dutch-Courage!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "alcoholic bravery"
	boozepwr = 80

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	id = "tequilasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	color = "#FFE48C" // rgb: 255, 228, 140
	taste_description = "oranges with a hint of pomegranate"
	boozepwr = 45


/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	id = "phoronspecial"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "spicy toxins"
	boozepwr = 25
	targ_temp = 330
	adj_temp = 15

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "JUSTICE"
	boozepwr = 90 //THE FIST OF THE LAW IS STRONG AND HARD

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/L, metabolism)
	L.Stun(2)
	return ..()

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "creamy alcohol"
	boozepwr = 70

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "hair on your chest and your chin"
	boozepwr = 100 //For the manly only

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "a mixture of cola and alcohol"
	boozepwr = 35

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitterness"
	boozepwr = 95

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "angry and irish"
	boozepwr = 85

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "giving up on the day"
	boozepwr = 35

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	taste_description = "dry and salty"
	boozepwr = 35

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	taste_description = "bitterness"
	boozepwr = 70

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "mild dryness"
	boozepwr = 30

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "death, the destroyer of worlds"
	boozepwr = 45
	druggy = 30

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "For the more refined griffon."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "soda"
	boozepwr = 70

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "Jack Frost's piss"
	boozepwr = 35
	targ_temp = 330
	adj_temp = 20

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "creamy berries"
	boozepwr = 45

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_description = "refreshing cold"
	boozepwr = 35

/datum/reagent/consumable/ethanol/melonliquor
	name = "Melon Liquor"
	id = "melonliquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	color = "#138808" // rgb: 19, 136, 8
	boozepwr = 60
	taste_description = "fruity alcohol"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "Exotically blue, fruity drink, distilled from oranges."
	color = "#0000CD" // rgb: 0, 0, 205
	boozepwr = 50
	taste_description = "oranges"

/datum/reagent/consumable/ethanol/suidream
	name = "Sui Dream"
	id = "suidream"
	description = "Comprised of: White soda, blue curacao, melon liquor."
	color = "#00A86B" // rgb: 0, 168, 107
	taste_description = "fruity soda"
	boozepwr = 10

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	taste_description = "sweet tasting iron"
	boozepwr = 75

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "tart bitterness"
	boozepwr = 70

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "dry, tart lemons"
	boozepwr = 45

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropical cocktail."
	color = "#FF7F3B" // rgb: 255, 127, 59
	taste_description = "lime and orange"
	boozepwr = 35


/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "concentrated matter"
	boozepwr = 35

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "hot and spice"
	boozepwr = 70
	targ_temp = 360
	adj_temp = 50

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	taste_description = "bitter iron"
	boozepwr = 70

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking's drink! Even though it has a strange red color."
	color = "#C73C00" // rgb: 199, 60, 0
	taste_description = "sweet and salty alcohol"
	boozepwr = 51

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Viking's drink, though a cheap one."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "sweet, sweet alcohol"
	boozepwr = 50
	nutriment_factor = 1 * FOOD_METABOLISM

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "refreshingly cold"
	boozepwr = 15
	targ_temp = 270
	adj_temp = 20

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, NanoTrasen approves!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "a poor excuse for alcohol"
	boozepwr = 1

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "sweet 'n creamy"
	boozepwr = 35

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strangely named drink."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "lemons"
	boozepwr = 40

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies, not as sweet as when made from your enemies."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter yet free"
	boozepwr = 45

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	color = "#365000" // rgb: 54, 80, 0
	taste_description = "stomach acid"
	boozepwr = 80

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the NanoTrasen Gun-Club!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "dark and metallic"
	boozepwr = 35

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "your brain coming out your nose"
	boozepwr = 95

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "delicious anger"
	boozepwr = 25

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "Tastes like terrorism!"
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "purified antagonism"
	boozepwr = 90

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "tartness and bananas"
	boozepwr = 35

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "a beach"
	boozepwr = 65

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFF91" // rgb: 255, 255, 140
	taste_description = "a bad joke"
	boozepwr = 60

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1 * FOOD_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 59
	taste_description = "a pencil eraser"

/datum/reagent/consumable/ethanol/silencer/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 50)
			L.Dizzy(5)
			L.stuttering += 2
		if(51 to 100)
			L.Dizzy(5)
			L.stuttering += 5
			if(prob(20))
				L.confused += 3
		if(101 to INFINITY)
			L.Dizzy(6)
			L.stuttering += 5
			if(prob(20))
				L.confused += 5
	return ..()