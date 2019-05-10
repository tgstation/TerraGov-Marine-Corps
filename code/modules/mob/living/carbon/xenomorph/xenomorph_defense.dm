/*
    Contains most of the procs that are called when a xeno is attacked by something
*/

/mob/living/carbon/Xenomorph/screech_act(mob/living/carbon/Xenomorph/Queen/Q)
	shake_camera(src, 1 SECONDS, 1)

/mob/living/carbon/Xenomorph/has_smoke_protection()
	return TRUE

/mob/living/carbon/Xenomorph/smoke_contact(obj/effect/particle_effect/smoke/S)
	var/protection = max(1 - get_permeability_protection() * S.bio_protection) //0.2 by default
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		adjustFireLoss(10 * protection)
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_PLASMALOSS))
		use_plasma(7)
		if(prob(15))
			to_chat(src, "<span class='xenowarning'>You feel your plasma reserves being drained.</span>")
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_CHEM))
		S.reagents?.reaction(src, TOUCH, S.fraction)