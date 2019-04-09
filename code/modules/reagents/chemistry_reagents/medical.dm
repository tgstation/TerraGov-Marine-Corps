
// All reagents related to medicine

/datum/reagent/medicine
	name = "Medicine"
	id = "medicine"
	taste_description = "bitterness"
	reagent_state = LIQUID
	taste_description = "bitterness"

/datum/reagent/medicine/on_mob_life(mob/living/carbon/M)
	purge(M)
	current_cycle++
	holder.remove_reagent(src.id, custom_metabolism / M.metabolism_efficiency) //so far metabolism efficiency is fixed to 1, but medicine reagents last longer the better it is.


/datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE*2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL*2
	scannable = TRUE

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/M, alien)
	M.reagent_shock_modifier += PAIN_REDUCTION_LIGHT
	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REAGENTS_METABOLISM)
	else
		if(M.losebreath > 10)
			M.set_Losebreath(10)
	..()

/datum/reagent/medicine/inaprovaline/overdose_process(mob/living/M, alien)
	M.Jitter(5) //Overdose causes a spasm
	M.KnockOut(20)

/datum/reagent/medicine/inaprovaline/overdose_crit_process(mob/living/M, alien)
	M.drowsyness = max(M.drowsyness, 20)
	if(ishuman(M)) //Critical overdose causes total blackout and heart damage. Too much stimulant
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		E.take_damage(0.5, TRUE)
		if(prob(10))
			M.emote(pick("twitch","blink_r","shiver"))

/datum/reagent/medicine/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities via a catalytic process."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/medicine/ryetalyn/on_mob_life(mob/living/M)
	M.mutations = list()
	M.disabilities = 0
	M.sdisabilities = 0
	// Might need to update appearance for hulk etc.
	if(M.mutations.len)
		var/mob/living/carbon/human/H = M
		H.update_mutations()
	..()

/datum/reagent/medicine/ryetalyn/overdose_process(mob/living/M, alien)
	M.confused = max(M.confused, 20)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/ryetalyn/overdose_crit_process(mob/living/M, alien)
	if(prob(15))
		M.KnockOut(15)
	M.apply_damage(3, CLONE)

/datum/reagent/medicine/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
	color = "#C855DC"
	scannable = TRUE
	custom_metabolism = 0.025 // Lasts 10 minutes for 15 units
	overdose_threshold = REAGENTS_OVERDOSE*2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL*2

/datum/reagent/medicine/paracetamol/on_mob_life(mob/living/M)
	M.reagent_pain_modifier += PAIN_REDUCTION_HEAVY
	..()

/datum/reagent/paracetamol/overdose_process(mob/living/M, alien)
	M.hallucination = max(M.hallucination, 2)
	M.apply_damage(1, TOX)

/datum/reagent/paracetamol/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(3, TOX)

/datum/reagent/medicine/tramadol
	name = "Tramadol"
	id = "tramadol"
	description = "A simple, yet effective painkiller."
	color = "#C8A5DC"
	scannable = TRUE
	custom_metabolism = 0.1 // Lasts 10 minutes for 15 units
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/medicine/tramadol/on_mob_life(mob/living/M)
	M.reagent_pain_modifier += PAIN_REDUCTION_VERY_HEAVY
	..()

/datum/reagent/medicine/tramadol/overdose_process(mob/living/M, alien)
	M.hallucination = max(M.hallucination, 2) //Hallucinations and tox damage
	M.apply_damage(1, OXY)

/datum/reagent/medicine/tramadol/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(3, TOX)

/datum/reagent/medicine/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	description = "An effective and very addictive painkiller."
	color = "#C805DC"
	custom_metabolism = 0.25 // Lasts 10 minutes for 15 units
	overdose_threshold = REAGENTS_OVERDOSE * 0.66
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 0.66
	scannable = TRUE

/datum/reagent/medicine/oxycodone/on_mob_life(mob/living/M)
	M.reagent_pain_modifier += PAIN_REDUCTION_FULL
	..()

/datum/reagent/medicine/oxycodone/overdose_process(mob/living/M, alien)
	M.hallucination = max(M.hallucination, 3)
	M.set_drugginess(10)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/oxycodone/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(3, TOX)

/datum/reagent/medicine/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/medicine/sterilizine/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method in list(TOUCH, VAPOR, PATCH))
		M.germ_level -= min(volume*20, M.germ_level)
		if((M.getFireLoss() > 30 || M.getBruteLoss() > 30) && prob(10)) // >Spraying space bleach on open wounds
			to_chat(M, "<span class='warning'>Your open wounds feel like they're on fire!</span>")
			M.emote(pick("scream","pain","moan"))
			M.reagent_shock_modifier -= PAIN_REDUCTION_MEDIUM

/datum/reagent/medicine/sterilizine/reaction_obj(var/obj/O, var/volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/medicine/sterilizine/reaction_turf(var/turf/T, var/volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/medicine/sterilizine/on_mob_life(mob/living/M)
	M.adjustToxLoss(2*REM)
	..()

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	id = "leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	color = "#C8A5DC" // rgb: 200, 165, 220
	scannable = TRUE
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/M)
	var/target_temp = M.get_standard_bodytemperature()
	if(M.bodytemperature > target_temp)
		M.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)
	else if(M.bodytemperature < target_temp + 1)
		M.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, target_temp)
	return ..()

/datum/reagent/medicine/leporazine/overdose_process(mob/living/M, alien)
	if(prob(10))
		M.KnockOut(15)

/datum/reagent/medicine/leporazine/overdose_crit_process(mob/living/M, alien)
	M.drowsyness  = max(M.drowsyness, 30)

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Kelotane is a drug used to treat burns."
	color = "#D8C58C"
	scannable = TRUE
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/medicine/kelotane/on_mob_life(var/mob/living/M)
	M.heal_limb_damage(0, 2 * REM)
	..()

/datum/reagent/medicine/kelotane/overdose_process(mob/living/M, alien)
	M.apply_damages(1, 0, 1)

/datum/reagent/medicine/kelotane/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, 0, 2)

/datum/reagent/medicine/dermaline
	name = "Dermaline"
	id = "dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	color = "#F8C57C"
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2
	scannable = TRUE

/datum/reagent/medicine/dermaline/on_mob_life(mob/living/M, alien)
	if(!alien)
		M.heal_limb_damage(0, 3 * REM)
	..()

/datum/reagent/medicine/dermaline/overdose_process(mob/living/M, alien)
	M.apply_damages(1, 0, 1)

/datum/reagent/medicine/dermaline/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(3, 0, 3)

/datum/reagent/medicine/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	color = "#C865FC"
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE

/datum/reagent/medicine/dexalin/on_mob_life(mob/living/M,alien)
	if(alien == IS_VOX)
		M.adjustToxLoss(2*REM)
	else
		M.adjustOxyLoss(-2*REM)

	holder.remove_reagent("lexorin", 2 * REM)
	..()

/datum/reagent/medicine/dexalin/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/dexalin/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, 0, 2)

/datum/reagent/medicine/dexalinplus
	name = "Dexalin Plus"
	id = "dexalinplus"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. It is highly effective."
	color = "#C8A5FC"
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2
	scannable = TRUE

/datum/reagent/medicine/dexalinplus/on_mob_life(mob/living/M,alien)
	if(alien == IS_VOX)
		M.adjustToxLoss(3*REM)
	else if(!alien)
		M.adjustOxyLoss(-M.getOxyLoss())
	holder.remove_reagent("lexorin", 2*REM)
	..()

/datum/reagent/medicine/dexalinplus/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/dexalinplus/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, 0, 3)

/datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	color = "#B865CC"
	scannable = TRUE
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "grossness"

/datum/reagent/medicine/tricordrazine/on_mob_life(mob/living/M, alien)
	if(!alien)
		if(M.getOxyLoss())
			M.adjustOxyLoss(-REM)
		if(M.getBruteLoss() && prob(80))
			M.heal_limb_damage(REM, 0)
		if(M.getFireLoss() && prob(80))
			M.heal_limb_damage(0, REM)
		if(M.getToxLoss() && prob(80))
			M.adjustToxLoss(-REM)
	..()

/datum/reagent/medicine/tricordrazine/overdose_process(mob/living/M, alien)
	M.Jitter(5)
	M.adjustBrainLoss(1, TRUE)

/datum/reagent/medicine/tricordrazine/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(3, 3, 3)

/datum/reagent/medicine/dylovene
	name = "Dylovene"
	id = "dylovene"
	description = "Dylovene is a broad-spectrum antitoxin."
	color = "#A8F59C"
	scannable = TRUE
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "a roll of gauze"

/datum/reagent/medicine/dylovene/on_mob_life(mob/living/M,alien)
	if(!alien)
		M.reagents.remove_all_type(/datum/reagent/toxin, REM, 0, 1)
		M.drowsyness = max(M.drowsyness- 2 * REM, 0)
		M.hallucination = max(0, M.hallucination -  5 * REM)
		M.adjustToxLoss(-2 * REM)
	..()

/datum/reagent/medicine/dylovene/overdose_process(mob/living/carbon/M, alien)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
		if(E)
			E.take_damage(0.5, TRUE)

/datum/reagent/medicine/dylovene/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, 2) //Starts detoxing, hard
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
		if(E)
			E.take_damage(1.5, TRUE)

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "badmins"

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_limb_damage(5,5)
	M.adjustToxLoss(-5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.set_blurriness(0, TRUE)
	M.set_blindness(0, TRUE)
	M.SetKnockeddown(0)
	M.SetStunned(0)
	M.SetKnockedout(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.SetSleeping(0)
	M.jitteriness = 0
	M.drunkenness = 0
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	..()


/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat various diseases."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.1
	overdose_threshold = REAGENTS_OVERDOSE/5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/5
	scannable = TRUE

datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	M.reagent_shock_modifier += PAIN_REDUCTION_MEDIUM
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustKnockedout(-1)
	M.AdjustStunned(-1)
	M.AdjustKnockeddown(-1)
	holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(80))
		M.adjustToxLoss(1)
	..()

datum/reagent/medicine/synaptizine/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

datum/reagent/medicine/synaptizine/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(1, 1, 1)

/datum/reagent/medicine/neuraline //injected by neurostimulator implant
	name = "Neuraline"
	id = "neuraline"
	description = "A chemical cocktail tailored to enhance or dampen specific neural processes."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.4
	overdose_threshold = 2
	overdose_crit_threshold = 3
	scannable = FALSE

/datum/reagent/medicine/neuraline/on_mob_life(mob/living/M)
	M.reagent_shock_modifier += PAIN_REDUCTION_FULL
	M.drowsyness = max(M.drowsyness-5, 0)
	M.Dizzy(-5)
	M.stuttering = max(M.stuttering-5, 0)
	var/mob/living/carbon/C = M
	C.drunkenness = max(C.drunkenness-5, 0)
	M.confused = max(M.confused-5, 0)
	M.adjust_blurriness(-5)
	M.AdjustKnockedout(-2)
	M.AdjustStunned(-2)
	M.AdjustKnockeddown(-1)
	M.AdjustSleeping(-2)
	..()

/datum/reagent/medicine/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE

/datum/reagent/medicine/hyronalin/on_mob_life(var/mob/living/M as mob)
	M.radiation = max(M.radiation-3*REM,0)
	..()

/datum/reagent/medicine/hyronalin/overdose_process(mob/living/M, alien)
	M.apply_damage(2, TOX)

/datum/reagent/medicine/hyronalin/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(0, 1, 1)

/datum/reagent/medicine/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.05
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2

/datum/reagent/medicine/arithrazine/on_mob_life(mob/living/M)
	M.radiation = max(M.radiation-7*REM,0)
	M.adjustToxLoss(-1*REM)
	if(prob(15))
		M.take_limb_damage(1, 0)
	..()

/datum/reagent/medicine/arithrazine/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/arithrazine/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(1, 1, 2)

/datum/reagent/medicine/russianred
	name = "Russian Red"
	id = "russianred"
	description = "An emergency radiation treatment, however it has extreme side effects."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 1
	overdose_threshold = REAGENTS_OVERDOSE/3
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/3
	scannable = TRUE

/datum/reagent/medicine/russianred/on_mob_life(mob/living/carbon/M)
	M.radiation = max(M.radiation - 10 * REM, 0)
	M.drunkenness = max(M.drunkenness - 2)
	M.adjustToxLoss(-1*REM)
	if(prob(50))
		M.take_limb_damage(3, 0)
	..()

/datum/reagent/medicine/russianred/overdose_process(mob/living/M, alien)
	M.apply_damages(1, 0, 0)
	M.adjustBrainLoss(1, TRUE)

/datum/reagent/medicine/russianred/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(1, 2, 1)
	M.adjustBrainLoss(1, TRUE)

/datum/reagent/medicine/alkysine
	name = "Alkysine"
	id = "alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	color = "#E89599"
	custom_metabolism = 0.05
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE

/datum/reagent/medicine/alkysine/on_mob_life(mob/living/M)
	M.reagent_shock_modifier += PAIN_REDUCTION_VERY_LIGHT
	M.adjustBrainLoss(-3 * REM)
	..()

/datum/reagent/medicine/alkysine/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/alkysine/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(0, 1, 1)

/datum/reagent/medicine/imidazoline
	name = "Imidazoline"
	id = "imidazoline"
	description = "Heals eye damage"
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE
	taste_description = "dull toxin"

/datum/reagent/medicine/imidazoline/on_mob_life(mob/living/M)
	M.adjust_blurriness(-5)
	M.adjust_blindness(-5)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
		if(E)
			E.heal_damage(1)
	..()

/datum/reagent/medicine/imidazoline/overdose_process(mob/living/M, alien)
	M.apply_damage(2, TOX)

/datum/reagent/medicine/imidazoline/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(0, 1, 2)

/datum/reagent/medicine/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	description = "Used to stabilize internal organs while waiting for surgery, and fixes organ damage at cryogenic temperatures. Medicate cautiously."
	color = "#C845DC"
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2
	custom_metabolism = 0.05
	scannable = TRUE

/datum/reagent/medicine/peridaxon/on_mob_life(mob/living/M)
    if(ishuman(M))
        var/mob/living/carbon/human/H = M
        for(var/datum/internal_organ/I in H.internal_organs)
            if(I.damage)
                if(M.bodytemperature > 169 && I.damage > 5)
                    continue
                I.heal_damage(1)
    return ..()

/datum/reagent/medicine/peridaxon/overdose_process(mob/living/M, alien)
	M.apply_damage(2, BRUTE)

/datum/reagent/peridaxon/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(1, 3, 3)

/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	color = "#E8756C"
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/M, alien)
	M.heal_limb_damage(2*REM,0)
	..()


/datum/reagent/medicine/bicaridine/overdose_process(mob/living/M, alien)
	M.apply_damage(1, BURN)

/datum/reagent/medicine/bicaridine/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(1, 3, 2)

/datum/reagent/medicine/meralyne
	name = "Meralyne"
	id = "meralyne"
	description = "Meralyne is a concentrated form of bicardine and can be used to treat extensive blunt trauma."
	color = "#E6666C"
	overdose_threshold = REAGENTS_OVERDOSE*0.5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL*0.5
	scannable = TRUE

/datum/reagent/medicine/meralyne/on_mob_life(mob/living/M, alien)
	. = ..()
	M.heal_limb_damage(4 * REM, 0)


/datum/reagent/medicine/meralyne/overdose_process(mob/living/M, alien)
	M.apply_damage(2, BURN)

/datum/reagent/medicine/meralyne/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, 6, 4)

/datum/reagent/medicine/quickclot
	name = "Quick Clot"
	id = "quickclot"
	description = "A chemical designed to quickly arrest all sorts of bleeding by encouraging coagulation. Can rectify internal bleeding at cryogenic temperatures."
	color = "#CC00FF"
	overdose_threshold = REAGENTS_OVERDOSE/2 //Was 4, now 6 //Now 15
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2
	scannable = TRUE //scannable now.  HUZZAH.
	custom_metabolism = 0.05

/datum/reagent/medicine/quickclot/on_mob_life(mob/living/M)
	if(!ishuman(M) || M.bodytemperature > 169) //only heals IB at cryogenic temperatures.
		return ..()
	var/mob/living/carbon/human/H = M
	for(var/datum/limb/X in H.limbs)
		for(var/datum/wound/W in X.wounds)
			if(W.internal)
				W.damage = max(0, W.damage - 1)
				X.update_damages()
				if (X.update_icon())
					X.owner.UpdateDamageIcon(1)
	return ..()


/datum/reagent/medicine/quickclot/overdose_process(mob/living/M, alien)
	M.apply_damage(2, BRUTE)

/datum/reagent/medicine/quickclot/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(0, 2, 2)

/datum/reagent/medicine/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	description = "Hyperzine is a highly effective, muscle and adrenal stimulant that massively accelerates metabolism.  May cause heart damage"
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.2
	overdose_threshold = REAGENTS_OVERDOSE/5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/5
	scannable = TRUE
	purge_list = list() //Does this purge any specific chems?
	purge_rate = 15 //rate at which it purges specific chems

/datum/reagent/medicine/hyperzine/on_mob_delete(mob/living/M)
	var/amount = current_cycle * 4
	M.adjustOxyLoss(amount)
	M.adjustHalLoss(amount)
	if(M.stat == DEAD)
		var/death_message = "<span class='danger'>Your body is unable to bear the strain. The last thing you feel, aside from crippling exhaustion, is an explosive pain in your chest as you drop dead. It's a sad thing your adventures have ended here!</span>"
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.species.species_flags & NO_PAIN)
				death_message = "<span class='danger'>Your body is unable to bear the strain. The last thing you feel as you drop dead is utterly crippling exhaustion. It's a sad thing your adventures have ended here!</span>"

		to_chat(M, "[death_message]")
	else
		switch(amount)
			if(1 to 20)
				to_chat(M, "<span class='warning'>You feel a bit tired.</span>")
			if(21 to 50)
				M.KnockDown(amount * 0.05)
				to_chat(M, "<span class='danger'>You collapse as a sudden wave of fatigue washes over you.</span>")
			if(50 to INFINITY)
				M.KnockOut(amount * 0.1)
				to_chat(M, "<span class='danger'>Your world convulses as a wave of extreme fatigue washes over you!</span>") //when hyperzine is removed from the body, there's a backlash as it struggles to transition and operate without the drug

	return ..()

/datum/reagent/medicine/hyperzine/on_mob_add(mob/living/L)
	purge_list.Add(/datum/reagent/medicine/dexalinplus, /datum/reagent/medicine/peridaxon) //Rapidly purges chems that would offset the downsides
	return ..()

/datum/reagent/medicine/hyperzine/on_mob_life(mob/living/M)
	M.reagent_move_delay_modifier -= min(2.5, volume * 0.5)
	M.nutrition = max(M.nutrition-(3 * REM * volume), 0) //Body burns through energy fast (also can't go under 0 nutrition)
	if(prob(1))
		M.emote(pick("twitch","blink_r","shiver"))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/internal_organ/heart/F = H.internal_organs_by_name["heart"]
			F.take_damage(1, TRUE)
	return ..()

/datum/reagent/medicine/hyperzine/overdose_process(mob/living/M, alien)
	if(ishuman(M))
		M.Jitter(5)
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(0.5, TRUE)
		if(prob(10))
			M.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/medicine/hyperzine/overdose_crit_process(mob/living/M, alien)
	if(ishuman(M))
		M.Jitter(10)
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(2, TRUE)
		if(prob(25))
			M.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/medicine/ultrazine
	name = "Ultrazine"
	id = "ultrazine"
	description = "A highly-potent, long-lasting combination CNS and muscle stimulant. Extremely addictive."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.0167 //5 units will last approximately 10 minutes
	overdose_threshold = 10
	overdose_crit_threshold = 20
	addiction_threshold = 0.4 // Adios Addiction Virus
	taste_multi = 2

/datum/reagent/medicine/ultrazine/on_mob_life(mob/living/carbon/C)
	C.reagent_move_delay_modifier -= 2
	if(prob(50))
		C.AdjustKnockeddown(-1)
		C.AdjustStunned(-1)
		C.AdjustKnockedout(-1)
	C.adjustHalLoss(-2)
	if(prob(2))
		C.emote(pick("twitch","blink_r","shiver"))
	return ..()

/datum/reagent/medicine/ultrazine/addiction_act_stage1(mob/living/carbon/C, alien)
	if(prob(10))
		to_chat(C, "<span class='notice'>[pick("You could use another hit.", "More of that would be nice.", "Another dose would help.", "One more dose wouldn't hurt", "Why not take one more?")]</span>")
	if(prob(5))
		C.emote(pick("twitch","blink_r","shiver"))
		C.adjustHalLoss(20)
	if(prob(20))
		C.hallucination += 10
	return

/datum/reagent/medicine/ultrazine/addiction_act_stage2(mob/living/carbon/C, alien)
	if(prob(10))
		to_chat(C, "<span class='warning'>[pick("It's just not the same without it.", "You could use another hit.", "You should take another.", "Just one more.", "Looks like you need another one.")]</span>")
	if(prob(5))
		C.emote("me",1, pick("winces slightly.", "grimaces."))
		C.adjustHalLoss(35)
		C.Stun(2)
	if(prob(20))
		C.hallucination += 15
		C.confused += 3
	return


/datum/reagent/medicine/ultrazine/addiction_act_stage3(mob/living/carbon/C, alien)
	if(prob(10))
		to_chat(C, "<span class='warning'>[pick("You need more.", "It's hard to go on like this.", "You want more. You need more.", "Just take another hit. Now.", "One more.")]</span>")
	if(prob(5))
		C.emote("me",1, pick("winces.", "grimaces.", "groans!"))
		C.adjustHalLoss(50)
		C.Stun(3)
	if(prob(20))
		C.hallucination += 20
		C.confused += 5
		C.Dizzy(60)
	C.adjustToxLoss(0.1)
	C.adjustBrainLoss(0.1, TRUE)
	return

/datum/reagent/medicine/ultrazine/addiction_act_stage4(mob/living/carbon/C, alien)
	if(prob(10))
		to_chat(C, "<span class='danger'>[pick("You need another dose, now. NOW.", "You can't stand it. You have to go back. You have to go back.", "You need more. YOU NEED MORE.", "MORE", "TAKE MORE.")]</span>")
	if(prob(5))
		C.emote("me",1, pick("groans painfully!", "contorts with pain!"))
		C.adjustHalLoss(65)
		C.Stun(4)
		C.do_jitter_animation(200)
	if(prob(20))
		C.hallucination += 30
		C.confused += 7
		C.Dizzy(80)
	C.adjustToxLoss(0.3)
	C.adjustBrainLoss(0.1, TRUE)
	if(prob(15) && ishuman(C))
		var/mob/living/carbon/human/H = C
		var/affected_organ = pick("heart","lungs","liver","kidneys")
		var/datum/internal_organ/I =  H.internal_organs_by_name[affected_organ]
		I.take_damage(2)
	return


/datum/reagent/medicine/ultrazine/overdose_process(mob/living/M, alien)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(0.5, TRUE)
		if(prob(10))
			M.emote(pick("twitch", "blink_r", "shiver"))

/datum/reagent/medicine/ultrazine/overdose_crit_process(mob/living/M, alien)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		if(E)
			E.take_damage(1.5, TRUE)

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	scannable = TRUE
	taste_description = "sludge"

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/M)
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-1)
		M.heal_limb_damage(1,1)
		M.adjustToxLoss(-1)
	..()

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	color = "#C8A5DC" // rgb: 200, 165, 220
	scannable = TRUE
	taste_description = "muscle"

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/M)
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_limb_damage(3,3)
		M.adjustToxLoss(-3)
	..()

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE
	taste_description = "fish"

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_limb_damage(1,1)
		if(16 to 35)
			M.adjustCloneLoss(-2)
			M.heal_limb_damage(2,1)
			M.status_flags &= ~DISFIGURED
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.name = H.get_visible_name()
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)
	..()

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/rezadone/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(2, TOX)

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antiviral agent."
	color = "#C8A5DC" // rgb: 200, 165, 220
	custom_metabolism = 0.01
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE

/datum/reagent/medicine/spaceacillin/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/spaceacillin/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(2, TOX)

/datum/reagent/medicine/ethylredoxrazine	// FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/medicine/ethylredoxrazine/on_mob_life(mob/living/M)
	M.Dizzy(-1)
	M.drowsyness = max(M.drowsyness-1, 0)
	M.stuttering = max(M.stuttering-1, 0)
	M.confused = max(M.confused-1, 0)
	var/mob/living/carbon/C = M
	C.drunkenness = max(C.drunkenness-4, 0)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, REM, 0, 1)
	..()

/datum/reagent/medicine/ethylredoxrazine/overdose_process(mob/living/M, alien)
	M.apply_damage(1, TOX)

/datum/reagent/medicine/ethylredoxrazine/overdose_crit_process(mob/living/M, alien)
	M.apply_damage(2, TOX)

///////RP CHEMS///////

#define ANTIDEPRESSANT_MESSAGE_DELAY 5*60*10

/datum/reagent/medicine/antidepressant
	name = "Antidepressant"
	id = "antidepressant"
	var/timer = 0

/datum/reagent/medicine/antidepressant/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	description = "Improves the ability to concentrate."
	color = "#C8A5DC"
	custom_metabolism = 0.01

/datum/reagent/medicine/antidepressant/methylphenidate/on_mob_add(mob/living/carbon/M)
	to_chat(M, "<span class='notice'>Your mind feels focused and undivided.</span>")

/datum/reagent/medicine/antidepressant/methylphenidate/on_mob_life(mob/living/carbon/M)
	if(world.time > timer + ANTIDEPRESSANT_MESSAGE_DELAY)
		timer = world.time
		to_chat(M, "<span class='notice'>Your mind feels focused and undivided.</span>")
	..()

/datum/reagent/medicine/antidepressant/methylphenidate/on_mob_delete(mob/living/carbon/M)
	to_chat(M, "<span class='warning'>You lose focus.</span>")
	..()

/datum/reagent/medicine/antidepressant/citalopram
	name = "Citalopram"
	id = "citalopram"
	description = "Stabilizes the mind a little."
	color = "#C8A5DC"
	custom_metabolism = 0.01

/datum/reagent/medicine/antidepressant/citalopram/on_mob_add(mob/living/carbon/M)
	to_chat(M, "<span class='notice'>Your mind feels stable.. a little stable.</span>")
	..()

/datum/reagent/medicine/antidepressant/citalopram/on_mob_life(mob/living/M)
	if(world.time > timer + ANTIDEPRESSANT_MESSAGE_DELAY)
		timer = world.time
		to_chat(M, "<span class='notice'>Your mind feels stable.. a little stable.</span>")
	..()

/datum/reagent/medicine/antidepressant/citalopram/on_mob_delete(mob/living/carbon/M)
	to_chat(M, "<span class='warning'>Your mind feels a little less stable...</span>")
	..()


/datum/reagent/medicine/antidepressant/paroxetine
	name = "Paroxetine"
	id = "paroxetine"
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	color = "#C8A5DC"
	custom_metabolism = 0.01

/datum/reagent/medicine/antidepressant/paroxetine/on_mob_add(mob/living/carbon/M)
	to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
	..()

/datum/reagent/medicine/antidepressant/paroxetine/on_mob_life(mob/living/carbon/M)
	if(world.time > timer + ANTIDEPRESSANT_MESSAGE_DELAY)
		timer = world.time
		if(prob(90))
			to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
		else
			to_chat(M, "<span class='warning'>Your mind breaks apart...</span>")
			M.hallucination += 200
	..()

/datum/reagent/medicine/antidepressant/paroxetine/on_mob_delete(mob/living/carbon/M)
	to_chat(M, "<span class='warning'>Your mind feels much less stable...</span>")
	..()

/datum/reagent/medicine/antized
	name = "Anti-Zed"
	id = "antiZed"
	description = "Destroys the zombie virus in living humans and prevents regeneration for those who have already turned."
	color = "#C8A5DC"
	custom_metabolism = 0.01

/datum/reagent/medicine/antized/on_mob_life(mob/living/carbon/human/M)
	M.regenZ = 0
	..()

/datum/reagent/medicine/hypervene
	name = "Hypervene"
	id = "hypervene"
	description = "Quickly purges the body of toxin damage, radiation and all other chemicals. Causes significant pain."
	color = "#19C832"
	overdose_threshold = REAGENTS_OVERDOSE * 0.5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 0.5
	custom_metabolism = REAGENTS_METABOLISM * 2
	scannable = TRUE
	taste_description = "punishment"
	taste_multi = 8

/datum/reagent/medicine/hypervene/on_mob_life(mob/living/M, alien)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,HYPERVENE_REMOVAL_AMOUNT * REM)
			if(R.id == "hyperzine")
				R.current_cycle += HYPERVENE_REMOVAL_AMOUNT * REM * 1 / max(1,custom_metabolism) //Increment hyperzine's purge cycle in proportion to the amount removed.
	M.reagent_shock_modifier -= PAIN_REDUCTION_HEAVY //Significant pain while metabolized.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(5)) //causes vomiting
			H.vomit()
	//M.adjustToxLoss(-4 * REM)
	//M.radiation = max(M.radiation-8*REM,0)
	..()

/datum/reagent/medicine/hypervene/overdose_process(mob/living/M, alien)
	M.apply_damages(1, 1) //Starts detoxing, hard
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(10)) //heavy vomiting
			H.vomit()
	if(ishuman(M))
		M.reagent_shock_modifier -= PAIN_REDUCTION_VERY_HEAVY * 1.25//Massive pain.

/datum/reagent/medicine/hypervene/overdose_crit_process(mob/living/M, alien)
	M.apply_damages(2, 2) //Starts detoxing, hard
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(20)) //violent vomiting
			H.vomit()
	if(ishuman(M))
		M.reagent_shock_modifier -= PAIN_REDUCTION_FULL //Unlimited agony.
