//Refer to life.dm for caller

/mob/living/carbon/human/handle_status_effects()
	. = ..()


	//The analgesic effect wears off slowly
	analgesic = max(0, analgesic - 1)

	//If you're dirty, your gloves will become dirty, too.
	if(gloves && germ_level > gloves.germ_level && prob(10))
		gloves.germ_level++

	if(command_aura_cooldown > 0 && (--command_aura_cooldown == 0))
		update_action_buttons() // Update "Issue Order" action button

	if(command_aura)
		command_aura_tick--

		if(command_aura_tick < 1 || IsMute()) //Null the command aura if we're muted or its duration is over
			command_aura = null

		if(stat == CONSCIOUS) //Must be conscious
			command_aura_strength = skills.getRating("leadership") - 1
			var/command_aura_range = round(4 + command_aura_strength * 1)
			for(var/mob/living/carbon/human/H in range(command_aura_range, src))
				if(H.faction == faction) //You can only give orders to people in your own faction
					if(command_aura == "move" && command_aura_strength > H.mobility_new)
						H.mobility_new = command_aura_strength
					if(command_aura == "hold" && command_aura_strength > H.protection_new)
						H.protection_new = command_aura_strength
					if(command_aura == "focus" && command_aura_strength > H.marksman_new)
						H.marksman_new = command_aura_strength

	set_mobility_aura(mobility_new)
	protection_aura = protection_new
	marksman_aura = marksman_new

	mobility_new = 0
	protection_new = 0
	marksman_new = 0
	aura_recovery_multiplier = 0

	//Natural recovery; enhanced by hold/protection aura.
	if(protection_aura)
		aura_recovery_multiplier = 1 + max(0,0.5 + 0.5 * protection_aura) //Protection aura adds +50% recovery rate per point of leadership; +100% for an SL +200% for a CO/XO
		dizzy(- 3 * aura_recovery_multiplier + 3)
		jitter(- 3 * aura_recovery_multiplier + 3)
	hud_set_order()

	return TRUE


/mob/living/carbon/human/proc/set_mobility_aura(new_aura)
	if(mobility_aura == new_aura)
		return
	mobility_aura = new_aura
	if(mobility_aura)
		add_movespeed_modifier(MOVESPEED_ID_MOBILITY_AURA, TRUE, 0, NONE, TRUE, -(0.1 + 0.1 * mobility_aura))
		return
	remove_movespeed_modifier(MOVESPEED_ID_MOBILITY_AURA)
