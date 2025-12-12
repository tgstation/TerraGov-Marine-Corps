
/*////////////////////////
	energy shield module
*/////////////////////////
//worst of ideas brought to you by vide noir

/obj/item/armor_module/module/eshield/absorbant
	name = "Theoritical absorbant shield"
	desc = "nomnomnom"
	slot = ATTACHMENT_SLOT_MODULE
	var/list/blocked_attack_types = list()

	max_shield_health = 40 //less than standard e shield by base
	var/overcharge_max_health = 345

	//pale ass but black-white absorbing/deflect light and shit like that.
	shield_color_low = COLOR_DARKER_RED
	shield_color_mid = COLOR_DARK_RED
	shield_color_full = COLOR_GRAY
	var/shield_color_overmax_full = COLOR_WHITE
	var/shield_color_overmax_full_danger = COLOR_VIVID_RED
	var/last_warning_time
	var/explode_on_overload = TRUE
	///percent chance to go off without exploding.
	var/auto_release_chance = 75

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
		var/shield_left
		if(found_type)
			shield_left = shield_health + incoming_damage
		else
			shield_left = shield_health - incoming_damage
		var/mob/living/affected = parent.loc
		if(shield_left >= overcharge_max_health)
			shield_health = 0
			if((!explode_on_overload) || prob(auto_release_chance)) //chance to save before exploding.
				balloon_alert_to_viewers("emergency release!")
				playsound(src.loc, 'sound/effects/airhiss.ogg', 40)
			else
				balloon_alert_to_viewers("shield break!")
				explosion(src.loc,0,0,0,3,0,0,0,smoke = TRUE,explosion_cause = src)
			affected.remove_filter("eshield")
			STOP_PROCESSING(SSobj, src)
			recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown * 1.2, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT) //Gives it a bunch extra time for the cooldown.
			return (shield_left - overcharge_max_health)
		if(shield_left > 0)
			if(found_type ? (shield_health > max_shield_health) : (shield_health < max_shield_health))
				STOP_PROCESSING(SSobj, src)
				recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT)
			shield_health = shield_left
			var/level
			if(shield_health > max_shield_health)
				level = 1 + ((shield_health - max_shield_health) / (overcharge_max_health - max_shield_health))
			else
				level = shield_health / max_shield_health
			current_color = gradient(0, shield_color_low, 0.5, shield_color_mid, 1, shield_color_full, 1.5, shield_color_overmax_full, 2, shield_color_overmax_full_danger, space = COLORSPACE_HCY, index = level)
			affected.add_filter("eshield", 2, outline_filter(1, current_color))

			spark_system.start()
			if(shield_health > (max_shield_health + ((overcharge_max_health - max_shield_health)/2)) && world.time > (last_warning_time + 2 SECONDS))
				last_warning_time = world.time
				balloon_alert_to_viewers("overloading! [shield_health]/[overcharge_max_health]")
				playsound(src.loc, 'sound/machines/beepalert.ogg', 40)
			return 0
		else
			shield_health = 0
			affected.remove_filter("eshield")
			STOP_PROCESSING(SSobj, src)
			recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown + 1, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT) //Gives it a little extra time for the cooldown.
			return -shield_left
	else
		return incoming_damage

/obj/item/armor_module/module/eshield/absorbant/process()
	if(shield_health < max_shield_health)
		shield_health = min(shield_health + recharge_rate, max_shield_health)
	if(shield_health > max_shield_health)
		shield_health = max(shield_health - recharge_rate, max_shield_health)
	var/level
	if(shield_health > max_shield_health)
		level = 1 + ((shield_health - max_shield_health) / (overcharge_max_health - max_shield_health))
	else
		level = shield_health / max_shield_health
	var/new_color = gradient(0, shield_color_low, 0.5, shield_color_mid, 1, shield_color_full, 1.5, shield_color_overmax_full, 2, shield_color_overmax_full_danger, space = COLORSPACE_HCY, index = level)
	if(level < 0.2 || level > 1.8)
		playsound(parent.loc, 'sound/items/eshield_down.ogg', 40)
	if(new_color != current_color)
		current_color = new_color
		var/mob/living/affected = parent.loc
		affected.add_filter("eshield", 2, outline_filter(1, current_color))
	if(shield_health == max_shield_health) //Once health is full, we don't need to process until the next time we take damage.
		STOP_PROCESSING(SSobj, src)

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
