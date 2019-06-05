

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now weaken and break when smashed on people's heads. - Giacom

/obj/item/reagent_container/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/isGlass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it

/obj/item/reagent_container/food/drinks/bottle/proc/smash(mob/living/target as mob, mob/living/user as mob)

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

	playsound(src, "shatter", 25, 1)
	user.put_in_active_hand(B)

	qdel(src)

/obj/item/reagent_container/food/drinks/bottle/attack(mob/living/target as mob, mob/living/user as mob)

	if(!target)
		return

	if(user.a_intent != INTENT_HARM || !isGlass)
		return ..()


	force = 15 //Smashing bottles over someoen's head hurts.

	var/datum/limb/affecting = user.zone_selected //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armour values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	armor_block = target.run_armor_check(affecting, "melee")
	armor_duration = duration + force - target.getarmor(affecting, "melee")

	//Apply the damage!
	target.apply_damage(force, BRUTE, affecting, armor_block, sharp=0)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	if(affecting == "head" && istype(target, /mob/living/carbon/) && !isxeno(target))

		if(target != user)
			user.visible_message("<span class='danger'>[target] has been hit over the head with a bottle of [name], by [user]!</span>")
		else
			user.visible_message("<span class='danger'>[user] has hit [user.p_them()]self with the bottle of [name] on the head!</span>")
		if(armor_duration)
			target.apply_effect(min(armor_duration, 10) , WEAKEN, armor_block) // Never weaken more than a flash!

	else
		if(target != user)
			user.visible_message("<span class='danger'>[target] has been attacked with a bottle of [name], by [user]!</span>")
		else
			user.visible_message("<span class='danger'>[user] has attacked [user.p_them()]self with the bottle of [name]!</span>")

	//Attack logs
	log_combat(user, target, "smashed", src)
	msg_admin_attack("[ADMIN_TPMONTY(usr)] attacked [ADMIN_TPMONTY(target)] with a bottle. (INTENT: [uppertext(user.a_intent)]).")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(reagents)
		visible_message("<span class='boldnotice'>The contents of the [src] splashes all over [target]!</span>")
		reagents.reaction(target, TOUCH)

	//Finally, smash the bottle. This kills (del) the bottle.
	smash(target, user)

	return



/obj/item/reagent_container/food/drinks/bottle/gin
	name = "\improper Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"
	center_of_mass = list("x"=16, "y"=4)
	list_reagents = list("gin" = 100)

/obj/item/reagent_container/food/drinks/bottle/whiskey
	name = "\improper Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured for four years by hillbillies in the backwaters of Alabama."
	icon_state = "whiskeybottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list("whiskey" = 100)

/obj/item/reagent_container/food/drinks/bottle/sake
	name = "\improper Harakiri traditional styled sake"
	desc = "Sweet as can be, and burns like fire going down."
	icon_state = "sakebottle"
	center_of_mass = list("x"=17, "y"=7)
	list_reagents = list("sake" = 100)

/obj/item/reagent_container/food/drinks/bottle/vodka
	name = "\improper Red Star Vodka"
	desc = "The bottle reads, 'Ra Ra Red Star Man: Lover of the Finer Things.' Or at least that's what you assume...."
	icon_state = "vodkabottle"
	center_of_mass = list("x"=17, "y"=3)
	list_reagents = list("vodka" = 100)

/obj/item/reagent_container/food/drinks/bottle/tequila
	name = "\improper Caccavo Guaranteed Quality Tequila"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequilabottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list("tequila" = 100)

/obj/item/reagent_container/food/drinks/bottle/davenport
	name = "\improper Davenport Rye Whiskey"
	desc = "An expensive whiskey with a distinct flavor. The bottle proudly proclaims that it's, 'A True Classic.'"
	icon_state = "davenportbottle"
	center_of_mass = list("x"=16, "y"=3)
	list_reagents = list("davenport" = 50)


/obj/item/reagent_container/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing"
	icon_state = "bottleofnothing"
	center_of_mass = list("x"=17, "y"=5)
	list_reagents = list("nothing" = 100)

/obj/item/reagent_container/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequila, served in space night clubs across the galaxy."
	icon_state = "patronbottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list("patron" = 100)

/obj/item/reagent_container/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "Named after the famed Captain 'Cuban' Pete, this rum is about as volatile as his final mission."
	icon_state = "rumbottle"
	center_of_mass = list("x"=16, "y"=8)
	list_reagents = list("rum" = 100)

/obj/item/reagent_container/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	center_of_mass = list("x"=17, "y"=10)
	list_reagents = list("holywater" = 100)

/obj/item/reagent_container/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"
	center_of_mass = list("x"=17, "y"=3)
	list_reagents = list("vermouth" = 100)

/obj/item/reagent_container/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	center_of_mass = list("x"=17, "y"=3)
	list_reagents = list("kahlua" = 100)

/obj/item/reagent_container/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"
	center_of_mass = list("x"=15, "y"=3)
	list_reagents = list("goldschlager" = 100)

/obj/item/reagent_container/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list("cognac" = 100)

/obj/item/reagent_container/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	center_of_mass = list("x"=16, "y"=4)
	list_reagents = list("wine" = 100)

/obj/item/reagent_container/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list("absinthe" = 100)

/obj/item/reagent_container/food/drinks/bottle/melonliquor
	name = "Emeraldine Melon Liquor"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "alco-green" //Placeholder.
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list("melonliquor" = 100)

/obj/item/reagent_container/food/drinks/bottle/bluecuracao
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "alco-blue" //Placeholder.
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list("bluecuracao" = 100)

/obj/item/reagent_container/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadinebottle"
	center_of_mass = list("x"=16, "y"=6)
	list_reagents = list("grenadine" = 100)

/obj/item/reagent_container/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	center_of_mass = list("x"=16, "y"=4)
	list_reagents = list("pwine" = 100)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_container/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=7)
	isGlass = 0
	list_reagents = list("orangejuice" = 100)

/obj/item/reagent_container/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = 0
	list_reagents = list("cream" = 100)

/obj/item/reagent_container/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = 0
	list_reagents = list("tomatojuice" = 100)

/obj/item/reagent_container/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	center_of_mass = list("x"=16, "y"=8)
	isGlass = 0
	list_reagents = list("limejuice" = 100)
