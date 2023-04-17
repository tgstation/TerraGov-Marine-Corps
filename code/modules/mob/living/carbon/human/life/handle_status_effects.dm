//Refer to life.dm for caller

/mob/living/carbon/human/handle_status_effects()
	. = ..()


	//The analgesic effect wears off slowly
	analgesic = max(0, analgesic - 1)

	return TRUE

/mob/living/carbon/human/finish_aura_cycle()

	set_mobility_aura(received_auras[AURA_HUMAN_MOVE] || 0)
	protection_aura = received_auras[AURA_HUMAN_HOLD] || 0
	set_marksman_aura_aura(received_auras[AURA_HUMAN_FOCUS] || 0)

	//Natural recovery; enhanced by hold/protection aura.
	if(protection_aura)
		var/aura_recovery_multiplier = 0.5 + 0.5 * protection_aura //Protection aura adds +50% recovery rate per point of leadership; +100% for an SL +200% for a CO/XO
		dizzy(- 3 * aura_recovery_multiplier)
		jitter(- 3 * aura_recovery_multiplier)
	hud_set_order()

	..()


/mob/living/carbon/human/proc/set_mobility_aura(new_aura)
	if(mobility_aura == new_aura)
		return
	mobility_aura = new_aura
	if(mobility_aura)
		add_movespeed_modifier(MOVESPEED_ID_MOBILITY_AURA, TRUE, 0, NONE, TRUE, -(0.1 + 0.1 * mobility_aura))
		return
	remove_movespeed_modifier(MOVESPEED_ID_MOBILITY_AURA)

///Updates the marksman aura if it is actually changing
/mob/living/carbon/human/proc/set_marksman_aura_aura(new_aura)
	if(marksman_aura == new_aura)
		return
	marksman_aura = new_aura
	SEND_SIGNAL(src, COMSIG_HUMAN_MARKSMAN_AURA_CHANGED, marksman_aura)
