
/mob/living/carbon/xenomorph/ravager/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD_XENO]
	if(!holder)
		return
	if(stat == DEAD)
		holder.icon_state = "xenohealth0"
		return

	var/amount = health > 0 ? round(health * 100 / maxHealth, 10) : CEILING(health, 10)
	if(!amount && health < 0)
		amount = -1 //don't want the 'zero health' icon when we are crit
	holder.icon_state = "ravagerhealth[amount]"
