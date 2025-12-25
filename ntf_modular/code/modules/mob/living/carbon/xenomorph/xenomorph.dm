/mob/living/carbon/xenomorph/Destroy()
	var/mob/living/carbon/human/user = eaten_mob
	if(user)
		user.handle_unhaul()
		eaten_mob = null
	. = ..()

/mob/living/carbon/human/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount, damage_type, armor_type, effects, armor_penetration, isrightclick)
	if(HAS_TRAIT(src, TRAIT_HAULED))
		to_chat(xeno_attacker, span_warning("[src] is being hauled, we cannot do anything to them."))
		return
	. = ..()
