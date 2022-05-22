/datum/reagent/toxin/xeno_neurotoxin
	name = "Neurotoxin"
	description = "A debilitating nerve toxin. Impedes motor control in high doses. Causes progressive loss of mobility over time."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	custom_metabolism = REAGENTS_METABOLISM * 2
	overdose_threshold = 10000 //Overdosing for neuro is what happens when you run out of stamina to avoid its oxy and toxin damage
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_neurotoxin/on_mob_life(mob/living/L, metabolism)
	var/power
	switch(current_cycle)
		if(1 to 20)
			power = (2*effect_str) //While stamina loss is going, stamina regen apparently doesn't happen, so I can keep this smaller.
		if(21 to 45)
			power = (6*effect_str)
			L.jitter(4) //Shows that things are bad
		if(46 to INFINITY)
			power = (15*effect_str)
			L.reagent_pain_modifier -= PAIN_REDUCTION_VERY_HEAVY
			L.jitter(8) //Shows that things are *really* bad

	//Apply stamina damage, then apply any 'excess' stamina damage beyond our maximum as tox and oxy damage
	var/stamina_loss_limit = L.maxHealth * 2
	L.adjustStaminaLoss(min(power, max(0, stamina_loss_limit - L.staminaloss))) //If we're under our stamina_loss limit, apply the difference between our limit and current stamina damage or power, whichever's less

	var/stamina_excess_damage = (L.staminaloss + power) - stamina_loss_limit
	if(stamina_excess_damage > 0) //If we exceed maxHealth * 2 stamina damage, apply any excess as toxloss and oxyloss
		L.adjustToxLoss(stamina_excess_damage * 0.5)
		L.adjustOxyLoss(stamina_excess_damage * 0.5)
		L.Losebreath(2) //So the oxy loss actually means something.

	L.stuttering = max(L.stuttering, 1)

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
	color = "#602CFF"
	custom_metabolism = 0.4
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_hemodile/on_mob_life(mob/living/L, metabolism)

	var/slowdown_multiplier = 1

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox)) //Each other Defiler toxin increases the multiplier by 2x; 2x if we have 1 combo chem, 4x if we have 2
		slowdown_multiplier *= 2

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin))
		slowdown_multiplier *= 2

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_ozelomelyn))
		slowdown_multiplier *= 2

	switch(slowdown_multiplier) //Description varies in severity and probability with the multiplier
		if(0 to 1 && prob(10))
			to_chat(L, span_warning("You feel your legs tense up.") )
		if(2 to 3.9 && prob(20))
			to_chat(L, span_warning("You feel your legs go numb.") )
		if(4 to INFINITY && prob(30))
			to_chat(L, span_danger("You can barely feel your legs!") )

	L.add_movespeed_modifier(MOVESPEED_ID_XENO_HEMODILE, TRUE, 0, NONE, TRUE, 1.5 * slowdown_multiplier)

	return ..()

/datum/reagent/toxin/xeno_hemodile/on_mob_delete(mob/living/L, metabolism)
	L.remove_movespeed_modifier(MOVESPEED_ID_XENO_HEMODILE)


/datum/reagent/toxin/xeno_transvitox //when damage is received, converts brute/burn equal to 50% of damage received to tox damage
	name = "Transvitox"
	description = "Converts burn damage to toxin damage over time, and causes brute damage received to inflict extra toxin damage."
	reagent_state = LIQUID
	color = "#94FF00"
	custom_metabolism = 0.4
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_transvitox/on_mob_add(mob/living/L, metabolism, affecting)
	RegisterSignal(L, COMSIG_HUMAN_DAMAGE_TAKEN, .proc/transvitox_human_damage_taken)

/datum/reagent/toxin/xeno_transvitox/on_mob_life(mob/living/L, metabolism)
	var/fire_loss = L.getFireLoss()
	if(!fire_loss) //If we have no burn damage, cancel out
		return ..()

	if(prob(10))
		to_chat(L, span_warning("You notice your wounds crusting over with disgusting green ichor.") )

	var/tox_cap_multiplier = 1

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile)) //Each other Defiler toxin doubles the multiplier
		tox_cap_multiplier *= 2

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin))
		tox_cap_multiplier *= 2

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

	var/tox_cap_multiplier = 1

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile)) //Each other Defiler toxin doubles the multiplier
		tox_cap_multiplier *= 2

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin))
		tox_cap_multiplier *= 2

	var/tox_loss = L.getToxLoss()
	if(tox_loss > DEFILER_TRANSVITOX_CAP) //If toxin levels are already at their cap, cancel out
		return

	L.setToxLoss(clamp(tox_loss + min(L.getBruteLoss() * 0.1 * tox_cap_multiplier, damage * 0.1 * tox_cap_multiplier), tox_loss, DEFILER_TRANSVITOX_CAP)) //Deal bonus tox damage equal to a % of the lesser of the damage taken or the target's brute damage; capped at DEFILER_TRANSVITOX_CAP.

/datum/reagent/toxin/xeno_sanguinal //deals brute damage and causes persistant bleeding. Causes additional damage for each other xeno chem in the system
	name = "Sanguinal"
	description = "Potent blood coloured toxin that causes constant bleeding and reacts with other xeno toxins to cause rapid tissue damage."
	reagent_state = LIQUID
	color = "#bb0a1e"
	custom_metabolism = 0.4
	overdose_threshold = 10000
	scannable = TRUE
	toxpwr = 0

/datum/reagent/toxin/xeno_sanguinal/on_mob_life(mob/living/L, metabolism)
	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_hemodile)) //Each other Defiler toxin doubles the multiplier
		L.adjustStaminaLoss(DEFILER_SANGUINAL_DAMAGE)

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_neurotoxin))
		L.adjustToxLoss(DEFILER_SANGUINAL_DAMAGE)

	if(L.reagents.get_reagent_amount(/datum/reagent/toxin/xeno_transvitox))
		L.adjustFireLoss(DEFILER_SANGUINAL_DAMAGE)

	L.apply_damage(DEFILER_SANGUINAL_DAMAGE, BRUTE, sharp = TRUE) //Causes brute damage

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.drip(DEFILER_SANGUINAL_DAMAGE) //Causes bleeding

	return ..()

/datum/reagent/toxin/xeno_ozelomelyn // deals capped toxloss and purges at a rapid rate
	name = "Ozelomelyn"
	description = "A potent Xenomorph chemical that quickly purges other chemicals in a bloodstream, causing small scale poisoning in a organism that won't progress. Appears to be strangely water based.."
	reagent_state = LIQUID
	color = "#f1ddcf"
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
	color = "#ac0abb"
	custom_metabolism = REAGENTS_METABOLISM * 0.25
	scannable = TRUE
	overdose_threshold = 20
	overdose_crit_threshold = 50

/datum/reagent/zombium/on_overdose_start(mob/living/L, metabolism)
	RegisterSignal(L, COMSIG_HUMAN_SET_UNDEFIBBABLE, .proc/zombify)

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
	addtimer(CALLBACK(H, /mob/living/carbon/human.proc/revive_to_crit, TRUE, TRUE), SSticker.mode?.zombie_transformation_time)
