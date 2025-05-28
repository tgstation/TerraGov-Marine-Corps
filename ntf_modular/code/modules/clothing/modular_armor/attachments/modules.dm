
/*////////////////////////
	energy shield module
*/////////////////////////

/obj/item/armor_module/module/eshield/antienergy
	name = "Voidwalker Anti-Energy Shield System"
	desc = "NineTails Corporation's special modification of Svalinn energy shield system, allowing the shield to fully nullify laser and energy attacks and absorb\
them as power, warning: overcharging too much will result in an explosion, accumulated energy dissipates over time using heatsinks."
	icon = 'icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_eshield"
	worn_icon_state = "mod_eshield_a"
	slot = ATTACHMENT_SLOT_MODULE
	soft_armor = list(MELEE = -10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = -5, FIRE = 0, ACID = -5)
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = null, /obj/item/clothing/suit/modular/tdf = "")

	var/overcharge_max_health = 200
	var/decharge_rate = 4

	shield_color_low = COLOR_MAROON
	shield_color_mid = COLOR_MOSTLY_PURE_RED
	shield_color_full = COLOR_BLACK
	var/shield_color_overmax_full = COLOR_WHITE

///Handles the interception of damage.
/obj/item/armor_module/module/eshield/antienergy/intercept_damage(attack_type, incoming_damage, damage_type, silent)
	if(attack_type == COMBAT_TOUCH_ATTACK) //Touch attack so runners can pounce
		return incoming_damage
	if(!shield_health)
		return
	if(damage_type == (ENERGY||LASER) && shield_health < overcharge_max_health) //power...
		shield_health += incoming_damage/4
		spark_system.start()
		if(shield_health > overcharge_max_health/2)
			visible_message("[src] beeps ominiously as it is overcharged beyond safety limits.")
			playsound(src, 'sound/machines/beepalert.ogg')
		return
	else if(damage_type == (ENERGY||LASER) && shield_health > overcharge_max_health)
		playsound(src, 'sound/machines/beepalert.ogg')
		explosion(src.loc,0,0,0,2,2,1,2)
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
			if(1 to INFINITY)
				affected.add_filter("eshield", 2, outline_filter(1, shield_color_overmax_full))
		spark_system.start()
	else
		shield_health = 0
		recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown + 1, TIMER_STOPPABLE) //Gives it a little extra time for the cooldown.
		return -shield_left
	recharge_timer = addtimer(CALLBACK(src, PROC_REF(begin_recharge)), damaged_shield_cooldown, TIMER_STOPPABLE)
	return 0

/obj/item/armor_module/module/eshield/antienergy/process()
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
		if(1 to INFINITY)
			new_color = (shield_color_overmax_full != current_color) ? shield_color_overmax_full : null
	if(!new_color)
		return
	var/mob/living/affected = parent.loc
	affected.remove_filter("eshield")
	affected.add_filter("eshield", 2, outline_filter(1, new_color))
