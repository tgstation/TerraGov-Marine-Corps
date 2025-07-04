
/*////////////////////////
	energy shield module
*/////////////////////////
//worst of ideas brought to you by vide noir

/obj/item/armor_module/module/eshield/absorbant
	name = "Theoritical absorbant shield"
	desc = "nomnomnom"
	slot = ATTACHMENT_SLOT_MODULE
	var/list/blocked_attack_types = list()
	var/deflect_projectile = FALSE

	var/overcharge_max_health = 200
	var/decharge_rate = 5 //danger zone duuu duu dududuu duu

	//pale ass but black-white absorbing/deflect light and shit like that.
	shield_color_low = COLOR_DARKER_RED
	shield_color_mid = COLOR_DARK_RED
	shield_color_full = COLOR_GRAY
	var/shield_color_overmax_full = COLOR_WHITE
	var/shield_color_overmax_full_danger = COLOR_VIVID_RED
	var/last_warning_time
	///how many times the energy converted damage is halved, making shield more durable.
	var/mitigation_rate = 2
	var/explode_on_overload = TRUE
	///percent chance to go off without exploding.
	var/auto_release_chance = 85

/obj/item/armor_module/module/eshield/absorbant/energy
	name = "NT Voidwalker Anti-Energy Shield System"
	desc = "NineTails Corporation's special modification of Svalinn energy shield system, allowing the shield to fully nullify energy attacks by absorbing them in an antienergy field\
converting the absorbed energy into shield power, warning: overcharging too much will result in an explosion, accumulated energy dissipates over time using heatsinks. Does not prevent deflagrates or fires."
	blocked_attack_types = list(LASER, ENERGY)
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = -5, ENERGY = -5, BOMB = 0, BIO = -5, FIRE = 10, ACID = -5)

///Handles the interception of damage.
/obj/item/armor_module/module/eshield/absorbant/intercept_damage(attack_type, incoming_damage, damage_type, silent)
	if(attack_type == COMBAT_TOUCH_ATTACK) //Touch attack so runners can pounce
		return incoming_damage
	if(attack_type == COMBAT_PROJ_ATTACK)
		if(incoming_damage <= 0)
			return 0
		var/found_type = FALSE
		for(var/damage_fuckening in blocked_attack_types) //didnt work any other way.
			if(damage_fuckening == damage_type)
				found_type = TRUE
				break
		if(found_type && shield_health < overcharge_max_health) //power...
			START_PROCESSING(SSobj, src)
			shield_health += incoming_damage/mitigation_rate
			spark_system.start()
			if(shield_health > (overcharge_max_health/1.5) && world.time > (last_warning_time + 2 SECONDS))
				last_warning_time = world.time
				balloon_alert_to_viewers("overloading! [shield_health]/[overcharge_max_health]")
				playsound(src.loc, 'sound/machines/beepalert.ogg', 40)
			if(shield_health >= overcharge_max_health && prob(auto_release_chance && explode_on_overload)) //chance to save before exploding.
				balloon_alert_to_viewers(src, "emergency release!")
				playsound(src.loc, 'sound/effects/airhiss.ogg', 40)
				shield_health = 0
				recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown, TIMER_STOPPABLE)
				return incoming_damage
			var/mob/living/affected = parent.loc
			affected.remove_filter("eshield")
			if(shield_health > 0)
				switch(shield_health / max_shield_health)
					if(0 to 0.33)
						affected.add_filter("eshield", 2, outline_filter(1, shield_color_low))
					if(0.33 to 0.66)
						affected.add_filter("eshield", 2, outline_filter(1, shield_color_mid))
					if(0.66 to 1)
						affected.add_filter("eshield", 2, outline_filter(1, shield_color_full))
					if(1 to 2.3)
						affected.add_filter("eshield", 2, outline_filter(1, shield_color_overmax_full))
					if(2.3 to INFINITY)
						affected.add_filter("eshield", 2, outline_filter(1, shield_color_overmax_full_danger))
			return 0
		else if(found_type && shield_health > overcharge_max_health)
			if(explode_on_overload)
				balloon_alert_to_viewers("shield break!")
				explosion(src.loc,0,0,0,3,0,1,2, smoke = TRUE)
			else
				balloon_alert_to_viewers(src, "overload release!")
				playsound(src.loc, 'sound/effects/airhiss.ogg', 40)
			shield_health = 0
		STOP_PROCESSING(SSobj, src)
		deltimer(recharge_timer)
		var/shield_left = shield_health - incoming_damage
		var/mob/living/affected = parent.loc
		affected.remove_filter("eshield")
		if(shield_left > 0)
			shield_health = shield_left
			switch(shield_left / max_shield_health)
				if(0 to 0.33)
					affected.add_filter("eshield", 2, outline_filter(1, shield_color_low))
				if(0.33 to 0.66)
					affected.add_filter("eshield", 2, outline_filter(1, shield_color_mid))
				if(0.66 to 1)
					affected.add_filter("eshield", 2, outline_filter(1, shield_color_full))
				if(1 to 2.3)
					affected.add_filter("eshield", 2, outline_filter(1, shield_color_overmax_full))
				if(2.3to INFINITY)
					affected.add_filter("eshield", 2, outline_filter(1, shield_color_overmax_full_danger))
			spark_system.start()
		else
			shield_health = 0
			recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown + 1, TIMER_STOPPABLE) //Gives it a little extra time for the cooldown.
			return -shield_left
		recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown, TIMER_STOPPABLE)
		return 0
	else
		return incoming_damage

/obj/item/armor_module/module/eshield/absorbant/process()
	if(shield_health < max_shield_health)
		shield_health = min(shield_health + recharge_rate, max_shield_health)
	if(shield_health > max_shield_health)
		shield_health -= decharge_rate
	if(shield_health == max_shield_health) //Once health is full, we don't need to process until the next time we take damage.
		STOP_PROCESSING(SSobj, src)
		return
	var/new_color
	switch(shield_health/max_shield_health)
		if(0 to 0.2)
			playsound(parent.loc, 'sound/items/eshield_down.ogg', 40)
			new_color = (shield_color_low != current_color) ? shield_color_low : null
		if(0.2 to 0.6)
			new_color = (shield_color_mid != current_color) ? shield_color_mid : null
		if(0.6 to 1)
			new_color = (shield_color_full != current_color) ? shield_color_full : null
		if(1 to 2.3)
			new_color = (shield_color_overmax_full != current_color) ? shield_color_overmax_full : null
		if(2.3 to INFINITY)
			new_color = (shield_color_overmax_full != current_color) ? shield_color_overmax_full_danger : null
	if(!new_color)
		return
	var/mob/living/affected = parent.loc
	affected.remove_filter("eshield")
	affected.add_filter("eshield", 2, outline_filter(1, new_color))

//boolet shield
/obj/item/armor_module/module/eshield/absorbant/ballistic
	name = "KZ Ronin Anti-Ballistics Shield System"
	desc = "Kaizoku Corporation's specialized anti-ballistic shield allowing the shield utilize the kinetic energy created by bullet impacts to overcharge itself.\
warning: overcharging too much will result in an explosion, accumulated energy dissipates over time using heatsinks."
	soft_armor = list(MELEE = -10, BULLET = -10, LASER = 0, ENERGY = 0, BOMB = 0, BIO = -5, FIRE = 10, ACID = -5)
	blocked_attack_types = list(BULLET)
	shield_color_low = COLOR_MAROON
	shield_color_mid = COLOR_OLIVE
	shield_color_full = COLOR_LIGHT_ORANGE
	shield_color_overmax_full = COLOR_VERY_SOFT_YELLOW
	shield_color_overmax_full_danger = COLOR_BRIGHT_ORANGE
