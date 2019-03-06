
/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.

/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	custom_metabolism = FOOD_METABOLISM
	taste_description = "generic food"
	taste_multi = 4
	var/nutriment_factor = 1
	var/adj_temp = 0
	var/targ_temp = BODYTEMP_NORMAL
	taste_description = "generic food"

/datum/reagent/consumable/on_mob_life(mob/living/carbon/M)
	current_cycle++
	M.nutrition += nutriment_factor * REM
	if(adj_temp)
		M.adjust_bodytemperature(adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT, (adj_temp < 0 ? targ_temp : INFINITY), (adj_temp > 0 ? 0 : targ_temp))
	holder.remove_reagent(src.id, custom_metabolism)
	return TRUE

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48

	var/brute_heal = 1
	var/burn_heal = 0
	var/blood_gain = 0.4

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/M)
	if(prob(50))
		M.heal_limb_damage(brute_heal,burn_heal)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume += blood_gain

	..()

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	if(!islist(newdata) || !newdata.len)
		return

	// data for nutriment is one or more (flavour -> ratio)
	// where all the ratio values adds up to 1

	var/list/taste_amounts = list()
	if(data)
		taste_amounts = data.Copy()

	counterlist_scale(taste_amounts, volume)

	var/list/other_taste_amounts = newdata.Copy()
	counterlist_scale(other_taste_amounts, newvolume)

	counterlist_combine(taste_amounts, other_taste_amounts)

	counterlist_normalise(taste_amounts)

	data = taste_amounts

/datum/reagent/consumable/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_multi = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 10
	taste_description = "sweetness"

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "umami"

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "ketchup"

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "hot peppers"
	taste_multi = 1.5
	targ_temp = BODYTEMP_NORMAL + 15
	adj_temp = 5
	var/discomfort_message = "<span class='danger'>Your insides feel uncomfortably hot!</span>"
	var/agony_start = 20
	var/agony_amount = 2

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/M)
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((H.species.species_flags & NO_PAIN))
			return ..()
	switch(current_cycle)
		if(1 to agony_start - 1)
			if(prob(5))
				to_chat(M, discomfort_message)
		if(agony_start to INFINITY)
			M.apply_effect(agony_amount,AGONY,0)
			if(prob(5))
				M.custom_emote(2, "[pick("dry heaves!","coughs!","splutters!")]")
				to_chat(M, discomfort_message)
	return ..()

/datum/reagent/consumable/capsaicin/condensed
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "A chemical agent used for self-defense and in police work."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "scorching agony"
	taste_multi = 10
	targ_temp = BODYTEMP_HEAT_DAMAGE_LIMIT_ONE + 5
	discomfort_message = "<span class='danger'>You feel like your insides are burning!</span>"
	agony_start = 3
	agony_amount = 4

/datum/reagent/consumable/capsaicin/condensed/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method in list(TOUCH, VAPOR, PATCH))
		if(ishuman(M))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if( victim.wear_mask )
				if( victim.wear_mask.flags_inventory & COVEREYES )
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if( victim.wear_mask.flags_inventory & COVERMOUTH )
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if( victim.head )
				if( victim.head.flags_inventory & COVEREYES )
					eyes_covered = 1
					safe_thing = victim.head
				if( victim.head.flags_inventory & COVERMOUTH )
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if( !safe_thing )
					safe_thing = victim.glasses
			if( eyes_covered && mouth_covered )
				to_chat(victim, "<span class='danger'>Your [safe_thing.name] protects you from the pepperspray!</span>")
				return
			else if( mouth_covered )	// Reduced effects if partially protected
				to_chat(victim, "<span class='danger'>Your [safe_thing] protect your face from the pepperspray!</span>")
				victim.blur_eyes(15)
				victim.blind_eyes(5)
				victim.Stun(5)
				victim.KnockDown(5)
				//victim.KnockOut(10)
				//victim.drop_held_item()
				return
			else if( eyes_covered ) // Mouth cover is better than eye cover, except it's actually the opposite.
				to_chat(victim, "<span class='danger'>Your [safe_thing] protects you from most of the pepperspray!</span>")
				if(!(victim.species && (victim.species.species_flags & NO_PAIN)))
					if(prob(10))
						victim.Stun(1)
				victim.blur_eyes(5)
				return
			else // Oh dear :D
				if(!(victim.species && (victim.species.species_flags & NO_PAIN)))
					if(prob(10))
						victim.emote("scream")
				to_chat(victim, "<span class='danger'>You're sprayed directly in the eyes with pepperspray!</span>")
				victim.blur_eyes(25)
				victim.blind_eyes(10)
				victim.Stun(5)
				victim.KnockDown(5)
				//victim.KnockOut(10)
				//victim.drop_held_item()


/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extracted from Ice Peppers."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233
	taste_description = "mint"
	targ_temp = - 50
	adj_temp = 10

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/M)
	if(prob(1))
		M.emote("shiver")
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 5)
	return ..()

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	color = "#FFFFFF" // rgb: 255,255,255
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "salt"

/datum/reagent/consumable/sodiumchloride/overdose_process(mob/living/M, alien)
	M.confused = max(M.confused, 20)
	if(prob(10))
		M.emote(pick("sigh","grumble","frown"))

/datum/reagent/consumable/sodiumchloride/overdose_crit_process(mob/living/M, alien)
	M.Jitter(5) //Turn super salty
	if(prob(10))
		M.KnockDown(10)
	if(prob(10))
		M.emote(pick("cry","moan","pain"))

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	// no color (ie, black)
	taste_description = "pepper"

/datum/reagent/consumable/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "bitterness"

/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "creamy chocolate"
	adj_temp = 5

/datum/reagent/consumable/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "mushroom"

/datum/reagent/consumable/psilocybin/on_mob_life(mob/living/M)
	M.druggy = max(M.druggy, 30)
	switch(current_cycle)
		if(1 to 5)
			M.stuttering += 1
			M.Dizzy(5)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.stuttering += 1
			M.Jitter(10)
			M.Dizzy(10)
			M.set_drugginess(35)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.stuttering += 1
			M.Jitter(20)
			M.Dizzy(20)
			M.set_drugginess(40)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..()

/datum/reagent/consumable/psilocybin/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)
	if(prob(15))
		M.KnockOut(5)

/datum/reagent/consumable/psilocybin/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(2, TOX)
	if(prob(60))
		M.KnockOut(3)
	M.drowsyness = max(M.drowsyness, 30)

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 5
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_description = "childhood whimsy"

/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "slime"

/datum/reagent/consumable/cornoil/reaction_turf(var/turf/T, var/volume)
	if(!istype(T))
		return
	src = null
	if(volume >= 3)
		T.wet_floor(FLOOR_WET_WATER)

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = LIQUID
	color = "#365E30" // rgb: 54, 94, 48
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "sweetness"

/datum/reagent/consumable/enzyme/overdose_process(mob/living/M, alien)
	M.apply_damage(1, BURN)

/datum/reagent/consumable/enzyme/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, BURN)

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	nutriment_factor = 1
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "dry and cheap noodles"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles"
	adj_temp = 10

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles on fire"
	targ_temp = INFINITY
	adj_temp = 10

/datum/reagent/consumable/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	nutriment_factor = 2
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "rice"


/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "cherry"

/datum/reagent/consumable/honey
	name = "Honey"
	id = "honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#FFFF00"
	nutriment_factor = 15
	taste_description = "sweetness"

/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/M)
	M.reagents.add_reagent("sugar",3)
	if(prob(55))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		M.adjustOxyLoss(-1*REM, 0)
		M.adjustToxLoss(-1*REM, 0)
	return ..()