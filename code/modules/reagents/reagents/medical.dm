
// All reagents related to medicine

/datum/reagent/medicine
	name = "Medicine"
	taste_description = "bitterness"
	reagent_state = LIQUID
	taste_description = "bitterness"

/datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE*2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL*2
	scannable = TRUE
	trait_flags = TACHYCARDIC

/datum/reagent/medicine/inaprovaline/on_mob_add(mob/living/L, metabolism)
	var/mob/living/carbon/human/H = L
	if(TIMER_COOLDOWN_CHECK(L, name))
		return
	if(L.health < H.health_threshold_crit && volume > 14) //If you are in crit, and someone injects at least 15u into you at once, you will heal 30% of your physical damage instantly.
		to_chat(L, span_userdanger("You feel a rush of energy as stimulants course through your veins!"))
		L.adjustBruteLoss(-L.getBruteLoss() * 0.30)
		L.adjustFireLoss(-L.getFireLoss() * 0.30)
		L.jitter(5)
		for(var/datum/internal_organ/I AS in H.internal_organs)
			if(I.damage)
				if(I.damage < 29)
					return
				I.heal_organ_damage((I.damage-29) *effect_str)
		TIMER_COOLDOWN_START(L, name, 300 SECONDS)

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/L, metabolism)
	L.reagent_shock_modifier += PAIN_REDUCTION_LIGHT
	if(metabolism & IS_VOX)
		L.adjustToxLoss(REAGENTS_METABOLISM)
	else if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.losebreath > 10)
			C.set_Losebreath(10)
	return ..()

/datum/reagent/medicine/inaprovaline/overdose_process(mob/living/L, metabolism)
	L.jitter(5) //Overdose causes a spasm
	L.Unconscious(40 SECONDS)

/datum/reagent/medicine/inaprovaline/overdose_crit_process(mob/living/L, metabolism)
	L.setDrowsyness(L.drowsyness, 20)
	if(ishuman(L)) //Critical overdose causes total blackout and heart damage. Too much stimulant
		var/mob/living/carbon/human/H = L
		var/datum/internal_organ/heart/E = H.internal_organs_by_name["heart"]
		E.take_damage(0.5*effect_str, TRUE)
	if(prob(10))
		L.emote(pick("twitch","blink_r","shiver"))

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	description = "Kelotane is a drug used to treat burns."
	color = "#D8C58C"
	scannable = TRUE
	purge_list = list(/datum/reagent/medicine/ryetalyn)
	purge_rate = 1
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/L, metabolism)
	var/target_temp = L.get_standard_bodytemperature()
	L.heal_limb_damage(0, effect_str)
	if(L.bodytemperature > target_temp)
		L.adjust_bodytemperature(-2.5*TEMPERATURE_DAMAGE_COEFFICIENT*effect_str, target_temp)
	if(volume > 10)
		L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_LIGHT
	if(volume > 20)
		L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		L.heal_limb_damage(0, 0.5*effect_str)
	return ..()

/datum/reagent/medicine/kelotane/overdose_process(mob/living/L, metabolism)
	L.apply_damages(effect_str, 0, effect_str)

/datum/reagent/medicine/kelotane/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(2*effect_str, 0, 2*effect_str)

/datum/reagent/medicine/dermaline
	name = "Dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	color = "#F8C57C"
	overdose_threshold = REAGENTS_OVERDOSE*0.5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL*0.5
	scannable = TRUE
	purge_list = list(/datum/reagent/medicine/oxycodone)
	purge_rate = 0.2

/datum/reagent/medicine/dermaline/on_mob_life(mob/living/L, metabolism)
	var/target_temp = L.get_standard_bodytemperature()
	L.heal_limb_damage(0, 2*effect_str)
	if(L.bodytemperature > target_temp)
		L.adjust_bodytemperature(-5*TEMPERATURE_DAMAGE_COEFFICIENT*effect_str, target_temp)
	if(volume > 5)
		L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
	if(volume > 10)
		L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		L.heal_limb_damage(0, 1.5*effect_str)
	return ..()

/datum/reagent/medicine/dermaline/overdose_process(mob/living/L, metabolism)
	L.apply_damages(effect_str, 0, effect_str)

/datum/reagent/medicine/dermaline/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(3*effect_str, 0, 3*effect_str)

/datum/reagent/medicine/dylovene
	name = "Dylovene"
	description = "Dylovene is a broad-spectrum antitoxin."
	color = "#A8F59C"
	scannable = TRUE
	purge_list = list(/datum/reagent/toxin, /datum/reagent/medicine/research/stimulon, /datum/reagent/consumable/drink/atomiccoffee, /datum/reagent/medicine/paracetamol, /datum/reagent/medicine/larvaway)
	purge_rate = 1
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "a roll of gauze"

/datum/reagent/medicine/dylovene/on_mob_life(mob/living/L,metabolism)
	L.hallucination = max(0, L.hallucination -  2.5*effect_str)
	L.adjustToxLoss(-effect_str)
	if(volume > 10)
		L.adjustStaminaLoss(0.5*effect_str)
	return ..()

/datum/reagent/medicine/dylovene/overdose_process(mob/living/L, metabolism)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
	if(E)
		E.take_damage(0.5*effect_str, TRUE)

/datum/reagent/medicine/dylovene/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(2*effect_str, 2*effect_str)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/datum/internal_organ/eyes/E = H.internal_organs_by_name["eyes"]
		if(E)
			E.take_damage(1.5*effect_str, TRUE)

/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	color = "#E8756C"
	purge_list = list(/datum/reagent/medicine/ryetalyn)
	purge_rate = 1
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = TRUE

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(effect_str, 0)
	if(volume > 10)
		L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_LIGHT
	if(volume > 20)
		L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		L.heal_limb_damage(0.5*effect_str, 0)
	return ..()

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/L, metabolism)
	L.apply_damage(effect_str, BURN)

/datum/reagent/medicine/bicaridine/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(effect_str, 3*effect_str, 2*effect_str)

/datum/reagent/medicine/meralyne
	name = "Meralyne"
	description = "Meralyne is a concentrated form of bicardine and can be used to treat extensive blunt trauma."
	color = "#E6666C"
	overdose_threshold = REAGENTS_OVERDOSE*0.5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL*0.5
	scannable = TRUE
	purge_list = list(/datum/reagent/medicine/oxycodone)
	purge_rate = 0.2

/datum/reagent/medicine/meralyne/on_mob_life(mob/living/L, metabolism)
	L.heal_limb_damage(2*effect_str, 0)
	if(volume > 5)
		L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
	if(volume > 10)
		L.reagent_pain_modifier -= PAIN_REDUCTION_LIGHT
		L.heal_limb_damage(1.5*effect_str, 0)
	return ..()


/datum/reagent/medicine/meralyne/overdose_process(mob/living/L, metabolism)
	L.apply_damage(2*effect_str, BURN)

/datum/reagent/medicine/meralyne/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(2*effect_str, 6*effect_str, 4*effect_str)

/datum/reagent/hypervene // this isn't under /medicine so things that purge /datum/reagent/medicine like neuro/larval don't purge it
	name = "Hypervene"
	description = "Quickly purges the body of toxin damage, radiation and all other chemicals. Causes significant pain."
	color = "#19C832"
	overdose_threshold = REAGENTS_OVERDOSE * 0.5
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL * 0.5
	custom_metabolism = REAGENTS_METABOLISM * 5
	purge_list = list(/datum/reagent/medicine, /datum/reagent/toxin, /datum/reagent/zombium)
	purge_rate = 5
	scannable = TRUE
	taste_description = "punishment"
	taste_multi = 8

/datum/reagent/hypervene/on_mob_life(mob/living/L, metabolism)
	L.reagent_shock_modifier -= PAIN_REDUCTION_HEAVY //Significant pain while metabolized.
	if(prob(5)) //causes vomiting
		L.vomit()
	return ..()

/datum/reagent/hypervene/overdose_process(mob/living/L, metabolism)
	L.apply_damages(effect_str, effect_str)
	if(prob(10)) //heavy vomiting
		L.vomit()
	L.reagent_shock_modifier -= PAIN_REDUCTION_VERY_HEAVY * 1.25//Massive pain.

/datum/reagent/hypervene/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(2*effect_str, 2*effect_str)
	if(prob(50)) //violent vomiting
		L.vomit()
	L.reagent_shock_modifier -= PAIN_REDUCTION_VERY_HEAVY * 4 //Unlimited agony.
