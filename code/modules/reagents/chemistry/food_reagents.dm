///////////////////////////////////////////////////////////////////
					//Food Reagents
//////////////////////////////////////////////////////////////////


// Part of the food code. Also is where all the food
// condiments, additives, and such go.

/datum/reagent/consumable
	name = "Consumable"
	taste_description = "generic food"
	taste_mult = 4
	/// How much nutrition this reagent supplies
	var/nutriment_factor = 1
	/// affects mood, typically higher for mixed drinks with more complex recipes'
	var/quality = 0

/datum/reagent/consumable/New()
	. = ..()

/datum/reagent/consumable/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(affected_mob) || (isrobot(affected_mob) || issynth(affected_mob)))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.adjust_nutrition(get_nutriment_factor(affected_mob) * REM * seconds_per_tick)

/// Gets just how much nutrition this reagent is worth for the passed mob
/datum/reagent/consumable/proc/get_nutriment_factor(mob/living/carbon/eater)
	return nutriment_factor * REAGENTS_METABOLISM  * 2

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48
	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume * 0.2))

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(30, seconds_per_tick))
		if(affected_mob.heal_overall_damage(brute = brute_heal * REM * seconds_per_tick, burn = burn_heal * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	. = ..()
	if(!data)
		return
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	. = ..()
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

/datum/reagent/consumable/nutriment/get_taste_description(mob/living/taster)
	return data

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."
	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.nutrition < NUTRITION_OVERFED)
		affected_mob.nutrition += 30 * REM * seconds_per_tick

/// The basic resource of vat growing.
/datum/reagent/consumable/nutriment/protein
	name = "Protein"
	description = "A natural polyamide made up of amino acids. An essential constituent of mosts known forms of life."
	brute_heal = 0.8 //Rewards the player for eating a balanced diet.
	nutriment_factor = 9 //45% as calorie dense as oil.
	default_container = /obj/item/reagent_containers/condiment/protein

/datum/reagent/consumable/nutriment/fat
	name = "Fat"
	description = "Triglycerides found in vegetable oils and fatty animal tissue."
	color = "#f0eed7"
	taste_description = "lard"
	brute_heal = 0
	burn_heal = 1
	nutriment_factor = 18 // Twice as nutritious compared to protein and carbohydrates
	var/fry_temperature = 450 //Around ~350 F (117 C) which deep fryers operate around in the real world

/datum/reagent/consumable/nutriment/fat/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	if(!holder || (holder.chem_temp <= fry_temperature))
		return
	if(!isitem(exposed_obj) || HAS_TRAIT(exposed_obj, TRAIT_FOOD_FRIED))
		return
	if(is_type_in_typecache(exposed_obj, GLOB.oilfry_blacklisted_items) || (exposed_obj.resistance_flags & INDESTRUCTIBLE))
		exposed_obj.visible_message(span_notice("The hot oil has no effect on [exposed_obj]!"))
		return
	if(isstorageobj(exposed_obj))
		exposed_obj.visible_message(span_notice("The hot oil splatters about as [exposed_obj] touches it. It seems too full to cook properly!"))
		return

	exposed_obj.visible_message(span_warning("[exposed_obj] rapidly fries as it's splashed with hot oil! Somehow."))
	exposed_obj.AddElement(/datum/element/fried_item, volume)
	exposed_obj.reagents.add_reagent(src.type, reac_volume)

/datum/reagent/consumable/nutriment/fat/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (VAPOR|TOUCH)) || isnull(holder) || (holder.chem_temp < fry_temperature)) //Directly coats the mob, and doesn't go into their bloodstream
		return

	var/burn_damage = ((holder.chem_temp / fry_temperature) * 0.33) //Damage taken per unit
	if(methods & TOUCH)
		burn_damage *= max(1 - touch_protection, 0)
	var/FryLoss = round(min(38, burn_damage * reac_volume))
	if(!HAS_TRAIT(exposed_mob, TRAIT_OIL_FRIED))
		exposed_mob.visible_message(span_warning("The boiling oil sizzles as it covers [exposed_mob]!"), \
		span_userdanger("You're covered in boiling oil!"))
		if(FryLoss)
			exposed_mob.emote("scream")
		playsound(exposed_mob, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
		ADD_TRAIT(exposed_mob, TRAIT_OIL_FRIED, "cooking_oil_react")
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, unfry_mob)), 0.3 SECONDS)
	if(FryLoss)
		exposed_mob.adjustFireLoss(FryLoss)


/datum/reagent/consumable/nutriment/fat/oil
	name = "Vegetable Oil"
	description = "A variety of cooking oil derived from plant fats. Used in food preparation and frying."
	color = "#EADD6B" //RGB: 234, 221, 107 (based off of canola oil)
	taste_mult = 0.8
	taste_description = "oil"
	nutriment_factor = 7 //Not very healthy on its own
	custom_metabolism = 10 * REAGENTS_METABOLISM
	default_container = /obj/item/reagent_containers/condiment/vegetable_oil

/datum/reagent/consumable/nutriment/fat/oil/olive
	name = "Olive Oil"
	description = "A high quality oil, suitable for dishes where the oil is a key flavour."
	taste_description = "olive oil"
	color = "#DBCF5C"
	nutriment_factor = 10
	default_container = /obj/item/reagent_containers/condiment/olive_oil

/datum/reagent/consumable/nutriment/fat/oil/corn
	name = "Corn Oil"
	description = "An oil derived from various types of corn."
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "slime"
	nutriment_factor = 5 //it's a very cheap oil

/datum/reagent/consumable/nutriment/organ_tissue
	name = "Organ Tissue"
	description = "Natural tissues that make up the bulk of organs, providing many vitamins and minerals."
	taste_description = "rich earthy pungent"

/datum/reagent/consumable/nutriment/cloth_fibers
	name = "Cloth Fibers"
	description = "It's not actually a form of nutriment but it does keep Mothpeople going for a short while..."
	nutriment_factor = 30
	brute_heal = 0
	burn_heal = 0
	///Amount of satiety that will be drained when the cloth_fibers is fully metabolized
	var/delayed_satiety_drain = 2 * CLOTHING_NUTRITION_GAIN

/datum/reagent/consumable/nutriment/cloth_fibers/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.nutrition < NUTRITION_OVERFED)
		affected_mob.adjust_nutrition(CLOTHING_NUTRITION_GAIN)
		delayed_satiety_drain += CLOTHING_NUTRITION_GAIN

/datum/reagent/consumable/nutriment/cloth_fibers/on_mob_delete(mob/living/carbon/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.adjust_nutrition(-delayed_satiety_drain)


/datum/reagent/consumable/sugar
	name = "Sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = COLOR_WHITE // rgb: 255, 255, 255
	taste_mult = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 2
	custom_metabolism = 5 * REAGENTS_METABOLISM
	overdose_threshold = 120 // Hyperglycaemic shock
	taste_description = "sweetness"
	default_container = /obj/item/reagent_containers/condiment/sugar

// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
/datum/reagent/consumable/sugar/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_weedlevel(rand(1, 2))
	mytray.adjust_pestlevel(rand(1, 2))

/datum/reagent/consumable/sugar/on_overdose_crit_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("You go into hyperglycemic shock! Lay off the twinkies!"))
	affected_mob.AdjustSleeping(20 SECONDS)

/datum/reagent/consumable/sugar/overdose_crit_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.AdjustSleeping((1 SECONDS * REM * seconds_per_tick))

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "A mixture of water and milk. Virus cells can use this mixture to reproduce."
	nutriment_factor = 2
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"

// Compost for EVERYTHING
/datum/reagent/consumable/virus_food/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 0.5))

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "umami"
	default_container = /obj/item/reagent_containers/condiment/soysauce

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "ketchup"
	default_container = /obj/item/reagent_containers/condiment/ketchup

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "This is what makes chilis hot."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "hot peppers"
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/heating = 0
	switch(current_cycle)
		if(1 to 15)
			heating = 5
		if(15 to 25)
			heating = 10
		if(25 to 35)
			heating = 15
		if(35 to INFINITY)
			heating = 20
	affected_mob.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "A special oil that noticeably chills the body. Extracted from chilly peppers and slimes."
	color = "#8BA6E9" // rgb: 139, 166, 233
	taste_description = "mint"
	///40 joules per unit.
	specific_heat = 40
	default_container = /obj/item/reagent_containers/cup/bottle/frostoil

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/cooling = 0
	switch(current_cycle)
		if(1 to 15)
			cooling = -10
			if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
				holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5 * REM * seconds_per_tick)
		if(15 to 25)
			cooling = -20
		if(25 to 35)
			cooling = -30
			if(prob(1))
				affected_mob.emote("shiver")
		if(35 to INFINITY)
			cooling = -40
			if(prob(5))
				affected_mob.emote("shiver")
	affected_mob.adjust_bodytemperature(cooling * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick, 50)

/datum/reagent/consumable/frostoil/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "scorching agony"
	default_container = /obj/item/reagent_containers/cup/bottle/capsaicin


/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!holder.has_reagent(/datum/reagent/consumable/milk))
		if(SPT_PROB(5, seconds_per_tick))
			affected_mob.visible_message(span_warning("[affected_mob] [pick("dry heaves!","coughs!","splutters!")]"))

/datum/reagent/consumable/salt
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = COLOR_WHITE // rgb: 255,255,255
	taste_description = "salt"
	default_container = /obj/item/reagent_containers/condiment/saltshaker

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)
	taste_description = "pepper"
	default_container = /obj/item/reagent_containers/condiment/peppermill

/datum/reagent/consumable/coco
	name = "Coco Powder"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "bitterness"

/datum/reagent/consumable/garlic //NOTE: having garlic in your blood stops vampires from biting you.
	name = "Garlic Juice"
	description = "Crushed garlic. Chefs love it, but it can make you smell bad."
	color = "#FEFEFE"
	taste_description = "garlic"
	custom_metabolism = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	if(SPT_PROB(10, seconds_per_tick)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
		if(affected_mob.heal_overall_damage(brute = 1 * REM * seconds_per_tick, burn = 1 * REM * seconds_per_tick, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/consumable/tearjuice
	name = "Tear Juice"
	description = "A blinding substance extracted from certain onions."
	color = "#c0c9a0"
	taste_description = "bitterness"

/datum/reagent/consumable/tearjuice/expose_mob(mob/living/exposed_mob, methods = INGEST, reac_volume)
	. = ..()
	if(!ishuman(exposed_mob))
		return

	var/mob/living/carbon/victim = exposed_mob
	to_chat(exposed_mob, span_warning("Your eyes sting!"))
	victim.emote("cry")
	victim.blur_eyes(6 SECONDS)

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = COLOR_MAGENTA // rgb: 255, 0, 255
	taste_description = "childhood whimsy"


/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "A universal enzyme used in the preparation of certain chemicals and foods."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "sweetness"
	default_container = /obj/item/reagent_containers/condiment/enzyme

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "dry and cheap noodles"
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles"
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/nutraslop
	name = "Nutraslop"
	description = "Mixture of leftover prison foods served on previous days."
	nutriment_factor = 5
	color = "#3E4A00" // rgb: 62, 74, 0
	taste_description = "your imprisonment"

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "wet and cheap noodles on fire"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * seconds_per_tick)

/datum/reagent/consumable/flour
	name = "Flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = COLOR_WHITE // rgb: 0, 0, 0
	taste_description = "chalky wheat"
	default_container = /obj/item/reagent_containers/condiment/flour

/datum/reagent/consumable/flour/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isspaceturf(exposed_turf))
		return

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	nutriment_factor = 10
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "cherry"
	default_container = /obj/item/reagent_containers/condiment/cherryjelly

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	description = "Blue and tastier kind of cherry jelly."
	color = "#00F0FF"
	taste_description = "blue cherry"

/datum/reagent/consumable/rice
	name = "Rice"
	description = "tiny nutritious grains"
	reagent_state = SOLID
	nutriment_factor = 3
	color = COLOR_WHITE // rgb: 0, 0, 0
	taste_description = "rice"
	default_container = /obj/item/reagent_containers/condiment/rice

/datum/reagent/consumable/rice_flour
	name = "Rice Flour"
	description = "Flour mixed with Rice"
	reagent_state = SOLID
	color = COLOR_WHITE // rgb: 0, 0, 0
	taste_description = "chalky wheat with rice"

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 5
	color = "#FFFACD"
	taste_description = "vanilla"

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	description = "It's full of protein."
	nutriment_factor = 8
	color = "#FFB500"
	taste_description = "egg"

/datum/reagent/consumable/eggwhite
	name = "Egg White"
	description = "It's full of even more protein."
	nutriment_factor = 4
	color = "#fffdf7"
	taste_description = "bland egg"

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	description = "A slippery solution."
	color = "#DBCE95"
	taste_description = "slime"

/datum/wound/proc/on_starch(reac_volume, mob/living/carbon/carbies)
	return

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	description = "Decays into sugar."
	color = "#DBCE95"
	custom_metabolism = 3 * REAGENTS_METABOLISM
	taste_description = "sweet slime"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)

/datum/reagent/consumable/honey
	name = "Honey"
	description = "Sweet sweet honey that decays into sugar. Has antibacterial and natural healing properties."
	color = "#d3a308"
	nutriment_factor = 15
	custom_metabolism = 1 * REAGENTS_METABOLISM
	taste_description = "sweetness"
	default_container = /obj/item/reagent_containers/condiment/honey


/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * seconds_per_tick)
	var/need_mob_update
	if(SPT_PROB(33, seconds_per_tick))
		need_mob_update = affected_mob.adjustBruteLoss(-1, updating_health = FALSE)
		need_mob_update += affected_mob.adjustFireLoss(-1, updating_health = FALSE)
		need_mob_update += affected_mob.adjustOxyLoss(-1)
		need_mob_update += affected_mob.adjustToxLoss(-1)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	description = "A white and oily mixture of mixed egg yolks."
	color = "#DFDFDF"
	taste_description = "mayonnaise"
	default_container = /obj/item/reagent_containers/condiment/mayonnaise

/datum/reagent/consumable/mold // yeah, ok, togopal, I guess you could call that a condiment
	name = "Mold"
	description = "This condiment will make any food break the mold. Or your stomach."
	color ="#708a88"
	taste_description = "rancid fungus"

/datum/reagent/consumable/eggrot
	name = "Rotten Eggyolk"
	description = "It smells absolutely dreadful."
	color ="#708a88"
	taste_description = "rotten eggs"

/datum/reagent/consumable/nutriment/stabilized
	name = "Stabilized Nutriment"
	description = "A bioengineered protien-nutrient structure designed to decompose in high saturation. In layman's terms, it won't get you fat."
	reagent_state = SOLID
	nutriment_factor = 15
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/consumable/nutriment/stabilized/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.nutrition > NUTRITION_OVERFED - 25)
		affected_mob.adjust_nutrition(-3 * REM * get_nutriment_factor(affected_mob) * seconds_per_tick)

/datum/reagent/consumable/astrotame
	name = "Astrotame"
	description = "A space age artifical sweetener."
	nutriment_factor = 0
	custom_metabolism = 2 * REAGENTS_METABOLISM
	reagent_state = SOLID
	color = COLOR_WHITE // rgb: 255, 255, 255
	taste_mult = 8
	taste_description = "sweetness"
	overdose_threshold = 17


/datum/reagent/consumable/secretsauce
	name = "Secret Sauce"
	description = "What could it be?"
	nutriment_factor = 2
	color = "#792300"
	taste_description = "indescribable"
	quality = FOOD_AMAZING
	taste_mult = 100

/datum/reagent/consumable/nutriment/peptides
	name = "Peptides"
	color = "#BBD4D9"
	taste_description = "mint frosting"
	description = "These restorative peptides not only speed up wound healing, but are nutritious as well!"
	nutriment_factor = 10 // 33% less than nutriment to reduce weight gain
	brute_heal = 3
	burn_heal = 1

/datum/reagent/consumable/caramel
	name = "Caramel"
	description = "Who would have guessed that heated sugar could be so delicious?"
	nutriment_factor = 10
	color = "#D98736"
	taste_mult = 2
	taste_description = "caramel"
	reagent_state = SOLID

/datum/reagent/consumable/char
	name = "Char"
	description = "Essence of the grill. Has strange properties when overdosed."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#C8C8C8"
	taste_mult = 6
	taste_description = "smoke"
	overdose_threshold = 15

/datum/reagent/consumable/char/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(13, seconds_per_tick))
		affected_mob.say(pick_list_replacements(BOOMER_FILE, "boomer"), forced = /datum/reagent/consumable/char)

/datum/reagent/consumable/bbqsauce
	name = "BBQ Sauce"
	description = "Sweet, smoky, savory, and gets everywhere. Perfect for grilling."
	nutriment_factor = 5
	color = "#78280A" // rgb: 120 40, 10
	taste_mult = 2.5 //sugar's 1.5, capsacin's 1.5, so a good middle ground.
	taste_description = "smokey sweetness"
	default_container = /obj/item/reagent_containers/condiment/bbqsauce

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "A great dessert for chocolate lovers."
	color = COLOR_MAROON
	quality = DRINK_VERYGOOD
	nutriment_factor = 4
	taste_description = "sweet chocolate"
	glass_price = DRINK_PRICE_EASY

/datum/glass_style/drinking_glass/chocolatepudding
	required_drink_type = /datum/reagent/consumable/chocolatepudding
	name = "chocolate pudding"
	desc = "Tasty."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "chocolatepudding"

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "A great dessert for vanilla lovers."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 4
	taste_description = "sweet vanilla"

/datum/glass_style/drinking_glass/vanillapudding
	required_drink_type = /datum/reagent/consumable/vanillapudding
	name = "vanilla pudding"
	desc = "Tasty."
	icon = 'icons/obj/drinks/shakes.dmi'
	icon_state = "vanillapudding"

/datum/reagent/consumable/laughsyrup
	name = "Laughin' Syrup"
	description = "The product of juicing Laughin' Peas. Fizzy, and seems to change flavour based on what it's used with!"
	color = "#803280"
	nutriment_factor = 5
	taste_mult = 2
	taste_description = "fizzy sweetness"

/datum/reagent/consumable/gravy
	name = "Gravy"
	description = "A mixture of flour, water, and the juices of cooked meat."
	taste_description = "gravy"
	color = "#623301"
	taste_mult = 1.2

/datum/reagent/consumable/pancakebatter
	name = "Pancake Batter"
	description = "A very milky batter. 5 units of this on the griddle makes a mean pancake."
	taste_description = "milky batter"
	color = "#fccc98"

/datum/reagent/consumable/korta_flour
	name = "Korta Flour"
	description = "A coarsely ground, peppery flour made from korta nut shells."
	taste_description = "earthy heat"
	color = "#EEC39A"

/datum/reagent/consumable/korta_milk
	name = "Korta Milk"
	description = "A milky liquid made by crushing the centre of a korta nut."
	taste_description = "sugary milk"
	color = COLOR_WHITE

/datum/reagent/consumable/korta_nectar
	name = "Korta Nectar"
	description = "A sweet, sugary syrup made from crushed sweet korta nuts."
	color = "#d3a308"
	nutriment_factor = 5
	custom_metabolism = 1 * REAGENTS_METABOLISM
	taste_description = "peppery sweetness"

/datum/reagent/consumable/whipped_cream
	name = "Whipped Cream"
	description = "A white fluffy cream made from whipping cream at intense speed."
	color = "#efeff0"
	nutriment_factor = 4
	taste_description = "fluffy sweet cream"

/datum/reagent/consumable/peanut_butter
	name = "Peanut Butter"
	description = "A rich, creamy spread produced by grinding peanuts."
	taste_description = "peanuts"
	reagent_state = SOLID
	color = "#D9A066"
	nutriment_factor = 15
	default_container = /obj/item/reagent_containers/condiment/peanut_butter

/datum/reagent/consumable/vinegar
	name = "Vinegar"
	description = "Useful for pickling, or putting on chips."
	taste_description = "acid"
	color = "#661F1E"
	default_container = /obj/item/reagent_containers/condiment/vinegar

/datum/reagent/consumable/cornmeal
	name = "Cornmeal"
	description = "Ground cornmeal, for making corn related things."
	taste_description = "raw cornmeal"
	color = "#ebca85"
	default_container = /obj/item/reagent_containers/condiment/cornmeal

/datum/reagent/consumable/yoghurt
	name = "Yoghurt"
	description = "Creamy natural yoghurt, with applications in both food and drinks."
	taste_description = "yoghurt"
	color = "#efeff0"
	nutriment_factor = 2
	default_container = /obj/item/reagent_containers/condiment/yoghurt

/datum/reagent/consumable/cornmeal_batter
	name = "Cornmeal Batter"
	description = "An eggy, milky, corny mixture that's not very good raw."
	taste_description = "raw batter"
	color = "#ebca85"

/datum/reagent/consumable/olivepaste
	name = "Olive Paste"
	description = "A mushy pile of finely ground olives."
	taste_description = "mushy olives"
	color = "#adcf77"

/datum/reagent/consumable/creamer
	name = "Coffee Creamer"
	description = "Powdered milk for cheap coffee. How delightful."
	taste_description = "milk"
	color = "#efeff0"
	nutriment_factor = 1.5
	default_container = /obj/item/reagent_containers/condiment/creamer

/datum/reagent/consumable/mintextract
	name = "Mint Extract"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "mint"


/datum/reagent/consumable/worcestershire
	name = "Worcestershire Sauce"
	description = "That's \"Woostershire\" sauce, by the way."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#572b26"
	taste_description = "sweet fish"
	default_container = /obj/item/reagent_containers/condiment/worcestershire

/datum/reagent/consumable/red_bay
	name = "Red Bay Seasoning"
	description = "A secret blend of herbs and spices that goes well with anything- according to Martians, at least."
	color = "#8E4C00"
	taste_description = "spice"
	default_container = /obj/item/reagent_containers/condiment/red_bay

/datum/reagent/consumable/curry_powder
	name = "Curry Powder"
	description = "One of humanity's most common spices. Typically used to make curry."
	color = "#F6C800"
	taste_description = "dry curry"
	default_container = /obj/item/reagent_containers/condiment/curry_powder

/datum/reagent/consumable/dashi_concentrate
	name = "Dashi Concentrate"
	description = "A concentrated form of dashi. Simmer with water in a 1:8 ratio to produce a tasty dashi broth."
	color = "#372926"
	taste_description = "extreme umami"
	default_container = /obj/item/reagent_containers/condiment/dashi_concentrate

/datum/reagent/consumable/martian_batter
	name = "Martian Batter"
	description = "A thick batter made with dashi and flour, used for making dishes such as okonomiyaki and takoyaki."
	color = "#D49D26"
	taste_description = "umami dough"

/datum/reagent/consumable/grounding_solution
	name = "Grounding Solution"
	description = "A food-safe ionic solution designed to neutralise the enigmatic \"liquid electricity\" that is common to food from Sprout, forming harmless salt on contact."
	color = "#efeff0"
	taste_description = "metallic salt"
