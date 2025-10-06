//Not to be confused with /obj/item/reagent_containers/cup/glass/bottle

/obj/item/reagent_containers/cup/bottle
	name = "bottle"
	desc = "A small bottle."
	icon_state = "bottle-1"
	fill_icon_state = "bottle-1"
	worn_icon_state = "bottle-1"
	possible_transfer_amounts = list(5, 10, 15, 25, 50)
	volume = 50
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

/obj/item/reagent_containers/cup/bottle/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle-1"
	update_appearance()

/obj/item/reagent_containers/cup/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle of toxins. Do not drink, it is poisonous."
	list_reagents = list(/datum/reagent/toxin = 30)

/obj/item/reagent_containers/cup/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide. Bitter almonds?"
	list_reagents = list(/datum/reagent/toxin/cyanide = 30)

/obj/item/reagent_containers/cup/bottle/chloralhydrate
	name = "chloral hydrate bottle"
	desc = "A small bottle of Choral Hydrate. Mickey's Favorite!"
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 15)

/obj/item/reagent_containers/cup/bottle/mutagen
	name = "unstable mutagen bottle"
	desc = "A small bottle of unstable mutagen. Randomly changes the DNA structure of whoever comes in contact."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/cup/bottle/synaptizine
	name = "synaptizine bottle"
	desc = "A small bottle of synaptizine."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 30)

/obj/item/reagent_containers/cup/bottle/ammonia
	name = "ammonia bottle"
	desc = "A small bottle of ammonia."
	list_reagents = list(/datum/reagent/ammonia = 30)

/obj/item/reagent_containers/cup/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A small bottle of diethylamine."
	list_reagents = list(/datum/reagent/diethylamine = 30)

/obj/item/reagent_containers/cup/bottle/adminordrazine
	name = "Adminordrazine Bottle"
	desc = "A small bottle. Contains the liquid essence of the gods."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 30)

/obj/item/reagent_containers/cup/bottle/capsaicin
	name = "Capsaicin Bottle"
	desc = "A small bottle. Contains hot sauce."
	list_reagents = list(/datum/reagent/consumable/capsaicin = 30)

/obj/item/reagent_containers/cup/bottle/frostoil
	name = "Frost Oil Bottle"
	desc = "A small bottle. Contains cold sauce."
	list_reagents = list(/datum/reagent/consumable/frostoil = 30)

//Oldstation.dmm chemical storage bottles

/obj/item/reagent_containers/cup/bottle/hydrogen
	name = "hydrogen bottle"
	list_reagents = list(/datum/reagent/hydrogen = 30)

/obj/item/reagent_containers/cup/bottle/lithium
	name = "lithium bottle"
	list_reagents = list(/datum/reagent/lithium = 30)

/obj/item/reagent_containers/cup/bottle/carbon
	name = "carbon bottle"
	list_reagents = list(/datum/reagent/carbon = 30)

/obj/item/reagent_containers/cup/bottle/nitrogen
	name = "nitrogen bottle"
	list_reagents = list(/datum/reagent/nitrogen = 30)

/obj/item/reagent_containers/cup/bottle/oxygen
	name = "oxygen bottle"
	list_reagents = list(/datum/reagent/oxygen = 30)

/obj/item/reagent_containers/cup/bottle/fluorine
	name = "fluorine bottle"
	list_reagents = list(/datum/reagent/fluorine = 30)

/obj/item/reagent_containers/cup/bottle/sodium
	name = "sodium bottle"
	list_reagents = list(/datum/reagent/sodium = 30)

/obj/item/reagent_containers/cup/bottle/silicon
	name = "silicon bottle"
	list_reagents = list(/datum/reagent/silicon = 30)

/obj/item/reagent_containers/cup/bottle/phosphorus
	name = "phosphorus bottle"
	list_reagents = list(/datum/reagent/phosphorus = 30)

/obj/item/reagent_containers/cup/bottle/sulfur
	name = "sulfur bottle"
	list_reagents = list(/datum/reagent/sulfur = 30)

/obj/item/reagent_containers/cup/bottle/chlorine
	name = "chlorine bottle"
	list_reagents = list(/datum/reagent/chlorine = 30)

/obj/item/reagent_containers/cup/bottle/potassium
	name = "potassium bottle"
	list_reagents = list(/datum/reagent/potassium = 30)

/obj/item/reagent_containers/cup/bottle/iron
	name = "iron bottle"
	list_reagents = list(/datum/reagent/iron = 30)

/obj/item/reagent_containers/cup/bottle/copper
	name = "copper bottle"
	list_reagents = list(/datum/reagent/copper = 30)

/obj/item/reagent_containers/cup/bottle/mercury
	name = "mercury bottle"
	list_reagents = list(/datum/reagent/mercury = 30)

/obj/item/reagent_containers/cup/bottle/water
	name = "water bottle"
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/cup/bottle/ethanol
	name = "ethanol bottle"
	list_reagents = list(/datum/reagent/consumable/ethanol = 30)

/obj/item/reagent_containers/cup/bottle/sugar
	name = "sugar bottle"
	list_reagents = list(/datum/reagent/consumable/sugar = 30)

/obj/item/reagent_containers/cup/bottle/sacid
	name = "sulfuric acid bottle"
	list_reagents = list(/datum/reagent/toxin/acid = 30)

/obj/item/reagent_containers/cup/bottle/welding_fuel
	name = "welding fuel bottle"
	list_reagents = list(/datum/reagent/fuel = 30)

/obj/item/reagent_containers/cup/bottle/silver
	name = "silver bottle"
	list_reagents = list(/datum/reagent/silver = 30)

/obj/item/reagent_containers/cup/bottle/caramel
	name = "bottle of caramel"
	desc = "A bottle containing caramalized sugar, also known as caramel. Do not lick."
	list_reagents = list(/datum/reagent/consumable/caramel = 30)

/*
 *	Syrup bottles, basically a unspillable cup that transfers reagents upon clicking on it with a cup
 */

/obj/item/reagent_containers/cup/bottle/syrup_bottle
	name = "syrup bottle"
	desc = "A bottle with a syrup pump to dispense the delicious substance directly into your coffee cup."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "syrup"
	fill_icon_state = "syrup"
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100)
	possible_transfer_amounts = list(5, 10)
	amount_per_transfer_from_this = 5
	///variable to tell if the bottle can be refilled
	var/cap_on = TRUE

/obj/item/reagent_containers/cup/bottle/syrup_bottle/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to toggle the pump cap.")
	. += span_notice("Use a pen on it to rename it.")

//when you attack the syrup bottle with a container it refills it
/obj/item/reagent_containers/cup/bottle/syrup_bottle/attackby(obj/item/attacking_item, mob/user, params)

	if(!cap_on)
		return ..()

	if(!check_allowed_items(attacking_item,target_self = TRUE))
		return

	if(attacking_item.is_refillable())
		if(!reagents.total_volume)
			balloon_alert(user, "bottle empty!")
			return TRUE

		if(attacking_item.reagents.holder_full())
			balloon_alert(user, "container full!")
			return TRUE

		var/transfer_amount = reagents.trans_to(attacking_item, amount_per_transfer_from_this)
		balloon_alert(user, "transferred [transfer_amount] unit\s")
		flick("syrup_anim",src)

	attacking_item.update_appearance()
	update_appearance()

	return TRUE

/obj/item/reagent_containers/cup/bottle/syrup_bottle/AltClick(mob/user)
	. = ..()
	cap_on = !cap_on
	if(!cap_on)
		icon_state = "syrup_open"
		balloon_alert(user, "removed pump cap")
	else
		icon_state = "syrup"
		balloon_alert(user, "put pump cap on")
	update_icon_state()

//types of syrups

/obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel
	name = "bottle of caramel syrup"
	desc = "A pump bottle containing caramalized sugar, also known as caramel. Do not lick."
	list_reagents = list(/datum/reagent/consumable/caramel = 50)

/obj/item/reagent_containers/cup/bottle/syrup_bottle/liqueur
	name = "bottle of coffee liqueur syrup"
	desc = "A pump bottle containing mexican coffee-flavoured liqueur syrup. In production since 1936, HONK."
	list_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 50)

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	worn_icon_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/can_shatter = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/reagent_containers/food/drinks/bottle/proc/smash(mob/living/target as mob, mob/living/user as mob)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.temporarilyRemoveItemFromInventory(src)
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(user.loc)
	user.put_in_active_hand(B)
	if(prob(33))
		new/obj/item/shard(target.loc) // Create a glass shard at the target's location!
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/items/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	playsound(src, SFX_SHATTER, 25, 1)
	user.put_in_active_hand(B)

	qdel(src)

/obj/item/reagent_containers/food/drinks/bottle/attack(mob/living/target as mob, mob/living/user as mob)

	if(!target)
		return

	if(user.a_intent != INTENT_HARM || !can_shatter)
		return ..()

	force = 15 //Smashing bottles over someoen's head hurts.

	var/datum/limb/affecting = user.zone_selected //Find what the player is aiming at

	//apply damage
	var/paralyze_duration = target.apply_damage(force, BRUTE, affecting, MELEE, updating_health = TRUE, attacker = user)

	if(affecting == "head" && istype(target, /mob/living/carbon/) && !isxeno(target))

		if(target != user)
			user.visible_message(span_danger("[target] has been hit over the head with a bottle of [name], by [user]!"))
		else
			user.visible_message(span_danger("[user] has hit [user.p_them()]self with the bottle of [name] on the head!"))
		if(paralyze_duration >= force) //if they have armor, no stun
			target.apply_effect(4 SECONDS, EFFECT_PARALYZE)

	else
		if(target != user)
			user.visible_message(span_danger("[target] has been attacked with a bottle of [name], by [user]!"))
		else
			user.visible_message(span_danger("[user] has attacked [user.p_them()]self with the bottle of [name]!"))

	UPDATEHEALTH(target)

	//Attack logs
	log_combat(user, target, "smashed", src)

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(reagents)
		visible_message(span_boldnotice("The contents of the [src] splashes all over [target]!"))
		reagents.reaction(target, TOUCH)

	//Finally, smash the bottle. This kills (del) the bottle.
	smash(target, user)

/obj/item/reagent_containers/food/drinks/bottle/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(xeno_attacker)

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "\improper Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	center_of_mass = list("x"=16, "y"=4)
	list_reagents = list(/datum/reagent/consumable/ethanol/gin = 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "\improper Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured for four years by hillbillies in the backwaters of Alabama."
	icon_state = "whiskeybottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 100)

/obj/item/reagent_containers/food/drinks/bottle/specialwhiskey
	name = "\improper Nanotrasen 'Space-Aged' 60-Year Old Whiskey"
	desc = "This exquisite brand of whiskey has been aged in the hull of a colony ship since 2378. It's worth more than what you make in several months- and bold enough to state this fact on the bottle."
	icon_state = "specialwhiskeybottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/specialwhiskey = 100)

/obj/item/reagent_containers/food/drinks/bottle/experimentalliquor
	name = "\improper NT-06"
	desc = "A black bottle with nothing but a note and a warning label on it. 'Drink this and you will die,' '600 proof,' and other such discouraging words are written upon it."
	icon_state = "experimentalliquorbottle"
	center_of_mass = list("x"=17, "y"=5)
	list_reagents = list(/datum/reagent/consumable/ethanol/pwine = 100)

/obj/item/reagent_containers/food/drinks/bottle/sake
	name = "\improper Harakiri traditional styled sake"
	desc = "Sweet as can be, and burns like fire going down."
	icon_state = "sakebottle"
	center_of_mass = list("x"=17, "y"=7)
	list_reagents = list(/datum/reagent/consumable/ethanol/sake = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "\improper Red Star Vodka"
	desc = "The bottle reads, 'Ra Ra Red Star Man: Lover of the Finer Things.' Or at least that's what you assume...."
	icon_state = "vodkabottle"
	center_of_mass = list("x"=17, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/vodka = 100)

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "\improper Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/tequila = 100)

/obj/item/reagent_containers/food/drinks/bottle/davenport
	name = "\improper Davenport Rye Whiskey"
	desc = "An expensive whiskey with a distinct flavor. The bottle proudly proclaims that it's, 'A True Classic.'"
	icon_state = "davenportbottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/davenport = 50)


/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	center_of_mass = list("x"=17, "y"=5)
	list_reagents = list(/datum/reagent/consumable/nothing = 100)

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list(/datum/reagent/consumable/ethanol/patron = 100)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "Named after the famed Captain 'Cuban' Pete, this rum is about as volatile as his final mission."
	icon_state = "rumbottle"
	center_of_mass = list("x"=16, "y"=8)
	list_reagents = list(/datum/reagent/consumable/ethanol/rum = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	center_of_mass = list("x"=17, "y"=10)
	list_reagents = list(/datum/reagent/water/holywater = 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	center_of_mass = list("x"=17, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/vermouth = 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	center_of_mass = list("x"=17, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 100)

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	center_of_mass = list("x"=15, "y"=3)
	list_reagents = list(/datum/reagent/consumable/ethanol/goldschlager = 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list(/datum/reagent/consumable/ethanol/cognac = 100)

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	center_of_mass = list("x"=16, "y"=4)
	list_reagents = list(/datum/reagent/consumable/ethanol/wine = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list(/datum/reagent/consumable/ethanol/absinthe = 100)

/obj/item/reagent_containers/food/drinks/bottle/melonliquor
	name = "Emeraldine Melon Liquor"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "alco-green" //Placeholder.
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list(/datum/reagent/consumable/ethanol/melonliquor = 100)

/obj/item/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "alco-blue" //Placeholder.
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list(/datum/reagent/consumable/ethanol/bluecuracao = 100)

/obj/item/reagent_containers/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadine"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list(/datum/reagent/consumable/grenadine = 100)

/obj/item/reagent_containers/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	center_of_mass = list("x"=16, "y"=4)
	list_reagents = list(/datum/reagent/consumable/ethanol/pwine = 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	worn_icon_state = "carton"
	center_of_mass = list("x"=16, "y"=7)
	can_shatter = 0
	list_reagents = list(/datum/reagent/consumable/orangejuice = 100)

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	worn_icon_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	can_shatter = 0
	list_reagents = list(/datum/reagent/consumable/cream = 100)

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	worn_icon_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	can_shatter = 0
	list_reagents = list(/datum/reagent/consumable/tomatojuice = 100)

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	worn_icon_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	can_shatter = 0
	list_reagents = list(/datum/reagent/consumable/limejuice = 100)
