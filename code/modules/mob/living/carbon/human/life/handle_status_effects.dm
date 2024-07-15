//Refer to life.dm for caller

/mob/living/carbon/human/handle_status_effects()
	. = ..()


	//The analgesic effect wears off slowly
	analgesic = max(0, analgesic - 1)

	return TRUE

/mob/living/carbon/human/finish_aura_cycle()
	var/update_required = FALSE
	if(set_mobility_aura(received_auras[AURA_HUMAN_MOVE] || 0))
		update_required = TRUE
	if(set_protection_aura(received_auras[AURA_HUMAN_HOLD] || 0))
		update_required = TRUE
	if(set_marksman_aura_aura(received_auras[AURA_HUMAN_FOCUS] || 0))
		update_required = TRUE
	if(set_flag_aura(received_auras[AURA_HUMAN_FLAG] || 0))
		update_required = TRUE

	if(update_required)
		hud_set_order()

	//Natural recovery; enhanced by hold/protection aura.
	if(protection_aura)
		var/aura_recovery_multiplier = 0.5 + 0.5 * protection_aura //Protection aura adds +50% recovery rate per point of leadership; +100% for an SL +200% for a CO/XO
		dizzy(- 3 * aura_recovery_multiplier)
		jitter(- 3 * aura_recovery_multiplier)

	return ..()

///Updates the mobility aura if it is actually changing
/mob/living/carbon/human/proc/set_mobility_aura(new_aura)
	if(mobility_aura == new_aura)
		return
	. = TRUE
	mobility_aura = new_aura
	if(mobility_aura)
		add_movespeed_modifier(MOVESPEED_ID_MOBILITY_AURA, TRUE, 0, NONE, TRUE, -(0.1 + 0.1 * mobility_aura))
		return
	remove_movespeed_modifier(MOVESPEED_ID_MOBILITY_AURA)

///Updates the protection aura if it is actually changing
/mob/living/carbon/human/proc/set_protection_aura(new_aura)
	if(protection_aura == new_aura)
		return
	protection_aura = new_aura
	return TRUE

///Updates the marksman aura if it is actually changing
/mob/living/carbon/human/proc/set_marksman_aura_aura(new_aura)
	if(marksman_aura == new_aura)
		return
	. = TRUE
	marksman_aura = new_aura
	SEND_SIGNAL(src, COMSIG_HUMAN_MARKSMAN_AURA_CHANGED, marksman_aura)

///Updates the flag aura if it is actually changing
/mob/living/carbon/human/proc/set_flag_aura(new_aura)
	if(flag_aura == new_aura)
		return
	. = TRUE
	health_threshold_crit += flag_aura * 10
	flag_aura = new_aura
	health_threshold_crit -= flag_aura * 10
