#define ALCOHOL_THRESHOLD_MODIFIER 0.05 //Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_RATE 0.004 //The rate at which alcohol affects you
#define ALCOHOL_EXPONENT 1.6 //The exponent applied to boozepwr to make higher volume alcohol atleast a little bit damaging.

/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "alcohol"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/beer
	///How much drugginess our mob gets on life tick
	var/druggy = 0
	///How much hallucination our mob gets on life tick
	var/halluci = 0
	/**
	 * Boozepwr Chart
	 * Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
	 * In addition, severe effects won't always trigger unless the drink is poisonously strong
	 * All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance
	 * 0: Non-alcoholic
	 * 1-10: Barely classifiable as alcohol - occassional slurring
	 * 11-20: Slight alcohol content - slurring
	 * 21-30: Below average - imbiber begins to look slightly drunk
	 * 31-40: Just below average - no unique effects
	 * 41-50: Average - mild disorientation, imbiber begins to look drunk
	 * 51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
	 * 61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
	 * 71-80: High alcohol content - blurry vision, imbiber completely shitfaced
	 * 81-90: Extremely high alcohol content - toxin damage, passing out
	 * 91-100: Dangerously toxic - brain damage, probable liver failure.
	 * 101 and beyond: Lethally toxic - Swift death.
	*/
	var/boozepwr = 65 //Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning.

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/L, metabolism)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
			C.drunkenness = max((C.drunkenness + (sqrt(volume) * boozepwr * ALCOHOL_RATE)), 0) //Volume, power, and server alcohol rate effect how quickly one gets drunk.
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			var/datum/internal_organ/liver/O = H.get_organ_slot(ORGAN_SLOT_LIVER)
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
		to_chat(usr, span_warning("The [name] dissolves the ink on the paper."))
	if(istype(O,/obj/item/book))
		if(volume > 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			to_chat(usr, span_warning("The [name] dissolves the ink on the book."))
		else
			to_chat(usr, span_warning("[O]'s ink is smeared by [name], but doesn't wash away!"))

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/L, method = TOUCH, volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(method in list(TOUCH, VAPOR, PATCH))
		L.adjust_fire_stacks(round(volume * 0.65))

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25
	taste_description = "mild carbonated malt"

/datum/reagent/consumable/ethanol/nt_beer
	name = "Aspen Beer"
	description = "Pretty good when you get past the fact that it tastes like piss. Canned by the Nanotrasen Corporation."
	color = "#ffcc66"
	boozepwr = 5 //Space Europeans hate it
	taste_description = "dish water"

/datum/reagent/consumable/ethanol/beer/light
	name = "Light Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety has reduced calorie and alcohol content."
	boozepwr = 5 //Space Europeans hate it
	taste_description = "dish water"

/datum/reagent/consumable/ethanol/beer/maltliquor
	name = "Malt Liquor"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is stronger than usual, super cheap, and super terrible."
	boozepwr = 35
	taste_description = "sweet corn beer and the hood life"

/datum/reagent/consumable/ethanol/beer/green
	name = "Green Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is dyed a festive green."
	color = "#A8E61D"
	overdose_threshold = 55 //More than a glass
	taste_description = "green piss water"

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "spiked latte"
	boozepwr = 45

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/L, metabolism)
	L.dizzy(-4)
	L.adjustDrowsyness(-2)
	L.AdjustSleeping(-6 SECONDS)
	L.jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67,
	taste_description = "molasses"
	boozepwr = 75

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 80
	taste_description = "exquisite amber"

/datum/reagent/consumable/ethanol/whiskey/kong
	name = "Kong"
	description = "Makes You Go Ape!&#174;"
	color = "#332100" // rgb: 51, 33, 0
	taste_description = "the grip of a giant ape"

/datum/reagent/consumable/ethanol/whiskey/candycorn
	name = "Candy Corn Liquor"
	description = "Like they drank in 2D speakeasies."
	color = "#ccb800" // rgb: 204, 184, 0
	taste_description = "pancake syrup"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	boozepwr = 80
	nutriment_factor = 0.5 * FOOD_METABOLISM
	taste_description = "jitters and death"
	adj_temp = 5
	targ_temp = 305
	trait_flags = TACHYCARDIC

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/L, metabolism)
	L.adjustDrowsyness(-7)
	L.AdjustSleeping(-80 SECONDS)
	L.jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "grain alcohol"
	boozepwr = 65
	default_container = /obj/item/reagent_containers/cup/glass/bottle/vodka

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	boozepwr = 15
	nutriment_factor = 1 * FOOD_METABOLISM
	taste_description = "desperation and lactate"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	taste_description = "dryness"
	boozepwr = 10
	druggy = 50

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "pine"
	boozepwr = 45
	taste_description = "an alcoholic christmas tree"

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	description = "Yohoho and all that."
	color = "#c9c07e" // rgb: 201,192,126
	taste_description = "spiked butterscotch"
	boozepwr = 60
	default_container = /obj/item/reagent_containers/cup/glass/bottle/rum

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	description = "A strong and mildly flavoured, Mexican produced spirit. Feeling thirsty, hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 70
	taste_description = "paint stripper"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	taste_description = "dry alcohol"
	boozepwr = 45

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	description = "A premium alcoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 35
	taste_description = "bitter sweetness"
	default_container = /obj/item/reagent_containers/cup/glass/bottle/wine

/datum/reagent/consumable/ethanol/lizardwine
	name = "Lizard Wine"
	description = "An alcoholic beverage from Space China, made by infusing lizard tails in ethanol."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 45
	taste_description = "scaley sweetness"

/datum/reagent/consumable/ethanol/grappa
	name = "Grappa"
	description = "A fine Italian brandy, for when regular wine just isn't alcoholic enough for you."
	color = "#F8EBF1"
	boozepwr = 60
	taste_description = "classy bitter sweetness"

/datum/reagent/consumable/ethanol/amaretto
	name = "Amaretto"
	description = "A gentle drink that carries a sweet aroma."
	color = "#E17600"
	boozepwr = 25
	taste_description = "fruity and nutty sweetness"

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	description = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	boozepwr = 75
	taste_description = "smooth and french"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	description = "A powerful alcoholic drink. Rumored to cause hallucinations but does not."
	color = "#33EE00" // rgb: 51, 238, 0
	taste_description = "death and licorice"
	boozepwr = 80 //Very strong even by default

/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/L, metabolism)
	if(prob(10))
		L.hallucination += 4 //Reference to the urban myth
	return ..()

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	description = "Either someone's failure at cocktail making or attempt in alcohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "pure resignation"
	boozepwr = 100

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	description = "A dark alcoholic beverage made with malted barley and yeast."
	color = "#976063" // rgb: 151,96,99
	taste_description = "hearty barley ale"
	boozepwr = 65

/datum/reagent/consumable/ethanol/pwine
	name = "Poison Wine"
	description = "A potent wine with hallucinogenic properties, popular among high personalities and villains."
	color = "#000000" // rgb: 0, 0, 0 SHOCKER
	taste_description = "evil velvet"
	boozepwr = 40

/datum/reagent/consumable/ethanol/pwine/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 19)
			L.jitter(2)
			L.hallucination = max(L.hallucination, 3)
			if(prob(1))
				L.emote(pick("twitch","giggle"))
		if(20 to 59)
			L.set_timed_status_effect(4 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
			L.hallucination = max(L.hallucination, 10)
			L.jitter(3)
			L.dizzy(2)
			L.set_drugginess(10)
			if(prob(5))
				L.emote(pick("twitch","giggle"))
		if(60 to 119)
			L.set_timed_status_effect(4 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
			L.hallucination = max(L.hallucination, 60)
			L.jitter(4)
			L.dizzy(4)
			L.set_drugginess(30)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
			if(prob(30))
				L.adjustToxLoss(0.5)
		if(120 to 199)
			L.set_timed_status_effect(4 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
			L.hallucination = max(L.hallucination, 60)
			L.jitter(4)
			L.dizzy(4)
			L.druggy = max(L.druggy, 60)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
			if(prob(30))
				L.adjustToxLoss(1)
			if(prob(5))
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					var/datum/internal_organ/heart/E = H.get_organ_slot(ORGAN_SLOT_HEART)
					if(istype(E))
						E.take_damage(2)
		if(200 to INFINITY)
			L.set_timed_status_effect(5 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)
			L.adjustToxLoss(1)
			L.hallucination = max(L.hallucination, 60)
			L.jitter(4)
			L.dizzy(4)
			L.druggy = max(L.druggy, 60)
			if(ishuman(L) && prob(10))
				var/mob/living/carbon/human/H = L
				var/datum/internal_organ/heart/E = H.get_organ_slot(ORGAN_SLOT_HEART)
				if(istype(E))
					if(H.species.species_flags ~! NO_PAIN)
						to_chat(H, span_danger("You clutch for a moment as you feel a scorching pain covering your abdomen!"))
						H.Stun(6 SECONDS)
					E.take_damage(20)
	return ..()

/datum/reagent/consumable/ethanol/davenport
	name = "Davenport Rye"
	description = "An expensive alcohol with a distinct flavor"
	color = "#ffcc66"
	taste_description = "oil, whiskey, salt, rosemary mixed togheter" // Insert reference here.
	boozepwr = 50

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#FFFF91" // rgb: 255, 255, 145
	taste_description = "burning cinnamon"
	boozepwr = 25

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	taste_description = "metallic and expensive"
	boozepwr = 60

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	description = "An all time classic, mild cocktail."
	color = "#cae7ec" // rgb: 202,231,236
	taste_description = "mild and tart"
	boozepwr = 25

/datum/reagent/consumable/ethanol/rum_coke
	name = "Rum and Coke"
	description = "Rum, mixed with cola."
	taste_description = "cola"
	boozepwr = 40
	color = "#3E1B00"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	description = "Viva la revolucion! Viva Cuba Libre!"
	color = "#3E1B00" // rgb: 62, 27, 0
	taste_description = "a refreshing marriage of citrus and rum"
	boozepwr = 50

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	taste_description = "cola"
	boozepwr = 70

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#cddbac" // rgb: 205,219,172
	taste_description = "dry class"
	boozepwr = 60

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#cddcad" // rgb: 205,220,173
	taste_description = "shaken, not stirred"
	boozepwr = 65

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	taste_description = "bitter cream"
	boozepwr = 50

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	taste_description = "oranges"
	boozepwr = 55

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	description = "Ewww..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	taste_description = "sweet 'n creamy"
	boozepwr = 45

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#bf707c" // rgb: 191,112,124
	taste_description = "tomatoes with a hint of lime and liquid murder"
	boozepwr = 55

/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/L, metabolism)
	if(L.blood_volume < BLOOD_VOLUME_NORMAL)
		L.adjust_blood_volume(0.3) //Bloody Mary slowly restores blood loss.
	return ..()

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	description = "It's just as effective as Dutch-Courage!"
	color = "#a79f98" // rgb: 167,159,152
	taste_description = "alcoholic bravery"
	boozepwr = 60

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	color = "#FFE48C" // rgb: 255, 228, 140
	boozepwr = 45
	taste_description = "oranges with a hint of pomegranate"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	color = "#8880a8" // rgb: 136,128,168
	taste_description = "spicy toxins"
	boozepwr = 25
	targ_temp = 330
	adj_temp = 15

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	description = "Drink this and prepare for the LAW."
	color = COLOR_OLIVE // rgb: 128,128,0
	taste_description = "JUSTICE"
	boozepwr = 90 //THE FIST OF THE LAW IS STRONG AND HARD

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/L, metabolism)
	L.Stun(4 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish?"
	color = "#e3d0b2" // rgb: 227,208,178
	taste_description = "creamy alcohol"
	boozepwr = 50

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#815336" // rgb: 129,83,54
	taste_description = "hair on your chest and your chin"
	boozepwr = 100 //For the manly only

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#ff6633" // rgb: 255,102,51
	taste_description = "a mixture of cola and alcohol"
	boozepwr = 35

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha) (like water)
	taste_description = "bitterness"
	boozepwr = 95

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#8f1733" // rgb: 143,23,51
	taste_description = "angry and irish"
	boozepwr = 85

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#874010" // rgb: 135,64,16
	taste_description = "giving up on the day"
	boozepwr = 35

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	taste_description = "dry and salty"
	boozepwr = 35

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	taste_description = "bitterness"
	boozepwr = 70

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#ff3300" // rgb: 255,51,0
	taste_description = "mild dryness"
	boozepwr = 30

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = COLOR_MOSTLY_PURE_RED
	taste_description = "death, the destroyer of worlds"
	boozepwr = 45
	druggy = 30

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	description = "For the more refined griffon."
	color = "#ffcc33" // rgb: 255,204,51
	taste_description = "soda"
	boozepwr = 70

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	description = "The ultimate refreshment. Not what it sounds like."
	color = "#30f0f8" // rgb: 48,240,248
	taste_description = "Jack Frost's piss"
	boozepwr = 35
	targ_temp = 330
	adj_temp = 20

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	description = "Barefoot and pregnant."
	color = "#fc5acc" // rgb: 252,90,204
	taste_description = "creamy berries"
	boozepwr = 45

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	description = "A cold refreshment."
	color = COLOR_WHITE // rgb: 255, 255, 255
	taste_description = "refreshing cold"
	boozepwr = 35

/datum/reagent/consumable/ethanol/melonliquor
	name = "Melon Liquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	color = "#138808" // rgb: 19, 136, 8
	boozepwr = 60
	taste_description = "fruity alcohol"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	description = "Exotically blue, fruity drink, distilled from oranges."
	color = "#0000CD" // rgb: 0, 0, 205
	boozepwr = 50
	taste_description = "oranges"

/datum/reagent/consumable/ethanol/suidream
	name = "Sui Dream"
	description = "Comprised of: White soda, blue curacao, melon liquor."
	color = "#00A86B" // rgb: 0, 168, 107
	taste_description = "fruity soda"
	boozepwr = 10

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demons Blood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	taste_description = "sweet tasting iron"
	boozepwr = 75

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devil's Kiss"
	description = "Creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	taste_description = "bitter iron"
	boozepwr = 70

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	description = "For when a gin and tonic isn't Russian enough."
	color = "#0064C8" // rgb: 0, 100, 200
	taste_description = "tart bitterness"
	boozepwr = 70

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#ffffcc" // rgb: 255,255,204
	taste_description = "dry, tart lemons"
	boozepwr = 45

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama mama"
	description = "A tropical cocktail with a complex blend of flavors."
	color = "#FF7F3B" // rgb: 255, 127, 59
	taste_description = "pineapple, coconut, and a hint of coffee"
	boozepwr = 35

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	description = "A blue-space beverage!"
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "concentrated matter"
	boozepwr = 35

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#d8d5ae" // rgb: 216,213,174
	taste_description = "hot and spice"
	boozepwr = 70
	targ_temp = 360
	adj_temp = 50

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	description = "The true Viking drink! Even though it has a strange red color."
	color = "#C73C00" // rgb: 199, 60, 0
	taste_description = "sweet and salty alcohol"
	boozepwr = 51

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	description = "A Viking drink, though a cheap one."
	color = "#e0c058" // rgb: 224,192,88
	taste_description = "sweet, sweet alcohol"
	boozepwr = 30
	nutriment_factor = 0.5

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "refreshingly cold"
	boozepwr = 15
	targ_temp = 270
	adj_temp = 20

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	description = "Watered-down rum, Nanotrasen approves!"
	color = "#e0e058" // rgb: 224,224,88
	taste_description = "a poor excuse for alcohol"
	boozepwr = 1

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	description = "So very, very, very good."
	color = "#f8f800" // rgb: 248,248,0
	taste_description = "sweet 'n creamy"
	boozepwr = 35

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	description = "A nice, strangely named drink."
	color = "#c8f860" // rgb: 200,248,96
	taste_description = "lemons"
	boozepwr = 40

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	description = "A drink made from your allies. Not as sweet as those made from your enemies."
	color = "#60f8f8" // rgb: 96,248,248
	taste_description = "bitter yet free"
	boozepwr = 45

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	color = "#365000" // rgb: 54, 80, 0
	taste_description = "stomach acid"
	boozepwr = 70

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	description = "Official drink of the NanoTrasen Gun-Club!"
	color = "#e0e058" // rgb: 224,224,88
	taste_description = "dark and metallic"
	boozepwr = 35

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "your brain coming out your nose"
	boozepwr = 50

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	description = "Mmm, tastes like the free Irish state."
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "the spirit of Ireland"
	boozepwr = 25

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	description = "Tastes like terrorism!"
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "purified antagonism"
	boozepwr = 90

/datum/reagent/consumable/ethanol/hiveminderaser
	name = "Hivemind Eraser"
	description = "A vessel of pure flavor."
	color = "#FF80FC" // rgb: 255, 128, 252
	boozepwr = 40
	taste_description = "psychic links"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	description = "The surprise is, it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "tartness and bananas"
	boozepwr = 35

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 0.5
	color = "#2E6671" // rgb: 46, 102, 113
	taste_description = "a beach"
	boozepwr = 65

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Honk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 0.5
	color = "#FFFF91" // rgb: 255, 255, 140
	taste_description = "a bad joke"
	boozepwr = 60

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1
	color = "#a8a8a8" // rgb: 168,168,168
	boozepwr = 59 //Proof that clowns are better than mimes right here
	taste_description = "a pencil eraser"

/datum/reagent/consumable/ethanol/silencer/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 50)
			L.dizzy(5)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
		if(51 to 100)
			L.dizzy(5)
			L.adjust_timed_status_effect(10 SECONDS, /datum/status_effect/speech/stutter)
			if(prob(20))
				L.AdjustConfused(6 SECONDS)
		if(101 to INFINITY)
			L.dizzy(6)
			L.adjust_timed_status_effect(10 SECONDS, /datum/status_effect/speech/stutter)
			if(prob(20))
				L.AdjustConfused(10 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	description = "A weird mix of whiskey and blumpkin juice."
	color = "#1EA0FF" // rgb: 30,160,255
	boozepwr = 50
	taste_description = "molasses and a mouthful of pool water"

/datum/reagent/consumable/ethanol/whiskey_sour //Requested since we had whiskey cola and soda but not sour.
	name = "Whiskey Sour"
	description = "Lemon juice/whiskey/sugar mixture. Moderate alcohol content."
	color = rgb(255, 201, 49)
	boozepwr = 35
	taste_description = "sour lemons"

/datum/reagent/consumable/ethanol/hcider
	name = "Hard Cider"
	description = "Apple juice, for adults."
	color = "#CD6839"
	nutriment_factor = 0.5
	boozepwr = 25
	taste_description = "the season that <i>falls</i> between summer and winter"

/datum/reagent/consumable/ethanol/fetching_fizz //A reference to one of my favorite games of all time. Pulls nearby ores to the imbiber!
	name = "Fetching Fizz"
	description = "Whiskey sour/iron/uranium mixture resulting in a highly magnetic slurry. Mild alcohol content." //Requires no alcohol to make but has alcohol anyway because ~magic~
	color = rgb(255, 91, 15)
	boozepwr = 10
	custom_metabolism = 0.1 * FOOD_METABOLISM
	taste_description = "charged metal" // the same as teslium, honk honk.

//Another reference. Heals those in critical condition extremely quickly.
/datum/reagent/consumable/ethanol/hearty_punch
	name = "Hearty Punch"
	description = "Brave bull/syndicate bomb/absinthe mixture resulting in an energizing beverage. Mild alcohol content."
	color = rgb(140, 0, 0)
	boozepwr = 90
	custom_metabolism = 0.4 * FOOD_METABOLISM
	taste_description = "bravado in the face of disaster"

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	description = "Unidentifiable mixture. Unmeasurably high alcohol content."
	color = rgb(51, 19, 3) //Sickly brown
	boozepwr = 300 //I warned you
	taste_description = "a wall of bricks"

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	boozepwr = 0 //custom drunk effect
	taste_description = "da bomb"

/datum/reagent/consumable/ethanol/atomicbomb/on_mob_life(mob/living/L, metabolism)
	L.set_drugginess(50)
	L.AdjustConfused(4 SECONDS)
	L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk)
	switch(current_cycle)
		if(40 to 49)
			L.adjustDrowsyness(2)
		if(51 to 200)
			L.Sleeping(6 SECONDS)
		if(201 to INFINITY)
			L.Sleeping(6 SECONDS)
			L.adjustToxLoss(2)
	return ..()

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#9cc8b4" // rgb: 156,200,180
	boozepwr = 0 //custom drunk effect
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"
	adj_dizzy = 6
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"

/datum/reagent/consumable/ethanol/gargle_blaster/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(15 to 45)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk)
			L.jitter(2)
		if(46 to 65)
			L.AdjustConfused(4 SECONDS)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk)
			L.jitter(3)
		if(66 to 199)
			L.set_drugginess(50)
			if(prob(10))
				L.vomit()
			L.jitter(4)
			if(prob(5))
				L.Sleeping(16 SECONDS)
		if(200 to INFINITY)
			L.set_drugginess(50)
			L.AdjustConfused(4 SECONDS)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk)
			L.adjustToxLoss(2)
			L.jitter(5)
			if(prob(10))
				L.vomit()
			L.Sleeping(6 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	boozepwr = 50
	taste_description = "a numbing sensation"
	adj_dizzy = 6
	trait_flags = BRADYCARDICS

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/L, metabolism)
	L.Paralyze(6 SECONDS)
	switch(current_cycle)
		if(15 to 35)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
		if(36 to 55)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
			L.AdjustConfused(4 SECONDS)
		if(56 to 200)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
			L.AdjustConfused(4 SECONDS)
			L.set_drugginess(30)
		if(201 to INFINITY)
			L.set_drugginess(30)
			L.adjustToxLoss(2)
	return ..()

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	description = "You just don't get it maaaan."
	color = "#b16e8b" // rgb: 177,110,139
	nutriment_factor = 0
	boozepwr = 0 //custom drunk effect
	taste_description = "giving peace a chance"

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/L, metabolism)
	L.set_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk, only_if_higher = TRUE)
	switch(current_cycle)
		if(1 to 5)
			L.dizzy(10)
			L.set_drugginess(30)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
		if(6 to 10)
			L.dizzy(20)
			L.jitter(20)
			L.set_drugginess(45)
			if(prob(20))
				L.emote(pick("twitch","giggle"))
		if(11 to 200)
			L.dizzy(40)
			L.jitter(40)
			L.set_drugginess(60)
			if(prob(30))
				L.emote(pick("twitch","giggle"))
		if(201 to INFINITY)
			L.adjust_timed_status_effect(1 SECONDS, /datum/status_effect/speech/stutter)
			L.jitter(60)
			L.dizzy(60)
			L.set_drugginess(75)
			if(prob(40))
				L.emote(pick("twitch","giggle"))
			L.adjustToxLoss(0.6)
	return ..()

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	description = "For enjoying the most wonderful time of the year."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 1
	boozepwr = 1
	taste_description = "custard and alcohol"

/datum/reagent/consumable/ethanol/dreadnog
	name = "Dreadnog"
	description = "For suffering during a period of joy."
	color = "#abb862" // rgb: 252, 253, 198
	nutriment_factor = 1.5 * REAGENTS_METABOLISM
	boozepwr = 1
	taste_description = "custard and alcohol"

/datum/reagent/consumable/ethanol/narsour
	name = "Nar'Sour"
	description = "Side effects include self-mutilation and hoarding plasteel."
	color = "#7D1717"
	boozepwr = 10
	taste_description = "bloody"

/datum/reagent/consumable/ethanol/triple_sec
	name = "Triple Sec"
	description = "A sweet and vibrant orange liqueur."
	color = "#ffcc66"
	boozepwr = 30
	taste_description = "a warm flowery orange taste which recalls the ocean air and summer wind of the caribbean"

/datum/reagent/consumable/ethanol/creme_de_menthe
	name = "Creme de Menthe"
	description = "A minty liqueur excellent for refreshing, cool drinks."
	color = "#00cc00"
	boozepwr = 20
	taste_description = "a minty, cool, and invigorating splash of cold streamwater"

/datum/reagent/consumable/ethanol/creme_de_cacao
	name = "Creme de Cacao"
	description = "A chocolatey liqueur excellent for adding dessert notes to beverages and bribing sororities."
	color = "#996633"
	boozepwr = 20
	taste_description = "a slick and aromatic hint of chocolates swirling in a bite of alcohol"

/datum/reagent/consumable/ethanol/creme_de_coconut
	name = "Creme de Coconut"
	description = "A coconut liqueur for smooth, creamy, tropical drinks."
	color = "#F7F0D0"
	boozepwr = 20
	taste_description = "a sweet milky flavor with notes of toasted sugar"

/datum/reagent/consumable/ethanol/quadruple_sec
	name = "Quadruple Sec"
	description = "Kicks just as hard as licking the power cell on a baton, but tastier."
	color = "#cc0000"
	boozepwr = 35
	taste_description = "an invigorating bitter freshness which suffuses your being; no enemy of the station will go unrobusted this day"

/datum/reagent/consumable/ethanol/quintuple_sec
	name = "Quintuple Sec"
	description = "Law, Order, Alcohol, and Police Brutality distilled into one single elixir of JUSTICE."
	color = "#ff3300"
	boozepwr = 55
	taste_description = "THE LAW"

/datum/reagent/consumable/ethanol/grasshopper
	name = "Grasshopper"
	description = "A fresh and sweet dessert shooter. Difficult to look manly while drinking this."
	color = "#00ff00"
	boozepwr = 25
	taste_description = "chocolate and mint dancing around your mouth"

/datum/reagent/consumable/ethanol/stinger
	name = "Stinger"
	description = "A snappy way to end the day."
	color = "#ccff99"
	boozepwr = 25
	taste_description = "a slap on the face in the best possible way"

/datum/reagent/consumable/ethanol/bastion_bourbon
	name = "Bastion Bourbon"
	description = "Soothing hot herbal brew with restorative properties. Hints of citrus and berry flavors."
	color = COLOR_CYAN
	boozepwr = 30
	taste_description = "hot herbal brew with a hint of fruit"
	custom_metabolism = 2 * FOOD_METABOLISM

/datum/reagent/consumable/ethanol/squirt_cider
	name = "Squirt Cider"
	description = "Fermented squirt extract with a nose of stale bread and ocean water. Whatever a squirt is."
	color = COLOR_RED
	boozepwr = 40
	taste_description = "stale bread with a staler aftertaste"
	nutriment_factor = 1

/datum/reagent/consumable/ethanol/fringe_weaver
	name = "Fringe Weaver"
	description = "Bubbly, classy, and undoubtedly strong - a Glitch City classic."
	color = "#FFEAC4"
	boozepwr = 90 //classy hooch, essentially, but lower pwr to make up for slightly easier access
	taste_description = "ethylic alcohol with a hint of sugar"

/datum/reagent/consumable/ethanol/sugar_rush
	name = "Sugar Rush"
	description = "Sweet, light, and fruity - as girly as it gets."
	color = "#FF226C"
	boozepwr = 10
	taste_description = "your arteries clogging with sugar"
	nutriment_factor = 1

/datum/reagent/consumable/ethanol/crevice_spike
	name = "Crevice Spike"
	description = "Sour, bitter, and smashingly sobering."
	color = "#5BD231"
	boozepwr = -10 //sobers you up - ideally, one would drink to get hit with brute damage now to avoid alcohol problems later
	taste_description = "a bitter SPIKE with a sour aftertaste"

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	description = "A sweet rice wine of questionable legality and extreme potency."
	color = "#DDDDDD"
	taste_description = "sweet rice wine"
	boozepwr = 70

/datum/reagent/consumable/ethanol/peppermint_patty
	name = "Peppermint Patty"
	description = "This lightly alcoholic drink combines the benefits of menthol and cocoa."
	color = "#45ca7a"
	taste_description = "mint and chocolate"
	boozepwr = 25

/datum/reagent/consumable/ethanol/alexander
	name = "Alexander"
	description = "Named after a Greek hero, this mix is said to embolden a user's shield as if they were in a phalanx."
	color = "#F5E9D3"
	boozepwr = 50
	taste_description = "bitter, creamy cacao"

/datum/reagent/consumable/ethanol/amaretto_alexander
	name = "Amaretto Alexander"
	description = "A weaker version of the Alexander, what it lacks in strength it makes up for in flavor."
	color = "#DBD5AE"
	boozepwr = 35
	taste_description = "sweet, creamy cacao"

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	description = "The one ride you'll gladly give up the wheel for."
	color = "#FFC55B"
	boozepwr = 45
	taste_description = "delicious freedom"

/datum/reagent/consumable/ethanol/between_the_sheets
	name = "Between the Sheets"
	description = "A provocatively named classic. Funny enough, doctors recommend drinking it before taking a nap while underneath bedsheets."
	color = "#F4C35A"
	boozepwr = 55
	taste_description = "seduction"

/datum/reagent/consumable/ethanol/kamikaze
	name = "Kamikaze"
	description = "Divinely windy."
	color = "#EEF191"
	boozepwr = 60
	taste_description = "divine windiness"

/datum/reagent/consumable/ethanol/mojito
	name = "Mojito"
	description = "A drink that looks as refreshing as it tastes."
	color = "#DFFAD9"
	boozepwr = 30
	taste_description = "refreshing mint"

/datum/reagent/consumable/ethanol/moscow_mule
	name = "Moscow Mule"
	description = "A chilly drink that reminds you of the Derelict."
	color = "#EEF1AA"
	boozepwr = 30
	taste_description = "refreshing spiciness"

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	description = "An incredibly bitter herbal liqueur used as a digestif."
	color = "#1B2E24" // rgb: 27, 46, 36
	boozepwr = 80
	taste_description = "utter bitterness"

/datum/reagent/consumable/ethanol/fernet_cola
	name = "Fernet Cola"
	description = "A very popular and bittersweet digestif, ideal after a heavy meal. Best served on a sawed-off cola bottle as per tradition."
	color = "#390600" // rgb: 57, 6,
	boozepwr = 25
	taste_description = "sweet relief"

/datum/reagent/consumable/ethanol/fanciulli
	name = "Fanciulli"
	description = "What if the Manhattan cocktail ACTUALLY used a bitter herb liquour? Helps you sober up." //also causes a bit of stamina damage to symbolize the afterdrink lazyness
	color = "#CA933F" // rgb: 202, 147, 63
	boozepwr = -10
	taste_description = "a sweet sobering mix"

/datum/reagent/consumable/ethanol/branca_menta
	name = "Branca Menta"
	description = "A refreshing mixture of bitter Fernet with mint creme liquour."
	color = "#4B5746" // rgb: 75, 87, 70
	boozepwr = 35
	taste_description = "a bitter freshness"

/datum/reagent/consumable/ethanol/blank_paper
	name = "Blank Paper"
	description = "A bubbling glass of blank paper. Just looking at it makes you feel fresh."
	nutriment_factor = 0.5
	color = "#DCDCDC" // rgb: 220, 220, 220
	boozepwr = 20
	taste_description = "bubbling possibility"

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Fruit Wine"
	description = "A wine made from grown plants."
	color = COLOR_WHITE
	boozepwr = 35
	taste_description = "bad coding"
	var/list/names = list("null fruit" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("bad coding" = 1) //List of tastes. See above.

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	if(!data)
		return

	src.data = data
	names = data["names"]
	tastes = data["tastes"]
	boozepwr = data["boozepwr"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	..()
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	boozepwr *= oldvolume
	var/newzepwr = data["boozepwr"] * amount
	boozepwr += newzepwr
	boozepwr /= volume //Blending boozepwr to volume.
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	// BYOND's compiler fails to catch non-consts in a ranged switch case, and it causes incorrect behavior. So this needs to explicitly be a constant.
	var/const/minimum_percent = 0.15 //Percentages measured between 0 and 1.
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	for(var/taste in tastes)
		switch(tastes[taste])
			if(minimum_percent*2 to INFINITY)
				primary_tastes += taste
			if(minimum_percent to minimum_percent*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "Wine"
	else
		name = "Mixed [names_in_order[1]] Wine"

	var/alcohol_description
	switch(boozepwr)
		if(120 to INFINITY)
			alcohol_description = "suicidally strong"
		if(90 to 120)
			alcohol_description = "rather strong"
		if(70 to 90)
			alcohol_description = "strong"
		if(40 to 70)
			alcohol_description = "rich"
		if(20 to 40)
			alcohol_description = "mild"
		if(0 to 20)
			alcohol_description = "sweet"
		else
			alcohol_description = "watery" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "other plants"
	var/fruit_list = english_list(fruits)
	description = "A [alcohol_description] wine brewed from [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] alcohol")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", with a hint of "
		flavor += english_list(secondary_tastes)
	taste_description = flavor

/datum/reagent/consumable/ethanol/champagne //How the hell did we not have champagne already!?
	name = "Champagne"
	description = "A sparkling wine known for its ability to strike fast and hard."
	color = "#ffffc1"
	boozepwr = 40
	taste_description = "auspicious occasions and bad decisions"

/datum/reagent/consumable/ethanol/wizz_fizz
	name = "Wizz Fizz"
	description = "A magical potion, fizzy and wild! However the taste, you will find, is quite mild."
	color = "#4235d0" //Just pretend that the triple-sec was blue curacao.
	boozepwr = 50
	taste_description = "friendship! It is magic, after all"

/datum/reagent/consumable/ethanol/bug_spray
	name = "Bug Spray"
	description = "A harsh, acrid, bitter drink, for those who need something to brace themselves."
	color = "#33ff33"
	boozepwr = 50
	taste_description = "the pain of ten thousand slain mosquitos"

/datum/reagent/consumable/ethanol/applejack
	name = "Applejack"
	description = "The perfect beverage for when you feel the need to horse around."
	color = "#ff6633"
	boozepwr = 20
	taste_description = "an honest day's work at the orchard"

/datum/reagent/consumable/ethanol/jack_rose
	name = "Jack Rose"
	description = "A light cocktail perfect for sipping with a slice of pie."
	color = "#ff6633"
	boozepwr = 15
	taste_description = "a sweet and sour slice of apple"

/datum/reagent/consumable/ethanol/turbo
	name = "Turbo"
	description = "A turbulent cocktail associated with outlaw hoverbike racing. Not for the faint of heart."
	color = "#e94c3a"
	boozepwr = 85
	taste_description = "the outlaw spirit"

/datum/reagent/consumable/ethanol/old_timer
	name = "Old Timer"
	description = "An archaic potation enjoyed by old coots of all ages."
	color = "#996835"
	boozepwr = 35
	taste_description = "simpler times"

/datum/reagent/consumable/ethanol/rubberneck
	name = "Rubberneck"
	description = "A quality rubberneck should not contain any gross natural ingredients."
	color = "#ffe65b"
	boozepwr = 60
	taste_description = "artifical fruityness"

/datum/reagent/consumable/ethanol/duplex
	name = "Duplex"
	description = "An inseparable combination of two fruity drinks."
	color = "#50e5cf"
	boozepwr = 25
	taste_description = "green apples and blue raspberries"

/datum/reagent/consumable/ethanol/trappist
	name = "Trappist Beer"
	description = "A strong dark ale brewed by space-monks."
	color = "#390c00"
	boozepwr = 40
	taste_description = "dried plums and malt"

/datum/reagent/consumable/ethanol/blazaam
	name = "Blazaam"
	description = "A strange drink that few people seem to remember existing. Doubles as a Berenstain remover."
	boozepwr = 70
	taste_description = "alternate realities"

/datum/reagent/consumable/ethanol/planet_cracker
	name = "Planet Cracker"
	description = "This jubilant drink celebrates humanity's triumph over the alien menace. May be offensive to non-human crewmembers."
	boozepwr = 50
	taste_description = "triumph with a hint of bitterness"

/datum/reagent/consumable/ethanol/mauna_loa
	name = "Mauna Loa"
	description = "Extremely hot; not for the faint of heart!"
	boozepwr = 40
	color = "#fe8308" // 254, 131, 8
	taste_description = "fiery, with an aftertaste of burnt flesh"

/datum/reagent/consumable/ethanol/painkiller
	name = "Painkiller"
	description = "Dulls your pain. Your emotional pain, that is."
	boozepwr = 20
	color = "#EAD677"
	taste_description = "sugary tartness"

/datum/reagent/consumable/ethanol/pina_colada
	name = "Pina Colada"
	description = "A fresh pineapple drink with coconut rum. Yum."
	boozepwr = 40
	color = "#FFF1B2"
	taste_description = "pineapple, coconut, and a hint of the ocean"

/datum/reagent/consumable/ethanol/pina_olivada
	name = "Piña Olivada"
	description = "An oddly designed concoction of olive oil and pineapple juice."
	boozepwr = 20 // the oil coats your gastrointestinal tract, meaning you can't absorb as much alcohol. horrifying
	color = "#493c00"
	taste_description = "a horrible emulsion of pineapple and olive oil"

/datum/reagent/consumable/ethanol/pruno // pruno mix is in drink_reagents
	name = "Pruno"
	color = "#E78108"
	description = "Fermented prison wine made from fruit, sugar, and despair. Security loves to confiscate this, which is the only kind thing Security has ever done."
	boozepwr = 85
	taste_description = "your tastebuds being individually shanked"

/datum/reagent/consumable/ethanol/ginger_amaretto
	name = "Ginger Amaretto"
	description = "A delightfully simple cocktail that pleases the senses."
	boozepwr = 30
	color = "#EFB42A"
	taste_description = "sweetness followed by a soft sourness and warmth"

/datum/reagent/consumable/ethanol/godfather
	name = "Godfather"
	description = "A rough cocktail with illegal connections."
	boozepwr = 50
	color = "#E68F00"
	taste_description = "a delightful softened punch"

/datum/reagent/consumable/ethanol/godmother
	name = "Godmother"
	description = "A twist on a classic, liked more by mature women."
	boozepwr = 50
	color = "#E68F00"
	taste_description = "sweetness and a zesty twist"

/datum/reagent/consumable/ethanol/kortara
	name = "Kortara"
	description = "A sweet, milky nut-based drink enjoyed on Tizira. Frequently mixed with fruit juices and cocoa for extra refreshment."
	boozepwr = 25
	color = "#EEC39A"
	taste_description = "sweet nectar"

/datum/reagent/consumable/ethanol/sea_breeze
	name = "Sea Breeze"
	description = "Light and refreshing with a mint and cocoa hit- like mint choc chip ice cream you can drink!"
	boozepwr = 15
	color = "#CFFFE5"
	taste_description = "mint choc chip"

/datum/reagent/consumable/ethanol/white_tiziran
	name = "White Tiziran"
	description = "A mix of vodka and kortara. The Lizard imbibes."
	boozepwr = 65
	color = "#A68340"
	taste_description = "strikes and gutters"

/datum/reagent/consumable/ethanol/drunken_espatier
	name = "Drunken Espatier"
	description = "Look, if you had to get into a shootout in the cold vacuum of space, you'd want to be drunk too."
	boozepwr = 65
	color = "#A68340"
	taste_description = "sorrow"

/datum/reagent/consumable/ethanol/protein_blend
	name = "Protein Blend"
	description = "A vile blend of protein, pure grain alcohol, korta flour, and blood. Useful for bulking up, if you can keep it down."
	boozepwr = 65
	color = "#FF5B69"
	taste_description = "regret"
	nutriment_factor = 1.5

/datum/reagent/consumable/ethanol/mushi_kombucha
	name = "Mushi Kombucha"
	description = "A popular summer beverage on Tizira, made from sweetened mushroom tea."
	boozepwr = 10
	color = "#C46400"
	taste_description = "sweet 'shrooms"

/datum/reagent/consumable/ethanol/triumphal_arch
	name = "Triumphal Arch"
	description = "A drink celebrating the Lizard Empire and its military victories. It's popular at bars on Unification Day."
	boozepwr = 60
	color = "#FFD700"
	taste_description = "victory"

/datum/reagent/consumable/ethanol/the_juice
	name = "The Juice"
	description = "Woah man, this like, feels familiar to you dude."
	color = "#4c14be"
	boozepwr = 50
	taste_description = "like, the future, man"

//a jacked up absinthe that causes hallucinations to the game master controller basically, used in smuggling objectives
/datum/reagent/consumable/ethanol/ritual_wine
	name = "Ritual Wine"
	description = "The dangerous, potent, alcoholic component of ritual wine."
	color = rgb(35, 231, 25)
	boozepwr = 90 //enjoy near death intoxication
	taste_description = "concentrated herbs"

//Moth Drinks
/datum/reagent/consumable/ethanol/curacao
	name = "Curaçao"
	description = "Made with laraha oranges, for an aromatic finish."
	boozepwr = 30
	color = "#1a5fa1"
	taste_description = "blue orange"

/datum/reagent/consumable/ethanol/navy_rum //IN THE NAVY
	name = "Navy Rum"
	description = "Rum as the finest sailors drink."
	boozepwr = 90 //the finest sailors are often drunk
	color = "#d8e8f0"
	taste_description = "a life on the waves"

/datum/reagent/consumable/ethanol/bitters //why do they call them bitters, anyway? they're more spicy than anything else
	name = "Andromeda Bitters"
	description = "A bartender's best friend, often used to lend a delicate spiciness to any drink. Produced in New Trinidad, now and forever."
	boozepwr = 70
	color = "#1c0000"
	taste_description = "spiced alcohol"

/datum/reagent/consumable/ethanol/admiralty //navy rum, vermouth, fernet
	name = "Admiralty"
	description = "A refined, bitter drink made with navy rum, vermouth and fernet."
	boozepwr = 100
	color = "#1F0001"
	taste_description = "haughty arrogance"

/datum/reagent/consumable/ethanol/long_haul //Rum, Curacao, Sugar, dash of bitters, lengthened with soda water
	name = "Long Haul"
	description = "A favourite amongst freighter pilots, unscrupulous smugglers, and nerf herders."
	boozepwr = 35
	color = "#003153"
	taste_description = "companionship"

/datum/reagent/consumable/ethanol/long_john_silver //navy rum, bitters, lemonade
	name = "Long John Silver"
	description = "A long drink of navy rum, bitters, and lemonade. Particularly popular aboard the Mothic Fleet as it's light on ration credits and heavy on flavour."
	boozepwr = 50
	color = "#c4b35c"
	taste_description = "rum and spices"

/datum/reagent/consumable/ethanol/tropical_storm //dark rum, pineapple juice, triple citrus, curacao
	name = "Tropical Storm"
	description = "A taste of the Caribbean in one glass."
	boozepwr = 40
	color = "#00bfa3"
	taste_description = "the tropics"

/datum/reagent/consumable/ethanol/dark_and_stormy //rum and ginger beer- simple and classic
	name = "Dark and Stormy"
	description = "A classic drink arriving to thunderous applause." //thank you, thank you, I'll be here forever
	boozepwr = 50
	color = "#8c5046"
	taste_description = "ginger and rum"

/datum/reagent/consumable/ethanol/salt_and_swell //navy rum, tochtause syrup, egg whites, dash of saline-glucose solution
	name = "Salt and Swell"
	description = "A bracing sour with an interesting salty taste."
	boozepwr = 60
	color = "#b4abd0"
	taste_description = "salt and spice"

/datum/reagent/consumable/ethanol/tiltaellen //yoghurt, salt, vinegar
	name = "Tiltällen"
	description = "A lightly fermented yoghurt drink with salt and a light dash of vinegar. Has a distinct sour cheesy flavour."
	boozepwr = 10
	color = "#F4EFE2"
	taste_description = "sour cheesy yoghurt"

/datum/reagent/consumable/ethanol/tich_toch
	name = "Tich Toch"
	description = "A mix of Tiltällen, Töchtaüse Syrup, and vodka. It's not exactly to everyones' tastes."
	boozepwr = 75
	color = "#b4abd0"
	taste_description = "spicy sour cheesy yoghurt"

/datum/reagent/consumable/ethanol/helianthus
	name = "Helianthus"
	description = "A dark yet radiant mixture of absinthe and hallucinogens. The choice of all true artists."
	boozepwr = 75
	color = "#fba914"
	taste_description = "golden memories"

/datum/reagent/consumable/ethanol/plumwine
	name = "Plum wine"
	description = "Plums turned into wine."
	color = "#8a0421"
	nutriment_factor = 0.5
	boozepwr = 20
	taste_description = "a poet's love and undoing"

/datum/reagent/consumable/ethanol/the_hat
	name = "The Hat"
	description = "A fancy drink, usually served in a man's hat."
	color = "#b90a5c"
	boozepwr = 80
	taste_description = "something perfumy"

/datum/reagent/consumable/ethanol/gin_garden
	name = "Gin Garden"
	description = "Excellent cooling alcoholic drink with not so ordinary taste."
	boozepwr = 20
	color = "#6cd87a"
	taste_description = "light gin with sweet ginger and cucumber"

/datum/reagent/consumable/ethanol/wine_voltaic
	name = "Voltaic Yellow Wine"
	description = "Electrically charged wine. Recharges ethereals, but also nontoxic."
	boozepwr = 30
	color = "#FFAA00"
	taste_description = "static with a hint of sweetness"

/datum/reagent/consumable/ethanol/telepole
	name = "Telepole"
	description = "A grounding rod in the form of a drink. Recharges ethereals, and gives temporary shock resistance."
	boozepwr = 50
	color = "#b300ff"
	taste_description = "the howling storm"

/datum/reagent/consumable/ethanol/pod_tesla
	name = "Pod Tesla"
	description = "Ride the lightning!  Recharges ethereals, suppresses phobias, and gives strong temporary shock resistance."
	boozepwr = 80
	color = "#00fbff"
	taste_description = "victory, with a hint of insanity"

// Welcome to the Blue Room Bar and Grill, home to Mars' finest cocktails
/datum/reagent/consumable/ethanol/rice_beer
	name = "Rice Beer"
	description = "A light, rice-based lagered beer popular on Mars. Considered a hate crime against Bavarians under the Reinheitsgebot Act of 1516."
	boozepwr = 5
	color = "#664300"
	taste_description = "mild carbonated malt"

/datum/reagent/consumable/ethanol/shochu
	name = "Shochu"
	description = "Also known as soju or baijiu, this drink is made from fermented rice, much like sake, but at a generally higher proof making it more similar to a true spirit."
	boozepwr = 45
	color = "#DDDDDD"
	taste_description = "stiff rice wine"

/datum/reagent/consumable/ethanol/yuyake
	name = "Yūyake"
	description = "A sweet melon liqueur from Japan. Considered a relic of the 1980s by most, it has some niche use in cocktail making, in part due to its bright red colour."
	boozepwr = 40
	color = "#F54040"
	taste_description = "sweet melon"

/datum/reagent/consumable/ethanol/coconut_rum
	name = "Coconut Rum"
	description = "The distilled essence of the beach. Tastes like bleach-blonde hair and suncream."
	boozepwr = 21
	color = "#F54040"
	taste_description = "coconut rum"

// Mixed Martian Drinks
/datum/reagent/consumable/ethanol/yuyakita
	name = "Yūyakita"
	description = "A hell unleashed upon the world by an unnamed patron."
	boozepwr = 40
	color = "#F54040"
	taste_description = "death"

/datum/reagent/consumable/ethanol/saibasan
	name = "Saibāsan"
	description = "A drink glorifying Cybersun's enduring business."
	boozepwr = 20
	color = "#F54040"
	taste_description = "betrayal"

/datum/reagent/consumable/ethanol/banzai_ti
	name = "Banzai-Tī"
	description = "A variation on the Long Island Iced Tea, made with yuyake for an alternative flavour that's hard to place."
	boozepwr = 40
	color = "#F54040"
	taste_description = "an asian twist on the liquor cabinet"

/datum/reagent/consumable/ethanol/sanraizusoda
	name = "Sanraizusōda"
	description = "It's a melon cream soda, except with alcohol- what's not to love? Well... possibly the hangovers."
	boozepwr = 6
	color = "#F54040"
	taste_description = "creamy melon soda"

/datum/reagent/consumable/ethanol/kumicho
	name = "Kumichō"
	description = "A new take on a classic cocktail, the Kumicho takes the Godfather formula and adds shochu for an Asian twist."
	boozepwr = 62
	color = "#F54040"
	taste_description = "rice and rye"

/datum/reagent/consumable/ethanol/red_planet
	name = "Red Planet"
	description = "Made in celebration of the Martian Concession, the Red Planet is based on the classic El Presidente, and is as patriotic as it is bright crimson."
	boozepwr = 45
	color = "#F54040"
	taste_description = "the spirit of freedom"

/datum/reagent/consumable/ethanol/amaterasu
	name = "Amaterasu"
	description = "Named for Amaterasu, the Shinto Goddess of the Sun, this cocktail embodies radiance- or something like that, anyway."
	boozepwr = 54 //1 part bitters is a lot
	color = "#F54040"
	taste_description = "sweet nectar of the gods"

/datum/reagent/consumable/ethanol/nekomimosa
	name = "Nekomimosa"
	description = "An overly sweet cocktail, made with melon liqueur, melon juice, and champagne (which contains no melon, unfortunately)."
	boozepwr = 17
	color = "#FF0C8D"
	taste_description = "MELON"

/datum/reagent/consumable/ethanol/sentai_quencha //melon soda, triple citrus, shochu, blue curacao
	name = "Sentai Quencha"
	description = "Based on the galaxy-famous \"Kyūkyoku no Ninja Pawā Sentai\", the Sentai Quencha is a favourite at anime conventions and weeb bars."
	boozepwr = 28
	color = "#F54040"
	taste_description = "ultimate ninja power"

/datum/reagent/consumable/ethanol/bosozoku
	name = "Bōsōzoku"
	description = "A simple summer drink from Mars, made from a 1:1 mix of rice beer and lemonade."
	boozepwr = 6
	color = "#F54040"
	taste_description = "bittersweet lemon"

/datum/reagent/consumable/ethanol/ersatzche
	name = "Ersatzche"
	description = "Sweet, bitter, spicy- that's a great combination."
	boozepwr = 6
	color = "#F54040"
	taste_description = "spicy pineapple beer"

/datum/reagent/consumable/ethanol/red_city_am
	name = "Red City AM"
	description = "A breakfast drink from New Osaka, for when you really need to get drunk at 9:30 in the morning in more socially acceptable manner than drinking bagwine on the bullet train. Not that you should drink this on the bullet train either."
	boozepwr = 5 //this thing is fucking disgusting and both less tasty and less alcoholic than a bloody mary. it is against god and nature
	color = "#F54040"
	taste_description = "breakfast in a glass"

/datum/reagent/consumable/ethanol/kings_ransom
	name = "King's Ransom"
	description = "A stiff, bitter drink with an odd name and odder recipe."
	boozepwr = 26
	color = "#F54040"
	taste_description = "bitter raspberry"

/datum/reagent/consumable/ethanol/four_bit
	name = "Four Bit"
	description = "A drink to power your typing hands."
	boozepwr = 26
	color = "#F54040"
	taste_description = "cyberspace"

/datum/reagent/consumable/ethanol/white_hawaiian //coconut milk, coconut rum, coffee liqueur
	name = "White Hawaiian"
	description = "A take on the classic White Russian, subbing out the classics for some tropical flavours."
	boozepwr = 16
	color = "#F54040"
	taste_description = "COCONUT"

/datum/reagent/consumable/ethanol/maui_sunrise //coconut rum, pineapple juice, yuyake, triple citrus, lemon-lime soda
	name = "Maui Sunrise"
	description = "Behind this drink's red facade lurks a sharp, complex flavour."
	boozepwr = 15
	color = "#F54040"
	taste_description = "sunrise over the pacific"

/datum/reagent/consumable/ethanol/imperial_mai_tai //navy rum, rum, lime, triple sec, korta nectar
	name = "Imperial Mai Tai"
	description = "For when orgeat is in short supply, do as the spacers do- make do and mend."
	boozepwr = 52
	color = "#F54040"
	taste_description = "spicy nutty rum"

/datum/reagent/consumable/ethanol/konococo_rumtini //todo: add espresso | coffee, coffee liqueur, coconut rum, sugar
	name = "Konococo Rumtini"
	description = "Coconut rum, coffee liqueur, and espresso- an odd combination, to be sure, but a welcomed one."
	boozepwr = 20
	color = "#F54040"
	taste_description = "coconut coffee"

/datum/reagent/consumable/ethanol/blue_hawaiian //pineapple juice, lemon juice, coconut rum, blue curacao
	name = "Blue Hawaiian"
	description = "Sweet, sharp and coconutty."
	boozepwr = 30
	color = "#F54040"
	taste_description = "the aloha state"

#undef ALCOHOL_EXPONENT
#undef ALCOHOL_THRESHOLD_MODIFIER
#undef ALCOHOL_RATE
