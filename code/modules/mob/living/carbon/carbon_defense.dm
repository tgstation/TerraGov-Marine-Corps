/mob/living/carbon/proc/has_smoke_protection()
	if(stat == DEAD) //they don't breath
		return TRUE
	return FALSE

/mob/living/carbon/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO) && (stat == DEAD || (istype(buckled, /obj/structure/bed/nest) && status_flags & XENO_HOST)))
		return
	if(smoke_delay)
		return
	smoke_delay = TRUE
	addtimer(CALLBACK(src, .proc/remove_smoke_delay), 10)
	smoke_contact(S)
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
		drowsyness += 6
		if(drowsyness >= 18)
			Sleeping(5)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		adjustOxyLoss(4 + S.strength * 2)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO))
		if(!is_blind(src) && has_eyes())
			to_chat(src, "<span class='danger'>Your eyes sting. You can't see!</span>")
		blur_eyes(4)
		blind_eyes(2)
		var/reagent_amount = 4 + S.strength * 2
		reagents.add_reagent("xeno_toxin", reagent_amount)
		if(prob(10 * S.strength)) //Likely to momentarily freeze up/fall due to arms/hands seizing up
			to_chat(src, "<span class='danger'>You feel your body going numb and lifeless!</span>")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.pre_chem_effect(src)

/mob/living/carbon/proc/smoke_contact(obj/effect/particle_effect/smoke/S)
	var/protection = max(1 - get_permeability_protection() * S.bio_protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(2 * protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		if(prob(25 * protection))
			to_chat(src, "<span class='danger'>Your skin feels like it is melting away!</span>")
		adjustFireLoss(S.strength * rand(20, 23) * protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_NEURO) && (internal || has_smoke_protection())) //either inhaled or this.
		var/reagent_amount = 2 + S.strength
		reagents.add_reagent("xeno_toxin", round(reagent_amount * protection, 0.1))
		if(prob(10 * S.strength * protection))
			to_chat(src, "<span class='danger'>Your body goes numb where the gas touches it!</span>")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, VAPOR, S.fraction)