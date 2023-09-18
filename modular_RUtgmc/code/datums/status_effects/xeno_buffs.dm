
// ***************************************
// *********** Feast
// ***************************************

/datum/status_effect/xeno_feast/tick()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	var/heal_amount = X.maxHealth*0.08
	for(var/mob/living/carbon/xenomorph/target_xeno AS in cheap_get_xenos_near(X, 4))
		if(target_xeno == X)
			continue
		if(target_xeno.faction != X.faction)
			continue
		HEAL_XENO_DAMAGE(target_xeno, heal_amount, FALSE)
		adjustOverheal(target_xeno, heal_amount / 2)
		new /obj/effect/temp_visual/healing(get_turf(target_xeno))

