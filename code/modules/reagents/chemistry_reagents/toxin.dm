

//////////////////////////Poison stuff///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	description = "A toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	taste_description = "bitterness"
	taste_multi = 1.2

/datum/reagent/toxin/on_mob_life(mob/living/L, metabolism)
	if(toxpwr)
		L.adjustToxLoss(toxpwr*REM)
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
	L.adjustOxyLoss(2*REM)
	return ..()


/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 1
	taste_description = "mushrooms"

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = "#13BC5E" // rgb: 19, 188, 94
	toxpwr = 0
	taste_description = "slime"
	taste_multi = 0.9

/datum/reagent/toxin/mutagen/on_mob_life(mob/living/L, metabolism)
	L.apply_effect(10, IRRADIATE)
	return ..()

/datum/reagent/toxin/phoron
	name = "Phoron"
	description = "Phoron in its liquid form."
	color = "#E71B00" // rgb: 231, 27, 0
	toxpwr = 3

/datum/reagent/toxin/phoron/on_mob_life(mob/living/L, metabolism)
	holder.remove_reagent(/datum/reagent/medicine/inaprovaline, 2*REM)
	return ..()

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	color = "#C8A5DC" // rgb: 200, 165, 220
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "acid"

/datum/reagent/toxin/lexorin/on_mob_life(mob/living/L, metabolism)
	if(prob(33))
		L.take_limb_damage(REM, 0)
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
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 3
	custom_metabolism = REAGENTS_METABOLISM * 2

/datum/reagent/toxin/cyanide/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(4*REM)
	if(current_cycle > 10)
		L.Sleeping(40)
	return ..()

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0
	taste_description = "mint"

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded space carp."
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 2
	taste_description = "fish"

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5
	taste_description = "death"

/datum/reagent/toxin/zombiepowder/on_mob_add(mob/living/L, metabolism)
	ADD_TRAIT(L, TRAIT_FAKEDEATH, type)
	return ..()

/datum/reagent/toxin/zombiepowder/on_mob_life(mob/living/L, metabolism)
	L.adjustOxyLoss(0.5*REM)
	L.Paralyze(20 SECONDS)
	return ..()

/datum/reagent/toxin/zombiepowder/on_mob_delete(mob/living/L, metabolism)
	REMOVE_TRAIT(L, TRAIT_FAKEDEATH, type)
	return ..()

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	description = "A powerful hallucinogen, it can cause fatal effects in users."
	color = "#B31008" // rgb: 139, 166, 233
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
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/toxin/fertilizer/eznutrient
	name = "EZ Nutrient"

/datum/reagent/toxin/fertilizer/left4zed
	name = "Left-4-Zed"

/datum/reagent/toxin/fertilizer/robustharvest
	name = "Robust Harvest"

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1
	taste_multi = 1

/datum/reagent/toxin/plantbgone/reaction_obj(obj/O, volume)
	if(istype(O,/obj/effect/alien/weeds))
		var/obj/effect/alien/A = O
		A.take_damage(min(0.5 * volume))
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment))
		if(prob(50)) qdel(O) //Kills kudzu too.
	else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = O

		if(tray.seed)
			tray.health -= rand(30,50)
			if(tray.pestlevel > 0)
				tray.pestlevel -= 2
			if(tray.weedlevel > 0)
				tray.weedlevel -= 3
			tray.toxins += 4
			tray.check_level_sanity()
			tray.update_icon()

/datum/reagent/toxin/plantbgone/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(H.species.species_flags & IS_PLANT) //plantmen take a LOT of damage
		H.adjustToxLoss(10 * touch_protection)

/datum/reagent/toxin/sleeptoxin
	name = "Soporific"
	description = "An effective hypnotic used to treat insomnia."
	color = "#E895CC" // rgb: 232, 149, 204
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = 1
	taste_description = "cough syrup"
	trait_flags = BRADYCARDICS

/datum/reagent/toxin/sleeptoxin/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 12)
			if(prob(5))
				L.emote("yawn")
		if(13 to 15)
			L.blur_eyes(10)
		if(16 to 40)
			if(prob(10))
				L.Sleeping(20 SECONDS)
			L.drowsyness  = max(L.drowsyness, 20)
		if(41 to INFINITY)
			L.Sleeping(40 SECONDS) //previously knockdown, no good for a soporific.
			L.drowsyness  = max(L.drowsyness, 30)
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
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0
	custom_metabolism = REAGENTS_METABOLISM * 0.5
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2

/datum/reagent/toxin/chloralhydrate/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 20)
			L.AdjustConfused(40)
			L.adjustDrowsyness(2)
		if(21 to 60)
			L.Sleeping(10 SECONDS)
		if(61 to INFINITY)
			L.Sleeping(10 SECONDS)
			L.adjustToxLoss((current_cycle/2 - 50)*REM)
	return ..()

/datum/reagent/toxin/chloralhydrate/overdose_process(mob/living/L, metabolism)
	L.apply_damages(0, 0, 1, 2)

/datum/reagent/toxin/chloralhydrate/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(0, 0, 0, 2)

/datum/reagent/toxin/potassium_chloride
	name = "Potassium Chloride"
	description = "A delicious salt that stops the heart when injected into cardiac muscle."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
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
	color = "#FFFFFF" // rgb: 255,255,255
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

/datum/reagent/toxin/beer2	//disguised as normal beer
	name = "Beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water. The fermentation appears to be incomplete." //If the players manage to analyze this, they deserve to know something is wrong.
	color = "#664300" // rgb: 102, 67, 0
	custom_metabolism = REAGENTS_METABOLISM * 2.5
	taste_description = "piss water"

/datum/reagent/toxin/beer2/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 50)
			L.Sleeping(10 SECONDS)
		if(51 to INFINITY)
			L.Sleeping(10 SECONDS)
			L.adjustToxLoss((current_cycle - 50)*REM)
	return ..()

/datum/reagent/toxin/plasticide
	name = "Plasticide"
	description = "Liquid plastic, do not eat."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0.2
	taste_description = "plastic"

/datum/reagent/toxin/plasticide/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(0.2)
	return ..()

/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	description = "A very corrosive mineral acid with the molecular formula H2SO4."
	spray_warning = TRUE
	color = "#DB5008" // rgb: 219, 80, 8
	toxpwr = 1
	var/meltprob = 10
	taste_description = "acid"

/datum/reagent/toxin/acid/on_mob_life(mob/living/L, metabolism)
	L.take_limb_damage(0, REM)
	return ..()

/datum/reagent/toxin/acid/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(method in list(TOUCH, VAPOR, PATCH)))
		return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L

		if(H.head)
			if(prob(meltprob) && !CHECK_BITFIELD(H.head.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
				if(show_message)
					to_chat(H, "<span class='danger'>Your headgear melts away but protects you from the acid!</span>")
				qdel(H.head)
				H.update_inv_head(0)
				H.update_hair(0)
			else if(show_message)
				to_chat(H, "<span class='warning'>Your headgear protects you from the acid.</span>")
			return

		if(H.wear_mask)
			if(prob(meltprob) && !CHECK_BITFIELD(H.wear_mask.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
				if(show_message)
					to_chat(H, "<span class='danger'>Your mask melts away but protects you from the acid!</span>")
				qdel(H.wear_mask)
				H.update_inv_wear_mask(0)
				H.update_hair(0)
			else if(show_message)
				to_chat(H, "<span class='warning'>Your mask protects you from the acid.</span>")
			return

		if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
			if(prob(meltprob) && !CHECK_BITFIELD(H.glasses.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
				if(show_message)
					to_chat(H, "<span class='danger'>Your glasses melts away!</span>")
				qdel(H.glasses)
				H.update_inv_glasses(0)

	else if(ismonkey(L))
		var/mob/living/carbon/monkey/MK = L
		if(MK.wear_mask)
			if(!CHECK_BITFIELD(MK.wear_mask.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
				if(show_message)
					to_chat(MK, "<span class='danger'>Your mask melts away but protects you from the acid!</span>")
				qdel(MK.wear_mask)
				MK.update_inv_wear_mask(0)
			else if(show_message)
				to_chat(MK, "<span class='warning'>Your mask protects you from the acid.</span>")
			return

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
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(meltprob * 3))
		if(!CHECK_BITFIELD(O.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			O.visible_message("<span class='warning'>\the [O] melts.</span>", null, 5)
			qdel(O)

/datum/reagent/toxin/acid/polyacid
	name = "Polytrinic acid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	color = "#8E18A9" // rgb: 142, 24, 169
	toxpwr = 2
	meltprob = 30
	taste_multi = 1.5

/datum/reagent/toxin/xeno_neurotoxin
	name = "Neurotoxin"
	description = "A debilitating nerve toxin. Impedes motor control in high doses. Causes progressive loss of mobility over time."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	custom_metabolism = REAGENTS_METABOLISM * 2 //otherwise it defaults to half of that
	purge_list = list(/datum/reagent/medicine) 
	purge_rate = 1
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 1.2 //make this a little more forgiving in light of the lethality
	scannable = TRUE
	toxpwr = 0


/datum/reagent/toxin/xeno_neurotoxin/on_mob_life(mob/living/L, metabolism)
	switch(current_cycle)
		if(1 to 20)
			L.adjustStaminaLoss(4*REM) //While stamina loss is going, stamina regen apparently doesn't happen, so I can keep this smaller.
			L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		if(21 to 45)
			L.adjustStaminaLoss(12*REM)
			L.reagent_pain_modifier -= PAIN_REDUCTION_HEAVY
		if(46 to INFINITY)
			L.adjustStaminaLoss(30*REM)
			L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_HEAVY
	L.adjust_drugginess(1.1)
	L.stuttering = max(L.stuttering, 1)
	return ..()


/datum/reagent/toxin/xeno_neurotoxin/overdose_process(mob/living/L, metabolism)
	L.adjustToxLoss(REM) //Overdose starts applying toxin and oxygen damage. Long-term overdose will kill the host.
	L.adjustOxyLoss(REM)
	L.jitter(4) //Lets Xenos know they're ODing and should probably stop.


/datum/reagent/toxin/xeno_neurotoxin/overdose_crit_process(mob/living/L, metabolism)
	L.Losebreath(1) //Can't breathe; for punishing the bullies

/datum/reagent/toxin/xeno_growthtoxin
	name = "Larval Accelerant"
	description = "A metabolic accelerant that dramatically increases the rate of larval growth in a host."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	purge_list = list(/datum/reagent/toxin/xeno_neurotoxin, /datum/reagent/medicine) 
	purge_rate = 3
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	toxpwr = 0
	scannable = TRUE

/datum/reagent/toxin/xeno_growthtoxin/on_mob_life(mob/living/L)
	var/target_temp = L.get_standard_bodytemperature()
	if(L.getBruteLoss() || L.getFireLoss())
		L.heal_limb_damage(REM, REM)
	if(L.getToxLoss())
		L.adjustToxLoss(-REM)
	if(L.bodytemperature > target_temp) 
		L.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)
	L.reagent_pain_modifier += PAIN_REDUCTION_VERY_HEAVY
	L.jitter(1) //So unga know to get treated
	return ..()

/datum/reagent/toxin/xeno_growthtoxin/overdose_process(mob/living/L, metabolism)
	L.adjustOxyLoss(2)
	L.jitter(4)

/datum/reagent/toxin/xeno_growthtoxin/overdose_crit_process(mob/living/L, metabolism)
	L.Losebreath(2)
