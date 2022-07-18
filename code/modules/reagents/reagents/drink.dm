///////////////////////////////////////////////////////////////////////////////////////////
// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum //
///////////////////////////////////////////////////////////////////////////////////////////


/datum/reagent/consumable/drink
	name = "Drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	nutriment_factor = 1
	color = "#E78108" // rgb: 231, 129, 8
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0

/datum/reagent/consumable/drink/on_mob_life(mob/living/L, metabolism)
	if(adj_dizzy != 0)
		L.dizzy(adj_dizzy)
	if(adj_drowsy != 0)
		L.adjustDrowsyness(adj_drowsy)
	if(adj_sleepy != 0)
		L.AdjustSleeping(adj_sleepy)
	return ..()

/datum/reagent/consumable/drink/orangejuice
	name = "Orange juice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	taste_description = "oranges"

/datum/reagent/consumable/drink/orangejuice/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(-0.3)
	return ..()

/datum/reagent/consumable/drink/tomatojuice
	name = "Tomato Juice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "tomatoes"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0, 0.2)
	return ..()


/datum/reagent/consumable/drink/limejuice
	name = "Lime Juice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "unbearable sourness"

/datum/reagent/consumable/drink/limejuice/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(-0.2)
	return ..()

/datum/reagent/consumable/drink/carrotjuice
	name = "Carrot juice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	taste_description = "carrots"

/datum/reagent/consumable/drink/carrotjuice/on_mob_life(mob/living/L, metabolism)
	L.adjust_blurriness(-1)
	L.adjust_blindness(-1)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10) && iscarbon(L))
				var/mob/living/carbon/C = L
				C.disabilities &= ~NEARSIGHTED
	return ..()

/datum/reagent/consumable/drink/berryjuice
	name = "Berry Juice"
	description = "A delicious blend of several different kinds of berries."
	color = "#990066" // rgb: 153, 0, 102
	taste_description = "berries"

/datum/reagent/consumable/drink/grapejuice
	name = "Grape Juice"
	description = "It's grrrrrape!"
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "grapes"

/datum/reagent/consumable/drink/suoto
	name = "Souto Classic"
	description = "A fruit flavored soda canned in Havana"
	color = "#802b00"
	taste_description = "sour soda"
	taste_multi = 2

/datum/reagent/consumable/drink/suoto/cherry
	name = "Souto Cherry"
	description = "Now with more artificial flavors! Canned in Havanna"
	color = "#800000"
	taste_description = "bittersweet soda"

/datum/reagent/consumable/drink/grapesoda
	name = "Grape Soda"
	description = "Grapes made into a fine drank."
	color = "#421C52" // rgb: 98, 57, 53
	adj_drowsy = -3
	taste_description = "grape soda"

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Poison Berry Juice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	taste_description = "berries"

/datum/reagent/consumable/drink/poisonberryjuice/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(1)
	return ..()

/datum/reagent/consumable/drink/watermelonjuice
	name = "Watermelon Juice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "juicy watermelon"

/datum/reagent/consumable/drink/lemonjuice
	name = "Lemon Juice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "sourness"

/datum/reagent/consumable/drink/banana
	name = "Banana Juice"
	description = "The raw essence of a banana."
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "banana"

/datum/reagent/consumable/drink/nothing
	name = "Nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"


/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Some say that this is the best medicine, but recent studies have proven that to be untrue."
	custom_metabolism = INFINITY
	color = "#FF4DD2"
	taste_description = "laughter"

/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/M)
	M.emote("laugh")
	return ..()

/datum/reagent/consumable/drink/potato_juice
	name = "Potato Juice"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "irish sadness"

/datum/reagent/consumable/drink/milk
	name = "Milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	taste_description = "milk"

/datum/reagent/consumable/drink/milk/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0.2)
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2)
	return ..()

/datum/reagent/consumable/drink/milk/soymilk
	name = "Soy Milk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199
	taste_description = "soy milk"

/datum/reagent/consumable/drink/milk/cream
	name = "Cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	taste_description = "creamy milk"

/datum/reagent/consumable/drink/grenadine
	name = "Grenadine Syrup"
	description = "Made in the modern day with proper pomegranate substitute. Who uses real fruit, anyways?"
	color = "#FF004F" // rgb: 255, 0, 79
	taste_description = "100% pure pomegranate"

/datum/reagent/consumable/drink/hot_coco
	name = "Hot Chocolate"
	description = "Made with love! And cocoa beans."
	nutriment_factor = 2
	color = "#403010" // rgb: 64, 48, 16
	adj_temp = 15
	taste_description = "creamy chocolate"

/datum/reagent/consumable/drink/coffee
	name = "Coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	overdose_threshold = REAGENTS_OVERDOSE * 2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 3
	custom_metabolism = REAGENTS_METABOLISM * 5 //1u/tick
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 20
	taste_description = "bitterness"
	purge_rate = 2
	trait_flags = TACHYCARDIC


/datum/reagent/consumable/drink/coffee/overdose_process(mob/living/L, metabolism)
	L.apply_damage(0.2, TOX)
	L.jitter(2)
	if(prob(5) && ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(1, TRUE)
		L.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/consumable/drink/coffee/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(0.5, TOX)
	L.jitter(5)
	if(prob(5) && L.stat != UNCONSCIOUS)
		to_chat(L, span_warning("You spasm and pass out!"))
		L.Unconscious(10 SECONDS)
	if(prob(30) && ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(1, TRUE)

//nice one jpr~
/datum/reagent/consumable/drink/coffee/atomiccoffee
	name = "Atomic Coffee"
	description = "This coffee is a brewed drink prepared from roasted seeds and enriched from use in atomic coffemaker. Consume in moderation"
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	overdose_threshold = REAGENTS_OVERDOSE * 2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 3
	custom_metabolism = REAGENTS_METABOLISM * 5 //1u/tick
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 20
	taste_description = "bitterness"
	purge_list = list(/datum/reagent/consumable/frostoil, /datum/reagent/medicine/oxycodone)
	purge_rate = 2
	trait_flags = TACHYCARDIC

/datum/reagent/consumable/drink/atomiccoffee/on_mob_add(mob/living/L, metabolism)
	. = ..()
	L.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -0.2)

/datum/reagent/consumable/drink/atomiccoffee/on_mob_delete(mob/living/L, metabolism)
	L.remove_movespeed_modifier(type)
	var/amount = (current_cycle * 0.5) // 15/cup
	L.adjustStaminaLoss(amount)


/datum/reagent/consumable/drink/atomiccoffee/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 10)
			L.adjustStaminaLoss(-effect_str)
		if(11 to 30)
			L.adjustStaminaLoss(-0.5*effect_str)
		if(11 to 60)
			L.adjustStaminaLoss(-0.25*effect_str)
			L.jitter(1)
		if(61 to 150)
			L.adjustStaminaLoss(0.25*effect_str)
			L.apply_damage(5, TOX)
			L.jitter(2)
		if(151 to INFINITY)
			L.adjustStaminaLoss(2.5*effect_str)
			L.apply_damage(10, TOX) //You're having a bad day.
			L.jitter(5)
	return ..()

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Iced Coffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	taste_description = "bitter coldness"
	adj_temp = 5
	targ_temp = BODYTEMP_NORMAL - 5

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Soy Latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "creamy coffee"
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/consumable/drink/coffee/soy_latte/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0.2)
	return ..()

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Cafe Latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter cream"
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/consumable/drink/coffee/cafe_latte/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0.2)
	return ..()

/datum/reagent/consumable/drink/tea
	name = "Tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	taste_description = "tart black tea"
	adj_dizzy = - 2
	adj_drowsy = -1
	adj_sleepy = -1
	adj_temp = 10

/datum/reagent/consumable/drink/tea/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(-0.2)
	return ..()

/datum/reagent/consumable/drink/tea/icetea
	name = "Iced Tea"
	description = "No relation to a certain rap artist/ actor."
	color = "#104038" // rgb: 16, 64, 56
	taste_description = "sweet tea"
	adj_temp = - 5
	targ_temp = BODYTEMP_NORMAL - 5

/datum/reagent/consumable/drink/cold
	name = "Cold drink"
	adj_temp = - 5
	targ_temp = BODYTEMP_NORMAL - 5
	taste_description = "refreshment"

/datum/reagent/consumable/drink/cold/tonic
	name = "Tonic Water"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "tart and fresh"
	adj_dizzy = - 5
	adj_drowsy = -2
	adj_sleepy = -1

/datum/reagent/consumable/drink/cold/sodawater
	name = "Soda Water"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "carbonated water"
	adj_dizzy = -5
	adj_drowsy = -1

/datum/reagent/consumable/drink/cold/ice
	name = "Ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "ice"
	adj_temp = - 7
	targ_temp = BODYTEMP_NORMAL - 15

/datum/reagent/consumable/drink/cold/space_cola
	name = "Space Cola"
	description = "A refreshing beverage."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "cola"
	adj_drowsy = -2
	adj_sleepy = -1

/datum/reagent/consumable/drink/cold/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "the future"
	adj_sleepy = -2
	adj_drowsy = -10
	adj_dizzy = 5

/datum/reagent/consumable/drink/cold/nuka_cola/on_mob_life(mob/living/L, metabolism)
	L.jitter(10)
	L.set_drugginess(30)
	return ..()

/datum/reagent/consumable/drink/cold/spacemountainwind
	name = "Mountain Wind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "sweet citrus soda"
	adj_drowsy = -7
	adj_sleepy = -1

/datum/reagent/consumable/drink/cold/dr_gibb
	name = "Dr. Gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "cherry soda" // FALSE ADVERTISING
	adj_drowsy = -6

/datum/reagent/consumable/drink/cold/space_up
	name = "Space-Up"
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" // rgb: 32, 40, 0
	taste_description = "cherry soda"
	adj_temp = - 8
	targ_temp = BODYTEMP_NORMAL - 10

/datum/reagent/consumable/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	color = "#878F00" // rgb: 135, 40, 0
	taste_description = "tangy lime and lemon soda"
	adj_temp = - 8
	targ_temp = BODYTEMP_NORMAL - 10

/datum/reagent/consumable/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	color = "#FFFF00" // rgb: 255, 255, 0
	taste_description = "tartness"

/datum/reagent/consumable/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	color = "#CCCC99" // rgb: 204, 204, 153
	taste_description = "fruity sweetness"

/datum/reagent/consumable/drink/cold/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	color = "#9F3400" // rgb: 159, 052, 000
	taste_description = "orange and cola soda"
	adj_temp = - 2

/datum/reagent/consumable/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	color = "#AEE5E4" // rgb" 174, 229, 228
	taste_description = "creamy vanilla"
	adj_temp = - 9
	targ_temp = BODYTEMP_NORMAL - 10

/datum/reagent/consumable/drink/cold/milkshake/on_mob_life(mob/living/L, metabolism)
	if(prob(1))
		L.emote("shiver")
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2)
	return ..()

/datum/reagent/consumable/drink/cold/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Librarian..."
	color = "#485000" // rgb:72, 080, 0
	taste_description = "a bad night out"

/datum/reagent/consumable/drink/cold/rewriter/on_mob_life(mob/living/L, metabolism)
	L.jitter(5)
	return ..()

/datum/reagent/consumable/drink/doctor_delight
	name = "The Doctor's Delight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	color = "#FF8CFF" // rgb: 255, 140, 255
	taste_description = "homely fruit"
	nutriment_factor = - 1
	custom_metabolism = REAGENTS_METABOLISM * 0.25 //Twice the rate of paracetamol
	adj_dizzy = - 10

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/L, metabolism)
	L.adjustBruteLoss(-0.5, 0)
	L.adjustFireLoss(-0.5, 0)
	L.adjustToxLoss(-0.5, 0)
	L.adjustOxyLoss(-0.5, 0)
	return ..()

/datum/reagent/consumable/drink/atomicbomb
	name = "Atomic Bomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	adj_dizzy = 10
	taste_description = "da bomb"

/datum/reagent/consumable/drink/atomicbomb/on_mob_life(mob/living/L, metabolism)
	L.set_drugginess(50)
	L.AdjustConfused(40)
	L.slurring += 2
	switch(current_cycle)
		if(40 to 49)
			L.adjustDrowsyness(2)
		if(51 to 200)
			L.Sleeping(60)
		if(201 to INFINITY)
			L.Sleeping(60)
			L.adjustToxLoss(2)
	return ..()

/datum/reagent/consumable/drink/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = 6
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"

/datum/reagent/consumable/drink/gargle_blaster/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(15 to 45)
			L.slurring += 2
			L.jitter(2)
		if(46 to 65)
			L.AdjustConfused(40)
			L.slurring += 2
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
			L.AdjustConfused(40)
			L.slurring += 2
			L.adjustToxLoss(2)
			L.jitter(5)
			if(prob(10))
				L.vomit()
			L.Sleeping(60)
	return ..()

/datum/reagent/consumable/drink/neurotoxin
	name = "Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	adj_dizzy = 6
	taste_description = "a numbing sensation"
	trait_flags = BRADYCARDICS

/datum/reagent/consumable/drink/neurotoxin/on_mob_life(mob/living/L, metabolism)
	L.Paralyze(60)
	switch(current_cycle)
		if(15 to 35)
			L.stuttering += 2
		if(36 to 55)
			L.stuttering +=2
			L.AdjustConfused(40)
		if(56 to 200)
			L.stuttering +=2
			L.AdjustConfused(40)
			L.set_drugginess(30)
		if(201 to INFINITY)
			L.set_drugginess(30)
			L.adjustToxLoss(2)
	return ..()

/datum/reagent/consumable/drink/hippies_delight
	name = "Hippies' Delight"
	description = "You just don't get it maaaan."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "giving peace a chance"

/datum/reagent/consumable/drink/hippies_delight/on_mob_life(mob/living/L, metabolism)
	L.slurring = max(L.slurring, 2)
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
			L.stuttering = 1
			L.jitter(60)
			L.dizzy(60)
			L.set_drugginess(75)
			if(prob(40))
				L.emote(pick("twitch","giggle"))
			L.adjustToxLoss(0.6)
	return ..()
