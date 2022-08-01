/mob/living/carbon/proc/has_smoke_protection()
	if(stat == DEAD || species.species_flags & NO_BREATHE) //they don't breath
		return TRUE
	return FALSE

/mob/living/carbon/effect_smoke(atom/movable/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(!internal && !has_smoke_protection())
		inhale_smoke(S)

/mob/living/carbon/proc/inhale_smoke(atom/movable/effect/particle_effect/smoke/S)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_COUGH) && prob(30))
		emote("cough")
	else if(CHECK_BITFIELD(S.smoke_traits, SMOKE_GASP) && prob(30))
		emote("gasp")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_FOUL) && prob(30))
		drop_held_item()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_OXYLOSS))
		adjustOxyLoss(4)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_SLEEP))
		adjustDrowsyness(6)
		if(drowsyness >= 18)
			Sleeping(10 SECONDS)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(12)
		blur_eyes(2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_PLASMALOSS))
		blur_eyes(2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		adjustOxyLoss(4 + S.strength * 2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO))
		if(!CHECK_BITFIELD(S.smoke_traits, SMOKE_NEURO_LIGHT) && !is_blind(src) && has_eyes()) //Only full neurogas blinds
			to_chat(src, span_danger("Your eyes sting. You can't see!"))
			blind_eyes(2)
			blur_eyes(4)
			reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
		else
			reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
		if(prob(10 * S.strength)) //Likely to momentarily freeze up/fall due to arms/hands seizing up
			to_chat(src, span_danger("You feel your body going numb and lifeless!"))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_HEMODILE))
		reagents.add_reagent(/datum/reagent/toxin/xeno_hemodile, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_TRANSVITOX))
		reagents.add_reagent(/datum/reagent/toxin/xeno_transvitox, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_SANGUINAL))
		reagents.add_reagent(/datum/reagent/toxin/xeno_sanguinal, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_OZELOMELYN))
		reagents.add_reagent(/datum/reagent/toxin/xeno_ozelomelyn, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_SATRAPINE))
		to_chat(src, span_danger("Your eyes are burning!"))
		blur_eyes(4)
		reagents.add_reagent(/datum/reagent/toxin/satrapine, GAS_INHALE_REAGENT_TRANSFER_AMOUNT * S.strength)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.pre_chem_effect(src)

/mob/living/carbon/smoke_contact(atom/movable/effect/particle_effect/smoke/S)
	. = ..()
	var/protection = .
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO) && (internal || has_smoke_protection())) //either inhaled or this.
		if(CHECK_BITFIELD(S.smoke_traits, SMOKE_NEURO_LIGHT))
			reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, round(GAS_INHALE_REAGENT_TRANSFER_AMOUNT * 0.6 * S.strength * protection, 0.1))
		else
			reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, round(GAS_INHALE_REAGENT_TRANSFER_AMOUNT * 0.6 * S.strength * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, span_danger("Your body goes numb where the gas touches it!"))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_HEMODILE) && (internal || has_smoke_protection())) //either inhaled or this.
		reagents.add_reagent(/datum/reagent/toxin/xeno_hemodile, round(GAS_INHALE_REAGENT_TRANSFER_AMOUNT * 0.6 * S.strength * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, span_danger("Your muscles' strength drains away where the gas makes contact!"))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_TRANSVITOX) && (internal || has_smoke_protection())) //either inhaled or this.
		reagents.add_reagent(/datum/reagent/toxin/xeno_transvitox, round(GAS_INHALE_REAGENT_TRANSFER_AMOUNT * 0.6 * S.strength * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, span_danger("Your exposed wounds coagulate with a dark green tint!"))
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_SATRAPINE) && (internal || has_smoke_protection())) //either inhaled or this.
		reagents.add_reagent(/datum/reagent/toxin/satrapine, round(GAS_INHALE_REAGENT_TRANSFER_AMOUNT * 0.6 * S.strength * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, span_danger("Your whole body feels like it's burning!"))
