
/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.

/datum/reagent/consumable
	name = "Consumable"
	custom_metabolism = FOOD_METABOLISM
	taste_description = "generic food"
	taste_multi = 4
	var/nutriment_factor = 1
	var/adj_temp = 0
	var/targ_temp = BODYTEMP_NORMAL

/datum/reagent/consumable/on_mob_life(mob/living/L, metabolism)
	current_cycle++
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.adjust_nutrition(nutriment_factor*0.5*effect_str)
	if(adj_temp)
		L.adjust_bodytemperature(adj_temp * TEMPERATURE_DAMAGE_COEFFICIENT, (adj_temp < 0 ? targ_temp : INFINITY), (adj_temp > 0 ? 0 : targ_temp))
	holder.remove_reagent(type, custom_metabolism)
	return TRUE

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48
	var/brute_heal = 1
	var/burn_heal = 0
	var/blood_gain = 0.4

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/L, metabolism)
	if(prob(50))
		L.heal_limb_damage(brute_heal, burn_heal)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume += blood_gain

	return ..()

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
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_multi = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 10
	taste_description = "sweetness"

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "umami"

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "ketchup"

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "hot peppers"
	taste_multi = 1.5
	targ_temp = BODYTEMP_NORMAL + 15
	adj_temp = 5
	var/discomfort_message = span_danger("Your insides feel uncomfortably hot!")
	var/agony_start = 20
	var/agony_amount = 2

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/L, metabolism)
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if((H.species.species_flags & NO_PAIN))
			return ..()
	switch(current_cycle)
		if(1 to agony_start - 1)
			if(prob(5))
				to_chat(L, discomfort_message)
		if(agony_start to INFINITY)
			L.apply_effect(agony_amount, AGONY)
			if(prob(5))
				L.emote(pick("dry heaves!", "coughs!", "splutters!"))
				to_chat(L, discomfort_message)
	return ..()

/datum/reagent/consumable/capsaicin/condensed
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "scorching agony"
	taste_multi = 10
	targ_temp = BODYTEMP_HEAT_DAMAGE_LIMIT_ONE + 5
	discomfort_message = span_danger("You feel like your insides are burning!")
	agony_start = 3
	agony_amount = 4

/datum/reagent/consumable/capsaicin/condensed/reaction_mob(mob/living/L, method = TOUCH, volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(method in list(TOUCH, VAPOR)) || !ishuman(L))
		return
	var/mob/living/carbon/human/victim = L
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
		if(show_message)
			to_chat(victim, span_danger("Your [safe_thing.name] protects you from the pepperspray!"))
		return
	else if( mouth_covered )	// Reduced effects if partially protected
		if(show_message)
			to_chat(victim, span_danger("Your [safe_thing] protect your face from the pepperspray!"))
		victim.blur_eyes(15)
		victim.blind_eyes(5)
		victim.Stun(10 SECONDS)
		victim.Paralyze(10 SECONDS)
		//victim.Unconscious(10)
		//victim.drop_held_item()
		return
	else if( eyes_covered ) // Mouth cover is better than eye cover, except it's actually the opposite.
		if(show_message)
			to_chat(victim, span_danger("Your [safe_thing] protects you from most of the pepperspray!"))
		if(!(victim.species && (victim.species.species_flags & NO_PAIN)))
			if(prob(10))
				victim.Stun(20)
		victim.blur_eyes(5)
		return
	else // Oh dear :D
		if(!(victim.species && (victim.species.species_flags & NO_PAIN)))
			if(prob(10))
				victim.emote("scream")
		if(show_message)
			to_chat(victim, span_danger("You're sprayed directly in the eyes with pepperspray!"))
		victim.blur_eyes(25)
		victim.blind_eyes(10)
		victim.Stun(10 SECONDS)
		victim.Paralyze(10 SECONDS)


/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "A special oil that noticably chills the body. Extracted from Ice Peppers."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233
	taste_description = "mint"
	targ_temp = - 50
	adj_temp = 10

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/L, metabolism)
	if(prob(1))
		L.emote("shiver")
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5)
	return ..()

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."
	color = "#FFFFFF" // rgb: 255,255,255
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "salt"

/datum/reagent/consumable/sodiumchloride/overdose_process(mob/living/L, metabolism)
	L.Confused(40 SECONDS)
	if(prob(10))
		L.emote(pick("sigh","grumble","frown"))

/datum/reagent/consumable/sodiumchloride/overdose_crit_process(mob/living/L, metabolism)
	L.jitter(5) //Turn super salty
	if(prob(10))
		L.Paralyze(20 SECONDS)
	if(prob(10))
		L.emote(pick("cry","moan","pain"))

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	// no color (ie, black)
	taste_description = "pepper"

/datum/reagent/consumable/coco
	name = "Coco Powder"
	description = "A fatty, bitter paste made from coco beans."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "bitterness"

/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "creamy chocolate"
	adj_temp = 5

/datum/reagent/consumable/psilocybin
	name = "Psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "mushroom"

/datum/reagent/consumable/psilocybin/on_mob_life(mob/living/L, metabolism)
	L.druggy = max(L.druggy, 30)
	switch(current_cycle)
		if(1 to 5)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
			L.dizzy(5)
			if(prob(10))
				L.emote(pick("twitch","giggle"))
		if(5 to 10)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
			L.jitter(10)
			L.dizzy(10)
			L.set_drugginess(35)
			if(prob(20))
				L.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			L.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter)
			L.jitter(20)
			L.dizzy(20)
			L.set_drugginess(40)
			if(prob(30))
				L.emote(pick("twitch","giggle"))
	return ..()

/datum/reagent/consumable/psilocybin/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)
	if(prob(15))
		L.Unconscious(10 SECONDS)

/datum/reagent/consumable/psilocybin/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(2, TOX)
	if(prob(60))
		L.Unconscious(60)
	L.setDrowsyness(max(L.drowsyness, 30))

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 5
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_description = "childhood whimsy"

/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "slime"

/datum/reagent/consumable/cornoil/reaction_turf(turf/T, volume)
	if(volume >= 3)
		T.wet_floor(FLOOR_WET_WATER)

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = LIQUID
	color = "#365E30" // rgb: 54, 94, 48
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "sweetness"

/datum/reagent/consumable/enzyme/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, BURN)

/datum/reagent/consumable/enzyme/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(2, BURN)

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	nutriment_factor = 1
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "dry and cheap noodles"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles"
	adj_temp = 10

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles on fire"
	targ_temp = INFINITY
	adj_temp = 10

/datum/reagent/consumable/rice
	name = "Rice"
	description = "Enjoy the great taste of nothing."
	nutriment_factor = 2
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "rice"


/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "cherry"

/datum/reagent/consumable/honey
	name = "Honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	color = "#FFFF00"
	nutriment_factor = 15
	taste_description = "sweetness"

/datum/reagent/consumable/honey/on_mob_life(mob/living/L, metabolism)
	L.reagents.add_reagent(/datum/reagent/consumable/sugar,3)
	L.adjustBruteLoss(-0.25*effect_str)
	L.adjustFireLoss(-0.25*effect_str)
	L.adjustOxyLoss(-0.25*effect_str)
	L.adjustToxLoss(-0.25*effect_str)
	return ..()

/datum/reagent/consumable/larvajelly
	name = "Larva Jelly"
	description = "The blood and guts of a xenomorph larva blended into a paste. Drinking this is bad for you."
	reagent_state = LIQUID
	nutriment_factor = 0
	color = "#66801e"
	taste_description = "burning"

/datum/reagent/consumable/larvajelly/on_mob_life(mob/living/L, metabolism)
	L.adjustBruteLoss(-0.5*effect_str)
	L.adjustFireLoss(effect_str)
	L.adjustToxLoss(effect_str)
	return ..()

/datum/reagent/consumable/larvajellyprepared
	name = "Prepared Larva Jelly"
	description = "A delicious blend of xenomorphic entrails and acid, denatured by exposure to high-frequency radiation. Probably has some uses."
	reagent_state = LIQUID
	nutriment_factor = 1
	color = "#66801e"
	taste_description = "victory"

/datum/reagent/consumable/larvajellyprepared/on_mob_life(mob/living/L, metabolism)
	L.adjustBruteLoss(-0.5*effect_str)
	return ..()


