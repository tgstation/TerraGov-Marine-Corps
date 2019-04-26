

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/reagent/consumable/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	nutriment_factor = 1
	color = "#E78108" // rgb: 231, 129, 8
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0

/datum/reagent/consumable/drink/on_mob_life(mob/living/L, metabolism)
	if(adj_dizzy != 0)
		L.Dizzy(adj_dizzy)
	if(adj_drowsy != 0)
		L.drowsyness = max(0,L.drowsyness + adj_drowsy)
	if(adj_sleepy != 0)
		L.AdjustSleeping(adj_sleepy)
	return ..()

/datum/reagent/consumable/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#E78108" // rgb: 231, 129, 8
	taste_description = "oranges"

/datum/reagent/consumable/drink/orangejuice/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(-0.3)
	return ..()

/datum/reagent/consumable/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "tomatoes"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0,0.2)
	return ..()


/datum/reagent/consumable/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "unbearable sourness"

/datum/reagent/consumable/drink/limejuice/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(-0.2)
	return ..()

/datum/reagent/consumable/drink/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
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
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	color = "#990066" // rgb: 153, 0, 102
	taste_description = "berries"

/datum/reagent/consumable/drink/grapejuice
	name = "Grape Juice"
	id = "grapejuice"
	description = "It's grrrrrape!"
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "grapes"

/datum/reagent/consumable/drink/suoto
	name = "Souto Classic"
	id = "souto_classic"
	description = "A fruit flavored soda canned in Havana"
	color = "#802b00"
	taste_description = "sour soda"
	taste_multi = 2

/datum/reagent/consumable/drink/suoto/cherry
	name = "Souto Cherry"
	id = "souto_cherry"
	description = "Now with more artificial flavors! Canned in Havanna"
	color = "#800000"
	taste_description = "bittersweet soda"

/datum/reagent/consumable/drink/grapesoda
	name = "Grape Soda"
	id = "grapesoda"
	description = "Grapes made into a fine drank."
	color = "#421C52" // rgb: 98, 57, 53
	adj_drowsy = -3
	taste_description = "grape soda"

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	taste_description = "berries"

/datum/reagent/consumable/drink/poisonberryjuice/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(1)
	return ..()

/datum/reagent/consumable/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "juicy watermelon"

/datum/reagent/consumable/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "sourness"

/datum/reagent/consumable/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana."
	color = "#863333" // rgb: 175, 175, 0
	taste_description = "banana"

/datum/reagent/consumable/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."
	taste_description = "nothing"

/datum/reagent/consumable/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2 * FOOD_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "irish sadness"

/datum/reagent/consumable/drink/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223
	taste_description = "milk"

/datum/reagent/consumable/drink/milk/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0.2,0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	return ..()

/datum/reagent/consumable/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	color = "#DFDFC7" // rgb: 223, 223, 199
	taste_description = "soy milk"

/datum/reagent/consumable/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	taste_description = "creamy milk"

/datum/reagent/consumable/drink/grenadine
	name = "Grenadine Syrup"
	id = "grenadine"
	description = "Made in the modern day with proper pomegranate substitute. Who uses real fruit, anyways?"
	color = "#FF004F" // rgb: 255, 0, 79
	taste_description = "100% pure pomegranate"

/datum/reagent/consumable/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	nutriment_factor = 2
	color = "#403010" // rgb: 64, 48, 16
	adj_temp = 15
	taste_description = "creamy chocolate"

/datum/reagent/consumable/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	overdose_threshold = REAGENTS_OVERDOSE * 3
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 3
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp = 20
	taste_description = "bitterness"

/datum/reagent/consumable/drink/coffee/on_mob_life(mob/living/L, metabolism)
	L.Jitter(2)
	if(adj_temp > 0 && holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	return ..()

/datum/reagent/consumable/drink/coffee/overdose_process(mob/living/L, metabolism)
	L.Jitter(5)
	if(prob(5) && ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(0.1, TRUE)
		L.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/consumable/drink/coffee/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(0.2, TOX)
	L.Jitter(5)
	if(prob(5) && L.stat != UNCONSCIOUS)
		to_chat(L, "<span class='warning'>You spasm and pass out!</span>")
		L.KnockOut(5)
	if(prob(5) && ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(0.1, TRUE)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	taste_description = "bitter coldness"
	adj_temp = 5
	targ_temp = BODYTEMP_NORMAL - 5

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "creamy coffee"
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/consumable/drink/coffee/soy_latte/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0.2,0)
	return ..()

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "bitter cream"
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/consumable/drink/coffee/cafe_latte/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(0.2,0)
	return ..()

/datum/reagent/consumable/drink/tea
	name = "Tea"
	id = "tea"
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
	id = "icetea"
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
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "tart and fresh"
	adj_dizzy = - 5
	adj_drowsy = -2
	adj_sleepy = -1

/datum/reagent/consumable/drink/cold/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "carbonated water"
	adj_dizzy = -5
	adj_drowsy = -1

/datum/reagent/consumable/drink/cold/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	taste_description = "ice"
	adj_temp = - 7
	targ_temp = BODYTEMP_NORMAL - 15

/datum/reagent/consumable/drink/cold/space_cola
	name = "Space Cola"
	id = "cola"
	description = "A refreshing beverage."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "cola"
	adj_drowsy = -2
	adj_sleepy = -1

/datum/reagent/consumable/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "the future"
	adj_sleepy = -2
	adj_drowsy = -10
	adj_dizzy = 5

/datum/reagent/consumable/drink/cold/nuka_cola/on_mob_life(mob/living/L, metabolism)
	L.Jitter(10)
	L.set_drugginess(30)
	return ..()

/datum/reagent/consumable/drink/cold/spacemountainwind
	name = "Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "sweet citrus soda"
	adj_drowsy = -7
	adj_sleepy = -1

/datum/reagent/consumable/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#102000" // rgb: 16, 32, 0
	taste_description = "cherry soda" // FALSE ADVERTISING
	adj_drowsy = -6

/datum/reagent/consumable/drink/cold/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" // rgb: 32, 40, 0
	taste_description = "cherry soda"
	adj_temp = - 8
	targ_temp = BODYTEMP_NORMAL - 10

/datum/reagent/consumable/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	color = "#878F00" // rgb: 135, 40, 0
	taste_description = "tangy lime and lemon soda"
	adj_temp = - 8
	targ_temp = BODYTEMP_NORMAL - 10

/datum/reagent/consumable/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	id = "lemonade"
	color = "#FFFF00" // rgb: 255, 255, 0
	taste_description = "tartness"

/datum/reagent/consumable/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = "kiraspecial"
	color = "#CCCC99" // rgb: 204, 204, 153
	taste_description = "fruity sweetness"

/datum/reagent/consumable/drink/cold/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	id = "brownstar"
	color = "#9F3400" // rgb: 159, 052, 000
	taste_description = "orange and cola soda"
	adj_temp = - 2

/datum/reagent/consumable/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#AEE5E4" // rgb" 174, 229, 228
	taste_description = "creamy vanilla"
	adj_temp = - 9
	targ_temp = BODYTEMP_NORMAL - 10

/datum/reagent/consumable/drink/cold/milkshake/on_mob_life(mob/living/L, metabolism)
	if(prob(1))
		L.emote("shiver")
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	return ..()

/datum/reagent/consumable/drink/cold/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Librarian..."
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0
	taste_description = "a bad night out"

/datum/reagent/consumable/drink/cold/rewriter/on_mob_life(mob/living/L, metabolism)
	L.Jitter(5)
	return ..()

/datum/reagent/consumable/drink/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	color = "#FF8CFF" // rgb: 255, 140, 255
	taste_description = "homely fruit"
	nutriment_factor = - 1
	adj_dizzy = - 10

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/L, metabolism)
	L.adjustBruteLoss(-0.5, 0)
	L.adjustFireLoss(-0.5, 0)
	L.adjustToxLoss(-0.5, 0)
	L.adjustOxyLoss(-0.5, 0)
	L.confused = max(L.confused - 5, 0)
	return ..()

/datum/reagent/consumable/drink/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	adj_dizzy = 10
	taste_description = "da bomb"

/datum/reagent/consumable/drink/atomicbomb/on_mob_life(mob/living/L, metabolism)
	L.set_drugginess(50)
	L.confused += 2
	L.slurring += 2
	switch(current_cycle)
		if(40 to 49)
			L.drowsyness += 2
		if(51 to 200)
			L.Sleeping(3)
		if(201 to INFINITY)
			L.Sleeping(3)
			L.adjustToxLoss(2)
	return ..()

/datum/reagent/consumable/drink/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = 6
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"

/datum/reagent/consumable/drink/gargle_blaster/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(15 to 45)
			L.slurring += 2
			L.Jitter(2)
		if(46 to 65)
			L.confused += 2
			L.slurring += 2
			L.Jitter(3)
		if(66 to 199)
			L.set_drugginess(50)
			if(prob(10))
				L.vomit()
			L.Jitter(4)
			if(prob(5))
				L.Sleeping(8)
		if(200 to INFINITY)
			L.set_drugginess(50)
			L.confused += 2
			L.slurring += 2
			L.adjustToxLoss(2)
			L.Jitter(5)
			if(prob(10))
				L.vomit()
			L.Sleeping(3)
	return ..()

/datum/reagent/consumable/drink/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	adj_dizzy = 6
	taste_description = "a numbing sensation"

/datum/reagent/consumable/drink/neurotoxin/on_mob_life(mob/living/L, metabolism)
	L.KnockDown(3)
	switch(current_cycle)
		if(15 to 35)
			L.stuttering += 2
		if(36 to 55)
			L.stuttering +=2
			L.confused += 2
		if(56 to 200)
			L.stuttering +=2
			L.confused += 2
			L.set_drugginess(30)
		if(201 to INFINITY)
			L.set_drugginess(30)
			L.adjustToxLoss(2)
	return ..()

/datum/reagent/consumable/drink/hippies_delight
	name = "Hippies' Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	color = "#664300" // rgb: 102, 67, 0
	taste_description = "giving peace a chance"

/datum/reagent/consumable/drink/hippies_delight/on_mob_life(mob/living/L, metabolism)
	L.slurring = max(L.slurring, 2)
	switch(current_cycle)
		if(1 to 5)
			L.Dizzy(10)
			L.set_drugginess(30)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
		if(6 to 10)
			L.Dizzy(20)
			L.Jitter(20)
			L.set_drugginess(45)
			if(prob(20))
				L.emote(pick("twitch","giggle"))
		if(11 to 200)
			L.Dizzy(40)
			L.Jitter(40)
			L.set_drugginess(60)
			if(prob(30))
				L.emote(pick("twitch","giggle"))
		if(201 to INFINITY)
			L.stuttering = 1
			L.Jitter(60)
			L.Dizzy(60)
			L.set_drugginess(75)
			if(prob(40))
				L.emote(pick("twitch","giggle"))
			L.adjustToxLoss(0.6)
	return ..()