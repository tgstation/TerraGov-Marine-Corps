

//////////////////////////Poison stuff///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	description = "A toxic chemical."
	reagent_state = LIQUID
	color = COLOR_TOXIN_TOXIN
	var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	taste_description = "bitterness"
	taste_multi = 1.2

/datum/reagent/toxin/on_mob_life(mob/living/L, metabolism)
	if(toxpwr)
		L.adjustToxLoss(toxpwr*0.5*effect_str)
	return ..()

/datum/reagent/toxin/hptoxin
	name = "Toxin"
	description = "A toxic chemical."
	custom_metabolism = REAGENTS_METABOLISM * 5
	toxpwr = 1
	taste_description = "alchemy" //just anti-pwr-game stuff, no sci-fi or anything

/datum/reagent/toxin/sdtoxin
	name = "Toxin"
	description = "A toxic chemical."
	custom_metabolism = REAGENTS_METABOLISM * 5
	toxpwr = 0
	taste_description = "alchemy"

/datum/reagent/toxin/sdtoxin/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(effect_str)
	return ..()


/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = COLOR_TOXIN_AMATOXIN
	toxpwr = 1
	taste_description = "mushrooms"

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = COLOR_TOXIN_MUTAGEN
	toxpwr = 0
	taste_description = "slime"
	taste_multi = 0.9

/datum/reagent/toxin/mutagen/on_mob_life(mob/living/L, metabolism)
	L.apply_effect(10, AGONY)
	return ..()

/datum/reagent/toxin/phoron
	name = "Phoron"
	description = "Phoron in its liquid form."
	color = COLOR_TOXIN_PHORON
	toxpwr = 3

/datum/reagent/toxin/phoron/on_mob_life(mob/living/L, metabolism)
	holder.remove_reagent(/datum/reagent/medicine/inaprovaline, effect_str)
	return ..()

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	color = COLOR_TOXIN_LEXORIN
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "acid"

/datum/reagent/toxin/lexorin/on_mob_life(mob/living/L, metabolism)
	if(prob(33))
		L.take_limb_damage(0.5*effect_str, 0)
	L.adjustOxyLoss(3)
	if(prob(20))
		L.emote("gasp")
	return ..()

/datum/reagent/toxin/lexorin/overdose_process(mob/living/L, metabolism)
	L.apply_damages(0, 1, 1)

/datum/reagent/toxin/lexorin/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(1, 0, 1)

/datum/reagent/toxin/cyanide //Fast and Lethal
	name = "Cyanide"
	description = "A highly toxic chemical."
	color = COLOR_TOXIN_CYANIDE
	toxpwr = 3
	custom_metabolism = REAGENTS_METABOLISM * 2

/datum/reagent/toxin/cyanide/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(2*effect_str)
	if(current_cycle > 10)
		L.Sleeping(4 SECONDS)
	return ..()

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	description = "Useful for dealing with undesirable customers."
	color = COLOR_TOXIN_MINTTOXIN
	toxpwr = 0
	taste_description = "mint"

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded space carp."
	color = COLOR_TOXIN_CARPOTOXIN
	toxpwr = 2
	taste_description = "fish"

/datum/reagent/toxin/huskpowder
	name = "Zombie Powder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = COLOR_TOXIN_HUSKPOWDER
	toxpwr = 0.5
	taste_description = "death"

/datum/reagent/toxin/huskpowder/on_mob_add(mob/living/L, metabolism)
	ADD_TRAIT(L, TRAIT_FAKEDEATH, type)
	return ..()

/datum/reagent/toxin/huskpowder/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(0.25*effect_str)
	L.Paralyze(20 SECONDS)
	return ..()

/datum/reagent/toxin/huskpowder/on_mob_delete(mob/living/L, metabolism)
	REMOVE_TRAIT(L, TRAIT_FAKEDEATH, type)
	return ..()

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	description = "A powerful hallucinogen, it can cause fatal effects in users."
	color = COLOR_TOXIN_MINDBREAKER
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "sourness"

/datum/reagent/toxin/mindbreaker/on_mob_life(mob/living/L, metabolism)
	L.hallucination += 10
	return ..()

/datum/reagent/toxin/mindbreaker/overdose_process(mob/living/L, metabolism)
	L.adjustToxLoss(1)
	L.jitter(5)
	if(prob(10) && !L.stat)
		L.Unconscious(10 SECONDS)

/datum/reagent/toxin/mindbreaker/overdose_crit_process(mob/living/L, metabolism)
	L.adjustToxLoss(1)
	L.adjustBrainLoss(1, TRUE)
	L.jitter(5)
	if(prob(10) && !L.stat)
		L.Unconscious(10 SECONDS)
	L.setDrowsyness(max(L.drowsyness, 30))

//Reagents used for plant fertilizers.
/datum/reagent/toxin/fertilizer
	name = "fertilizer"
	description = "A chemical mix good for growing plants with."
	toxpwr = 0.2 //It's not THAT poisonous.
	color = COLOR_TOXIN_FERTILIZER

/datum/reagent/toxin/fertilizer/eznutrient
	name = "EZ Nutrient"

/datum/reagent/toxin/fertilizer/left4zed
	name = "Left-4-Zed"

/datum/reagent/toxin/fertilizer/robustharvest
	name = "Robust Harvest"

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = COLOR_TOXIN_PLANTBGONE
	toxpwr = 1
	taste_multi = 1

/datum/reagent/toxin/plantbgone/reaction_obj(obj/O, volume)
	if(istype(O,/obj/alien/weeds))
		var/obj/alien/A = O
		A.take_damage(min(0.5 * volume))
	else if(istype(O,/obj/structure/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment))
		if(prob(50)) qdel(O) //Kills kudzu too.
	else if(istype(O,/obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/tray = O

		if(tray.seed)
			tray.health -= rand(30,50)
			if(tray.pestlevel > 0)
				tray.pestlevel -= 2
			if(tray.weedlevel > 0)
				tray.weedlevel -= 3
			tray.toxins += 4
			tray.check_level_sanity()
			tray.update_icon()

/datum/reagent/toxin/sleeptoxin
	name = "Soporific"
	description = "An effective hypnotic used to treat insomnia."
	color = COLOR_TOXIN_SLEEPTOXIN
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE
	taste_description = "cough syrup"
	trait_flags = BRADYCARDICS

/datum/reagent/toxin/sleeptoxin/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 6)
			if(prob(5))
				L.emote("yawn")
			L.blur_eyes(10)
		if(7 to 10)
			if(prob(10))
				L.Sleeping(10 SECONDS)
			L.drowsyness = max(L.drowsyness, 20)
		if(11 to 80)
			L.Sleeping(10 SECONDS) //previously knockdown, no good for a soporific.
			L.drowsyness = max(L.drowsyness, 30)
		if(81 to INFINITY)
			L.adjustDrowsyness(2)
	L.reagent_pain_modifier += PAIN_REDUCTION_HEAVY
	return ..()

/datum/reagent/toxin/sleeptoxin/overdose_process(mob/living/L, metabolism)
	L.apply_damages(0, 0, 1, 2)

/datum/reagent/toxin/sleeptoxin/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(0, 0, 1, 1)

/datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	description = "A powerful sedative."
	reagent_state = SOLID
	color = COLOR_TOXIN_CHLORALHYDRATE
	toxpwr = 0
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2

/datum/reagent/toxin/chloralhydrate/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 60)
			L.Sleeping(10 SECONDS)
		if(61 to INFINITY)
			L.adjustDrowsyness(2)
			L.adjustToxLoss((current_cycle/4 - 25)*effect_str)
	return ..()

/datum/reagent/toxin/chloralhydrate/overdose_process(mob/living/L, metabolism)
	L.apply_damages(0, 0, 1, 2)

/datum/reagent/toxin/chloralhydrate/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(0, 0, 0, 2)

/datum/reagent/toxin/potassium_chloride
	name = "Potassium Chloride"
	description = "A delicious salt that stops the heart when injected into cardiac muscle."
	reagent_state = SOLID
	color = COLOR_TOXIN_POTASSIUM_CHLORIDE
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	trait_flags = CHEARTSTOPPER

/datum/reagent/toxin/potassium_chloride/overdose_process(mob/living/L, metabolism)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.losebreath > 10)
			C.set_Losebreath(10)
	L.adjustOxyLoss(2)
	switch(current_cycle)
		if(7 to 15)
			L.Paralyze(10 SECONDS)
		if(16 to INFINITY)
			L.Unconscious(10 SECONDS)
	return ..()

/datum/reagent/toxin/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	description = "A specific chemical based on Potassium Chloride to stop the heart for surgery. Not safe to eat!"
	color = COLOR_TOXIN_POTASSIUM_CHLORIDE
	toxpwr = 2

/datum/reagent/toxin/potassium_chlorophoride/on_mob_life(mob/living/L, metabolism)
	if(L.stat != UNCONSCIOUS)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.losebreath > 10)
				C.set_Losebreath(10)
		L.adjustOxyLoss(2)
	switch(current_cycle)
		if(7 to 15)
			L.Paralyze(10 SECONDS)
		if(16 to INFINITY)
			L.Unconscious(10 SECONDS)
	return ..()

/datum/reagent/toxin/pain
	name = "Liquid Pain"
	description = "This is a chemical used to simulate specific pain levels for testing. Pain is equal to the total volume."
	custom_metabolism = 0
	toxpwr = 0
	taste_description = "ow ow ow"

/datum/reagent/toxin/pain/on_mob_life(mob/living/L, metabolism)
	L.reagent_pain_modifier = volume
	return ..()

/datum/reagent/toxin/plasticide
	name = "Plasticide"
	description = "Liquid plastic, do not eat."
	color = COLOR_TOXIN_PLASTICIDE
	toxpwr = 0.2
	taste_description = "plastic"

/datum/reagent/toxin/plasticide/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(0.2)
	return ..()

/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	description = "A very corrosive mineral acid with the molecular formula H2SO4."
	color = COLOR_TOXIN_ACID
	toxpwr = 1
	var/meltprob = 10
	taste_description = "acid"

/datum/reagent/toxin/acid/on_mob_life(mob/living/L, metabolism)
	L.take_limb_damage(0, 0.5*effect_str)
	return ..()

/datum/reagent/toxin/acid/reaction_mob(mob/living/L, method = TOUCH, volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(method in list(TOUCH, VAPOR, PATCH)))
		return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L

		if(H.head)
			if(prob(meltprob) && !CHECK_BITFIELD(H.head.resistance_flags, RESIST_ALL))
				if(show_message)
					to_chat(H, span_danger("Your headgear melts away but protects you from the acid!"))
				qdel(H.head)
				H.update_inv_head(0)
				H.update_hair(0)
			else if(show_message)
				to_chat(H, span_warning("Your headgear protects you from the acid."))
			return

		if(H.wear_mask)
			if(prob(meltprob) && !CHECK_BITFIELD(H.wear_mask.resistance_flags, RESIST_ALL))
				if(show_message)
					to_chat(H, span_danger("Your mask melts away but protects you from the acid!"))
				qdel(H.wear_mask)
				H.update_inv_wear_mask(0)
				H.update_hair(0)
			else if(show_message)
				to_chat(H, span_warning("Your mask protects you from the acid."))
			return

		if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
			if(prob(meltprob) && !CHECK_BITFIELD(H.glasses.resistance_flags, RESIST_ALL))
				if(show_message)
					to_chat(H, span_danger("Your glasses melts away!"))
				qdel(H.glasses)
				H.update_inv_glasses(0)

	if(!isxeno(L))
		if(ishuman(L) && volume >= 10)
			var/mob/living/carbon/human/H = L
			var/datum/limb/affecting = H.get_limb("head")
			if(affecting)
				if(affecting.take_damage_limb(4 * toxpwr, 2 * toxpwr))
					H.UpdateDamageIcon()
				if(prob(meltprob)) //Applies disfigurement
					if(!H.species || !CHECK_BITFIELD(H.species.species_flags, NO_PAIN))
						H.emote("scream")
					H.status_flags |= DISFIGURED
					H.name = H.get_visible_name()
		else
			L.take_limb_damage(min(6*toxpwr, volume * toxpwr) * touch_protection)

/datum/reagent/toxin/acid/reaction_obj(obj/O, volume)
	if((istype(O,/obj/item) || istype(O,/obj/structure/glowshroom)) && prob(meltprob * 3))
		if(!CHECK_BITFIELD(O.resistance_flags, RESIST_ALL))
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			O.visible_message(span_warning("\the [O] melts."), null, 5)
			qdel(O)

/datum/reagent/toxin/acid/polyacid
	name = "Polytrinic acid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	color = COLOR_TOXIN_POLYACID
	toxpwr = 2
	meltprob = 30
	taste_multi = 1.5

/datum/reagent/toxin/nanites
	name = "Nanomachines"
	description = "Microscopic construction robots designed to tear iron out of the surroundings and build jagged structures of wire when mixed into a foam. Drinking this is a bad idea."
	taste_description = "poor life choices, followed by burning agony"
	reagent_state = LIQUID
	color = COLOR_TOXIN_NANITES
	custom_metabolism = REAGENTS_METABOLISM * 5
	medbayblacklist = TRUE
	reactindeadmob = FALSE

/datum/reagent/toxin/nanites/on_mob_add(mob/living/L, metabolism)
	to_chat(L, span_userdanger("Your body begins to twist and deform! Get out of the razorburn!"))
	. = ..()

/datum/reagent/toxin/nanites/on_mob_life(mob/living/L, metabolism)
	L.apply_damages(2.5*effect_str, 1.5*effect_str, 1.5*effect_str) //DO NOT DRINK THIS. Seriously!
	L.blood_volume -= 5
	if(current_cycle > 5)
		L.apply_damages(2.5*effect_str, 1.5*effect_str, 1.5*effect_str)
		L.blood_volume -= 5
		holder.remove_reagent(/datum/reagent/toxin/nanites, (current_cycle * 0.2) - 1)
	if(volume > 100)
		var/turf/location = get_turf(holder.my_atom)
		location.visible_message(span_danger("Holy shit! They just exploded into a ball of razorwire! Dear god!"))
		L.gib()
		new /obj/structure/razorwire(location)
	return ..()

/datum/reagent/toxin/xeno_neurotoxin
	name = "Neurotoxin"
	description = "A debilitating nerve toxin. Impedes motor control in high doses. Causes progressive loss of mobility over time."
	reagent_state = LIQUID
	color = COLOR_TOXIN_XENO_NEUROTOXIN
	custom_metabolism = REAGENTS_METABOLISM * 2
	overdose_threshold = 10000 //Overdosing for neuro is what happens when you run out of stamina to avoid its oxy and toxin damage
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_neurotoxin/on_mob_life(mob/living/L, metabolism)
	var/power
	switch(current_cycle)
		if(1 to 20)
			power = (2*effect_str) //While stamina loss is going, stamina regen apparently doesn't happen, so I can keep this smaller.
			L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		if(21 to 45)
			power = (6*effect_str)
			L.reagent_pain_modifier -= PAIN_REDUCTION_HEAVY
			L.jitter(4) //Shows that things are bad
		if(46 to INFINITY)
			power = (15*effect_str)
			L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_HEAVY
			L.jitter(8) //Shows that things are *really* bad

	//Apply stamina damage, then apply any 'excess' stamina damage beyond our maximum as tox and oxy damage
	var/stamina_loss_limit = L.maxHealth * 2
	var/applied_damage = clamp(power, 0, (stamina_loss_limit - L.getStaminaLoss()))
	L.adjustStaminaLoss(applied_damage) //If we're under our stamina_loss limit, apply the difference between our limit and current stamina damage or power, whichever's less
	var/damage_overflow = power - applied_damage
	if(damage_overflow > 0) //If we exceed maxHealth * 2 stamina damage, apply any excess as toxloss and oxyloss
		L.adjustToxLoss(damage_overflow * 0.5)
		L.adjustOxyLoss(damage_overflow * 0.5)
		L.Losebreath(2) //So the oxy loss actually means something.

	L.set_timed_status_effect(2 SECONDS, /datum/status_effect/speech/stutter, only_if_higher = TRUE)

	if(current_cycle < 21) //Additional effects at higher cycles
		return ..()

	L.adjust_drugginess(1.1) //Move this to stage 2 and 3 so it's not so obnoxious

	if(L.eye_blurry < 30) //So we don't have the visual acuity of Mister Magoo forever
		L.adjust_blurriness(1.3)

	return ..()

/datum/reagent/toxin/xeno_hemodile //Slows its victim. The slow becomes twice as strong with each other xeno toxin in the victim's system.
	name = "Hemodile"
	description = "Impedes motor functions and muscle response, causing slower movement."
	reagent_state = LIQUID
	color = COLOR_TOXIN_XENO_HEMODILE
	custom_metabolism = 0.4
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_hemodile/on_mob_life(mob/living/L, metabolism)

	var/slowdown_multiplier = 0.5 //Because hemodile is obviously in blood already

	for(var/datum/reagent/current_reagent AS in L.reagents.reagent_list) //Cycle through all chems
		if(is_type_in_typecache(current_reagent, GLOB.defiler_toxins_typecache_list)) //For each xeno toxin reagent, double the strength multiplier
			slowdown_multiplier *= 2 //Each other Defiler toxin increases the multiplier by 2x; 2x if we have 1 combo chem, 4x if we have 2

	switch(slowdown_multiplier) //Description varies in severity and probability with the multiplier
		if(0 to 1)
			if(prob(10))
				to_chat(L, span_warning("You feel your legs tense up.") )
		if(2 to 3.9)
			if(prob(20))
				to_chat(L, span_warning("You feel your legs go numb.") )
		if(4 to INFINITY)
			if(prob(30))
				to_chat(L, span_danger("You can barely feel your legs!") )

	L.add_movespeed_modifier(MOVESPEED_ID_XENO_HEMODILE, TRUE, 0, NONE, TRUE, 1.5 * slowdown_multiplier)

	return ..()

/datum/reagent/toxin/xeno_hemodile/on_mob_delete(mob/living/L, metabolism)
	L.remove_movespeed_modifier(MOVESPEED_ID_XENO_HEMODILE)


/datum/reagent/toxin/xeno_transvitox //when damage is received, converts brute/burn equal to 50% of damage received to tox damage
	name = "Transvitox"
	description = "Converts burn damage to toxin damage over time, and causes brute damage received to inflict extra toxin damage."
	reagent_state = LIQUID
	color = COLOR_TOXIN_XENO_TRANSVITOX
	custom_metabolism = 0.4
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_transvitox/on_mob_add(mob/living/L, metabolism, affecting)
	RegisterSignal(L, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(transvitox_human_damage_taken))

/datum/reagent/toxin/xeno_transvitox/on_mob_life(mob/living/L, metabolism)
	var/fire_loss = L.getFireLoss(TRUE)
	if(!fire_loss) //If we have no burn damage, cancel out
		return ..()

	if(prob(10))
		to_chat(L, span_warning("You notice your wounds crusting over with disgusting green ichor.") )

	var/tox_cap_multiplier = 0.5 //Because transvitox is obviously in blood already

	for(var/datum/reagent/current_reagent AS in L.reagents.reagent_list) //Cycle through all chems
		if(is_type_in_typecache(current_reagent, GLOB.defiler_toxins_typecache_list)) //For each xeno toxin reagent, double the strength multiplier
			tox_cap_multiplier *= 2 //Each other Defiler toxin doubles the multiplier

	var/tox_loss = L.getToxLoss()
	if(tox_loss > DEFILER_TRANSVITOX_CAP) //If toxin levels are already at their cap, cancel out
		return ..()

	var/dam = (current_cycle * 0.25 * tox_cap_multiplier) //Converts burn damage at this rate to toxin damage

	if(fire_loss < dam) //If burn damage is less than damage to be converted, have the conversion value be equal to the burn damage
		dam = fire_loss

	L.heal_limb_damage(burn = dam, updating_health = TRUE) //Heal damage equal to toxin damage dealt; heal before applying toxin damage so we don't flash kill the target
	L.adjustToxLoss(dam * (1 + 0.1 * tox_cap_multiplier)) //Apply toxin damage. Deal extra toxin damage equal to 10% * the tox cap multiplier

	return ..()

/datum/reagent/toxin/xeno_transvitox/proc/transvitox_human_damage_taken(mob/living/L, damage)
	SIGNAL_HANDLER

	var/tox_cap_multiplier = 0.5 //Because transvitox is obviously in blood already

	for(var/datum/reagent/current_reagent AS in L.reagents.reagent_list) //Cycle through all chems
		if(is_type_in_typecache(current_reagent, GLOB.defiler_toxins_typecache_list)) //For each xeno toxin reagent, double the strength multiplier
			tox_cap_multiplier *= 2 //Each other Defiler toxin doubles the multiplier

	var/tox_loss = L.getToxLoss()
	if(tox_loss > DEFILER_TRANSVITOX_CAP) //If toxin levels are already at their cap, cancel out
		return

	L.setToxLoss(clamp(tox_loss + min(L.getBruteLoss(TRUE) * 0.1 * tox_cap_multiplier, damage * 0.1 * tox_cap_multiplier), tox_loss, DEFILER_TRANSVITOX_CAP)) //Deal bonus tox damage equal to a % of the lesser of the damage taken or the target's brute damage; capped at DEFILER_TRANSVITOX_CAP.

/datum/reagent/toxin/xeno_sanguinal //deals brute damage and causes persistant bleeding. Causes additional damage for each other xeno chem in the system
	name = "Sanguinal"
	description = "Potent blood coloured toxin that causes constant bleeding and reacts with other xeno toxins to cause rapid tissue damage."
	reagent_state = LIQUID
	color = COLOR_TOXIN_XENO_SANGUINAL
	custom_metabolism = 0.4
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_sanguinal/on_mob_life(mob/living/L, metabolism)
	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile))
		L.adjustStaminaLoss(DEFILER_SANGUINAL_DAMAGE)

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin))
		L.adjustToxLoss(DEFILER_SANGUINAL_DAMAGE)

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox))
		L.adjustFireLoss(DEFILER_SANGUINAL_DAMAGE)

	if(L.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = L.has_status_effect(STATUS_EFFECT_INTOXICATED)
		if(debuff.stacks > 0)
			debuff.stacks = debuff.stacks + SENTINEL_INTOXICATED_SANGUINAL_INCREASE
			L.adjustFireLoss(DEFILER_SANGUINAL_DAMAGE)

	L.apply_damage(DEFILER_SANGUINAL_DAMAGE, BRUTE, sharp = TRUE)

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.drip(DEFILER_SANGUINAL_DAMAGE) //Causes bleeding

	return ..()

/datum/reagent/toxin/xeno_ozelomelyn // deals capped toxloss and purges at a rapid rate
	name = "Ozelomelyn"
	description = "A potent Xenomorph chemical that quickly purges other chemicals in a bloodstream, causing small scale poisoning in a organism that won't progress. Appears to be strangely water based.."
	reagent_state = LIQUID
	color = COLOR_TOXIN_XENO_OZELOMELYN
	custom_metabolism = 1.5 // metabolizes decently quickly. A sting does 15 at the same rate as neurotoxin.
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0 // This is going to do slightly snowflake tox damage.
	purge_list = list(/datum/reagent/medicine)
	purge_rate = 5

/datum/reagent/toxin/xeno_ozelomelyn/on_mob_life(mob/living/L, metabolism)
	if(L.getToxLoss() < 40) // if our toxloss is below 40, do 0.75 tox damage.
		L.adjustToxLoss(0.75)
		if(prob(15))
			to_chat(L, span_warning("Your veins feel like water and you can feel a growing itchy feeling in them!") )
		return ..()
	if(prob(15))
		to_chat(L, span_warning("Your veins feel like water..") )
		return ..()

/datum/reagent/zombium
	name = "Zombium"
	description = "Powerful chemical able to raise the dead, origin is likely from an unidentified bioweapon."
	reagent_state = LIQUID
	color = COLOR_TOXIN_ZOMBIUM
	custom_metabolism = REAGENTS_METABOLISM * 0.25
	scannable = TRUE
	overdose_threshold = 20
	overdose_crit_threshold = 50

/datum/reagent/zombium/on_overdose_start(mob/living/L, metabolism)
	RegisterSignal(L, COMSIG_HUMAN_SET_UNDEFIBBABLE, PROC_REF(zombify))

/datum/reagent/zombium/on_overdose_stop(mob/living/L, metabolism)
	UnregisterSignal(L, COMSIG_HUMAN_SET_UNDEFIBBABLE)

/datum/reagent/zombium/overdose_process(mob/living/L, metabolism)
	if(prob(5))
		L.emote("gasp")
	L.adjustOxyLoss(1.5)
	L.adjustToxLoss(1.5)

/datum/reagent/zombium/overdose_crit_process(mob/living/L, metabolism)
	if(prob(50))
		L.emote("gasp")
	L.adjustOxyLoss(5)
	L.adjustToxLoss(5)

///Signal handler preparing the source to become a zombie
/datum/reagent/zombium/proc/zombify(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	UnregisterSignal(H, COMSIG_HUMAN_SET_UNDEFIBBABLE)
	if(!H.has_working_organs())
		return
	H.do_jitter_animation(1000)
	addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, revive_to_crit), TRUE, TRUE), SSticker.mode?.zombie_transformation_time)


//SOM nerve agent
/datum/reagent/toxin/satrapine
	name = "Satrapine"
	description = "A nerve agent designed to incapacitate targets through debilitating pain. Its severity increases over time, causing various lung complications, and will purge common painkillers. Based on a chemical agent originally used against rebelling Martian colonists, improved by the SOM for their own use."
	reagent_state = LIQUID
	color = COLOR_TOXIN_SATRAPINE
	overdose_threshold = 10000
	custom_metabolism = REAGENTS_METABOLISM
	scannable = TRUE
	toxpwr = 0
	purge_list = list(
		/datum/reagent/medicine/tramadol,
		/datum/reagent/medicine/paracetamol,
		/datum/reagent/medicine/inaprovaline,
	)
	purge_rate = 1

/datum/reagent/toxin/satrapine/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 10)
			L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		if(11 to 20)
			L.reagent_pain_modifier -= PAIN_REDUCTION_HEAVY
			L.jitter(4)
		if(21 to 30)
			L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_HEAVY
			L.jitter(6)
		if(31 to INFINITY)
			L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_HEAVY * 1.5 //bad times ahead
			L.jitter(8)

	if(current_cycle > 21)
		L.adjustStaminaLoss(effect_str)
		if(iscarbon(L) && prob(min(current_cycle - 10,30)))
			var/mob/living/carbon/C = L
			C.emote("me", 1, "coughs up blood!")
			C.drip(10)
		if(prob(min(current_cycle - 5,30)))
			L.emote("me", 1, "gasps for air!")
			L.Losebreath(4)
		if(L.eye_blurry < 30)
			L.adjust_blurriness(1.3)
	else
		L.adjustStaminaLoss(0.5*effect_str)
		if(prob(20))
			L.emote("gasp")
			L.Losebreath(3)

	return ..()
