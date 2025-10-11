
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

	var/overcharge_max_health = 150

	//pale ass but black-white absorbing/deflect light and shit like that.
	shield_color_low = COLOR_DARKER_RED
	shield_color_mid = COLOR_DARK_RED
	shield_color_full = COLOR_GRAY
	var/shield_color_overmax_full = COLOR_WHITE
	var/shield_color_overmax_full_danger = COLOR_VIVID_RED
	var/last_warning_time
	var/explode_on_overload = TRUE
	///percent chance to go off without exploding.
	var/auto_release_chance = 60

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
			shield_health += incoming_damage
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
				var/level
				if(shield_health > max_shield_health)
					level = (shield_health - max_shield_health) / (overcharge_max_health - max_shield_health)
				else
					level = shield_health / max_shield_health
				var/color = gradient(0, shield_color_low, 0.5, shield_color_mid, 1, shield_color_full, 1.5, shield_color_overmax_full, 2, shield_color_overmax_full_danger, space = COLORSPACE_HCY, index = level)
				affected.add_filter("eshield", 2, outline_filter(1, color))
			return 0
		else if(found_type && shield_health > overcharge_max_health)
			if(explode_on_overload)
				balloon_alert_to_viewers("shield break!")
				explosion(src.loc,0,0,0,3,0,0,2, smoke = TRUE)
				var/mob/living/affected = parent.loc
				affected.adjustStaminaLoss(400)
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
			var/level
			if(shield_left > max_shield_health)
				level = (shield_left - max_shield_health) / (overcharge_max_health - max_shield_health)
			else
				level = shield_left / max_shield_health
			var/color = gradient(0, shield_color_low, 0.5, shield_color_mid, 1, shield_color_full, 1.5, shield_color_overmax_full, 2, shield_color_overmax_full_danger, space = COLORSPACE_HCY, index = level)
			affected.add_filter("eshield", 2, outline_filter(1, color))
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
		shield_health = max(shield_health - recharge_rate, max_shield_health)
	if(shield_health == max_shield_health) //Once health is full, we don't need to process until the next time we take damage.
		STOP_PROCESSING(SSobj, src)
		return
	var/level
	if(shield_health > max_shield_health)
		level = (shield_health - max_shield_health) / (overcharge_max_health - max_shield_health)
	else
		level = shield_health / max_shield_health
	var/new_color = gradient(0, shield_color_low, 0.5, shield_color_mid, 1, shield_color_full, 1.5, shield_color_overmax_full, 2, shield_color_overmax_full_danger, space = COLORSPACE_HCY, index = level)
	if(new_color == current_color)
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
