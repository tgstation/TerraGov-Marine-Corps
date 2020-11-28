/mob/living/carbon/proc/has_smoke_protection()
	if(stat == DEAD) //they don't breath
		return TRUE
	return FALSE

/mob/living/carbon/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(!internal && !has_smoke_protection())
		inhale_smoke(S)

/mob/living/carbon/proc/inhale_smoke(obj/effect/particle_effect/smoke/S)
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
		adjustToxLoss(0.25)
		adjustStaminaLoss(3)
		blur_eyes(2)	
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		adjustOxyLoss(4 + S.strength * 2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO))
		if(!is_blind(src) && has_eyes())
			to_chat(src, "<span class='danger'>Your eyes sting. You can't see!</span>")
		blur_eyes(4)
		blind_eyes(2)
		reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, 5 + S.strength * 2)
		if(prob(10 * S.strength)) //Likely to momentarily freeze up/fall due to arms/hands seizing up
			to_chat(src, "<span class='danger'>You feel your body going numb and lifeless!</span>")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_HEMODILE))
		reagents.add_reagent(/datum/reagent/toxin/xeno_hemodile, 5 + S.strength * 2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_TRANSVITOX))
		reagents.add_reagent(/datum/reagent/toxin/xeno_transvitox, 5 + S.strength * 2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.pre_chem_effect(src)

/mob/living/carbon/smoke_contact(obj/effect/particle_effect/smoke/S)
	. = ..()
	var/protection = .
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO) && (internal || has_smoke_protection())) //either inhaled or this.
		reagents.add_reagent(/datum/reagent/toxin/xeno_neurotoxin, round((3 + S.strength) * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, "<span class='danger'>Your body goes numb where the gas touches it!</span>")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_HEMODILE) && (internal || has_smoke_protection())) //either inhaled or this.
		reagents.add_reagent(/datum/reagent/toxin/xeno_hemodile, round((3 + S.strength) * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, "<span class='danger'>Your muscles' strength drains away where the gas makes contact!</span>")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_TRANSVITOX) && (internal || has_smoke_protection())) //either inhaled or this.
		reagents.add_reagent(/datum/reagent/toxin/xeno_transvitox, round((3 + S.strength) * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, "<span class='danger'>Your exposed wounds coagulate with a dark green tint!</span>")
