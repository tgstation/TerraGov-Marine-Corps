//Refer to life.dm for caller

/mob/living/carbon/human/handle_status_effects()
	. = ..()


	//The analgesic effect wears off slowly
	analgesic = max(0, analgesic - 1)

	//Periodically double-check embedded_flag
	if(embedded_flag && !(life_tick % 10))
		var/list/E
		E = get_visible_implants(0)
		if(!E.len)
			embedded_flag = 0

	//If you're dirty, your gloves will become dirty, too.
	if(gloves && germ_level > gloves.germ_level && prob(10))
		gloves.germ_level += 1

	if(command_aura_cooldown > 0 && (--command_aura_cooldown == 0))
		update_action_buttons() // Update "Issue Order" action button

	if(command_aura)
		command_aura_tick--
		if(command_aura_tick < 1)
			command_aura = null
	if(command_aura && !stat)
		command_aura_strength = mind.cm_skills.leadership - 1 //2 is SL, so base of 1. Goes up to 3 (CO, XO)
		var/command_aura_range = round(4 + command_aura_strength * 1)
		for(var/mob/living/carbon/human/H in range(command_aura_range, src)) //Goes from 7 for Young Drone to 16 for Ancient Queen
			if(command_aura == "move" && command_aura_strength > H.mobility_new)
				H.mobility_new = command_aura_strength
			if(command_aura == "hold" && command_aura_strength > H.protection_new)
				H.protection_new = command_aura_strength
			if(command_aura == "focus" && command_aura_strength > H.marksman_new)
				H.marksman_new = command_aura_strength

	mobility_aura = mobility_new
	protection_aura = protection_new
	marksman_aura = marksman_new

	mobility_new = 0
	protection_new = 0
	marksman_new = 0
	aura_recovery_multiplier = 0

	//Natural recovery; enhanced by hold/protection aura.
	if(protection_aura)
		aura_recovery_multiplier = 1 + max(0,0.5 + 0.5 * protection_aura) //Protection aura adds +50% recovery rate per point of leadership; +100% for an SL +200% for a CO/XO
		Dizzy(- 3 * aura_recovery_multiplier + 3)
		Jitter(- 3 * aura_recovery_multiplier + 3)
	hud_set_order()

	return 1

/mob/living/carbon/human/handle_knocked_down()
	if(knocked_down) //&& client
		AdjustKnockeddown(-species.knock_down_reduction)
		if(!knocked_down && !no_stun) //anti chain stun
			no_stun = ANTI_CHAINSTUN_TICKS //1 tick reprieve
	return knocked_down

/mob/living/carbon/human/handle_knocked_out()
	if(knocked_out)
		AdjustKnockedout(-species.knock_out_reduction)
	return knocked_out

/mob/living/carbon/human/handle_stunned()
	if(stunned)
		AdjustStunned(-species.stun_reduction)
		if(!stunned && !no_stun) //anti chain stun
			no_stun = ANTI_CHAINSTUN_TICKS //1 tick reprieve
	return stunned
