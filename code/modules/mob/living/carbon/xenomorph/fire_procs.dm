/mob/living/carbon/xenomorph/can_ignite()
	. = ..()
	if(!.)
		return
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return FALSE
	return TRUE

/mob/living/carbon/xenomorph/on_ignite()
	for(var/obj/item/clothing/mask/facehugger/hugger in get_held_items())
		hugger.kill_hugger()
		dropItemToGround(hugger)

/mob/living/carbon/xenomorph/handle_fire(stacks)
	. = ..()
	if(resting)
		adjust_burning(-1)

	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	apply_damage((stacks + 3), BURN, blocked = FIRE)

/mob/living/carbon/xenomorph/fire_act(burn_level)
	if(status_flags & GODMODE)
		return
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	return ..()
